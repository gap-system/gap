/* File setstab.c. */

/* Copyright (C) 1992 by Jeffrey S. Leon.  This software may be used freely
   for educational and research purposes.  Any other use requires permission
   from the author. */

/* Main program for set stabilizer command, which may be used
   compute the stabilizer G_Lambda in a permutation group G of a point set
   Lmabda.  The format of the command is:

      setstab <options> <permGroup> <pointSet> <stabGroup>

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
                  omitted, the new generators are named xxxx01, xxxx02, etc.,
                  where xxxx are the first four characters of the group name.

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
      15: computation terminated due to error.
   The return code for set or partition image computations is as follows:
      0: computation successful; sets or partitions are equivalent,
      1: computation successful; sets or partitions are not equivalent,
      15: computation terminated due to error.
*/


#include <stddef.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#define MAIN

#include "group.h"
#include "groupio.h"

#include "cparstab.h"
#include "csetstab.h"
#include "cuprstab.h"
#include "errmesg.h"
#include "permgrp.h"
#include "readgrp.h"
#include "readpar.h"
#include "readper.h"
#include "readpts.h"
#include "token.h"
#include "util.h"


GroupOptions options;

static void verifyOptions(void);

UnsignedS (*chooseNextBasePoint)(
   const PermGroup *const G,
   const PartitionStack *const UpsilonStack) = NULL;


int main( int argc, char *argv[])
{
   char permGroupFileName[MAX_FILE_NAME_LENGTH] = "",
        pointSetFileName[MAX_FILE_NAME_LENGTH] = "",
        *pointSet_L_FileName = pointSetFileName,
        pointSet_R_FileName[MAX_FILE_NAME_LENGTH] = "",
        *partitionFileName = pointSetFileName,
        *partition_L_FileName = pointSet_L_FileName,
        *partition_R_FileName = pointSet_R_FileName,
        knownSubgroupSpecifier[MAX_FILE_NAME_LENGTH] = "",
        *knownSubgroup_L_Specifier = knownSubgroupSpecifier,
        knownSubgroup_R_Specifier[MAX_FILE_NAME_LENGTH] = "",
        knownSubgroupFileName[MAX_FILE_NAME_LENGTH] = "",
        *knownSubgroup_L_FileName = knownSubgroupFileName,
        knownSubgroup_R_FileName[MAX_FILE_NAME_LENGTH] = "",
        outputFileName[MAX_FILE_NAME_LENGTH] = "";
   Unsigned i, j, optionCountPlus1;
   char outputObjectName[MAX_NAME_LENGTH+1] = "",
        outputLibraryName[MAX_NAME_LENGTH+1] = "",
        permGroupLibraryName[MAX_NAME_LENGTH+1] = "",
        pointSetLibraryName[MAX_NAME_LENGTH+1] = "",
        *partitionLibraryName = pointSetLibraryName,
        knownSubgroupLibraryName[MAX_NAME_LENGTH+1] = "",
        *pointSet_L_LibraryName = pointSetLibraryName,
        pointSet_R_LibraryName[MAX_NAME_LENGTH+1] = "",
        *partition_L_LibraryName = pointSet_L_LibraryName,
        *partition_R_LibraryName = pointSet_R_LibraryName,
        *knownSubgroup_L_LibraryName = knownSubgroupLibraryName,
        knownSubgroup_R_LibraryName[MAX_NAME_LENGTH+1] = "",
        prefix[MAX_FILE_NAME_LENGTH],
        suffix[MAX_NAME_LENGTH];
   PermGroup *G, *G_pP, *L = NULL, *L_L = NULL, *L_R = NULL;
   Permutation *y;
   PointSet *Lambda, *Xi;
   Partition *PLambda, *PXi;
   BOOLEAN imageFlag = FALSE, imageFormatFlag = FALSE;
   char ordUnord[] = "Ordered";
   char tempArg[8];
   enum { SET_STAB, SET_IMAGE, PARTN_STAB, PARTN_IMAGE,
          UPARTN_STAB, UPARTN_IMAGE} computationType = SET_STAB;
   char comment[100];

   /* Check whether the first parameter is Image or (U)Partn, and if so whether
      the second parameter is Image or (U)Partn.  If so, a set image, partition
      stabilizer, or partition image computation will be performed instead of
      a set stabilizer one, and the valid remaining parameters will be
      different. */

   j = 0;
   for ( i = 1 ; i <= 2 && i < argc ; ++i ) {
      strncpy( tempArg, argv[i], 8);
      tempArg[7] = '\0';
      lowerCase( tempArg);
      if ( strcmp( tempArg, "-image") == 0 )
         j |= 4;
      else if ( strcmp( tempArg, "-upartn") == 0 )
         j |= 2;
      else if ( strcmp( tempArg, "-partn") == 0 )
         j |= 1;
      else
         break;
   }
   switch( j ) {
      case 0:  computationType = SET_STAB;  break;
      case 1:  computationType = PARTN_STAB;  break;
      case 2:  computationType = UPARTN_STAB;
                  strcpy( ordUnord, "Unordered"); break;
      case 4:  computationType = SET_IMAGE;  imageFlag = TRUE;  break;
      case 5:  computationType = PARTN_IMAGE;  imageFlag = TRUE;  break;
      case 6:  computationType = UPARTN_IMAGE;  imageFlag = TRUE;
                  strcpy( ordUnord, "Unordered"); break;
      default: ERROR( "main (setstab)", "Invalid options"); break;
   }

   /* Provide help if no arguments are specified. Note i and j must be as
      described above. */
   if ( i == argc ) {
      switch( j ) {
         case 0:  printf( "\nUsage:  setstab [options] permGroup pointSet stabilizerSubgroup\n");
                  break;
         case 1:  printf( "\nUsage:  parstab [options] permGroup ordPartition stabilizerSubgroup\n");
                  break;
         case 2:  printf( "\nUsage:  uprstab [options] permGroup unOrdPartition stabilizerSubgroup\n");
                  break;
         case 4:  printf( "\nUsage:  setimage [options] permGroup pointSet1 pointSet2 groupElement\n");
                  break;
         case 5:  printf( "\nUsage:  parimage [options] permGroup ordPartition1 ordPartition2 groupElement\n");
                  break;
         case 6:  printf( "\nUsage:  uprimage [options] permGroup unOrdPartition1 unOrdPartition2 groupElement\n");
                  break;
      }
      return 0;
   }

   /* Check for limits option.  If present in position i (i as above) give
      limits and return. */
   if ( i < argc && (strcmp(argv[i], "-l") == 0 || strcmp(argv[i], "-L") == 0) ) {
      showLimits();
      return 0;
   }
   /* Check for verify option.  If present in position i (i as above) perform
      verify (Note verifyOptions terminates program). */
   if ( i < argc && (strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "-V") == 0) )
      verifyOptions();
   if ( argc < 4 )
      ERROR( "main (setstab)", "Too few parameters.")

   /* Check for exactly 3 (set or partn stabilizer) or 4 (set or partn image) parameters
      following options.  Note i must be as above. */
   for ( optionCountPlus1 = i ; optionCountPlus1 < argc &&
              argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
      ;

   if ( argc - optionCountPlus1 != 3 + imageFlag ) {
      ERROR1i( "setStabilizer", "Exactly ", 3+imageFlag,
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

   /* Note i must still be as above. */
   for ( ; i < optionCountPlus1 ; ++i ) {
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
            ERROR( "main (setstab)", "Invalid syntax for -mb option")
      }
      else if ( strncmp( argv[i], "-mw:", 4) == 0 ) {
         errno = 0;
         options.maxWordLength = (Unsigned) strtol(argv[i]+4,NULL,0);
         if ( errno )
            ERROR( "main (setstab)", "Invalid syntax for -mw option")
      }
      else if ( strncmp( argv[i], "-n:", 3) == 0 )
         if ( isValidName( argv[i]+3) )
            strcpy( outputObjectName, argv[i]+3);
         else
            ERROR1s( "main (setstab)", "Invalid name ", outputObjectName,
                     " for stabilizer group or coset rep.")
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
      else
         ERROR1s( "main (compute subgroup)", "Invalid option ", argv[i], ".")
   }

   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   /* Compute names for files and name for set stabilizer or coset rep. */
   parseLibraryName( argv[optionCountPlus1], prefix, suffix, permGroupFileName,
                     permGroupLibraryName);
   switch( computationType) {
      case SET_STAB:
      case PARTN_STAB:
      case UPARTN_STAB:
         parseLibraryName( argv[optionCountPlus1+1], prefix, suffix,
                           pointSetFileName, pointSetLibraryName);
         parseLibraryName( argv[optionCountPlus1+2], "", "",
                           outputFileName, outputLibraryName);
         if ( outputObjectName[0] == '\0' )
            strncpy( outputObjectName, outputLibraryName, MAX_NAME_LENGTH+1);
         if ( knownSubgroupSpecifier[0] != '\0' )
            parseLibraryName( knownSubgroupSpecifier, prefix, suffix,
                              knownSubgroupFileName, knownSubgroupLibraryName);
         break;
      case SET_IMAGE:
      case PARTN_IMAGE:
      case UPARTN_IMAGE:
         parseLibraryName( argv[optionCountPlus1+1], prefix, suffix,
                           pointSet_L_FileName, pointSet_L_LibraryName);
         parseLibraryName( argv[optionCountPlus1+2], prefix, suffix,
                           pointSet_R_FileName, pointSet_R_LibraryName);
         parseLibraryName( argv[optionCountPlus1+3], "", "",
                           outputFileName, outputLibraryName);
         if ( outputObjectName[0] == '\0' )
            strncpy( outputObjectName, outputLibraryName, MAX_NAME_LENGTH+1);
         if ( knownSubgroup_L_Specifier[0] )
            parseLibraryName( knownSubgroup_L_Specifier, prefix, suffix,
                              knownSubgroup_L_FileName, knownSubgroup_L_LibraryName);
         if ( knownSubgroup_R_Specifier[0] )
            parseLibraryName( knownSubgroup_R_Specifier, prefix, suffix,
                              knownSubgroup_R_FileName, knownSubgroup_R_LibraryName);
   }

   /* Read in the containing group G. */
   G = readPermGroup( permGroupFileName, permGroupLibraryName, 0, "Generate");

   /* Read in the known subgroups, if present. */
   switch ( computationType ) {
      case SET_STAB:
      case PARTN_STAB:
      case UPARTN_STAB:
         if ( knownSubgroupSpecifier[0] )
            L = readPermGroup( knownSubgroupFileName, knownSubgroupLibraryName,
                               G->degree, "Generate");
         break;
      case SET_IMAGE:
      case PARTN_IMAGE:
      case UPARTN_IMAGE:
         if ( knownSubgroup_L_Specifier[0] ) 
            L_L = readPermGroup( knownSubgroup_L_FileName,
                       knownSubgroup_L_LibraryName, G->degree, "Generate");
         if ( knownSubgroup_R_Specifier[0] ) 
            L_R = readPermGroup( knownSubgroup_R_FileName,
                       knownSubgroup_R_LibraryName, G->degree, "Generate");
         break;
   }

   /* Read in the point set(s) or partition(s). */
   switch ( computationType ) {
      case SET_STAB:
         Lambda = readPointSet( pointSetFileName, pointSetLibraryName,
                                G->degree);
         break;
      case SET_IMAGE:
         Lambda = readPointSet( pointSet_L_FileName, pointSet_L_LibraryName,
                                G->degree);
         Xi     = readPointSet( pointSet_R_FileName, pointSet_R_LibraryName,
                                G->degree);
         break;
      case PARTN_STAB:
      case UPARTN_STAB:
         PLambda = readPartition( partitionFileName, partitionLibraryName,
                                 G->degree);
         break;
      case PARTN_IMAGE:
      case UPARTN_IMAGE:
         PLambda = readPartition( partition_L_FileName, partition_L_LibraryName,
                                 G->degree);
         PXi     = readPartition( partition_R_FileName, partition_R_LibraryName,
                                 G->degree);
         break;
   }

   /* Compute maximum base change level if not specified as option. */
   if ( options.maxBaseChangeLevel == UNKNOWN )
      options.maxBaseChangeLevel =
         isDoublyTransitive(G) ?
            ( 1 + options.maxBaseSize * depthGreaterThan(G,4) ) :
            ( depthGreaterThan(G,5) + options.maxBaseSize * depthGreaterThan(G,6));

   /* Compute the set or partition stabilizer or coset rep and write it out. */
   switch ( computationType ) {
      case SET_STAB:
         if ( options.inform ) {
            printf( "\n\n               Set Stabilizer Program:  "
                    "Group %s, Point Set %s\n\n", G->name, Lambda->name);
            if ( L )
               printf( "\nKnown Subgroup: %s\n", L->name);
         }
         options.groupOrderMessage = "Set stabilizer";
         G_pP = setStabilizer( G, Lambda, L);
         strcpy( G_pP->name, outputObjectName);
         G_pP->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
         sprintf( comment,
                 "The stabilizer in permutation group %s of point set %s.",
                 G->name, Lambda->name);
         writePermGroup( outputFileName, outputLibraryName, G_pP, comment);
         break;
      case PARTN_STAB:
      case UPARTN_STAB:
         if ( options.inform ) {
            printf( "\n\n        %s Partition Stabilizer Program:  "
                    "Group %s, Partition %s\n\n", ordUnord, G->name,
                    PLambda->name);
            if ( L )
               printf( "\nKnown Subgroup: %s\n", L->name);
         }
         switch( computationType ) {
            case PARTN_STAB:
            options.groupOrderMessage = 
                     "Ordered partition stabilizer";
               G_pP = partnStabilizer( G, PLambda, L);
               sprintf( comment,
                    "The stabilizer in permutation group %s of ordered partition %s.",
                    G->name, PLambda->name);
               break;
            case UPARTN_STAB:
            options.groupOrderMessage = 
                     "Unordered partition stabilizer";
               G_pP = uPartnStabilizer( G, PLambda, L);
               sprintf( comment,
                    "The stabilizer in permutation group %s of unordered partition %s.",
                    G->name, PLambda->name);
               break;
         }
         strcpy( G_pP->name, outputObjectName);
         G_pP->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
         writePermGroup( outputFileName, outputLibraryName, G_pP, comment);
         break;
      case SET_IMAGE:
         if ( options.inform ) {
            printf( "\n\n\n           Set Image Program:  "
                    "Group %s, Point Sets %s And %s\n\n", G->name,
                    Lambda->name, Xi->name);
            if ( L_L )
               printf( "\nKnown Subgroup (left):  %s", L_L->name);
            if ( L_R )
               printf( "\nKnown Subgroup (right): %s", L_R->name);
            if ( L_L || L_R )
               printf( "\n");
         }
         options.cosetRepMessage = 
            "The first set is mapped to the second by group element:";
         options.noCosetRepMessage = "The sets are not equivalent under the group.";
         y = setImage( G, Lambda, Xi, L_L, L_R);
         if ( y ) {
            strcpy( y->name, outputObjectName);
            sprintf( comment,
               "A permutation in group %s mapping point set %s to point set %s.",
                     G->name, Lambda->name, Xi->name);
            if ( imageFormatFlag )
               writePermutation( outputFileName, outputLibraryName, y, "image", comment);
            else
               writePermutation( outputFileName, outputLibraryName, y, "", comment);
         }
         break;
      case PARTN_IMAGE:
      case UPARTN_IMAGE:
         if ( options.inform ) {
            printf( "\n\n\n      %s Partition Image Program:  "
                    "Group %s, Partitions %s And %s\n\n", ordUnord, G->name,
                    PLambda->name, PXi->name);
            if ( L_L )
               printf( "\nKnown Subgroup (left):  %s", L_L->name);
            if ( L_R )
               printf( "\nKnown Subgroup (right): %s", L_R->name);
            if ( L_L || L_R )
               printf( "\n");
         }
         switch( computationType ) {
            case PARTN_IMAGE:
               options.cosetRepMessage = 
                   "The first ordered partition is mapped to the second by group element:";
               options.noCosetRepMessage = 
                   "The ordered partitions are not equivalent under the group.";
               y = partnImage( G, PLambda, PXi, L_L, L_R);
            sprintf( comment,
               "A permutation in group %s mapping ordered partition %s to ordered partition %s.",
                     G->name, PLambda->name, PXi->name);
               break;
            case UPARTN_IMAGE:
               options.cosetRepMessage = 
                   "The first unordered partition is mapped to the second by group element:";
               options.noCosetRepMessage = 
                   "The unordered partitions are not equivalent under the group.";
               y = uPartnImage( G, PLambda, PXi, L_L, L_R);
            sprintf( comment,
               "A permutation in group %s mapping unordered partition %s to unordered partition %s.",
                     G->name, PLambda->name, PXi->name);
               break;
         }
         if ( y ) {
            strcpy( y->name, outputObjectName);
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
   extern void xchbase( CompileOptions *cOpts);
   extern void xcompcr( CompileOptions *cOpts);
   extern void xcompsg( CompileOptions *cOpts);
   extern void xcopy  ( CompileOptions *cOpts);
   extern void xcparst( CompileOptions *cOpts);
   extern void xcsetst( CompileOptions *cOpts);
   extern void xcstbor( CompileOptions *cOpts);
   extern void xcstrba( CompileOptions *cOpts);
   extern void xcuprst( CompileOptions *cOpts);
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
   extern void xreadpa( CompileOptions *cOpts);
   extern void xreadpe( CompileOptions *cOpts);
   extern void xreadpt( CompileOptions *cOpts);
   extern void xrpriqu( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);

   xaddsge( &mainOpts);
   xbitman( &mainOpts);
   xchbase( &mainOpts);
   xcompcr( &mainOpts);
   xcompsg( &mainOpts);
   xcopy  ( &mainOpts);
   xcparst( &mainOpts);
   xcsetst( &mainOpts);
   xcstbor( &mainOpts);
   xcstrba( &mainOpts);
   xcuprst( &mainOpts);
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
   xreadpa( &mainOpts);
   xreadpe( &mainOpts);
   xreadpt( &mainOpts);
   xrpriqu( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}
