#############################################################################
##
#W  mgmring.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
##  Examples of free magma rings are (multivariate) polynomial rings and
##  group rings.
##
##  Polynomials have an external representation independent of the
##  underlying monomials, whereas the group ring of a permutation group
##  does not admit such an external representation.
##  Thus there is *no* generic external representation for elements in an
##  *arbitrary* free magma ring.
##
##  If the elements of the magma do have an external representation then
##  the external representation of elements in the free magma ring is
##  defined as a list of length 2, the first entry being the zero
##  coefficient, the second being a list with external representations of
##  the magma elements at the odd positions and the coefficients at the
##  even positions.
#T what about the ordering of this list???
#T (cannot be the ordering of magma elements)
##
##  In order to treat elements of free magma rings uniformly, the attribute
##  'CoefficientsAndMagmaElements' is introduced that allows to take an
##  element into pieces.
##  The element constructor is 'FreeMagmaRingElement', it constructs an
##  element from a given lists of coefficients and magma elements.
##
##  As the above examples show, there are several possible element
##  representations, the one used as default representation of polynomials
##  as well as the default representation that simply stores the coefficients
##  and magma elements.
##
Revision.mgmring_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsElementOfFreeMagmaRing( <obj> )
##
IsElementOfFreeMagmaRing := NewCategory( "IsElementOfFreeMagmaRing",
    IsScalar );


#############################################################################
##
#C  IsElementOfFreeMagmaRingCollection( <obj> )
##
IsElementOfFreeMagmaRingCollection := CategoryCollections(
    "IsElementOfFreeMagmaRingCollection", IsElementOfFreeMagmaRing );


#############################################################################
##
#C  IsFamilyElementOfFreeMagmaRing( <Fam> )
##
IsFamilyElementOfFreeMagmaRing := CategoryFamily(
    "IsFamilyElementOfFreeMagmaRing", IsElementOfFreeMagmaRing );


#############################################################################
##
#A  CoefficientsAndMagmaElements( <elm> ) . . . for elm. in a free magma ring
##
##  is a list that contains at the odd positions the magma elements,
##  and at the even positions their coefficients in the element <elm>.
##
CoefficientsAndMagmaElements := NewAttribute( "CoefficientsAndMagmaElements",
    IsElementOfFreeMagmaRing );


#############################################################################
##
#C  IsFreeMagmaRing( <obj> )
##
IsFreeMagmaRing := NewCategory( "IsFreeMagmaRing", IsFLMLOR );


#############################################################################
##
#C  IsFreeMagmaRingWithOne( <obj> )
##
IsFreeMagmaRingWithOne := IsFreeMagmaRing and IsMagmaWithOne;


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
#O  ElementOfFreeMagmaRing( <Fam>, <zerocoeff>, <coeffs>, <mgmelms> )
##
ElementOfFreeMagmaRing := NewOperation( "ElementOfFreeMagmaRing",
    [ IsFamily, IsRingElement, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  FreeMagmaRing( <R>, <M> )
##
##  is a free magma ring over the ring <R>, free on the magma <M>.
##
FreeMagmaRing := NewOperationArgs( "FreeMagmaRing" );


#############################################################################
##
#E  mgmring.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



