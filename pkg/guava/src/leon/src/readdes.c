/* File readdes.c.  Contains routines to read and write block designs. */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "group.h"
#include "groupio.h"

#include "code.h"
#include "field.h"
#include "errmesg.h"
#include "new.h"
#include "token.h"

CHECK( readde)

extern GroupOptions options;

static Matrix_01 *xRead01Matrix(
   FILE *libFile,
   char *name,
   BOOLEAN transposeFlag,
   Unsigned requiredSetSize,
   Unsigned requiredNumberOfRows,
   Unsigned requiredNumberOfCols);


/*-------------------------- readDesign -----------------------------------*/

/* This function reads in a block design and returns an (0,1)-matrix which
   is the incidence matrix of the design.  Rows correspond to points and
   columns to blocks.  Row and column numbering starts at 1.  NOTE THAT
   THE STORAGE MANAGER IS NOT INITIALIZED. */

Matrix_01 *readDesign(
   char *libFileName,
   char *libName,
   Unsigned requiredPointCount,       /* 0 = any */
   Unsigned requiredBlockCount)       /* 0 = any */
{
   Unsigned pt, nRows, nCols;
   Matrix_01 *matrix;
   Token token, saveToken;
   char inputBuffer[81];
   FILE *libFile;
   Unsigned j;
   char matrixName[MAX_NAME_LENGTH+1];

   /* Open input file. */
   libFile = fopen( libFileName, "r");
   if ( libFile == NULL )
      ERROR1s( "readDesign", "File ", libFileName,
               " could not be opened for input.")

   /* Initialize input routines to correct file. */
   setInputFile( libFile);
   lowerCase( libName);

   /* Search for the correct library.  Terminate with error message if
      not found. */
   rewind( libFile);
   for (;;) {
      fgets( inputBuffer, 80, libFile);
      if ( feof(libFile) )
         ERROR1s( "readDesign", "Library block ", libName,
                  " not found in specified library.")
      if ( inputBuffer[0] == 'l' || inputBuffer[0] == 'L' ) {
         setInputString( inputBuffer);
         if ( ( (token = sReadToken()) , token.type == identifier &&
                strcmp(lowerCase(token.value.identValue),"library") == 0 )
              &&
              ( (token = sReadToken()) , token.type == identifier &&
                strcmp(lowerCase(token.value.identValue),libName) == 0 ) )
            break;
      }
   }

   /* Read the design name. */
   if ( (token = nkReadToken() , saveToken = token , token.type == identifier) &&
         (token = nkReadToken() , token.type == equal) )
      strcpy( matrixName, saveToken.value.identValue);

   if ( (token = readToken() , token.type != identifier) ||
             strcmp( token.value.identValue, "seq") != 0 ||
             (token = readToken() , token.type != leftParen) )
      ERROR( "readDesign", "Invalid syntax in design library.")

   /* Read the number of points and number of blocks. */
   if ( (token = readToken() , token.type != integer) ||
        (nRows = token.value.intValue) < 2 ||
        ( requiredPointCount != 0 && nRows != requiredPointCount ) ||
        (token = readToken() , token.type != comma) ||
        (token = readToken() , token.type != integer) ||
        (nCols= token.value.intValue) < 2 ||
        ( requiredBlockCount != 0 && nCols != requiredBlockCount ) ||
        (token = readToken() , token.type != comma) )
      ERROR( "readDesign", "Invalid syntax in design library.")
   if ( nRows + nCols > options.maxDegree )
      ERROR( "readDesign", "Too many rows+columns.")

   /* Allocate the (0,1) incidence matrix, and zero it. */
   matrix = newZeroMatrix( 2, nRows, nCols);
   strcpy( matrix->name, matrixName);

   /* Read the blocks. */
   for ( j = 1 ; j <= nCols ; ++j ) {
      if ( token = readToken() , token.type != leftBracket )
         ERROR( "readDesign", "Invalid symbol in point list.")
      while  (token = readToken() , token.type == integer ||
                                    token.type == comma )
         if ( token.type == integer && (pt = token.value.intValue) > 0 &&
                                       pt <= nRows )
            matrix->entry[pt][j] = 1;
         else if ( token.type == integer )
            ERROR1i( "readDesign", "Invalid point ", pt, ".")
      if ( token.type != rightBracket || (token = readToken() ,
               (j < nCols ? token.type != comma : token.type != rightParen)) )
         ERROR( "readDesign", "Invalid symbol in point list.")
   }

   /* Close the input file and return. */
   fclose( libFile);
   return matrix;
}


/*-------------------------- writeDesign ----------------------------------*/

/* This function writes out an (0,1) matrix as a block design.  Rows
   correspond to points and columns to blocks.  Row and column numbering
   starts at 1. */

void writeDesign(
   char *libFileName,
   char *libName,
   Matrix_01 *matrix,
   char *comment)
{
   Unsigned i, j, column, leadChar;
   FILE *libFile;

   /* Open output file. */
   libFile = fopen( libFileName, options.outputFileMode);
   if ( libFile == NULL )
      ERROR1s( "writeDesign", "File ", libFileName,
               " could not be opened for output.")

   /* Write the library name. */
   fprintf( libFile, "LIBRARY %s;\n", libName);

   /* Write the comment. */
   if ( comment )
      fprintf( libFile, "& %s &\n", comment);

   /* Write the matrix name. */
   if ( !matrix->name[0] )
      strcpy( matrix->name, "D");
   fprintf( libFile, " %s = seq(", matrix->name);

   /* Write the numbers of points and blocks. */
   fprintf( libFile, " %d, %d,", matrix->numberOfRows, matrix ->numberOfCols);

   /* For j = 1,2,.., write the j'th block. */
   for ( j = 1 ; j <= matrix->numberOfCols ; ++j) {
      fprintf( libFile, "\n    ");
      column = 5;
      leadChar = '[';
      for ( i = 1 ; i <= matrix->numberOfRows ; ++i )
         if ( matrix->entry[i][j] != 0 ) {
            column += fprintf( libFile, "%c", leadChar);
            if (column > 73 ) {
               fprintf( libFile, "\n      ");
               column = 7;
            }
            column += fprintf( libFile, "%d", i);
            leadChar = ',';
         }
      fprintf( libFile, "]");
      if ( j < matrix->numberOfCols )
         fprintf( libFile, ",");
   }

   /* Write terminators. */
   fprintf( libFile, ");\nFINISH;\n");

   /* Close output file. */
   fclose( libFile);
}


/*-------------------------- read01Matrix ---------------------------------*/

/* This function reads in an (0,1)-matrix and returns a new matrix equal
   to that read in.  NOTE THAT THE STORAGE MANAGER IS NOT INITIALIZED. */

Matrix_01 *read01Matrix(
   char *libFileName,
   char *libName,
   BOOLEAN transposeFlag,                /* If true, matrix is transposed. */
   BOOLEAN adjoinIdentity,               /* If true, form (A|I), A = matrix read. */
   Unsigned requiredSetSize,             /* 0 = any */
   Unsigned requiredNumberOfRows,        /* 0 = any */
   Unsigned requiredNumberOfCols)        /* 0 = any */
{
   Unsigned  nRows, nCols, setSize;
   Matrix_01 *matrix;
   Token token, saveToken;
   char inputBuffer[81];
   FILE *libFile;
   Unsigned i, j, temp;
   char matrixName[MAX_NAME_LENGTH+1], str[100];
   BOOLEAN firstIdent;

   /* Open input file. */
   libFile = fopen( libFileName, "r");
   if ( libFile == NULL )
      ERROR1s( "read01Matrix", "File ", libFileName,
               " could not be opened for input.")

   /* Initialize input routines to correct file. */
   setInputFile( libFile);
   lowerCase( libName);

   /* Search for the correct library.  Terminate with error message if
      not found. */
   rewind( libFile);
   firstIdent = TRUE;
   for (;;) {
      fgets( inputBuffer, 80, libFile);
      if ( feof(libFile) )
         ERROR1s( "read01Matrix", "Library block ", libName,
                  " not found in specified library.")
      if ( firstIdent && sscanf( inputBuffer, "%s", str) == 1 &&
           (firstIdent = FALSE , strcmp( lowerCase(str), "library") != 0) )
              return xRead01Matrix( libFile, str, transposeFlag, requiredSetSize,
                             requiredNumberOfRows, requiredNumberOfCols);
      if ( inputBuffer[0] == 'l' || inputBuffer[0] == 'L' ) {
         setInputString( inputBuffer);
         if ( ( (token = sReadToken()) , token.type == identifier &&
                strcmp(lowerCase(token.value.identValue),"library") == 0 )
              &&
              ( (token = sReadToken()) , token.type == identifier &&
                strcmp(lowerCase(token.value.identValue),libName) == 0 ) )
            break;
      }
   }

   /* Read the matrix name. */
   if ( (token = nkReadToken() , saveToken = token , token.type == identifier) &&
         (token = nkReadToken() , token.type == equal) )
      strcpy( matrixName, saveToken.value.identValue);

   if ( (token = readToken() , token.type != identifier) ||
             strcmp( token.value.identValue, "seq") != 0 ||
             (token = readToken() , token.type != leftParen) )
      ERROR( "read01Matrix", "Invalid syntax in matrix library.")

   /* Read the field or set size, the number of rows, and number of columns, 
      and exchange numbers if matrix is to be transposed. */
   if ( (token = readToken() , token.type != integer) ||
        (setSize = token.value.intValue) < 1 ||
        (token = readToken() , token.type != comma) ||
        (token = readToken() , token.type != integer) ||
        (nRows = token.value.intValue) < 1 ||
        (token = readToken() , token.type != comma) ||
        (token = readToken() , token.type != integer) ||
        (nCols= token.value.intValue) < 1 ||
        (token = readToken() , token.type != comma) )
      ERROR( "read01Matrix", "Invalid syntax in matrix library.")
   if ( transposeFlag )
      EXCHANGE( nRows, nCols, temp)
   if ( nRows + nCols + adjoinIdentity * nRows> options.maxDegree )
      ERROR( "read01Matrix", "Too many rows+columns.")
   if ( requiredSetSize != 0 && setSize != requiredSetSize )
      ERROR1s( "read01Matrix", "Matrix ", matrixName, 
               " has the wrong set/field size.")
   if ( requiredNumberOfRows != 0 && nRows != requiredNumberOfRows )
      ERROR1s( "read01Matrix", "Matrix ", matrixName, 
               " has the wrong number of rows.")
   if ( requiredNumberOfCols != 0 && nCols != requiredNumberOfCols )
      ERROR1s( "read01Matrix", "Matrix ", matrixName, 
               " has the wrong number of columns.")

   /* Allocate the (0,1) incidence matrix, and zero it. */
   matrix = newZeroMatrix( setSize, nRows, nCols + adjoinIdentity * nRows);
   strcpy( matrix->name, matrixName);
   if ( adjoinIdentity )
      for ( i = 1 ; i <= nRows ; ++i )
         matrix->entry[i][nCols+i] = 1;

   /* Read the entries of the matrix in row-major order. */
   if ( (token = readToken() , token.type != identifier) ||
        strcmp( token.value.identValue, "seq") != 0 ||
        (token = readToken() , token.type != leftParen) )
      ERROR( "read01Matrix", "Invalid syntax at start of matrix entries.")
   if ( !transposeFlag )
      for ( i = 1 ; i <= nRows ; ++i )
         for ( j = 1 ; j <= nCols ; ++j ) {
            while ( token = readToken() , token.type == comma )
               ;
            if ( token.type != integer || token.value.intValue < 0 ||
                                          token.value.intValue >= matrix->setSize )
               ERROR( "read01Matrix", "Invalid syntax in matrix entries.")
            matrix->entry[i][j] = token.value.intValue;
         }
   else
      for ( i = 1 ; i <= nCols ; ++i )
         for ( j = 1 ; j <= nRows ; ++j ) {
            while ( token = readToken() , token.type == comma )
               ;
            if ( token.type != integer || token.value.intValue < 0 ||
                                          token.value.intValue >= matrix->setSize )
               ERROR( "read01Matrix", "Invalid syntax in matrix entries.")
            matrix->entry[j][i] = token.value.intValue;
         }

   /* Check for proper closing. */
   if ( (token = readToken() , token.type != rightParen) ||
        (token = readToken() , token.type != rightParen) ||
        (token = readToken() , token.type != semicolon) )
      ERROR( "read01Matrix", "Invalid syntax at end of matrix entries.")

   /* Close the input file and return. */
   fclose( libFile);
   return matrix;
}


/*-------------------------- xRead01Matrix --------------------------------*/

/* This function reads in an (0,1)-matrix in the alternate format and returns 
   a new matrix equal to that read in.  It is called only by read01Matrix.
   NOTE THAT THE STORAGE MANAGER IS NOT INITIALIZED. */

static Matrix_01 *xRead01Matrix(
   FILE *libFile,
   char *name,
   BOOLEAN transposeFlag,            /* If true, matrix is transposed. */
   Unsigned requiredSetSize,         /* 0 = any */
   Unsigned requiredNumberOfRows,    /* 0 = any */
   Unsigned requiredNumberOfCols)    /* 0 = any */
{
   Unsigned  nRows, nCols, setSize;
   Matrix_01 *matrix;
   Unsigned i, j, temp;
   int symbol, maxSymbol;

   /* Read the field or set size, the number of rows, and number of columns, 
      and exchange numbers if matrix is to be transposed. */
   if ( fscanf( libFile, "%d %d %d", &setSize, &nRows, &nCols) != 3 )
      ERROR( "xRead01Matrix", "Invalid syntax set size, rows count, or col count")
   if ( (requiredSetSize != 0 && setSize != requiredSetSize) ||
           nRows < 1 ||
           (requiredNumberOfRows != 0 && nRows != requiredNumberOfRows) ||
           nCols < 1 ||
           (requiredNumberOfCols != 0 && nCols != requiredNumberOfCols) )
      ERROR( "xRead01Matrix", "Invalid syntax in matrix library.")
   if ( nRows + nCols > options.maxDegree )
      ERROR( "xRead01Matrix", "Too many rows+columns.")
   if ( transposeFlag )
      EXCHANGE( nRows, nCols, temp)

   /* Allocate the (0,1) incidence matrix, and zero it. */
   matrix = newZeroMatrix( setSize, nRows, nCols);
   if ( strlen(name) > MAX_NAME_LENGTH )
      ERROR1i( "xRead01Matrix", "Name for code exceeds maximum of ",
               MAX_NAME_LENGTH, " characters.")
   strcpy( matrix->name, name);

   /* Read the entries of the matrix in row-major order. */
   maxSymbol = '0' + setSize - 1;
   if ( !transposeFlag )
      for ( i = 1 ; i <= nRows ; ++i )
         for ( j = 1 ; j <= nCols ; ++j ) {
            while ( (symbol = getc(libFile)) == ' ' || symbol == ','  || symbol == '\n' )
               ;
            if ( symbol < '0' && symbol > maxSymbol )
               if ( symbol == EOF )
                  ERROR( "xRead01Matrix", "Premature end of file.")
               else
                  ERROR( "xRead01Matrix", "Invalid symbol in matrix entries.")
            matrix->entry[i][j] = symbol - '0';
         }
   else
      for ( i = 1 ; i <= nCols ; ++i )
         for ( j = 1 ; j <= nRows ; ++j ) {
            while ( (symbol = getc(libFile)) == ' ' || symbol == ',' || symbol == '\n' )
               ;
            if ( symbol < '0' && symbol > maxSymbol )
               if ( symbol == EOF )
                  ERROR( "xRead01Matrix", "Premature end of file.")
               else
                  ERROR( "xRead01Matrix", "Invalid symbol in matrix entries.")
            matrix->entry[j][i] = symbol - '0';
         }

   /* Close the input file and return. */
   fclose( libFile);
   return matrix;
}


/*-------------------------- write01Matrix --------------------------------*/

/* This function writes out an (0,1) matrix.  The entries are written in
   row-major order. */

void write01Matrix(
   char *libFileName,
   char *libName,
   Matrix_01 *matrix,
   BOOLEAN transposeFlag,
   char *comment)
{
   Unsigned i, j, column,
     outputRows = (transposeFlag) ? matrix->numberOfCols : matrix->numberOfRows,
     outputCols = (transposeFlag) ? matrix->numberOfRows : matrix->numberOfCols;
   FILE *libFile;

   /* Open output file. */
   libFile = fopen( libFileName, options.outputFileMode);
   if ( libFile == NULL )
      ERROR1s( "write01Matrix", "File ", libFileName,
               " could not be opened for output.")

   /* Write the library name. */
   fprintf( libFile, "LIBRARY %s;\n", libName);

   /* Write the comment. */
   if ( comment )
      fprintf( libFile, "& %s &\n", comment);

   /* Write the matrix name. */
   if ( !matrix->name[0] )
      strcpy( matrix->name, "M");
   fprintf( libFile, " %s = seq(", matrix->name);

   /* Write the set size and numbers of rows and columns and "seq(". */
   fprintf( libFile, " %d, %d, %d, seq(", matrix->setSize, outputRows, 
                                          outputCols);

   /* For i = 1,2,..,nRows write the i'th block. */
   for ( i = 1 ; i <= outputRows ; ++i) {
      fprintf( libFile, "\n    ");
      column = 5;
      for ( j = 1 ; j <= outputCols ; ++j ) {
         if ( column > 75 ) {
            fprintf( libFile, "\n     ");
            column = 6;
         }
         column += transposeFlag ?
                      fprintf( libFile, "%d", matrix->entry[j][i]) :
                      fprintf( libFile, "%d", matrix->entry[i][j]);
         if ( i < outputRows || j < outputCols )
            column += fprintf( libFile, ",");
      }
   }

   /* Write terminators. */
   fprintf( libFile, "));\nFINISH;\n");

   /* Close output file. */
   fclose( libFile);
}




/*-------------------------- readCode -------------------------------------*/

/* This function reads in a binary code and returns a new code equal
   to that read in.  NOTE THAT THE STORAGE MANAGER IS NOT INITIALIZED. */

Code *readCode(
   char *libFileName,
   char *libName,
   BOOLEAN reduceFlag,                   /* If true, gen matrix is reduced. */
   Unsigned requiredSetSize,             /* 0 = any */
   Unsigned requiredDimension,           /* 0 = any */
   Unsigned requiredLength)              /* 0 = any */
{
   Code *C;
   Matrix_01 *M;

   M = read01Matrix( libFileName, libName, FALSE, FALSE, requiredSetSize, 
                     requiredDimension, requiredLength);
   C = (Code *) M;
   C->infoSet = NULL;
   if ( C->fieldSize > 2 )
      C->field = buildField( C->fieldSize);
   if ( reduceFlag )
      reduceBasis( C);
   return C;
}


/*-------------------------- writeCode ------------------------------------*/

/* This function writes out a code.  The information set is not written. */

void writeCode(
   char *libFileName,
   char *libName,
   Code *C,
   char *comment)
{
   write01Matrix( libFileName, libName, (Matrix_01 *) C, FALSE, comment);
}

