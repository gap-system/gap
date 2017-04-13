/****************************************************************************
**
*W  systimer.c
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**
**  This file implements timers for CallWithTimeout. There are two options
**  1) Using the POSIX 2001 timer api
**  2) Using setitimer/getitimer
**
*/

#include <src/system.h>
#include <src/gapstate.h>
#include <src/gap.h>
#include <src/objects.h>
#include <src/stats.h>
#include <src/scanner.h>  // for Pr()

#include <assert.h>
#include <time.h>
#include <signal.h>

#include <sys/time.h>

volatile int SyAlarmRunning = 0;
volatile int SyAlarmHasGoneOff = 0;


#if defined(HAVE_SIGNAL) && defined(HAVE_SIGACTION) && \
    defined(HAVE_TIMER_CREATE) && defined(CLOCK_REALTIME)

/* This uses the POSIX 2001 API
   which allows per-thread timing and minimises risk of
   interference with other code using timers.

   Sadly it's not always available, so we have an alternative implementation
   below using the odler setitimer interface */

/* Handler for the Alarm signal */

int SyHaveAlarms = 1;

/* This API lets us pick wich signal to use */
#define TIMER_SIGNAL SIGVTALRM

/* For now anyway we create one timer at initialisation and use it */
static timer_t syTimer = 0;

#define MY_CLOCK CLOCK_REALTIME

void SyInitAlarm( void ) {
/* Create the CPU timer used for timeouts */
  struct sigevent se;
  se.sigev_notify = SIGEV_SIGNAL;
  se.sigev_signo = TIMER_SIGNAL;
  se.sigev_value.sival_int = 0x12345678;
  if (timer_create( MY_CLOCK, &se, &syTimer)) {
    Pr("#E  Could not create interval timer. Timeouts will not be supported\n",0L,0L);
    SyHaveAlarms = 0;
  }
}

static void syAnswerAlarm ( int signr, siginfo_t * si, void *context)
{
    /* interrupt the executor
       Later we might want to do something cleverer with throwing an
       exception or dealing better if this isn't our timer     */
  assert( signr == TIMER_SIGNAL);
  assert( si->si_signo == TIMER_SIGNAL);
  assert( si->si_code == SI_TIMER);
  assert( si->si_value.sival_int == 0x12345678 );
  SyAlarmRunning = 0;
  SyAlarmHasGoneOff = 1;
  InterruptExecStat();
}


void SyInstallAlarm ( UInt seconds, UInt nanoseconds )
{
  struct sigaction sa;

  sa.sa_handler = NULL;
  sa.sa_sigaction = syAnswerAlarm;
  sigemptyset(&(sa.sa_mask));
  sa.sa_flags = SA_RESETHAND | SA_SIGINFO | SA_RESTART;

  /* First install the handler */
  if (sigaction( TIMER_SIGNAL, &sa, NULL ))
    {
      ErrorReturnVoid("Could not set handler for alarm signal",0L,0L,"you can return to ignore");
      return;
    }


  struct itimerspec tv;
  tv.it_value.tv_sec = (time_t)seconds;
  tv.it_value.tv_nsec = (long)nanoseconds;
  tv.it_interval.tv_sec = (time_t)0;
  tv.it_interval.tv_nsec = 0L;

  SyAlarmRunning = 1;
  SyAlarmHasGoneOff = 0;
  if (timer_settime(syTimer, 0, &tv, NULL)) {
    signal(TIMER_SIGNAL, SIG_DFL);
    ErrorReturnVoid("Could not set interval timer", 0L, 0L, "you can return to ignore");
  }
  return;
}

void SyStopAlarm(UInt *seconds, UInt *nanoseconds) {
  struct itimerspec tv, buf;
  tv.it_value.tv_sec = (time_t)0;
  tv.it_value.tv_nsec = 0L;
  tv.it_interval.tv_sec = (time_t)0;
  tv.it_interval.tv_nsec = 0L;

  timer_settime(syTimer, 0, &tv, &buf);
  SyAlarmRunning = 0;
  signal(TIMER_SIGNAL, SIG_IGN);

  if (seconds)
    *seconds = (UInt)buf.it_value.tv_sec;
  if (nanoseconds)
    *nanoseconds = (UInt)buf.it_value.tv_nsec;
  return;
}

#elif defined(HAVE_SIGNAL) && defined(HAVE_SIGACTION) && \
      defined(HAVE_SETITIMER) && defined(HAVE_GETITIMER)

/* Using setitimer and getitimer from sys/time.h */
/* again sigaction could be replaced by signal if that was useful
 sigaction is just a bit more robust */

/* Handler for the Alarm signal */

int SyHaveAlarms = 1;

void SyInitAlarm( void ) {
  /* No initialisation in this case */
  return;
}

static void syAnswerAlarm ( int signr, siginfo_t * si, void *context)
{
    /* interrupt the executor
       Later we might want to do something cleverer with throwing an
       exception or dealing better if this isn't our timer     */
  assert( signr == SIGVTALRM);
  assert( si->si_signo == SIGVTALRM);
  SyAlarmRunning = 0;
  SyAlarmHasGoneOff = 1;
  InterruptExecStat();
}

void SyInstallAlarm ( UInt seconds, UInt nanoseconds )
{
  struct sigaction sa;

  sa.sa_handler = NULL;
  sa.sa_sigaction = syAnswerAlarm;
  sigemptyset(&(sa.sa_mask));
  sa.sa_flags = SA_RESETHAND | SA_SIGINFO | SA_RESTART;


  /* First install the handler */
  if (sigaction( SIGVTALRM, &sa, NULL ))
    {
      ErrorReturnVoid("Could not set handler for alarm signal",0L,0L,"you can return to ignore");
      return;
    }


  struct itimerval tv;
  tv.it_value.tv_sec = (time_t)seconds;
  tv.it_value.tv_usec = (suseconds_t)(nanoseconds/1000);
  tv.it_interval.tv_sec = (time_t)0;
  tv.it_interval.tv_usec = (suseconds_t)0L;

  SyAlarmRunning = 1;
  SyAlarmHasGoneOff = 0;
  if (setitimer(ITIMER_VIRTUAL, &tv, NULL)) {
    signal(SIGVTALRM, SIG_IGN);
    ErrorReturnVoid("Could not set interval timer", 0L, 0L, "you can return to ignore");
  }
  return;
}

void SyStopAlarm(UInt *seconds, UInt *nanoseconds) {
  struct itimerval tv, buf;
  tv.it_value.tv_sec = (time_t)0;
  tv.it_value.tv_usec = (suseconds_t)0L;
  tv.it_interval.tv_sec = (time_t)0;
  tv.it_interval.tv_usec = (suseconds_t)0L;

  setitimer(ITIMER_VIRTUAL, &tv, &buf);
  SyAlarmRunning = 0;
  signal(SIGVTALRM, SIG_IGN);

  if (seconds)
    *seconds = (UInt)buf.it_value.tv_sec;
  if (nanoseconds)
    *nanoseconds = 1000*(UInt)buf.it_value.tv_usec;
  return;
}

#else

int SyHaveAlarms = 0;

/* stub implementations */

void SyInitAlarm( void )
{
    /* No initialisation in this case */
    return;
}

void SyInstallAlarm ( UInt seconds, UInt nanoseconds )
{
    assert(0);
    return;
}

void SyStopAlarm(UInt *seconds, UInt *nanoseconds) {
    assert(0);
    return;
}

#endif
