/****************************************************************************
**
**    system.c                        NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include <stdio.h>
#include <signal.h>
#include <sys/time.h>

#include "config.h"

#include "nq.h"

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
			  "Alarm clock (14)",
			  "User termination (15)",
			  "",
			  "",
			  "",
			  "",
			  "",
			  "",
			  "",
			  "",
			  "",
			  "",
			  "Virtual alarm (26)" };

static
void	handler( sig, code, scp, addr )
int	sig, code;
struct  sigcontext *scp;
char	*addr;

{	fprintf( stderr, "\n\n# Process terminating with signal" );
	fprintf( stderr, " %s.\n\n", SignalName[sig] );

	if( Gap ) printf( "];\n" );
        fflush( stdout );

	signal( sig, SIG_DFL );
	kill( getpid(), sig );

	/* Please lint.*/
	scp  = (void *)0;
	addr = (void *)0;
	code = 0;
}

static int TimeOutReached = 0;
static int DoTimeOut = 1;

/*
**    Set the alarm.
*/
void	SetTimeOut( nsec )
int	nsec;

{	struct itimerval  si;

	if( nsec > 0 ) {
	    printf( "#\n#    Time out after %d seconds.\n", nsec );
	    /* Set time after which timer expires. */
	    si.it_value.tv_sec  = nsec;    /*  sec */
	    si.it_value.tv_usec = 0;       /* msec */
	    /* The timer is not going to be reset. */
	    si.it_interval.tv_sec  = 0;
	    si.it_interval.tv_usec = 0;

	    if( setitimer( ITIMER_VIRTUAL, &si, (struct itimerval*)0 )== -1 ) {
		perror( "" );
	    }
	    TimeOutReached = 0;
	    DoTimeOut = 1;
	    return;
	}
	else
	    printf( "SetTimeOut(): argument negative, timout not set.\n" );
}

/*
**    Switch on the time out mechanism. Check if the program has timed
**    out in the mean time and if so terminate.
*/
void	TimeOutOn() {
        if( TimeOutReached ) {
	    printf( "#\n#    Process has timed out.\n#\n" );

	    if( Gap ) printf( "];\n" );
	    exit( 0 );
	}
	else
	    DoTimeOut = 1;
}

/*
**    Switch off the time out mechanism.
*/
void	TimeOutOff() {     DoTimeOut = 0;    }

static
void	alarmClock( sig, code, scp, addr )
int	sig, code;
struct  sigcontext *scp;
char	*addr;

{	TimeOutReached = 1;

	if( DoTimeOut ) TimeOutOn();
}

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
	/*
	**    Catch the virtual alarm signal so that the process can time out.
	*/
	signal( SIGVTALRM, alarmClock );
}

/*
**    return the cpu time in milli seconds
*/
#ifdef HAVE_GETRUSAGE

#include <sys/time.h>
#include <sys/resource.h>

long	RunTime() {

	struct	rusage	buf;

	if( getrusage( RUSAGE_SELF, &buf ) ) {
		perror( "couldn't obtain timing" );
		exit( 1 );
	}
	return buf.ru_utime.tv_sec*1000 + buf.ru_utime.tv_usec/1000;
}

#else 

#include <sys/types.h>
#include <sys/times.h>

long RunTime () 
{
   struct tms buf;
  
   times (&buf);
   return (buf.tms_utime * 50 / 3); 
} 

#endif

/* some functions for debugging puposes */
void	printCommute() {

	gen	i;

	for( i = 1; i <= NrPcGens+NrCenGens; i++ )
	    printf( " %d", Commute[i] );
	printf( "\n" );
}

void	printDim() {

	int	i;

	for( i = 1; i <= Class; i++ ) printf( " %d", Dimension[i] );
	printf( "\n" );
}

void	printExp() {

	int	i, j, k;

	for( i = 1, k = 1; i <= Class; i++ ) {
	    for( j = 1; j <= Dimension[i]; j++, k++ )
#ifdef LONGLONG
		printf( " %Ld", Exponent[k] );
#else
		printf( " %d", Exponent[k] );
#endif
	    printf( "   " );
	}
}

void	printRenumber( renumber )
gen	*renumber;

{	long	i;

	for( i = 1; i <= NrCenGens; i++ )
	    printf( " %d", renumber[i] );
}

void	printERow( eRow )
long	*eRow;

{	long	i;

	for( i = 1; i <= NrCenGens; i++ )
#ifdef LONGLONG
	    printf( " %Ld", eRow[i] );
#else
	    printf( " %d", eRow[i] );
#endif
}
