/* File wtdist.c. */

/* Copyright (C) 1992 by Jeffrey S. Leon.  This software may be used freely
   for educational and research purposes.  Any other use requires permission
   from the author. */

/*  Highly optimized main program to compute weight distribution
   of a linear code  The command format is

      wtdist  <options>  <code>  <weightToSave>  <matrix>
   or
      wtdist  <options>  <code>

   where in the second case all vectors of weight <weightToSave> (except
   scalar multiples) are saved as a matrix whose rows are the vectors.  If 
   the -1 option is coded, only one vector of this weight is saved.  If there 
   are no vectors of the given weight, the matrix is not created.

   For most binary codes, bit string operations on vectors are used.  

   For nonbinary codes (and for binary codes whose parameters fail to meet
   certain constraints), several columns of each codeword are packed into a 
   single integer in order to make computations much faster, for large codes, 
   than would otherwise be possible.  The number of columns packed into a
   single integer is referred to as the "packing factor".  It may be
   specified explicitly by the -pf option (within limits) or allowed to
   default.  Optimal choice of the packing factor can improve performance 
  considerably.

   Let the code be an (n,k) code over GF(q), where q = p^e.  Let F(x) =
   a[0] + a[1]*x + ... + a[e]*x^e be the irreducible polynomial over
   GF(p) used to construct GF(q).  The elements of GF(q) are represented
   as integers in the range 0..q-1, where field element
   g[0] + g[1]*x + ... + g[e-1]*x^(e-1) is represented by the integer
   g[0] + g[1] * q + ... + g[e-1] * q^(e-1).

   Let P denote the packing factor.  In order to save space and time, up
   to P components of a vector over GF(q) are represented as a single
   integer in the range 0..(q^P-1).  Specifically, the sequence of
   components b[i],b[i+1],...,b[i+P-1] is represented by the integer
   b[i] + b[i+1] * q + ... + b[i+P-1] * q^(P-1).

   The integer representing a sequence of field elements (components) is
   referred to as a "packed field sequence".  The number of packed field
   sequences required to represent one codeword is called the "packed
   length" of the code; it equals ceil(n/P).  The set of columns of the
   code corresponding to a packed field sequence is referred to as a "packed column".

   The packing factor P must satisfy the constraints
                i)  P <= MaxPackingFactor,
               ii)  FieldSize ^ P - 1 <= MaxPackedInteger,
              iii)  ceil(n/P) <= MaxPackedLength,
   where MaxPackingFactor, MaxPackedInteger, and MaxPackedLength are
   symbolic constant (see above).

   In general, a large packing factor will increase memory requirements
   and will increase the time required to initialize various tables, but
   it will decrease the time required to compute the weight distribution,
   once initialization has been completed.  The largest single data
   structure contains  e * k * q^P * MaxPackedLength * r  bytes,
   where r is the number of bytes used to represent type
   0..MaxPackedInteger.

   In general, a relatively small packing factor (say 8 for binary codes)
   is indicated for codes of moderate size.  For large codes, a larger
   packing factor (say 12 for binary codes) leads to lower execution times,
   at the cost of a higher memory requirement.

   The user may specify the value of the packing factor in the input,
   subject to the limits specified above.  An input value of 0 will cause
   the program to choose a default value, which may not give as good
   performance as a user-specified value.
*/

/* Note: BINARY_CUTOFF_DIMENSION must be at least 3. */
#define BINARY_CUTOFF_DIMENSION 12
#define DEFAULT_INIT_ALLOC_SIZE 10000

#include <stddef.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#ifdef HUGE
#include <alloc.h>
#endif

#define MAIN

#include "group.h"
#include "groupio.h"

#include "errmesg.h"
#include "field.h"
#include "readdes.h"
#include "storage.h"
#include "token.h"
#include "util.h"

GroupOptions options;

static void verifyOptions(void);

static void binaryWeightDist(
   const Code *const C,
   const Unsigned saveWeight,
   const BOOLEAN oneCodeWordOnly,
   Unsigned *const allocatedSize,
   unsigned long *const freq,
   Matrix_01 *const matrix);

static void generalWeightDist(
   const Code *const C,
   Unsigned saveWeight,
   const BOOLEAN oneCodeWordOnly,
   const Unsigned packingFactor,
   const Unsigned largestPackedInteger,
   const Unsigned packedLength,
   Unsigned *const allocatedSize,
   unsigned long *const freq,
   Matrix_01 *matrix);

static void binaryCosetWeightDist(
   const Code *const C,
   const Unsigned maxCosetWeight,
   const BOOLEAN oneCodeWordOnly,
   const Unsigned passes,
   Unsigned *const allocatedSize,
   unsigned long *const freq,
   Matrix_01 *const matrix);


int main( int argc, char *argv[])
{
   char codeFileName[MAX_FILE_NAME_LENGTH] = "",
        matrixFileName[MAX_FILE_NAME_LENGTH] = "";
   Unsigned i, j, temp, optionCountPlus1, packingFactor, packedLength,
            largestPackedInteger, saveWeight, allocatedSize,
            maxCosetWeight, passes;
   char matrixObjectName[MAX_NAME_LENGTH+1] = "",
        codeLibraryName[MAX_NAME_LENGTH+1] = "",
        matrixLibraryName[MAX_NAME_LENGTH+1] = "",
        prefix[MAX_FILE_NAME_LENGTH],
        suffix[MAX_NAME_LENGTH];
   Code *C;
   Matrix_01 *matrix;
   BOOLEAN saveCodeWords, oneCodeWordOnly, defaultForBinaryProcedure,
           useBinaryProcedure, cWtDistFlag;
   char comment[100];
   unsigned long *freq = malloc( (MAX_CODE_LENGTH+2) * sizeof(unsigned long));

   /* Provide help if no arguments are specified. */
   if ( argc == 1 ) {
      printf( "\nUsage:  wtdist [options] code [saveWeight matrix]\n");
      return 0;
   }

   /* Check for limits option.  If present in position 1, give limits and
      return. */
   if ( strcmp(argv[1], "-l") == 0 || strcmp(argv[1], "-L") == 0 ) {
      showLimits();
      return 0;
   }

   /* Check for verify option.  If present in position 1, perform verify (Note
      verifyOptions terminates program). */
   if ( strcmp(argv[1], "-v") == 0 || strcmp(argv[1], "-V") == 0 )
      verifyOptions();

   /* Check for exactly 1 or 3 parameters following options. */
   for ( optionCountPlus1 = 1 ; optionCountPlus1 < argc &&
              argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
      ;

   if ( argc - optionCountPlus1 < 1 && argc - optionCountPlus1 > 3 ) {
      ERROR( "main (wtdist)",
             "1, 2 or 3 non-option parameters are required.");
      exit(ERROR_RETURN_CODE);
   }
   saveCodeWords = (argc - optionCountPlus1 == 3);

   /* Process options. */
   prefix[0] = '\0';
   suffix[0] = '\0';
   options.inform = TRUE;
   packingFactor = 0;
   cWtDistFlag = FALSE;
   oneCodeWordOnly = FALSE;
   defaultForBinaryProcedure = TRUE;
   allocatedSize = 0;
   parseLibraryName( argv[optionCountPlus1+2], "", "", matrixFileName,
                     matrixLibraryName);
   strncpy( options.genNamePrefix, matrixLibraryName, 4);
   options.genNamePrefix[4] = '\0';
   strcpy( options.outputFileMode, "w");

   /* Retrieve command-line options. */
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
      errno = 0;
      if ( strcmp( argv[i], "-a") == 0 )
         strcpy( options.outputFileMode, "a");
      else if ( strcmp( argv[i], "-cwtdist") == 0 ) {
         cWtDistFlag = TRUE;
      }
      else if ( strncmp( argv[i], "-p:", 3) == 0 ) {
         strcpy( prefix, argv[i]+3);
      }
      else if ( strncmp( argv[i], "-t:", 3) == 0 ) {
         strcpy( suffix, argv[i]+3);
      }
      else if ( strncmp( argv[i], "-n:", 3) == 0 )
         if ( isValidName( argv[i]+3) )
            strcpy( matrixObjectName, argv[i]+3);
         else
            ERROR1s( "main (wtdist)", "Invalid name ", matrixObjectName,
                     " for codewords to be saved.")
      else if ( strcmp( argv[i], "-q") == 0 )
         options.inform = FALSE;
      else if ( strcmp( argv[i], "-overwrite") == 0 )
         strcpy( options.outputFileMode, "w");
      else if ( strcmp( argv[i], "-b") == 0 ) {
         defaultForBinaryProcedure = FALSE;
         useBinaryProcedure = TRUE;
      }
      else if ( strcmp( argv[i], "-g") == 0 ) {
         defaultForBinaryProcedure = FALSE;
         useBinaryProcedure = FALSE;
      }
      else if ( strncmp( argv[i], "-pf:", 4) == 0 ) {
         errno = 0;
         packingFactor = (Unsigned) strtol(argv[i]+4,NULL,0);
         if ( errno )
            ERROR( "main (wtdist)", "Invalid syntax for -pf option")
      }
      else if ( strncmp( argv[i], "-s:", 3) == 0 ) {
         errno = 0;
         allocatedSize = (Unsigned) strtol(argv[i]+3,NULL,0);
         if ( errno )
            ERROR( "main (wtdist)", "Invalid syntax for -s option")
      }
      else if ( strcmp( argv[i], "-1") == 0 )
         oneCodeWordOnly = TRUE;
      else
         ERROR1s( "main (compute subgroup)", "Invalid option ", argv[i], ".")
   }

   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   if ( cWtDistFlag )
      maxCosetWeight = saveWeight;

   /* Compute names for files and name for matrix of codewords saved.  Also
      determine weight of codewords to save. */
   parseLibraryName( argv[optionCountPlus1], prefix, suffix,
                     codeFileName, codeLibraryName);
   if ( saveCodeWords ) {
      errno = 0;
      saveWeight = (Unsigned) strtol(argv[optionCountPlus1+1], NULL, 0);
      if ( errno )
         ERROR( "main (wtdist)", "Invalid syntax weight to save.")
      parseLibraryName( argv[optionCountPlus1+2], prefix, suffix,
                        matrixFileName, matrixLibraryName);
      if ( matrixObjectName[0] == '\0' )
         strncpy( matrixObjectName, matrixLibraryName, MAX_NAME_LENGTH+1);
   }
   else
      saveWeight = UNKNOWN;

   /* Read in the code. */
   C = readCode( codeFileName, codeLibraryName, TRUE, 0, 0, 0);

   /* Partially allocate matrix for saving codewords.  Compute initial
      allocatedSize, unless specified as input. */
   if ( saveCodeWords ) {
      if ( allocatedSize == 0 )
         allocatedSize = DEFAULT_INIT_ALLOC_SIZE;
      matrix = (Matrix_01 *) malloc( sizeof(Matrix_01) );
      if ( !matrix )
         ERROR( "main (wtdist)", "Out of memory.")
      matrix->unused = NULL;
      matrix->field = NULL;
      matrix->entry = (FieldElement **) malloc( sizeof(FieldElement *) *
                                                (allocatedSize+2) );
      if ( !matrix->entry )
         ERROR( "main (wtdist)", "Out of memory.")
      matrix->setSize = C->fieldSize;
      matrix->numberOfRows = 0;
      matrix->numberOfCols = C->length;
   }

#ifdef xxxxxx
   /* If a coset weight distribution is requested, check the size limits,
      call cosetWeightDist if ok, and return. */
   if ( cWtDistFlag ) {
      if ( C->fieldSize != 2 || C->length > 128 || C->length - C->dimension > 32 )
         ERROR( "main (wtdist)", 
           "Coset weight dist requires binary code, length <= 128, codimension <= 32.")
      binaryCosetWeightDist( C, maxCosetWeight, oneCodeWordOnly, passes, &allocatedSize, 
                             matrix);
      return 0;
   }
#endif

   /* Decide whether to use binary or general procedure.  The general 
      procedure is used on binary codes of small dimension. */
   if ( defaultForBinaryProcedure )
      useBinaryProcedure &= (C->fieldSize == 2 &&
                            C->length <= 128 &&
                            C->dimension > BINARY_CUTOFF_DIMENSION);
   else if ( useBinaryProcedure && (C->fieldSize != 2 || C->length > 128 ||
                                    C->dimension <= 3) ) {
      useBinaryProcedure = FALSE;
      if ( options.inform )
         printf( "\n\n Special binary procedure cannot be used.\n");
   }

   /* If the general procedure is to be used, determine the packing factor if
      one was not specified.  Determine the packed length and the largest
      packed integer. */
   if ( !useBinaryProcedure ) {
      if ( packingFactor == 0 ) {
         packingFactor = 1;
         largestPackedInteger = C->fieldSize;
         while ( (largestPackedInteger <= 0x7fff / C->fieldSize) &&
                 (packingFactor <= C->dimension / 2) ) {
            ++packingFactor;
            largestPackedInteger *= C->fieldSize;
         }
         --largestPackedInteger;
      }
      else {
         temp = 1;
         largestPackedInteger = C->fieldSize;
         while ( (largestPackedInteger <= 0x7fff / C->fieldSize) &&
                 (temp < packingFactor) ) {
            ++temp;
            largestPackedInteger *= C->fieldSize;
         }
         packingFactor = temp;
         --largestPackedInteger;
      }
      packedLength = (C->length + packingFactor - 1) / packingFactor;
   }

   /* Compute the weight distribution. */
   if ( useBinaryProcedure )
      binaryWeightDist( C, saveWeight, oneCodeWordOnly, &allocatedSize, freq,
                        matrix);
   else
      generalWeightDist( C, saveWeight, oneCodeWordOnly, packingFactor,
                         largestPackedInteger, packedLength,
                         &allocatedSize, freq, matrix);

   /* Write out the weight distribution. */
   if ( options.inform ) {
      printf(  "\n\n          Weight Distribution of code %s", C->name);
      printf(  "\n\n                 Weight      Frequency");
      printf(    "\n                 ------      ---------");
      for ( i = 0 ; i <= C->length ; ++i )
         if ( freq[i] != 0 )
            printf( "\n                  %3u       %10lu", i, freq[i]);
      printf( "\n");
   }

   /* Write out the codewords of weight saveWeight. */
   if ( saveCodeWords && matrix->numberOfRows > 0 ) {
      if ( oneCodeWordOnly )
         sprintf( comment, "One codeword of weight %u in code %s.",
                  saveWeight, C->name);
      else if ( C->fieldSize == 2 )
         sprintf( comment, "The %u codewords of weight %u in code %s.",
                  matrix->numberOfRows, saveWeight, C->name);
      else 
         sprintf( comment, 
                 "%u of %u codewords of weight %u in code %s"
                 " (scalar multiples excluded).",
                  matrix->numberOfRows, matrix->numberOfRows * (C->fieldSize-1),
                  saveWeight, C->name);
      strcpy( matrix->name, matrixObjectName);
      write01Matrix( matrixFileName, matrixLibraryName, matrix, FALSE,
                           comment);
   }
   return 0;
}


/*-------------------------- packBinaryCodeWord ---------------------------*/


void packBinaryCodeWord(
   const Unsigned length,
   const FieldElement *const codeWordToPack,
   unsigned long *const packedWord1,
   unsigned long *const packedWord2,
   unsigned long *const packedWord3,
   unsigned long *const packedWord4)
{
   Unsigned col;

   *packedWord1 = *packedWord2 = *packedWord3 = *packedWord4 = 0;
   for ( col = 1 ; col <= length ; ++col )
      if ( col <= 32 )
         *packedWord1 |= codeWordToPack[col] << (col-1);
      else if (col <= 64 )
         *packedWord2 |= codeWordToPack[col] << (col-33);
      else if (col <= 96 )
         *packedWord3 |= codeWordToPack[col] << (col-65);
      else if (col <= 128 )
         *packedWord4 |= codeWordToPack[col] << (col-97);
}


/*-------------------------- buildOnesCount -------------------------------*/

/* This function allocates and constructs an array of size 2^16 in which
   entry i contains the number of ones in the binary representation of i,
   0 <= i < 2^16.  It returns (a pointer to) the array.  It is assumed that
   type short has length 16 bits. */

#ifdef HUGE
char huge *buildOnesCount(void)
#else
char *buildOnesCount(void)
#endif
{
   long i, j;
#ifdef HUGE
	char  huge *onesCount = (char  huge *) farmalloc( 65536L * sizeof(char) );
#else
	char *onesCount = (char *) malloc( 65536L * sizeof(char) );
#endif

   if ( !onesCount )
      ERROR( "buildOnesCount",
             "Not enough memory to run program.  Program terminated.")
   for ( i = 0 ; i <= 65535L ; ++i ) {
      onesCount[i] = 0;
      for ( j = 0 ; j <= 15 ; ++j )
         onesCount[i] +=  ( i & (1 << j)) != 0;
   }
   return onesCount;
}


/*-------------------------- binaryWeightDist ----------------------------*/

/* Assumes length <= 128. */

#define SAVE  if ( curWt == saveWeight ) {  \
                 if ( ++matrix->numberOfRows > *allocatedSize ) {  \
                    *allocatedSize *= 2;  \
                    matrix->entry = (FieldElement **) realloc( matrix->entry,  \
                                                               *allocatedSize); \
                 }  \
                 if ( !matrix->entry )  \
                    ERROR( "binaryWeightDist", "Out of memory.")  \
                 vec = matrix->entry[matrix->numberOfRows] = (FieldElement *)  \
                          malloc( (C->length+1) * sizeof(FieldElement) );  \
                 if ( !vec )  \
                    ERROR( "binaryWeightDist", "Out of memory.")  \
                 for ( j = 0 ; j < length ; ++j )  \
                    if ( j < 32 )  \
			              vec[j+1] = ((cw1 >> j) & 1);  \
                    else if ( j < 64 )  \
                       vec[j+1] = ((cw2 >> j-32) & 1);  \
                    else if ( j < 96 )  \
                       vec[j+1] = ((cw3 >> j-64) & 1);  \
                    else if ( j < 128 )  \
                       vec[j+1] = ((cw4 >> j-96) & 1);  \
                 if ( oneCodeWordOnly )  \
                    saveWeight = UNKNOWN;  \
              }

void binaryWeightDist(
   const Code *const C,
   Unsigned saveWeight,
   const BOOLEAN oneCodeWordOnly,
   Unsigned *const allocatedSize,
   unsigned long *const freq,
   Matrix_01 *const matrix)
{
	Unsigned length = C->length,
            dimension = C->dimension,
            i, j, curWt;
   FieldElement *vec;
   unsigned long m;
#ifdef HUGE
   char huge *onesCount = buildOnesCount();
#else
   char *onesCount = buildOnesCount();
#endif
   unsigned long  basis1[35], basis2[35], basis3[35], basis4[35];
   unsigned long  cw1, cw2, cw3, cw4;
   unsigned long  loopIndex, lastPass, temp;


   /* Initializations. */
   for ( i = 0 ; i <=C->length ; ++i )
      freq[i] = 0;
   cw1 = cw2 = cw3 = cw4 = 0;

   /* Pack the code words. */
   for ( i = 1 ; i <= C->dimension ; ++i )
      packBinaryCodeWord( C->length, C->basis[i], &basis1[i-1], &basis2[i-1],
                                                  &basis3[i-1], &basis4[i-1]);

   /* Enumerate the codewords. */
   lastPass = (1L << (dimension-3)) - 1;
   if ( saveWeight == UNKNOWN ) {
      if ( length <= 32 )
         #define MAXLEN 32
         #include "wt.h"
      else if ( length <= 48 )
         #define MAXLEN 48
         #include "wt.h"
      else if ( length <= 64 )
         #define MAXLEN 64
         #include "wt.h"
      else if ( length <= 80 )
         #define MAXLEN 80
         #include "wt.h"
      else if ( length <= 96 )
         #define MAXLEN 96
         #include "wt.h"
      else if ( length <= 112 )
         #define MAXLEN 112
         #include "wt.h"
      else if ( length <= 128 )
         #define MAXLEN 128
         #include "wt.h"
   }
   else
      if ( length <= 32 )
         #define MAXLEN 32
			#include "swt.h"
      else if ( length <= 48 )
         #define MAXLEN 48
			#include "swt.h"
      else if ( length <= 64 )
         #define MAXLEN 64
			#include "swt.h"
      else if ( length <= 80 )
         #define MAXLEN 80
			#include "swt.h"
      else if ( length <= 96 )
         #define MAXLEN 96
			#include "swt.h"
      else if ( length <= 112 )
         #define MAXLEN 112
			#include "swt.h"
      else if ( length <= 128 )
         #define MAXLEN 128
			#include "swt.h" 

}



/*-------------------------- buildWeightArray -------------------------------------*/

/* The procedure BuildWeightArray constructs the array Weight
   of size 0..LargestPackedInteger.  For t = 0,1,...,HighPackedInteger,
   Weight[t] is set to the number of nonzero field elements in the
   sequence of PackingFactor field elements represented by integer t. */

char *buildWeightArray(
   const Unsigned fieldSize,            /* Size of the field. */
   const Unsigned packingFactor,        /* No of cols packed into integer. */
   const Unsigned largestPackedInteger)
{
   Unsigned i, v;
   char *weight;

   weight = (char *) malloc( sizeof(char) * largestPackedInteger);
   if ( !weight )
      ERROR( "buildWeightArray", "Out of memory.");

   for ( i = 0 ; i <= largestPackedInteger ; ++i ) {
      weight[i] = 0;
      v = i;
      while ( v > 0 ) {
         if ( v % fieldSize )
            ++weight[i];
         v /= fieldSize;
      }
   }

   return weight;
}


/*-------------------------- packNonBinaryCodeWord --------------------------------*/

/* This procedure packs a codeword over a field of size greater than 2.
   (If the field size is 2, it works, but it returns an array of type
   unsigned short, whereas type unsigned would be preferable.)
   It returns a new packed code word which is obtained by packing the code
   word supplied as a parameter.  If p  denotes the PackingFactor, then p
   columns of the input codeword (Word) are packed into each integer of the
   output packed codeword (PackedWord).  If q denotes the field size and if
   c(1),...,c(n) denotes the input codeword, then the output packed word will
   have components
   c(1)+c(2)*q+...+c(p)*q**(p-1), c(p+1)+c(p+2)*q+...+c(2*p)*q**(p-1), etc. */

unsigned short *packNonBinaryCodeWord(
   const Unsigned fieldSize,              /* Field size for codeword. */
   const Unsigned length,                 /* Length of codeword to pack. */
   const Unsigned packingFactor,          /* No of cols packed into integer. */
   const FieldElement *codeWord)          /* The codeword to pack. */
{
   Unsigned index = 0,
            offset = 0,
            col,
            powerOfFieldSize = 1;
   const Unsigned colsPerArrayElt = (length+packingFactor) / packingFactor;
   unsigned short *packedCodeWord;

   packedCodeWord = (unsigned short *)
                      malloc( colsPerArrayElt * sizeof(unsigned short *));
   if ( !packedCodeWord )
      ERROR( "packNonBinaryCodeWord", "Out of memory.");
   packedCodeWord[0] = 0;

   for ( col = 1 ; col <= length ; ++col ) {
      if ( offset >= packingFactor ) {
         packedCodeWord[++index] = 0;
         offset = 0;
         powerOfFieldSize = 1;
      }
      packedCodeWord[index] += codeWord[col] * powerOfFieldSize;
      ++offset;
      powerOfFieldSize *= fieldSize;
   }

   return packedCodeWord;
}


/*-------------------------- unpackNonBinaryCodeWord --------------------------------*/

/* This procedure unpacks a codeword over a field of size greater than 2.  
   It performs the reverse of the packNonBinaryCodeword procedure above. */

void unpackNonBinaryCodeWord(
   const Unsigned fieldSize,              /* Field size for codeword. */
   const Unsigned length,                 /* Length of codeword to unpack. */
   const Unsigned packingFactor,          /* No of cols packed into integer. */
   const unsigned short *packedCodeWord,  /* The codeword to unpack pack. */
   FieldElement *const codeWord)          /* Set to unpacked code word. */
{
   Unsigned index = 0,
            offset = 0,
            col, temp;

   temp = packedCodeWord[0];
   for ( col = 1 ; col <= length ; ++col ) {
      if ( offset >= packingFactor ) {
         temp = packedCodeWord[++index];
         offset = 0;
      }
      codeWord[col] = temp % fieldSize;
      ++offset;
      temp /= fieldSize;
   }
}



/*-------------------------- buildAddBasisElement -----------------------------------*/

/* This procedure constructs a data structure AddBasisElement which
   specifies how to add a a prime-basis element to an arbitrary
   codeword.  addBasisElement[i][p][j] gives the sum of packed column j
   of the i'th prime basis vector and packed field sequence k, for
         1 <= i <= C->dimension * C->field->exponent,
         0 <= j < packedLength,
         0 <= p <= largestPackedInteger.
*/

unsigned short ***buildAddBasisElement(
   const Code *const C,
   const Unsigned packingFactor,
   const Unsigned packedLength,
   const Unsigned largestPackedInteger)
{
   unsigned short ***addBasisElement;
   Unsigned a, h, i, j, k, m, z, primeRow;
   FieldElement s;
   FieldElement *x, *y;
   Unsigned *primeBasisVector;
   const Unsigned fieldExponent = (C->fieldSize == 2) ? 1 : C->field->exponent;
   const primeDimension = C->dimension * fieldExponent;

   primeBasisVector = (Unsigned *) malloc( (C->length+1) * sizeof(Unsigned));
   if ( !primeBasisVector )
      ERROR( "buildAddBasisElement", "Out of memory.");
   addBasisElement = (unsigned short ***)
          malloc( primeDimension * sizeof(unsigned short **));
   if ( !addBasisElement )
      ERROR( "buildAddBasisElement", "Out of memory.");
   x = (FieldElement *) malloc( (C->length+2) * sizeof(FieldElement));
   if ( !x )
      ERROR( "buildAddBasisElement", "Out of memory.");
   y = (FieldElement *) malloc( (C->length+2) * sizeof(FieldElement));
   if ( !y )
      ERROR( "buildAddBasisElement", "Out of memory.");

   for ( i = 1 , primeRow = 0 ; i <= C->dimension ; ++i )
      for ( m = 0 ; m < fieldExponent ; ++m ) {

         /* This part works only for prime fields or GF(4). */
         s = (m == 0) ? 1 : 2;
         ++primeRow;
         if ( m > 0 && C->fieldSize != 4 )
            ERROR( "buildAddBasisElement", "Field whose order is not prime or 4.")
         if ( C->fieldSize == 2 )
            for ( k = 1 ; k <= C->length ; ++k )
               primeBasisVector[k] = C->basis[i][k];
         else
            for ( k = 1 ; k <= C->length ; ++k )
               primeBasisVector[k] = C->field->prod[C->basis[i][k]][s];
         addBasisElement[primeRow] = (unsigned short **)
             malloc( (largestPackedInteger+1) * sizeof(unsigned short **));
         if ( !addBasisElement[primeRow] )
            ERROR( "buildAddBasisElement", "Out of memory.")
         for ( h = 1 ; h <= C->length ; ++h )
            x[h] = 0;
         for ( z = 0 ; z <= largestPackedInteger ; ++z ) {
            if ( C->fieldSize == 2 )
               for ( j = 1 ; j <= C->length ; ++j ) 
                  y[j] = primeBasisVector[j] ^ x[j];
            else
               for ( j = 1 ; j <= C->length ; ++j )
                  y[j] = C->field->sum[primeBasisVector[j]][x[j]];
            addBasisElement[primeRow][z] = packNonBinaryCodeWord( C->fieldSize,
                                                   C->length, packingFactor, y);
            a = 1;
            while ( x[a] == C->fieldSize - 1 )
               ++a;
            ++x[a];
            for ( h = 1; h < a ; ++h)
               x[h] = 0;
            for ( h = packingFactor+1 ; h <= C->length ; ++h )
               x[h] = x[h-packingFactor];
         }
      }

   return addBasisElement;
}



/*-------------------------- generalWeightDist ----------------------------*/

void generalWeightDist(
   const Code *const C,
   Unsigned saveWeight,
   const BOOLEAN oneCodeWordOnly,
   const Unsigned packingFactor,
   const Unsigned largestPackedInteger,
   const Unsigned packedLength,
   Unsigned *const allocatedSize,
   unsigned long *const freq,
   Matrix_01 *matrix)
{
   const Unsigned fieldExponent = (C->fieldSize == 2) ? 1 : C->field->exponent;
   const Unsigned fieldCharacteristic = 
                  (C->fieldSize == 2) ? 2 : C->field->characteristic;
   const Unsigned primeDimension = C->dimension * fieldExponent;
   Unsigned currentWeight, h, m, primeRow, packedCol, wt;
   char *weight;
   unsigned short ***addBasisElement;
   unsigned short *currentWord;       /* Array of size packedLength+1 */
   Unsigned *x;                 /* Array of size primeDimension+1 */
   FieldElement *vec;

   /* Allocate the arrays x and currentWord. */
   x = (Unsigned *) malloc( (primeDimension+1) * sizeof(Unsigned *));
   if ( !x )
      ERROR( "generalWeightDist", "Out of memory")
   currentWord = 
            (unsigned short *) malloc( (packedLength+1) * sizeof(Unsigned *));
   if ( !currentWord )
      ERROR( "generalWeightDist", "Out of memory")
   
   /* Construct the weight array. */
   weight = buildWeightArray( C->fieldSize, packingFactor, 
                              largestPackedInteger);

   /* Construct structure AddBasisElement, used to add a prime basis codeword
      to an arbitrary codeword. */
   addBasisElement = buildAddBasisElement( C, packingFactor, packedLength,
                                           largestPackedInteger);

   /* Initialize freq and saveCount.  Upon termination, freq will hold the
      weight distribution. */
   for ( wt = 1 ; wt <= C->length ; ++wt )
      freq[wt] = 0;
   freq[0] = 1;

   /* Traverse the code. */
   for ( h = C->dimension ; h >= 1 ; --h ) {

      /* Traverse codewords of form  0*basis[1] +...+ 0*basis[h-1] +
         1*basis[h] + (anything) * basis[h+1] +...+ (anything) * basis[k]),
         where k is the dimension. */
      for ( primeRow = 0 ; primeRow <= primeDimension ; ++primeRow )
         x[primeRow] = 0;
      for ( packedCol = 0 ; packedCol < packedLength ; ++packedCol )
         currentWord[packedCol] = 0;
      m = (h - 1) * fieldExponent + 1;

      do {

         /* Add prime basis codeword m to current word and find weight
            of result. */
         currentWeight = 0;
         for ( packedCol = 0 ; packedCol < packedLength ; ++packedCol ) {
            currentWord[packedCol] =
                  addBasisElement[m][currentWord[packedCol]][packedCol];
            currentWeight += weight[currentWord[packedCol]];
         }

         /* Record weight. */
         freq[currentWeight] += (C->fieldSize - 1);

         /* Save the codeword, if appropriate. */
         if ( currentWeight == saveWeight ) {
            ++matrix->numberOfRows;
            if ( matrix->numberOfRows > *allocatedSize ) {
               *allocatedSize *= 2;
               matrix->entry = (FieldElement **) realloc( matrix->entry,
                                                       *allocatedSize);
               if ( !matrix->entry )
                  ERROR( "binaryWeightDist", "Out of memory.")
             }
             vec = matrix->entry[matrix->numberOfRows] =
                   malloc( (C->length+1) * sizeof(FieldElement) );
             if ( !vec )
                ERROR( "binaryWeightDist", "Out of memory.")
             unpackNonBinaryCodeWord( C->fieldSize, C->length, packingFactor,
                                      currentWord, vec);
             if ( oneCodeWordOnly )
                saveWeight = UNKNOWN+1;
          }

         /* Find m such that prime basis codeword number X[m] is the
            basis codeword to add next. */
         m = primeDimension;
         while ( x[m] == fieldCharacteristic - 1 )
            --m;

         /* Adjust array X, which determines which basis codeword to add
            next. */
         ++x[m];
         for ( primeRow = m+1 ; primeRow <= primeDimension ; ++primeRow )
            x[primeRow] = 0;

      } while ( m > h * fieldExponent );  
   }
}

#ifdef xxxxxx

/*-------------------------- binaryCosetWeightDist -----------------------*/

void binaryCosetWeightDist(
   const Code *const C,
   const Unsigned maxCosetWeight,
   const BOOLEAN oneCodeWordOnly,
   const Unsigned passes,
   Unsigned *const allocatedSize,
   unsigned long *const freq,
   Matrix_01 *const matrix)
{
   unsigned long sum;
   const unsigned coDimension = C->length - C->dimension;
   const unsigned long numberOfCosetsLess1 = (2L << coDimension) - 1;
   const unsigned long maxCosetsPerPass = numberOfCosetsLess1 / passes + 1;

   /* Initializations. */
   for ( i = 0 ; i <=C->length ; ++i )
      freq[i] = 0;
   cw1 = cw2 = cw3 = cw4 = 0;

   for ( wt = 1 ; wt <= maxCosetWeight && cosetsFound <= goal ; ++wt ) {
      for ( i = 1 ; i <= wt ; ++i )


   /* Write out the coset weight distribution. */
   sumLess1 = 0;
   if ( options.inform ) {
      printf(  "\n\n        Coset Weight Distribution of code %s", C->name);
      printf(  "\n\n             Coset Min Wt     Number Of Cosets");
      printf(    "\n             ------------     ----------------");
      for ( i = 0 ; i <= maxCosetWeight ; ++i )
         if ( freq[i] != 0 )
            if ( i != 0 )
               sumLess1 += freq[i];
            printf( "\n                  %2u         %10lu", i, freq[i]);
      if ( sumLess1 < numberOfCosetsLess1 )
         printf( "\n         at least %2u         %10lu", maxCosetWeight+1, 
                 numberOfCosetsLess1 - sumLess1);
      printf( "\n");
   }
#endif

/*-------------------------- verifyOptions -------------------------------*/

static void verifyOptions(void)
{
   CompileOptions mainOpts = { DEFAULT_MAX_BASE_SIZE, MAX_NAME_LENGTH,
                               MAX_PRIME_FACTORS,
                               MAX_REFINEMENT_PARMS, MAX_FAMILY_PARMS,
                               MAX_EXTRA,  XLARGE, SGND, NFLT};
   extern void xbitman( CompileOptions *cOpts);
   extern void xcode  ( CompileOptions *cOpts);
   extern void xcopy  ( CompileOptions *cOpts);
   extern void xerrmes( CompileOptions *cOpts);
   extern void xessent( CompileOptions *cOpts);
   extern void xfactor( CompileOptions *cOpts);
   extern void xfield ( CompileOptions *cOpts);
   extern void xnew   ( CompileOptions *cOpts);
   extern void xpartn ( CompileOptions *cOpts);
   extern void xpermut( CompileOptions *cOpts);
   extern void xpermgr( CompileOptions *cOpts);
   extern void xprimes( CompileOptions *cOpts);
   extern void xreadde( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);

   xbitman( &mainOpts);
   xcode  ( &mainOpts);
   xcopy  ( &mainOpts);
   xerrmes( &mainOpts);
   xessent( &mainOpts);
   xfactor( &mainOpts);
   xfield ( &mainOpts);
   xnew   ( &mainOpts);
   xpartn ( &mainOpts);
   xpermut( &mainOpts);
   xpermgr( &mainOpts);
   xprimes( &mainOpts);
   xreadde( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}
