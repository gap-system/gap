/* Could live without sigaction but it seems to be pretty universal */

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

#if SYS_IS_CYGWIN32
#define MY_CLOCK CLOCK_REALTIME
#else
#define MY_CLOCK CLOCK_THREAD_CPUTIME_ID
#endif

static void SyInitAlarm( void ) {
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
