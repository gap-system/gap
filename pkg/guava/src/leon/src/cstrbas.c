/* File cstrbas.c.  Contains function constructRBase, which may be used to
   construct an RRR-base.  Also contains function getOptimInfo, which may
   invoked during RRR-base construction by functions that check
   RRR-reducbility. */

#include <stddef.h>
#include <stdlib.h>
#include <time.h>

#include "group.h"

/* Bug fix for Waterloo C (IBM 370). */
#if defined(IBMCMSWC) && !defined(SIGNED) && !defined(EXTRA_LARGE)
#define FIXUP1 short
#else
#define FIXUP1 Unsigned
#endif

#include "chbase.h"
#include "cstborb.h"
#include "inform.h"
#include "new.h"
#include "orbrefn.h"
#include "permgrp.h"
#include "ptstbref.h"
#include "optsvec.h"
#include "storage.h"

CHECK( cstrba)

extern GroupOptions options;
extern RefinementFamily ptStabFamily;


/*-------------------------- constructRBase -------------------------------*/

/* This function allocates and constructs an RRR-base for a permutation group,
   and it returns a pointer to the R-base that is constructed.  The parameters
   are as follows:

         G:           The permutation group (pointer) for which the RRR-base is
                      to be constructed.  A base and strong generating set must
                      be known.  Note that the base and strong generating set
                      for G will be changed to that in the RRR-base.
         RRR:         A null terminated list of refinement family pointers (zero
                      based).  These describe the refinement families that
                      compose the superfamily RRR.
         isReducible: A null terminated list of functions that check
                      reducibility (zero-based).  Specifically, for each i the
                      function *isReducible[i] checks RRR[i]-reducibility.
          L:          A known subgroup (pointer)of the group G_pP that is to be
                      constructed.  A base and strong generating set must be
                      known.  Optionally, if L = 1, the argument may be NULL.
                      Note that L the base and strong generating set for L will
                      be changed to that the base is AlphaHat (in the RRR-base).

   The line numbers referred to below are those in Figure 10 of "Permutation
   group algorithms based on Partitions" by J. Leon. */

RBase *constructRBase(
   PermGroup *const G,
   RefinementFamily *const RRR[],
   ReducChkFn *const isReducible[],
   SpecialRefinementDescriptor *const specialRefinement[],
   UnsignedS basicCellSize[],
   ExtraDomain *extra[] )
{
   Unsigned f, h, i, m, pt, sGenCount;
   unsigned long minPriority;
   UnsignedS k[10];
   SplitSize split;
   RefinementPriorityPair refPriPair;
   Refinement bestRefinement;
   RBase *AAA = newRBase( G->degree);
   UnsignedS *const startCell = AAA->PsiStack->startCell,
             *const pointList = AAA->PsiStack->pointList,
             *const omega = AAA->omega;
   Permutation *gen;
   THatWordType tHatWord;

   /* Set tHatWord to a trivial word. */
   tHatWord.invWord = malloc( sizeof(UnsignedS *) );
   tHatWord.revWord = malloc( sizeof(UnsignedS *) );
   tHatWord.invWord[0] = tHatWord.revWord[0] = NULL;


   /* Here we trim unnecessary strong generators if so requested. */
   for ( sGenCount = 0 , gen = G->generator ; gen ;
         gen = gen->next )
      ++sGenCount;
   if ( sGenCount > options.trimSGenSetToSize )
        removeRedunSGens( G, 1);

   /* Here we construct the complete orbit structure at the top level. */
   for ( m = 0 ; specialRefinement[m] ; ++m )
      constructAllOrbitInfo( specialRefinement[m]->leftGroup, 1);

   /* Figure 10, lines 3-5. Note newRBase above already initialized
      AAA->PsiStack. */
   for ( i = 0 ; specialRefinement[i] ; ++i )
      k[i] = 0;
   AAA->ell = 0;
   f = 0;
   AAA->n_[0] = 0;
   /* Array f_ not needed.
   AAA->f_[0] = 0;
   AAA->f_[1] = 0; */

      
   for ( m = 0 ; extra[m] ; ++m ) {
      extra[m]->cstExtraRBase( 0);
   }

   /* Figure 10, line 6. */
   for ( h = 1 ; h <= G->degree-1 ; ++ h ) {

      /* Figure 10, line 7. */
      for ( i = 0 , minPriority = IRREDUCIBLE ; isReducible[i] != NULL; ++i ) {
         if ( RRR[i]->refine == orbRefine ) {
            RRR[i]->familyParm_L[1].intParm = k[i] + 1;
            RRR[i]->familyParm_L[2].ptrParm = &tHatWord;
         }
         refPriPair = (isReducible[i])( RRR[i], AAA->PsiStack);
         if ( refPriPair.priority != IRREDUCIBLE && ( refPriPair.priority <
                                minPriority || minPriority == IRREDUCIBLE ) ) {
            minPriority = refPriPair.priority;
            bestRefinement = refPriPair.refn;
         }
      }
      if ( minPriority != IRREDUCIBLE )

         /* Figure 10, lines 8-9. */
         AAA->aAA[h] = bestRefinement;

      /* Figure 10, line 10. */
      else {

         /* Figure 10, lines 12-14.  Line 11 is omitted since an explicit
            representation of Pi is not maintained; note Pi_i = Psi_{n_{i+1}}.*/
         ++AAA->ell;
         AAA->n_[AAA->ell] = h;

         /* Figure 10, lines 15-17.  CAUTION: Note that the second and third
            lines below depend on the numbering of the refinement parameters
            in function pointStabRefine. */
         refPriPair = isPointStabReducible( &ptStabFamily,
                                            AAA->PsiStack, G, AAA, k[0]+1);
         AAA->alphaHat[AAA->ell] = refPriPair.refn.refnParm[0].intParm;
         AAA->p_[AAA->ell] = refPriPair.refn.refnParm[1].intParm;
         AAA->aAA[h] = refPriPair.refn;
         basicCellSize[AAA->ell] =
                 AAA->PsiStack->cellSize[ refPriPair.refn.refnParm[1].intParm ];
      }

      /* Figure 10, line 19. */
      if ( AAA->aAA[h].family->refine == orbRefine ) {
         for ( i = 0 ; specialRefinement[i]->leftGroup !=
               AAA->aAA[h].family->familyParm_L[0].ptrParm ; ++i )
            ;
         AAA->aAA[h].family->familyParm_L[1].intParm = k[i] + 1;
         AAA->aAA[h].family->familyParm_L[2].ptrParm = &tHatWord;
      }
      split = AAA->aAA[h].family->refine( AAA->aAA[h].family->familyParm_L,
                                          AAA->aAA[h].refnParm,
                                          AAA->PsiStack);

      /* Figure 10, lines 20-21. */
      AAA->a_[h] = split.newCellSize;
      AAA->b_[h] = AAA->PsiStack->parent[h+1];

      /* Figure 10, lines 22-27. */
      if ( split.newCellSize == 1 ) {
         omega[++f] = pointList[startCell[h+1]];
         for ( m = 0 ; specialRefinement[m] ; ++m )
            if ( !isFixedPointOf( specialRefinement[m]->leftGroup, k[m]+1,
                                  omega[f]) ) {
               ++k[m];
               insertBasePoint( specialRefinement[m]->leftGroup, k[m],
                                omega[f] );
               for ( sGenCount = 0 , gen = G->generator ; gen ;
                     gen = gen->next )
                  ++sGenCount;
               if ( sGenCount > options.trimSGenSetToSize )
                  removeRedunSGens( G, 1);
               constructAllOrbitInfo( specialRefinement[m]->leftGroup,
                                      k[m] + 1);
               if ( options.compress )
                  compressAtLevel( specialRefinement[m]->leftGroup, k[m]);
            }
      }
      if ( split.oldCellSize == 1 ) {
         omega[++f] = pointList[startCell[AAA->b_[h]]];
         for ( m = 0 ; specialRefinement[m] ; ++m )
            if ( !isFixedPointOf( specialRefinement[m]->leftGroup, k[m]+1,
                                  omega[f]) ) {
               ++k[m];
               insertBasePoint( specialRefinement[m]->leftGroup, k[m],
                                omega[f] );
               for ( sGenCount = 0 , gen = G->generator ; gen ;
                     gen = gen->next )
                  ++sGenCount;
               if ( sGenCount > options.trimSGenSetToSize )
                  removeRedunSGens( G, 1);
               constructAllOrbitInfo( specialRefinement[m]->leftGroup,
                                      k[m] + 1);
               if ( options.compress )
                  compressAtLevel( specialRefinement[m]->leftGroup, k[m]);
            }
      }
      
      for ( m = 0 ; extra[m] ; ++m ) {
         extra[m]->cstExtraRBase( h);
      }

      /* Figure 10, line 28. */
      /* Array f_ not needed.
      AAA->f_[h+1] = f;  */
   }

   /* Figure 10, line 30. */
   AAA->n_[AAA->ell+1] = G->degree;

   AAA->k = k[0];

   /* Create the inverse point list invOmega. */
   AAA->invOmega = allocIntArrayDegree();
   for ( pt = 1 ; pt <= G->degree ; ++pt )
      AAA->invOmega[omega[pt]] = pt;

   /* Add null terminator to alphaHat. */
   AAA->alphaHat[AAA->ell+1] = 0;

   /* Print summary information about R-Base if requested. */
   if ( options.inform )
      informRBase( G, AAA, basicCellSize);

   /* Return RRR-Base to caller. */
   return AAA;
}
