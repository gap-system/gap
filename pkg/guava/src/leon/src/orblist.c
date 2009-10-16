/* File orblist.c.  Main program for orblist command, which may be used
   to list the orbits of a permutation group of a set.  The orbits are written
   to the standard output.  The format of the
   command is:

      orblist <options> <permGroup>

   where the meaning of the parameters is as follows:

      <permGroup>: the permutation group whose orbits are to be computed,

   The options are as follows:

      -t:           Only the orbit lengths are listed.

      -r            The orbits are listed in randomized order.  Ignored if -l
                    option is present.

      -gn:<str>   (Set stabilizer only).  The generators for the newly-created
                  group created are given names <str>01, <str>02, ...  .  If
                  omitted, the new generators are named xxxx01, xxxx02, etc.,
                  where xxxx are the first four characters of the group name.

      -wp:<name>    Write out the ordered partition formed by the orbits.

      -wg:<name>    Write out the group, following base change.  This allows
                    orblist to be used to change the base of a permutation
                    group, or merely to construct a base and strong generating
                    set (using random schreier method).

      -ws:<name>    Like -wg, except when a point list is specified, only the
                    subgroup stabilizing that point list is written.  Note
                    -wg and -ws options are mutually exclusive.

      -i            Used with -wg, causes generators to be written in image
                    format.

      -f:<ptlist>   Here ptlist is a comma-separated list of points.  The
                    orbits of the (pointwise) stabilizer of these points is
                    found.

      -q            quite mode.  Orbit information not printed.

      -z            Remove redundant Schreier generators before group is
                    written out.

      -s:<integer>  Seed for random number generator used in conjunction with
                    -r option.   */


#include <stddef.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAIN

#include "group.h"
#include "groupio.h"

#include "addsgen.h"
#include "chbase.h"
#include "cstborb.h"
#include "errmesg.h"
#include "factor.h"
#include "new.h"
#include "randgrp.h"
#include "readgrp.h"
#include "readpar.h"
#include "readpts.h"
#include "storage.h"
#include "util.h"

static void nameGenerators(
   PermGroup *const H,
   char genNamePrefix[]);

static void verifyOptions(void);

GroupOptions options;


int main( int argc, char *argv[])
{
   char libFileName[MAX_FILE_NAME_LENGTH], partnFileName[MAX_FILE_NAME_LENGTH], 
        altGroupFileName[MAX_FILE_NAME_LENGTH], 
        pointSetFileName[MAX_FILE_NAME_LENGTH];
   char libName[MAX_NAME_LENGTH+1], partnLibName[MAX_NAME_LENGTH+1],
        altGroupLibName[MAX_NAME_LENGTH+1], pointSetLibName[MAX_NAME_LENGTH+1];
   char prefix[MAX_FILE_NAME_LENGTH] = "";
   Unsigned i, j, optionCountPlus1, found, processed, pt, img, orbitCount, orbRep,
       column, temp, cumLen, len, numOrbitsToWrite;
   BOOLEAN lengthOnlyOption, randomOption, writePartn, writeGroup, writePtStab,
           writeOrbit, writeMultipleOrbits, pointListOption, quietOption, 
           imageFormatFlag, printOrbits, trimStrGenSet, writePS, changeBaseOnly,
           ptStabOnly, lengthRepOption;
   unsigned long seed;
   PermGroup *G;
   Permutation *gen, *nextGen;
   Partition *Theta;
   PointSet *Lambda;
   UnsignedS *completeOrbit, *startOfOrbitNo, *orbNumberOfPt, *orbOrder;
   char comment[128], tempStr[12];
   UnsignedS *pointList = allocIntArrayBaseSize();
   UnsignedS *orbitRepList = allocIntArrayBaseSize();
   char *nextPos, *currentPos;
   UnsignedS stabLevel = 0;
   FactoredInt factoredOrbLen;

   /* Provide usage information if no arguments (except possibly -chbase
      or -ptstab) are given. */
   if ( argc == 1 ) {
      printf( "\nUsage:  orblist [options] permGroup\n");
      return 0;
   }
   else if ( argc == 2 && strcmp(argv[1], "-chbase") == 0 ) {
      printf( "\nUsage:  chbase permGroup p1,p2,...,pk newGroup\n");
      return 0;
   }
   else if ( argc == 2 && strcmp(argv[1], "-ptstab") == 0 ) {
      printf( "\nUsage:  ptstab permGroup p1,p2,...,pk stabilizerSubgroup\n");
      return 0;
   }

   /* Check for limits option.  If present in position 1 give limits and
      return. */
   if ( argc > 1 && (strcmp(argv[1], "-l") == 0 || strcmp(argv[1], "-L") == 0) ) {
      showLimits();
      return 0;
   }

   /* Check for verify option.  If present, perform verify (Note verify Options
      terminates program). */
   if ( argc > 1 && (strcmp(argv[1], "-v") == 0 || strcmp(argv[1], "-V") == 0) ) 
      verifyOptions();

   /* Check for 1 to 3 parameters following options. */
      for ( optionCountPlus1 = 1 ; optionCountPlus1 <= argc-1 &&
                 argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
         ;

      if ( argc - optionCountPlus1 > 3 ) {
         printf( "\n\nError: At most 3 non-option parameters are allowed.\n");
         exit(ERROR_RETURN_CODE);
      }

   /* Process options. */
   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   lengthOnlyOption = FALSE;
   lengthRepOption = FALSE;
   randomOption = FALSE;
   writePartn = FALSE;
   writeGroup = FALSE;
   writePtStab = FALSE;
   writePS = FALSE;
   writeOrbit = FALSE;
   writeMultipleOrbits = FALSE;
   changeBaseOnly = FALSE;
   ptStabOnly = FALSE;
   pointListOption = FALSE;
   quietOption = FALSE;
   imageFormatFlag = FALSE;
   options.genNamePrefix[0] = '\0';
   seed = 47;
   trimStrGenSet = FALSE;
   strcpy( options.outputFileMode, "w");
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
      /* -a option */
      if ( strcmp( argv[i], "-a") == 0 )
         strcpy( options.outputFileMode, "a");
      /* -chbase option */
      else if ( strcmp(argv[i],"-chbase") == 0 ) 
         changeBaseOnly = TRUE;
      /* -gn option (not useful at present) */
      else if ( strncmp( argv[i], "-gn:", 4) == 0 )
         if ( strlen( argv[i]+4) <= 8 )
            strcpy( options.genNamePrefix, argv[i]+4);
         else
            ERROR( "main (orblist)", "Invalid value for -gn option")
      /* -i option */
      else if ( strcmp( argv[i], "-i") == 0 )
         imageFormatFlag = TRUE;
      /* -mb option */
      else if ( strncmp( argv[i], "-mb:", 4) == 0 ) {
         errno = 0;
         options.maxBaseSize = (Unsigned) strtol(argv[i]+4,NULL,0);
         if ( errno )
            ERROR( "main (cent)", "Invalid syntax for -mb option")
      }
      /* -mv option */
      else if ( strncmp( argv[i], "-mw:", 4) == 0 ) {
         errno = 0;
         options.maxWordLength = (Unsigned) strtol(argv[i]+4,NULL,0);
         if ( errno )
            ERROR( "main (cent)", "Invalid syntax for -mw option")
      }
      /* -overwrite option */
      else if ( strcmp( argv[i], "-overwrite") == 0 )
         strcpy( options.outputFileMode, "w");
      /* -p option */
      else if ( strncmp( argv[i], "-p:", 3) == 0 ) {
         strcpy( prefix, argv[i]+3);
      }
      /* -ps option */
      else if ( strncmp( argv[i], "-ps:", 4) == 0 ) {
         parseLibraryName( argv[i]+4, "", "", pointSetFileName, 
                           pointSetLibName);
         writePS = TRUE;
      }
      /* -ptstab option */
      else if ( strcmp(argv[i],"-ptstab") == 0 ) 
         ptStabOnly = TRUE;
      /* -q option */
      else if ( strcmp( argv[i], "-q") == 0 )
         quietOption = TRUE;
      /* -r option */
      else if ( strcmp( argv[i], "-r") == 0 )
         randomOption = TRUE;
      /* -s option */
      else if ( strncmp(argv[i],"-s:",3) == 0 ) {
         errno = 0;
         seed = (unsigned long) strtol( argv[i]+3, NULL, 0);
         if ( errno )
            ERROR1s( "main (orblist command)", "Invalid option ", argv[i], ".")
      }
      /* -len option */
      else if ( strcmp( argv[i], "-len") == 0 )
         lengthOnlyOption = TRUE;
      /* -lr option */
      else if ( strcmp( argv[i], "-lr") == 0 )
         lengthRepOption = TRUE;
      /* -wno option */
      else if ( strncmp( argv[i], "-wno:", 5) == 0 ) {
         writeMultipleOrbits = TRUE;
         if ( writeOrbit )
            ERROR( "main (orblist command)", "-wo and -wno are incompatible.")
         errno = 0;
         numOrbitsToWrite = (Unsigned) strtol( argv[i]+5, NULL, 0);
         if ( errno )
            ERROR1s( "main (orblist command)", "Invalid option ", argv[i], ".")
      }
      /* -wo option */
      else if ( strncmp( argv[i], "-wo:", 4) == 0 ) {
         writeOrbit = TRUE;
         if ( writeMultipleOrbits )
            ERROR( "main (orblist command)", "-wo and -wno are incompatible.")
         errno = 0;
         j = 0;
         currentPos = argv[i]+4;
         do {
            orbitRepList[++j] = strtol( currentPos, &nextPos, 0);
            if ( errno )
               ERROR( "main (orblist command)", "Invalid syntax in -wo option.")
            currentPos = nextPos+1;
         } while ( *nextPos == ',' && j < options.maxBaseSize );
         orbitRepList[j+1] = 0;
         if ( *nextPos != '\0' )
            ERROR( "main (orblist command)", "orbitRepList invalid or too long.")
      }
      /* -wp option */
      else if ( strncmp( argv[i], "-wp:", 4) == 0 ) {
         writePartn = TRUE;
         if ( writeGroup )
            ERROR( "main (orblist command)", "-wg and -ws are incompatible.")
         parseLibraryName( argv[i]+4, "", "", partnFileName, partnLibName);
      }
      else if ( strcmp( argv[i], "-z") == 0 )
         trimStrGenSet = TRUE;
      else
            ERROR1s( "main (orblist command)", "Invalid option ", argv[i], ".")
   }

   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   /* -ps option requires -wo and -wno, and conversely. Check this. */
   if ( writePS ^ (writeOrbit | writeMultipleOrbits) )
      ERROR( "main (orblist command)", 
             "-ps option requires -wo or -wno, and conversely")

   /* If -chbase or -ptstab options has been specified, check for 3 command
      line arguments. */
   if ( (changeBaseOnly || ptStabOnly) && (argc - optionCountPlus1 != 3) )
      ERROR( "main (orblist command)", 
             "3 non-option parameters are needed for chbase or ptstab");
      
   /* Compute name for group file. */
   parseLibraryName( argv[optionCountPlus1], prefix, "", libFileName, libName);

   /* Process the point list, if present. */
   if ( argc - optionCountPlus1 >= 2 ) {
      pointListOption = TRUE;
      errno = 0;
      j = 0;
      currentPos = argv[optionCountPlus1+1];
      do {
         pointList[++j] = strtol( currentPos, &nextPos, 0);
         if ( errno )
            ERROR( "main (orblist command)", "Invalid point in -f option.")
         currentPos = nextPos+1;
      } while ( *nextPos == ',' && j < options.maxBaseSize );
      pointList[j+1] = 0;
      if ( *nextPos != '\0' )
         ERROR( "main (orblist command)", "Pointlist invalid or too long.")
   }

   /* Process name of the point stabilizer to save, or the name under which
      to save the group with its new base. */
   if ( argc - optionCountPlus1 == 3 ) {
      if ( changeBaseOnly )
         writeGroup = TRUE;
      else
         writePtStab = TRUE;
      parseLibraryName( argv[optionCountPlus1+2], "", "", altGroupFileName, altGroupLibName);
   }

   /* Read in group. */
   if ( pointListOption || writeGroup || writePtStab )
      G = readPermGroup( libFileName, libName, 0, "Generate");
   else
      G = readPermGroup( libFileName, libName, 0, "");

   /* Change base if requested, and find level in new base of stabilizer
      of pointList. */
   if ( pointListOption ) {
      changeBase( G, pointList);
      if ( trimStrGenSet )
         removeRedunSGens( G, 1);
      if ( !quietOption ) {
         printf( "\n  New base: ");
         for ( j = 1 ; j <= G->baseSize ; ++j)
            printf( " %u", G->base[j]);
         printf( "\n");
      }
      if ( changeBaseOnly ) {
         strcpy( G->name, altGroupLibName);
         G->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
         nameGenerators( G, options.genNamePrefix);
         writePermGroup( altGroupFileName, altGroupLibName, G, NULL);
         return 0;
      }
      for ( stabLevel = 1 ; stabLevel <= G->baseSize ; ++stabLevel ) {
         for ( j = 1 ; pointList[j] != 0 && pointList[j] != G->base[stabLevel] ;
                       ++j )
            ;
         if ( pointList[j] == 0 )
            break;
      }
   }
   else if ( !writeGroup && !writePtStab )
      for ( gen = G->generator ; gen ; gen = gen->next )
         gen->level = 0;

   /* Allocate arrays completeOrbit, startOfOrbitNo, orbNumberOfPt, and
      orbOrder. */
   completeOrbit = allocIntArrayDegree();
   startOfOrbitNo = allocIntArrayDegree();
   orbNumberOfPt = allocIntArrayDegree();
   orbOrder = allocIntArrayDegree();
   if ( writePartn ) {
      Theta = allocPartition();
      Theta->degree = 0;                      /* To be adjusted */
      strcpy( Theta->name, partnLibName);
      Theta->pointList = allocIntArrayDegree();
      Theta->invPointList = allocIntArrayDegree();
      Theta->cellNumber = allocIntArrayDegree();
      Theta->startCell = allocIntArrayDegree();
   }
   if ( writePS ) {
      Lambda = allocPointSet();
      strcpy( Lambda->name, pointSetLibName);
      Lambda->degree = 0;
      Lambda->size = 0;
      Lambda->pointList = allocIntArrayDegree();
      Lambda->inSet = allocBooleanArrayDegree();
      for ( j = 1 ; j <= G->degree ; ++j )
         Lambda->inSet[j] = FALSE;
   }

   /* Construct the orbits, one by one in order. */
   found = processed = orbitCount = 0;
   for ( i = 1 ; i <= G->degree ; ++i )
      orbNumberOfPt[i] = 0;
   for ( orbRep = 1 ; orbRep <= G->degree ; ++orbRep )
      if ( !orbNumberOfPt[orbRep] ) {
         completeOrbit[++found] = orbRep;
         startOfOrbitNo[++orbitCount] = found;
         orbNumberOfPt[orbRep] = orbitCount;
         while ( processed < found ) {
            pt = completeOrbit[++processed];
            for ( gen = G->generator ; gen ; gen = gen->next )
               if ( gen->level >= stabLevel ) {
                  img = gen->image[pt];
                  if ( !orbNumberOfPt[img] ) {
                     completeOrbit[++found] = img;
                     orbNumberOfPt[img] = orbitCount;
                  }
               }
         }
      }

   startOfOrbitNo[orbitCount+1] = G->degree+1;

   /* Write out the orbits. */
   if ( !quietOption && (lengthOnlyOption || lengthRepOption) ) {
      column = printf( "\n Orbit lengths for group %s", G->name);
      if ( pointListOption ) {
         column += printf( " (Stabilizer of");
         for ( j = 1 ; pointList[j] != 0 ; ++j ) {
            column += printf( " ");
            column += printf( "%d", pointList[j]);
         }
         column += printf( ")");
      }
      column += printf( ":  ");
      for ( i = 1 ; i <= orbitCount ; ++i ) {
         if ( column > 66 ) {
            printf( "\n   ");
            column = 4;
         }
         if ( lengthRepOption )
         column += printf( "%u:", completeOrbit[startOfOrbitNo[i]]);
         column += printf( "%u ", startOfOrbitNo[i+1] -
                                          startOfOrbitNo[i]);
      }
      printf( "\n");
   }

   printOrbits = !quietOption && !lengthOnlyOption && !lengthRepOption;
   if ( printOrbits || writePartn || writeMultipleOrbits ) {
      if ( printOrbits )
         printf( "\n Orbits for group %s.", G->name);
      if ( printOrbits && pointListOption ) {
         printf( " (Stabilizer of");
         for ( j = 1 ; pointList[j] != 0 ; ++j ) {
            printf( " ");
            printf( "%d", pointList[j]);
         }
         printf( ")");
      }
      if ( printOrbits )
         printf( "\n\n    Repr  Length  CumLen     Points\n");
      for ( i = 1 ; i <= orbitCount ; ++i )
         orbOrder[i] = i;
      if ( randomOption ) {
         initializeSeed (seed);
         for ( i = 1 ; i <= orbitCount-1 ; ++i ) {
            j = randInteger( i, orbitCount);
            EXCHANGE( orbOrder[i], orbOrder[j], temp);
         }
      }
      cumLen = 0;
      for ( i = 1 ; i <= orbitCount ; ++i ) {
         len = startOfOrbitNo[orbOrder[i]+1] - startOfOrbitNo[orbOrder[i]];
         cumLen += len;
         if ( printOrbits )
            printf( "\n %6d %6d %6d       ",
                 completeOrbit[startOfOrbitNo[orbOrder[i]]], len, cumLen);
         column = 28;
         for ( j = startOfOrbitNo[orbOrder[i]] ;
                           j < startOfOrbitNo[orbOrder[i]+1] ; ++j ) {
            if ( printOrbits && column > 71 ) {
               printf( "\n                            ");
               column = 28;
            }
            if ( printOrbits )
               column = column + printf( "%d ", completeOrbit[j]);
            if ( writePartn ) {
               Theta->pointList[++Theta->degree] = completeOrbit[j];
               Theta->invPointList[completeOrbit[j]] = Theta->degree;
               Theta->cellNumber[completeOrbit[j]] = i;
               if ( j == startOfOrbitNo[orbOrder[i]] )
                  Theta->startCell[i] = Theta->degree;
            }
            if ( writeMultipleOrbits && i <= numOrbitsToWrite ) {
               Lambda->pointList[++Lambda->size] = completeOrbit[j];
               Lambda->inSet[completeOrbit[j]] = TRUE;
            }
         }
      }
   }
   if ( printOrbits )
      printf( "\n");

   if ( writePartn ) {
      strcpy( comment, "Orbit partition of group ");
      strcat( comment, G->name);
      if ( pointListOption ) {
         strcat( comment, ", stabilizer of");
         for ( j = 1 ; pointList[j] != 0 ; ++j ) {
            sprintf( tempStr, " %u", pointList[j]);;
            strcat( comment, tempStr);
         }
      }
      strcpy( Theta->name, partnLibName);
      Theta->startCell[orbitCount+1] = Theta->degree + 1;
      writePartition( partnFileName, partnLibName, comment, Theta);
   }

   if ( writeMultipleOrbits ) {
      strcpy( comment, "First ");
      sprintf( tempStr, "%u", numOrbitsToWrite);
      strcat( comment, tempStr);
      strcat( comment, " orbits of group ");
      strcat( comment, G->name);
      if ( pointListOption ) {
         strcat( comment, "(stabilizer of");
         for ( j = 1 ; pointList[j] != 0 ; ++j ) {
            sprintf( tempStr, " %u", pointList[j]);;
            strcat( comment, tempStr);
         strcat( comment, ")");
         }
      }
      writePointSet( pointSetFileName, pointSetLibName, comment, Lambda);
   }

   if ( writeOrbit ) {
      strcpy( comment, "Orbit(s) in group ");
      strcat( comment, G->name);
      if ( pointListOption ) {
         strcat( comment, "(stabilizer of");
         for ( j = 1 ; pointList[j] != 0 ; ++j ) {
            sprintf( tempStr, " %u", pointList[j]);;
            strcat( comment, tempStr);
         strcat( comment, ")");
         }
      }
      strcat( comment, " of point(s)");
      for ( j = 1 ; orbitRepList[j] != 0 ; ++j ) {
         sprintf( tempStr, " %u", orbitRepList[j]);;
         strcat( comment, tempStr);
      }
      for ( i = 1 ; orbitRepList[i] != 0 ; ++i )
         if ( !Lambda->inSet[orbitRepList[i]] ) 
            for ( j = startOfOrbitNo[orbNumberOfPt[orbitRepList[i]]] ;
                  j < startOfOrbitNo[orbNumberOfPt[orbitRepList[i]]+1] ; ++j ) 
               Lambda->pointList[++Lambda->size] = completeOrbit[j];
      for ( j = 1 ; j < Lambda->size ; ++j )
         Lambda->inSet[Lambda->pointList[j]] = TRUE;
      writePointSet( pointSetFileName, pointSetLibName, comment, Lambda);
   }

   if ( writeGroup ) {
      strcpy( G->name, altGroupLibName);
      G->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
      nameGenerators( G, options.genNamePrefix);
      writePermGroup( altGroupFileName, altGroupLibName, G, NULL);
   }

   if ( writePtStab ) {
      if ( trimStrGenSet )
         removeRedunSGens( G, 1);
      /* First remove generators from G having level less than stabLevel, and
         adjust the order.  Note, after here, the group table is not valid,
         but it is adequate for writing out (writePermGroup). */
      for ( gen = G->generator ; gen ; gen = nextGen ) {
         nextGen = gen->next;
         if ( gen->level < stabLevel ) {
            if ( gen->last )
               gen->last->next = nextGen;
            else
               G->generator = nextGen;
            if ( nextGen )
               nextGen->last = gen->last;
            deletePermutation( gen);
         }
      }
      for ( i = 1 ; i < stabLevel ; ++i ) {
         factoredOrbLen = factorize( G->basicOrbLen[i]);
         factDivide( G->order, &factoredOrbLen);
         G->basicOrbLen[i] = 1;
      }

      /* Now write out the modified G. */
      strcpy( comment, "Pointwise stabilizer in %s of ");
      for ( j = 1 ; pointList[j] != 0 ; ++j ) {
         sprintf( tempStr, " %d", pointList[j]);
         strcat( comment, tempStr);
      }
      strcpy( G->name, altGroupLibName);
      G->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
      nameGenerators( G, options.genNamePrefix);
      writePermGroup( altGroupFileName, altGroupLibName, G, NULL);
   }

   /* Free pseudo-stack storage. */
   freeIntArrayBaseSize( pointList);
   freeIntArrayBaseSize( orbitRepList);

   /* Terminate. */
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
   extern void xreadpa( CompileOptions *cOpts);
   extern void xreadpt( CompileOptions *cOpts);
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
   xreadpa( &mainOpts);
   xreadpt( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}
