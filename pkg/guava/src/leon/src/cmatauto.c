/* File cmatauto.c.  Contains functions matrixAutoGroup and matrixIsomorphism,
   the main functions for computing automorphism groups of general and
   monomial matrices.  */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include "group.h"
#include "groupio.h"

#include "code.h"
#include "compcrep.h"
#include "compsg.h"
#include "cparstab.h"
#include "errmesg.h"
#include "matrix.h"
#include "new.h"
#include "randgrp.h"
#include "readgrp.h"
#include "storage.h"

CHECK( cmatau)

extern GroupOptions options;

static RefinementMapping setStabRefine;
static ReducChkFn isSetStabReducible;
static void initializeSetStabRefn(void);
static RefinementMapping gRowVsColRefine;
static ReducChkFn isGRowVsColReducible;

static PointSet *knownIrreducible[10]  /* Null terminated 0-base list of */
                = {NULL};              /*  point sets Lambda for which top */
                                       /*  partition on UpsilonStack is */
                                       /*  known to be SSS_Lambda irred. */

static Matrix_01 *MM, *MM_L, *MM_R;
static Code *CC, *CC_L, *CC_R;
static BOOLEAN checkMonomialProperty;   /* Also needed by isGRowVsColReducible. */
static BOOLEAN informCols;

static BOOLEAN matrix01AutoProperty(
   Permutation *s )
{
   return isMatrix01Isomorphism( MM, MM, s, checkMonomialProperty);
}


static BOOLEAN matrix01IsoProperty(
   Permutation *s )
{
   return isMatrix01Isomorphism( MM_L, MM_R, s, checkMonomialProperty);
}


static BOOLEAN codeAutoProperty(
   Permutation *s )
{
   return isCodeIsomorphism( CC, CC, s);
}


static BOOLEAN codeIsoProperty(
   Permutation *s )
{
   return isCodeIsomorphism( CC_L, CC_R, s);
}

static void informMatrixIso(
   Permutation *perm);

static void informMatrixMonIso(
   Permutation *perm);

static void informCodeMonIso(
   Permutation *perm);


/*-------------------------- matrixAutoGroup ------------------------------*/

/* Function matrixAutoGroup.  Returns a new permutation group representing 
   the automorphism group of the matrix M.  If M is an (0,1)-matrix, the
   function designAutoGroup should be invoked instead.  The algorithm is based 
   on Figure 9 in the paper "Permutation group algorithms based on partitions" by the 
   author.  */

#define familyParm familyParm_L

PermGroup *matrixAutoGroup(
   Matrix_01 *const M,            /* The matrix whose group is to be found. */
   PermGroup *const L,            /* A (possibly trivial) known subgroup of the
                                     automorphism group of D.  (A null pointer
                                     designates a trivial group.) */
   Code *const C,                 /* If nonnull, the auto grp of the code C is */
   const BOOLEAN monomialFlag)    /* computed, assuming its group is contained
                                     in that of the design. */
{
   RefinementFamily SSS_Lambda, IIIg_M;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];
   ExtraDomain *extra[1];
   PointSet *Lambda;                     /* Set of rows. */
   Partition *Pi;                        /* Rows, cols, identity cols. */
   PermGroup *G;
   Unsigned degree = M->numberOfRows + M->numberOfCols;
   Unsigned i;
   Property *pp;

   /* Construct the symmetric group G of degree rows+cols. */
   G = allocPermGroup();
   sprintf( G->name, "%c%d", SYMMETRIC_GROUP_CHAR, degree);
   G->degree = degree;
   G->baseSize = 0;

   /* Construct the set Lambda of points, ie. Lambda = {1,...,numberOfRows} or
      the partition Pi. */
   if ( monomialFlag ) {
      Pi = allocPartition();
      Pi->degree = degree;
      Pi->pointList = allocIntArrayDegree();
      Pi->invPointList = allocIntArrayDegree();
      Pi->cellNumber = allocIntArrayDegree();
      Pi->startCell = allocIntArrayDegree();
      for ( i = 1 ; i <= degree ; ++i ) {
         Pi->pointList[i] = Pi->invPointList[i] = i;
         Pi->cellNumber[i] = ( i <= M->numberOfRows) ? 1 :
                             ( i <= degree - M->numberOfRows ) ? 2 : 3;
      }
      Pi->startCell[1] = 1;
      Pi->startCell[2] = M->numberOfRows + 1;
      Pi->startCell[3] = degree - M->numberOfRows + 1;
      Pi->startCell[4] = degree + 1;;
      SSS_Lambda.refine = partnStabRefine;
      SSS_Lambda.familyParm[0].ptrParm = (void *) Pi;
   }
   else {
      Lambda = allocPointSet();
      Lambda->degree = degree;
      Lambda->size = M->numberOfRows;
      Lambda->pointList = allocIntArrayDegree();
      for ( i = 1 ; i <= M->numberOfRows ; ++i )
         Lambda->pointList[i] = i;
      Lambda->pointList[M->numberOfRows+1] = 0;
      Lambda->inSet = allocBooleanArrayDegree();
      for ( i = 1 ; i <= degree ; ++i )
         Lambda->inSet[i] = ( i <= M->numberOfRows);
      SSS_Lambda.refine = setStabRefine;
      SSS_Lambda.familyParm[0].ptrParm = (void *) Lambda;
   }

   IIIg_M.refine = gRowVsColRefine;
   IIIg_M.familyParm[0].ptrParm = (void *) M;

   refnFamList[0] = &SSS_Lambda;
   refnFamList[1] = &IIIg_M;
   refnFamList[2] = NULL;

   reducChkList[0] = (monomialFlag) ? isPartnStabReducible : isSetStabReducible;
   reducChkList[1] = isGRowVsColReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = NULL;
   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   extra[0] = NULL;

   if ( monomialFlag )
      initializePartnStabRefn();
   else
      initializeSetStabRefn();

   if ( C ) {
      CC = C;
      checkMonomialProperty = (C->fieldSize > 2);
      pp = codeAutoProperty;
   }
   else {
      MM = M;
      checkMonomialProperty = monomialFlag;
      pp = matrix01AutoProperty;
   }
   

   return  computeSubgroup( G, pp, refnFamList, reducChkList,
                            specialRefinement, extra, L);
}
#undef familyParm


/*-------------------------- matrixIsomorphism ----------------------------*/

/* Function matrixIsomorphism.  Returns a permutation mapping one specified   
   matrix M_L to another matrix M_R.  The two matrices must have
   the same number of rows and the same number of columns.  The algorithm is 
   based on Figure 9 in the paper "Permutation group algorithms based on 
   partitions" by the author. */

Permutation *matrixIsomorphism(
   Matrix_01 *const M_L,          /* The first design. */
   Matrix_01 *const M_R,          /* The second design. */
   PermGroup *const L_L,          /* A known subgroup of Aut(M_L), or NULL. */
   PermGroup *const L_R,          /* A known subgroup of Aut(M_R), or NULL. */
   Code *const C_L,               /* If nonnull, C_R must also be nonull, and */
   Code *const C_R,               /*   any isomorphism of C_L to C_R must map */
   const BOOLEAN monomialFlag,    /*   M_L to M_R.  A code isomorphism is     */
                                  /*   computed.  */  
   const BOOLEAN colInformFlag)   /* Print iso on columns to std output. */
{
   RefinementFamily SSS_Lambda_Lambda, IIIg_ML_MR;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];
   ExtraDomain *extra[1];
   PointSet *Lambda;                     /* Set of rows. */
   Partition *Pi;                        /* Rows, cols, identity cols. */
   PermGroup *G;
   Unsigned degree = M_L->numberOfRows + M_L->numberOfCols;
   Unsigned i;
   Property *pp;

   /* Construct the symmetric group G of degree rows+cols. */
   G = allocPermGroup();
   sprintf( G->name, "%c%d", SYMMETRIC_GROUP_CHAR, degree);
   G->degree = degree;
   G->baseSize = 0;

   /* Construct the set Lambda of points, ie. Lambda = {1,...,numberOfRows} or
      the partition Pi. */
   if ( monomialFlag ) {
      Pi = allocPartition();
      Pi->degree = degree;
      Pi->pointList = allocIntArrayDegree();
      Pi->invPointList = allocIntArrayDegree();
      Pi->cellNumber = allocIntArrayDegree();
      Pi->startCell = allocIntArrayDegree();
      for ( i = 1 ; i <= degree ; ++i ) {
         Pi->pointList[i] = Pi->invPointList[i] = i;
         Pi->cellNumber[i] = ( i <= M_L->numberOfRows) ? 1 :
                             ( i <= degree - M_L->numberOfRows ) ? 2 : 3;
      }
      Pi->startCell[1] = 1;
      Pi->startCell[2] = M_L->numberOfRows + 1;
      Pi->startCell[3] = degree - M_L->numberOfRows + 1;
      Pi->startCell[4] = degree + 1;;
      SSS_Lambda_Lambda.refine = partnStabRefine;
      SSS_Lambda_Lambda.familyParm_L[0].ptrParm = (void *) Pi;
      SSS_Lambda_Lambda.familyParm_R[0].ptrParm = (void *) Pi;
   }
   else {
      Lambda = allocPointSet();
      Lambda->degree = degree;
      Lambda->size = M_L->numberOfRows;
      Lambda->pointList = allocIntArrayDegree();
      for ( i = 1 ; i <= M_L->numberOfRows ; ++i )
         Lambda->pointList[i] = i;
      Lambda->pointList[M_L->numberOfRows+1] = 0;
      Lambda->inSet = allocBooleanArrayDegree();
      for ( i = 1 ; i <= degree ; ++i )
         Lambda->inSet[i] = ( i <= M_L->numberOfRows);
      SSS_Lambda_Lambda.refine = setStabRefine;
      SSS_Lambda_Lambda.familyParm_L[0].ptrParm = (void *) Lambda;
      SSS_Lambda_Lambda.familyParm_R[0].ptrParm = (void *) Lambda;
   }

   IIIg_ML_MR.refine = gRowVsColRefine;
   IIIg_ML_MR.familyParm_L[0].ptrParm = (void *) M_L;
   IIIg_ML_MR.familyParm_R[0].ptrParm = (void *) M_R;

   refnFamList[0] = &SSS_Lambda_Lambda;
   refnFamList[1] = &IIIg_ML_MR;
   refnFamList[2] = NULL;

   reducChkList[0] = (monomialFlag) ? isPartnStabReducible : isSetStabReducible;
   reducChkList[1] = isGRowVsColReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = NULL;
   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   extra[0] = NULL;

   if ( monomialFlag )
      initializePartnStabRefn();
   else
      initializeSetStabRefn();

   if ( C_L ) {
      CC_L = C_L;
      CC_R = C_R;
      checkMonomialProperty = (C_L->fieldSize > 2);
      pp = codeIsoProperty;
      options.altInformCosetRep = (monomialFlag ? &informCodeMonIso 
                                                : NULL);
   }
   else {
      MM_L = M_L;
      MM_R = M_R;
      checkMonomialProperty = monomialFlag;
      pp = matrix01IsoProperty;
      options.altInformCosetRep = (monomialFlag ? &informMatrixMonIso 
                                                : &informMatrixIso);
   }
   informCols = colInformFlag;


   return  computeCosetRep( G, pp, refnFamList, reducChkList,
                            specialRefinement, extra, L_L, L_R);
}


/*-------------------------- initializeSetStabRefn ------------------------*/

static void initializeSetStabRefn( void)
{
   knownIrreducible[0] = NULL;
}

/*-------------------------- setStabRefine --------------------------------*/

/* The function implements the refinement family setStabRefine (denoted
   SSS_Lambda in the reference).  This family consists of the elementary
   refinements ssS_{Lambda,i}, where Lambda fixed.  (It is the set to be
   stabilized) and where 1 <= i <= degree.  Application of sSS_{Lambda,i} to
   UpsilonStack splits off from UpsilonTop the intersection of Lambda and the
   i'th cell of UpsilonTop from cell i of the top partition of UpsilonStack and
   pushes the resulting partition onto UpsilonStack, unless sSS_{Lambda,i} acts
   trivially on UpsilonTop, in which case UpsilonStack remains unchanged.

   The family parameter is:
         familyParm[0].ptrParm:  Lambda
   The refinement parameters are:
         refnParm[0].intParm:    i.

   In the expectation that this refinement will be applied only a small number
   of times, no attempt has been made to optimize this procedure. */


static SplitSize setStabRefine(
   const RefinementParm familyParm[],      /* Family parm: Lambda. */
   const RefinementParm refnParm[],        /* Refinement parm: i. */
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
{
   PointSet *Lambda = familyParm[0].ptrParm;
   Unsigned  cellToSplit = refnParm[0].intParm;
   Unsigned  m, last, i, j, temp,
             inLambdaCount = 0,
             outLambdaCount = 0;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const invPointList = UpsilonStack->invPointList,
              *const cellNumber = UpsilonStack->cellNumber,
              *const parent = UpsilonStack->parent,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   char *inSet = Lambda->inSet;
   SplitSize  split;

   /* First check if the refinement acts nontrivially on UpsilonTop. If not
      return immediately. */
   for ( m = startCell[cellToSplit] , last = m + cellSize[cellToSplit] ;
         m < last && (inLambdaCount == 0 || outLambdaCount == 0) ; ++m )
      if ( inSet[pointList[m]] )
         ++inLambdaCount;
      else
         ++outLambdaCount;
   if ( inLambdaCount == 0 || outLambdaCount == 0 ) {
      split.oldCellSize = cellSize[cellToSplit];
      split.newCellSize = 0;
      return split;
   }

   /* Now split cell cellToSplit of UpsilonTop.  A variation of the splitting
      algorithm used in quicksort is applied. */
   i = startCell[cellToSplit]-1;
   j = last;
   while ( i < j ) {
      while ( !inSet[pointList[++i]] );
      while (  inSet[pointList[--j]] );
      if ( i < j ) {
         EXCHANGE( pointList[i], pointList[j], temp)
         EXCHANGE( invPointList[pointList[i]], invPointList[pointList[j]], temp)
      }
   }
   ++UpsilonStack->height;
   for ( m = i ; m < last ; ++m )
      cellNumber[pointList[m]] = UpsilonStack->height;
   startCell[UpsilonStack->height] = i;
   parent[UpsilonStack->height] = cellToSplit;
   cellSize[UpsilonStack->height] = last - i;
   cellSize[cellToSplit] -= (last - i);
   split.oldCellSize = cellSize[cellToSplit];
   split.newCellSize = cellSize[UpsilonStack->height];
   return split;
}


/*-------------------------- isSetStabReducible ---------------------------*/

/* The function isSetStabReducible checks whether the top partition on a given
   partition stack is SSS_Lambda-reducible, where Lambda is a fixed set. If
   so, it returns a pair consisting of a refinement acting nontrivially on
   the top partition and a priority.  Otherwise it returns a structure of
   type RefinementPriorityPair in which the priority field is IRREDUCIBLE.  Assuming
   that a reducing refinement is found, the (reverse) priority is set very
   low (1).  Note that, once this function returns negative in the priority
   field once, it will do so on all subsequent calls.  (The static variable
   knownIrreducible is set to true in this situation.)  Again, no attempt
   at efficiency has been made.  */

static RefinementPriorityPair isSetStabReducible(
   const RefinementFamily *family,
   const PartitionStack *const UpsilonStack)
{
   PointSet *Lambda = family->familyParm_L[0].ptrParm;
   Unsigned    i, cellNo, position;
   BOOLEAN ptsInLambda, ptsNotInLambda;
   RefinementPriorityPair reducingRefn;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   char *inSet = Lambda->inSet;

   /* Check that the refinement mapping really is setStabRefn, as required. */
   if ( family->refine != setStabRefine )
      ERROR( "isSetStabReducible", "Error: incorrect refinement mapping");

   /* If the top partition has previously been found to be SSS-irreducible, we
      return immediately. */
   for ( i = 0 ; knownIrreducible[i] && knownIrreducible[i] != Lambda ; ++i )
      ;
   if ( knownIrreducible[i] ) {
      reducingRefn.priority = IRREDUCIBLE;
      return reducingRefn;
   }

   /* If we reach here, the top partition has not been previously found to be
      SSS-irreducible.  We check each cell in turn to see if it intersects both
      Lambda and Omega - Lambda.  If such a cell is found, we return
      immediately. */
   for ( cellNo = 1 ; cellNo <= UpsilonStack->height ; ++cellNo ) {
      ptsInLambda = ptsNotInLambda = FALSE;
      for ( position = startCell[cellNo] ; position < startCell[cellNo] +
                                           cellSize[cellNo] ; ++position ) {
         if ( inSet[pointList[position]] )
            ptsInLambda = TRUE;
         else
            ptsNotInLambda = TRUE;
         if ( ptsInLambda && ptsNotInLambda ) {
            reducingRefn.refn.family = family;
            reducingRefn.refn.refnParm[0].intParm = cellNo;
            reducingRefn.priority = 1;
            return reducingRefn;
         }
      }
   }

   /* If we reach here, we have found the top partition to be SSS_Lambda
      irreducible, so we add Lambda to the list knownIrreducible and return. */
   for ( i = 0 ; knownIrreducible[i] ; ++i )
      ;
   if ( i < 9 ) {
      knownIrreducible[i] = Lambda;
      knownIrreducible[i+1] = NULL;
   }
   else
      ERROR( "isSetStabReducible", "Number of point sets exceeded max of 9.")

   reducingRefn.priority = IRREDUCIBLE;
   return reducingRefn;
}


/*--------------------------------------------------------------------------*/

/* Static variables shared by gRowVsColRefine and isGRowVsColReducible.  Note
   they are modified only by gRowVsColRefine.  */

   static Unsigned *header = NULL;
   static Unsigned *nonZeroPosition;
   static Unsigned nonZeroCount;
   typedef struct {
      Unsigned rowOrCol;
      Unsigned link;
   } Node;
   static Node *node;
   static BOOLEAN skipFlag = FALSE;

   static Unsigned randBits;
   static unsigned long twoExpRandBits;
   static Unsigned randBitsFlag = 0;
   static Unsigned *randArray = NULL;


/*-------------------------- gRowVsColRefine --------------------------------*/

/* The function implements the refinement families III_RC and III_CR.  Here
   III_RC consists of the elementary refinements IIi_RC_{D,i,j,m}, where 
   IIi_RC_{D,i,j,m} splits from row cell i those rows that have m ones in 
   column cell j, and IIi_CR_{D,i,j,m} splits from column cell i those columns
   that have m ones in row cell j.  Note that from i and j the routine can
   tell whether III_RC or III_CR should be applied.
  
   The family parameter is:
         familyParm[0].ptrParm:  D (the matrix)
   The refinement parameters are:
         refnParm[0].intParm:    i.
         refnParm[1].intParm:    j.
         refnParm[2].intParm:    m.

   As a special convention, j = 0 signifies the same i and j as before,
   with the sums across row or column cells already computed.
*/

static SplitSize gRowVsColRefine(
   const RefinementParm familyParm[],      /* Family parm: D. */
   const RefinementParm refnParm[],        /* Refinement parm: i,j,m. */
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
{
   Matrix_01 *M = familyParm[0].ptrParm;
   Unsigned  i = refnParm[0].intParm,
             j = refnParm[1].intParm,
             m = refnParm[2].intParm;
   Unsigned  nRows = M->numberOfRows;
   Unsigned  degree = UpsilonStack->degree;
   Unsigned  k, p, r, t, cnt, last, last1, rowOrCol, 
             rowOrColSum;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const invPointList = UpsilonStack->invPointList,
              *const cellNumber = UpsilonStack->cellNumber,
              *const parent = UpsilonStack->parent,
              *const startCell = UpsilonStack->startCell,
              *const cellSize = UpsilonStack->cellSize;
   SplitSize  split;
   enum {RC, CR} familySelector;
   static Unsigned numberOfSubcells;

   /* Allocate header, etc, if not already done. */
   if ( !header ) {
      header = (Unsigned *) malloc( twoExpRandBits * sizeof(Unsigned));
      for ( k = 0 ; k < twoExpRandBits ; ++k )      /* Note degree+1 needed */
         header[k] = 0;
      nonZeroPosition = allocIntArrayDegree();
      nonZeroCount = 0;
      node = (Node *) malloc( (degree+2) * sizeof(Node) );
   }

   /* First we check whether we need to compute row/col sums across cells,
      or whether this was already done on a previous call.  If so, we first
      clear the array header. */
   if ( j != 0 && !skipFlag ) {
      for ( k = 1 ; k <= nonZeroCount ; ++k )
         header[nonZeroPosition[k]] = 0;
      nonZeroCount = 0;
      familySelector = (pointList[startCell[i]] <= nRows ) ? RC : CR;
      for ( k = startCell[i] , last = k + cellSize[i] , cnt = 1; k < last ; 
                                                               ++k , ++cnt ) {
         rowOrCol = pointList[k];
         rowOrColSum = 0;
         switch( familySelector ) {
            case RC:
               for ( t = startCell[j] , last1 = t + cellSize[j] ; t < last1 ; 
                                                                  ++t )
                  rowOrColSum += randArray[M->entry[rowOrCol][pointList[t]-nRows]];
               break;
            case CR:
               for ( t = startCell[j] , last1 = t + cellSize[j] ; t < last1 ; 
                                                                  ++t )
                  rowOrColSum += randArray[M->entry[pointList[t]][rowOrCol-nRows]];
               break;
         }
         rowOrColSum &= randBitsFlag;
         node[cnt].rowOrCol = rowOrCol;
         node[cnt].link = header[rowOrColSum];
         if ( header[rowOrColSum] == 0 ) 
            nonZeroPosition[++nonZeroCount] = rowOrColSum;
         header[rowOrColSum] = cnt;
      }
      numberOfSubcells = nonZeroCount;
   }
   skipFlag = FALSE;
   
   /* If cell i does not split, return at once. */
   if ( m == UNKNOWN || header[m] == 0 || numberOfSubcells == 1 ) {
      split.oldCellSize = cellSize[i];
      split.newCellSize = 0;
      return split;
   }

   /* Now split cell i. */
   last = startCell[i] + cellSize[i];
   for ( k = last-1 , p = header[m] ; p != 0 ; --k , p = node[p].link ) {
      t = node[p].rowOrCol;
      r = invPointList[t];
      pointList[r] = pointList[k];
      pointList[k] = t;
      invPointList[t] = k;
      invPointList[pointList[r]] = r; 
   }

   ++k;
   ++UpsilonStack->height;
   for ( r = k ; r < last ; ++r )
      cellNumber[pointList[r]] = UpsilonStack->height;
   startCell[UpsilonStack->height] = k;
   parent[UpsilonStack->height] = i;
   cellSize[UpsilonStack->height] = last - k;
   cellSize[i] -= (last - k);
   split.oldCellSize = cellSize[i];
   split.newCellSize = cellSize[UpsilonStack->height];
   --numberOfSubcells;
   return split;
}


/*-------------------------- isGRowVsColReducible ---------------------------*/

#define familyParm familyParm_L

#define CELL_TYPE(k) (pointList[startCell[k]] <= M_L->numberOfRows ? ROW : COL)

static RefinementPriorityPair isGRowVsColReducible(
   const RefinementFamily *family,
   const PartitionStack *const UpsilonStack)
{
   typedef enum{ ROW, COL} CellType;
   Matrix_01 *M_L = family->familyParm_L[0].ptrParm;
   RefinementPriorityPair reducingRefn;
   static Unsigned processingCell = 0, opposingCell = 0;
   static Unsigned listSize = 0;
   static UnsignedS *list = NULL;
   static UnsignedS *freq = NULL;
   Unsigned i, k, p, maxPos;
   static Unsigned firstRowCell = 0, firstColCell = 0,
                   lastRowCell = 0, lastColCell = 0;
   static UnsignedS *nextCellSameType = NULL;
   UnsignedS  *const pointList = UpsilonStack->pointList,
              *const startCell = UpsilonStack->startCell;
   unsigned long initialSeed = 47;
   SplitSize dummySplit;

   /* Allocate and construct randArray the first time. */
   if ( !randArray ) {
      initializeSeed( initialSeed);
      randBits = 6;
      twoExpRandBits = 64;
      while ( randBits < INT_SIZE && twoExpRandBits <  
                 (unsigned long) UpsilonStack->degree + M_L->setSize ) {
         ++randBits;
         twoExpRandBits <<=1;
      }
      for ( i = 0 ; i < randBits ; ++ i)
         randBitsFlag |= (1u << i);
      randArray = (Unsigned *) malloc( sizeof(Unsigned *) * M_L->setSize);
      for ( i = 0 ; i < M_L->setSize ; ++i ) 
         randArray[i] = 2 * randInteger( 1, twoExpRandBits>>1) - 1;
   }

   /* Allocate list, freq, and nextCellSameType the first time. */
   if ( !list )
      list = allocIntArrayDegree();
   if ( !freq )
      freq = allocIntArrayDegree();
   if ( !nextCellSameType ) {
      nextCellSameType = allocIntArrayDegree();
      nextCellSameType[0] = 0;
   }

   /* Check that the refinement mapping really is rowVsColRefine, as 
      required. */
   if ( family->refine != gRowVsColRefine )
      ERROR( "isGRowVsColReducible", "Error: incorrect refinement mapping");

   /* If the height is 1 (row/col split not yet performed), for regular
      matrices, or 1 or 2, for monomial matrices, return irreducible. */
   if ( UpsilonStack->height <= 1 + checkMonomialProperty ) {
      reducingRefn.priority = IRREDUCIBLE;
      return reducingRefn;
   }

   /* When the stack height reaches 2 (1 row cell, 1 col cell), for normal
      matrices, or 3 (1 row cell, 2 col cells), for monomial matrices, perform
      initializations for nextCellSameType, etc. */
   if ( UpsilonStack->height == 2 + checkMonomialProperty ) {
      firstRowCell = (CELL_TYPE(1) == ROW) ? 1 : 2;
      firstColCell = 3 - firstRowCell;
      lastRowCell = firstRowCell;
      lastColCell = firstColCell;
      nextCellSameType[1] = nextCellSameType[2] = 0;
   }

   /* If we can split the same cell as before using a different weighted
      sum, do so immediately (priority 1). */
   if ( listSize > 0 ) {
      reducingRefn.refn.family = family;
      reducingRefn.refn.refnParm[0].intParm = opposingCell;
      reducingRefn.refn.refnParm[1].intParm = 0;
      reducingRefn.refn.refnParm[2].intParm = list[listSize--];
      reducingRefn.priority = 1;
      skipFlag = TRUE;
      return reducingRefn;
   }

   /* Consider the next opposing cell for the cell being processed, or the
      next cell to be processed if there are no more opposing cells.  First
      we update nextCellSameType  (Note this must be done only here). */
   for (;;) {
      if ( nextCellSameType[opposingCell] != 0 )
         opposingCell = nextCellSameType[opposingCell];
      else if ( processingCell < UpsilonStack->height ) {
         ++processingCell;
         for ( i = MAX(lastRowCell,lastColCell)+1 ; i <= UpsilonStack->height ;
                                                    ++i ) 
            switch( CELL_TYPE(i) ) {
               case ROW:
                  nextCellSameType[lastRowCell] = i;
                  lastRowCell = i;
                  nextCellSameType[i] = 0;
                  break;
               case COL:
                  nextCellSameType[lastColCell] = i;
                  lastColCell = i;
                  nextCellSameType[i] = 0;
                  break;
            }
         opposingCell = ( CELL_TYPE(processingCell) == ROW) ? firstColCell:
                                                              firstRowCell;
      }
      else {
         reducingRefn.priority = IRREDUCIBLE;
         return reducingRefn;
      }

      /* Now we try to split opposingCell using processingCell, and an 
      intersectionCount that guarantees failure.  (This forces rowVsColRefine 
      to compute the header, etc). */
      reducingRefn.refn.refnParm[0].intParm = opposingCell;
      reducingRefn.refn.refnParm[1].intParm = processingCell;
      reducingRefn.refn.refnParm[2].intParm = UNKNOWN;
      dummySplit = gRowVsColRefine( family->familyParm, reducingRefn.refn.refnParm, 
                      UpsilonStack);
                                                  
      /* If no splitting occured of opposing cell via processing cell is 
          possible, nonZeroCount will be 1.  If this occurs, skip to the next 
          pair (processingCell,opposingCell). */
      if ( nonZeroCount == 1 )
         continue;

      /* Now we consider all the possible splittings of opposingCell, reject
         that giving the largest new cell, and put the others on the list. */
      for ( k = 1 ; k <= nonZeroCount ; ++k) {
         freq[k] = 1;
         p = header[nonZeroPosition[k]];
         while ( node[p].link != 0 ) {
            ++freq[k];
            p = node[p].link;
         }
      }
      maxPos = 1;
      for ( k = 2 ; k <= nonZeroCount ; ++k )
         if ( freq[k] > freq[maxPos] )
            maxPos = k;
      listSize = 0;
      for ( k = 1 ; k <= nonZeroCount ; ++k )
         if ( k != maxPos )
            list[++listSize] = nonZeroPosition[k];

      /* Finally return the first entry on the list. */
      reducingRefn.refn.family = family;
      reducingRefn.refn.refnParm[0].intParm = opposingCell;
      reducingRefn.refn.refnParm[1].intParm = processingCell;
      reducingRefn.refn.refnParm[2].intParm = list[listSize--];
      reducingRefn.priority = 1;    
      skipFlag = TRUE;
      return reducingRefn;
   }
}   
      
#undef familyParm



/*-------------------------- informMatrixIso -----------------------------*/

static void informMatrixIso(
   Permutation *perm)
{
   Unsigned trueDegree = perm->degree, i;
   Permutation *shiftPerm;

   if ( MM_L->numberOfRows + informCols * MM_L->numberOfCols > 
                                        options.writeConjPerm ) {
      printf( "     <permutation written to library file>");
      return;
   }
   
   perm->degree = MM_L->numberOfRows;
   printf( "   rows: ");
   writeCyclePerm( perm, 10, 10, 72);
   perm->degree = trueDegree;

   if ( informCols ) {
      shiftPerm = newUndefinedPerm( perm->degree);
      shiftPerm->degree = MM_L->numberOfCols;
      for ( i = 1 ; i <= MM_L->numberOfCols ; ++i )
         shiftPerm->image[i] = perm->image[i+MM_L->numberOfRows] - 
                               MM_L->numberOfRows;
      printf( "\n\n   cols: ");
      writeCyclePerm( shiftPerm, 10, 10, 72);
      shiftPerm->degree = trueDegree;
      deletePermutation( shiftPerm);
   }
}
   

/*-------------------------- informMatrixMonIso --------------------------*/

static void informMatrixMonIso(
   Permutation *perm)
{
   Unsigned trueDegree = perm->degree, i;
   Permutation *shiftPerm;

   if ( (MM_L->numberOfRows+informCols*MM_L->numberOfCols) / (MM_L->setSize-1) > 
                                        options.writeConjPerm ) {
      printf( "     <permutation written to library file>");
      return;
   }

   perm->degree = MM_L->numberOfRows;
   printf( "  rows: ");
   writeImageMonomialPerm( perm, MM_L->setSize, 10);
   perm->degree = trueDegree;

   if ( informCols ) {
      shiftPerm = newUndefinedPerm( perm->degree);
      shiftPerm->degree = MM_L->numberOfCols - MM_L->numberOfRows;
      for ( i = 1 ; i <= shiftPerm->degree ; ++i )
         shiftPerm->image[i] = perm->image[i+MM_L->numberOfRows] - 
                               MM_L->numberOfRows;
      printf( "\n\n  cols: ");
      writeImageMonomialPerm( shiftPerm, MM_L->setSize, 10);
      shiftPerm->degree = trueDegree;
      deletePermutation( shiftPerm);
   }
}


/*-------------------------- informCodeMonIso ----------------------------*/

static void informCodeMonIso(
   Permutation *perm)
{
   Unsigned trueDegree = perm->degree;

   if ( CC_L->length > options.writeConjPerm ) {
      printf( "     <permutation written to library file>");
      return;
   }

   perm->degree = CC_L->length * (CC_L->fieldSize-1) ;
   printf( "   ");
   writeImageMonomialPerm( perm, CC_L->fieldSize, 5);
   perm->degree = trueDegree;

}
