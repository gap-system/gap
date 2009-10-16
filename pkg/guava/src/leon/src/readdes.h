#ifndef READDES
#define READDES

extern Matrix_01 *readDesign(
   char *libFileName,
   char *libName,
   Unsigned requiredPointCount,       /* 0 = any */
   Unsigned requiredBlockCount)       /* 0 = any */
;

extern void writeDesign(
   char *libFileName,
   char *libName,
   Matrix_01 *matrix,
   char *comment)
;

extern Matrix_01 *read01Matrix(
   char *libFileName,
   char *libName,
   BOOLEAN transposeFlag,                /* If true, matrix is transposed. */
   BOOLEAN adjoinIdentity,               /* If true, form (A|I), A = matrix read. */
   Unsigned requiredSetSize,             /* 0 = any */
   Unsigned requiredNumberOfRows,        /* 0 = any */
   Unsigned requiredNumberOfCols)        /* 0 = any */
;

extern void write01Matrix(
   char *libFileName,
   char *libName,
   Matrix_01 *matrix,
   BOOLEAN transposeFlag,
   char *comment)
;

extern Code *readCode(
   char *libFileName,
   char *libName,
   BOOLEAN reduceFlag,                   /* If true, gen matrix is reduced. */
   Unsigned requiredSetSize,             /* 0 = any */
   Unsigned requiredDimension,           /* 0 = any */
   Unsigned requiredLength)              /* 0 = any */
;

extern void writeCode(
   char *libFileName,
   char *libName,
   Code *C,
   char *comment)
;

#endif
