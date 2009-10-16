/****************************************************************************
**
**    system.c                        NQ                       Werner Nickel
**                                                    werner@pell.anu.edu.au
**
**    Copyright Dec 1992                        Mathematics Research Section
**                                           School of Mathematical Sciences 
**                                            Australian National University
*/

#include <stdio.h>
#include <signal.h>

static
char	*SignalName[] = { "",
			  "Hangup (1)",
			  "Interrupt (2)",
			  "Quit (3)",
			  "Illegal instruction (4)",
			  "(5)",
			  "Abort (6)",
			  "(7)",
			  "Arithmetic exception (8)",
			  "(9)",
			  "Bus error (10)",
			  "Segmentation violation (11)",
			  "(12)",
			  "(13)",
			  "(14)",
			  "User termination (15)" };
#ifdef SYS_BSD 
static
void	handler( sig, code, scp, addr )
int	sig, code;
struct  sigcontext *scp;
char	*addr;

{	fprintf( stderr, "\n\n Process terminating with signal" );
	fprintf( stderr, " %s.\n\n", SignalName[sig] );

	signal( sig, SIG_DFL );
	kill( getpid(), sig );

	/** Please lint.**/
	scp  = (void *)0;
	addr = (void *)0;
	code = 0;
}

#else
#if SYS_USG || SYS_ALPHA
static
void	handler( sig )
int	sig;

{	fprintf( stderr, "\n\n Process terminating with signal" );
	fprintf( stderr, " %s.\n\n", SignalName[sig] );
	signal( sig, SIG_DFL );
	kill( getpid(), sig );

}
#else
static
void	handler( sig )
int	sig;

{	fprintf( stderr, "\n\n Process terminating with signal" );
	fprintf( stderr, " %s.\n\n", SignalName[sig] );
	signal( sig, SIG_DFL );
	kill( getpid(), sig );

}
#endif
#endif

void	CatchSignals() {

	/*
	**    Catch the following signal in order to exit gracefully
	**    if the process is killed.
	*/
	signal( SIGHUP,  handler );
	signal( SIGINT,  handler );
	signal( SIGQUIT, handler );
	signal( SIGABRT, handler );
	signal( SIGTERM, handler );
	/*
	**    Catch the following signals to exit gracefully if the
	**    process crashes.
	*/
	signal( SIGILL,  handler );
	signal( SIGFPE,  handler );
	signal( SIGBUS,  handler );
	signal( SIGSEGV, handler );
}


/****************************************************************************
**
*F  RunTime() . . . . . . . . . . . . . . . return time spent in milliseconds
**
**  'RunTime' returns the number of milliseconds spent so far. The following
**   functions were taken out of the GAP file system.c
**
**  Should be as accurate as possible,  because it  is  used  for  profiling.
*/


/** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
**
**  For Berkeley UNIX the clock ticks in 1/60.  On some (all?) BSD systems we
**  can use 'getrusage', which gives us a much better resolution.
*/
#ifdef  __STDC__
#define P(ARGS) ARGS
#else
#define P(ARGS) ()
#endif

#if SYS_BSD || SYS_MACH || SYS_MSDOS_DJGPP || SYS_ALPHA

#ifndef SYS_HAS_NO_GETRUSAGE

#ifndef SYS_RESOURCE_H                  /* definition of 'struct rusage'   */
# include       <sys/time.h>            /* definition of 'struct timeval'  */
# include       <sys/resource.h>
# define SYS_RESOURCE_H
#endif
#ifndef SYS_HAS_TIME_PROTO              /* UNIX decl. from 'man'           */
extern  int             getrusage P(( int, struct rusage * )); 
#endif

unsigned long   RunTime ()
{
    struct rusage       buf;

    if ( getrusage( RUSAGE_SELF, &buf ) ) {
        fputs("Sq: panic 'RunTime' cannot get time!\n",stderr);
        exit( 1 );
    }
    return buf.ru_utime.tv_sec*1000 + buf.ru_utime.tv_usec/1000;
}

#endif

#ifdef SYS_HAS_NO_GETRUSAGE

#ifndef SYS_TIMES_H                     /* time functions                  */
# include       <sys/types.h>
# include       <sys/times.h>
# define SYS_TIMES_H
#endif
#ifndef SYS_HAS_TIME_PROTO              /* UNIX decl. from 'man'           */
extern  int             times P(( struct tms * ));
#endif

unsigned long   RunTime ()
{
    struct tms          tbuf;

    if ( times( &tbuf ) == -1 ) {
        fputs("Sq: panic 'RunTime' cannot get time!\n",stderr);
        exit( 1 );
    }
    return 100 * tbuf.tms_utime / (60/10);
}

#endif

#endif


/** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
**
**  For UNIX System V and OS/2 the clock ticks in 1/HZ,  this is usually 1/60
**  or 1/100.
*/
#if SYS_USG || SYS_OS2_EMX

#ifndef SYS_TIMES_H                     /* time functions                  */
# include       <sys/param.h>           /* definition of 'HZ'              */
# include       <sys/types.h>
# include       <sys/times.h>
# define SYS_TIMES_H
#endif
#ifndef SYS_HAS_TIME_PROTO              /* UNIX decl. from 'man'           */
extern  int             times P(( struct tms * ));
#endif

unsigned long   SyTime ()
{
    struct tms          tbuf;

    if ( times( &tbuf ) == -1 ) {
        fputs("gap: panic 'RunTime' cannot get time!\n",stderr);
        exit( 1 );
    }
    return 100 * tbuf.tms_utime / (HZ / 10);
}

#endif


/** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
**
**  For TOS and VMS we use the function 'clock' and allow to stop the clock.
*/
#if SYS_TOS_GCC2 || SYS_VMS

#ifndef SYS_TIME_H                      /* time functions                  */
# include       <time.h>
# define SYS_TIME_H
#endif
#ifndef SYS_HAS_TIME_PROTO              /* ANSI/TRAD decl. from H&S 18.2    */
# if SYS_ANSI
extern  clock_t         clock P(( void ));
# define SYS_CLOCKS     CLOCKS_PER_SEC
# else
extern  long            clock P(( void ));
#  if SYS_TOS_GCC2
#   define SYS_CLOCKS   200
#  else
#   define SYS_CLOCKS   100
#  endif
# endif
#endif

unsigned long           syFirstTime;    /* time at which Sq was started   */

unsigned long           syLastTime;     /* time at which clock was stopped */

unsigned long   RunTime ()
{
    return 100 * (unsigned long)clock() / (SYS_CLOCKS/10) - syFirstTime;
}

void            syStopTime ()
{
    syLastTime = RunTime();
}

void            syStartTime ()
{
    syFirstTime += RunTime() - syLastTime;
}

#endif


/** * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
**
**  For  MAC with MPW we  use the 'TickCount' function  and allow to stop the
**  clock.
*/
#if SYS_MAC_MPW

#ifndef SYS_EVENTS_H                    /* event functions                 */
# include       <Types.h>
# include       <Events.h>
# include       <OSEvents.h>
# define SYS_EVENTS_H
#endif

unsigned long           syFirstTime;    /* time at which GAP was started   */

unsigned long           syLastTime;     /* time at which clock was stopped */

unsigned long   RunTime ()
{
    return 100 * (unsigned long)TickCount() / (60/10) - syFirstTime;
}

void            syStopTime ()
{
    syLastTime = RunTime();
}

void            syStartTime ()
{
    syFirstTime += RunTime() - syLastTime;
}

#endif


char * TmpFileName() {

      return tmpnam((char *) NULL);
}

#if SYS_USG || SYS_BSD || SYS_ALPHA
extern int unlink();
void Unlink (fn) 
char * fn;
{
  unlink( fn );
}
#else
extern int unlink();
void Unlink (fn) 
char * fn;
{
  unlink( fn );
}
#endif


#if SYS_USG || SYS_ALPHA 
#include <sys/utsname.h>
char * GetHostName () {
       
           struct utsname *uts;
           uts = (struct utsname * )malloc( sizeof(struct utsname));
           uname(uts);
       
           return uts->nodename;
       }

#elif SYS_BSD
char * GetHostName () {
       
           static char  hostname[128]; 
          
           gethostname( hostname, 128 );
	   return hostname;
       }
#else
char * GetHostName () {
       
           char  *hostname = "unknown host";
          
           return  hostname;

       }
#endif
