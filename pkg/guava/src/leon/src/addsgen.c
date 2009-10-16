/* File addsgen.c.  Contains function addStrongGenerator, which may be used
   to adjoin a new strong generator to a permutation group. */

#include <stddef.h>

#include "group.h"

#include "essentia.h"
#include "permgrp.h"
#include "permut.h"
#include "cstborb.h"

CHECK( addsge)

/*-------------------------- addStrongGenerator ---------------------------*/

/* This function may be used to adjoin a new strong generator to a
   permutation group.  The new strong generator must move a base point
   (This is not checked.), and it should extend the basic orbit at its level (If
   not, no error occurs, but the new generator is always marked as essential
   at its level.).  The inverse image of the new generator, if absent, will be
   appended.  Schreier vectors are reconstructed as necessary. */



void addStrongGenerator(
   PermGroup *G,              /* Group to which strong gen is adjoined. */
   Permutation *newGen,       /* The new strong generator. It must move
                                 a base point (not checked). */
   BOOLEAN essentialAtOne)    /* Should the new generator be marked as essential
                                 at level 1. */
{
   Unsigned i;
   /* Append inverse image of new strong generator, if absent. */
   if ( !newGen->invImage )
      adjoinInvImage( newGen);

   /* Find level of new strong generator, and mark it essential at this
      level. */
   newGen->level = levelIn( G, newGen);
   MAKE_NOT_ESSENTIAL_ALL( newGen);
   MAKE_ESSENTIAL_AT_LEVEL( newGen, newGen->level);

   /* Add the generator. */
   if ( G->generator )
      G->generator->last = newGen;
   newGen->last = NULL;
   newGen->next = G->generator;
   G->generator = newGen;

   /* Rebuild the Schreier vectors and basic orbits. */
   constructBasicOrbit( G, newGen->level, "KnownEssential");
   for ( i = newGen->level - 1 ; i >= (essentialAtOne ? 1 : 2) ; --i ) {
      MAKE_ESSENTIAL_AT_LEVEL(newGen,i);
      if ( !fixesBasicOrbit( G, i, newGen) )
         constructBasicOrbit( G, i, "FindEssential");
   }
}

