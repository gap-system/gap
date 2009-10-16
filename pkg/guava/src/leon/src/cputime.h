#ifndef CPUTIME
#define CPUTIME

#ifdef CLK_TCK
  #undef CLK_TCK
#endif
#define CLK_TCK 1000

extern clock_t cpuTime(void)
;

#endif
