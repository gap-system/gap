/* File cjrndper.c.  Main program for cjrndper command, which may be used
   to conjugate a given point set, permutation, permutation group, partition,
   design, or code by one of the following: (1) a random permutation from the
   symmetric group, (2) a random permutation from a specified permutation group,
   or (3) a specified permutation.  The syntax of the command is:

      cjrndper <options> <objectType> <ObjectName> <conjObjectName> <permName>

   where the meaning of the parameters is as follows:

      <objectType>:     "group", "perm", "set", "partition", "design",
                         "matrix", or "code"
      <objectName>:     The point set or permutation to be conjugated.  The name
                        must include the suffix.
      <conjObjectName>: The name (excluding suffix) of the new object created by
                        conjugating <fullObjectName> by a random element of
                        <groupName>.  May be the same of <fullObjectName>.
      <permName>:       (optional) Set to the conjugating permutation chosen at
                         random from group <groupName>.  If omitted, the
                         conjugating permutation is not saved.

   The valid options are follows:
      -g:<groupName>  The name of the permutation group from which the
                      conjugating element is to be chosen.  If omitted, the
                      symmetric group is used.  In case of input from a Cayley
                      library, <groupName> is the name of the library block.
      -i              Write permutations in image format.
      -p:<permName>   The specific permutation to be used as the conjugating
                      element.
      -s:<integer>    Sets seed for random number generator to <integer>,
      -d:<integer>    Degree for point sets, permutations, or partitions.
      -b              Construct base and sgs for conjugated group. */


#include <stddef.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAIN

#include "group.h"
#include "groupio.h"

#include "code.h"
#include "copy.h"
#include "errmesg.h"
#include "field.h"
#include "matrix.h"
#include "new.h"
#include "permut.h"
#include "readdes.h"
#include "randgrp.h"
#include "readgrp.h"
#include "readpar.h"
#include "readper.h"
#include "readpts.h"
#include "storage.h"
#include "token.h"
#include "util.h"

GroupOptions options;

static void nameGenerators(
   PermGroup *const H,
   char genNamePrefix[]);

static void verifyOptions(void);
static void setToRandomMonomialPerm(
   Permutation *const perm,
   const Unsigned subDegree,
   const Field *const field);


int main(
   int argc,
   char *argv[])
{
   ObjectType objectType;
   char inputFileName[60] = "",
        inputLibraryName[MAX_NAME_LENGTH+1] = "",
        outputFileName[60] = "",
        outputLibraryName[MAX_NAME_LENGTH+1] = "",
        outputObjectName[MAX_NAME_LENGTH+1] = "",
        permGroupSpecifier[60] = "",
        permGroupFileName[60] = "",
        permGroupLibraryName[MAX_NAME_LENGTH+1] = "",
        permFileName[60] = "",
        permLibraryName[MAX_NAME_LENGTH+1] = "",
        originalInputName[MAX_NAME_LENGTH+1],
        prefix[60] = "",
        suffix[MAX_NAME_LENGTH] = "";
   Unsigned i, j, k, degree, temp, optionCountPlus1, nRows, nCols, m, lambda, 
            mu, tau, fSize;
   unsigned long seed;
   PermGroup *G, *H, *HConjugated;
   PointSet *Lambda;
   Permutation *s, *t, *conjugatingPerm, *gen, *genConj;
   Partition *partn;
   Matrix_01 *matrix, *matrixConjugated;
   Code *C, *CConjugated;
   char comment[255];
   BOOLEAN baseSgsFlag = FALSE, imageFormatFlag = FALSE, cjperFlag = FALSE,
           monomialFlag = FALSE;
   UnsignedS *newCellNumber;

   /* If there are no options (except possibly -perm), provide usage
      information and exit. */
   if ( argc == 1 ) {
      printf( "\nUsage:  cjrndper [options] type object conjugateObject [conjugatingPerm]");
      printf( "\n        (type = group, perm, set, partition, design, matrix, or code)\n");
      return 0;
   }
   else if ( argc == 2 && strcmp(argv[1],"-perm") == 0 ) {
      printf( "\nUsage:  cjrndper [options] type object conjugateObject conjugatingPerm");
      printf( "\n        (type = group, perm, set, partition, design, matrix, or code)\n");
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

   if ( strcmp(argv[1],"-perm") ==  0 )
      i = 2;
   else
      i = 1;

   /* Check for limits option.  If present in position i (i as above) give
      limits and return. */
   if ( strcmp(argv[i], "-l") == 0 || strcmp(argv[i], "-L") == 0 ) {
      showLimits();
      return 0;
   }

   /* Check for verify option.  If present in position i (i as above) perform
      verify (Note verifyOptions terminates program). */
   if ( strcmp(argv[i], "-v") == 0 || strcmp(argv[i], "-V") == 0 ) 
      verifyOptions();

   /* Check for exactly 3 or 4 parameters following options. */
      if ( argc - optionCountPlus1 != 3 && argc - optionCountPlus1 != 4 ) {
         printf( "\n\nError: Exactly 3 or 4 non-option parameters are "
                 "required.\n");
         exit(ERROR_RETURN_CODE);
      }

   /* Process options. */
   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   strcpy( options.outputFileMode, "w");
   seed = 47;
   degree = 0;
   options.genNamePrefix[0] = '\0';
   for ( i = 1 ; i < optionCountPlus1 ; ++i )
      if ( strcmp(argv[i],"-a") == 0 )
         strcpy( options.outputFileMode, "a");
      else if ( strncmp(argv[i],"-d:",3) == 0 ) {
         degree = strtol( argv[i]+3, NULL, 0);
      }
      else if ( strncmp(argv[i],"-s:",3) == 0 ) {
         errno = 0;
         seed = strtol( argv[i]+3, NULL, 0);
         if ( errno )
            ERROR1s( "main (cjrndper command)", "Invalid option ", argv[i], ".")
      }
      else if ( strncmp(argv[i],"-g:",3) == 0 )
         strcpy( permGroupSpecifier, argv[i]+3);
      else if ( strcmp(argv[i],"-i") == 0 )
         imageFormatFlag = TRUE;
      else if ( strcmp(argv[i],"-mm") == 0 )
         monomialFlag = TRUE;
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
         strcpy( outputObjectName, argv[i]+3);
      else if ( strcmp(argv[i],"-perm") == 0 )
         cjperFlag = TRUE;
      else if ( strncmp( argv[i], "-gn:", 4) == 0 )
         if ( strlen( argv[i]+4) <= 8 )
            strcpy( options.genNamePrefix, argv[i]+4);
         else
            ERROR( "main (orblist)", "Invalid value for -gn option")
      else if ( strncmp( argv[i], "-p:", 3) == 0 ) {
         strcpy( prefix, argv[i]+3);
      }
      else if ( strncmp( argv[i], "-t:", 3) == 0 ) {
         strcpy( suffix, argv[i]+3);
      }
      else if ( strcmp( argv[i], "-b" ) == 0 )
         baseSgsFlag = TRUE;
      else if ( strcmp( argv[i], "-overwrite") == 0 )
         strcpy( options.outputFileMode, "w");
      else
         ERROR1s( "main (cjrndper command)", "Invalid option ", argv[i], ".")
   if ( cjperFlag && permGroupSpecifier[0] )
         ERROR( "main (cjrndper command)",
                 "-g and -p are conflicting options.")

   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   objectType =
      strcmp( lowerCase(argv[optionCountPlus1]), "group") == 0 ? PERM_GROUP :
      strcmp( lowerCase(argv[optionCountPlus1]), "perm") == 0 ? PERMUTATION :
      strcmp( lowerCase(argv[optionCountPlus1]), "set") == 0 ? POINT_SET :
      strcmp( lowerCase(argv[optionCountPlus1]), "partition") == 0 ? PARTITION :
      strcmp( lowerCase(argv[optionCountPlus1]), "design") == 0 ? DESIGN :
      strcmp( lowerCase(argv[optionCountPlus1]), "matrix") == 0 ? MATRIX_01 :
      strcmp( lowerCase(argv[optionCountPlus1]), "code") == 0 ? BINARY_CODE :
                                                    INVALID_OBJECT;
   if ( objectType == INVALID_OBJECT )
      ERROR( "main (chrndper command)",
             "File type for object to be conjugated is invalid.")
   if ( degree == 0 && (objectType == PERMUTATION || objectType == POINT_SET ||
                        objectType == PARTITION)  )
      ERROR( "main (cjrndper command)", "Degree must be specified.")

   /* Compute file names. */
   parseLibraryName( argv[optionCountPlus1+1], prefix, suffix, inputFileName,
                     inputLibraryName);
   parseLibraryName( argv[optionCountPlus1+2], "", "", outputFileName,
                     outputLibraryName);
   if ( optionCountPlus1+3 < argc )
      parseLibraryName( argv[optionCountPlus1+3], "", "", permFileName,
                        permLibraryName);
   else if ( cjperFlag )
      ERROR( "main (cjrndper command)", "Conjugating permutation not specified.")
   if ( permGroupSpecifier[0] )
      parseLibraryName( permGroupSpecifier, prefix, suffix, permGroupFileName,
                        permGroupLibraryName);

   /* Set output object name, if not specified by -n option. */
   if ( !outputObjectName[0] )
      strcpy( outputObjectName, outputLibraryName);

   /* Read in the object to be conjugated. */
   switch( objectType ) {
      case PERM_GROUP:
         if ( baseSgsFlag ) {
            H = readPermGroup( inputFileName, inputLibraryName, 0, "Generate");
           initializeSeed( seed);
         }
         else
            H = readPermGroup( inputFileName, inputLibraryName, 0, "");
         degree = H->degree;
         break;
      case POINT_SET:
         Lambda = readPointSet( inputFileName, inputLibraryName, degree);
         break;
      case PERMUTATION:
         s = readPermutation( inputFileName, inputLibraryName, degree, TRUE);
         degree = s->degree;
         break;
      case PARTITION:
         partn = readPartition( inputFileName, inputLibraryName, degree);
         degree = partn->degree;
         break;
      case DESIGN:
      case MATRIX_01:
         if ( objectType == DESIGN )
            matrix = readDesign( inputFileName, inputLibraryName, 0, 0);
         else
            matrix = read01Matrix( inputFileName, inputLibraryName, FALSE,
                                   FALSE, 0, 0, 0);
         nRows = matrix->numberOfRows;
         nCols = matrix->numberOfCols;
         if ( monomialFlag ) {
            matrix->field = buildField( matrix->setSize);
            degree = (matrix->setSize - 1) * (nRows + nCols);
         }
         else
            degree = nRows + nCols;
         initializeStorageManager( degree);
         break;
      case BINARY_CODE:
         C = readCode( inputFileName, inputLibraryName, FALSE, 0, 0, 0);
         if ( C->fieldSize > 2 ) {
            C->field = buildField( C->fieldSize);
            degree = (C->fieldSize - 1) * C->length;
         }
         else
            degree = C->length;
         initializeStorageManager( degree);
         break;
   }

   /* Initialize random number generator. */
   initializeSeed( seed);

   /* Read in the group, if provided and check its degree.  Then generate
      either a random permutation in the group, or a random permutation from
      the symmetric group. */
   if ( cjperFlag )
      conjugatingPerm = readPermutation( permFileName,
                              permLibraryName, degree, TRUE);
   else if ( permGroupFileName[0] ) {
      G = readPermGroup( permGroupFileName, permGroupLibraryName, degree,
                         "Generate");
      initializeSeed( seed);
      conjugatingPerm = randGroupPerm( G, 1);
   }
   else {
      conjugatingPerm = newIdentityPerm( degree);
      if ( objectType != DESIGN && objectType != MATRIX_01 ) 
         if ( objectType != BINARY_CODE || C->fieldSize == 2 )
            for ( i = 1 ; i < degree ; ++i ) {
               j = randInteger( i, degree);
               EXCHANGE( conjugatingPerm->image[i], conjugatingPerm->image[j], temp);
            }
         else
            setToRandomMonomialPerm( conjugatingPerm, degree, C->field);
      else 
         if ( !monomialFlag ) {
            for ( i = 1 ; i < nRows ; ++i ) {
               j = randInteger( i, nRows);
               EXCHANGE( conjugatingPerm->image[i], conjugatingPerm->image[j], temp);
            }
            for ( i = nRows+1 ; i < degree ; ++i ) {
               j = randInteger( i, degree);
               EXCHANGE( conjugatingPerm->image[i], conjugatingPerm->image[j], temp);
            }
         }
         else
            setToRandomMonomialPerm( conjugatingPerm, nRows*(matrix->setSize-1), 
                                     matrix->field);
      conjugatingPerm->invImage = NULL;
      adjoinInvImage( conjugatingPerm);
   }

   /* Conjugate the object, write out conjugated object, and close its file. */
   switch ( objectType ) {
      case POINT_SET:
         strcpy( originalInputName, Lambda->name);
         for ( i = 1 ; i <= Lambda->size ; ++i )
            Lambda->pointList[i] =
                  conjugatingPerm->image[Lambda->pointList[i]];
         if ( cjperFlag )
            sprintf( comment, "%s conjugated by %s.", Lambda->name,
                                                      conjugatingPerm->name);
         else if ( permGroupFileName[0] )
            sprintf( comment, "%s conjugated by a random permutation "
                              "from group %s.", Lambda->name, G->name);
         else
            sprintf( comment, "%s conjugated by a random permutation.",
                              Lambda->name);
         strcpy( Lambda->name, outputObjectName);
         writePointSet( outputFileName, outputLibraryName, comment, Lambda);
         break;
      case PARTITION:
         /* Temporarily we use the invPointList field for another purpose.
            It will be restored below. */
         strcpy( originalInputName, partn->name);
         newCellNumber = partn->invPointList;
         for ( i = 1 ; i <= degree ; ++i )
            newCellNumber[conjugatingPerm->image[partn->pointList[i]]] =
               partn->cellNumber[partn->pointList[i]];
         for ( i = 1 ; i <= degree ; ++i )
            partn->cellNumber[i] = newCellNumber[i];
         for ( i = 1 ; i <= degree ; ++i )
            partn->pointList[i] = conjugatingPerm->image[partn->pointList[i]];
         for ( i = 1 ; i <= degree ; ++i )
            partn->invPointList[partn->pointList[i]] = i;
         if ( cjperFlag )
            sprintf( comment, "%s conjugated by %s.", partn->name,
                                                      conjugatingPerm->name);
         else if ( permGroupFileName[0] )
            sprintf( comment, "%s conjugated by a random permutation "
                              "from group %s.", partn->name, G->name);
         else
            sprintf( comment, "%s conjugated by a random permutation.",
                              partn->name);
         strcpy( partn->name, outputObjectName);
         writePartition( outputFileName, outputLibraryName, comment, partn);
         break;
      case PERMUTATION:
         strcpy( originalInputName, s->name);
         t = newUndefinedPerm( degree);
         t->degree = degree;
         for ( i = 1 ; i <= degree ; ++i )
            t->image[conjugatingPerm->image[i]] =
                 conjugatingPerm->image[s->image[i]];
         if ( cjperFlag )
            sprintf( comment, "%s conjugated by %s.", s->name,
                                                      conjugatingPerm->name);
         else if ( permGroupFileName[0] )
            sprintf( comment, "%s conjugated by a random permutation "
                              "from group %s.", s->name, G->name);
         else
            sprintf( comment, "%s conjugated by a random permutation.",
                              s->name);
         strcpy( t->name, outputObjectName);
         if ( imageFormatFlag )
            writePermutation( outputFileName, outputLibraryName, t, "image",
                              comment);
         else
            writePermutation( outputFileName, outputLibraryName, t, "",
                              comment);
         break;
      case PERM_GROUP:
         strcpy( originalInputName, H->name);
         HConjugated = copyOfPermGroup( H);
         for ( gen = H->generator , genConj = HConjugated->generator ;
               gen ; gen = gen->next , genConj = genConj->next )
            for ( i = 1 ; i <= degree ; ++i )
               genConj->image[conjugatingPerm->image[i]] =
                    conjugatingPerm->image[gen->image[i]];
         if ( H->base )
            for ( i = 1 ; i <= H->baseSize ; ++i )
               HConjugated->base[i] = conjugatingPerm->image[H->base[i]];
         if ( cjperFlag )
            sprintf( comment, "%s conjugated by %s.", H->name,
                                                      conjugatingPerm->name);
         else if ( permGroupFileName[0] )
            sprintf( comment, "%s conjugated by a random permutation "
                              "from group %s.", H->name, G->name);
         else
            sprintf( comment, "%s conjugated by a random permutation.",
                              H->name);
         strcpy( HConjugated->name, outputObjectName);
         HConjugated->printFormat = imageFormatFlag ? imageFormat : cycleFormat;
         nameGenerators( HConjugated, options.genNamePrefix);
         writePermGroup( outputFileName, outputLibraryName, HConjugated, comment);
         break;
      case DESIGN:
      case MATRIX_01:
         strcpy( originalInputName, matrix->name);
         matrixConjugated = newZeroMatrix( matrix->setSize, nRows, nCols);
         if ( !monomialFlag )
            for ( i = 1 ; i <= nRows ; ++i )
               for ( j = 1 ; j <= nCols ; ++j )
                  matrixConjugated->entry[conjugatingPerm->image[i]]
                                      [conjugatingPerm->image[j+nRows]-nRows] =
                                                         matrix->entry[i][j];
         else {
            fSize = matrix->setSize - 1;
            for ( i = 1 ; i <= nRows ; ++i ) {
               /* Find k, lambda such that 1*i is mapped to lambda*k. */
               k = (conjugatingPerm->image[fSize*(i-1)+1]-1) / fSize + 1;
               lambda = (conjugatingPerm->image[fSize*(i-1)+1]-1) % fSize + 1;
               for ( j = 1 ; j <= nCols ; ++j ) {
                  /* Find m, mu such that 1*j is mapped to mu*m. */
                  m = (conjugatingPerm->image[fSize*(nRows+j-1)+1]-1) / fSize + 1 - 
                                                            nRows;
                  mu = (conjugatingPerm->image[fSize*(nRows+j-1)+1]-1) % fSize + 1;
                  tau = matrix->field->prod[lambda][mu];
                  matrixConjugated->entry[k][m] =
                         matrix->field->prod[tau][matrix->entry[i][j]];
               }
            }
         }
         if ( cjperFlag )
            sprintf( comment, "%s conjugated by %s.", matrix->name,
                                                      conjugatingPerm->name);
         else if ( permGroupFileName[0] )
            sprintf( comment, "%s conjugated by a random permutation "
                              "from group %s.", matrix->name, G->name);
         else if ( (objectType == MATRIX_01 && monomialFlag) )
            sprintf( comment, "%s conjugated by a random monomial permutation.",
                              matrix->name);
         else
            sprintf( comment, "%s conjugated by a random permutation.",
                              matrix->name);
         strcpy( matrixConjugated->name, outputObjectName);
         if ( objectType == DESIGN )
            writeDesign( outputFileName, outputLibraryName, matrixConjugated,
                         comment);
         else
            write01Matrix( outputFileName, outputLibraryName, matrixConjugated,
                         FALSE, comment);
         break;
      case BINARY_CODE:
         strcpy( originalInputName, C->name);
         CConjugated = (Code *) newZeroMatrix( C->fieldSize, C->dimension, C->length);
         if ( C->fieldSize == 2 )
            for ( j = 1 ; j <= C->length ; ++j )
               for ( i = 1 ; i <= C->dimension ; ++i )
                  CConjugated->basis[i][conjugatingPerm->image[j]] =
                                                          C->basis[i][j];
         else {
            fSize = C->fieldSize - 1;
            for ( j = 1 ; j <= C->length ; ++j ) {
               /* Find m, mu such that 1*j is mapped to mu*m. */
               m = (conjugatingPerm->image[fSize*(j-1)+1]-1) / fSize + 1;
               mu = (conjugatingPerm->image[fSize*(j-1)+1]-1) % fSize + 1;
               for ( i = 1 ; i <= C->dimension ; ++i )
                  CConjugated->basis[i][m] =
                                     C->field->prod[mu][C->basis[i][j]];
            }
         }
         if ( cjperFlag )
            sprintf( comment, "%s conjugated by %s.", C->name,
                                                      conjugatingPerm->name);
         else if ( permGroupFileName[0] )
            sprintf( comment, "%s conjugated by a random permutation "
                              "from group %s.", C->name, G->name);
         else if ( C->fieldSize > 2 )
            sprintf( comment, "%s conjugated by a random monomial permutation.",
                              C->name);
         else
            sprintf( comment, "%s conjugated by a random permutation.",
                              C->name);
         strcpy( CConjugated->name, outputObjectName);
         writeCode( outputFileName, outputLibraryName, CConjugated, comment);
         break;
   }

   /* Write out the conjugating permutation, if requested, and close its file. */
   if ( !cjperFlag && permFileName[0] ) {
      if ( (objectType == MATRIX_01 && monomialFlag) ||
           (objectType == BINARY_CODE && C->fieldSize > 2) )
         sprintf( comment, "A monomial permutation mapping %s to %s.", 
                  originalInputName, outputObjectName);
      else if ( objectType != PERM_GROUP && 
                objectType != PERMUTATION )
         sprintf( comment, "A permutation mapping %s to %s.", 
                  originalInputName, outputObjectName);
      else
         sprintf( comment, "A permutation conjugating %s to %s.", 
                  originalInputName, outputObjectName);
      if ( imageFormatFlag )
         writePermutation( permFileName, permLibraryName, conjugatingPerm,
                           "image", comment);
      else
         writePermutation( permFileName, permLibraryName, conjugatingPerm,
                           "", comment);
   }

   /* Terminate. */
   return 0;
}


/*--------------------------- setToRandomMonomialPerm ---------------------*/

static void setToRandomMonomialPerm(
   Permutation *const perm,               /* Must start as identity. */
   const Unsigned subDegree,
   const Field *const field)
{
   Unsigned i, j, k, delta, lambda, temp, m, mu;
   const Unsigned fSize = field->size - 1;
   const degree = perm->degree;

   for ( i = 1 ; i <= degree ; i += fSize ) {
      j = randInteger( i, (i <= subDegree) ? subDegree : degree);
      delta = 0;
      for ( k = 0 ; k < fSize ; ++k ) {
         EXCHANGE( perm->image[i+k], 
                   perm->image[j+k-delta], temp);
         if ( (j+k) % fSize == 0 )
            delta = fSize;
      }
      /* Find mu, m such that perm->image[i] = mu*m. 
         Then perm->image[lambda*i] = (lambda*mu)*m. */
      m = (perm->image[i] - 1 ) / fSize + 1;
      mu = (perm->image[i] - 1 ) % fSize + 1;
      for ( lambda = 2 ; lambda < field->size ; ++lambda )
         perm->image[i+lambda-1] = 
                           fSize*(m-1) + field->prod[lambda][mu];
   }
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
   extern void xfield ( CompileOptions *cOpts);
   extern void xnew   ( CompileOptions *cOpts);
   extern void xoldcop( CompileOptions *cOpts);
   extern void xpermgr( CompileOptions *cOpts);
   extern void xpermut( CompileOptions *cOpts);
   extern void xprimes( CompileOptions *cOpts);
   extern void xrandgr( CompileOptions *cOpts);
   extern void xrandsc( CompileOptions *cOpts);
   extern void xreadde( CompileOptions *cOpts);
   extern void xreadgr( CompileOptions *cOpts);
   extern void xreadpa( CompileOptions *cOpts);
   extern void xreadpe( CompileOptions *cOpts);
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
   xfield ( &mainOpts);
   xnew   ( &mainOpts);
   xoldcop( &mainOpts);
   xpermgr( &mainOpts);
   xpermut( &mainOpts);
   xprimes( &mainOpts);
   xrandgr( &mainOpts);
   xrandsc( &mainOpts);
   xreadde( &mainOpts);
   xreadgr( &mainOpts);
   xreadpa( &mainOpts);
   xreadpe( &mainOpts);
   xreadpt( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}
