/* Using setitimer and getitimer from sys/time.h */
/* again sigaction could be replaced by signal if that was useful
 sigaction is just a bit more robust */

/* Handler for the Alarm signal */

int SyHaveAlarms = 1;

static void SyInitAlarm( void ) {
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
