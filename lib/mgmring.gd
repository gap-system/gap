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
##  We do not have an external representation of elements.
##  Note that the group ring of a permutation group is a free magma ring
##  as well as any (multivariate) polynomial ring.
##
Revision.mgmring_gd :=
    "@(#)$Id$";


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
#O  FreeMagmaRingElement( <Fam>, <zerocoeff>, <coeffs>, <mgmelms> )
##
FreeMagmaRingElement := NewOperation( "FreeMagmaRingElement",
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



