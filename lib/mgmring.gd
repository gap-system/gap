#############################################################################
##
#W  mgmring.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares operations for magma rings.
##
##  Given a magma $M$ then the free magma ring on $M$ over a ring $R$
##  (a ring with 1) is the set of finite sums $\sum_{i\in I} r_i m_i$ with
##  $r_i \in R$, and $m_i \in M$.
##  $M$ is linearly independent over $R$.
##  Addition, subtraction and multiplication are the obvious ones.
##
##  A more general construction allows to create magma rings that are not
##  free on the magma but arise by factoring out certain identities.
##  Finitely presented algebras arise that way, but also free Lie algebras.
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
##  `CoefficientsAndMagmaElements' is introduced that allows to take an
##  element into pieces.
##  The element constructor is `FreeMagmaRingElement', it constructs an
##  element from a given lists of coefficients and magma elements.
##
##  As the above examples show, there are several possible element
##  representations, the one used as default representation of polynomials
##  as well as the default representation that simply stores the coefficients
##  and magma elements.
##
#T add some words about magma rings modulo relations,
#T in particular state that elements are always normalized.
#T So the implementation via magma rings modulo relations is *not*
#T suitable for general f.p. algebras!
##
Revision.mgmring_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsElementOfMagmaRingModuloRelations( <obj> )
##
##  This category is used, e. g., for elements of free Lie algebras.
##
DeclareCategory( "IsElementOfMagmaRingModuloRelations", IsScalar );


#############################################################################
##
#C  IsElementOfMagmaRingModuloRelationsCollection( <obj> )
##
DeclareCategoryCollections( "IsElementOfMagmaRingModuloRelations" );


#############################################################################
##
#C  IsElementOfMagmaRingModuloRelationsFamily( <Fam> )
##
DeclareCategoryFamily( "IsElementOfMagmaRingModuloRelations" );


#############################################################################
##
#C  IsElementOfFreeMagmaRing( <obj> )
##
DeclareCategory( "IsElementOfFreeMagmaRing",
    IsElementOfMagmaRingModuloRelations );


#############################################################################
##
#C  IsFamilyElementOfFreeMagmaRing( <Fam> )
##
##  Elements of families in this category have trivial normalisation, i.e.,
##  efficient methods for `\=' and `\<'.
##
DeclareCategoryFamily( "IsElementOfFreeMagmaRing" );


#############################################################################
##
#C  IsElementOfFreeMagmaRingCollection( <obj> )
##
DeclareCategoryCollections( "IsElementOfFreeMagmaRing" );


#############################################################################
##
#A  CoefficientsAndMagmaElements( <elm> ) . . . . .  for elm. in a magma ring
##
##  is a list that contains at the odd positions the magma elements,
##  and at the even positions their coefficients in the element <elm>.
##
DeclareAttribute( "CoefficientsAndMagmaElements",
    IsElementOfMagmaRingModuloRelations );


#############################################################################
##
#O  NormalizedElementOfMagmaRingModuloRelations( <F>, <descr> )
##
##  Let <F> be a family of magma ring elements modulo relations, and <descr>
##  the description (in the sense of `CoefficientsAndMagmaElements') of an
##  element in a magma ring modulo relations.
##  `NormalizedElementOfMagmaRingModuloRelations' returns a description of
##  the same element, but normalized w.r.t. the relations.
##  So two elements are equal if and only if the result of 
##  `NormalizedElementOfMagmaRingModuloRelations' is equal for their internal
##  data in the sense of `CoefficientsAndMagmaElements'.
##
##  `NormalizedElementOfMagmaRingModuloRelations' is allowed to return
##  <descr> itself, it need not make a copy.
##
DeclareOperation( "NormalizedElementOfMagmaRingModuloRelations",
    [ IsElementOfMagmaRingModuloRelationsFamily, IsList ] );


#############################################################################
##
#C  IsMagmaRingModuloRelations( <obj> )
##
DeclareCategory( "IsMagmaRingModuloRelations", IsFLMLOR );


#############################################################################
##
#C  IsFreeMagmaRing( <obj> )
##
DeclareCategory( "IsFreeMagmaRing", IsMagmaRingModuloRelations );


#############################################################################
##
#C  IsFreeMagmaRingWithOne( <obj> )
##
DeclareSynonym( "IsFreeMagmaRingWithOne",
    IsFreeMagmaRing and IsMagmaWithOne );


#############################################################################
##
#P  IsGroupRing( <obj> )
##
##  A group ring is a free magma ring where the underlying magma is a group.
##
DeclareProperty( "IsGroupRing", IsFreeMagmaRing );


#############################################################################
##
#A  UnderlyingMagma( <RM> )
##
DeclareAttribute( "UnderlyingMagma", IsFreeMagmaRing );


#############################################################################
##
#O  ElementOfMagmaRing( <Fam>, <zerocoeff>, <coeffs>, <mgmelms> )
##
##  `ElementOfMagmaRing' returns the element $\sum_{i=1}^n c_i m_i$,
##  where $<coeffs> = [ c_1, c_2, \ldots, c_n ]$ and
##  $<mgmelms> = [ m_1, m_2, \ldots, m_n ]$;
##  the family of this element is <Fam>, which must be a family of elements
##  of a free magma ring.
##  <zerocoeff> must be the zero of the coefficients ring.
##
##  Note that both <Fam> and <zerocoeff> are needed at least if <coeff> and
##  <mgmelms> are empty.
#T Is it desirable to have a version that takes only <coeff> and <mgmelms>,
#T and is not applicable to the case of the zero element?
#T (It would be necessary to store the families of magma ring elements in
#T the family of ring elements or in the family of magma elements.)
##
DeclareOperation( "ElementOfMagmaRing",
    [ IsFamily, IsRingElement, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#F  FreeMagmaRing( <R>, <M> )
##
##  is a free magma ring over the ring <R>, free on the magma <M>.
##
DeclareGlobalFunction( "FreeMagmaRing" );


#############################################################################
##
#F  GroupRing( <R>, <G> )
##
##  is the group ring of the group <G>, over the ring <R>.
##
DeclareGlobalFunction( "GroupRing" );


#############################################################################
##
#A  AugmentationIdeal( <RG> )
##
##  is the augmentation ideal of the group ring <RG>, i.e., the kernel of the
##  trivial representation of <RG>.
##
DeclareAttribute( "AugmentationIdeal", IsFreeMagmaRing );


#############################################################################
##
#E  mgmring.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

