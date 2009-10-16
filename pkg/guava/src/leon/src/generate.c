/* File generate.c. */

/* Copyright (C) 1992 by Jeffrey S. Leon.  This software may be used freely
   for educational and research purposes.  Any other use requires permission
   from the author. */

/*  Main program for generate command, which may be used
   to find a base and strong generating set for a permutation group using
   the random Schreier and/or Schreier-Todd-Coxeter-Sims methods.  The format
   of the command is:

      generate  <options>  <permGroup>  <generatedPermGroup>

   where the meaning of the parameters is as follows:

      <permGroup>:          the permutation group G for which a base and strong
                            generating set is to be found.

      <generatedPermGroup>: the same permutation group G with a base and strong
                            generating set, depending on options, possibly a
                            strong presentation.

   The general options are as follows:

      -nr            Omit random-Schreier phase.

      -ns            Omit Schreier-Todd-Coxeter-Sims phase (automatically
                     omitted if order is known in advance and random-Schreier
                     phases generates full order, unless the -p option is given.

      -p             Find a presentation.

      -q             Don't write status information to standard output.

      -in:<group>    Group G is contained in <group>.  Only base of <group> is
                     used; <group> need not be valid as long as its base ,
                     base size, and degree fields are filled in correctly.

      -overwrite     Overwrite, rather than append to, the output file.

      -i             Image format for output group.

      -c             Cycle format for output group.

      -gn:<name>

   Options applicable specifically to the random-Schreier phase are:

      -s:<integer>    Seed for random number generator.

      -tr:<integer>   Random Schreier phase terminates after this many
                      consecutive "successes" (quasi-random elements that
                      are factorable).

      -ti:<integer>   This many consecutive non-involutory generators will
                      be rejected in an attempt to choose involutory generators.

      -th:k           This many consecutive generators will be rejected in
                      an attempt to choose a generator of order 3 (or less).

      -nro            Suppress normal attempt to reduce generator order by
                      replacing generators with powers.

      -wi:w,x         Here w and x are integers with w <= x.  The word length
                      increment will be random between w and x.

      -z              Redundant strong generators will be removed after the
                      algorithm completes..

   Options applicable to the STCS phase are:

      -go:m           Automatically include the order of each generator as a
                      relator when the generator order does not exceed m
                      (default 15).

      -po:m           Automatically include the order of each product of
                      generators as a relator when the product order does
                      not exceed m (default 5).

      -x2:m           If the STCS phase terminates with more than
                      m generators (excluding inverses), redundant generators
                      are removed.

      -pr:a,b,c,d,e   Determines priority for relator selection.  The priority
                      of a relator r is  a - b * (len+symLen)/2.  Relators are
                      selected if their priority exceeds
                      c + d * chosen - e * omitted, where chosen represents the
                      number of relators chosen at this level and omitted
                      represents the number not chosen.

      -sh:i1,k1,i2..  Specifies which cyclic shifts of relators will be
                      used in the Felsch enumeration.  Specifies that an
                      i1 position shift will be used if the relator
                      priority exceeds the selection priority by at least
                      k1, etc.  By default, all shifts are always used.
      -x:k            Specifies use of up to k extra cosets during enumeration
                      (default 0).  When k > 0, a different procedure is
                      used to check point stabilizers.

      -y:m            The number of extra cosets used will be
                      m/100 * degree (rounded up), but in no case more than
                      k, as above  (default 10). */


#include <stddef.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define MAIN

#include "group.h"
#include "groupio.h"
#include "enum.h"
#include "storage.h"

#ifdef ALT_TIME_HEADER
#include "cputime.h"
#endif

#ifdef TICK
#undef CLK_TCK
#define CLK_TCK TICK
#endif

#include "errmesg.h"
#include "new.h"
#include "readgrp.h"
#include "randschr.h"
#include "stcs.h"
#include "util.h"

static void nameGenerators(
   PermGroup *const H,
   char genNamePrefix[]);

static void informGenerateTime(
   clock_t startTime,
   clock_t randSchrTime,
   clock_t optGroupTime,
   clock_t stcsTime);

static void verifyOptions(void);

GroupOptions options;
STCSOptions sOptions;

Unsigned relatorSelection[5] = {1000,0,800,0,0};
Unsigned shiftSelection[11] = {UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
                               UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
                               UNKNOWN};
Unsigned shiftPriority[11];


int main( int argc, char *argv[])
{
   char groupFileName[MAX_FILE_NAME_LENGTH] = "",
        genGroupFileName[MAX_FILE_NAME_LENGTH] = "",
        containingGroupFileName[MAX_FILE_NAME_LENGTH] = "";
   char groupLibraryName[MAX_NAME_LENGTH+1] = "",
        genGroupLibraryName[MAX_NAME_LENGTH+1] = "",
        genGroupObjectName[MAX_NAME_LENGTH+1] = "",
        containingGroupLibraryName[MAX_NAME_LENGTH+1] = "",
        prefix[MAX_FILE_NAME_LENGTH],
        suffix[MAX_NAME_LENGTH];
   Unsigned i, j, optionCountPlus1, level;
   BOOLEAN omitRandomSchreierOption, omitStcsOption, presentationOption,
           quietOption, cycleFormatFlag, imageFormatFlag, removeRedunStrGens,
           noBackupFlag;
   Unsigned trimStrGenSet1, trimStrGenSet2;
   PermGroup *G, *containingGroup;
   char comment[60] = "";
   UnsignedS *pointList = allocIntArrayBaseSize();
   char tempStr[12];
   char *strPtr, *commaPtr;
   Unsigned *knownBase = allocIntArrayBaseSize();
   RandomSchreierOptions rOptions = {47,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
                                     UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN};
   clock_t        startTime, randSchrTime, optGroupTime, stcsTime;


   /* Provide usage info if no arguments are specified. */
   if ( argc == 1 ) {
      printf( "\nUsage:  generate [options] originalPermGroup permGroupWithBaseSGS\n");
      freeIntArrayBaseSize( pointList);
      freeIntArrayBaseSize( knownBase);
      return 0;
   }

   /* Check for limits option.  If present in position 1 give limits and
      return. */
   if ( strcmp( argv[1], "-l") == 0 || strcmp( argv[1], "-L") == 0 ) {
      showLimits();
      freeIntArrayBaseSize( pointList);
      freeIntArrayBaseSize( knownBase);
      return 0;
   }

   /* Check for verify option.  If present, perform verify (Note verifyOptions
      terminates program). */
   if ( strcmp( argv[1], "-v") == 0 || strcmp( argv[1], "-V") == 0 )
      verifyOptions();

   /* Check for 1 or 2 parameters following options. */
      for ( optionCountPlus1 = 1 ; optionCountPlus1 <= argc-1 &&
                 argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
         ;

      if ( argc - optionCountPlus1 < 1 || argc - optionCountPlus1 > 2 ) {
         printf( "\n\nError: 1 or 2 non-option parameters are required.\n");
         exit(ERROR_RETURN_CODE);
      }

   /* Process options. */
   prefix[0] = '\0';
   suffix[0] = '\0';
   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   sOptions.maxDeducQueueSize = UNKNOWN;
   sOptions.genOrderLimit = 13;
   sOptions.prodOrderLimit = 3;
   sOptions.maxExtraCosets = 0;
   sOptions.percentExtraCosets = 10;
   omitRandomSchreierOption = FALSE;
   omitStcsOption = TRUE;
   presentationOption = FALSE;
   rOptions.reduceGenOrder = TRUE;
   rOptions.rejectNonInvols = 0;
   removeRedunStrGens = FALSE;
   quietOption = FALSE;
   options.genNamePrefix[0] = '\0';
   trimStrGenSet1 = 20;
   trimStrGenSet2 = 20;
   cycleFormatFlag = FALSE;
   imageFormatFlag = FALSE;
   noBackupFlag = FALSE;
   strcpy( options.outputFileMode, "w");
   strcpy( options.genNamePrefix, "");

   for ( i = 1 ; i < optionCountPlus1 ; ++i )

      /* General options. */
      if ( strcmp( argv[i], "-a") == 0 )
         strcpy( options.outputFileMode, "a");
      else if ( strcmp( argv[i], "-c") == 0 )
         cycleFormatFlag = TRUE;
      else if ( strcmp( argv[i], "-i") == 0 )
         imageFormatFlag = TRUE;
      else if ( strncmp( argv[i], "-mb:", 4) == 0 ) {
         errno = 0;
         options.maxBaseSize = (Unsigned) strtol(argv[i]+4,NULL,0);
         if ( errno )
            ERROR( "main (cent)", "Invalid syntax for -mb option")
      }
      else if ( strncmp( argv[i], "-mw:", 4) == 0 ) {
         errno = 0;
         options.maxWordLength = (Unsigned) strtol(argv[i]+4,NULL,0);
         if ( errno )
            ERROR( "main (cent)", "Invalid syntax for -mw option")
      }
      else if ( strncmp(argv[i],"-n:",3) == 0 )
         strcpy( genGroupObjectName, argv[i]+3);
      else if ( strcmp( argv[i], "-nb") == 0 )
         noBackupFlag = TRUE;
      else if ( strcmp( argv[i], "-overwrite") == 0 )
         strcpy( options.outputFileMode, "w");
      else if ( strncmp( argv[i], "-p:", 3) == 0 ) {
         strcpy( prefix, argv[i]+3);
      }
      else if ( strcmp( argv[i], "-q") == 0 )
         quietOption = TRUE;
      else if ( strncmp( argv[i], "-t:", 3) == 0 ) {
         strcpy( suffix, argv[i]+3);
      }
      else if ( strcmp( argv[i], "-z") == 0 ) {
         removeRedunStrGens = TRUE;
      }

      /* Method selection options. */
      else if ( strcmp( argv[i], "-nr") == 0 )
         omitRandomSchreierOption = TRUE;
      else if ( strcmp( argv[i], "-stcs") == 0 )
         omitStcsOption = FALSE;

      /* Random Schreier options. */
      else if ( strcmp( argv[i], "-nro") == 0 )
         rOptions.reduceGenOrder = FALSE;
      else if ( strncmp(argv[i],"-s:",3) == 0 ) {
         errno = 0;
         rOptions.initialSeed = (unsigned long) strtol( argv[i]+3, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")
      }
      else if ( strncmp(argv[i],"-ti:",4) == 0 ) {
         errno = 0;
         rOptions.rejectNonInvols = (unsigned long) strtol( argv[i]+4, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")
      }
      else if ( strncmp(argv[i],"-tr:",4) == 0 ) {
         errno = 0;
         rOptions.stopAfter = (unsigned long) strtol( argv[i]+4, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")
      }
      else if ( strncmp( argv[i], "-wi:", 4) == 0 ) {
         errno = 0;
         rOptions.minWordLengthIncrement = (unsigned long) strtol( argv[i]+4, &commaPtr, 0);
         if ( errno || *commaPtr != ',' )
            ERROR1s( "main (generate command)", "Invalid syntax in option ",
                     argv[i], ".")
         rOptions.maxWordLengthIncrement = (unsigned long) strtol( commaPtr+1, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid syntax in option ",
                     argv[i], ".")
      }

      /* STCS options. */
      else if ( strncmp( argv[i], "-in:", 4) == 0 ) {
         parseLibraryName( argv[i]+4, "", "", containingGroupFileName,
                                              containingGroupLibraryName);
      }
      else if ( strncmp(argv[i],"-pr:",4) == 0 ) {
         errno = 0;
         commaPtr = argv[i]+3;
         for ( j = 0 ; j <= 4 ; ++j ) {
            strPtr = commaPtr + 1;
            relatorSelection[j] = (Unsigned) (unsigned long) strtol( strPtr, &commaPtr, 0);
            if ( errno || ( j < 4 && *commaPtr != ',') )
               ERROR1s( "main (generate command)", "Invalid option ", argv[i],
                        ".")
         }
      }
      else if ( strncmp(argv[i],"-sh:",4) == 0 ) {
         errno = 0;
         commaPtr = argv[i]+3;
         for ( j = 0 ; j < 10 && *commaPtr != '\0' ; ++j ) {
            strPtr = commaPtr + 1;
            shiftSelection[j] = (Unsigned) (unsigned long) strtol( strPtr, &commaPtr, 0);
            if ( errno || *commaPtr != ',' )
               ERROR1s( "main (generate command)", "Invalid option ", argv[i],
                        ".")
            strPtr = commaPtr + 1;
            shiftPriority[j] = (Unsigned) (unsigned long) strtol( strPtr, &commaPtr, 0);
            if ( errno || (*commaPtr != ',' && *commaPtr != '\0') )
               ERROR1s( "main (generate command)", "Invalid option ", argv[i],
                        ".")
         }
      }
      else if ( strncmp(argv[i],"-th:",4) == 0 ) {
         errno = 0;
         rOptions.rejectHighOrder = (unsigned long) strtol( argv[i]+4, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")
      }
      else if ( strncmp(argv[i],"-go:",4) == 0 ) {
         errno = 0;
         sOptions.genOrderLimit = (unsigned long) strtol( argv[i]+4, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")
      }
      else if ( strncmp(argv[i],"-po:",4) == 0 ) {
         errno = 0;
         sOptions.prodOrderLimit = (unsigned long) strtol( argv[i]+4, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")
      }
      else if ( strncmp(argv[i],"-x:",3) == 0 ) {
         errno = 0;
         sOptions.maxExtraCosets = (unsigned long) strtol( argv[i]+3, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")
      }
      else if ( strncmp(argv[i],"-y:",3) == 0 ) {
         errno = 0;
         sOptions.percentExtraCosets = (unsigned long) strtol( argv[i]+3, NULL, 0);
         if ( errno )
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")
      }
      else
            ERROR1s( "main (generate command)", "Invalid option ", argv[i], ".")

   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;


   /* Compute names for input and output groups. */
   parseLibraryName( argv[optionCountPlus1], prefix, suffix, groupFileName,
                     groupLibraryName);
   if ( argc - optionCountPlus1 == 2 )
      parseLibraryName( argv[optionCountPlus1+1], "", "", genGroupFileName,
                        genGroupLibraryName);
   else {
      strcpy( genGroupFileName, groupFileName);
      strcpy( genGroupLibraryName, groupLibraryName);
   }   

   /* Set initialize option for STCS. */
   sOptions.initialize = omitRandomSchreierOption;

   /* Set default generator name prefix, if not specified. */
   if ( options.genNamePrefix[0] == ' ' )
      strncpy( options.genNamePrefix, genGroupLibraryName, 4);

   /* Read in input group, and base for containing group, if requested. */
   G = readPermGroup( groupFileName, groupLibraryName, 0, "");
   if ( containingGroupFileName[0] ) {
      containingGroup = readPermGroup( containingGroupFileName,
                                 containingGroupLibraryName, G->degree, "");
      for ( i = 1 ; i <= containingGroup->baseSize ; ++i )
         knownBase[i] = containingGroup->base[i];
      knownBase[containingGroup->baseSize+1] = 0;
      deletePermGroup( containingGroup);
   }

   startTime = CPU_TIME();

   /* Apply random Schreier algorithm. */
   if ( !omitRandomSchreierOption ) {
      /* SETUP OPTIONS STRING */
      randomSchreier( G, rOptions);
      if ( removeRedunStrGens )
         removeRedunSGens( G, 1);
   }
   randSchrTime = CPU_TIME();

   optGroupTime = CPU_TIME();

   /* Apply Schreier-Todd-Coxeter-Sims algorithm, if appropriate. */
   if ( !omitStcsOption /* FIX THIS */ )
      schreierToddCoxeterSims( G, knownBase);
   stcsTime = CPU_TIME();

   if ( !quietOption ) {
      informGroup(G);
      printf( "\n  Base:               ");
      for ( level = 1 ; level <= G->baseSize ; ++level )
         printf( " %5u", G->base[level]);
      printf(   "\n  Basic orbit lengths:");
      for ( level = 1 ; level <= G->baseSize ; ++level )
         printf( " %5u", G->basicOrbLen[level]);
      printf( "\n");
      informGenerateTime( startTime, randSchrTime, optGroupTime, stcsTime);
   }

   /* Write out the generated group. */
   sprintf( comment, "The group %s, base and strong generating set constucted.",
            G->name);
   if ( cycleFormatFlag )
      G->printFormat = cycleFormat;
   if ( imageFormatFlag )
      G->printFormat = imageFormat;
   if ( genGroupObjectName[0] )
      strcpy( G->name, genGroupObjectName);
   if ( argc - optionCountPlus1 == 1 && !noBackupFlag ) 
      if ( rename(groupFileName,"oldgroup") == -1 )
         ERROR1s( "main (generate command)", "Original group ", groupFileName,
                  " could not be renamed as oldgroup.")
      
   writePermGroup( genGroupFileName, genGroupLibraryName, G, comment);

   /* Free pseudo-stack storage. */
   freeIntArrayBaseSize( pointList);
   freeIntArrayBaseSize( knownBase);

   return 0;
}


/*-------------------------- nameGenerators ------------------------------*/

static void nameGenerators(
   PermGroup *const H,
   char genNamePrefix[])
{
   Unsigned i;
   Permutation *gen;

   if ( genNamePrefix[0] == '\0' ) {
      strncpy( genNamePrefix, H->name, 4);
      genNamePrefix[4] = '\0';
   }
   for ( gen = H->generator , i = 1 ; gen ; gen = gen->next , ++i ) {
      strcpy( gen->name, genNamePrefix);
      sprintf( gen->name + strlen(gen->name), "%02d", i);
   }
}


/*-------------------------- verifyOptions -------------------------------*/

static void verifyOptions(void)
{
   CompileOptions mainOpts = { DEFAULT_MAX_BASE_SIZE, MAX_NAME_LENGTH,
                               MAX_PRIME_FACTORS,
                               MAX_REFINEMENT_PARMS, MAX_FAMILY_PARMS,
                               MAX_EXTRA,  XLARGE, SGND, NFLT};
   extern void xaddsge( CompileOptions *cOpts);
   extern void xbitman( CompileOptions *cOpts);
   extern void xchbase( CompileOptions *cOpts);
   extern void xcopy  ( CompileOptions *cOpts);
   extern void xcstbor( CompileOptions *cOpts);
   extern void xerrmes( CompileOptions *cOpts);
   extern void xessent( CompileOptions *cOpts);
   extern void xfactor( CompileOptions *cOpts);
   extern void xinform( CompileOptions *cOpts);
   extern void xnew   ( CompileOptions *cOpts);
   extern void xoldcop( CompileOptions *cOpts);
   extern void xpermgr( CompileOptions *cOpts);
   extern void xpermut( CompileOptions *cOpts);
   extern void xprimes( CompileOptions *cOpts);
   extern void xrandgr( CompileOptions *cOpts);
   extern void xrandsc( CompileOptions *cOpts);
   extern void xreadgr( CompileOptions *cOpts);
   extern void xrelato( CompileOptions *cOpts);
   extern void xstcs  ( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);

   xaddsge( &mainOpts);
   xbitman( &mainOpts);
   xchbase( &mainOpts);
   xcopy  ( &mainOpts);
   xcstbor( &mainOpts);
   xerrmes( &mainOpts);
   xessent( &mainOpts);
   xfactor( &mainOpts);
   xinform( &mainOpts);
   xnew   ( &mainOpts);
   xoldcop( &mainOpts);
   xpermgr( &mainOpts);
   xpermut( &mainOpts);
   xprimes( &mainOpts);
   xrandgr( &mainOpts);
   xrandsc( &mainOpts);
   xreadgr( &mainOpts);
   xrelato( &mainOpts);
   xstcs  ( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}


/*-------------------------- informGenerateTime ----------------------------*/

static void informGenerateTime(
   clock_t startTime,
   clock_t randSchrTime,
   clock_t optGroupTime,
   clock_t stcsTime)
{
   clock_t  totalTime;
#ifdef NOFLOAT
   unsigned long secs, hSecs;
#endif

   stcsTime -= optGroupTime;
   optGroupTime -= randSchrTime;
   randSchrTime -= startTime;
   totalTime = randSchrTime + optGroupTime + stcsTime;

#ifndef NOFLOAT
   printf(   "\nTime:   Random Schreier:    %6.2lf sec",
                        (double) randSchrTime / CLK_TCK);
   printf(   "\n        Gen optimization:   %6.2lf sec",
                        (double) optGroupTime / CLK_TCK);
   printf(   "\n        Schr-Todd-Cox-Sims: %6.2lf sec",
                        (double) stcsTime / CLK_TCK);
   printf(   "\n        TOTAL:              %6.2lf sec",
                        (double) totalTime / CLK_TCK);
#endif

#ifdef NOFLOAT
   secs = randSchrTime / CLK_TCK;
   hSecs = (randSchrTime - secs * CLK_TCK) * 100;
   hSecs /= CLK_TCK;
   printf(   "\nTime:   Random Schreier:    %4lu.%02lu sec", secs, hSecs);
   secs = optGroupTime / CLK_TCK;
   hSecs = (optGroupTime - secs * CLK_TCK) * 100;
   hSecs /= CLK_TCK;
   printf(   "\n        Gen optimization:   %4lu.%02lu sec", secs, hSecs);
   secs = stcsTime / CLK_TCK;
   hSecs = (stcsTime - secs * CLK_TCK) * 100;
   hSecs /= CLK_TCK;
   printf(   "\n        Schr-Todd-Cox-Sims: %4lu.%02lu sec", secs, hSecs);
   secs = totalTime / CLK_TCK;
   hSecs = (totalTime - secs * CLK_TCK) * 100;
   hSecs /= CLK_TCK;
   printf(   "\n        TOTAL:              %4lu.%02lu sec", secs, hSecs);
#endif

   printf(   "\n");
}
