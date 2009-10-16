/* File randobj.c.  Main program for randobj command, which may be used
   to construct a random point set of specified degree and size, or a random
   partition with specified cell sizes.    The format of
   the command is:

      randobj <options> set <name> <degree> <size>
      randobj <options> set <name> <degree>

   where the meaning of the parameters is as follows:

      <name>:      the name for the point set constructed,
      <degree>:    the degree for the point set (i.e, the point set will be a
                   subset of {1,...,degree}),
      <size>:      the number of points in the point set.

   The valid options are follows:
      -s:<integer>    Sets seed for random number generator to <integer>,
      -cl:<libName>   Append the point set in Cayley library format to library
                      libName.  */

#include <stddef.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAIN

#include "group.h"
#include "groupio.h"

#include "errmesg.h"
#include "randgrp.h"
#include "readpar.h"
#include "readpts.h"
#include "storage.h"
#include "token.h"
#include "util.h"


GroupOptions options;

static void verifyOptions(void);


int main(
   int argc,
   char *argv[])
{
   BOOLEAN equalSizeFlag;
   char outputFileName[MAX_FILE_NAME_LENGTH+1] = "";
   char outputLibraryName[MAX_NAME_LENGTH+1] = "";
   char outputObjectName[MAX_NAME_LENGTH+1] = "";
   Unsigned i, j, degree, setSize, equalCellSize, temp, optionCountPlus1,
            cellSizeSum, numberOfEqualCells, extraPoints;
   Unsigned designatedCellSize[102];
   UnsignedS *randOrder;
   unsigned long seed;
   PointSet *lambda;
   Partition *pi;
   char comment[255], tempstr[25];
   char *currentPos, *nextPos;
   ObjectType objectType;

   /* If there are no options, provide usage information and exit. */
   if ( argc == 1 ) {
      printf( "\nUsage:  randobj [-e] type degree size object\n");
      return 0;
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

   /* Count the number of options. */
   for ( optionCountPlus1 = 1 ; optionCountPlus1 <= argc-1 &&
              argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
      ;

   /* Check for exactly 4 parameters following options.  */
   if ( argc - optionCountPlus1 != 4 )
      ERROR( "main (randobj)", "Exactly 4 non-option parameters are required.")

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


   /* Process options. */
   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   strcpy( options.outputFileMode, "w");
   equalSizeFlag = FALSE;
   seed = 47;
   for ( i = 1 ; i < optionCountPlus1 ; ++i )
      if ( strcmp(argv[i],"-a") == 0 )
         strcmp( options.outputFileMode, "a");
      else if ( strcmp(argv[i],"-e") == 0 )
         equalSizeFlag = TRUE;
      else if ( strncmp( argv[i], "-n:", 3) == 0 )
         if ( isValidName( argv[i]+3) )
            strcpy( outputObjectName, argv[i]+3);
         else
            ERROR1s( "main (randobj)", "Invalid name ", outputObjectName,
                     " for random set or partition.")
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
      else if ( strncmp(argv[i],"-s:",3) == 0 ) {
         errno = 0;
         seed = strtol( argv[i]+3, NULL, 0);
         if ( errno )
            ERROR1s( "main (randobj command)", "Invalid option ", argv[i], ".")
      }
      else
         ERROR1s( "main (randobj command)", "Invalid option ", argv[i], ".")

   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   /* Determine the type of object (point set or partition). */
   objectType =
      strcmp( lowerCase(argv[optionCountPlus1]), "set") == 0 ? POINT_SET :
      strcmp( lowerCase(argv[optionCountPlus1]), "partition") == 0 ? PARTITION :
                                                    INVALID_OBJECT;
   if ( objectType == INVALID_OBJECT )
      ERROR( "main (randobj command)",
             "Only types set and partition are allowed.")

   /* Determine the degree. */
   errno = 0;
   degree = strtol( argv[optionCountPlus1+1], NULL, 0);
   if ( errno || degree <= 1 || degree > options.maxDegree )
      ERROR( "main (randobj command)", "Invalid entry for degree.")

   /* Determine the set size, the number of cells (-e option), or the
      cell sizes (no -e option). */
   switch( objectType ) {
      case POINT_SET:
         errno = 0;
         setSize = strtol( argv[optionCountPlus1+2], NULL, 0);
         if ( errno || setSize < 1 || setSize >= degree )
            ERROR( "main (randobj command)", "Invalid entry for set size.")
         break;
      case PARTITION:
         if ( equalSizeFlag ) {
            errno = 0;
            numberOfEqualCells = strtol( argv[optionCountPlus1+2], NULL, 0);
            if ( errno || numberOfEqualCells < 1 || numberOfEqualCells > degree )
               ERROR( "main (randobj command)",
                      "Invalid entry for number of equal-size cells.")
         }
         else {
            errno = 0;
            j = 0;
            cellSizeSum = 0;
            currentPos = argv[optionCountPlus1+2];
            do {
               designatedCellSize[++j] = (unsigned long) strtol( currentPos, &nextPos, 0);
               if ( errno )
                  ERROR( "main (randobj command)", "Invalid cell size.")
               cellSizeSum += designatedCellSize[j];
               currentPos = nextPos+1;
            } while ( *nextPos == ',' && j <= 100 );
            designatedCellSize[j+1] = 0;
            if ( j > 100 || *nextPos != '\0' )
               ERROR( "main (randobj command)", "Cell size list invalid or too long.")
            if ( cellSizeSum != degree )
               ERROR( "main (randobj command)", "Cell sizes do not sum to degree.")
         }
         break;
   }

   /* Compute file and library names for output object. */
   parseLibraryName( argv[optionCountPlus1+3], "", "",
                     outputFileName, outputLibraryName);


   /* Initialize storage manager and random number generator. */
   initializeStorageManager( degree);
   initializeSeed( seed);

   /* Now we construct a random ordering of 1,...,degree. */
   randOrder = allocIntArrayDegree();
   for ( i = 1 ; i <= degree ; ++i )
      randOrder[i] = i;
   for ( i = 1 ; i <= degree-1 ; ++i ) {
      j = randInteger( i, degree);
      EXCHANGE( randOrder[i], randOrder[j], temp);
   }

   /* Construct and write out the point set or partition. */
   switch ( objectType ) {

      case POINT_SET:
         lambda = allocPointSet();
         if ( outputObjectName[0] )
            strcpy( lambda->name, outputObjectName);
         else
            strcpy( lambda->name, outputLibraryName);
         lambda->degree = degree;
         lambda->size = setSize;
         lambda->pointList = allocIntArrayDegree();
         for ( j = 1 ; j <= setSize ; ++j )
            lambda->pointList[j] = randOrder[j];
         sprintf( comment, "Random %u-element subset of {1,...%u}.  Seed = %lu.",
                 lambda->size, lambda->degree, seed);
         writePointSet( outputFileName, outputLibraryName, comment, lambda);
         freeIntArrayDegree( lambda->pointList);
         freePointSet( lambda);
         break;

      case PARTITION:
         pi = allocPartition();
         if ( outputObjectName[0] )
            strcpy( pi->name, outputObjectName);
         else
            strcpy( pi->name, outputLibraryName);
         pi->degree = degree;
         pi->pointList = allocIntArrayDegree();
         pi->startCell = allocIntArrayDegree();
         for ( i = 1 ; i <= degree ; ++i )
            pi->pointList[i] = randOrder[i];
         pi->startCell[1] = 1;
         if ( !equalSizeFlag ) {
            for ( i = 1 ; designatedCellSize[i] != 0 ; ++i )
               pi->startCell[i+1] = pi->startCell[i] + designatedCellSize[i];
            if ( pi->startCell[i] != degree+1 )
               ERROR( "randobj", "Cell size error (should not occur).")
            if ( i-1 <= 6 ) {
               sprintf( comment, "Random partition of {1,...%u} with cell sizes", 
                                 pi->degree);
               for ( j = 1 ; j <= i-1 ; ++j ) {
                  sprintf( tempstr, " %u", designatedCellSize[j]);
                  strcat( comment, tempstr);
               }
               sprintf( tempstr, ",  seed = %lu.", seed);
               strcat( comment, tempstr);
            }
            else
               sprintf( comment, "Random partition of {1,...%u} with %u cells "
                                 "of designated sizes.  Seed = %lu.",
                                 pi->degree, i-1, seed);
         }
         else {
            equalCellSize = degree / numberOfEqualCells;
            extraPoints = degree % numberOfEqualCells;
            for ( i = 1 ; i <= numberOfEqualCells ; ++i )
               pi->startCell[i+1] = pi->startCell[i] + equalCellSize +
                                    ((i <= extraPoints) ? 1 : 0);
            if ( pi->startCell[i] != degree+1 )
               ERROR( "randobj", "Cell size error (should not occur).")
            if ( extraPoints == 0 )
               sprintf( comment, "Random partition of {1,...%u} with %u cells "
                                 "of size %u.  Seed = %lu.",
                                 pi->degree, numberOfEqualCells, equalCellSize, 
                                 seed);
            else
               sprintf( comment, "Random partition of {1,...%u} with %u cells "
                                 "of size %u or %u.  Seed = %lu.",
                                 pi->degree, numberOfEqualCells, equalCellSize, 
                                 equalCellSize+1, seed);
         }
         writePartition( outputFileName, outputLibraryName, comment, pi);
         freeIntArrayDegree( pi->pointList);
         freeIntArrayDegree( pi->startCell);
         freePartition( pi);
         break;
   }

   return 0;
}


/*-------------------------- verifyOptions -------------------------------*/

static void verifyOptions(void)
{
   CompileOptions mainOpts = { DEFAULT_MAX_BASE_SIZE, MAX_NAME_LENGTH,
                               MAX_PRIME_FACTORS,
                               MAX_REFINEMENT_PARMS, MAX_FAMILY_PARMS,
                               MAX_EXTRA,  XLARGE, SGND, NFLT};
   extern void xbitman( CompileOptions *cOpts);
   extern void xcopy  ( CompileOptions *cOpts);
   extern void xerrmes( CompileOptions *cOpts);
   extern void xessent( CompileOptions *cOpts);
   extern void xfactor( CompileOptions *cOpts);
   extern void xnew   ( CompileOptions *cOpts);
   extern void xoldcop( CompileOptions *cOpts);
   extern void xpartn ( CompileOptions *cOpts);
   extern void xpermgr( CompileOptions *cOpts);
   extern void xpermut( CompileOptions *cOpts);
   extern void xprimes( CompileOptions *cOpts);
   extern void xrandgr( CompileOptions *cOpts);
   extern void xreadpa( CompileOptions *cOpts);
   extern void xreadpt( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);

   xbitman( &mainOpts);
   xcopy  ( &mainOpts);
   xerrmes( &mainOpts);
   xessent( &mainOpts);
   xfactor( &mainOpts);
   xnew   ( &mainOpts);
   xoldcop( &mainOpts);
   xpartn ( &mainOpts);
   xpermgr( &mainOpts);
   xpermut( &mainOpts);
   xprimes( &mainOpts);
   xrandgr( &mainOpts);
   xreadpa( &mainOpts);
   xreadpt( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}
