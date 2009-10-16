/* File compgrp.c.  Contains main program for command compgrp, which can be
   used to compare two groups.  The command format is

      compgrp  <options>  <group1>  <group2>

   where <group1> and <group2> are the permutation groups to be compared.
   The command prints one of the following messages:

      i)   <group1> and <group2> are equal.
      ii)  <group1> is properly contained in <group2>.
      iii) <group2> is properly contained in <group1>.
      iv)  Neither of <group1> or <group2> is contained in the other.

   The return value is 0, 1, 2, or 3 depending on whether (i), (ii), (iii),
   or (iv) above hold, respectively.  If an error occurs, the return code
   is 4.

   The only options are -c and -n (and the special options -l and -v, which
   have their standard meaning).  If -c is specified, the program checks
   whether the two groups centralize each other.  If -n is specified, it
   checks whether either group normalizes the other.
*/

#include <errno.h>
#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAIN

#include "group.h"
#include "groupio.h"

#include "errmesg.h"
#include "permgrp.h"
#include "permut.h"
#include "readgrp.h"
#include "readpar.h"
#include "readper.h"
#include "readpts.h"
#include "util.h"

/* Nonstandard error return code. */
#undef ERROR_RETURN_CODE
#define ERROR_RETURN_CODE 4

static int comparePerm(
   const Permutation *const perm1,
   const Permutation *const perm2);
static int comparePointSet(
   const PointSet *const set1,
   const PointSet *const set2);
static int comparePartition(
   const Partition *const partn1,
   const Partition *const partn2);
static void verifyOptions(void);

GroupOptions options;


int main( int argc, char *argv[])
{
   char group1FileName[MAX_FILE_NAME_LENGTH] = "",
        group2FileName[MAX_FILE_NAME_LENGTH] = "",
        group1LibraryName[MAX_NAME_LENGTH] = "",
        group2LibraryName[MAX_NAME_LENGTH] = "",
        prefix[MAX_FILE_NAME_LENGTH] = "",
        suffix[MAX_NAME_LENGTH] = "";
   PermGroup *group1, *group2 = NULL;
   Permutation *perm1, *perm2 = NULL;
   Partition *partn1, *partn2 = NULL;
   PointSet *set1, *set2 = NULL;
   Unsigned optionCountPlus1, i, j;
   Unsigned normalizeFlag = FALSE, centralizeFlag = FALSE,
            skipNormalize = FALSE, returnCode, degree;
   BOOLEAN comparePermFlag = FALSE, comparePointSetFlag = FALSE,
           comparePartitionFlag = FALSE;

   /* If there are no options, provide usage information and exit. */
   if ( argc == 1 ) {
      printf( "\nUsage:  compgrp [-n] [-c] permGroup1 [permGroup2]\n");
      return 0;
   }
   if ( argc == 2 && strncmp( argv[1], "-perm:", 6) == 0 ) {
      printf( "\nUsage:  compper degree permutation1 [permutation2]\n");
      return 0;
   }
   if ( argc == 2 && strncmp( argv[1], "-set:", 5) == 0 ) {
      printf( "\nUsage:  compset degree set1 [set2]\n");
      return 0;
   }
   if ( argc == 2 && strncmp( argv[1], "-partition:", 11 ) == 0 ) {
      printf( "\nUsage:  comppar degree partition1 [partition2]\n");
      return 0;
   }

   /* Count the number of options. */
   for ( optionCountPlus1 = 1 ; optionCountPlus1 <= argc-1 &&
              argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
      ;

   /* Translate options to lower case. */
   for ( i = 1 ; i < optionCountPlus1 ; ++i ) {
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
   }

   /* Check for limits option.  If present in position 1, give limits and
      return. */
   if ( strcmp( argv[1], "-l") == 0 || strcmp( argv[1], "-L") == 0 ) {
      showLimits();
      return 0;
   }
   /* Check for verify option.  If present in position i (i as above) perform
      verify (Note verifyOptions terminates program). */
   if ( strcmp( argv[1], "-v") == 0 || strcmp( argv[1], "-V") == 0 )
      verifyOptions();

   /* Check for at most 2 parameters following options. */
   if ( argc - optionCountPlus1 > 2 )
      ERROR( "Compgrp", "Exactly 2 non-option parameters are required.")

   /* Process options. */
   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   options.inform = TRUE;
   for ( i = 1 ; i < optionCountPlus1 ; ++i )
      if ( strcmp(argv[i],"-c") == 0 )
         centralizeFlag = TRUE;
      else if ( strcmp(argv[i],"-n") == 0 )
         normalizeFlag = TRUE;
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
      else if ( strncmp( argv[i], "-p:", 3) == 0 ) {
         strcpy( prefix, argv[i]+3);
      }
      else if ( strcmp( argv[i], "-q") == 0 )
         options.inform = FALSE;
      else if ( strncmp( argv[i], "-t:", 3) == 0 ) {
         strcpy( suffix, argv[i]+3);
      }
      else if ( strncmp( argv[i], "-perm:", 6) == 0 ) {
         errno = 0;
         degree = (Unsigned) strtol(argv[i]+6,NULL,0);
         comparePermFlag = TRUE;
         if ( errno )
            ERROR( "main (compgrp)", "Invalid syntax for -perm option")
      }
      else if ( strncmp( argv[i], "-set:", 5) == 0 ) {
         errno = 0;
         degree = (Unsigned) strtol(argv[i]+5,NULL,0);
         comparePointSetFlag = TRUE;
         if ( errno )
            ERROR( "main (compgrp)", "Invalid syntax for -set option")
      }
      else if ( strncmp( argv[i], "-partition:", 11) == 0 ) {
         errno = 0;
         degree = (Unsigned) strtol(argv[i]+11,NULL,0);
         comparePartitionFlag = TRUE;
         if ( errno )
            ERROR( "main (compgrp)", "Invalid syntax for -partition option")
      }
      else
         ERROR1s( "main (compgrp command)", "Invalid option ", argv[i], ".")


   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   /* Compute file and library names. */
   parseLibraryName( argv[optionCountPlus1], prefix, suffix,
                     group1FileName, group1LibraryName);
   parseLibraryName( argv[optionCountPlus1+1], prefix, suffix,
                     group2FileName, group2LibraryName);

   /* Read in groups.  For types other than permutation groups, call special
      function to perform comparison. */
   if ( comparePermFlag ) {
      perm1 = readPermutation( group1FileName, group1LibraryName, degree, FALSE);
      if ( argc > optionCountPlus1+1 )
         perm2 = readPermutation( group2FileName, group2LibraryName, degree, FALSE);
      return comparePerm( perm1, perm2);
   }
   else if ( comparePointSetFlag ) {
      set1 = readPointSet( group1FileName, group1LibraryName, degree);
      if ( argc > optionCountPlus1+1 )
         set2 = readPointSet( group2FileName, group2LibraryName, degree);
      return comparePointSet( set1, set2);
   }
   else if ( comparePartitionFlag) {
      partn1 = readPartition( group1FileName, group1LibraryName, degree);
      if ( argc > optionCountPlus1+1 )
         partn2 = readPartition( group2FileName, group2LibraryName, degree);
      return comparePartition( partn1, partn2);
   }
   else {
      group1 = readPermGroup( group1FileName, group1LibraryName, 0, "Generate");
      if ( argc > optionCountPlus1+1 )
         group2 = readPermGroup( group2FileName, group2LibraryName, group1->degree,
                                                              "Generate");
   }

   /* If second group is omitted, check if first group is the identity. */
   if ( !group2 )
      if ( group1->order->noOfFactors == 0 ) {
         if ( options.inform )
            printf( "\n  %s is the identity.\n", group1->name);
         return 0;
      }
      else {
         if ( options.inform )
            printf( "\n  %s is not the identity.\n", group1->name);
         return 1;
      }

   /* Check containment. */
   if ( isSubgroupOf(group1,group2) )
      if ( isSubgroupOf(group2,group1) ) {
         if ( options.inform )
            printf( "\n  %s and %s are equal.\n", group1->name, group2->name);
         if ( centralizeFlag )
            if ( isCentralizedBy(group1,group2) ) {
               printf( "  %s and %s centralize each other.\n",
                       group1->name, group2->name);
               skipNormalize = TRUE;
            }
            else
               printf( "  %s and %s do not centralize each other.\n",
                       group1->name, group2->name);
         returnCode = 0;
      }
      else {
         if ( options.inform )
            printf( "\n  %s is properly contained in %s.\n", group1->name,
                                                        group2->name);
         if ( centralizeFlag )
            if ( isCentralizedBy(group1,group2) ) {
               printf( "  %s and %s centralize each other.\n",
                       group1->name, group2->name);
               skipNormalize = TRUE;
            }
            else
               printf( "  %s and %s do not centralize each other.\n",
                       group1->name, group2->name);
         if ( normalizeFlag && !skipNormalize )
            if ( isNormalizedBy(group1,group2) )
               printf( "  %s is normal in %s.\n", group1->name,
                                                    group2->name);
            else
               printf( "  %s is not normal in %s.\n", group1->name,
                                                    group2->name);
         returnCode = 1;
      }
   else
      if ( isSubgroupOf(group2,group1) ) {
         if ( options.inform )
            printf( "\n  %s is properly contained in %s.\n", group2->name,
                                                        group1->name);
         if ( centralizeFlag )
            if ( isCentralizedBy(group1,group2) ) {
               printf( "  %s and %s centralize each other.\n",
                       group1->name, group2->name);
               skipNormalize = TRUE;
            }
            else
               printf( "  %s and %s do not centralize each other.\n",
                       group1->name, group2->name);
         if ( normalizeFlag && !skipNormalize )
            if ( isNormalizedBy( group2, group1) )
               printf( "  %s is normal in %s.\n", group2->name,
                                                    group1->name);
            else
               printf( "  %s is not normal in %s.\n", group2->name,
                                                    group1->name);
         returnCode = 2;
      }
      else {
         if ( options.inform )    
            printf( "\n  Neither of %s or %s is contained in the other.\n",
                                          group1->name, group2->name);
         if ( centralizeFlag )
            if ( isCentralizedBy(group1,group2) ) {
               printf( "  %s and %s centralize each other.\n",
                       group1->name, group2->name);
               skipNormalize = TRUE;
            }
            else
               printf( "  %s and %s do not centralize each other.\n",
                       group1->name, group2->name);
         if ( normalizeFlag && !skipNormalize ) {
            if ( isNormalizedBy( group1, group2) )
               printf( "  %s is normalized by %s.\n", group1->name,
                                                    group2->name);
            else
               printf( "  %s is not normalized by %s.\n", group1->name,
                                                    group2->name);
            if ( isNormalizedBy( group2, group1) )
               printf( "  %s is normalized by %s.\n", group2->name,
                                                    group1->name);
            else
               printf( "  %s is not normalized by %s.\n", group2->name,
                                                    group1->name);
         }
         returnCode = 3;
      }

   return returnCode;
}



/*-------------------------- comparePerm ---------------------------------*/

static int comparePerm(
   const Permutation *const perm1,
   const Permutation *const perm2)
{
   Unsigned pt;

   if ( perm2 ) {
      for ( pt = 1 ; pt <= perm1->degree ; ++pt )
         if ( perm1->image[pt] != perm2->image[pt] ) {
            if ( options.inform )
               printf( "\n  %s and %s are not equal.\n", perm1->name,
                       perm2->name);
            return 1;
         }
      if ( options.inform )
         printf( "\n  %s and %s are equal.\n", perm1->name, perm2->name);
      return 0;
   }
   else {
      for ( pt = 1 ; pt <= perm1->degree ; ++pt )
         if ( perm1->image[pt] != pt ) {
            if ( options.inform )
               printf( "\n  %s is not the identity.\n", perm1->name);
            return 1;
         }
      if ( options.inform )
         printf( "\n  %s is the identity.\n", perm1->name);
      return 0;
   }
}




/*-------------------------- comparePointSet -------------------------------*/

static int comparePointSet(
   const PointSet *const set1,
   const PointSet *const set2)
{
   Unsigned i;
   BOOLEAN set1InSet2 = TRUE, set2InSet1 = TRUE;

   if ( set2 ) {
      for ( i = 1 ; i <= set1->size ; ++i )
         if ( !set2->inSet[set1->pointList[i]] ) {
            set1InSet2 = FALSE;
            break;
         }
      for ( i = 1 ; i <= set2->size ; ++i )
         if ( !set1->inSet[set2->pointList[i]] ) {
            set2InSet1 = FALSE;
            break;
         }
      if ( set1InSet2 && set2InSet1 ) {
         if ( options.inform )
            printf( "\n  Sets %s and %s are equal.\n", set1->name, set2->name);
         return 0;
      }
      else if ( set1InSet2 ) {
         if ( options.inform )
            printf( "\n  Set %s is properly contained in set %s.\n", set1->name, 
                    set2->name);
         return 1;
      }
      else if ( set2InSet1 ) {
         if ( options.inform )
            printf( "\n  Set %s is properly contained in set %s.\n", set2->name, 
                    set1->name);
         return 2;
      }
      else {
         if ( options.inform )
            printf( "\n  Neither set %s or set %s is contained in the other.\n", 
                    set1->name, set2->name);
         return 3;
      }
   }
   else {
      if ( set1->size == 0 ) {
         if ( options.inform ) 
            printf( "\n  %s is empty.\n", set1->name);
         return 0;
      }
      else {
         if ( options.inform ) 
            printf( "\n  %s is not empty.\n", set1->name);
         return 1;
      }
   }
}


/*-------------------------- comparePartition ----------------------------*/

static int comparePartition(
   const Partition *const partn1,
   const Partition *const partn2)
{
   ERROR( "comparePartition", "Comparison of partitions not yet implemented")
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
   extern void xcopy  ( CompileOptions *cOpts);
   extern void xcstbor( CompileOptions *cOpts);
   extern void xerrmes( CompileOptions *cOpts);
   extern void xessent( CompileOptions *cOpts);
   extern void xfactor( CompileOptions *cOpts);
   extern void xnew   ( CompileOptions *cOpts);
   extern void xoldcop( CompileOptions *cOpts);
   extern void xpermgr( CompileOptions *cOpts);
   extern void xpermut( CompileOptions *cOpts);
   extern void xprimes( CompileOptions *cOpts);
   extern void xrandgr( CompileOptions *cOpts);
   extern void xrandsc( CompileOptions *cOpts);
   extern void xreadgr( CompileOptions *cOpts);
   extern void xreadpe( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);

   xaddsge( &mainOpts);
   xbitman( &mainOpts);
   xcopy  ( &mainOpts);
   xcstbor( &mainOpts);
   xerrmes( &mainOpts);
   xessent( &mainOpts);
   xfactor( &mainOpts);
   xnew   ( &mainOpts);
   xoldcop( &mainOpts);
   xpermgr( &mainOpts);
   xpermut( &mainOpts);
   xprimes( &mainOpts);
   xrandgr( &mainOpts);
   xrandsc( &mainOpts);
   xreadgr( &mainOpts);
   xreadpe( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}
