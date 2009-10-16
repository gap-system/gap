/* File compsg.c. */

/* Copyright (C) 1992 by Jeffrey S. Leon.  This software may be used freely
   for educational and research purposes.  Any other use requires permission
   from the author. */

/* Contains function computeSubgroup, which may be used to
   compute the subgroup G_pP a specified group G (with known base and strong
   generating set) consisting of those elements satisfying a specified
   subgroup-type property pP.  One or more  families RRR of pP-refinement
   processes must be supplied as input.  One of these families should be the
   family OOO_G based on the orbit structure of G (unless G is the symmetric
   group of a very large subgroup of it).  If a known subgroup L of G_pP is
   known in advance, the algorithm takes advantage of it. The function returns
   a newly-created group equal to G_pP. */

/* Since refinements are symmetric here, we define the following. */
#define familyParm familyParm_L

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "group.h"

/* Bug fix for Waterloo C (IBM 370). */
#if defined(IBMCMSWC) && !defined(SIGNED) && !defined(EXTRA_LARGE)
#define FIXUP (unsigned short)
#define FIXUP1 short
#else
#define FIXUP
#define FIXUP1 Unsigned
#endif

#ifdef ALT_TIME_HEADER
#include "cputime.h"
#endif

#include "addsgen.h"
#include "chbase.h"
#include "copy.h"
#include "cstrbas.h"
#include "errmesg.h"
#include "inform.h"
#include "new.h"
#include "optsvec.h"
#include "orbit.h"
#include "orbrefn.h"
#include "partn.h"
#include "permgrp.h"
#include "permut.h"
#include "ptstbref.h"
#include "rprique.h"
#include "storage.h"

CHECK( compsg)

extern GroupOptions options;
RefinementFamily ptStabFamily = {pointStabRefine};

#define BACKTRACK  \
   {if ( options.statistics )  \
      ++nodesPruned[d];  \
   while ( d > 0 && RPQ_SIZE(Gamma[d]) < K->basicOrbLen[d] ) { \
      if ( options.statistics ) {  \
         nodesVisited[d] += RPQ_SIZE(Gamma[d]);  \
         nodesPruned[d] += RPQ_SIZE(Gamma[d]);  \
      }  \
      --d;  \
   }  \
   h = AAA->n_[d];  \
   if ( d > 0 ) {  \
      popToHeight( UpsilonStack, AAA->n_[d]);  \
      for ( m = 0 ; extra[m] ; ++m )  \
         xPopToLevel( extra[m]->xUpsilonStack,  \
                      extra[m]->applyAfter, AAA->n_[d]);  \
      f = AAA->invOmega[AAA->alphaHat[d]] - 1;  \
      for ( m = 0 ; m < orbRefnCount ; ++m )  {  \
         e[m] = q_[m][d] - 1;  \
         tHatWord[m].invWord[tHatWord[m].lengthAtLevel[d-1]] = NULL;  \
         tHatWord[m].revWord = initialRevWord[m] -   \
                  tHatWord[m].lengthAtLevel[d-1];  \
      }   \
   }  \
   continue;}


static void buildDeltaList(
   PermGroup *G,                   /* The perm group (base/sgs known). */
   UnsignedS *DeltaList[]);        /* Set to the list that is constructed. */


/*-------------------------- Compute Subgroup -----------------------------*/

/* Given a permutation group G and a property pP such that G_pP (the subset
   of G consisting of those elements satisfying pP) is a subgroup of G, this
   function computes and returns a new permutation group equal to G_pP.  In
   addition to G and pP, a family RRR of pP-refinement processes must be
   supplied as input to the function.  This is supplied in the form of three
   array parameters: rRR, isReducible, and orbRefnGroup.  Here
   *rRR[1],*rRR[2],... are families of pP-refinement processes.  (See file
   group.h for representation of a refinement family.), and
   *isReducible[1],*isReducible[2],... are functions taking a partition
   stack UpsilonStack and a refinement family (with fixed refinement mapping)
   as parameters such that isReducible[i] a refinement-priority pair:  If the
   top partition UpsilonTop on UpsilonStack is RRR-irreducible, a priority of
   IRREDUCIBLE is returned; otherwise a refinement acting nontrivially on
   UpsilonTop and a priority indicated the relative desirability of this
   refinement are returned.  For most refinement families, orbRefnGroup will be
   NULL; when orbRefnGroup[i] is nonnull, computeSubgroup will pass extra
   information to the refinement rRR[i] and reducibility-check functions
   isReducible[i]. */

PermGroup *computeSubgroup(
   PermGroup *const G,        /* The permutation group, as above.  A base/sgs
                                 must be known (unless name is "symmetric"). */
   Property *const pP,        /* The subgroup-type property, as above.  A value
                                 of NULL may be used to suppress checking pP.*/
   RefinementFamily           /* (Ptr to) null-terminated list of refinement */
       *const RRR[],          /*    family pointers (List starts rrR[1].) */
   ReducChkFn *const          /* (Ptr to) null-terminated list of pointers */
       isReducible[],         /*    to functions checking rRR-reducibility. */
   SpecialRefinementDescriptor
       *const
       specialRefinement[],   /*   (Ptr to) list of permutation ptrs, some */
                              /*   possibly null.  For nonnull pointers, */
                              /*   computeSubgroup will keep track of perm t. */
   ExtraDomain *extra[],      /* extra[1], extra[2], ... are extra domains.
                                 pointer terminates list. */
   PermGroup *const L)        /* A known (possibly trivial) subgroup of G_pP.
                                 (Null pointer signifies a trivial group.) */

{
   PermGroup      *K, *altK;
   RBase          *AAA;
   PartitionStack *UpsilonStack;
   THatWordType   tHatWord[4];
   UnsignedS      **initialRevWord[4], **beginRevWord[4];
   UnsignedS      *betaHat = allocIntArrayBaseSize();
   RPriorityQueue **Gamma = (RPriorityQueue **) allocPtrArrayBaseSize();
   UnsignedS      **DeltaList =           /* DeltaList[d][1..] is a null-   */
                    allocPtrArrayBaseSize();    /* terminated list of points i with */
                                          /*  alphahat[d] in Delta[i](K)    */
   Unsigned       d, f, h, i, j, m, pt, delta, oldF, firstMoved;
   UnsignedS      e[4];
   UnsignedS      *eta = allocIntArrayDegree();
   UnsignedS*     q_[4];            /* alloc (mbs+2)*sizeof(UnsignedS) each */
   BOOLEAN        backtrackFlag;
   UnsignedS      *pp;
   UnsignedS      **p;
   Unsigned       maxBaseChangeLevel;
   SplitSize      split, xSplit;
   UnsignedS      **minPointOfOrbit = (UnsignedS **) allocPtrArrayBaseSize();
   UnsignedS      **minPointKnown = (UnsignedS **) allocPtrArrayBaseSize();
   UnsignedS      *minPointKnownCount = allocIntArrayBaseSize();
   unsigned long  *nodesVisited = allocLongArrayBaseSize();
   unsigned long  *nodesPruned = allocLongArrayBaseSize();
   unsigned long  *nodesEssential = allocLongArrayBaseSize();
   UnsignedS      *lastGeneratorBaseImage = allocIntArrayBaseSize();
   Permutation    *gen, *newPerm;
   clock_t        RBaseTime, optGroupTime, backtrackTime, startTime;
   Unsigned       orbRefnCount;
   UnsignedS      *longRepLen = allocIntArrayBaseSize();
   Unsigned       newGenCount = 0;
   UnsignedS      *basicCellSize = allocIntArrayBaseSize();
   ExtraDomain    *ex;

   /* Allocate q_. */
   for ( i = 0 ; i <= 3 ; ++i )
      q_[i] = allocIntArrayDegree();

   /* Initialize nodesVisited and nodesPruned. */
   for ( i = 0 ; i <= options.maxBaseSize+1 ; ++i )
      nodesVisited[i] = nodesPruned[i] = 0;
   nodesVisited[0] = 1;

   /* Set orbRefnCount.  */
   for ( i = 0 ; specialRefinement[i] && specialRefinement[i]->refnType == 'O' ;
         ++i )
      ;
   orbRefnCount = i;

   if ( options.inform ) {
      informOptions();
      informGroup( G);
   }

   /* Figure 9, lines 3-4.  These lines construct an rRR-base AAA for G.  (The
      base and strong generating sets for G itself are changed.  The base for L
      is not changed to alphaHat.  A null terminator is added to base of
      the containing groups.  */
   startTime = CPU_TIME();
   AAA = constructRBase( G, RRR, isReducible, specialRefinement,
         basicCellSize, extra);
   for ( m = 0 ; specialRefinement[m] ; ++m )
      specialRefinement[m]->leftGroup->base
                    [specialRefinement[m]->leftGroup->baseSize+1] = 0;
   deletePartitionStack( AAA->PsiStack);
   AAA->PsiStack = NULL;

   RBaseTime = CPU_TIME();
   /* Now compression is done by level in constructRBase.
   if ( options.compress )
      compressGroup( G); */
   for ( gen = G->generator ; gen ; gen = gen->next )
      adjoinInverseGen( G, gen);
   for ( i = 1 ; i <= G->baseSize ; ++i )
      longRepLen[i] = reconstructBasicOrbit( G, i);
   if ( options.inform )
      meanCosetRepLen( G);
   expandSGS( G, longRepLen, basicCellSize, AAA->ell);
   if ( options.inform )
      meanCosetRepLen( G);
   optGroupTime = CPU_TIME();

   /* Here we adjust each generator of G such that it maps 0 to 0 and
      degree+1 to degree+1.  This is necessary for the procedure
      orbRefine. */
   for ( gen = G->generator ; gen ; gen = gen->next ) {
      gen->image[0] = gen->invImage[0] = 0;
      gen->image[G->degree+1] = gen->invImage[G->degree+1] = G->degree+1;
   }

   maxBaseChangeLevel = MAX( 0, MIN( options.maxBaseChangeLevel, AAA->ell) );
   firstMoved = AAA->ell + 1;
   if ( options.statistics )
      for ( i = 0 ; i <= AAA->ell ; ++i ) {
         nodesEssential[i] = 1;
         lastGeneratorBaseImage[i] = AAA->alphaHat[i];
      }

   /* Here we build an array q_[0][1],...,q_[orbRefnCount-1][AAA->ell] such that
      alphaHat[d] = specialRefinement[m]->leftGroup->base[q_[d]].  Here
      the array e is used as a temporary variable. */
   for ( m = 0 ; m < orbRefnCount ; ++m ) {
      j = 1;
      for ( i = 1 ; i <= specialRefinement[m]->leftGroup->baseSize ; ++i )
         if ( specialRefinement[m]->leftGroup->base[i] == AAA->alphaHat[j] )
            q_[m][j++] = i;
   }

   if ( L )
      changeBase( L, AAA->alphaHat );

   /* Create the group K and initialize it to L (with base alphaHat).
      Also, if K is nontrivial, build its initial Delta-List. */
   if ( L )
      K = L;
   else {
      K = newTrivialPermGroup( G->degree);
      changeBase( K, AAA->alphaHat);
   }
   for ( i = 1 ; i <= AAA->ell+1 ; ++i )
      DeltaList[i] = allocIntArrayBaseSize();
   if ( isNontrivialGroup(K) )
      buildDeltaList( K, DeltaList);

   /* Allocate the R-Priority queues Gamma[1],...,Gamma[ell] and the
      permutations tHatWord[i], 0 <= i < orbRefnCount,
      and initialized to the identity below. */
   for ( i = 1 ; i <= AAA->ell ; ++i )
      Gamma[i] = newRPriorityQueue( G->degree, basicCellSize[i]);
   for ( m = 0 ; m < orbRefnCount ; ++m ) {
      beginRevWord[m] = (UnsignedS **) malloc( (options.maxWordLength+2) * sizeof(UnsignedS**));
      tHatWord[m].lengthAtLevel = (UnsignedS *) malloc( (options.maxBaseSize+2) * sizeof(Unsigned *) );
      tHatWord[m].revWord = initialRevWord[m] = beginRevWord[m] + options.maxWordLength-1;
      tHatWord[m].invWord = (UnsignedS **) malloc((options.maxWordLength+2) * sizeof(UnsignedS**));
      if ( ! tHatWord[m].lengthAtLevel || !beginRevWord[m] || !tHatWord[m].invWord )
         ERROR( "computeSubgroup", "Out of memory.")
      tHatWord[m].revWord[0] = NULL;
      tHatWord[m].invWord[0] = NULL;
      for ( i = 0 ; i <= AAA->ell ; ++i )
         tHatWord[m].lengthAtLevel[i] = 0;
   }

   /* Allocate and initialize the arrays used to keep track of which points
      are minimal in their K_betaHat[1..d-1] orbits.  In general,
      minPointOfOrbit[i][..] will keep track of the orbits of
      K'^(i+firstMoved), 0 <= i <= maxBaseChangeLevel, where the ' indicates
      the alternate base betaHat[1..]. */
   for ( i = 0 ; i <= maxBaseChangeLevel ; ++i ) {
      minPointOfOrbit[i] = allocIntArrayDegree();
      for ( pt = 1 ; pt <= G->degree ; ++pt )
         minPointOfOrbit[i][pt] = 0;
      minPointKnownCount[i] = 0;
      minPointKnown[i] = allocIntArrayDegree();
   }

   /* Figure 9, lines 5-12.  The following lines perform initializations
      corresponding to starting at the root of the tree. */
   if ( maxBaseChangeLevel > 0 )
      altK = copyOfPermGroup( K);
   else
      altK = K;
   UpsilonStack = newPartitionStack( G->degree);
   h = 1;
   f = 0;
   for ( i = 0 ; specialRefinement[i] ; ++i )
      e[i] = 0;
   if ( AAA->n_[1] == 1 ) {
      d = 1;
      initFromPartnStack( Gamma[1], UpsilonStack, 1, AAA);
   }
   else
      d = 0;

   backtrackFlag = FALSE;
   for ( m = 0 ; extra[m] ; ++m ) {
      ex = extra[m];
      while ( ex->applyAfter[i = ex->xUpsilonStack->height] == 0 ) {
  /*     xSplit = (ex->xRRR[i].family->refine)(
                          ex->xRRR[i].family->familyParm,
                          ex->xRRR[i].refnParm,
                          ex->xUpsilonStack); */
         if ( xSplit.newCellSize != ex->xA_[i] ) {
            backtrackFlag = TRUE;
            break;
         }
      }
      if ( backtrackFlag )
         break;
   }
   if ( backtrackFlag )
      h = 0;

   /* Figure 9, line 13.  The main loop begins here.  On each pass, the
      elementary P-refinement aAA[h] is applied to the top partition on
      UpsilonStack. */
   while ( h > 0 ) {

      /* Figure 9, lines 14-21.  The code which follows is executed whenever
         a node is entered, either by descending from its parent or after
         backtracking from a descendant of a sibling. */

      if ( h == AAA->n_[d] ) {
         if ( options.statistics )
            ++nodesVisited[d];
         betaHat[d] = removeMin( Gamma[d] );
         if ( d < firstMoved && betaHat[d] != AAA->alphaHat[d] ) {
            firstMoved = d;
            for ( i = (L ? 0 : 1) ; i <= maxBaseChangeLevel ; ++i ) {
               for ( j = 1 ; j <= minPointKnownCount[i] ; ++j )
                  minPointOfOrbit[i][minPointKnown[i][j]] = 0;
               minPointKnownCount[i] = 0;
            }
         }
         /* In the following, should we check K^(firstMoved) in place of K? */
         if ( K->order->noOfFactors > 0 ) {
            backtrackFlag = FALSE ;
            for ( pp = DeltaList[d]+1 ; *pp ; ++pp )
               /* In the following line, the second condition is always true
                  if L is trivial.  Otherwise ???. */
               if ( *pp <= firstMoved + maxBaseChangeLevel &&
                                            *pp >= firstMoved )
                  if ( AAA->invOmega[betaHat[*pp]] >
                       AAA->invOmega[ FIXUP minimalPointOfOrbit( altK, *pp ,
                                      betaHat[d],
                                      minPointOfOrbit[*pp-firstMoved],
                                      minPointKnown[*pp-firstMoved],
                                      &minPointKnownCount[*pp-firstMoved],
                                      AAA->invOmega) ] ) {
                     backtrackFlag = TRUE;
                     break;
                  }
                  else
                     ;
               else
                  if (AAA->invOmega[betaHat[*pp]] > AAA->invOmega[betaHat[d]]) {
                     backtrackFlag = TRUE;
                     break;
                  }
         if ( backtrackFlag )
            BACKTRACK
         }
      }

      /* Figure 9, line 22.  Now aAA[h] is applied to the top partition
         on UpsilonStack, and the result is pushed onto UpsilonStack. */
      if ( h == AAA->n_[d] )
         AAA->aAA[h].refnParm[0].intParm = betaHat[d];
      else if ( AAA->aAA[h].family->refine == orbRefine ) {
         for ( m = 0 ; AAA->aAA[h].family->familyParm[0].ptrParm !=
                       specialRefinement[m]->rightGroup ; ++m )
            ;
         AAA->aAA[h].family->familyParm[1].intParm = e[m] + 1;
         AAA->aAA[h].family->familyParm[2].ptrParm = &tHatWord[m];
      }
      split = (AAA->aAA[h].family->refine)( AAA->aAA[h].family->familyParm,
                             AAA->aAA[h].refnParm, UpsilonStack );

      /* Figure 9, lines 23-32.  The following lines attempt to prune the
         current node using Prop. 7(c). */
      if ( split.newCellSize != AAA->a_[h] )
         BACKTRACK
      else
         ++h;

      oldF = f;
      if ( split.newCellSize == 1 )
         eta[++f] = UpsilonStack->pointList[UpsilonStack->startCell[h]];
      if ( split.oldCellSize == 1 )
         eta[++f] =
                UpsilonStack->pointList[UpsilonStack->startCell[AAA->b_[h-1]]];
      for ( i = oldF+1 , backtrackFlag = FALSE ; i <= f ; ++i ) {
         for ( m = 0 ; m < orbRefnCount ; ++m ) {
            if ( AAA->omega[i] ==
                         specialRefinement[m]->leftGroup->base[e[m]+1] ) {
               ++e[m];
               delta = eta[i];
               for ( p = tHatWord[m].invWord ; *p ; ++p )
                  delta = (*p)[delta];
               if (specialRefinement[m]->leftGroup->schreierVec[e[m]][delta])
                  while ( (gen = specialRefinement[m]->leftGroup->
                           schreierVec[e[m]][delta]) != FIRST_IN_ORBIT ) {
                     *p = gen->invImage;
                     *(--tHatWord[m].revWord) = gen->image;
                     delta = (*p++)[delta];
                     *p = NULL;
                  }
               else {
                  backtrackFlag = TRUE;
                  break;
               }
            }
            else {
               delta = eta[i];
               for ( p = tHatWord[m].invWord ; *p ; ++p )
                  delta = (*p)[delta];
               if ( delta != AAA->omega[i] ) {
                  backtrackFlag = TRUE;
                  break;
               }
            }
            if ( backtrackFlag )
               break;
         }
         if ( backtrackFlag )
            break;
      }
      if ( backtrackFlag)
         BACKTRACK

      for ( m = 0 ; extra[m] ; ++m ) {
         ex = extra[m];
         while ( ex->applyAfter[i = ex->xUpsilonStack->height] == h-1 ) {
      /*    xSplit = (ex->xRRR[i].family->refine)(
                             ex->xRRR[i].family->familyParm,
                             ex->xRRR[i].refnParm,
                             ex->xUpsilonStack); */
            if ( xSplit.newCellSize != ex->xA_[i] ) {
               backtrackFlag = TRUE;
               break;
            }
         }
         if ( backtrackFlag )
            break;
      }

      if ( h == G->degree ) {

         /* Figure 9, lines 34-40.  The following lines add a new strong
            generator, if appropriate. */
         newPerm = permMapping( G->degree, AAA->omega, eta);
         if ( (!pP || pP( newPerm)) &&
               !isIdentityElt( G, newPerm) ) {
            if ( options.genNamePrefix[0] != '\0' ) {
               strcpy( newPerm->name, options.genNamePrefix);
               sprintf( newPerm->name + strlen(newPerm->name), "%02u",
                        ++newGenCount);
            }
            addStrongGenerator( K, newPerm, TRUE );
            if ( options.inform )
               informNewGenerator( K, firstMoved );
            if ( maxBaseChangeLevel > 0 ) {
               deletePermGroup( altK);
               altK = copyOfPermGroup( K);
               betaHat[AAA->ell+1] = 0;
               conjugateGroupByPerm( altK, newPerm);
            }
            /* Can the following be done only for i = 0? */
            for ( i = 0 ; i <= maxBaseChangeLevel ; ++i ) {
               for ( j = 1 ; j <= minPointKnownCount[i] ; ++j )
                  minPointOfOrbit[i][minPointKnown[i][j]] = 0;
               minPointKnownCount[i] = 0;
            }
            buildDeltaList( K, DeltaList);
            for ( i = firstMoved + 1 ; i <= AAA->ell ; ++i )
               makeEmpty( Gamma[i] );
            if ( options.statistics ) {
               --nodesPruned[AAA->ell];
               for ( i = 1 ; i <= AAA->ell &&
                             newPerm->image[AAA->alphaHat[i]] ==
                             lastGeneratorBaseImage[i] ; ++i )
                  ;
               for ( j = i ; j <= AAA->ell ; ++j ) {
                  lastGeneratorBaseImage[i] = newPerm->image[AAA->alphaHat[i]];
                  ++nodesEssential[j];
               }
            }
         }
         else
            deletePermutation( newPerm);
         BACKTRACK
      }

      else if ( h == AAA->n_[d+1] ) {

         /* The following lines compute the set Gamma[d+1] of values of
            betaHat[d+1] corresponding to possible children of the current
            node, and then descend to the leftmost child. */
         if ( d >= firstMoved && d < firstMoved+maxBaseChangeLevel ) {
            insertBasePoint( altK, d, betaHat[d] );
            for ( i = d+1-firstMoved ; i <= maxBaseChangeLevel ; ++i ) {
               for ( j = 1 ; j <= minPointKnownCount[i] ; ++j )
                  minPointOfOrbit[i][minPointKnown[i][j]] = 0;
               minPointKnownCount[i] = 0;
            }
         }
         for ( m = 0 ; m < orbRefnCount ; ++m ) {
            if ( d > 0 )
               tHatWord[m].lengthAtLevel[d] = tHatWord[m].lengthAtLevel[d-1];
            else
               tHatWord[m].lengthAtLevel[0] = 0;
            while ( tHatWord[m].invWord[tHatWord[m].lengthAtLevel[d]] )
               ++tHatWord[m].lengthAtLevel[d];
         }
         ++d;
         initFromPartnStack( Gamma[d], UpsilonStack, AAA->p_[d], AAA);
      }
   }

   /* Free temporary storage. */
   if ( maxBaseChangeLevel > 0 )
      deletePermGroup( altK);
   for ( m = 0 ; m < orbRefnCount ; ++m ) {
      /*DEBUG -- Following code temporarily commented out because it corrupts
        the heap.
      free( tHatWord[m].invWord);
      free( beginRevWord[m]);
      END DEBUG*/
   }
   for ( i = 1 ; i <= AAA->ell ; ++i)
      deleteRPriorityQueue( Gamma[i]);

   /* Write summary information for subgroup computed, if requested. */
   backtrackTime = CPU_TIME();
   if ( options.inform ) {
      informSubgroup( K);
      informTime( startTime, RBaseTime, optGroupTime, backtrackTime);
   }

   /* Write statistics to standard output, if requested. */
   if ( options.statistics ) {
      --nodesPruned[AAA->ell];    /* identity node not counted as pruned. */
      informStatistics( AAA->ell, nodesVisited, nodesPruned, nodesEssential);
   }

   /* Free pseudo-stack storage. */
   freeIntArrayBaseSize( betaHat);
   freePtrArrayBaseSize( Gamma);
   freePtrArrayBaseSize( DeltaList);
   freeIntArrayDegree( eta);
   freePtrArrayBaseSize( minPointOfOrbit);
   freePtrArrayBaseSize( minPointKnown);
   freeIntArrayBaseSize( minPointKnownCount);
   freeLongArrayBaseSize( nodesVisited);
   freeLongArrayBaseSize( nodesPruned);
   freeLongArrayBaseSize( nodesEssential);
   freeIntArrayBaseSize( lastGeneratorBaseImage);
   freeIntArrayBaseSize( longRepLen);
   freeIntArrayBaseSize( basicCellSize);
   for ( i = 0 ; i <= 3 ; ++i )
      freeIntArrayDegree( q_[i]);

   /* Return to caller. */
   return K;
}



/*-------------------------- buildDeltaList -------------------------------*/

/* The function buildDeltaList may be used to construct a two-dimensional
   array DeltaList, such that DeltaList[d][1..] is the null-terminated list
   of those integers i with i <= d such that the d'th base point of the group G
   lies in the i'th basic orbit. */

static void buildDeltaList(
   PermGroup *G,                   /* The perm group (base/sgs known). */
   UnsignedS *DeltaList[])         /* Set to the list that is constructed. */
{
   Unsigned  d, i, listLen, basePt;
   for ( d = 1 ; d <= G->baseSize ; ++d) {
      listLen = 0;
      basePt = G->base[d];
      for ( i = 1 ; i <= d ; ++i )
         if ( G->schreierVec[i][basePt] )
            DeltaList[d][++listLen] = i;
      DeltaList[d][++listLen] = 0;
   }
}
