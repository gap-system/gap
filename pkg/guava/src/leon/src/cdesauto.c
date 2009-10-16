/* File cdesauto.c.  Contains functions designAutoGroup and designIsomorphism,
   the main function the design automorphism group and design isomorphism
   programs.  */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>

#include "group.h"
#include "groupio.h"

#include "code.h"
#include "compcrep.h"
#include "compsg.h"
#include "errmesg.h"
#include "matrix.h"
#include "new.h"
#include "readgrp.h"
#include "storage.h"

CHECK( cdesau)

extern GroupOptions options;

static RefinementMapping setStabRefine;
static ReducChkFn isSetStabReducible;
static void initializeSetStabRefn(void);
static RefinementMapping rowVsColRefine;
static ReducChkFn isRowVsColReducible;

static PointSet *knownIrreducible[10]  /* Null terminated 0-base list of */
                = {NULL};              /*  point sets Lambda for which top */
                                       /*  partition on UpsilonStack is */
                                       /*  known to be SSS_Lambda irred. */

static Matrix_01 *DD, *DD_L, *DD_R;
static Code *CC, *CC_L, *CC_R;
static BOOLEAN informCols;


static BOOLEAN matrix01AutoProperty(
   Permutation *s )
{
   return isMatrix01Isomorphism( DD, DD, s, FALSE);
}


static BOOLEAN matrix01IsoProperty(
   Permutation *s )
{
   return isMatrix01Isomorphism( DD_L, DD_R, s, FALSE);
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

static void informDesignIsoPtBlk(
   Permutation *perm);


/*-------------------------- designAutoGroup ------------------------------*/

/* Function designAutoGroup.  Returns a new permutation group representing 
   the automorphism group of the matrix/design D.  The algorithm is based 
   on Figure 9 in the paper "Permutation group algorithms based on partitions" by the 
   author.  */

#define familyParm familyParm_L

PermGroup *designAutoGroup(
   Matrix_01 *const D,            /* The matrix whose group is to be found. */
   PermGroup *const L,            /* A (possibly trivial) known subgroup of the
                                     automorphism group of D.  (A null pointer
                                     designates a trivial group.) */
   Code *const C)                 /* If nonnull, the auto grp of the code C is
                                     computed, assuming its group is contained
                                     in that of the design. */
{
   RefinementFamily SSS_Lambda, III_D;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];
   ExtraDomain *extra[1];
   PointSet *Lambda = allocPointSet();                   /* Set of rows. */
   PermGroup *G;
   Unsigned degree = D->numberOfRows + D->numberOfCols;
   Unsigned i;
   Property *pp;

   /* Construct the symmetric group G of degree rows+cols. */
   G = allocPermGroup();
   sprintf( G->name, "%c%d", SYMMETRIC_GROUP_CHAR, degree);
   G->degree = degree;
   G->baseSize = 0;

   /* Construct the set Lambda of points, ie. Lambda = {1,...,numberOfRows}. */
   Lambda->degree = degree;
   Lambda->size = D->numberOfRows;
   Lambda->pointList = allocIntArrayDegree();
   for ( i = 1 ; i <= D->numberOfRows ; ++i )
      Lambda->pointList[i] = i;
   Lambda->pointList[D->numberOfRows+1] = 0;
   Lambda->inSet = allocBooleanArrayDegree();
   for ( i = 1 ; i <= degree ; ++i )
      Lambda->inSet[i] = ( i <= D->numberOfRows);

   SSS_Lambda.refine = setStabRefine;
   SSS_Lambda.familyParm[0].ptrParm = (void *) Lambda;

   III_D.refine = rowVsColRefine;
   III_D.familyParm[0].ptrParm = (void *) D;

   refnFamList[0] = &SSS_Lambda;
   refnFamList[1] = &III_D;
   refnFamList[2] = NULL;

   reducChkList[0] = isSetStabReducible;
   reducChkList[1] = isRowVsColReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = NULL;
   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   extra[0] = NULL;

   initializeSetStabRefn();

   if ( C ) {
      CC = C;
      pp = codeAutoProperty;
   }
   else {
      DD = D;
      pp = matrix01AutoProperty;
   }
   

   return  computeSubgroup( G, pp, refnFamList, reducChkList,
                            specialRefinement, extra, L);
}
#undef familyParm


/*-------------------------- designIsomorphism ----------------------------*/

/* Function designIsomorphism.  Returns a permutation mapping one specified   
   matrix/design D_L to another matrix/design D_R.  The two matrices must have
   the same number of rows and the same number of columns.  The algorithm is 
   based on Figure 9 in the paper "Permutation group algorithms based on 
   partitions" by the author. */

Permutation *designIsomorphism(
   Matrix_01 *const D_L,          /* The first design. */
   Matrix_01 *const D_R,          /* The second design. */
   PermGroup *const L_L,          /* A known subgroup of Aut(D_L), or NULL. */
   PermGroup *const L_R,          /* A known subgroup of Aut(D_R), or NULL. */
   Code *const C_L,               /* If nonnull, C_R must also be nonull, and */
   Code *const C_R,               /*   any isomorphism of C_L to C_R must map */
                                  /*   D_L to D_R.  A code isomorphism is     */
                                  /*   computed.  */  
   const BOOLEAN colInformFlag)
{
   RefinementFamily SSS_Lambda_Lambda, III_DL_DR;
   RefinementFamily  *refnFamList[3];
   ReducChkFn  *reducChkList[3];
   SpecialRefinementDescriptor *specialRefinement[3];
   ExtraDomain *extra[1];
   PointSet *Lambda = allocPointSet();                   /* Set of rows. */
   PermGroup *G;
   Unsigned degree = D_L->numberOfRows + D_L->numberOfCols;
   Unsigned i;
   Property *pp;

   /* Construct the symmetric group G of degree rows+cols. */
   G = allocPermGroup();
   sprintf( G->name, "%c%d", SYMMETRIC_GROUP_CHAR, degree);
   G->degree = degree;
   G->baseSize = 0;

   /* Construct the set Lambda of points, ie. Lambda = {1,...,numberOfRows}. */
   Lambda->degree = degree;
   Lambda->size = D_L->numberOfRows;
   Lambda->pointList = allocIntArrayDegree();
   for ( i = 1 ; i <= D_L->numberOfRows ; ++i )
      Lambda->pointList[i] = i;
   Lambda->pointList[D_L->numberOfRows+1] = 0;
   Lambda->inSet = allocBooleanArrayDegree();
   for ( i = 1 ; i <= degree ; ++i )
      Lambda->inSet[i] = ( i <= D_L->numberOfRows);

   SSS_Lambda_Lambda.refine = setStabRefine;
   SSS_Lambda_Lambda.familyParm_L[0].ptrParm = (void *) Lambda;
   SSS_Lambda_Lambda.familyParm_R[0].ptrParm = (void *) Lambda;

   III_DL_DR.refine = rowVsColRefine;
   III_DL_DR.familyParm_L[0].ptrParm = (void *) D_L;
   III_DL_DR.familyParm_R[0].ptrParm = (void *) D_R;

   refnFamList[0] = &SSS_Lambda_Lambda;
   refnFamList[1] = &III_DL_DR;
   refnFamList[2] = NULL;

   reducChkList[0] = isSetStabReducible;
   reducChkList[1] = isRowVsColReducible;
   reducChkList[2] = NULL;

   specialRefinement[0] = NULL;
   specialRefinement[1] = NULL;
   specialRefinement[2] = NULL;

   extra[0] = NULL;

   initializeSetStabRefn();
   if ( C_L ) {
      CC_L = C_L;
      CC_R = C_R;
      pp = codeIsoProperty;
   }
   else {
      DD_L = D_L;
      DD_R = D_R;
      pp = matrix01IsoProperty;
      options.altInformCosetRep = (colInformFlag ? &informDesignIsoPtBlk
                                                 : NULL);
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

/* Static variables shared by rowVsColRefine and isRowVsColReducible.  Note
   they are modified only by rowVsColRefine.  */

   static Unsigned *header = NULL;
   static Unsigned *nonZeroPosition;
   static Unsigned nonZeroCount;
   typedef struct {
      Unsigned rowOrCol;
      Unsigned link;
   } Node;
   static Node *node;
   static BOOLEAN skipFlag = FALSE;


/*-------------------------- rowVsColRefine --------------------------------*/

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

static SplitSize rowVsColRefine(
   const RefinementParm familyParm[],      /* Family parm: D. */
   const RefinementParm refnParm[],        /* Refinement parm: i,j,m. */
   PartitionStack *const UpsilonStack)     /* The partition stack to refine. */
{
   Matrix_01 *D = familyParm[0].ptrParm;
   Unsigned  i = refnParm[0].intParm,
             j = refnParm[1].intParm,
             m = refnParm[2].intParm;
   Unsigned  nRows = D->numberOfRows;
   Unsigned  degree = UpsilonStack->degree;
   Unsigned  lastRow, lastCol, k, p, r, t, cnt, last, last1, rowOrCol, 
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
      header = allocIntArrayDegree();
      for ( k = 0 ; k <= degree+1 ; ++k )      /* Note degree+1 needed */
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
                  rowOrColSum += D->entry[rowOrCol][pointList[t]-nRows];
               break;
            case CR:
               for ( t = startCell[j] , last1 = t + cellSize[j] ; t < last1 ; 
                                                                  ++t )
                  rowOrColSum += D->entry[pointList[t]][rowOrCol-nRows];
               break;
         }
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
   if ( header[m] == 0 || numberOfSubcells == 1 ) {
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


/*-------------------------- isRowVsColReducible ---------------------------*/

#define familyParm familyParm_L

#define CELL_TYPE(k) (pointList[startCell[k]] <= D_L->numberOfRows ? ROW : COL)

static RefinementPriorityPair isRowVsColReducible(
   const RefinementFamily *family,
   const PartitionStack *const UpsilonStack)
{
   typedef enum{ ROW, COL} CellType;
   Matrix_01 *D_L = family->familyParm_L[0].ptrParm;
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
   if ( family->refine != rowVsColRefine )
      ERROR( "isRowVsColReducible", "Error: incorrect refinement mapping");

   /* If the height is 1 (row/col split not yet performed), return 
      irreducible. */
   if ( UpsilonStack->height == 1 ) {
      reducingRefn.priority = IRREDUCIBLE;
      return reducingRefn;
   }

   /* When the stack height reaches 2 (1 row cell, 1 col cell), perform
      initializations for nextCellSameType, etc. */
   if ( UpsilonStack->height == 2 ) {
      firstRowCell = (CELL_TYPE(1) == ROW) ? 1 : 2;
      firstColCell = 3 - firstRowCell;
      lastRowCell = firstRowCell;
      lastColCell = firstColCell;
      nextCellSameType[1] = nextCellSameType[2] = 0;
   }

   /* If we can split the same cell as before using a different intersection
      count, do so immediately (priority 1). */
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
      reducingRefn.refn.refnParm[2].intParm = UpsilonStack->degree + 1;
      rowVsColRefine( family->familyParm, reducingRefn.refn.refnParm, 
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




/*-------------------------- informDesignIsoPtBlk ------------------------*/

static void informDesignIsoPtBlk(
   Permutation *perm)
{
   Unsigned trueDegree = perm->degree, i;
   Permutation *shiftPerm;

   if ( DD_L->numberOfRows + informCols * DD_L->numberOfCols > 
                                        options.writeConjPerm ) {
      printf( "     <permutation written to library file>");
      return;
   }
   
   perm->degree = DD_L->numberOfRows;
   printf( "   points: ");
   writeCyclePerm( perm, 12, 12, 72);
   perm->degree = trueDegree;

   if ( informCols ) {
      shiftPerm = newUndefinedPerm( perm->degree);
      shiftPerm->degree = DD_L->numberOfCols;
      for ( i = 1 ; i <= DD_L->numberOfCols ; ++i )
         shiftPerm->image[i] = perm->image[i+DD_L->numberOfRows] - 
                               DD_L->numberOfRows;
      printf( "\n\n   blocks: ");
      writeCyclePerm( shiftPerm, 12, 12, 72);
      shiftPerm->degree = trueDegree;
      deletePermutation( shiftPerm);
   }
}
   
