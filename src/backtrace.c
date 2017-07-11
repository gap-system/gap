#include <src/system.h>
#include <src/gapstate.h>

#ifdef PRINT_BACKTRACE
#include <execinfo.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>

void BacktraceHandler(int sig) {
  void *trace[32];
  size_t size;
  const char *sigtext = "Unknown signal";
  size = backtrace(trace, 32);
  switch (sig) {
    case SIGSEGV:
      sigtext = "Segmentation fault"; break;
    case SIGBUS:
      sigtext = "Bus error"; break;
    case SIGINT:
      sigtext = "Interrupt"; break;
    case SIGABRT:
      sigtext = "Abort"; break;
    case SIGFPE:
      sigtext = "Floating point exception"; break;
    case SIGTERM:
      sigtext = "Program terminated"; break;
  }
  fprintf(stderr, "%s\n", sigtext);
  backtrace_symbols_fd(trace, size, fileno(stderr));
  exit(1);
}

void InstallBacktraceHandlers() {
  signal(SIGSEGV, BacktraceHandler);
  signal(SIGBUS, BacktraceHandler);
  signal(SIGINT, BacktraceHandler);
  signal(SIGABRT, BacktraceHandler);
  signal(SIGFPE, BacktraceHandler);
  signal(SIGTERM, BacktraceHandler);
}

#endif
