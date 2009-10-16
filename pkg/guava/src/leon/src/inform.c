/* File inform.c. */

#include <stdio.h>
#include <string.h>
#include <time.h>

#include "group.h"
#include "groupio.h"

#ifdef ALT_TIME_HEADER
#include "cputime.h"
#endif

#ifdef TICK
#undef CLK_TCK
#define CLK_TCK TICK
#endif

#include "readgrp.h"

CHECK( inform)

extern GroupOptions options;

void informStatistics(
   Unsigned ell,
   unsigned long nodesVisited[],
   unsigned long nodesPruned[],
   unsigned long nodesEssential[])
{
   Unsigned level;
   unsigned long totalVisited = 0, totalPruned = 0, totalEssential = 0;

   printf( "\n\nSummary of backtrack tree nodes traversed and pruned.");

   printf( "\n\n   Level       Nodes        Nodes     Nodes non-    Pruning");
   printf(   "\n              visited       pruned     essential   percentage\n");
   for ( level = 0 ; level <= ell ; ++level ) {
      if ( nodesEssential[level] < nodesVisited[level] )
#ifndef NOFLOAT
         printf( "\n    %3u   %10lu   %10lu   %10lu       %6.4f", level,
                 nodesVisited[level], nodesPruned[level],
                 nodesVisited[level] - nodesEssential[level],
                 (float) nodesPruned[level] /
                 (nodesVisited[level] - nodesEssential[level]) );
#endif
#ifdef NOFLOAT
         printf( "\n    %3u   %10lu   %10lu   %10lu", level,
                 nodesVisited[level], nodesPruned[level],
                 nodesVisited[level] - nodesEssential[level]);
#endif
      else
         printf( "\n    %3u   %10lu   %10lu   %10lu       ------", level,
                nodesVisited[level], nodesPruned[level],
                nodesVisited[level] - nodesEssential[level]);
      totalVisited += nodesVisited[level];
      totalPruned += nodesPruned[level];
      totalEssential += nodesEssential[level];
   }
   if ( totalEssential < totalVisited )
#ifndef NOFLOAT
      printf( "\n   total  %10lu   %10lu   %10lu       %6.4f\n", totalVisited,
              totalPruned, totalVisited - totalEssential, (float) totalPruned /
              (totalVisited - totalEssential) );
#endif
#ifdef NOFLOAT
      printf( "\n   total  %10lu   %10lu   %10lu\n", totalVisited, totalPruned);
#endif
   else
      printf( "\n   total  %10lu   %10lu   %10lu       ------\n", totalVisited,
              totalPruned, totalVisited - totalEssential);
}


/*-------------------------- informOptions ---------------------------------*/

void informOptions(void)
{
   printf("\nOptions:  -b:%u  -g:%u  -r:%u  -mb:%u  -mw:%u\n",
          (unsigned) options.maxBaseChangeLevel,
          (unsigned) options.maxStrongGens,
          (unsigned) options.trimSGenSetToSize,
          (unsigned) options.maxBaseSize,
          (unsigned) options.maxWordLength);
}


/*-------------------------- informGroup -----------------------------------*/

void informGroup(
   const PermGroup *const G)
{
   Unsigned i;

   if ( IS_SYMMETRIC(G) ) {
      printf( "\nGroup %s is symmetric of degree %d.\n ", G->name, G->degree);
      return;
   }

   printf( "\nGroup %s has order ", G->name);

   if ( G->order->noOfFactors == 0 )
      printf( "%d", 1);
   else
      for ( i = 0 ; i < G->order->noOfFactors ; ++i ) {
         if ( i > 0 )
            printf( " * ");
         printf( "%u", G->order->prime[i]);
         if ( G->order->exponent[i] > 1 )
            printf( "^%u", G->order->exponent[i]);
      }
   printf( "\n");
}


/*-------------------------- informRBase -----------------------------------*/

void informRBase(
   const PermGroup *const G,
   const RBase *const AAA,
   const UnsignedS basicCellSize[])
{
   Unsigned i, level;

   printf( "\nR-base construction complete.");

   printf( "\n\n  New base for group %s:", G->name);
   for ( level = 1 ; level <= G->baseSize ; ++level )
      printf( " %5u", G->base[level]);
   printf(   "\n  Basic orbit lengths:");
   for ( i = 1 ; i <= strlen(G->name) ; ++i )
      printf( " ");
   for ( level = 1 ; level <= G->baseSize ; ++level )
      printf( " %5u", G->basicOrbLen[level]);

   printf( "\n\n  Base for subgroup:  ");
   for ( level = 1 ; level <= AAA->ell ; ++level )
      printf( " %5u", AAA->alphaHat[level]);
   printf(   "\n  Basic cell sizes:   ");
   for ( level = 1 ; level <= AAA->ell ; ++level )
      printf( " %5u", basicCellSize[level]);
   printf( "\n\n");
}


/*-------------------------- informSubgroup --------------------------------*/

void informSubgroup(
   const PermGroup *const G_pP)
{
   Unsigned i, level;

   if ( !options.groupOrderMessage )
      options.groupOrderMessage = "Subgroup";
   printf( "\n%s computation complete.", options.groupOrderMessage);

   printf( "\n\n  %s has order ", options.groupOrderMessage);
   if ( G_pP->order->noOfFactors > 0 )
      for ( i = 0 ; i < G_pP->order->noOfFactors ; ++i ) {
         if ( i > 0 )
            printf( " * ");
         printf( "%u", G_pP->order->prime[i]);
         if ( G_pP->order->exponent[i] > 1 )
            printf( "^%u", G_pP->order->exponent[i]);
      }
   else
      printf( "1");
   printf( ".");


   printf( "\n\n  Base:               ");
   for ( level = 1 ; level <= G_pP->baseSize ; ++level )
      printf( " %5u", G_pP->base[level]);
   printf(   "\n  Basic orbit lengths:");
   for ( level = 1 ; level <= G_pP->baseSize ; ++level )
      printf( " %5u", G_pP->basicOrbLen[level]);
   printf( "\n");
}


/*-------------------------- informCosetRep --------------------------------*/

void informCosetRep(
   Permutation *y)
{
   Unsigned trueDegree;

   if ( y ) {
      trueDegree = y->degree;
      if ( !options.cosetRepMessage )
         options.cosetRepMessage = "Coset representative found:";
      printf( "\n%s\n\n", options.cosetRepMessage);
      if ( options.altInformCosetRep ) {
         setOutputFile( stdout);
         (*options.altInformCosetRep)( y);
      }
      else if ( (options.restrictedDegree ? options.restrictedDegree 
                                    : y->degree) <= options.writeConjPerm ) {
         setOutputFile( stdout);
         if ( options.restrictedDegree != 0 ) {
            printf("  ");
            y->degree = options.restrictedDegree;
            writeCyclePerm( y, 3, 5, 72);
            y->degree = trueDegree;
         }
         else {
            printf("  ");
            writeCyclePerm( y, 3, 5, 72);
         }
      }
      else
         printf( "     <permutation written to library file>");
   }
   else {
      if ( !options.noCosetRepMessage )
         options.noCosetRepMessage = "Coset representative does not exist.";
      printf( "\n%s\n", options.noCosetRepMessage);
   }
}


/*-------------------------- informNewGenerator ----------------------------*/

void informNewGenerator(
   const PermGroup *const G_pP,
   const Unsigned newLevel)
{
   Unsigned level;
   static BOOLEAN firstCall = TRUE;

   if ( firstCall ) {
      printf("\n");
      firstCall = FALSE;
   }
   printf( "New generator (level %u):  basic orbit lengths ", newLevel);
   for ( level = 1 ; level <= G_pP->baseSize ; ++level )
      printf( " %u ", G_pP->basicOrbLen[level]);
   printf( "\n");
}


/*-------------------------- informTime ------------------------------------*/

void informTime(
   clock_t startTime,
   clock_t RBaseTime,
   clock_t optGroupTime,
   clock_t backtrackTime)
{
   clock_t  totalTime;
#ifdef NOFLOAT
   unsigned long secs, hSecs;
#endif

   backtrackTime -= optGroupTime;
   optGroupTime -= RBaseTime;
   RBaseTime -= startTime;
   totalTime = RBaseTime + optGroupTime + backtrackTime;

#ifndef NOFLOAT
   printf( "\n\nTime:   RBase construction: %6.2lf sec",
                        (double) RBaseTime / CLK_TCK);
   printf(   "\n        Group optimization: %6.2lf sec",
                        (double) optGroupTime / CLK_TCK);
   printf(   "\n        Backtrack search:   %6.2lf sec",
                        (double) backtrackTime / CLK_TCK);
   printf(   "\n        TOTAL:              %6.2lf sec",
                        (double) totalTime / CLK_TCK);
#endif

#ifdef NOFLOAT
   secs = RBaseTime / CLK_TCK;
   hSecs = (RBaseTime - secs * CLK_TCK) * 100;
   hSecs /= CLK_TCK;
   printf( "\n\nTime:   RBase construction: %4lu.%02lu sec", secs, hSecs);
   secs = optGroupTime / CLK_TCK;
   hSecs = (optGroupTime - secs * CLK_TCK) * 100;
   hSecs /= CLK_TCK;
   printf(   "\n        Group optimization: %4lu.%02lu sec", secs, hSecs);
   secs = backtrackTime / CLK_TCK;
   hSecs = (backtrackTime - secs * CLK_TCK) * 100;
   hSecs /= CLK_TCK;
   printf(   "\n        Backtrack search:   %4lu.%02lu sec", secs, hSecs);
   secs = totalTime / CLK_TCK;
   hSecs = (totalTime - secs * CLK_TCK) * 100;
   hSecs /= CLK_TCK;
   printf(   "\n        TOTAL:              %4lu.%02lu sec", secs, hSecs);
#endif

   printf(   "\n");
}
