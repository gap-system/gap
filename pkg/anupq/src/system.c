/****************************************************************************
**
*A  system.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: system.c,v 1.10 2011/12/31 19:36:23 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_author.h"
#include "pq_defs.h"
#include <sys/types.h>
#include <sys/times.h>

/* system and operating system dependent pieces of code */

/* return CPU time in CLOCK TICKS -- the program should report 
   correct CPU times for each of SunOS and Solaris if compiled 
   and run under that operating system; under Solaris, 
   CLK_TCK is defined in <limits.h>; if compiled under SunOS
   and run under Solaris, then multiply reported times by
   3/5 to get correct user time */

int runTime ()
{
   struct tms buffer;

   times(&buffer);
   return buffer.tms_utime + buffer.tms_cutime;
}

/* print startup message */

void print_message (int work_space)
{
   time_t now;
   char *id;
   char string[100];

#if defined (HAVE_GETHOSTNAME) 
   char s[100];
   gethostname (s, 100);
#else 
   char *s = (char *)getenv ("HOST");
   if (s == NULL) s = "unknown";
#endif 

#if defined (GROUP) 
   id = PQ_VERSION;
#endif 

   printf ("%s running with workspace %d on %s\n", 
	   id, work_space, s);
   now = time (NULL);
#ifdef HAVE_STRFTIME
   strftime (string, 100, "%a %b %d %H:%M:%S %Z %Y", localtime (&now));
   printf ("%s\n", string);
#else
   printf ("\n");
#endif
}
