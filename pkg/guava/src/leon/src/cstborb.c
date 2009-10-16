/* File cstborb.c.  Contains functions to construct and extend basic orbits
   in permutation groups, as follows:

      constructBasicOrbit:   Constructs the basic orbit and (incomplete)
                             Schreier vector at a given level in a
                             permutation group.

      extendBasicOrbit:      Extends the basic orbit and Schreier vector at
                             a given level corresponding to inclusion of a
                             new generator.  ????? inverse

      constructAllOrbitInfo: Constructs complete orbit lists and Schreier
                             vectors at a designated level. */

#include <stddef.h>
#include <string.h>

#include "group.h"

#include "errmesg.h"
#include "essentia.h"
#include "factor.h"
#include "storage.h"

extern GroupOptions options;

CHECK( cstbor)


/*-------------------------- linkGensAtLevel ------------------------------*/

/* This function creates a (forward) linked list of the generators of a
   permutation group having level equal to or greater than a given value.
   The xNext field of each permutation is used for the links.  The function
   returns a pointer to the first permutation in the list.  The level fields
   of the generating permutations must be filled at before the function is
   invoked. */

Permutation *linkGensAtLevel(
   PermGroup *G,                      /* The permutation group. */
   Unsigned level)                    /* Permutations at or above this level
                                         will be included. */
{
   Permutation *gen, *listHeader = NULL, *currentListEntry;

   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( gen->level >= level )   {
         if ( !listHeader )
            listHeader = gen;
         else
            currentListEntry->xNext = gen;
         currentListEntry = gen;
      }
   if ( listHeader )
      currentListEntry->xNext = NULL;
   return listHeader;
}


/*-------------------------- linkEssentialGensAtLevel ---------------------*/

/* This function creates a (forward) linked list of the generators of a
   permutation group having level equal to or greater than a given value and
   which are flagged as essential at that value.  The xNext field of each
   permutation is used for the links.  The function returns a pointer to the
   first permutation in the list.  The level fields of the generating
   permutations must be filled at before the function is invoked. */

Permutation *linkEssentialGensAtLevel(
   PermGroup *G,                      /* The permutation group. */
   Unsigned level)                    /* Permutations at or above this level
                                         will be included if they are essential
                                         at this level. */
{
   Permutation *gen, *listHeader = NULL, *currentListEntry;

   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( gen->level >= level && ESSENTIAL_AT_LEVEL(gen,level) ) {
         if ( !listHeader )
            listHeader = gen;
         else
            currentListEntry->xNext = gen;
         currentListEntry = gen;
      }
   if ( listHeader )
      currentListEntry->xNext = NULL;
   return listHeader;
}


/*-------------------------- genExpandingBasicOrbit -----------------------*/

/* This function returns the first generator on the list *firstGen (xNext
   linked) that fails to fix orbit[1..orbitLen] setwise, or NULL if no such
   permutation exists.  Note svec is the Schreier vector for the orbit.  The
   function also delinks the permutation returned from the (xNext-linked)
   list *firstGen. */

Permutation *genExpandingBasicOrbit(
   Permutation **firstGen,
   const Unsigned orbitLen,
   UnsignedS *orbit,
   Permutation **svec)
{
   Permutation *gen, *lastGen = NULL;
   Unsigned i;

   for ( gen = *firstGen ; gen ; gen = gen->xNext ) {
      for ( i = 1 ; i <= orbitLen ; ++i )
         if ( !svec[gen->image[orbit[i]]] ) {
            if ( lastGen )
               lastGen->xNext = gen->xNext;
            else
               *firstGen = gen->xNext;
            return gen;
         }
      lastGen = gen;
   }

   return NULL;
}

/*-------------------------- constructBasicOrbit --------------------------*/

/* This function constructs the basic orbit vector and Schreier vector at a
   specified level in a permutation group.   Storage for the basic orbit
   and Schreier vector must have been allocated prior to invocation of this
   function, and the level field in each generating permutation for the
   group must be filled in.  Inverses of generators will be used only if
   there is a separate structure (type Permutation) for the inverse.

   There are three options, which determine which generators are used in
   constructing the Schreier vectors:
     "AllGensAtLevel":  All generators at or above the specified level are used
                        in constructing the Schreier vector, and all are
                        flagged as essential at this level.
     "KnownEssential":  Only generators previously flagged as essential at this
                        level are used, and the essential flags are not
                        modified.  (CAUTION: The essential flags MUST be
                        correct.)
     "FindEssential":   An attempt is made to use as few generators as possible
                        in the Schreier vector construction, and all generators
                        at or above the level are marked as essential or not
                        essential at this level, depending on whether or not
                        they are used in the Schreier vector. */

void constructBasicOrbit(
   PermGroup *const G,       /* The permutation group. */
   const Unsigned level,     /* The level of the basic orbit to build. */
   char *option)             /* One of the three options above. */
{
   typedef enum{ all, known, find} Option;
   Option svecOption;
   FactoredInt factoredOrbLen;
   Permutation **svec = G->schreierVec[level];
   Unsigned  i;
   UnsignedS *orbit = G->basicOrbit[level];
   Unsigned  found = 1, processed = 0, pt, img;
   Permutation *gen, *firstGen, *gensUsed, *newEssentialGen;

   /* Find option.  Terminate if invalid.  */
   if ( strcmp( option, "AllGensAtLevel") == 0 )
      svecOption = all;
   else if ( strcmp( option, "KnownEssential") == 0 )
      svecOption = known;
   else if ( strcmp( option, "FindEssential") == 0 )
      svecOption = find;
   else
      ERROR1s( "constructBasicOrbit", "Invalid option ", option, ".");

   /* Using xNext, form linked list of generators (or essential generators at
      level, if KnownEssential option is specified) at or above specified
      level. */
   switch( svecOption) {
      case all:
         firstGen = linkGensAtLevel( G, level);
         for ( gen = firstGen ; gen ; gen = gen->xNext )
            MAKE_ESSENTIAL_AT_LEVEL(gen,level);
         break;
      case known:
         firstGen = linkEssentialGensAtLevel( G, level);
         break;
      case find:
         firstGen = linkGensAtLevel( G, level);
         break;
   }

   for ( pt = 1 ; pt <= G->degree ; ++pt )
      svec[pt] = NULL;
   orbit[1] = G->base[level];
   svec[orbit[1]] = FIRST_IN_ORBIT;

   switch( svecOption) {

      case all:
      case known:
         while ( processed < found ) {
            pt = orbit[++processed];
            for ( gen = firstGen ; gen ; gen = gen->xNext ) {
               img = gen->image[pt];
               if ( !svec[img] ) {
                  svec[img] = gen;
                  orbit[++found] = img;
               }
            }
         }
         break;

      case find:
         gensUsed = NULL;
         while ( newEssentialGen = genExpandingBasicOrbit( &firstGen, found,
                                                          orbit, svec) ) {
            newEssentialGen->xNext = gensUsed;
            gensUsed = newEssentialGen;

            for ( i = 1 ; i <= found ; ++i ) {
               img = newEssentialGen->image[orbit[i]];
               if ( !svec[img] ) {
                  orbit[++found] = img;
                  svec[img] = newEssentialGen;
               }
            }

            while ( processed < found ) {
               pt = orbit[++processed];
               for ( gen = gensUsed ; gen ; gen = gen->xNext ) {
                  img = gen->image[pt];
                  if ( !svec[img] ) {
                     svec[img] = gen;
                     orbit[++found] = img;
                  }
               }
            }
         }

         for ( gen = gensUsed ; gen ; gen = gen->xNext )
            MAKE_ESSENTIAL_AT_LEVEL(gen,level);
         for ( gen = firstGen ; gen ; gen = gen->xNext )
            MAKE_NOT_ESSENTIAL_AT_LEVEL(gen,level);
         break;
   }

   factoredOrbLen = factorize( found);
   factMultiply( G->order, &factoredOrbLen);
   factoredOrbLen = factorize( G->basicOrbLen[level]);
   factDivide( G->order, &factoredOrbLen);
   G->basicOrbLen[level] = found;
}


/*-------------------------- extendBasicOrbit -----------------------------*/

/* This function may be used to extend a basic orbit and Schreier vector
   at a given level, corresponding to inclusion of a new generator (assumed
   to be) at a given level.  It returns the number of additional points in
   the basic orbit.  First the new generator is applied to all points in
   the basic orbit.  Then, if any new points are found, the construction of
   the Schreier vector continues in the usual manner. */

Unsigned extendBasicOrbit(
   PermGroup *G,            /* The permutation group. */
   Unsigned level,          /* The level of the basic orbit to extend. */
   Permutation *newGen)     /* The new generator not previously included
                               the Schreier vector. */
{
   Permutation **svec = G->schreierVec[level];
   UnsignedS   *orbit = G->basicOrbit[level];
   Unsigned    found = G->basicOrbLen[level], processed = found, pt, img,
               oldLength, i;
   Permutation *gen, *firstGen;

   for ( i = 1 ; i <= G->basicOrbLen[level] ; ++i ) {
      img = newGen->image[orbit[i]];
      if ( !svec[img] ) {
         svec[img] = newGen;
         orbit[++found] = img;
      }
   }

   if ( found > G->basicOrbLen[level] ) {
      firstGen = linkGensAtLevel( G, level);
      while ( processed < found ) {
         pt = orbit[++processed];
         for ( gen = firstGen ; gen ; gen = gen->xNext ) {
            img = gen->image[pt];
            if ( !svec[img] ) {
               svec[img] = gen;
               orbit[++found] = img;
            }
         }
      }
   }

   oldLength = G->basicOrbLen[level];
   G->basicOrbLen[level] = found;
   return  found - oldLength;

}


/*-------------------------- constructAllOrbitInfo ------------------------*/

/* This function constructs complete orbit information for a group at a given
   level.  Specifically, it fills in the completeOrbit, orbNumberOfPt, and
   startOfOrbitNo fields.  (Note fields schreierVec and basicOrbit are not
   modified; in particular, this routine will normally be used in addition to,
   rather that as an alternative to, routine cstborb.  Note
   startOfOrbitNo[orbitCount+1] is set to degree+1, in order to facilitate
   computation of orbit lengths. */

void constructAllOrbitInfo(
   PermGroup *const G,
   const Unsigned level)
{
   UnsignedS *completeOrbit, *orbNumberOfPt, *startOfOrbitNo;
   Unsigned  found = 0,
             processed = 0,
             orbitCount = 0,
             pt, img, orbRep, i;
   Permutation *gen, *firstGen;

   /* Here we allocate completeOrbit, orbNumberOfPt and startOfOrbitNo, if
      absent. */
   if ( !G->completeOrbit ) {
      G->completeOrbit = allocPtrArrayBaseSize();
      for ( pt = 1 ; pt <= options.maxBaseSize+1 ; ++pt )
         G->completeOrbit[pt] = NULL;
   }
   if ( !G->orbNumberOfPt ) {
      G->orbNumberOfPt = allocPtrArrayBaseSize();
      for ( pt = 1 ; pt <= options.maxBaseSize+1 ; ++pt )
         G->orbNumberOfPt[pt] = NULL;
   }
   if ( !G->startOfOrbitNo ) {
      G->startOfOrbitNo = allocPtrArrayBaseSize();
      for ( pt = 1 ; pt <= options.maxBaseSize+1 ; ++pt )
         G->startOfOrbitNo[pt] = NULL;
   }

   if ( !G->completeOrbit[level] )
      G->completeOrbit[level] = allocIntArrayDegree();
   if ( !G->orbNumberOfPt[level] )
      G->orbNumberOfPt[level] = allocIntArrayDegree();
   if ( !G->startOfOrbitNo[level] )
      G->startOfOrbitNo[level] = allocIntArrayDegree();

   /* Abbreviations. */
   completeOrbit = G->completeOrbit[level];
   orbNumberOfPt = G->orbNumberOfPt[level];
   startOfOrbitNo = G->startOfOrbitNo[level];

   /* The trivial case level>baseSize is handled here. */
   if ( level > G->baseSize ) {
      for ( pt = i = 1 ; pt <= G->degree ; ++pt , ++i ) {
         orbNumberOfPt[pt] = i;
         startOfOrbitNo[i] = i;
         completeOrbit[i] = pt;
      }
      startOfOrbitNo[G->degree+1] = G->degree+1;
      return;
   }

   /* Initially all points are flagged as not found. */
   for ( pt = 1 ; pt <= G->degree ; ++pt)
      orbNumberOfPt[pt] = 0;

   /* Construct a linked list of the generators at the appropriate level.
      Should only essential generators be used? */
   firstGen = linkGensAtLevel( G, level);

   /* Construct the orbits, one by one in order. */
   for ( orbRep = 1 ; orbRep <= G->degree ; ++orbRep )
      if ( !orbNumberOfPt[orbRep] ) {
         completeOrbit[++found] = orbRep;
         startOfOrbitNo[++orbitCount] = found;
         orbNumberOfPt[orbRep] = orbitCount;
         while ( processed < found ) {
            pt = completeOrbit[++processed];
            for ( gen = firstGen ; gen ; gen = gen->xNext ) {
               img = gen->image[pt];
               if ( !orbNumberOfPt[img] ) {
                  completeOrbit[++found] = img;
                  orbNumberOfPt[img] = orbitCount;
               }
            }
         }
      }

   startOfOrbitNo[orbitCount+1] = G->degree+1;
}
