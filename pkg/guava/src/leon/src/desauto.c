/* File desauto.c. */

/* Copyright (C) 1992 by Jeffrey S. Leon.  This software may be used freely
   for educational and research purposes.  Any other use requires permission
   from the author. */

/*  Main program for design/matrix automorphism group and
   isomorphism programs.   The formats for the commands are:

      desauto       <options> <design> <autoGroup>
      desauto -iso  <options> <design1> <design2> <isoPerm>

   where the meaning of the parameters is as follows:

      <design>:    The design whose automorphism group is to be computed.
      <autoGroup>: Set to the automorphism group of <design>.  Depending on
                   options, will be set to a permutation group on the set of
                   a file type of GRP is appended.
      <design1>:   The first of the two designs to be checked for isomorphism.
      <design2>:   The second of the two designs to be checked for isomorphism.
      <isoPerm>:   Set to a permutation mapping <design1> to <design2>, if one
                   exists.  Not created otherwise.  Depending on the options,
                   this will be set to a permutation on points only or on points                         
                   The name of the file in which the set stabilizer G_Lambda
                   and blocks.

   The options are as follows:

      -code:<c>   Finds the automorphism group of code c, assuming that
                  it is included in the group of the design.
      -codes:<c>,<d>  Checks isomorphism of codes <c> and <d>, assuming
                  iso is in effect, and assuming any isomorphism must map
                  <design1> to <design2>.

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

      -pb         Produces permutations on points and blocks.  Otherwise
                  the automorphism group or isomorphism are given on
                  points only.

      -cv         Applicable to codes only.  Causes the automorphism group
                  or isomorphism to be written as a permutation group on
                  coordinates and invariant vectors, rather than
                  coordinates only.

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

      -m          Read design in incidence matrix format: rows = point,
                                                          cols = blocks.

      -mt         Read design in transpose incidence matrix format:
                                                          rows = blocks,
                                                          cols = points.

   The return code for the design group algorithm is as follows:
      0: computation successful,
      15: computation terminated due to error.
   The return code for the design isomorphism algorithm is as follows:
      0: computation successful; designs isomorphic,
      1: computation successful; designs not isomorphic,
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

#include "cdesauto.h"
#include "cmatauto.h"
#include "errmesg.h"
#include "field.h"
#include "matrix.h"
#include "permgrp.h"
#include "readdes.h"
#include "readgrp.h"
#include "readper.h"
#include "storage.h"
#include "token.h"
#include "util.h"

GroupOptions options;

UnsignedS (*chooseNextBasePoint)(
   const PermGroup *const G,
   const PartitionStack *const UpsilonStack) = NULL;

static void verifyOptions(void);

int main( int argc, char *argv[])
{
   char matrixFileName[MAX_FILE_NAME_LENGTH] = "",
        outputFileName[MAX_FILE_NAME_LENGTH] = "",
        *matrix_L_FileName = matrixFileName,
        matrix_R_FileName[MAX_FILE_NAME_LENGTH] = "",
        knownSubgroupSpecifier[MAX_FILE_NAME_LENGTH] = "",
        *knownSubgroup_L_Specifier = knownSubgroupSpecifier,
        knownSubgroup_R_Specifier[MAX_FILE_NAME_LENGTH] = "",
        knownSubgroupFileName[MAX_FILE_NAME_LENGTH] = "",
        *knownSubgroup_L_FileName = knownSubgroupFileName,
        knownSubgroup_R_FileName[MAX_FILE_NAME_LENGTH] = "",
        codeFileName[MAX_FILE_NAME_LENGTH] = "",
        *code_L_FileName = codeFileName,
        code_R_FileName[MAX_FILE_NAME_LENGTH] = "";
   Unsigned i, j, optionCountPlus1, startOptions, degree;
   char matrixLibraryName[MAX_NAME_LENGTH+1] = "",
        outputLibraryName[MAX_NAME_LENGTH+1] = "",
        *matrix_L_LibraryName = matrixLibraryName,
        matrix_R_LibraryName[MAX_NAME_LENGTH+1] = "",
        knownSubgroupLibraryName[MAX_NAME_LENGTH+1] = "",
        *knownSubgroup_L_LibraryName = knownSubgroupLibraryName,
        knownSubgroup_R_LibraryName[MAX_NAME_LENGTH+1] = "",
        codeLibraryName[MAX_NAME_LENGTH+1] = "",
        *code_L_LibraryName = codeLibraryName,
        code_R_LibraryName[MAX_NAME_LENGTH+1] = "",
        prefix[MAX_FILE_NAME_LENGTH],
        suffix[MAX_NAME_LENGTH],
        outputObjectName[MAX_NAME_LENGTH+1] = "";
   Matrix_01 *matrix, *matrix_L, *matrix_R, *originalMatrix, *originalMatrix_L,
             *originalMatrix_R;
   PermGroup *A, *L = NULL, *L_L = NULL, *L_R = NULL;
   Code *C = NULL, *C_L = NULL, *C_R = NULL;
   Permutation *y;
   BOOLEAN imageFlag = FALSE, imageFormatFlag = FALSE,
           codeFlag = FALSE, transposeFlag = FALSE, pbFlag = FALSE,
           monomialFlag = FALSE;
   char tempArg[8];
   enum { DESIGN_AUTO, DESIGN_ISO, MATRIX_AUTO, MATRIX_ISO, CODE_AUTO,
          CODE_ISO} computationType = DESIGN_AUTO;
   char comment[100];

   /* Check whether the first parameters are iso, code, or matrix.
      Set the computation type. */
   j = 0;
   for ( i = 1 ; i <= 2 && i < argc ; ++i ) {
      strncpy( tempArg, argv[i], 8);
      tempArg[7] = '\0';
      lowerCase( tempArg);
      if ( strcmp( tempArg, "-iso") == 0 )
         j |= 4;
      else if ( strcmp( tempArg, "-matrix") == 0 )
         j |= 1;
      else if ( strcmp( tempArg, "-code") == 0 )
         j |= 2;
      else
         break;
   }
   switch( j ) {
      case 0:  computationType = DESIGN_AUTO;  break;
      case 1:  computationType = MATRIX_AUTO;  pbFlag = TRUE;  break;
      case 2:  computationType = CODE_AUTO; codeFlag = TRUE;  break;
      case 4:  computationType = DESIGN_ISO;  imageFlag = TRUE;  break;
      case 5:  computationType = MATRIX_ISO;  imageFlag = TRUE;  pbFlag = TRUE;  break;
      case 6:  computationType = CODE_ISO;  imageFlag = TRUE;  codeFlag = TRUE;  break;
      default: ERROR( "main (desauto)", "Invalid options"); break;
   }
   startOptions = i;

   /* Provide help if no arguments are specified. Note i and j must be as
      described above. */
   if ( startOptions == argc ) {
      switch( computationType ) {
         case DESIGN_AUTO:
            printf( "\nUsage:  desauto [options] design autoGroup\n");
            break;
         case MATRIX_AUTO:
            printf( "\nUsage:  matauto [options] matrix autoGroup\n");
            break;
         case CODE_AUTO:
            printf( "\nUsage:  codeauto [options] code invarVectorss autoGroup\n");
            break;
         case DESIGN_ISO:
            printf( "\nUsage:  desiso [options] design1 design2 isoPerm\n");
            break;
         case MATRIX_ISO:
            printf( "\nUsage:  matiso [options] matrix1 matrix2 isoPerm\n");
            break;
         case CODE_ISO:
            printf( "\nUsage:  codeiso [options] code1 code2 invarVectors1 invarVectors2 \n");
            break;
      }
      return 0;
   }

   /* Check for limits option.  If present in position startOptions give
      limits and return. */
   if ( startOptions < argc && (strcmp( argv[startOptions], "-l") == 0 ||
                                strcmp( argv[startOptions], "-L") == 0) ) {
      showLimits();
      return 0;
   }
   /* Check for verify option.  If present in position startOptions, perform
      verify.  (Note verifyOptions terminates program). */
   if ( startOptions < argc && (strcmp( argv[startOptions], "-v") == 0 ||
                                strcmp( argv[startOptions], "-V") == 0) )
      verifyOptions();

   /* Check for exactly 2 (design or matrix group), 3 (code group or design
      or matrix iso), or 4 (code iso ) parameters following options. */
   for ( optionCountPlus1 = startOptions ; optionCountPlus1 < argc &&
              argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
      ;

   if ( argc - optionCountPlus1 != 2 + imageFlag + codeFlag +
                                   (imageFlag && codeFlag) ) {
      ERROR1i( "main (design group)", "Exactly ", 2+imageFlag+codeFlag +
               (imageFlag && codeFlag), " non-option parameters are required.");
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
   parseLibraryName( argv[optionCountPlus1+1], "", "", outputFileName,
                     outputLibraryName);
   strncpy( options.genNamePrefix, outputLibraryName, 4);
   options.genNamePrefix[4] = '\0';
   strcpy( options.outputFileMode, "w");

   /* Translate options to lower case. */
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
      if ( strncmp( argv[i], "-a1:", 4) == 0 &&
                (options.alphaHat1 = (Unsigned) strtol(argv[i]+4,NULL,0) ,
                errno != ERANGE) )
         ;
      else if ( strcmp( argv[i], "-a") == 0 )
         strcpy( options.outputFileMode, "a");
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
            ERROR( "main (design group)", "Invalid value for -gn option")
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
      else if ( strcmp( argv[i], "-mm") == 0 )
         monomialFlag = TRUE;
      else if ( strcmp( argv[i], "-pb") == 0 || strcmp( argv[i], "-cv") == 0 )
         pbFlag = TRUE;
      else if ( strcmp( argv[i], "-ro") == 0 )
         pbFlag = FALSE;
      else if ( strcmp( argv[i], "-tr") == 0 )
         transposeFlag = TRUE;
      else if ( strncmp( argv[i], "-n:", 3) == 0 )
         if ( isValidName( argv[i]+3) )
            strcpy( outputObjectName, argv[i]+3);
         else
            ERROR1s( "main (design group)", "Invalid name ", outputObjectName,
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

   /* Compute file and library names. */
   switch( computationType) {
      case CODE_AUTO:
         parseLibraryName( argv[optionCountPlus1], prefix, suffix,
                           codeFileName, codeLibraryName);
         /* Deliberate fall through to next case. */
      case DESIGN_AUTO:
      case MATRIX_AUTO:
         parseLibraryName( argv[optionCountPlus1+codeFlag], prefix, suffix,
                           matrixFileName, matrixLibraryName);
         parseLibraryName( argv[optionCountPlus1+1+codeFlag], "", "",
                           outputFileName, outputLibraryName);
         if ( outputObjectName[0] == '\0' )
            strncpy( outputObjectName, outputLibraryName, MAX_NAME_LENGTH+1);
         if ( knownSubgroupSpecifier[0] != '\0' )
            parseLibraryName( knownSubgroupSpecifier, prefix, suffix,
                              knownSubgroupFileName, knownSubgroupLibraryName);
         break;
      case CODE_ISO:
         parseLibraryName( argv[optionCountPlus1], prefix, suffix,
                           code_L_FileName, code_L_LibraryName);
         parseLibraryName( argv[optionCountPlus1+1], prefix, suffix,
                           code_R_FileName, code_R_LibraryName);
         /* Deliberate fall through to next case. */
      case DESIGN_ISO:
      case MATRIX_ISO:
         parseLibraryName( argv[optionCountPlus1+2*codeFlag], prefix, suffix,
                           matrix_L_FileName, matrix_L_LibraryName);
         parseLibraryName( argv[optionCountPlus1+1+2*codeFlag], prefix, suffix,
                           matrix_R_FileName, matrix_R_LibraryName);
         parseLibraryName( argv[optionCountPlus1+2+2*codeFlag], "", "",
                           outputFileName, outputLibraryName);
         if ( outputObjectName[0] == '\0' )
            strncpy( outputObjectName, outputLibraryName, MAX_NAME_LENGTH+1);
         if ( knownSubgroup_L_Specifier[0] != '\0' )
            parseLibraryName( knownSubgroup_L_Specifier, prefix, suffix,
                              knownSubgroup_L_FileName, knownSubgroup_L_LibraryName);
         if ( knownSubgroup_R_Specifier[0] )
            parseLibraryName( knownSubgroup_R_Specifier, prefix, suffix,
                              knownSubgroup_R_FileName, knownSubgroup_R_LibraryName);
         break;
   }

   /* Read in the design(s), matrices, or codes, and compute the degree. */
   switch ( computationType ) {
      case DESIGN_AUTO:
         matrix = readDesign( matrixFileName, matrixLibraryName, 0, 0);
         degree = matrix->numberOfRows + matrix->numberOfCols;
         if ( !pbFlag )
            options.restrictedDegree = matrix->numberOfRows;
         break;
      case MATRIX_AUTO:
         if ( transposeFlag )
            matrix = read01Matrix( matrixFileName, matrixLibraryName, TRUE,
                                   monomialFlag, 0, 0, 0);
         else
            matrix = read01Matrix( matrixFileName, matrixLibraryName, FALSE,
                                   monomialFlag, 0, 0, 0);
         if ( monomialFlag ) {
            matrix->field = buildField( matrix->setSize);
            originalMatrix = matrix;
            matrix = augmentedMatrix( originalMatrix);
         }
         degree = matrix->numberOfRows + matrix->numberOfCols;
         if ( !pbFlag )
            options.restrictedDegree = matrix->numberOfRows;
         else if ( monomialFlag )
            options.restrictedDegree = matrix->numberOfCols;
         break;
      case CODE_AUTO:
         C = readCode( codeFileName, codeLibraryName, TRUE, 0, 0, 0);
         monomialFlag = (C->fieldSize > 2);
         matrix = read01Matrix( matrixFileName, matrixLibraryName, TRUE,
                                C->fieldSize > 2, C->fieldSize, C->length, 0);
         if ( monomialFlag ) {
            matrix->field = C->field;
            originalMatrix = matrix;
            matrix = augmentedMatrix( originalMatrix);
         }
         degree = matrix->numberOfRows + matrix->numberOfCols;
         if ( !pbFlag )
            options.restrictedDegree = matrix->numberOfRows;
         else if ( monomialFlag )
            options.restrictedDegree = matrix->numberOfCols;
         break;
      case DESIGN_ISO:
         matrix_L = readDesign( matrix_L_FileName, matrix_L_LibraryName,
                                0, 0);
         matrix_R = readDesign( matrix_R_FileName, matrix_R_LibraryName,
                                0, 0);
         if ( matrix_L->numberOfRows != matrix_R->numberOfRows )
            ERROR( "main (design group)",
                    "Designs have different numbers of points.")
         if ( matrix_L->numberOfCols != matrix_R->numberOfCols ) {
            if ( options.inform )  {
               printf( "\n\n%s and %s are not isomorphic.  ");
               printf( "They have %u and %u blocks, respectively.\n\n",
                       matrix_L->numberOfCols, matrix_R->numberOfCols);
            }
            return 1;
         }
         degree = matrix_L->numberOfRows + matrix_L->numberOfCols;
         if ( !pbFlag )
            options.restrictedDegree = matrix_L->numberOfRows;
         break;
      case MATRIX_ISO:
         if ( transposeFlag ) {
            matrix_L = read01Matrix( matrix_L_FileName, matrix_L_LibraryName, TRUE,
                           monomialFlag, 0, 0, 0);
            matrix_R = read01Matrix( matrix_R_FileName, matrix_R_LibraryName, TRUE,
                           monomialFlag, matrix_L->setSize, matrix_L->numberOfRows, 
                           matrix_L->numberOfCols - monomialFlag * 
                           matrix_L->numberOfRows);
         }
         else {
            matrix_L = read01Matrix( matrix_L_FileName, matrix_L_LibraryName, FALSE,
                           monomialFlag, 0, 0, 0);
            matrix_R = read01Matrix( matrix_R_FileName, matrix_R_LibraryName, FALSE,
                           monomialFlag, matrix_L->setSize, matrix_L->numberOfRows, 
                           matrix_L->numberOfCols - monomialFlag * 
                           matrix_L->numberOfRows);
         }
         if ( monomialFlag ) {
            matrix_L->field = matrix_R->field = buildField( matrix_L->setSize);
            originalMatrix_L = matrix_L;
            originalMatrix_R = matrix_R;
            matrix_L = augmentedMatrix( originalMatrix_L);
            matrix_R = augmentedMatrix( originalMatrix_R);
         }
         degree = matrix_L->numberOfRows + matrix_L->numberOfCols;
         if ( !pbFlag )
            options.restrictedDegree = matrix_L->numberOfRows;
         else if ( monomialFlag )
            options.restrictedDegree = matrix_L->numberOfCols;
         break;
      case CODE_ISO:
         C_L = readCode( code_L_FileName, code_L_LibraryName, TRUE, 
                           0, 0, 0);
         C_R = readCode( code_R_FileName, code_R_LibraryName, TRUE, 
                           C_L->fieldSize, 0, C_L->length);
         monomialFlag = (C_L->fieldSize > 2);
         matrix_L = read01Matrix( matrix_L_FileName, matrix_L_LibraryName, TRUE,
                           C_L->fieldSize > 2, C_L->fieldSize, C_L->length, 0);
         matrix_R = read01Matrix( matrix_R_FileName, matrix_R_LibraryName, TRUE,
                           C_L->fieldSize > 2, C_L->fieldSize, C_L->length, 
                           0);
         if ( C_L->dimension != C_R->dimension ) {
            if ( options.inform )  {
               printf( "\n\n%s and %s are not isomorphic.  ");
               printf( "They have dimension %u and %u, respectively.\n\n",
                       C_L->dimension, C_R->dimension);
            }
            return 1;
         }
         if ( matrix_L->numberOfCols != matrix_R->numberOfCols ) {
            if ( options.inform )  {
               printf( "\n\n%s and %s are not isomorphic.  ");
               printf( "The invariant vector sets have different sizes.\n");
            }
            return 1;
         }
         if ( monomialFlag ) {
            matrix_L->field = matrix_R->field = C_L->field; 
            originalMatrix_L = matrix_L;
            originalMatrix_R = matrix_R;
            matrix_L = augmentedMatrix( originalMatrix_L);
            matrix_R = augmentedMatrix( originalMatrix_R);
         }
         degree = matrix_L->numberOfRows + matrix_L->numberOfCols;
         if ( !pbFlag )
            options.restrictedDegree = matrix_L->numberOfRows;
         else if ( monomialFlag )
            options.restrictedDegree = matrix_L->numberOfCols;
         break;
   }

   /* Initialize storage manager. */
   initializeStorageManager( degree);

   /* Read in the known subgroups, if present, and the codes, if present. */
   switch ( computationType ) {
      case DESIGN_AUTO:
      case MATRIX_AUTO:
      case CODE_AUTO:
         if ( knownSubgroupSpecifier[0] )
            L = readPermGroup( knownSubgroupFileName, knownSubgroupLibraryName,
                               degree, "Generate");
         break;
      case DESIGN_ISO:
      case MATRIX_ISO:
      case CODE_ISO:
         if ( knownSubgroup_L_Specifier[0] )
            L_L = readPermGroup( knownSubgroup_L_FileName,
                       knownSubgroup_L_LibraryName, degree, "Generate");
         if ( knownSubgroup_R_Specifier[0] )
            L_R = readPermGroup( knownSubgroup_R_FileName,
                       knownSubgroup_R_LibraryName, degree, "Generate");
         break;
   }

   /* Compute maximum base change level if not specified as option ??????. */
   if ( options.maxBaseChangeLevel == UNKNOWN )
      options.maxBaseChangeLevel = 0;

   /* Compute the automorphism group or check isomorphism, and write out
      the group or isomorphism permutation. */
   switch ( computationType ) {
      case DESIGN_AUTO:
      case MATRIX_AUTO:
      case CODE_AUTO:
         if ( options.inform ) {
            switch ( computationType ) {
               case DESIGN_AUTO:
                  printf( "\n\n            Design Automorphism Group Program:  "
                          "Design %s\n\n", matrix->name);
                  sprintf( comment, "The automorphism group of design %s.",
                           matrix->name);
                  options.groupOrderMessage = "Design automorphism group";
                  break;
               case MATRIX_AUTO:
                  if ( monomialFlag ) {
                     printf( "\n\n            Matrix Monomial Group Program:  "
                             "Matrix %s\n\n", matrix->name);
                     sprintf( comment, "The monomial group of matrix %s.",
                              matrix->name);
                     options.groupOrderMessage = 
                              "Matrix monomial automorphism group";
                  }
                  else {
                     printf( "\n\n            Matrix Automorphism Group Program:  "
                             "Matrix %s\n\n", matrix->name);
                     sprintf( comment, "The automorphism group of matrix %s.",
                              matrix->name);
                     options.groupOrderMessage = "Matrix automorphism group";
                  }
                  break;
               case CODE_AUTO:
                  printf( "\n\n      Code Automorphism Group Program:  "
                          "Code %s, Invariant set %s\n\n", C->name, matrix->name);
                  sprintf( comment, "The automorphism group of code %s.",
                           C->name);
                  options.groupOrderMessage = "Code automorphism group";
                  break;
            }
            if ( L )
               printf( "\nKnown Subgroup: %s\n", L->name);
            printf( "\n");
         }
         if ( (computationType == MATRIX_AUTO && matrix->setSize > 2) ||
              (computationType == CODE_AUTO && C->fieldSize > 2) )
            A = matrixAutoGroup( matrix, L, C, monomialFlag);
         else
            A = designAutoGroup( matrix, L, C);
         strcpy( A->name, outputObjectName);
         A->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
         if ( pbFlag )
            if ( monomialFlag )
               writePermGroupRestricted( outputFileName, outputLibraryName, A, 
                                     comment, matrix->numberOfCols);
            else 
               writePermGroup( outputFileName, outputLibraryName, A, comment);
         else
            writePermGroupRestricted( outputFileName, outputLibraryName, A,
                                      comment, matrix->numberOfRows);
         break;
      case DESIGN_ISO:
      case MATRIX_ISO:
      case CODE_ISO:
         if ( options.inform ) {
            switch ( computationType ) {
               case DESIGN_ISO:
                  printf( "\n\n         Design Isomorphism Program:  "
                       "Designs %s and %s\n\n", matrix_L->name, matrix_R->name);
                  sprintf( comment, "An isomorphism from design %s to design %s.",
                        matrix_L->name, matrix_R->name);
                  options.cosetRepMessage = 
                     "The designs are isomorphic.  An isomorphism is:";
                  options.noCosetRepMessage = 
                     "The designs are not isomorphic.";
                  break;
               case MATRIX_ISO:
                  if ( monomialFlag ) {
                     printf( "\n\n         Matrix Monomial Isomorphism Program:  "
                          "Matrices %s and %s\n\n", matrix_L->name, matrix_R->name);
                     sprintf( comment, "An monomial isomorphism from matrix %s to matrix %s.",
                           matrix_L->name, matrix_R->name);
                     options.cosetRepMessage = 
                        "The matrices are monomially isomorphic.  An isomorphism is:";
                     options.noCosetRepMessage = 
                        "The designs are not monomially isomorphic.";
                  }
                  else {
                     printf( "\n\n         Matrix Isomorphism Program:  "
                          "Matrices %s and %s\n\n", matrix_L->name, matrix_R->name);
                     sprintf( comment, "An isomorphism from matrix %s to matrix %s.",
                           matrix_L->name, matrix_R->name);
                     options.cosetRepMessage = 
                        "The matrices are isomorphic.  An isomorphism is:";
                     options.noCosetRepMessage = 
                        "The matrices are not isomorphic.";
                  }  
                  break;
               case CODE_ISO:
                  printf( "\n\n     Code Isomorphism Program:  "
                       "Codes %s and %s, Invariant sets %s and %s\n\n",
                        C_L->name, C_R->name, matrix_L->name, matrix_R->name);
                  sprintf( comment, "An isomorphism from code %s to code %s.",
                        C_L->name, C_R->name);
                  options.cosetRepMessage = 
                     "The codes are isomorphic.  An isomorphism is:";
                  options.noCosetRepMessage = 
                     "The codes are not isomorphic.";
                  break;
            }
            if ( L_L )
               printf( "\nKnown Subgroup (left):  %s", L_L->name);
            if ( L_R )
               printf( "\nKnown Subgroup (right): %s", L_R->name);
            if ( L_L || L_R )
               printf( "\n");
         }
         if ( (computationType == MATRIX_ISO && matrix_L->setSize > 2) ||
              (computationType == CODE_ISO && C_L->fieldSize > 2) )
            y = matrixIsomorphism( matrix_L, matrix_R, L_L, L_R, C_L, C_R, 
                                   monomialFlag, pbFlag);
         else
            y = designIsomorphism( matrix_L, matrix_R, L_L, L_R, C_L, C_R, pbFlag);
         if ( y ) {
            strcpy( y->name, outputObjectName);
            if ( pbFlag )
               if ( monomialFlag )
                  if ( imageFormatFlag )
                     writePermutationRestricted( outputFileName, 
                            outputLibraryName, y, "image", comment, 
                            matrix_L->numberOfCols);
                  else
                     writePermutationRestricted( outputFileName, 
                            outputLibraryName, y, "", comment, 
                            matrix_L->numberOfCols);
               else
                  if ( imageFormatFlag )
                     writePermutation( outputFileName, outputLibraryName, y, 
                                       "image", comment);
                  else
                     writePermutation( outputFileName, outputLibraryName, y, 
                                       "", comment);
            else
               if ( imageFormatFlag )
                  writePermutationRestricted( outputFileName, outputLibraryName,
                                       y, "image", comment, matrix_L->numberOfRows);
               else
                  writePermutationRestricted( outputFileName, outputLibraryName,
                                       y, "", comment, matrix_L->numberOfRows);
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
   extern void xcdesau( CompileOptions *cOpts);
   extern void xchbase( CompileOptions *cOpts);
   extern void xcmatau( CompileOptions *cOpts);
   extern void xcompcr( CompileOptions *cOpts);
   extern void xcompsg( CompileOptions *cOpts);
   extern void xcopy  ( CompileOptions *cOpts);
   extern void xcstbor( CompileOptions *cOpts);
   extern void xcstrba( CompileOptions *cOpts);
   extern void xerrmes( CompileOptions *cOpts);
   extern void xessent( CompileOptions *cOpts);
   extern void xfactor( CompileOptions *cOpts);
   extern void xfield ( CompileOptions *cOpts);
   extern void xinform( CompileOptions *cOpts);
   extern void xmatrix( CompileOptions *cOpts);
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
   extern void xreadde( CompileOptions *cOpts);
   extern void xreadgr( CompileOptions *cOpts);
   extern void xreadpe( CompileOptions *cOpts);
   extern void xrpriqu( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);
   
   xaddsge( &mainOpts);
   xbitman( &mainOpts);
   xcdesau( &mainOpts);
   xchbase( &mainOpts);
   xcmatau( &mainOpts);
   xcompcr( &mainOpts);
   xcompsg( &mainOpts);
   xcopy  ( &mainOpts);
   xcstbor( &mainOpts);
   xcstrba( &mainOpts);
   xerrmes( &mainOpts);
   xessent( &mainOpts);
   xfactor( &mainOpts);
   xfield ( &mainOpts);
   xinform( &mainOpts);
   xmatrix( &mainOpts);
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
   xreadde( &mainOpts);
   xreadgr( &mainOpts);
   xreadpe( &mainOpts);
   xrpriqu( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}
