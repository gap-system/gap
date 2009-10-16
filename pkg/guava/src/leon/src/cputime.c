/* File cputime.c.  Contain Unix function cpuTime returning the CPU
   time in  milliseconds (user+system) used by the current program. 
   Works at least on Sun/3 and Sun/4. */

#include <time.h>
#include <sys/time.h>
#include <sys/resource.h>

#ifndef TICK
  #error TICK must be defined.
#endif

#if TICK != 1000
  #error TICK must have value 1000
#endif

#undef CLK_TCK
#define CLK_TCK 1000

clock_t cpuTime(void)
{
   struct rusage usage;

   getrusage( RUSAGE_SELF, &usage);
   return (clock_t) ( usage.ru_utime.tv_usec / 1000 +
                      usage.ru_utime.tv_sec * 1000  +
                      usage.ru_stime.tv_usec / 1000 +
                      usage.ru_stime.tv_sec * 1000 );
}
