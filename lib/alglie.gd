#############################################################################
##
#W  alglie.gd                   GAP library                     Thomas Breuer
#W                                                        and Willem de Graaf
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declaration of attributes, properties, and
##  operations for Lie algebras.
##
Revision.alglie_gd :=
    "@(#)$Id$";


#############################################################################
##
#P  IsAbelianLieAlgebra( <L> )
##
##  is 'true' if <L> is a Lie algebra such that each product of elements in
##  <L> is zero, and 'false' otherwise.
##
IsAbelianLieAlgebra := NewProperty( "IsAbelianLieAlgebra",
    IsAlgebra and IsLieAlgebra );
SetIsAbelianLieAlgebra := Setter( IsAbelianLieAlgebra );
HasIsAbelianLieAlgebra := Tester( IsAbelianLieAlgebra );


#############################################################################
##
#P  IsNilpotentAlgebra( <L> )
##
##  A Lie algebra <L> is defined to be {\em nilpotent} when its lower central
##  series reaches the trivial subalgebra.
##
IsNilpotentAlgebra := NewProperty( "IsNilpotentAlgebra",
    IsAlgebra and IsLieAlgebra );
SetIsNilpotentAlgebra := Setter( IsNilpotentAlgebra );
HasIsNilpotentAlgebra := Tester( IsNilpotentAlgebra );


#############################################################################
##
#P  IsRestrictedLieAlgebra( <L> )
##
##  A Lie algebra <L> is defined to be {\em restricted} when it is defined
##  over a field of characteristic $p \neq 0$, and for every basis element
##  $x$ of <L> there exists $y\in <L>$ such that $(ad x)^p = ad y$
##  (see Jacobson, p. 190).
##
IsRestrictedLieAlgebra := NewProperty( "IsRestrictedLieAlgebra",
    IsAlgebra and IsLieAlgebra );
SetIsRestrictedLieAlgebra := Setter( IsRestrictedLieAlgebra );
HasIsRestrictedLieAlgebra := Tester( IsRestrictedLieAlgebra );


#############################################################################
##
#P  IsSolvableAlgebra( <L> )
##
##  A Lie algebra <L> is defined to be {\em solvable} when its derived
##  series reaches the trivial subalgebra.
##
IsSolvableAlgebra := NewProperty( "IsSolvableAlgebra",
    IsAlgebra and IsLieAlgebra );
SetIsSolvableAlgebra := Setter( IsSolvableAlgebra );
HasIsSolvableAlgebra := Tester( IsSolvableAlgebra );


#############################################################################
##
#A  DerivedSeriesOfAlgebra( <L> )
##
DerivedSeriesOfAlgebra:= NewAttribute( "DerivedSeriesOfAlgebra",
    IsAlgebra and IsLieAlgebra );
SetDerivedSeriesOfAlgebra:= Setter( DerivedSeriesOfAlgebra );
HasDerivedSeriesOfAlgebra:= Tester( DerivedSeriesOfAlgebra );


#############################################################################
##
#A  LowerCentralSeriesOfAlgebra( <L> )
##
LowerCentralSeriesOfAlgebra:= NewAttribute( "LowerCentralSeriesOfAlgebra",
    IsAlgebra and IsLieAlgebra );
SetLowerCentralSeriesOfAlgebra:= Setter( LowerCentralSeriesOfAlgebra );
HasLowerCentralSeriesOfAlgebra:= Tester( LowerCentralSeriesOfAlgebra );


#############################################################################
##
#A  UpperCentralSeriesOfAlgebra( <L> )
##
UpperCentralSeriesOfAlgebra:= NewAttribute( "UpperCentralSeriesOfAlgebra",
    IsAlgebra and IsLieAlgebra );
SetUpperCentralSeriesOfAlgebra:= Setter( UpperCentralSeriesOfAlgebra );
HasUpperCentralSeriesOfAlgebra:= Tester( UpperCentralSeriesOfAlgebra );


#############################################################################
##
#A  LieCentre( <L> )
##
##  The Lie centre of the Lie algebra <L> is the kernel of the adjoint
##  mapping, that is, the set $\{ a \in L; a x = 0 \forall x \in L \}$.
##
##  In characteristic 2 this may differ from the usual centre.
##  (Every Lie algebra in characteristic 2 is abelian.)
##
##  Additionally we know that the centre of a Lie algebra is an ideal.
##
LieCentre:= NewAttribute( "LieCentre", IsAlgebra and IsLieAlgebra );
SetLieCentre:= Setter( LieCentre );
HasLieCentre:= Tester( LieCentre );


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
Derivations := NewAttribute( "Derivations", IsBasis );
SetDerivations := Setter( Derivations );
HasDerivations := Tester( Derivations );


#############################################################################
##
#A  KillingMatrix( <B> )
##
##  is the matrix $\kappa$ of the killing form w.r.t. the basis <B>.
##
##  We have $\kappa_{i,j} = \sum_{k,l=1}^n c_{jkl} c_{ilk}$
##  where $c_{ijk}$ are the structure constants w.r.t. <B>.
##
KillingMatrix := NewAttribute( "KillingMatrix", IsBasis );
SetKillingMatrix := Setter( KillingMatrix );
HasKillingMatrix := Tester( KillingMatrix );


#############################################################################
##
#A  CartanSubalgebra( <L> )
##
##  A Cartan subalgebra of a Lie algebra <L> is defined as a nilpotent
##  subalgebra of <L> equal to its own Lie normalizer in <L>.
##
CartanSubalgebra := NewAttribute( "CartanSubalgebra",
    IsAlgebra and IsLieAlgebra );
SetCartanSubalgebra := Setter( CartanSubalgebra );
HasCartanSubalgebra := Tester( CartanSubalgebra );


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
PthPowerImages := NewAttribute( "PthPowerImages", IsBasis );
SetPthPowerImages := Setter( PthPowerImages );
HasPthPowerImages := Tester( PthPowerImages );


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
NonNilpotentElement := NewAttribute( "NonNilpotentElement",
    IsAlgebra and IsLieAlgebra );
SetNonNilpotentElement := Setter( NonNilpotentElement );
HasNonNilpotentElement := Tester( NonNilpotentElement );


#############################################################################
##
#A  AdjointAssociativeAlgebra( <L> )
##
##  is the associative matrix algebra generated by the adjoint matrices of
##  the Lie algebra <L>.
##
AdjointAssociativeAlgebra := NewAttribute( "AdjointAssociativeAlgebra",
    IsAlgebra and IsLieAlgebra );
SetAdjointAssociativeAlgebra := Setter( AdjointAssociativeAlgebra );
HasAdjointAssociativeAlgebra := Tester( AdjointAssociativeAlgebra );


#############################################################################
##
#A  NilRadical( <L> )
##
##  This function calculates the nil radical $NR( <L> )$ of the Lie algebra
##  <L>.
##
NilRadical := NewAttribute( "NilRadical", IsAlgebra and IsLieAlgebra );
SetNilRadical := Setter( NilRadical );
HasNilRadical := Tester( NilRadical );


#############################################################################
##
#A  SolvableRadical( <L> )
##
SolvableRadical := NewAttribute( "SolvableRadical",
    IsAlgebra and IsLieAlgebra );
SetSolvableRadical := Setter( SolvableRadical );
HasSolvableRadical := Tester( SolvableRadical );


#############################################################################
##
#A  LeviDecomposition( <L> )
##
##  A Levi subalgebra of the Lie algebra <L> is a semisimple subalgebra
##  complementary to the solvable radical of <L>.
##
LeviDecomposition := NewAttribute( "LeviDecomposition",
    IsAlgebra and IsLieAlgebra );
SetLeviDecomposition := Setter( LeviDecomposition );
HasLeviDecomposition := Tester( LeviDecomposition );


#############################################################################
##
#A  DirectSumDecomposition( <L> )
##
##  This function calculates a list of ideals of the Lie algebra <L> such
##  that <L> is equal to their direct sum.
##
DirectSumDecomposition := NewAttribute( "DirectSumDecomposition",
    IsAlgebra and IsLieAlgebra );
SetDirectSumDecomposition := Setter( DirectSumDecomposition );
HasDirectSumDecomposition := Tester( DirectSumDecomposition );


#############################################################################
##
#A  SemiSimpleType( <L> )
##
##  A simple Lie algebra is either an element of the "great" classes
##  of simple Lie algebas ($A_n$, $B_n$, $C_n$, $D_n$),
##  or an exceptional algebra ($E_6$, $E_7$, $E_8$, $F_4$, $G_2$).
##
##  Let <L> be a semisimple Lie algebra, i.e., a direct sum of simple
##  Lie algebras.
##
##  'SemiSimpleType' returns ...
##
SemiSimpleType := NewAttribute( "SemiSimpleType",
    IsAlgebra and IsLieAlgebra );
SetSemiSimpleType := Setter( SemiSimpleType );
HasSemiSimpleType := Tester( SemiSimpleType );


#############################################################################
##
#O  LieCentralizer( <L>, <S> )
##
##  is the annihilator of <S> in the Lie algebra <L>, that is, the set
##  $\{ a \in L; a \* s = 0 \forall s \in S \}$.
##  Here <S> may be a subspace or a subalgebra of <L>.
##
LieCentralizer:= NewOperation( "LieCentralizer",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#A  LieCentralizerInParent( <S> )
##
##  is the Lie centralizer of the vector space <S> in its parent Lie algebra
##  $L$.
##
LieCentralizerInParent:= NewAttribute( "LieCentralizerInParent",
    IsAlgebra and IsLieAlgebra );
SetLieCentralizerInParent:= Setter( LieCentralizerInParent );
HasLieCentralizerInParent:= Tester( LieCentralizerInParent );


#############################################################################
##
#O  LieNormalizer( <L>, <U> )
##
##  is the normalizer of the subspace <U> in the Lie algebra <L>,
##  that is, the set $N_L(U) = \{ x \in L; [x,U] \subset U \}$.
##
LieNormalizer:= NewOperation( "LieNormalizer",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#A  LieNormalizerInParent( <S> )
##
##  is the Lie normalizer of the vector space <S> in its parent Lie algebra
##  $L$.
##
LieNormalizerInParent:= NewAttribute( "LieNormalizerInParent",
    IsAlgebra and IsLieAlgebra );
SetLieNormalizerInParent:= Setter( LieNormalizerInParent );
HasLieNormalizerInParent:= Tester( LieNormalizerInParent );


#############################################################################
##
#O  AdjointMatrix( <B>, <x> )
##
##  is the matrix of the adjoint representation of the element <x> w.r.t.
##  the basis <B>.
##
AdjointMatrix := NewOperation( "AdjointMatrix", [ IsBasis, IsRingElement ] );


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
KappaPerp := NewOperation( "KappaPerp",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#O  IsNilpotentElement( <L>, <x> )
##
##  <x> is nilpotent in <L> if its adjoint matrix $A$ is a nilpotent matrix.
##
IsNilpotentElement := NewOperation( "IsNilpotentElement",
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
PowerSi := NewOperationArgs( "PowerSi" );

PowerS := NewAttribute( "PowerS", IsAlgebra and IsLieAlgebra );
SetPowerS := Setter( PowerS );
HasPowerS := Tester( PowerS );


#############################################################################
##
#O  PthPowerImage( <B>, <x> )
##
##  <B> is a basis of a Lie algebra $L$.
##  This function calculates for an element <x> of $L$ the image $x^{[p]}$
##  under the $p$-th power map.
##
PthPowerImage := NewOperation( "PthPowerImage", [ IsBasis, IsRingElement ] );


#############################################################################
##
#O  FindSl2( <L>, <x> )
##
##  If the Lie algebra <L> contains a subalgebra that is isomorphic to $sl_2$
##  'FindSl2' returns this algebra, otherwise the result is 'fail'.
##
FindSl2 := NewOperation( "FindSl2",
    [ IsAlgebra and IsLieAlgebra, IsRingElement ] );


#############################################################################
##
#E  alglie.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



