#############################################################################
##
#W  mgmring.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares operations for free magma rings.
##
##  Given a magma $M$ then the free magma ring on $M$ over a ring $R$
##  (a ring with 1) is the set of finite sums $\sum_{i\in I} r_i m_i$ with
##  $r_i \in R$, and $m_i \in M$.
##  $M$ is linearly independent over $R$.
##  Addition, subtraction and multiplication are the obvious ones.
##
##  *Note* that the arithmetic allows to create elements with coefficients
##  in the whole family of $R$, and words in the whole family of $M$.
##  Also the multiplication with elements in the family of $R$ is allowed.
##
##  The external representation of an element object is a list of length 2,
##  at first position the zero coefficient, at second position a list with
##  the coefficients at the even positions, and the magma elements at the
##  odd positions, with the ordering as defined for the magma elements.
##
##  It is assumed that the arithmetic operations of $M$ produce only
##  normalized elements.
##
Revision.mgmring_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsFreeMagmaRingObj( <obj> )
##
IsFreeMagmaRingObj := NewCategory(
    "IsFreeMagmaRingObj", 
    IsRingElementWithOne );


#############################################################################
##
#C  IsFreeMagmaRingObjFamily( <obj> )
##
IsFreeMagmaRingObjFamily := CategoryFamily( "IsFreeMagmaRingObjFamily",
    IsFreeMagmaRingObj );


#############################################################################
##
#C  IsFreeMagmaRing( <obj> )
##
IsFreeMagmaRing := NewCategory( "IsFreeMagmaRing", IsFLMLOR );


#############################################################################
##
#C  IsFreeMagmaUnitalRing( <obj> )
##
IsFreeMagmaUnitalRing := IsFreeMagmaRing and IsMagmaWithOne;


#############################################################################
##
#P  IsGroupRing( <obj> )
##
##  A group ring is a free magma ring where the underlying magma is a group.
##
IsGroupRing := NewProperty( "IsGroupRing", IsFreeMagmaRing );
SetIsGroupRing := Setter( IsGroupRing );
HasIsGroupRing := Tester( IsGroupRing );


#############################################################################
##
#A  UnderlyingMagma( <RM> )
##
UnderlyingMagma := NewAttribute( "UnderlyingMagma", IsFreeMagmaRing );
SetUnderlyingMagma := Setter( UnderlyingMagma );
HasUnderlyingMagma := Tester( UnderlyingMagma );


#############################################################################
##
#O  FreeMagmaRingElement( <Fam>, <zerocoeff>, <coeffs>, <mgmelms> )
##
FreeMagmaRingElement := NewConstructor( "FreeMagmaRingElement",
    [ IsFreeMagmaRingObjFamily, IsRingElement,
      IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  FreeMagmaRing( <R>, <M> )
##
##  is a free magma ring over the ring <R>, free on the magma <M>.
##
FreeMagmaRing := NewOperationArgs( "FreeMagmaRing" );


#############################################################################
##
#R  IsCanonicalBasisFreeMagmaRing( <B> )
##
IsCanonicalBasisFreeMagmaRing := NewRepresentation(
    "IsCanonicalBasisFreeMagmaRing", IsCanonicalBasis,
    [ "zerovector" ] );


#############################################################################
##
#R  IsEmbeddingRingMagmaRing( <R>, <RM> )
##
IsEmbeddingRingMagmaRing := NewRepresentation( "IsEmbeddingRingMagmaRing",
    IsMapping and IsInjective and IsAttributeStoringRep,
    [] );


#############################################################################
##
#R  IsEmbeddingMagmaMagmaRing( <M>, <RM> )
##
IsEmbeddingMagmaMagmaRing := NewRepresentation( "IsEmbeddingMagmaMagmaRing",
    IsMapping and IsInjective and IsAttributeStoringRep,
    [] );


#############################################################################
##
#E  mgmring.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



