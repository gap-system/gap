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

#define _GNU_SOURCE  /* is used for ptsname_r prototype etc. */

#include        "system.h"              /* system dependent part           */


#include        "iostream.h"            /* file input/output               */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */

#include        "lists.h"               /* generic lists                   */
#include        "listfunc.h"            /* functions for generic lists     */

#include        "plist.h"               /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "records.h"             /* generic records                 */
#include        "bool.h"                /* True and False                  */

#include <stdio.h>                      /* standard input/output functions */
#include <stdlib.h>
#include <string.h>


#ifdef HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif

#if HAVE_SYS_TIME_H
#include  <sys/time.h>
#endif

#if HAVE_UNISTD_H
#include <unistd.h>
#endif

#if HAVE_ERRNO_H
#include <errno.h>
#endif

#if HAVE_SIGNAL_H
#include <signal.h>
#endif

#if HAVE_FCNTL_H
#include <fcntl.h>
#endif

#if HAVE_TERMIOS_H
#include <termios.h>
#endif

#if HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif

#if HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#if HAVE_ASSERT_H
#include <assert.h>
#else
#ifdef NDEBUG
#define assert( a )
#else
#define assert( a ) do if (!(a)) {fprintf(stderr,"Assertion failed at line %d file %s\n",__LINE__,__FILE__); abort();} while (0)
#endif
#endif

#if HAVE_SYS_STAT_H
#include <sys/stat.h>
#endif

typedef struct {
  int childPID;    /* Also used as a link to make a linked free list */
  int ptyFD;       /* GAP reading from external prog */
  Char ttyname[32];
  Char ptyname[32];
  UInt inuse;     /* we need to scan all the "live" structures when we have had SIGCHLD
                     so, for now, we just walk the array for the ones marked in use */
  UInt changed;   /* set non-zero by the signal handler if our child has
                     done something -- stopped or exited */
  int status;     /* status from wait3 -- meaningful only if changed is 1 */
  UInt blocked;   /* we have already reported a problem, which is still there */
  UInt alive;     /* gets set after waiting for a child actually fails
                     implying that the child has vanished under our noses */
} PtyIOStream;

#define MAX_PTYS 64

static PtyIOStream PtyIOStreams[MAX_PTYS];
static Int FreePtyIOStreams;

Int NewStream( void )
{
  Int stream = -1;
  if ( FreePtyIOStreams != -1 )
  {
      stream = FreePtyIOStreams;
      FreePtyIOStreams = PtyIOStreams[stream].childPID;
  }
  return stream;
}

void FreeStream( UInt stream)
{
   PtyIOStreams[stream].childPID = FreePtyIOStreams;
   FreePtyIOStreams = stream;
}

/****************************************************************************
**
*F  SignalChild(<stream>) . .. . . . . . . . . . .  interrupt the child process
*/
void SignalChild (UInt stream, UInt sig)
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
void KillChild (UInt stream)
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


static UInt GetMasterPty ( int * pty, Char * nametty, Char *namepty )
{
#if HAVE_GETPT && HAVE_PTSNAME_R
    if ((*pty = getpt()) > 0 ) {
        if (grantpt(*pty) || unlockpt(*pty))
            return 1;
        ptsname_r(*pty, nametty, 32); 
        return 0;
    }
    return 1;

#elif defined(att)
    if ( (*pty = open( "/dev/ptmx", O_RDWR )) < 0 )
        return 1;
    return 0;

#elif defined(__CYGWIN__)
 /* NOTE: #define SYS_PTYDEV to "/dev/ptmx" */
 /*            around line 246 ifdef __CYGWIN__    */
 /*            instead of doing the following strcpy  */
 /*            may be better.                                */
    strcpy(namepty, "/dev/ptmx");
    if ( (*pty = open( namepty, O_RDWR )) > 0 ) {
        strcpy(nametty, ptsname(*pty));
        /*revoke(nametty);*/
        return 0;
    }
    errno = ENOENT; /* out of ptys */
    perror(" Failed on open CYGWIN pty");
    return 1;

#elif HAVE_GETPSEUDOTTY
    return (*pty = getpseudotty( nametty, namepty )) >= 0 ? 0 : 1;

#elif HAVE__GETPTY
    char  * line;

    line = _getpty(pty, O_RDWR|O_NDELAY, 0600, 0) ;
    if (0 == line)
        return 1;
    strcpy( nametty, line );
    return 0;

#elif defined(sgi) || (defined(umips) && defined(USG))
    struct stat fstat_buf;

    *pty = open( "/dev/ptc", O_RDWR );
    if ( *pty < 0 || (fstat (*pty, &fstat_buf)) < 0 )
        return 1;
    sprintf( nametty, "/dev/ttyq%d", minor(fstat_buf.st_rdev) );
  #if !defined(sgi)
    sprintf( namepty, "/dev/ptyq%d", minor(fstat_buf.st_rdev) );
    if ( (*tty = open (nametty, O_RDWR)) < 0 ) 
    {
        close (*pty);
        return 1;
    }
  #endif
    return 0;

# else
    static int  devindex = 0;
    static int  letter   = 0;
    static int  slave    = 0;

    while ( SYS_PTYCHAR1[letter] )
    {
        nametty[strlen(nametty)-2] = SYS_PTYCHAR1[letter];
        namepty[strlen(namepty)-2] = SYS_PTYCHAR1[letter];

        while ( SYS_PTYCHAR2[devindex] )
        {
            nametty[strlen(nametty)-1] = SYS_PTYCHAR2[devindex];
            namepty[strlen(namepty)-1] = SYS_PTYCHAR2[devindex];
                    
            if ( (*pty = open( namepty, O_RDWR )) >= 0 )
            {
                if ( (slave = open( nametty, O_RDWR, 0 )) >= 0 )
                {
                    close(slave);
                    (void) devindex++;
                    return 0;
                }
                else close(*pty);
            } 
            devindex++;
        }
        devindex = 0;
        (void) letter++;
    }
    return 1;
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
/*  Int             j;       / loop variables                  */
/*  char            c[8];    / buffer for communication        */
/*  int             n;       / return value of 'select'        */
    int             slave;   /* pipe to child                   */
    Int            stream;

#if HAVE_TERMIOS_H
    struct termios  tst;     /* old and new terminal state      */
#elif HAVE_TERMIO_H
    struct termio   tst;     /* old and new terminal state      */
#elif HAVE_SGTTY_H
    struct sgttyb   tst;     /* old and new terminal state      */
#elif !defined(USE_PRECOMPILED)
/* If no way to store and reset terminal states is known, and we are
   not currently re-making the dependency list (via cnf/Makefile),
   then trigger an error. */
    #error No supported way of (re)storing terminal state is available
#endif

    /* Get a stream record */
    stream = NewStream();
    if (stream == -1)
      return -1;
    
    /* construct the name of the pseudo terminal */
    strcpy( PtyIOStreams[stream].ttyname, SYS_TTYDEV );
    strcpy( PtyIOStreams[stream].ptyname, SYS_PTYDEV );

    /* open pseudo terminal for communication with gap */
    if ( GetMasterPty(&PtyIOStreams[stream].ptyFD,
              PtyIOStreams[stream].ttyname,
              PtyIOStreams[stream].ptyname) )
    {
        Pr( "open master failed\n", 0L, 0L);
        FreeStream(stream);
        return -1;
    }
    slave  = open( PtyIOStreams[stream].ttyname, O_RDWR, 0 );
    if ( slave < 0 )
    {
        Pr( "open slave failed\n", 0L, 0L );
        close(PtyIOStreams[stream].ptyFD);
        FreeStream(stream);
        return -1;
    }

    /* Now fiddle with the terminal sessions on the pty */
#if HAVE_TERMIOS_H
    if ( tcgetattr( slave, &tst ) == -1 )
    {
        Pr( "tcgetattr on slave pty failed\n", 0L, 0L);
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
        Pr("tcsetattr on slave pty failed\n", 0, 0 );
        goto cleanup;
    }
#elif HAVE_TERMIO_H
    if ( ioctl( slave, TCGETA, &tst ) == -1 )
    {
        Pr( "ioctl TCGETA on slave pty failed\n");
        goto cleanup;
    }
    tst.c_cc[VINTR] = 0377;
    tst.c_cc[VQUIT] = 0377;
    tst.c_iflag    &= ~(INLCR|ICRNL);
    tst.c_cc[VMIN]  = 1;
    tst.c_cc[VTIME] = 0;   
    /* Note that this is at least on Linux dangerous! 
       Therefore, we now have the HAVE_TERMIOS_H section for POSIX
       Terminal control. */
    tst.c_lflag    &= ~(ECHO|ICANON);
    if ( ioctl( slave, TCSETAW, &tst ) == -1 )
    {
        Pr( "ioctl TCSETAW on slave pty failed\n");
        goto cleanup;
    }
#elif HAVE_SGTTY_H
    if ( ioctl( slave, TIOCGETP, (char*)&tst ) == -1 )
    {
        Pr( "ioctl TIOCGETP on slave pty failed\n");
        goto cleanup;
    }
    tst.sg_flags |= RAW;
    tst.sg_flags &= ~ECHO;
    if ( ioctl( slave, TIOCSETN, (char*)&tst ) == -1 )
    {
        Pr( "ioctl on TIOCSETN slave pty failed\n");
        goto cleanup;
    }
#endif

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
        Pr( "Panic: cannot fork to subprocess.\n", 0, 0);
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
  if (PtyIOStreams[pty].alive == 0)
  {
      PtyIOStreams[pty].changed = 0;
      PtyIOStreams[pty].blocked = 0;
      ErrorQuit("Child Process is unexpectedly dead", (Int) 0L, (Int) 0L);
  }
  if (PtyIOStreams[pty].blocked)
  {
      ErrorQuit("Child Process is still dead", (Int)0L,(Int)0L);
  }
  if (PtyIOStreams[pty].changed)
  {
      PtyIOStreams[pty].blocked = 1;
      PtyIOStreams[pty].changed = 0;
      ErrorQuit("Child Process %d has stopped or died, status %d",
                (Int) PtyIOStreams[pty].childPID,
                (Int) PtyIOStreams[pty].status);
  }
}

#define MAX_ARGS 1000

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
  
  

extern int errno;

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
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**
*E  iostream.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
