/****************************************************************************
**
*W  iostream.c                  GAP source                       Steve Linton
**
*H  @(#)$Id$
**
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
#include        "system.h"              /* system dependent part           */

const char * Revision_iostream_c =
   "@(#)$Id$";

#define INCLUDE_DECLARATION_PART
#include        "iostream.h"            /* file input/output               */
#undef  INCLUDE_DECLARATION_PART

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

#ifndef SYS_STDIO_H                     /* standard input/output functions */
# include <stdio.h>
# define SYS_STDIO_H
#endif

#if SYS_MAC_MWC || SYS_MAC_MPW

Obj FuncCREATE_PTY_IOSTREAM( Obj self, Obj dir, Obj prog, Obj args )
{
  ErrorQuit("IOStreams are not available on this architecture", (Int)0L, (Int) 0L);
  return Fail;
}
  
Obj FuncWRITE_IOSTREAM( Obj self, Obj stream, Obj string, Obj len )
{
  ErrorQuit("IOStreams are not available on this architecture", (Int)0L, (Int) 0L);
  return Fail;
}

Obj FuncREAD_IOSTREAM( Obj self, Obj stream, Obj string, Obj len )
{
  ErrorQuit("IOStreams are not available on this architecture", (Int)0L, (Int) 0L);
  return Fail;
}

Obj FuncKILL_CHILD_IOSTREAM( Obj self, Obj stream )
{
  ErrorQuit("IOStreams are not available on this architecture", (Int)0L, (Int) 0L);
  return 0;
}

Obj FuncCLOSE_PTY_IOSTREAM( Obj self, Obj stream )
{
  ErrorQuit("IOStreams are not available on this architecture", (Int)0L, (Int) 0L);
  return 0;
}

Obj FuncSIGNAL_CHILD_IOSTREAM( Obj self, Obj stream , Obj signal)
{
  ErrorQuit("IOStreams are not available on this architecture", (Int)0L, (Int) 0L);
  return 0;
}

Obj FuncIS_BLOCKED_IOSTREAM( Obj self, Obj stream )
{
  ErrorQuit("IOStreams are not available on this architecture", (Int)0L, (Int) 0L);
  return Fail;
}


#else

#include <unistd.h>
#include <errno.h>
#include <signal.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <assert.h>

typedef struct {
  int childPID;    /* Also used as a link to make a linked free list */
  int ptyFD;       /* GAP reading from external prog */
  Char ttyname[32];
  Char ptyname[32];
  UInt inuse;     /* we need to scan all the "live" structures when we have had SIGCHLD
		     so, for now, we just walk the array for the ones marked in use */
  UInt changed;			/* set non-zero by the signal handler if our child has
				   done something -- stopped or exited */
  int status;			/* status from wait3 -- meaningful only if changed is 1 */
  UInt blocked;			/* we have already reported a problem, which is still there */
  UInt alive;                   /* gets set after waiting for a child actually fails
				   implying that the child has vanished under our noses */
} PtyIOStream;

#define MAX_PTYS 32

static PtyIOStream PtyIOStreams[MAX_PTYS];
static UInt FreePtyIOStreams;

UInt NewStream( void )
{
  UInt stream  = -1;
  if (FreePtyIOStreams != -1)
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

Int ReadFromPty( UInt stream, Char *buf, Int len )
{
  Int         n;
  Int         old;

  if ( len < 0 )
    return read( PtyIOStreams[stream].ptyFD, buf, -len ); /* don't wait */
  else
    {
      old = len;
      while ( 0 < len )
        {
	  while ( ( n = read(PtyIOStreams[stream].ptyFD , buf, len ) ) < 0 )
	    ;
	  buf  += n;
	  len  -= n;
        }
      return old;
    }

}

extern int errno;

UInt WriteToPty ( UInt stream, Char *buf, Int len )
{
    Int         res;
    Int         old;
    if (len < 0)
      return  write( PtyIOStreams[stream].ptyFD, buf, -len );
    old = len;
    while ( 0 < len )
    {
        res = write( PtyIOStreams[stream].ptyFD, buf, len );
        if ( res < 0 )
        {
	    if ( errno == EAGAIN )
		continue;
	    return errno;
        }
        len  -= res;
        buf += res;
    }
    return old;
}



/****************************************************************************
**
*F  SignalChild(<stream>) . .. . . . . . . . . . .  interrupt the child process
*/
void SignalChild (UInt stream, UInt signal)
{
    if ( PtyIOStreams[stream].childPID != -1 )
    {
        kill( PtyIOStreams[stream].childPID, signal );
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


static UInt GetMasterPty ( int * pty, Char * ttyname, Char *ptyname )
{
#   ifdef att
        if ( (*pty = open( "/dev/ptmx", O_RDWR )) < 0 )
            return 1;
        return 0;

#   else
#   if HAVE_GETPSEUDOTTY
        return (*pty = getpseudotty( ttyname, ptyname )) >= 0 ? 0 : 1;
#   else
#   if HAVE__GETPTY
	char  * line;

	line = _getpty(pty, O_RDWR|O_NDELAY, 0600, 0) ;
        if (0 == line)
            return 1;
	strcpy( ttyname, line );
	return 0;

#   else
#   if defined(sgi) || (defined(umips) && defined(USG))
        struct stat fstat_buf;

        *pty = open( "/dev/ptc", O_RDWR );
        if ( *pty < 0 || (fstat (*pty, &fstat_buf)) < 0 )
            return 1;
        sprintf( ttyname, "/dev/ttyq%d", minor(fstat_buf.st_rdev) );
#       if !defined(sgi)
            sprintf( ptyname, "/dev/ptyq%d", minor(fstat_buf.st_rdev) );
            if ( (*tty = open (ttyname, O_RDWR)) < 0 ) 
            {
                close (*pty);
                return 1;
            }
#       endif
        return 0;

#   else
        static int  devindex = 0;
        static int  letter   = 0;
        static int  slave    = 0;

        while ( SYS_PTYCHAR1[letter] )
        {
            ttyname[strlen(ttyname)-2] = SYS_PTYCHAR1[letter];
            ptyname[strlen(ptyname)-2] = SYS_PTYCHAR1[letter];

            while ( SYS_PTYCHAR2[devindex] )
            {
                ttyname[strlen(ttyname)-1] = SYS_PTYCHAR2[devindex];
                ptyname[strlen(ptyname)-1] = SYS_PTYCHAR2[devindex];
                        
                if ( (*pty = open( ptyname, O_RDWR )) >= 0 )
                    if ( (slave = open( ttyname, O_RDWR, 0 )) >= 0 )
                    {
                        close(slave);
                        (void) devindex++;
                        return 0;
                    }
                devindex++;
            }
            devindex = 0;
            (void) letter++;
        }
        return 1;
#   endif
#   endif
#   endif
#   endif
}


/****************************************************************************
**
*F  StartChildProcess( <dir>, <name>, <args> ) . . . . start a subprocess using ptys
**  returns the stream number of the IOStream that is connected to the new processs
*/

RETSIGTYPE ChildStatusChanged( int whichsig )
{
  UInt i;
  int status;
  int retcode;
  assert(whichsig == SIGCHLD);
  for (i = 0; i < MAX_PTYS; i++)
    {
      if (PtyIOStreams[i].inuse)
	{
	  retcode = waitpid( PtyIOStreams[i].childPID, &status, WNOHANG | WUNTRACED );
	  if (retcode == -1)
	    {
	      PtyIOStreams[i].changed = 1;
	      PtyIOStreams[i].alive  = 1;
	    }
	  if (WIFEXITED(status) || WIFSIGNALED(status))
	    {
	      PtyIOStreams[i].changed = 1;
	      PtyIOStreams[i].status = status;
	      PtyIOStreams[i].blocked = 0;
	    }
	}
    }
  signal(SIGCHLD, ChildStatusChanged);
}

Int StartChildProcess ( Char *dir, Char *prg, Char *args[] )
{
    Int             j;       /* loop variables                  */
    char            c[8];    /* buffer for communication        */
    int             n;       /* return value of 'select'        */
    int             slave;   /* pipe to child                   */
    UInt            stream;

#   if HAVE_TERMIOS_H
        struct termios  tst; /* old and new terminal state      */
#   else
#     if HAVE_TERMIO_H
        struct termio   tst; /* old and new terminal state      */
#     else
        struct sgttyb   tst; /* old and new terminal state      */
#     endif
#   endif
	
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
	if ( (slave  = open( PtyIOStreams[stream].ttyname, O_RDWR, 0 )) < 0 )
	  {
	    Pr( "open slave failed\n", 0L, 0L );
	    close(PtyIOStreams[stream].ptyFD);
	    FreeStream(stream);
	    return -1;
	  }

	/* Now fiddle with the terminal sessions on the pty */
#   if HAVE_TERMIOS_H
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
#   else
#     if HAVE_TERMIO_H
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
#     else
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
#endif

	/* set input to non blocking operation */
	if ( fcntl( PtyIOStreams[stream].ptyFD, F_SETFL, O_NDELAY ) < 0 )
	  {
	    Pr( "Panic: cannot set non blocking operation.\n", 0, 0);
	    goto cleanup;
	  }

	PtyIOStreams[stream].inuse = 1;
	PtyIOStreams[stream].alive = 1;
	PtyIOStreams[stream].blocked = 0;
	PtyIOStreams[stream].changed = 0;
	/* fork */
	PtyIOStreams[stream].childPID = fork();
	if ( PtyIOStreams[stream].childPID == 0 )
	  {
	    /* Set up the child */
	    
	    if ( dup2( slave, 0 ) == -1)
	      _exit(-1);
	    fcntl( 0, F_SETFD, 0 );
	    
	    if (dup2( slave, 1 ) == -1)
	      _exit(-1);
	    fcntl( 1, F_SETFD, 0 );
	    
	    if ( chdir(dir) == -1 ) {
	      _exit(-1);
	    }
	    
#       ifdef SYS_HAS_EXECV_CCHARPP
            execv( prg, (const char**) args );
#       else
            execv( prg, (void*) args );
#       endif

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
  
Obj FuncWRITE_IOSTREAM( Obj self, Obj stream, Obj string, Obj len )
{
  UInt pty = INT_INTOBJ(stream);
  ConvString(string);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,"You can return another stream number to continue"));
  HandleChildStatusChanges(pty);
  return INTOBJ_INT(WriteToPty(pty, CSTR_STRING(string), INT_INTOBJ(len)));
}

Obj FuncREAD_IOSTREAM( Obj self, Obj stream, Obj string, Obj len )
{
  UInt pty = INT_INTOBJ(stream);
  ConvString(string);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,"You can return another stream number to continue"));
  HandleChildStatusChanges(pty);
  return INTOBJ_INT(ReadFromPty(pty, CSTR_STRING(string), INT_INTOBJ(len)));
}

Obj FuncKILL_CHILD_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,"You can return another stream number to continue"));
  /* Don't check for child having changes status */
  KillChild( pty );
  return 0;
}

Obj FuncSIGNAL_CHILD_IOSTREAM( Obj self, Obj stream , Obj signal)
{
  UInt pty = INT_INTOBJ(stream);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,"You can return another stream number to continue"));
  /* Don't check for child having changes status */
  SignalChild( pty, INT_INTOBJ(signal) );
  return 0;
}

Obj FuncCLOSE_PTY_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  int status;
  int retcode;
  UInt count;
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,"You can return another stream number to continue"));

  PtyIOStreams[pty].inuse = 0;
  
  /* Close down the child */
  kill(PtyIOStreams[pty].childPID, SIGTERM);
  close(PtyIOStreams[pty].ptyFD);
  retcode = waitpid(PtyIOStreams[pty].childPID, &status, 0);
  FreeStream(pty);
  return 0;
}

Obj FuncIS_BLOCKED_IOSTREAM( Obj self, Obj stream )
{
  UInt pty = INT_INTOBJ(stream);
  while (!PtyIOStreams[pty].inuse)
    pty = INT_INTOBJ(ErrorReturnObj("IOSTREAM %d is not in use",pty,0L,"You can return another stream number to continue"));
  return (PtyIOStreams[pty].blocked || PtyIOStreams[pty].changed || !PtyIOStreams[pty].alive) ? True : False;
}

#endif
/* end of if Macintosh */

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
    
    { "READ_IOSTREAM", 3, "stream, string, len",
      FuncREAD_IOSTREAM, "src/iostream.c:READ_IOSTREAM" },

    { "KILL_CHILD_IOSTREAM", 1, "stream",
      FuncKILL_CHILD_IOSTREAM, "src/iostream.c:KILL_CHILD_IOSTREAM" },

    { "CLOSE_PTY_IOSTREAM", 1, "stream",
      FuncCLOSE_PTY_IOSTREAM, "src/iostream.c:CLOSE_PTY_IOSTREAM" },

    { "SIGNAL_CHILD_IOSTREAM", 2, "stream, signal",
      FuncSIGNAL_CHILD_IOSTREAM, "src/iostream.c:SIGNAL_CHILD_IOSTREAM" },
    
    { "IS_BLOCKED_IOSTREAM", 1, "stream",
      FuncIS_BLOCKED_IOSTREAM, "src/iostream.c:IS_BLOCKED_IOSTREAM" },
    
    0 };
  
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
#if SYS_MAC_MWC || SYS_MAC_MPW
#else

  UInt i;
  PtyIOStreams[0].childPID = -1;
  for (i = 1; i < MAX_PTYS; i++)
    PtyIOStreams[i].childPID = i-1;
  FreePtyIOStreams = MAX_PTYS-1;

  /* init filters and functions                                          */
  InitHdlrFuncsFromTable( GVarFuncs );
  
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
    module.revision_c = Revision_iostream_c;
    module.revision_h = Revision_iostream_h;
    FillInVersion( &module );
    return &module;
}


/****************************************************************************
**

*E  sysfiles.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
