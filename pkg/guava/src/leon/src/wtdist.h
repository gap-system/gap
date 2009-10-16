#ifndef WTDIST
#define WTDIST

extern void readCommandLine(
   int argc,
   char *argv[],
   char *name,
   int  *saveWeightPtr,
   int  *saveCountPtr)
;

extern void readCode(
   FILE *inFile,
   int *lengthPtr,
   int *dimensionPtr,
   unsigned long *basis1,
   unsigned long *basis2,
   unsigned long *basis3,
   unsigned long *basis4)
;

extern void writeWtDist(
   FILE *wtFile,
   char *name,
   int length,
   int dimension,
   unsigned long *basis1,
   unsigned long *basis2,
   unsigned long *basis3,
   unsigned long *basis4,
   unsigned long *freq)
;

extern void writeVector(
    FILE *vecFile,
   int length,
   unsigned long cw1,
   unsigned long cw2,
   unsigned long cw3,
   unsigned long cw4)
;

extern char  HUGE *buildOnesCount(void)
;

extern void main( int argc, char *argv[] )
;

#endif
