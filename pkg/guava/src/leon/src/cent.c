/* File cent.c. */

/* Copyright (C) 1992 by Jeffrey S. Leon.  This software may be used freely
   for educational and research purposes.  Any other use requires permission
   from the author. */

/*  Main program for element centralizer and conjugacy commands.
   The formats for the commands are:

      cent        <options> <permGroup> <element> <centGroup>
      cent -conj  <options> <permGroup> <element1> <element2> <conjElement>
      cent -group <options> <permGroup> <groupToCent> <centGroup>

   where the meaning of the parameters is as follows:

      <permGroup>: The name of the file containing the permutation group G,
                   or the Cayley library name in which the permutation group
                   G is defined.  Except in the case of a Cayley library,
                   a file type of GRP is appended.
      <pointSet>:  The name of the file containing the point set Lambda, or the
                   Cayley library name in which the point set Lambda is defined.
                   Except in the case of a Cayley library, a file type of PTS
                   is appended.
      <stabGroup>: The name of the file in which the set stabilizer G_Lambda
                   is written, or the Cayley library name to which the
                   definition of G_Lambda is written.  Except in the case of
                   a Cayley library, a file type of PTS is appended.

   The options are as follows:

      -a          If the output file exists, it will be appended to rather than
                  overwritten.  (A Cayley library is always appended to rather
                  than overwritten.)

      -b:<int>    Base change in the subgroup being computed will be performed
                  at levels fm, fm+1,...,fm+<int>-1 only, where fm is the level
                  of the first base point (of the subgroup) moved by the current
                  permutation.  Values below 1 will be raised to 1; those above
                  the base size will be reduced to the base size.

      -c          Compress the group G after an R-base has been constructed.
                  This saves a moderate amount of memory at the cost of
                  relatively little CPU time, but the group (in memory) is
                  effectively destroyed.

      -crl:<name> The definition of the group G and point set Lambda should be
                  read from Cayley library <permGroup> in library file <name>.

      -cwl:<name> The definition for the group G_Lambda should be written to
                  Cayley library <stabGroup> library file <name>.

      -g:<int>    The maximum number of strong generators for the containing
                  group G.  If, after construction of a base and strong
                  generating set for G, the number of strong generators is
                  less than this number, additional strong generators will be
                  added, chosen to reduce the length of the coset
                  representatives (as words).   A larger value may increase
                  speed of computation slightly at the cost of extra space.
                  If, after construction of the base and strong generating set,
                  the number of strong generators exceeds this number, at
                  present strong generators are not removed.

      -gn:<str>   (Set stabilizer only).  The generators for the newly-created
                  group created are given names <str>01, <str>02, ...  .  If
                  omitted, the new generators are unnamed.

      -i          The generators of <stabGroup> are to be written in image format.

      -n:<name>   The name for the set stabilizer or coset rep being computed.
                  (Default: the file name <stabGroup> -- file type omitted)

      -q          As the computation proceeds, writing of information about
                  the current state to standard output is suppressed.

      -s:<name>   A known subgroup of the set stabilizer being computed.
                  (Default: no subgroup known)

       -r:<int>   During base change, if insertion of a new base point
                  expands the size of the strong generating set above
                  <int> gens (not counting inverses), redundant strong
                  generators are trimmed from the strong generating set.
                  (Default 25).

      -t          Upon conclusion, statistics regarding the number of nodes
                  of the backtrack search tree traversed is written to the
                  standard output.

      -v          Verify that all files were compiled with the same compile-
                  time parameters and stop.

      -w:<int>    For set or partition image computations in which the sets
                  or partitions turn out to be equivalent, a permutation
                  mapping one to the other is written to the standard output,
                  as well as a disk file, provided the degree is at most <int>.
                  (The option is ignored if -q is in effect.)  Default: 100

      -x:<int>    The ideal size for basic cells is set to <int>.

      -z          Subject to the restrictions imposed by the -b option above,
                  check Prop. 8.3 in "Permutation group algorithms based on
                  partitions".

   If a base for <permGroup> is not available, one will be computed.  In any
   the base and strong generating set for <permGroup> will be changed during
   the computation.

   The return code for set or partition stabilizer computations is as follows:
      0: computation successful,
      2: computation terminated due to error.
   The return code for set or partition image computations is as follows:
      0: computation successful; sets or partitions are equivalent,
      1: computation successful; sets or partitions are not equivalent,
      255: computation terminated due to error.
*/



#include <stddef.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#define MAIN

#include "group.h"
#include "groupio.h"

#include "ccent.h"
#include "errmesg.h"
#include "permgrp.h"
#include "readgrp.h"
#include "readper.h"
#include "storage.h"
#include "token.h"
#include "util.h"


GroupOptions options;

UnsignedS (*chooseNextBasePoint)(
   const PermGroup *const G,
   const PartitionStack *const UpsilonStack);

static void verifyOptions(void);

int main( int argc, char *argv[])
{
   char permGroupFileName[MAX_FILE_NAME_LENGTH] = "",
        eltOrGrpFileName[MAX_FILE_NAME_LENGTH] = "",
        *element_L_FileName = eltOrGrpFileName,
        element_R_FileName[MAX_FILE_NAME_LENGTH] = "",
        knownSubgroupSpecifier[MAX_FILE_NAME_LENGTH] = "",
        *knownSubgroup_L_Specifier = knownSubgroupSpecifier,
        knownSubgroup_R_Specifier[MAX_FILE_NAME_LENGTH] = "",
        knownSubgroupFileName[MAX_FILE_NAME_LENGTH] = "",
        *knownSubgroup_L_FileName = knownSubgroupFileName,
        knownSubgroup_R_FileName[MAX_FILE_NAME_LENGTH] = "",
        outputFileName[MAX_FILE_NAME_LENGTH] = "";
   Unsigned i, j, optionCountPlus1, centPartnCount, centGenCount, startOptions;
   char outputObjectName[MAX_NAME_LENGTH+1] = "",
        outputLibraryName[MAX_NAME_LENGTH+1] = "",
        permGroupLibraryName[MAX_NAME_LENGTH+1] = "",
        eltOrGrpLibraryName[MAX_NAME_LENGTH+1] = "",
        knownSubgroupLibraryName[MAX_NAME_LENGTH+1] = "",
        *element_L_LibraryName = eltOrGrpLibraryName,
        element_R_LibraryName[MAX_NAME_LENGTH+1] = "",
        *knownSubgroup_L_LibraryName = knownSubgroupLibraryName,
        knownSubgroup_R_LibraryName[MAX_NAME_LENGTH+1] = "",
        prefix[MAX_FILE_NAME_LENGTH],
        suffix[MAX_NAME_LENGTH];
   PermGroup *G, *G_pP, *L = NULL, *L_L = NULL, *L_R = NULL, *E;
   Permutation *y;
   Permutation *e, *f;
   BOOLEAN imageFlag = FALSE, imageFormatFlag = FALSE, noPartn = FALSE,
           longCycleOption, stdRBaseOption;
   Unsigned symmetricDegree = 0;
   char tempArg[8], *nextChar;
   enum { ELT_CENTRALIZER, ELT_CONJUGATE, GROUP_CENTRALIZER} computationType =
                                                             ELT_CENTRALIZER;
   char comment[100];

   /* Check whether the first parameter is conj or group.  If so, a conjugacy
      (rather than centralizer) or group centralizer computation will be
      performed, and the valid remaining parameters will be different. */
   if ( argc > 1 ) {
      strncpy( tempArg, argv[1], 8);
      tempArg[7] = '\0';
      lowerCase( tempArg);
      if ( strcmp( tempArg, "-conj") == 0 ) {
         computationType = ELT_CONJUGATE;
         imageFlag = TRUE;
         startOptions = 2;
      }
      else if ( strcmp( tempArg, "-group") == 0 ) {
         computationType = GROUP_CENTRALIZER;
         imageFlag = FALSE;
         startOptions = 2;
      }
      else {
         computationType = ELT_CENTRALIZER;
         imageFlag = FALSE;
         startOptions = 1;
      }
   }
   else
      startOptions = 1;

   /* Provide help if no arguments are specified. Note i and j must be as
      described above. */
   if ( startOptions == argc ) {
      switch( computationType ) {
         case ELT_CENTRALIZER:  
             printf( "\nUsage:  cent [options] permGroup permutation centralizerSubgroup\n");
             break;
         case GROUP_CENTRALIZER:  
             printf( "\nUsage:  gcent [options] permGroup1 permGroup2 centralizerSubgroup\n");
             break;
         case ELT_CONJUGATE:  
             printf( "\nUsage:  conj [options] permGroup permutation1 permutation2 conjugatingElement\n");
             break;
      }
      return 0;
   }

   /* Check for limits option.  If present in position i (i as above) give
      limits and return. */
   if ( startOptions < argc && (strcmp(argv[startOptions], "-l") == 0 || 
                                strcmp(argv[startOptions], "-L") == 0) ) {
      showLimits();
      return 0;
   }
   /* Check for verify option.  If present in position i (i as above) perform
      verify (Note verifyOptions terminates program). */
   if ( startOptions < argc && (strcmp(argv[startOptions], "-v") == 0 || 
                                strcmp(argv[startOptions], "-V") == 0) )
      verifyOptions();
   if ( argc < 4 )
      ERROR( "main (cent)", "Too few parameters.")

   /* Check for exactly 3 (centralizer) or 4 (conjugate) parameters
      following options.  Note i must be as above. */
   for ( optionCountPlus1 = startOptions ; optionCountPlus1 < argc &&
              argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
      ;

   if ( argc - optionCountPlus1 != 3 + imageFlag ) {
      ERROR1i( "Centralizer", "Exactly ", 3+imageFlag,
               " non-option parameters are required.");
      exit(ERROR_RETURN_CODE);
   }

   /* Process options. */
   prefix[0] = '\0';
   suffix[0] = '\0';
   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   options.statistics = FALSE;
   options.inform = TRUE;
   options.compress = TRUE;
   options.maxBaseChangeLevel = UNKNOWN;
   options.maxStrongGens = 70;
   options.idealBasicCellSize = 4;
   options.trimSGenSetToSize = 35;
   options.strongMinDCosetCheck = FALSE;
   options.writeConjPerm = MAX_COSET_REP_PRINT;
   options.restrictedDegree = 0;
   options.alphaHat1 = 0;
   parseLibraryName( argv[optionCountPlus1+2], "", "", outputFileName,
                     outputLibraryName);
   strncpy( options.genNamePrefix, outputLibraryName, 4);
   options.genNamePrefix[4] = '\0';
   strcpy( options.outputFileMode, "w");
   centPartnCount = 10;
   centGenCount = 3;
   longCycleOption = FALSE;
   stdRBaseOption = FALSE;

   /* Note i must still be as above. */
   for ( i = startOptions ; i < optionCountPlus1 ; ++i ) {
      for ( j = 1 ; argv[i][j] != ':' && argv[i][j] != '\0' ; ++j )
#ifdef EBCDIC
         argv[i][j] = ( argv[i][j] >= 'A' && argv[i][j] <= 'I' ||
                        argv[i][j] >= 'J' && argv[i][j] <= 'R' ||
                        argv[i][j] >= 'S' && argv[i][j] <= 'Z' ) ?
                        (argv[i][j] + 'a' - 'A') : argv[i][j];
#else
         argv[i][j] = (argv[i][j] >= 'A' && argv[i][j] <= 'Z') ?
                      (argv[i][j] + 'a' - 'A') : argv[i][j];
#endif
      errno = 0;
      if ( strcmp( argv[i], "-a") == 0 )
         strcpy( options.outputFileMode, "a");
      else if ( strncmp( argv[i], "-a1:", 4) == 0 &&
                (options.alphaHat1 = (Unsigned) strtol(argv[i]+4,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( strncmp( argv[i], "-b:", 3) == 0 &&
                (options.maxBaseChangeLevel = (Unsigned) strtol(argv[i]+3,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( strncmp( argv[i], "-p:", 3) == 0 ) {
         strcpy( prefix, argv[i]+3);
      }
      else if ( strncmp( argv[i], "-t:", 3) == 0 ) {
         strcpy( suffix, argv[i]+3);
      }
      else if ( strncmp( argv[i], "-g:", 3) == 0 &&
                (options.maxStrongGens = (Unsigned) strtol(argv[i]+3,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( strncmp( argv[i], "-gn:", 4) == 0 )
         if ( strlen( argv[i]+4) <= 8 )
            strcpy( options.genNamePrefix, argv[i]+4);
         else
            ERROR( "main (setstab)", "Invalid value for -gn option")
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
      else if ( strncmp( argv[i], "-n:", 3) == 0 )
         if ( isValidName( argv[i]+3) )
            strcpy( outputObjectName, argv[i]+3);
         else
            ERROR1s( "main (setstab)", "Invalid name ", outputObjectName,
                     " for stabilizer group or coset rep.")
      else if ( strcmp( argv[i], "-np") == 0 )
         noPartn = TRUE;
      else if ( strcmp( argv[i], "-q") == 0 )
         options.inform = FALSE;
      else if ( strcmp( argv[i], "-overwrite") == 0 )
         strcpy( options.outputFileMode, "w");
      else if ( strncmp( argv[i], "-r:", 3) == 0 &&
                (options.trimSGenSetToSize = (Unsigned) strtol(argv[i]+3,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( !imageFlag && strncmp( argv[i], "-k:", 3) == 0 )
         strcpy( knownSubgroupSpecifier, argv[i]+3);
      else if ( imageFlag && strncmp( argv[i], "-kl:", 4) == 0 )
         strcpy( knownSubgroup_L_Specifier, argv[i]+4);
      else if ( imageFlag && strncmp( argv[i], "-kr:", 4) == 0 )
         strcpy( knownSubgroup_R_Specifier, argv[i]+4);
      else if ( strcmp( argv[i], "-s") == 0 )
         options.statistics = TRUE;
      else if ( strncmp( argv[i], "-w:", 3) == 0 &&
                (options.writeConjPerm = (Unsigned) strtol(argv[i]+3,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( strncmp( argv[i], "-x:", 3) == 0 &&
                (options.idealBasicCellSize = (Unsigned) strtol(argv[i]+3,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( strcmp( argv[i], "-z") == 0 )
         options.strongMinDCosetCheck = TRUE;
      else if ( strncmp( argv[i], "-cp:", 4) == 0 &&
                (centPartnCount = (Unsigned) strtol(argv[i]+4,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( strncmp( argv[i], "-cg:", 4) == 0 &&
                (centGenCount = (Unsigned) strtol(argv[i]+4,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( strcmp( argv[i], "-lc" ) == 0 )
         longCycleOption = TRUE;
      else if ( strcmp( argv[i], "-srb" ) == 0 )
         stdRBaseOption = TRUE;
      else
         ERROR1s( "main (compute subgroup)", "Invalid option ", argv[i], ".")
   }

   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   /* Compute names for files and name for set stabilizer or coset rep. */
   if ( argv[optionCountPlus1][0] == SYMMETRIC_GROUP_CHAR ) {
      errno = 0;
      symmetricDegree = (Unsigned) strtol(argv[i]+1,&nextChar,0);
      if ( errno != 0 || symmetricDegree < 1 || symmetricDegree > options.maxDegree ||
                         (*nextChar != ' ' && *nextChar != '\0') )
         ERROR( "main (compute subgroup)", "Invalid symmetric group")
   }
   else
      parseLibraryName( argv[optionCountPlus1], prefix, suffix,
                        permGroupFileName, permGroupLibraryName);
   switch( computationType) {
      case ELT_CENTRALIZER:
      case GROUP_CENTRALIZER:
         parseLibraryName( argv[optionCountPlus1+1], prefix, suffix,
                           eltOrGrpFileName, eltOrGrpLibraryName);
         parseLibraryName( argv[optionCountPlus1+2], "", "",
                           outputFileName, outputLibraryName);
         if ( outputObjectName[0] == '\0' )
            strncpy( outputObjectName, outputLibraryName, MAX_NAME_LENGTH+1);
         if ( knownSubgroupSpecifier[0] != '\0' )
            parseLibraryName( knownSubgroupSpecifier, prefix, suffix,
                              knownSubgroupFileName, knownSubgroupLibraryName);
         break;
      case ELT_CONJUGATE:
         parseLibraryName( argv[optionCountPlus1+1], prefix, suffix,
                           element_L_FileName, element_L_LibraryName);
         parseLibraryName( argv[optionCountPlus1+2], prefix, suffix,
                           element_R_FileName, element_R_LibraryName);
         parseLibraryName( argv[optionCountPlus1+3], "", "",
                           outputFileName, outputLibraryName);
         if ( outputObjectName[0] == '\0' )
            strncpy( outputObjectName, outputLibraryName, MAX_NAME_LENGTH+1);
         if ( knownSubgroup_L_Specifier[0] != '\0' )
            parseLibraryName( knownSubgroup_L_Specifier, prefix, suffix,
                              knownSubgroup_L_FileName, knownSubgroup_L_LibraryName);
         if ( knownSubgroup_R_Specifier[0] )
            parseLibraryName( knownSubgroup_R_Specifier, prefix, suffix,
                              knownSubgroup_R_FileName, knownSubgroup_R_LibraryName);
   }

   /* Read in the containing group G. */
   if ( symmetricDegree == 0 )
      G = readPermGroup( permGroupFileName, permGroupLibraryName, 0, "Generate");
   else {
      G = allocPermGroup();
      sprintf( G->name, "%c%d", SYMMETRIC_GROUP_CHAR, symmetricDegree);
      G->degree = symmetricDegree;
      G->baseSize = 0;
   }

   /* Read in the known subgroups, if present. */
   switch ( computationType ) {
      case ELT_CENTRALIZER:
      case GROUP_CENTRALIZER:
         if ( knownSubgroupSpecifier[0] )
            L = readPermGroup( knownSubgroupFileName, knownSubgroupLibraryName,
                               G->degree, "Generate");
         break;
      case ELT_CONJUGATE:
         if ( knownSubgroup_L_Specifier[0] )
            L_L = readPermGroup( knownSubgroup_L_FileName,
                       knownSubgroup_L_LibraryName, G->degree, "Generate");
         if ( knownSubgroup_R_Specifier[0] )
            L_R = readPermGroup( knownSubgroup_R_FileName,
                       knownSubgroup_R_LibraryName, G->degree, "Generate");
         break;
   }

   /* Read in the element to be centralized, the group to be centralized, or
      the elements for which to check conjugacy. */
   switch ( computationType ) {
      case ELT_CENTRALIZER:
         e = readPermutation( eltOrGrpFileName, eltOrGrpLibraryName, G->degree,
                              TRUE);
         break;
      case GROUP_CENTRALIZER:
         E = readPermGroup( eltOrGrpFileName, eltOrGrpLibraryName, G->degree,
                            "Generate");
         break;
      case ELT_CONJUGATE:
         e = readPermutation( element_L_FileName, element_L_LibraryName,
                                G->degree, TRUE);
         f = readPermutation( element_R_FileName, element_R_LibraryName,
                                G->degree, TRUE);
         break;
   }

   /* Compute maximum base change level if not specified as option. */
   if ( options.maxBaseChangeLevel == UNKNOWN )
      options.maxBaseChangeLevel =
         isDoublyTransitive(G) ?
            ( 1 + options.maxBaseSize * depthGreaterThan(G,4) ) :
            ( depthGreaterThan(G,5) + options.maxBaseSize * depthGreaterThan(G,6));

   /* Compute the centralizer or conjugating element and write it out. */
   switch ( computationType ) {
      case ELT_CENTRALIZER:
         if ( options.inform ) {
            printf( "\n\n               Element Centralizer Program:  "
                    "Group %s, Element %s\n\n", G->name, e->name);
            if ( L )
               printf( "\nKnown Subgroup: %s\n", L->name);
         }
         options.groupOrderMessage = "Centralizer";
         G_pP = centralizer( G, e, L, noPartn, longCycleOption,
                             stdRBaseOption);
         strcpy( G_pP->name, outputObjectName);
         G_pP->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
         sprintf( comment,
                 "The centralizer in permutation group %s of permutation %s.",
                 G->name, e->name);
         writePermGroup( outputFileName, outputLibraryName, G_pP, comment);
         break;
      case GROUP_CENTRALIZER:
         if ( options.inform ) {
            printf( "\n\n               Group Centralizer Program:  "
                    "Centralizer in %s of %s\n\n", G->name, E->name);
            if ( L )
               printf( "\nKnown Subgroup: %s\n", L->name);
         }
         options.groupOrderMessage = "Group centralizer";
         G_pP = groupCentralizer( G, E, L, centPartnCount, centGenCount);
         strcpy( G_pP->name, outputObjectName);
         G_pP->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
         sprintf( comment,
                 "The centralizer in permutation group %s of permutation group %s.",
                 G->name, E->name);
         writePermGroup( outputFileName, outputLibraryName, G_pP, comment);
         break;
      case ELT_CONJUGATE:
         if ( options.inform ) {
            printf( "\n\n\n         Element Conjugacy Program:  "
                    "Group %s, Elements %s and %s\n\n", G->name,
                    e->name, f->name);
            if ( L_L )
               printf( "\nKnown Subgroup (left):  %s", L_L->name);
            if ( L_R )
               printf( "\nKnown Subgroup (right): %s", L_R->name);
            if ( L_L || L_R )
               printf( "\n");
         }
         options.cosetRepMessage = 
             "The first permutation is conjugated to the second by group element:";
         options.noCosetRepMessage = 
             "The two permutations are not conjugate under the group.";
         y = conjugatingElement( G, e, f, L_L, L_R, noPartn, longCycleOption,
                                 stdRBaseOption);
         if ( y ) {
            strcpy( y->name, outputObjectName);
            sprintf( comment,
               "A permutation in group %s mapping permutation %s to permutation %s.",
                     G->name, e->name, f->name);
            if ( imageFormatFlag )
               writePermutation( outputFileName, outputLibraryName, y, "image", comment);
            else
               writePermutation( outputFileName, outputLibraryName, y, "", comment);
         }
         break;
   }

   /* Return to caller. */
   if ( !imageFlag || y )
      return 0;
   else
      return 1;
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
   extern void xccent ( CompileOptions *cOpts);
   extern void xchbase( CompileOptions *cOpts);
   extern void xcompcr( CompileOptions *cOpts);
   extern void xcompsg( CompileOptions *cOpts);
   extern void xcopy  ( CompileOptions *cOpts);
   extern void xcstbor( CompileOptions *cOpts);
   extern void xcstrba( CompileOptions *cOpts);
   extern void xerrmes( CompileOptions *cOpts);
   extern void xessent( CompileOptions *cOpts);
   extern void xfactor( CompileOptions *cOpts);
   extern void xinform( CompileOptions *cOpts);
   extern void xnew   ( CompileOptions *cOpts);
   extern void xoldcop( CompileOptions *cOpts);
   extern void xoptsve( CompileOptions *cOpts);
   extern void xorbit ( CompileOptions *cOpts);
   extern void xorbref( CompileOptions *cOpts);
   extern void xpartn ( CompileOptions *cOpts);
   extern void xpermgr( CompileOptions *cOpts);
   extern void xpermut( CompileOptions *cOpts);
   extern void xprimes( CompileOptions *cOpts);
   extern void xptstbr( CompileOptions *cOpts);
   extern void xrandgr( CompileOptions *cOpts);
   extern void xrandsc( CompileOptions *cOpts);
   extern void xreadgr( CompileOptions *cOpts);
   extern void xreadpe( CompileOptions *cOpts);
   extern void xrpriqu( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);

   xaddsge( &mainOpts);
   xbitman( &mainOpts);
   xccent ( &mainOpts);
   xchbase( &mainOpts);
   xcompcr( &mainOpts);
   xcompsg( &mainOpts);
   xcopy  ( &mainOpts);
   xcstbor( &mainOpts);
   xcstrba( &mainOpts);
   xerrmes( &mainOpts);
   xessent( &mainOpts);
   xfactor( &mainOpts);
   xinform( &mainOpts);
   xnew   ( &mainOpts);
   xoldcop( &mainOpts);
   xoptsve( &mainOpts);
   xorbit ( &mainOpts);
   xorbref( &mainOpts);
   xpartn ( &mainOpts);
   xpermgr( &mainOpts);
   xpermut( &mainOpts);
   xprimes( &mainOpts);
   xptstbr( &mainOpts);
   xrandgr( &mainOpts);
   xrandsc( &mainOpts);
   xreadgr( &mainOpts);
   xreadpe( &mainOpts);
   xrpriqu( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}
