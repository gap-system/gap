#############################################################################
##
#W  alglie.gd                   GAP library                     Thomas Breuer
#W                                                        and Willem de Graaf
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of attributes, properties, and
##  operations for Lie algebras.
##
Revision.alglie_gd :=
    "@(#)$Id$";

#1 
## A Lie algebra is an algebra such that the multiplication satisfies
## $xx=0$ and $x(yz)+y(zx)+z(xy)=0$ for all $x,y,z$. Usually the product of
## two elements $x,y$ of a Lie algebra is denoted by $[x,y]$, but in 
## {\GAP} the product of elements is made by the usual `*'.

#############################################################################
##
#P  IsAbelianLieAlgebra( <L> )
##
##  is 'true' if <L> is a Lie algebra such that each product of elements in
##  <L> is zero, and 'false' otherwise.
##
DeclareProperty( "IsAbelianLieAlgebra",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#P  IsNilpotentAlgebra( <L> )
##
##  A Lie algebra <L> is defined to be {\it nilpotent} when its lower central
##  series reaches the trivial subalgebra.
##
DeclareProperty( "IsNilpotentAlgebra",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#P  IsRestrictedLieAlgebra( <L> )
##
##  A Lie algebra <L> is defined to be {\it restricted} when it is defined
##  over a field of characteristic $p \neq 0$, and for every basis element
##  $x$ of <L> there exists $y\in <L>$ such that $(ad x)^p = ad y$
##  (see Jacobson, p. 190).
##
DeclareProperty( "IsRestrictedLieAlgebra",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#P  IsSolvableAlgebra( <L> )
##
##  A Lie algebra <L> is defined to be {\it solvable} when its derived
##  series reaches the trivial subalgebra.
##
DeclareProperty( "IsSolvableAlgebra",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  LowerCentralSeriesOfAlgebra( <L> )
##
##  is the lower central series of <L>.  
##
DeclareAttribute( "LowerCentralSeriesOfAlgebra",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  UpperCentralSeriesOfAlgebra( <L> )
##
##  is the upper central series of <L>.
##
DeclareAttribute( "UpperCentralSeriesOfAlgebra",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  LieCentre( <L> )
##
##  The Lie centre of the Lie algebra <L> is the kernel of the adjoint
##  mapping, that is, the set $\{ a \in L; a x = 0 \forall x \in L \}$.
##
##  In characteristic 2 this may differ from the usual centre.
##
##
DeclareAttribute( "LieCentre", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  Derivations( <B> )
##
##  is the matrix Lie algebra of derivations of the algebra $A$ with basis
##  <B>.
##
##  A derivation is a linear map $D: A \rightarrow A$ with the property
##  $D( a b ) = D(a) b + a D(b)$.
##
##  With resprect to the basis $B$ of $A$, the derivation $D$ is described
##  by the matrix $[ d_{i,j} ]_{i,j}$
##  which means that $D$ maps $b_i$ to $\sum_{i=1}^n d_{ij} b_j$.
##  (Note that this is column convention.)
##
##  The set of derivations of $A$ forms a Lie algebra with product given by
##  $(D_1 D_2)(a) = D_1(D_2(a)) - D_2(D_1(a))$.
##
DeclareAttribute( "Derivations", IsBasis );


#############################################################################
##
#A  KillingMatrix( <B> )
##
##  is the matrix $\kappa$ of the killing form w.r.t. the basis <B>.
##
##  We have $\kappa_{i,j} = \sum_{k,l=1}^n c_{jkl} c_{ilk}$
##  where $c_{ijk}$ are the structure constants w.r.t. <B>.
##
DeclareAttribute( "KillingMatrix", IsBasis );


#############################################################################
##
#A  CartanSubalgebra( <L> )
##
##  A Cartan subalgebra of a Lie algebra <L> is defined as a nilpotent
##  subalgebra of <L> equal to its own Lie normalizer in <L>.
##
DeclareAttribute( "CartanSubalgebra",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  PthPowerImages( <B> )
##
##  <B> is a basis of a restricted Lie algebra $L$ of characteristic $p$ if
##  and only if there exists a map $x \mapsto x^{[p]}$ such that
##  $ad x^{[p]} = (ad x)^p$ (and some more conditions).
##
##  According to Jacobson, p. 190, Th. 11, this is the case if and only if
##  for a basis (x_1, \ldots ,x_n) of $L$ we have that for
##  $1 \leq i \leq n$ there exists a $y_i \in L$ such that
##  $ad x_i^{[p]}= ad y_i$.
##  In that case we have that $x_i^{[p]} = y_i$.
##  This function constructs a list of the images of the basis elements of
##  $L$ under this map (if $L$ is restricted).
##  Otherwise 'fail' is returned.
##
DeclareAttribute( "PthPowerImages", IsBasis );


#############################################################################
##
#A  NonNilpotentElement( <L> )
##
##  A non nilpotent element of a Lie algebra <L> is an element $x$ such that
##  $ad x$ is not nilpotent.
##  If <L> is not nilpotent, then by Engels theorem non nilpotent elements
##  exist in <L>.
##  In this case this function returns a non nilpotent element of <L>,
##  otherwise 'fail' is returned.
##
DeclareAttribute( "NonNilpotentElement",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  AdjointAssociativeAlgebra( <L>, <K> )
##
##  is the associative matrix algebra (with 1) generated by the 
##  matrices of the adjoint representation of the subalgebra <K> on the Lie 
##  algebra <L>.
##
DeclareOperation( "AdjointAssociativeAlgebra",
    [IsAlgebra and IsLieAlgebra, IsAlgebra and IsLieAlgebra] );

#############################################################################
##
#A  NilRadical( <L> )
##
##  This function calculates the nil radical of the Lie algebra
##  <L>.
##
DeclareAttribute( "NilRadical", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  SolvableRadical( <L> )
##
##  Returns the solvable radical of the Lie algebra <L>.
##
DeclareAttribute( "SolvableRadical",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  DirectSumDecomposition( <L> )
##
##  This function calculates a list of ideals of the Lie algebra <L> such
##  that <L> is equal to their direct sum.
##
DeclareAttribute( "DirectSumDecomposition",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  SemiSimpleType( <L> )
##
##  Let <L> be a semisimple Lie algebra, i.e., a direct sum of simple
##  Lie algebras. Then 'SemiSimpleType' returns the type of <L>, i.e.,
##  a string containg the types of the simple summands of <L>.
##
##
DeclareAttribute( "SemiSimpleType",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#O  LieCentralizer( <L>, <S> )
##
##  is the annihilator of <S> in the Lie algebra <L>, that is, the set
##  $\{ a \in L; a \* s = 0 \forall s \in S \}$.
##  Here <S> may be a subspace or a subalgebra of <L>.
##
DeclareOperation( "LieCentralizer",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#A  LieCentralizerInParent( <S> )
##
##  is the Lie centralizer of the vector space <S> in its parent Lie algebra
##  $L$.
##
DeclareAttribute( "LieCentralizerInParent",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#O  LieNormalizer( <L>, <U> )
##
##  is the normalizer of the subspace <U> in the Lie algebra <L>,
##  that is, the set $N_L(U) = \{ x \in L; [x,U] \subset U \}$.
##
DeclareOperation( "LieNormalizer",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#A  LieNormalizerInParent( <S> )
##
##  is the Lie normalizer of the vector space <S> in its parent Lie algebra
##  $L$.
##
DeclareAttribute( "LieNormalizerInParent",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#O  AdjointMatrix( <B>, <x> )
##
##  is the matrix of the adjoint representation of the element <x> w.r.t.
##  the basis <B>.
##
DeclareOperation( "AdjointMatrix", [ IsBasis, IsRingElement ] );


#############################################################################
##
#O  KappaPerp( <L>, <U> )
##
##  is the orthogonal complement of the subspace <U> of the Lie algebra <L>
##  w.r.t. the Killing form $\kappa$, that is,
##  the set $U^{\perp} = \{ x \in L; \kappa (x,y) =0 \forall y \in L \}$.
##
##  $U^{\perp}$ is a subspace of <L>, and if <U> is an ideal of <L> then
##  $U^{\perp}$ is a subalgebra of <L>.
##
DeclareOperation( "KappaPerp",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#O  IsNilpotentElement( <L>, <x> )
##
##  <x> is nilpotent in <L> if its adjoint matrix is a nilpotent matrix.
##
DeclareOperation( "IsNilpotentElement",
    [ IsAlgebra and IsLieAlgebra, IsRingElement ] );


#############################################################################
##
#O  PowerSi( <one>, <i> )
#A  PowerS( <L> )
##
##  <one> is the identity in a field $F$ of characteristic $p$.
##  The $p$-th power map of a restricted Lie algebra over $F$
##  satisfies the following relation.
##  $(x+y)^{[p]} = x^{[p]} + y^{[p]} + \sum_{i=1}^{p-1} s_i(x,y)$
##  where $i s_i(x,y)$ is the coefficient of $T^{i-1}$ in the polynomial
##  $( ad (Tx+y) )^{p-1} (x)$ (see Jacobson, p. 187f.).
##  From this it follows that
##  $i s_i(x,y) = \sum [ \ldots [[[x,y],a_1],a_2]\ldots, a_{p-2}]$ where
##  $a_j$ is $x$ or $y$ where the sum is taken over all words
##  $w = a_1 \cdots a_n$ such that $w$ contains $i-1$ $x$'s and $p-2-i+1$
##  $y$'s.
##
##  'PowerSi' returns the function $s_i$, which only depends on $p$ and
##  $i$ and not on the Lie algebra or on $F$.
##
##  'PowerS' returns the list $[ s_1, \ldots, s_{p-1} ]$ of all s-functions
##  as computed by 'PowerSi'.
##
DeclareGlobalFunction( "PowerSi" );

DeclareAttribute( "PowerS", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#O  PthPowerImage( <B>, <x> )
##
##  <B> is a basis of a Lie algebra $L$.
##  This function calculates for an element <x> of $L$ the image $x^{[p]}$
##  under the $p$-th power map.
##
DeclareOperation( "PthPowerImage", [ IsBasis, IsRingElement ] );


#############################################################################
##
#O  FindSl2( <L>, <x> )
##
##  This function tries to find a subalgebra $S$ of the Lie algebra <L> with
##  $S$ isomorphic to $sl_2$ and such that the nilpotent element <x> of <L>
##  is contained in $S$.
##  If such an algebra exists then it is returned,
##  otherwise 'fail' is returned.
##
DeclareGlobalFunction( "FindSl2" );


##############################################################################
##
#A  RootSystem( <L> )
##
##  'RootSystem' calculates the root system of the semisimple Lie algebra
##  <L>.
##  The output is a record with the following components.
##  `roots' (the roots as elements of <L>),
##  `rootvecs' (the roots as vectors), 
##  `fundroots' (set of fundamental roots), 
##  `cartanmat' (the Cartan matrix of the root system)
##  The roots are sorted according to increasing height.
##
DeclareAttribute( "RootSystem", IsAlgebra and IsLieAlgebra );


##############################################################################
##
#F  SimpleLieAlgebra( <type>, <n>, <F> )
##
##
##  This function constructs the simple Lie algebra of type <type> and
##  of rank <n> over the field <F>.
##
##  <type> must be one of A, B, C, D, E, F, G,
##  H, K, S, W. For the types A to G, <n> must be a positive integer.
##  The last four types only exist over fields of characteristic $p>0$.
##  If the type is H, then <n> must be a list of positive integers of 
##  even length.
##  If the type is K, then <n> must be a list of positive integers of odd 
##  length.
##  For the other types, S and W, <n> must be a list of positive integers
##  of any length. Sometimes the Lie algebra returned by this function
##  is not simple. Examples are the Lie algebras of type $A_n$ over a field
##  of charcteristic $p>0$ where $p$ divides $n+1$, and the Lie algebras
##  of type $K_n$ where $n$ is a list of length 1.
##
DeclareGlobalFunction( "SimpleLieAlgebra" );


#############################################################################
##
#F  DescriptionOfNormalizedUEAElement( <T>, <listofpairs> )
##
##  <T> is the structure constants table of a finite dim. Lie algebra $L$.
##
##  <listofpairs> is a list of the form
##  $[ l_1, c_1, l_2, c_2, \ldots, l_n, c_n ]$
##  where the $c_i$ are coefficients and the $l_i$ encode monomials
##  $x_{i_1}^{e_1} x_{i_2}^{e_2} \cdots x_{i_m}^{e_m}$ as lists
##  $[ i_1, e_1, i_2, e_2, \ldots, i_m, e_m ]$.
##  (All $e_k$ are nonzero.)
##  Here the generator $x_k$ of the universal enveloping algebra corresponds
##  to the $k$-th basis vector of $L$.
##
##  'DescriptionOfNormalizedUEAElement' applies successively the rewriting
##  rules of the universal enveloping algebra of $L$ such that the final
##  value descibes the same element as <listofpairs>, each monomial is
##  normalized, and the monomials are ordered lexicographically.
##  This list is the return value.
##
DeclareGlobalFunction(
    "DescriptionOfNormalizedUEAElement" );


#############################################################################
##
#A  UniversalEnvelopingAlgebra( <L> ) . . . . . . . . . . . for a Lie algebra
##
##  Returns the universal enveloping algebra of the Lie algebra <L>.
##
DeclareAttribute(
    "UniversalEnvelopingAlgebra",
    IsLieAlgebra );


#############################################################################
##
#F  FreeLieAlgebra( <R>, <rank> )
#F  FreeLieAlgebra( <R>, <rank>, <name> )
#F  FreeLieAlgebra( <R>, <name1>, <name2>, ... )
##
##  Returns the free Lie algebra of rank <rank> over the ring <R>. 
##  'FreeLieAlgebra( <R>, <name1>, <name2>,...)' returns the free Lie algebra
##  over <R> with generators named <name1>, <name2>, and so on.
##  
DeclareGlobalFunction( "FreeLieAlgebra" );


#############################################################################
##
#C  IsFamilyElementOfFreeLieAlgebra( <Fam> )
##
##  We need this for the normalization method, which takes a family as first
##  argument.
##
DeclareCategory( "IsFamilyElementOfFreeLieAlgebra",
    IsElementOfMagmaRingModuloRelationsFamily );


#############################################################################
##
#E  alglie.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here









