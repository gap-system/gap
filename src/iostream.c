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
**  The eventual intent is that there will be InputOutputStreams at the GAP level
**  with some API to be defined, and two ways of creating them. One is like Process
**  except that the external process is left running, the other connects as client
**  to a specified socket.
**
**  At this level, we provide the two interfaces separately. For each we have an integer
**  identifer for each open connection, and creation, read and write functions, and possibly
**  some sort of probe function
**
*/

#include <src/system.h>                 /* system dependent part */

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

#if HAVE_UTIL_H
#include <util.h>                       /* for openpty() on Mac OS X, OpenBSD and NetBSD */
#endif

#if HAVE_LIBUTIL_H
#include <libutil.h>                    /* for openpty() on FreeBSD */
#endif

#if HAVE_PTY_H
#include <pty.h>                        /* for openpty() on Cygwin, Interix, OSF/1 4 and 5 */
#endif


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

/* maximal number of pseudo ttys we will allocate */
#define MAX_PTYS 64

/* maximal length of argument string for CREATE_PTY_IOSTREAM */
#define MAX_ARGS 1000

static PtyIOStream PtyIOStreams[MAX_PTYS];
static Int FreePtyIOStreams;

Int NewStream( void )
{
  Int stream = -1;
  HashLock(PtyIOStreams);
  if ( FreePtyIOStreams != -1 )
  {
      stream = FreePtyIOStreams;
      FreePtyIOStreams = PtyIOStreams[stream].childPID;
  }
  HashUnlock(PtyIOStreams);
  return stream;
}

void FreeStream( UInt stream)
{
   HashLock(PtyIOStreams);
   PtyIOStreams[stream].childPID = FreePtyIOStreams;
   FreePtyIOStreams = stream;
   HashUnlock(PtyIOStreams);
}

/****************************************************************************
**
*F  SignalChild(<stream>) . .. . . . . . . . . . .  interrupt the child process
*/
void SignalChild (UInt stream, UInt sig)
{
    HashLock(PtyIOStreams);
    if ( PtyIOStreams[stream].childPID != -1 )
    {
        kill( PtyIOStreams[stream].childPID, sig );
    }
    HashUnlock(PtyIOStreams);
}

/****************************************************************************
**
*F  KillChild(<stream>) . . . . . . . . . . . . . . . .  kill the child process
*/
void KillChild (UInt stream)
{
    HashLock(PtyIOStreams);
    if ( PtyIOStreams[stream].childPID != -1 )
    {
        close(PtyIOStreams[stream].ptyFD);
        SignalChild( stream, SIGKILL );
    }
    HashUnlock(PtyIOStreams);
}




/****************************************************************************
**
*F  GetMasterPty( <fid> ) . . . . . . . . .  open a master pty (from "xterm")
*/

#if !defined(HAVE_OPENPTY)

#ifndef SYS_PTYDEV
#  ifdef hpux
#    define SYS_PTYDEV          "/dev/ptym/ptyxx"
#  else
#    define SYS_PTYDEV          "/dev/ptyxx"
#  endif
#endif

#ifndef SYS_TTYDEV
#  ifdef hpux
#    define SYS_TTYDEV          "/dev/pty/ttyxx"
#  else
#    define SYS_TTYDEV          "/dev/ttyxx"
#  endif
#endif

#ifndef SYS_PTYCHAR1
#  ifdef hpux
#    define SYS_PTYCHAR1        "zyxwvutsrqp"
#  else
#    define SYS_PTYCHAR1        "pqrstuvwxyz"
#  endif
#endif

#ifndef SYS_PTYCHAR2
#  ifdef hpux
#    define SYS_PTYCHAR2        "fedcba9876543210"
#  else
#    define SYS_PTYCHAR2        "0123456789abcdef"
#  endif
#endif


static UInt GetMasterPty ( int *pty, Char *nametty, Char *namepty )
{
#if HAVE_POSIX_OPENPT && HAVE_PTSNAME
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
    *pty = posix_openpt( O_RDWR | O_NOCTTY );
    if (*pty > 0) {
        if (grantpt(*pty) || unlockpt(*pty)) {
            close(*pty);
            return 1;
        }
        strxcpy(nametty, ptsname(*pty), 32);
        return 0;
    }
    return 1;

#elif HAVE_GETPT && HAVE_PTSNAME_R
    /* Attempt to use glibc specific APIs, for compatibility with older
       glibc versions (before 2.2.1, release January 2001). */
    *pty = getpt();
    if (*pty > 0) {
        if (grantpt(*pty) || unlockpt(*pty)) {
            close(*pty);
            return 1;
        }
        ptsname_r(*pty, nametty, 32); 
        return 0;
    }
    return 1;

#elif HAVE_PTSNAME
    /* Attempt to use Sys V pseudo ttys on systems that don't have posix_openpt,
       getpt or openpty, but do have ptsname.
       Platforms *missing* ptsname include:
       Mac OS X 10.3, OpenBSD 3.8, Minix 3.1.8, mingw, MSVC 9, BeOS. */
    *pty = open( "/dev/ptmx", O_RDWR );
    if ( *pty < 0 )
        return 1;
    strxcpy(nametty, ptsname(*pty), 32);
    return 0;

#elif HAVE_GETPSEUDOTTY
    /* TODO: From which system(s) does getpseudotty originate? */
    *pty = getpseudotty( nametty, namepty );
    return *pty < 0 ? 1 : 0;

#elif HAVE__GETPTY
    /* Available on SGI IRIX >= 4.0 (released September 1991).
       See also http://techpubs.sgi.com/library/tpl/cgi-bin/getdoc.cgi?cmd=getdoc&coll=0530&db=man&fname=7%20pty */
    char  * line;
    line = _getpty(pty, O_RDWR|O_NDELAY, 0600, 0) ;
    if (0 == line)
        return 1;
    strcpy( nametty, line );
    return 0;

#else
    /* fallback to old-style BSD pseudoterminals, doing a brute force
       search over all pty device files. */
    int devindex;
    int letter;
    int ttylen, ptylen;

    ttylen = strlen(nametty);
    ptylen = strlen(namepty);

    for ( letter = 0; SYS_PTYCHAR1[letter]; ++letter ) {
        nametty[ttylen-2] = SYS_PTYCHAR1[letter];
        namepty[ptylen-2] = SYS_PTYCHAR1[letter];

        for ( devindex = 0; SYS_PTYCHAR2[devindex]; ++devindex ) {
            nametty[ttylen-1] = SYS_PTYCHAR2[devindex];
            namepty[ptylen-1] = SYS_PTYCHAR2[devindex];
                    
            *pty = open( namepty, O_RDWR );
            if ( *pty >= 0 ) {
                int slave = open( nametty, O_RDWR );
                if ( slave >= 0 ) {
                    close(slave);
                    return 0;
                }
                close(*pty);
            } 
        }
    }
    return 1;
#endif
}

#endif /* !defined(HAVE_OPENPTY) */


static UInt OpenPty( int *pty, int *tty )
{
#if HAVE_OPENPTY
    /* openpty is available on OpenBSD, NetBSD and FreeBSD, Mac OS X,
       Cygwin, Interix, OSF/1 4 and 5, and glibc (since 1998), and hence
       on most modern Linux systems. See also:
       http://www.gnu.org/software/gnulib/manual/html_node/openpty.html */
    return (openpty(pty, tty, NULL, NULL, NULL) < 0);
#else
    Char ttyname[32];
    Char ptyname[32];

    /* construct the name of the pseudo terminal */
    strcpy( ttyname, SYS_TTYDEV );
    strcpy( ptyname, SYS_PTYDEV );

    if ( GetMasterPty(pty, ttyname, ptyname) ) {
        Pr( "open master failed\n", 0L, 0L );
        return 1;
    }
    *tty = open( ttyname, O_RDWR, 0 );
    if ( *tty < 0 ) {
        Pr( "open slave failed\n", 0L, 0L );
        close(*pty);
        return 1;
    }
    return 0;
#endif
}

/****************************************************************************
**
*F  StartChildProcess( <dir>, <name>, <args> ) . . . . start a subprocess using ptys
**  returns the stream number of the IOStream that is connected to the new processs
*/

void ChildStatusChanged( int whichsig )
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
  /* Collect up any other zombie children */
  do {
      retcode = waitpid( -1, &status, WNOHANG);
      if (retcode == -1 && errno != ECHILD)
          Pr("#E Unexpected waitpid error %d\n",errno, 0);
  } while (retcode != 0 && retcode != -1);
  
  signal(SIGCHLD, ChildStatusChanged);
}

Int StartChildProcess ( Char *dir, Char *prg, Char *args[] )
{
    int             slave;   /* pipe to child                   */
    Int            stream;

    struct termios  tst;     /* old and new terminal state      */

    /* Get a stream record */
    stream = NewStream();
    if (stream == -1)
        return -1;
    
    /* open pseudo terminal for communication with gap */
    if ( OpenPty(&PtyIOStreams[stream].ptyFD, &slave) )
    {
        Pr( "open pseudo tty failed (errno %d)\n", errno, 0);
        FreeStream(stream);
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
    
    
    return stream;

 cleanup:
    close(slave);
    close(PtyIOStreams[stream].ptyFD);
    PtyIOStreams[stream].inuse = 0;
    FreeStream(stream);
    return -1;
}


void HandleChildStatusChanges( UInt pty)
{
  /* common error handling, when we are asked to read or write to a stopped
     or dead child */
  HashLock(PtyIOStreams);
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
  HashUnlock(PtyIOStreams);
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




Int ReadFromPty2( UInt stream, Char *buf, Int maxlen, UInt block)
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
  
  
UInt WriteToPty ( UInt stream, Char *buf, Int len )
{
    Int         res;
    Int         old;
/*  struct timeval tv; */
/*  fd_set      writefds; */
/*  int retval; */
    if (len < 0)
      return  write( PtyIOStreams[stream].ptyFD, buf, -len );
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
  ConvString(string);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,
                                    "you can replace stream number <num> via 'return <num>;'"));
  HandleChildStatusChanges(pty);
  return INTOBJ_INT(WriteToPty(pty, CSTR_STRING(string), INT_INTOBJ(len)));
}

Obj FuncREAD_IOSTREAM( Obj self, Obj stream, Obj len )
{
  UInt pty = INT_INTOBJ(stream);
  Int ret;
  Obj string;
  string = NEW_STRING(INT_INTOBJ(len));
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,
                                    "you can replace stream number <num> via 'return <num>;'"));
  /* HandleChildStatusChanges(pty);   Omit this to allow picking up "trailing" bytes*/
  ret = ReadFromPty2(pty, CSTR_STRING(string), INT_INTOBJ(len), 1);
  if (ret == -1)
    return Fail;
  SET_LEN_STRING(string, ret);
  ResizeBag(string, SIZEBAG_STRINGLEN(ret));
  return string;
}

Obj FuncREAD_IOSTREAM_NOWAIT(Obj self, Obj stream, Obj len)
{
  Obj string;
  UInt pty = INT_INTOBJ(stream);
  Int ret;
  string = NEW_STRING(INT_INTOBJ(len));
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,
                                    "you can replace stream number <num> via 'return <num>;'"));
  /* HandleChildStatusChanges(pty);   Omit this to allow picking up "trailing" bytes*/
  ret = ReadFromPty2(pty, CSTR_STRING(string), INT_INTOBJ(len), 0);
  if (ret == -1)
    return Fail;
  SET_LEN_STRING(string, ret);
  ResizeBag(string, SIZEBAG_STRINGLEN(ret));
  return string;
}
     

Obj FuncKILL_CHILD_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,
                                    "you can replace stream number <num> via 'return <num>;'"));
  /* Don't check for child having changes status */
  KillChild( pty );
  return 0;
}

Obj FuncSIGNAL_CHILD_IOSTREAM( Obj self, Obj stream , Obj sig)
{
  UInt pty = INT_INTOBJ(stream);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,
                                    "you can replace stream number <num> via 'return <num>;'"));
  /* Don't check for child having changes status */
  SignalChild( pty, INT_INTOBJ(sig) );
  return 0;
}

Obj FuncCLOSE_PTY_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  int status;
  int retcode;
/*UInt count; */
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,
                                    "you can replace stream number <num> via 'return <num>;'"));

  PtyIOStreams[pty].inuse = 0;
  
  /* Close down the child */
  retcode = close(PtyIOStreams[pty].ptyFD);
  if (retcode)
    Pr("Strange close return code %d\n",retcode, 0);
  kill(PtyIOStreams[pty].childPID, SIGTERM);
  retcode = waitpid(PtyIOStreams[pty].childPID, &status, 0);
  FreeStream(pty);
  return 0;
}

Obj FuncIS_BLOCKED_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,
                                    "you can replace stream number <num> via 'return <num>;'"));
  return (PtyIOStreams[pty].blocked || PtyIOStreams[pty].changed || !PtyIOStreams[pty].alive) ? True : False;
}

Obj FuncFD_OF_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,
                                    "you can replace stream number <num> via 'return <num>;'"));
  return INTOBJ_INT(PtyIOStreams[pty].ptyFD);
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
  
  /* Set up the trap to detect future dying children */
  signal( SIGCHLD, ChildStatusChanged );

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
