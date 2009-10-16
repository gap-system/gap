/* File ccommut.c.  Contains function commutatorGroup, which computes the
   commutator [G,H] of a group G and a (not necessarily normal) subgroup
   H. */

#include <stddef.h>

#include "group.h"

#include "addsgen.h"
#include "copy.h"
#include "chbase.h"
#include "new.h"
#include "permgrp.h"
#include "permut.h"
#include "storage.h"

CHECK( ccommu)



/*-------------------------- commutatorGroup -----------------------------*/

/* The function commutatorGroup( G, H) returns a new permutation group
   equal to the commutator [G,H].  H must be a subgroup of G, though it
   need not be normal.  G must already have a base and strong generating
   set, but H need not have one. */

PermGroup *commutatorGroup(
   const PermGroup *const G,
   const PermGroup *const H)
{
   PermGroup *C = newTrivialPermGroup( G->degree);
   Permutation *a, *b, *x, *newGen;
   Unsigned i;
   UnsignedS *img = allocIntArrayBaseSize();

   G->base[G->baseSize+1] = 0;
   changeBase( C, G->base);
   for ( a = G->generator ; a ; a = a->next )
      for ( b = (H == G ? a->next : H->generator) ; b ; b = b->next )
         for ( x = G->generator ; x ; x = x->next ) {
            for ( i = 1 ; i <= G->baseSize ; ++i ) {
               img[i] = b->invImage[a->invImage[x->invImage[G->base[i]]]];
               img[i] = x->image[b->image[a->image[img[i]]]];
            }
            if ( !isBaseImage( C, img) ) {
               newGen = newIdentityPerm( G->degree);
               rightMultiplyInv( newGen, x);
               rightMultiplyInv( newGen, a);
               rightMultiplyInv( newGen, b);
               rightMultiply( newGen, a);
               rightMultiply( newGen, b);
               rightMultiply( newGen, x);
               reduceWrtGroup( C, newGen, NULL);
               addStrongGenerator( C, newGen, TRUE);
            }
         }
   freeIntArrayBaseSize( img);
   return C;
}


/*-------------------------- normalClosure -------------------------------*/

/* The function normalClosure( G, H) returns a new permutation group
   equal to the normal closure of H in G.  H must be a subgroup of G (not
   checked).  G must already have a base and strong generating set, but
   H need not have one. */

PermGroup *normalClosure(
   const PermGroup *const G,
   const PermGroup *const H)
{
   PermGroup *N = copyOfPermGroup( H);
   Permutation *a, *b, *newGen;
   Unsigned i;
   UnsignedS *img = allocIntArrayBaseSize();

   G->base[G->baseSize+1] = 0;
   changeBase( N, G->base);
   for ( a = G->generator ; a ; a = a->next )
      for ( b = H->generator ; b ; b = b->next ) {
         for ( i = 1 ; i <= G->baseSize ; ++i ) 
            img[i] = a->image[b->image[a->invImage[G->base[i]]]];
         if ( !isBaseImage( N, img) ) {
            newGen = newIdentityPerm( G->degree);
            rightMultiplyInv( newGen, a);
            rightMultiply( newGen, b);
            rightMultiply( newGen, a);
            reduceWrtGroup( N, newGen, NULL);
            addStrongGenerator( N, newGen, TRUE);
         }
      }

   freeIntArrayBaseSize( img);
   return N;
}
