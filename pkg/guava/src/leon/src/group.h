#ifndef GROUP   
#define GROUP

/* File group.h.  File to be included with all permutation group theoretic
   functions.  Defines constants and types relating to permutation groups.
   Also defines some convenient macros.

   Certain preprocessor symbols must, or may, be defined on the compilation
   command line.  Of the symbols below, INT_SIZE is always required; the others
   are sometime required, or desirable:

      INT_SIZE  d             -- Here d is the number of bits in type int (usually
                                 16 or 32).

      EBCDIC                  -- Must be defined if the system uses EBCDIC (rather
                                 than ASCII) to represent characters.

      PERIOD_TO_BLANK         -- If defined, periods in a file name are translated
                                 to blanks.  This option is present primarily
                                 for use with CMS.  It allows, for example,
                                 a file named PSP82 GROUP A1 to be entered
                                 in the form PSP82.GROUP.A1.

      LONG_EXTERNAL_NAMES     -- Should be defined if the compiler and linker
                                 support external names (31 characters).

      EXTRA_LARGE             -- If defined, the compiler represents points using
                                 type int rather than type short or unsigned short.
                                 This permits permutation groups of high degree but
                                 increases memory requirements considerably.  This
                                 option is intended for C compilers in which 
                                 sizeof(int) = 4.
                                   
      SIGNED                  -- Assuming EXTRA_LARGE is not defined, defining
                                 signed causes points to be represented using
                                 type short rather than type unsigned short.  This
                                 reduces the maximum degree for permutations groups
                                 but speeds up the algorithm significantly on some
                                 machines (e.g., IBM 3090).

      NOFLOAT                 -- Causes generation of code performing no floating
                                 point operations.  Useful primarily in cases
                                 where the C compiler generates code requiring a
                                 coprocessor when floating point arithmetic is
                                 used.

      TICK                    -- A value of CLK_TCK to be used in place of the
                                 value defined in the header file time.h.  This
                                 is needed in the NOFLOAT option is chosen and if
                                 CLK_TCK is given as a floating point quantity
                                 (e.g., 18.2 in Turbo C for the IBM PC).  It is
                                 also needed if an alternate CPU time function
                                 is specified.

      CPU_TIME  timeFunc      -- If defined, timeFunc must be the name of a user-
                                 supplied function for measuring CPU time.  If
                                 not defined, the C function clock() is used.
                                 (This function is required on the SUN/3 since
                                 the clock function wraps around after less than
                                 an hour.)

      DEFAULT_MAX_BASE_SIZE b -- Here b is a default bound on the size of the base for
                                 permutation groups.  It is 62 by default. Larger 
                                 values of b increase memory requirements slightly
                                 and may increase execution time very slightly.
                                 This default value may be overridden by
                                 means of the -mb option.

      MAX_NAME_LENGTH  n      -- Here n is the number of characters allowed in
                                 the name of a group, permutation, set, or
                                 partition.  Default is 16.  Large values may
                                 cause problems with output.

      MAX_FILE_ NAME_LENGTH m -- Here m is the number of characters allowed in
                                 any file name (including path information.
                                 The default is 60.


For some compilers, it may be necessary to insert code unique to that compiler.
In this case, a special symbol identifying the machine and compiler
(e.g., IBM_CMS_WATERLOOC for Waterloo C on the IBM 370) should be defined,
and the special code should be in the body of an #if directive specifying
that special symbol. */

#include <limits.h>

#if !defined(INT_SIZE)
#error INT_SIZE not defined.
#endif

#ifdef CPU_TIME
#define ALT_TIME_HEADER
#else
#define CPU_TIME clock
#endif

#ifndef LONG_EXTERNAL_NAMES
#include "extname.h"
#endif

#if defined(SIGNED)
#define Unsigned  short
#define UnsignedS short
#define MAX_INT   SHRT_MAX
#define SCANF_Int_FORMAT  "%hd"
#elif INT_SIZE <= 16 || defined(EXTRA_LARGE)
#define Unsigned  unsigned
#define UnsignedS unsigned
#define MAX_INT   UINT_MAX
#define SCANF_Int_FORMAT  "%u"
#else
#define Unsigned  unsigned short
#define UnsignedS unsigned short
#define MAX_INT   USHRT_MAX
#define SCANF_Int_FORMAT  "%hu"
#endif

#ifndef MAX_NAME_LENGTH
#define MAX_NAME_LENGTH      64
#endif

#ifndef MAX_FILE_NAME_LENGTH
#define MAX_FILE_NAME_LENGTH 60
#endif

#ifndef DEFAULT_MAX_BASE_SIZE
#define DEFAULT_MAX_BASE_SIZE  62
#endif


#ifndef MAX_CODE_LENGTH
#define MAX_CODE_LENGTH      128
#endif

#define MAX_REFINEMENT_PARMS 3
#define MAX_FAMILY_PARMS     6
#define MAX_PRIME_FACTORS    30
#define MAX_EXTRA            10

#define SYMMETRIC_GROUP_CHAR '#'
#define IS_SYMMETRIC(g) ((g)->name[0] == SYMMETRIC_GROUP_CHAR)
#define ERROR_RETURN_CODE  15
#define MAX_COSET_REP_PRINT 300


#define TRUE             1
#define FALSE            0
#define BOOLEAN          Unsigned

#define IRREDUCIBLE      MAX_INT
#define UNKNOWN          MAX_INT

#define MIN(x,y)         ( ((x) < (y)) ? (x) : (y) )
#define MAX(x,y)         ( ((x) > (y)) ? (x) : (y) )
#define ABS(x)           ( ((x) < 0) ? (-(x)) : (x) )

#define FIRST_IN_ORBIT  ((Permutation *) 1)

#define EXCHANGE(x,y,temp)   {temp = x;  x = y;  y = temp;}

#define ERROR(function,message)  \
    errorMessage( __FILE__, __LINE__, function, message);

#define ERROR1i(function,message1,intParm,message2)  \
    errorMessage1i( __FILE__, __LINE__, function, message1, intParm, message2);

#define ERROR1s(function,message1,strParm,message2)  \
    errorMessage1s( __FILE__, __LINE__, function, message1, strParm, message2);


#define ESSENTIAL_AT_LEVEL(perm,level)  essentialAtLevel( perm, level)
#define ESSENTIAL_BELOW_LEVEL(perm,level)  essentialBelowLevel( perm, level)
#define ESSENTIAL_ABOVE_LEVEL(perm,level)  essentialAboveLevel( perm, level)
#define MAKE_ESSENTIAL_AT_LEVEL(perm,level)  makeEssentialAtLevel( perm, level)
#define MAKE_NOT_ESSENTIAL_AT_LEVEL(perm,level)  \
                            makeNotEssentialAtLevel( perm, level)
#define MAKE_NOT_ESSENTIAL_ATABOV_LEVEL(perm,level)  \
                            makeNotEssentialAtAboveLevel( perm, level)
#define MAKE_NOT_ESSENTIAL_ALL(perm)  makeNotEssentialAll( perm)
#define MAKE_UNKNOWN_ESSENTIAL(perm)  makeUnknownEssential( perm)
#define COPY_ESSENTIAL(newPerm,oldPerm)  copyEssential( newPerm, oldPerm)

#define RPQ_SIZE( rpq)   rpq->size
#define RPQ_CLEAR( rpq)  rpq->size = 0;


#ifdef EXTRA_LARGE
#define XLARGE TRUE
#endif
#ifndef EXTRA_LARGE
#define XLARGE FALSE
#endif

#ifdef  SIGNED
#define SGND TRUE
#endif
#ifndef SIGNED
#define SGND FALSE
#endif

#ifdef NOFLOAT
#define NFLT TRUE
#endif
#ifndef NOFLOAT
#define NFLT FALSE
#endif

typedef struct {
   int mbs, mnl, mpf, mrp, mfp, me, xl, sg, nf;
} CompileOptions;

#ifndef MAIN
void checkCompileOptions(
   char *localFileName,
   CompileOptions *mainOpts,
   CompileOptions *localOpts);
#endif

#define CHECK(fileName)  \
      void x##fileName( CompileOptions *mainOptsPtr)  \
      {  CompileOptions localOpts = { DEFAULT_MAX_BASE_SIZE, MAX_NAME_LENGTH,  \
                                      MAX_PRIME_FACTORS,  \
                                      MAX_REFINEMENT_PARMS, MAX_FAMILY_PARMS,  \
                                      MAX_EXTRA,  XLARGE, SGND, NFLT};  \
         checkCompileOptions( __FILE__, mainOptsPtr, &localOpts);  \
      }


extern unsigned long bitSetAt[32];
extern unsigned long bitSetBelow[33];


typedef
   enum {
      PERM_GROUP, PERMUTATION, POINT_SET, PARTITION, DESIGN, MATRIX_01,
      BINARY_CODE, INVALID_OBJECT
   } ObjectType;

typedef struct {
   Unsigned noOfFactors;
   UnsignedS prime[MAX_PRIME_FACTORS+1];
   UnsignedS exponent[MAX_PRIME_FACTORS+1];
} FactoredInt;

struct Word;
struct OccurenceOfGen;

typedef
   struct Permutation {
      char name[MAX_NAME_LENGTH+1];
      UnsignedS  degree;
      UnsignedS  *image;               /* Alloc (degree+2)*sizeof(UnsignedS). */
      UnsignedS  *invImage;            /* Alloc (degree+2)*sizeof(UnsignedS). */
      Unsigned  level;
      unsigned long *essential;
      struct Permutation *invPermutation;
      struct Permutation *next,
                         *last;
      struct Permutation *xNext,
                         *xLast;
      struct Word *word;             /* Alloc (MWLENGTH+2)*sizeof(Word *). */
      struct OccurenceOfGen *occurHeader;
   } Permutation;

typedef
   struct Word {
      Unsigned length;
      Permutation **position;
   } Word;

typedef
   struct Relator {
      Unsigned length;
      Unsigned level;
      Permutation **rel;
      Unsigned **fRel;
      Unsigned **bRel;
      struct Relator *next;
      struct Relator *last;
   } Relator;

typedef
   struct OccurenceOfGen {
      Relator *r;
      Unsigned relLength;
      Unsigned level;
      Unsigned **fRelStart;
      Unsigned **bRelFinish;
      struct OccurenceOfGen *next;
   } OccurenceOfGen;

typedef
   struct SplitSize {
      Unsigned oldCellSize;
      Unsigned newCellSize;
   } SplitSize;

typedef
   enum {
      cycleFormat,
      imageFormat,
      binaryFormat,
      cayleyLibraryFormat,
      cayleyReadFormat
   } PermFormat;

typedef                                        /* Note below MBS denotes */
   struct PermGroup {                          /*  MAX_BASE_SIZE.        */
      char name[MAX_NAME_LENGTH+1];
      Unsigned degree;
      Unsigned baseSize;
      FactoredInt *order;           /* Alloc sizeof(FactoredInt). */
      UnsignedS *base;              /* Alloc (MBS+2)*sizeof(UnsignedS). */
      UnsignedS *basicOrbLen;       /* Alloc (MBS+2)*sizeof(UnsignedS). */
      UnsignedS **basicOrbit;       /* Alloc (MBS+2)*sizeof(UnsignedS **). */
      Permutation ***schreierVec;   /* Alloc (MBS+2)*sizeof(Permutation***).*/
      UnsignedS **completeOrbit;    /* Alloc (MBS+2)*sizeof(UnsignedS **). */
      UnsignedS **orbNumberOfPt;    /* Alloc (MBS+2)*sizeof(UnsignedS **). */
      UnsignedS **startOfOrbitNo;   /* Alloc (MBS+2)*sizeof(UnsignedS **). */
      Permutation *generator;
      UnsignedS *omega;             /* Alloc (degree+2)*sizeof(UnsignedS). */
      UnsignedS *invOmega;          /* Alloc (degree+2)*sizeof(UnsignedS). */
      PermFormat printFormat;
      Relator *relator;
   } PermGroup;

typedef
   struct Partition {
      char name[MAX_NAME_LENGTH+1];
      Unsigned degree;
      UnsignedS *pointList;         /* Alloc (degree+2)*sizeof(UnsignedS). */
      UnsignedS *invPointList;      /* Alloc (degree+2)*sizeof(UnsignedS). */
      UnsignedS *cellNumber;        /* Alloc (degree+2)*sizeof(UnsignedS). */
      UnsignedS *startCell;         /* Alloc (degree+2)*sizeof(UnsignedS). */
   } Partition;

typedef
   struct PartitionStack {
      Unsigned height;
      Unsigned degree;
      UnsignedS *pointList;         /* Allocate (degree+2)*sizeof(UnsignedS). */
      UnsignedS *invPointList;      /* Allocate (degree+2)*sizeof(UnsignedS). */
      UnsignedS *cellNumber;        /* Allocate (degree+2)*sizeof(UnsignedS). */
      UnsignedS *parent;            /* Allocate (degree+2)*sizeof(UnsignedS). */
      UnsignedS *startCell;         /* Allocate (degree+2)*sizeof(UnsignedS). */
      UnsignedS *cellSize;          /* Allocate (degree+2)*sizeof(UnsignedS). */
   } PartitionStack;

typedef
   struct CellPartitionStack {
      Partition *basePartn;
      Unsigned height;
      Unsigned cellCount;
      UnsignedS *cellList;          /* Alloc (cellCount+2)*sizeof(UnsignedS). */
      UnsignedS *invCellList;       /* Alloc (cellCount+2)*sizeof(UnsignedS). */
      UnsignedS *cellGroupNumber;   /* Alloc (cellCount+2)*sizeof(UnsignedS). */
      UnsignedS *parentGroup;       /* Alloc (cellCount+2)*sizeof(UnsignedS). */
      UnsignedS *startCellGroup;    /* Alloc (cellCount+2)*sizeof(UnsignedS). */
      UnsignedS *cellGroupSize;     /* Alloc (cellCount+2)*sizeof(UnsignedS). */
      UnsignedS *totalGroupSize;    /* Alloc (cellCount+2)*sizeof(UnsignedS). */
   } CellPartitionStack;

typedef
   union {
      Unsigned intParm;
      void *ptrParm;
   } RefinementParm;

typedef SplitSize RefinementMapping(
   const RefinementParm familyParm[],
   const RefinementParm refnParm[],
   PartitionStack *const UpsilonStack);

typedef struct {
   RefinementMapping *refine;
   RefinementParm familyParm_L[MAX_FAMILY_PARMS];
   RefinementParm familyParm_R[MAX_FAMILY_PARMS];
} RefinementFamily;

typedef struct {
   RefinementFamily *family;
   RefinementParm refnParm[MAX_REFINEMENT_PARMS];
} Refinement;

typedef struct {
   Refinement refn;
   long priority;
} RefinementPriorityPair;

typedef RefinementPriorityPair ReducChkFn(
   const RefinementFamily *family,
   const PartitionStack *const UpsilonStack);

/* R-base notation is as in "Perm Grp Algs...".  Note fields omega, invOmega,
   alpha are not included here, but are set in the structure for the
   containing group. */
typedef                                        /* Note below MBS denotes */
   struct {                                    /*  MAX_BASE_SIZE.        */
      Unsigned ell;
      Unsigned k;
      Unsigned degree;
      Refinement *aAA;               /* Alloc (degree+2) * sizeof(Refinement).*/
      PartitionStack *PsiStack;      /* Alloc sizeof(PartitionStack). */
      UnsignedS *n_;                 /* Alloc (MBS+2)*sizeof(UnsignedS). */
      UnsignedS *p_;                 /* Alloc (MBS+2)*sizeof(UnsignedS). */
      UnsignedS *alphaHat;           /* Alloc (MBS+2)*sizeof(UnsignedS). */
      UnsignedS *a_;                 /* Alloc (degree+2)*sizeof(UnsignedS). */
      UnsignedS *b_;                 /* Alloc (degree+2)*sizeof(UnsignedS). */
      UnsignedS *omega;              /* Alloc (degree+2)*sizeof(UnsignedS). */
      UnsignedS *invOmega;           /* Alloc (degree+2)*sizeof(UnsignedS). */
   } RBase;

typedef
   struct PointSet {
      char name[MAX_NAME_LENGTH+1];
      Unsigned size;
      Unsigned degree;
      UnsignedS *pointList;          /* Alloc (degree+2)*sizeof(UnsignedS). */
      char *inSet;                   /* Alloc (degree+2)*sizeof(char) */
   } PointSet;

typedef
   struct {
      Unsigned size;
      Unsigned degree;
      Unsigned maxSize;
      UnsignedS *pointList;         /* Alloc (maxSize+2)*sizeof(UnsignedS). */
   } RPriorityQueue;

typedef BOOLEAN Property( const Permutation *const);

typedef struct {
   Unsigned maxBaseSize;
   Unsigned maxDegree;
   Unsigned maxWordLength;
   BOOLEAN  statistics;
   BOOLEAN inform;
   BOOLEAN strongMinDCosetCheck;
   BOOLEAN compress;
   Unsigned maxStrongGens;
   Unsigned maxBaseChangeLevel;
   Unsigned idealBasicCellSize;
   Unsigned trimSGenSetToSize;
   Unsigned writeConjPerm;
   Unsigned restrictedDegree;                   /* For informCosetRep only. */
   void (*altInformCosetRep)( Permutation *y);
   Unsigned alphaHat1;
   char genNamePrefix[8];
   char outputFileMode[3];
   char *groupOrderMessage;
   char *cosetRepMessage;
   char *noCosetRepMessage;
} GroupOptions;

typedef struct {
   unsigned long initialSeed;
   Unsigned minWordLengthIncrement;
   Unsigned maxWordLengthIncrement;
   Unsigned stopAfter;
   BOOLEAN  reduceGenOrder;
   Unsigned rejectNonInvols;
   Unsigned rejectHighOrder;
   BOOLEAN  onlyEssentialInitGens;
   BOOLEAN  onlyEssentialAddedGens;
} RandomSchreierOptions;

typedef struct {
   char refnType;
   PermGroup *leftGroup;
   PermGroup *rightGroup;
} SpecialRefinementDescriptor;

typedef struct {
   UnsignedS **revWord;
   UnsignedS **invWord;
   UnsignedS *lengthAtLevel;    /* alloc (MAX_BASE_SIZE+2) * sizeof(UnsignedS) */
} THatWordType;

typedef char FieldElement;

typedef struct {
   char name[MAX_NAME_LENGTH+1];
   Unsigned size;
   Unsigned characteristic;
   Unsigned exponent;
   char **sum;
   char **dif;
   char **prod;
   char *inv;
} Field;

typedef struct {
   char name[MAX_NAME_LENGTH+1];
   Unsigned setSize;
   Field *field;
   Unsigned numberOfRows;
   Unsigned numberOfCols;
   char **entry;
   Unsigned *unused;
} Matrix_01;

typedef struct {
   char name[MAX_NAME_LENGTH+1];
   Unsigned fieldSize;
   Field *field;
   Unsigned dimension;
   Unsigned length;
   char **basis;
   Unsigned *infoSet;
} Code;

typedef struct {
   Unsigned cellCount;
   CellPartitionStack *xPsiStack;
   CellPartitionStack *xUpsilonStack;
   Refinement *xRRR;
   void (*cstExtraRBase)(Unsigned level);
   UnsignedS *applyAfter;
   UnsignedS *xA_;
   UnsignedS *xB_;
} ExtraDomain;

#endif
