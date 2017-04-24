/****************************************************************************
**
*W  iostream.c                  GAP source                       Steve Linton
**
**
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**
**  This file will contains the functions for communicating with other
**  processes via ptys and sockets
**
**  The eventual intent is that there will be InputOutputStreams at the GAP
**  level with some API to be defined, and two ways of creating them. One is
**  like Process except that the external process is left running, the other
**  connects as client to a specified socket.
**
**  At this level, we provide the two interfaces separately. For each we have
**  an integer identifer for each open connection, and creation, read and
**  write functions, and possibly some sort of probe function.
**
*/

#include <src/system.h>                 /* system dependent part */
#include <src/gapstate.h>

#include <src/iostream.h>               /* file input/output */

#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/lists.h>                  /* generic lists */
#include <src/listfunc.h>               /* functions for generic lists */

#include <src/plist.h>                  /* plain lists */
#include <src/stringobj.h>              /* strings */

#include <src/records.h>                /* generic records */
#include <src/bool.h>                   /* True and False */

#include <src/code.h>                   /* coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */

#include <stdio.h>                      /* standard input/output functions */
#include <stdlib.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>

#include <signal.h>
#include <fcntl.h>


#include <errno.h>

#include <termios.h>

#if HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#include <assert.h>

#if HAVE_OPENPTY
  #if HAVE_UTIL_H
    #include <util.h>     /* for openpty() on Mac OS X, OpenBSD and NetBSD */
  #elif HAVE_LIBUTIL_H
    #include <libutil.h>  /* for openpty() on FreeBSD */
  #elif HAVE_PTY_H
    #include <pty.h>      /* for openpty() on Cygwin, Interix, OSF/1 4 and 5 */
  #endif
#endif


// LOCKING
// In HPC-GAP, be sure to HashLock PtyIOStreams before accessing any of
// the IOStream related variables, including FreeptyIOStreams

typedef struct {
  int childPID;    /* Also used as a link to make a linked free list */
  int ptyFD;       /* GAP reading from external prog */
  UInt inuse;     /* we need to scan all the "live" structures when we have had SIGCHLD
                     so, for now, we just walk the array for the ones marked in use */
  UInt changed;   /* set non-zero by the signal handler if our child has
                     done something -- stopped or exited */
  int status;     /* status from wait3 -- meaningful only if changed is 1 */
  UInt blocked;   /* we have already reported a problem, which is still there */
  UInt alive;     /* gets set after waiting for a child actually fails
                     implying that the child has vanished under our noses */
} PtyIOStream;

enum {
    /* maximal number of pseudo ttys we will allocate */
    MAX_PTYS = 64,

    /* maximal length of argument string for CREATE_PTY_IOSTREAM */
    MAX_ARGS = 1000
};

static PtyIOStream PtyIOStreams[MAX_PTYS];

// FreePtyIOStreams is the index of the first unused slot of the PtyIOStreams
// array, or else -1 if there is none. The childPID field of each free slot in
// turn is set to the position of the next free slot (or -1), so that the free
// slots form a linked list.
static Int FreePtyIOStreams;

static Int NewStream( void )
{
  Int stream = -1;
  if ( FreePtyIOStreams != -1 )
  {
      stream = FreePtyIOStreams;
      FreePtyIOStreams = PtyIOStreams[stream].childPID;
  }
  return stream;
}

static void FreeStream( UInt stream)
{
   PtyIOStreams[stream].childPID = FreePtyIOStreams;
   FreePtyIOStreams = stream;
}

/****************************************************************************
**
*F  SignalChild(<stream>) . .. . . . . . . . . . .  interrupt the child process
*/
static void SignalChild (UInt stream, UInt sig)
{
    if ( PtyIOStreams[stream].childPID != -1 )
    {
        kill( PtyIOStreams[stream].childPID, sig );
    }
}

/****************************************************************************
**
*F  KillChild(<stream>) . . . . . . . . . . . . . . . .  kill the child process
*/
static void KillChild (UInt stream)
{
    if ( PtyIOStreams[stream].childPID != -1 )
    {
        close(PtyIOStreams[stream].ptyFD);
        SignalChild( stream, SIGKILL );
    }
}




/****************************************************************************
**
*F  GetMasterPty( <fid> ) . . . . . . . . .  open a master pty (from "xterm")
*/

#if HAVE_OPENPTY

static UInt OpenPty( int *master, int *slave )
{
    /* openpty is available on OpenBSD, NetBSD and FreeBSD, Mac OS X,
       Cygwin, Interix, OSF/1 4 and 5, and glibc (since 1998), and hence
       on most modern Linux systems. See also:
       http://www.gnu.org/software/gnulib/manual/html_node/openpty.html */
    return (openpty(master, slave, NULL, NULL, NULL) < 0);
}

#elif HAVE_POSIX_OPENPT

static UInt OpenPty( int *master, int *slave )
{
    /* Attempt to use POSIX 98 pseudo ttys. Opening a master tty is done
       via posix_openpt, which is available on virtually every current
       UNIX system; indeed, according to gnulib, it is available on at
       least the following systems:
         - glibc >= 2.2.1 (released January 2001; but is a stub on GNU/Hurd),
         - Mac OS X >= 10.4 (released April 2005),
         - FreeBSD >= 5.1 (released June 2003),
         - NetBSD >= 3.0 (released December 2005),
         - AIX >= 5.2 (released October 2002),
         - HP-UX >= 11.31 (released February 2007),
         - Solaris >= 10 (released January 2005),
         - Cygwin >= 1.7 (released December 2009).
       Systems lacking posix_openpt (in addition to older versions of
       the systems listed above) include:
         - OpenBSD
         - Minix 3.1.8
         - IRIX 6.5
         - OSF/1 5.1
         - mingw
         - MSVC 9
         - Interix 3.5
         - BeOS
       */
    *master = posix_openpt( O_RDWR | O_NOCTTY );
    if (*master < 0) {
        Pr( "OpenPty: posix_openpt failed\n", 0L, 0L );
        return 1;
    }

    if (grantpt(*master)) {
        Pr( "OpenPty: grantpt failed\n", 0L, 0L );
        goto error;
    }
    if (unlockpt(*master)) {
        close(*master);
        Pr( "OpenPty: unlockpt failed\n", 0L, 0L );
        goto error;
    }

    ttyname = ;
    *slave = open( ptsname(*master), O_RDWR, 0 );
    if ( *slave < 0 ) {
        Pr( "OpenPty: opening slave tty failed\n", 0L, 0L );
        goto error;
    }
    return 0;

error:
    close(*master);
    return 1;
}

#else

static UInt OpenPty( int *master, int *slave )
{
    Pr( "no pseudo tty support available\n", 0L, 0L );
    return 1;
}

#endif


/****************************************************************************
**
*F  StartChildProcess( <dir>, <name>, <args> ) . . . . start a subprocess using ptys
**  returns the stream number of the IOStream that is connected to the new processs
*/

static void ChildStatusChanged( int whichsig )
{
  UInt i;
  int status;
  int retcode;
  assert(whichsig == SIGCHLD);
  HashLock(PtyIOStreams);
  for (i = 0; i < MAX_PTYS; i++) {
      if (PtyIOStreams[i].inuse) {
          retcode = waitpid( PtyIOStreams[i].childPID, &status, WNOHANG | WUNTRACED );
          if (retcode != -1 && retcode != 0 && (WIFEXITED(status) || WIFSIGNALED(status)) ) {
              PtyIOStreams[i].changed = 1;
              PtyIOStreams[i].status = status;
              PtyIOStreams[i].blocked = 0;
          }
      }
  }
  HashUnlock(PtyIOStreams);

#if !defined(HPCGAP)
  /* Collect up any other zombie children */
  do {
      retcode = waitpid( -1, &status, WNOHANG);
      if (retcode == -1 && errno != ECHILD)
          Pr("#E Unexpected waitpid error %d\n",errno, 0);
  } while (retcode != 0 && retcode != -1);

  signal(SIGCHLD, ChildStatusChanged);
#endif
}

#ifdef HPCGAP
Obj FuncDEFAULT_SIGCHLD_HANDLER(Obj self) {
  extern void ChildStatusChanged(int signr);
  ChildStatusChanged(SIGCHLD);
  return (Obj) 0;
}
#endif

static Int StartChildProcess ( Char *dir, Char *prg, Char *args[] )
{
    int             slave;   /* pipe to child                   */
    Int            stream;

    struct termios  tst;     /* old and new terminal state      */

    HashLock(PtyIOStreams);

    /* Get a stream record */
    stream = NewStream();
    if (stream == -1) {
        HashUnlock(PtyIOStreams);
        return -1;
    }
    
    /* open pseudo terminal for communication with gap */
    if ( OpenPty(&PtyIOStreams[stream].ptyFD, &slave) )
    {
        Pr( "open pseudo tty failed (errno %d)\n", errno, 0);
        FreeStream(stream);
        HashUnlock(PtyIOStreams);
        return -1;
    }

    /* Now fiddle with the terminal sessions on the pty */
    if ( tcgetattr( slave, &tst ) == -1 )
    {
        Pr( "tcgetattr on slave pty failed (errno %d)\n", errno, 0);
        goto cleanup;

    }
    tst.c_cc[VINTR] = 0377;
    tst.c_cc[VQUIT] = 0377;
    tst.c_iflag    &= ~(INLCR|ICRNL);
    tst.c_cc[VMIN]  = 1;
    tst.c_cc[VTIME] = 0;
    tst.c_lflag    &= ~(ECHO|ICANON);
    tst.c_oflag    &= ~(ONLCR);
    if ( tcsetattr( slave, TCSANOW, &tst ) == -1 )
    {
        Pr("tcsetattr on slave pty failed (errno %d)\n", errno, 0);
        goto cleanup;
    }

    /* set input to non blocking operation */
    /* Not any more */

    PtyIOStreams[stream].inuse = 1;
    PtyIOStreams[stream].alive = 1;
    PtyIOStreams[stream].blocked = 0;
    PtyIOStreams[stream].changed = 0;
    /* fork */
    PtyIOStreams[stream].childPID = fork();
    if ( PtyIOStreams[stream].childPID == 0 )
    {
        /* Set up the child */
        close(PtyIOStreams[stream].ptyFD);
        if ( dup2( slave, 0 ) == -1)
            _exit(-1);
        fcntl( 0, F_SETFD, 0 );
        
        if (dup2( slave, 1 ) == -1)
            _exit(-1);
        fcntl( 1, F_SETFD, 0 );
        
        if ( chdir(dir) == -1 ) {
            _exit(-1);
        }

#if HAVE_SETPGID
        setpgid(0,0);
#endif

        execv( prg, args );

        /* This should never happen */
        close(slave);
        _exit(1);
    }

    /* Now we're back in the master */
    /* check if the fork was successful */
    if ( PtyIOStreams[stream].childPID == -1 )
    {
        Pr( "Panic: cannot fork to subprocess (errno %d).\n", errno, 0);
        goto cleanup;
    }
    close(slave);
    
    
    HashUnlock(PtyIOStreams);
    return stream;

 cleanup:
    close(slave);
    close(PtyIOStreams[stream].ptyFD);
    PtyIOStreams[stream].inuse = 0;
    FreeStream(stream);
    HashUnlock(PtyIOStreams);
    return -1;
}


// This function assumes that the caller invoked HashLock(PtyIOStreams).
// It unlocks just before throwing any error.
static void HandleChildStatusChanges( UInt pty)
{
  /* common error handling, when we are asked to read or write to a stopped
     or dead child */
  if (PtyIOStreams[pty].alive == 0)
  {
      PtyIOStreams[pty].changed = 0;
      PtyIOStreams[pty].blocked = 0;
      HashUnlock(PtyIOStreams);
      ErrorQuit("Child Process is unexpectedly dead", (Int) 0L, (Int) 0L);
      return;
  }
  if (PtyIOStreams[pty].blocked)
  {
      HashUnlock(PtyIOStreams);
      ErrorQuit("Child Process is still dead", (Int)0L,(Int)0L);
      return;
  }
  if (PtyIOStreams[pty].changed)
  {
      PtyIOStreams[pty].blocked = 1;
      PtyIOStreams[pty].changed = 0;
      Int cPID = PtyIOStreams[pty].childPID;
      Int status = PtyIOStreams[pty].status;
      HashUnlock(PtyIOStreams);
      ErrorQuit("Child Process %d has stopped or died, status %d",
                cPID, status);
      return;
  }
}

Obj FuncCREATE_PTY_IOSTREAM( Obj self, Obj dir, Obj prog, Obj args )
{
  Obj  allargs[MAX_ARGS+1];
  Char *argv[MAX_ARGS+2];
  UInt i,len;
  Int pty;
  len = LEN_LIST(args);
  if (len > MAX_ARGS)
    ErrorQuit("Too many arguments",0,0);
  ConvString(dir);
  ConvString(prog);
  for (i = 1; i <=len; i++)
    {
      allargs[i] = ELM_LIST(args,i);
      ConvString(allargs[i]);
    }
  /* From here we cannot afford to have a garbage collection */
  argv[0] = CSTR_STRING(prog);
  for (i = 1; i <=len; i++)
    {
      argv[i] = CSTR_STRING(allargs[i]);
    }
  argv[i] = (Char *)0;
  pty = StartChildProcess( CSTR_STRING(dir) , CSTR_STRING(prog), argv );
  if (pty < 0)
    return Fail;
  else
    return INTOBJ_INT(pty);
}


static Int ReadFromPty2( UInt stream, Char *buf, Int maxlen, UInt block)
{
  /* read at most maxlen bytes from stream, into buf.
    If block is non-zero then wait for at least one byte
    to be available. Otherwise don't. Return the number of
    bytes read, or -1 for error. A blocking return having read zero bytes
    definitely indicates an end of file */

  Int nread = 0;
  int ret;
  
  while (maxlen > 0)
    {
#if HAVE_SELECT
      if (!block || nread > 0)
      {
        fd_set set;
        struct timeval tv;
        do {
          FD_ZERO( &set);
          FD_SET( PtyIOStreams[stream].ptyFD, &set );
          tv.tv_sec = 0;
          tv.tv_usec = 0;
          ret =  select( PtyIOStreams[stream].ptyFD + 1, &set, NULL, NULL, &tv);
        } while (ret == -1 && errno == EAGAIN);
        if (ret == -1 && nread == 0)
          return -1;
        if (ret < 1)
          return nread ? nread : -1;
      }
#endif
      do {
        ret = read(PtyIOStreams[stream].ptyFD, buf, maxlen);
      } while (ret == -1 && errno == EAGAIN);
      if (ret == -1 && nread == 0)
        return -1;
      if (ret < 1)
        return nread;
      nread += ret;
      buf += ret;
      maxlen -= ret;
    }
  return nread;
}


static UInt WriteToPty ( UInt stream, Char *buf, Int len )
{
    Int         res;
    Int         old;
    if (len < 0) {
      // FIXME: why allow 'len' to be negative here? To allow
      // invoking a "raw" version of `write` perhaps? But we don't
      // seem to use that anywhere. So perhaps get rid of it or
      // even turn it into an error?!
      return  write( PtyIOStreams[stream].ptyFD, buf, -len );
    }
    old = len;
    while ( 0 < len )
    {
        res = write( PtyIOStreams[stream].ptyFD, buf, len );
        if ( res < 0 )
        {
          HandleChildStatusChanges(stream);
            if ( errno == EAGAIN )
              {
                continue;
              }
            else
              // FIXME: by returning errno, we make it impossible for the caller
              // to detect errors.
              return errno;
        }
        len  -= res;
        buf += res;
    }
    return old;
}

Obj FuncWRITE_IOSTREAM( Obj self, Obj stream, Obj string, Obj len )
{
  UInt pty = INT_INTOBJ(stream);
  HashLock(PtyIOStreams);
  if (!PtyIOStreams[pty].inuse) {
    HashUnlock(PtyIOStreams);
    ErrorMayQuit("IOSTREAM %d is not in use",pty,0L);
    return Fail;
  }

  HandleChildStatusChanges(pty);
  ConvString(string);
  UInt result = WriteToPty(pty, CSTR_STRING(string), INT_INTOBJ(len));
  HashUnlock(PtyIOStreams);
  return INTOBJ_INT(result);
}

Obj FuncREAD_IOSTREAM( Obj self, Obj stream, Obj len )
{
  UInt pty = INT_INTOBJ(stream);
  HashLock(PtyIOStreams);
  if (!PtyIOStreams[pty].inuse) {
    HashUnlock(PtyIOStreams);
    ErrorMayQuit("IOSTREAM %d is not in use",pty,0L);
    return Fail;
  }
  
  /* HandleChildStatusChanges(pty);   Omit this to allow picking up "trailing" bytes*/
  Obj string = NEW_STRING(INT_INTOBJ(len));
  Int ret = ReadFromPty2(pty, CSTR_STRING(string), INT_INTOBJ(len), 1);
  HashUnlock(PtyIOStreams);
  if (ret == -1)
    return Fail;
  SET_LEN_STRING(string, ret);
  ResizeBag(string, SIZEBAG_STRINGLEN(ret));
  return string;
}

Obj FuncREAD_IOSTREAM_NOWAIT(Obj self, Obj stream, Obj len)
{
  UInt pty = INT_INTOBJ(stream);
  HashLock(PtyIOStreams);
  if (!PtyIOStreams[pty].inuse) {
    HashUnlock(PtyIOStreams);
    ErrorMayQuit("IOSTREAM %d is not in use",pty,0L);
    return Fail;
  }
  
  /* HandleChildStatusChanges(pty);   Omit this to allow picking up "trailing" bytes*/
  Obj string = NEW_STRING(INT_INTOBJ(len));
  Int ret = ReadFromPty2(pty, CSTR_STRING(string), INT_INTOBJ(len), 0);
  HashUnlock(PtyIOStreams);
  if (ret == -1)
    return Fail;
  SET_LEN_STRING(string, ret);
  ResizeBag(string, SIZEBAG_STRINGLEN(ret));
  return string;
}

Obj FuncKILL_CHILD_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  HashLock(PtyIOStreams);
  if (!PtyIOStreams[pty].inuse) {
    HashUnlock(PtyIOStreams);
    ErrorMayQuit("IOSTREAM %d is not in use",pty,0L);
    return Fail;
  }
  
  /* Don't check for child having changes status */
  KillChild( pty );

  HashUnlock(PtyIOStreams);
  return 0;
}

Obj FuncSIGNAL_CHILD_IOSTREAM( Obj self, Obj stream , Obj sig)
{
  UInt pty = INT_INTOBJ(stream);
  HashLock(PtyIOStreams);
  if (!PtyIOStreams[pty].inuse) {
    HashUnlock(PtyIOStreams);
    ErrorMayQuit("IOSTREAM %d is not in use",pty,0L);
    return Fail;
  }
  
  /* Don't check for child having changes status */
  SignalChild( pty, INT_INTOBJ(sig) );

  HashUnlock(PtyIOStreams);
  return 0;
}

Obj FuncCLOSE_PTY_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  HashLock(PtyIOStreams);
  if (!PtyIOStreams[pty].inuse) {
    HashUnlock(PtyIOStreams);
    ErrorMayQuit("IOSTREAM %d is not in use",pty,0L);
    return Fail;
  }

  PtyIOStreams[pty].inuse = 0;

  /* Close down the child */
  int status;
  int retcode = close(PtyIOStreams[pty].ptyFD);
  if (retcode)
    Pr("Strange close return code %d\n",retcode, 0);
  kill(PtyIOStreams[pty].childPID, SIGTERM);
  retcode = waitpid(PtyIOStreams[pty].childPID, &status, 0);
  FreeStream(pty);
  HashUnlock(PtyIOStreams);
  return 0;
}

Obj FuncIS_BLOCKED_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  HashLock(PtyIOStreams);
  if (!PtyIOStreams[pty].inuse) {
    HashUnlock(PtyIOStreams);
    ErrorMayQuit("IOSTREAM %d is not in use",pty,0L);
    return Fail;
  }
  
  int isBlocked = (PtyIOStreams[pty].blocked || PtyIOStreams[pty].changed || !PtyIOStreams[pty].alive);
  HashUnlock(PtyIOStreams);
  return isBlocked ? True : False;
}

Obj FuncFD_OF_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  HashLock(PtyIOStreams);
  if (!PtyIOStreams[pty].inuse) {
    HashUnlock(PtyIOStreams);
    ErrorMayQuit("IOSTREAM %d is not in use",pty,0L);
    return Fail;
  }
  
  Obj result = INTOBJ_INT(PtyIOStreams[pty].ptyFD);
  HashUnlock(PtyIOStreams);
  return result;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "CREATE_PTY_IOSTREAM", 3, "dir, prog, args",
      FuncCREATE_PTY_IOSTREAM, "src/iostream.c:CREATE_PTY_IOSTREAM" },
    
    { "WRITE_IOSTREAM", 3, "stream, string, len",
      FuncWRITE_IOSTREAM, "src/iostream.c:WRITE_IOSTREAM" },
    
    { "READ_IOSTREAM", 2, "stream, len",
      FuncREAD_IOSTREAM, "src/iostream.c:READ_IOSTREAM" },

    { "READ_IOSTREAM_NOWAIT", 2, "stream, len",
      FuncREAD_IOSTREAM_NOWAIT, "src/iostream.c:READ_IOSTREAM_NOWAIT" },

    { "KILL_CHILD_IOSTREAM", 1, "stream",
      FuncKILL_CHILD_IOSTREAM, "src/iostream.c:KILL_CHILD_IOSTREAM" },

    { "CLOSE_PTY_IOSTREAM", 1, "stream",
      FuncCLOSE_PTY_IOSTREAM, "src/iostream.c:CLOSE_PTY_IOSTREAM" },

    { "SIGNAL_CHILD_IOSTREAM", 2, "stream, signal",
      FuncSIGNAL_CHILD_IOSTREAM, "src/iostream.c:SIGNAL_CHILD_IOSTREAM" },
    
    { "IS_BLOCKED_IOSTREAM", 1, "stream",
      FuncIS_BLOCKED_IOSTREAM, "src/iostream.c:IS_BLOCKED_IOSTREAM" },
    
    { "FD_OF_IOSTREAM", 1, "stream",
      FuncFD_OF_IOSTREAM, "src/iostream.c:FD_OF_IOSTREAM" },

#ifdef HPCGAP
    { "DEFAULT_SIGCHLD_HANDLER", 0, "",
      FuncDEFAULT_SIGCHLD_HANDLER, "src/threadapi.c:DEFAULT_SIGCHLD_HANDLER" },
#endif

      {0} };
  
/* NB Should probably do some checks preSave for open files etc and refuse to save
   if any are found */

/****************************************************************************
**
*F  postResore( <module> ) . . . . . . .re-initialise library data structures
*/

static Int postRestore (
    StructInitInfo *    module )
{
    /* return success                                                      */
    return 0;
}

/****************************************************************************
**
*F  InitKernel( <module> ) . . . . . . .  initialise kernel data structures
*/

static Int InitKernel( 
      StructInitInfo * module )
{
  UInt i;
  PtyIOStreams[0].childPID = -1;
  for (i = 1; i < MAX_PTYS; i++)
    {
      PtyIOStreams[i].childPID = i-1;
      PtyIOStreams[i].inuse = 0;
    }
  FreePtyIOStreams = MAX_PTYS-1;

  /* init filters and functions                                          */
  InitHdlrFuncsFromTable( GVarFuncs );

#if !defined(HPCGAP)
  /* Set up the trap to detect future dying children */
  signal( SIGCHLD, ChildStatusChanged );
#endif

  return 0;
}

/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/

static Int InitLibrary( 
      StructInitInfo * module )
{
      /* init filters and functions                                          */
  InitGVarFuncsFromTable( GVarFuncs );

  return postRestore( module );
}

/****************************************************************************
**
*F  InitInfoSysFiles()  . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "iostream",                         /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    postRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoIOStream ( void )
{
    return &module;
}


/****************************************************************************
**
*E  iostream.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
