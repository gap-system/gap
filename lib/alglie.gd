#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, and Willem de Graaf.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration of attributes, properties, and
##  operations for Lie algebras.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{alglie}">
##  A Lie algebra <M>L</M> is an algebra such that
##  <M>x x = 0</M> and <M>x(yz) + y(zx) + z(xy) = 0</M>
##  for all <M>x, y, z \in L</M>.
##  A common way of creating a Lie algebra is by taking an associative
##  algebra together with the commutator as product.
##  Therefore the product of two elements <M>x, y</M> of a Lie algebra
##  is usually denoted by  <M>[x,y]</M>,
##  but in &GAP; this denotes the list of the elements <M>x</M> and <M>y</M>;
##  hence the product of elements is made by the usual <C>*</C>.
##  This gives no problems when dealing with Lie algebras given by a
##  table of structure constants.
##  However, for matrix Lie algebras the situation is not so easy
##  as <C>*</C> denotes the ordinary (associative) matrix multiplication.
##  In &GAP; this problem is solved by wrapping
##  elements of a matrix Lie algebra up as <C>LieObject</C>s,
##  and then define  the <C>*</C> for <C>LieObject</C>s to be the commutator
##  (see <Ref Sect="Lie Objects"/>).
##  <#/GAPDoc>
##


#############################################################################
##
#P  IsLieAbelian( <L> )
##
##  <#GAPDoc Label="IsLieAbelian">
##  <ManSection>
##  <Prop Name="IsLieAbelian" Arg='L'/>
##
##  <Description>
##  returns <K>true</K> if <A>L</A> is a Lie algebra such that each
##  product of elements in <A>L</A> is zero, and <K>false</K> otherwise.
##  <Example><![CDATA[
##  gap>  T:= EmptySCTable( 5, 0, "antisymmetric" );;
##  gap>  L:= LieAlgebraByStructureConstants( Rationals, T );
##  <Lie algebra of dimension 5 over Rationals>
##  gap> IsLieAbelian( L );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsLieAbelian", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#P  IsLieNilpotent( <L> )
##
##  <#GAPDoc Label="IsLieNilpotent">
##  <ManSection>
##  <Prop Name="IsLieNilpotent" Arg='L'/>
##
##  <Description>
##  A Lie algebra <A>L</A> is defined to be (Lie) <E>nilpotent</E>
##  when its (Lie) lower central series reaches the trivial subalgebra.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 5, 0, "antisymmetric" );;
##  gap> L:= LieAlgebraByStructureConstants( Rationals, T );
##  <Lie algebra of dimension 5 over Rationals>
##  gap> IsLieNilpotent( L );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsLieNilpotent", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#P  IsRestrictedLieAlgebra( <L> )
##
##  <#GAPDoc Label="IsRestrictedLieAlgebra">
##  <ManSection>
##  <Prop Name="IsRestrictedLieAlgebra" Arg='L'/>
##
##  <Description>
##  Test whether <A>L</A> is restricted.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "W", [2], GF(5));
##  <Lie algebra of dimension 25 over GF(5)>
##  gap> IsRestrictedLieAlgebra( L );
##  false
##  gap> L:= SimpleLieAlgebra( "W", [1], GF(5));
##  <Lie algebra of dimension 5 over GF(5)>
##  gap> IsRestrictedLieAlgebra( L );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsRestrictedLieAlgebra", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  LieDerivedSubalgebra( <L> )
##
##  <#GAPDoc Label="LieDerivedSubalgebra">
##  <ManSection>
##  <Attr Name="LieDerivedSubalgebra" Arg='L'/>
##
##  <Description>
##  is the (Lie) derived subalgebra of the Lie algebra <A>L</A>.
##  <Example><![CDATA[
##  gap>  L:= FullMatrixLieAlgebra( GF( 3 ), 3 );
##  <Lie algebra over GF(3), with 5 generators>
##  gap> LieDerivedSubalgebra( L );
##  <Lie algebra of dimension 8 over GF(3)>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieDerivedSubalgebra", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  LieDerivedSeries( <L> )
##
##  <#GAPDoc Label="LieDerivedSeries">
##  <ManSection>
##  <Attr Name="LieDerivedSeries" Arg='L'/>
##
##  <Description>
##  is the (Lie) derived series of the Lie algebra <A>L</A>.
##  <Example><![CDATA[
##  gap> mats:= [ [[1,0],[0,0]], [[0,1],[0,0]], [[0,0],[0,1]] ];;
##  gap> L:= LieAlgebra( Rationals, mats );;
##  gap> LieDerivedSeries( L );
##  [ <Lie algebra of dimension 3 over Rationals>,
##    <Lie algebra of dimension 1 over Rationals>,
##    <Lie algebra of dimension 0 over Rationals> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieDerivedSeries", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#P  IsLieSolvable( <L> )
##
##  <#GAPDoc Label="IsLieSolvable">
##  <ManSection>
##  <Prop Name="IsLieSolvable" Arg='L'/>
##
##  <Description>
##  A Lie algebra <A>L</A> is defined to be (Lie) <E>solvable</E>
##  when its (Lie) derived series reaches the trivial subalgebra.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 5, 0, "antisymmetric" );;
##  gap> L:= LieAlgebraByStructureConstants( Rationals, T );
##  <Lie algebra of dimension 5 over Rationals>
##  gap> IsLieSolvable( L );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsLieSolvable", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  LieLowerCentralSeries( <L> )
##
##  <#GAPDoc Label="LieLowerCentralSeries">
##  <ManSection>
##  <Attr Name="LieLowerCentralSeries" Arg='L'/>
##
##  <Description>
##  is the (Lie) lower central series of the Lie algebra <A>L</A>.
##  <Example><![CDATA[
##  gap> mats:= [ [[ 1, 0 ], [ 0, 0 ]], [[0,1],[0,0]], [[0,0],[0,1]] ];;
##  gap> L:=LieAlgebra( Rationals, mats );;
##  gap> LieLowerCentralSeries( L );
##  [ <Lie algebra of dimension 3 over Rationals>,
##    <Lie algebra of dimension 1 over Rationals> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieLowerCentralSeries", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  LieUpperCentralSeries( <L> )
##
##  <#GAPDoc Label="LieUpperCentralSeries">
##  <ManSection>
##  <Attr Name="LieUpperCentralSeries" Arg='L'/>
##
##  <Description>
##  is the (Lie) upper central series of the Lie algebra <A>L</A>.
##  <Example><![CDATA[
##  gap> mats:= [ [[ 1, 0 ], [ 0, 0 ]], [[0,1],[0,0]], [[0,0],[0,1]] ];;
##  gap> L:=LieAlgebra( Rationals, mats );;
##  gap> LieUpperCentralSeries( L );
##  [ <two-sided ideal in <Lie algebra of dimension 3 over Rationals>,
##        (dimension 1)>, <Lie algebra of dimension 0 over Rationals>
##   ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieUpperCentralSeries", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  LieCentre( <L> )
#A  LieCenter( <L> )
##
##  <#GAPDoc Label="LieCentre">
##  <ManSection>
##  <Attr Name="LieCentre" Arg='L'/>
##  <Attr Name="LieCenter" Arg='L'/>
##
##  <Description>
##  The <E>Lie</E> centre of the Lie algebra <A>L</A> is the kernel of the
##  adjoint mapping, that is,
##  the set <M>\{ a \in L : \forall x \in L: a x = 0 \}</M>.
##  <P/>
##  In characteristic <M>2</M> this may differ from the usual centre
##  (that is the set of all <M>a \in L</M> such that <M>a x = x a</M>
##  for all <M>x \in L</M>).
##  Therefore, this operation is named <Ref Attr="LieCentre"/>
##  and not <Ref Attr="Centre"/>.
##  <Example><![CDATA[
##  gap> L:= FullMatrixLieAlgebra( GF(3), 3 );
##  <Lie algebra over GF(3), with 5 generators>
##  gap> LieCentre( L );
##  <two-sided ideal in <Lie algebra of dimension 9 over GF(3)>,
##    (dimension 1)>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieCentre", IsAlgebra and IsLieAlgebra );

DeclareSynonymAttr( "LieCenter", LieCentre );


#############################################################################
##
#A  RightDerivations( <B> )
#A  LeftDerivations( <B> )
#A  Derivations( <B> )
##
##  <#GAPDoc Label="RightDerivations">
##  <ManSection>
##  <Attr Name="RightDerivations" Arg='B'/>
##  <Attr Name="LeftDerivations" Arg='B'/>
##  <Attr Name="Derivations" Arg='B'/>
##
##  <Description>
##  These functions all return the matrix Lie algebra of derivations
##  of the algebra <M>A</M> with basis <A>B</A>.
##  <P/>
##  <C>RightDerivations( <A>B</A> )</C> returns the algebra of derivations
##  represented by their right action on the algebra <M>A</M>.
##  This means that with respect to the basis <M>B</M> of <M>A</M>,
##  the derivation <M>D</M> is described by the matrix <M>[ d_{{i,j}} ]</M>
##  which means that <M>D</M> maps the <M>i</M>-th basis element <M>b_i</M>
##  to  <M>\sum_{{j = 1}}^n d_{{i,j}} b_j</M>.
##  <P/>
##  <C>LeftDerivations( <A>B</A> )</C> returns the Lie algebra of derivations
##  represented by their left action on the algebra <M>A</M>.
##  So the matrices contained in the algebra output by
##  <C>LeftDerivations( <A>B</A> )</C> are the transposes of the
##  matrices contained in the output of <C>RightDerivations( <A>B</A> )</C>.
##  <P/>
##  <Ref Attr="Derivations"/> is just a synonym for
##  <Ref Attr="RightDerivations"/>.
##  <Example><![CDATA[
##  gap> A:= OctaveAlgebra( Rationals );
##  <algebra of dimension 8 over Rationals>
##  gap> L:= Derivations( Basis( A ) );
##  <Lie algebra of dimension 14 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RightDerivations", IsBasis );
DeclareAttribute( "LeftDerivations", IsBasis );
DeclareSynonymAttr( "Derivations", RightDerivations );


#############################################################################
##
#A  KillingMatrix( <B> )
##
##  <#GAPDoc Label="KillingMatrix">
##  <ManSection>
##  <Attr Name="KillingMatrix" Arg='B'/>
##
##  <Description>
##  is the matrix of the Killing form <M>\kappa</M> with respect to the basis
##  <A>B</A>, i.e., the matrix <M>( \kappa( b_i, b_j ) )</M>
##  where <M>b_1, b_2, \ldots</M> are the basis vectors of <A>B</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> KillingMatrix( Basis( L ) );
##  [ [ 0, 4, 0 ], [ 4, 0, 0 ], [ 0, 0, 8 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "KillingMatrix", IsBasis );


#############################################################################
##
#A  CartanSubalgebra( <L> )
##
##  <#GAPDoc Label="CartanSubalgebra">
##  <ManSection>
##  <Attr Name="CartanSubalgebra" Arg='L'/>
##
##  <Description>
##  A Cartan subalgebra of a Lie algebra <A>L</A> is defined as a nilpotent
##  subalgebra of <A>L</A> equal to its own Lie normalizer in <A>L</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "G", 2, Rationals );;
##  gap> CartanSubalgebra( L );
##  <Lie algebra of dimension 2 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CartanSubalgebra",
    IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  PthPowerImages( <B> )
##
##  <#GAPDoc Label="PthPowerImages">
##  <ManSection>
##  <Attr Name="PthPowerImages" Arg='B'/>
##
##  <Description>
##  Here <A>B</A> is a basis of a restricted Lie algebra.
##  This function returns the list of the images of the basis vectors of
##  <A>B</A> under the <M>p</M>-map.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "W", [1], GF(11) );
##  <Lie algebra of dimension 11 over GF(11)>
##  gap> B:= Basis( L );
##  CanonicalBasis( <Lie algebra of dimension 11 over GF(11)> )
##  gap> PthPowerImages( B );
##  [ 0*v.1, v.2, 0*v.1, 0*v.1, 0*v.1, 0*v.1, 0*v.1, 0*v.1, 0*v.1, 0*v.1,
##    0*v.1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PthPowerImages", IsBasis );


#############################################################################
##
#A  NonNilpotentElement( <L> )
##
##  <#GAPDoc Label="NonNilpotentElement">
##  <ManSection>
##  <Attr Name="NonNilpotentElement" Arg='L'/>
##
##  <Description>
##  A non-nilpotent element of a Lie algebra <A>L</A> is an element <M>x</M>
##  such that ad<M>x</M> is not nilpotent.
##  If <A>L</A> is not nilpotent, then by Engel's theorem non-nilpotent
##  elements exist in <A>L</A>.
##  In this case this function returns a non-nilpotent element of <A>L</A>,
##  otherwise (if <A>L</A> is nilpotent) <K>fail</K> is returned.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "G", 2, Rationals );;
##  gap> NonNilpotentElement( L );
##  v.13
##  gap> IsNilpotentElement( L, last );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NonNilpotentElement", IsAlgebra and IsLieAlgebra );

DeclareSynonymAttr( "NonLieNilpotentElement", NonNilpotentElement);


#############################################################################
##
#A  AdjointAssociativeAlgebra( <L>, <K> )
##
##  <#GAPDoc Label="AdjointAssociativeAlgebra">
##  <ManSection>
##  <Oper Name="AdjointAssociativeAlgebra" Arg='L, K'/>
##
##  <Description>
##  is the associative matrix algebra (with 1) generated by the matrices of
##  the adjoint representation of the subalgebra <A>K</A> on the Lie
##  algebra <A>L</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> AdjointAssociativeAlgebra( L, L );
##  <algebra of dimension 9 over Rationals>
##  gap> AdjointAssociativeAlgebra( L, CartanSubalgebra( L ) );
##  <algebra of dimension 3 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AdjointAssociativeAlgebra",
    [ IsAlgebra and IsLieAlgebra, IsAlgebra and IsLieAlgebra ] );


#############################################################################
##
#A  LieNilRadical( <L> )
##
##  <#GAPDoc Label="LieNilRadical">
##  <ManSection>
##  <Attr Name="LieNilRadical" Arg='L'/>
##
##  <Description>
##  This function calculates the (Lie) nil radical of the Lie algebra
##  <A>L</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> mats:= [ [[1,0],[0,0]], [[0,1],[0,0]], [[0,0],[0,1]] ];;
##  gap> L:= LieAlgebra( Rationals, mats );;
##  gap> LieNilRadical( L );
##  <two-sided ideal in <Lie algebra of dimension 3 over Rationals>,
##    (dimension 2)>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieNilRadical", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  LieSolvableRadical( <L> )
##
##  <#GAPDoc Label="LieSolvableRadical">
##  <ManSection>
##  <Attr Name="LieSolvableRadical" Arg='L'/>
##
##  <Description>
##  Returns the (Lie) solvable radical of the Lie algebra <A>L</A>.
##  <Example><![CDATA[
##  gap> L:= FullMatrixLieAlgebra( Rationals, 3 );;
##  gap> LieSolvableRadical( L );
##  <two-sided ideal in <Lie algebra of dimension 9 over Rationals>,
##    (dimension 1)>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LieSolvableRadical", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#A  SemiSimpleType( <L> )
##
##  <#GAPDoc Label="SemiSimpleType">
##  <ManSection>
##  <Attr Name="SemiSimpleType" Arg='L'/>
##
##  <Description>
##  Let <A>L</A> be a semisimple Lie algebra, i.e., a direct sum of simple
##  Lie algebras.
##  Then <Ref Attr="SemiSimpleType"/> returns the type of <A>L</A>, i.e.,
##  a string containing the types of the simple summands of <A>L</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "E", 8, Rationals );;
##  gap> b:= BasisVectors( Basis( L ) );;
##  gap> K:= LieCentralizer(L, Subalgebra(L, [ b[61]+b[79]+b[101]+b[102] ]));
##  <Lie algebra of dimension 102 over Rationals>
##  gap> lev:= LeviMalcevDecomposition(K);;
##  gap> SemiSimpleType( lev[1] );
##  "B3 A1"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SemiSimpleType", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#O  LieCentralizer( <L>, <S> )
##
##  <#GAPDoc Label="LieCentralizer">
##  <ManSection>
##  <Oper Name="LieCentralizer" Arg='L, S'/>
##
##  <Description>
##  is the annihilator of <A>S</A> in the Lie algebra <A>L</A>, that is,
##  the set <M>\{ a \in L : \forall s \in S: a*s = 0 \}</M>.
##  Here <A>S</A> may be a subspace or a subalgebra of <A>L</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "G", 2, Rationals );
##  <Lie algebra of dimension 14 over Rationals>
##  gap> b:= BasisVectors( Basis( L ) );;
##  gap> LieCentralizer( L, Subalgebra( L, [ b[1], b[2] ] ) );
##  <Lie algebra of dimension 1 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LieCentralizer",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#A  LieCentralizerInParent( <S> )
##
##  <ManSection>
##  <Attr Name="LieCentralizerInParent" Arg='S'/>
##
##  <Description>
##  is the Lie centralizer of the vector space <A>S</A>
##  in its parent Lie algebra <M>L</M>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "LieCentralizerInParent", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#O  LieNormalizer( <L>, <U> )
##
##  <#GAPDoc Label="LieNormalizer">
##  <ManSection>
##  <Oper Name="LieNormalizer" Arg='L, U'/>
##
##  <Description>
##  is the normalizer of the subspace <A>U</A> in the Lie algebra <A>L</A>,
##  that is, the set <M>N_L(U) = \{ x \in L : [x,U] \subset U \}</M>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "G", 2, Rationals );
##  <Lie algebra of dimension 14 over Rationals>
##  gap> b:= BasisVectors( Basis( L ) );;
##  gap> LieNormalizer( L, Subalgebra( L, [ b[1], b[2] ] ) );
##  <Lie algebra of dimension 8 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LieNormalizer",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#A  LieNormalizerInParent( <S> )
##
##  <ManSection>
##  <Attr Name="LieNormalizerInParent" Arg='S'/>
##
##  <Description>
##  is the Lie normalizer of the vector space <A>S</A>
##  in its parent Lie algebra <M>L</M>.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "LieNormalizerInParent", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#O  AdjointMatrix( <B>, <x> )
##
##  <#GAPDoc Label="AdjointMatrix">
##  <ManSection>
##  <Oper Name="AdjointMatrix" Arg='B, x'/>
##
##  <Description>
##  is the matrix of the adjoint representation of the element <A>x</A>
##  w.r.t. the basis <A>B</A>.
##  The adjoint map is the left multiplication by <A>x</A>.
##  The <M>i</M>-th column of the resulting matrix represents the image of
##  the <M>i</M>-th basis vector of <A>B</A> under left multiplication by
##  <A>x</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> AdjointMatrix( Basis( L ), Basis( L )[1] );
##  [ [ 0, 0, -2 ], [ 0, 0, 0 ], [ 0, 1, 0 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AdjointMatrix", [ IsBasis, IsRingElement ] );


#############################################################################
##
#O  KappaPerp( <L>, <U> )
##
##  <#GAPDoc Label="KappaPerp">
##  <ManSection>
##  <Oper Name="KappaPerp" Arg='L, U'/>
##
##  <Description>
##  is the orthogonal complement of the subspace <A>U</A> of the Lie algebra
##  <A>L</A> with respect to the Killing form <M>\kappa</M>, that is,
##  the set <M>U^{{\perp}} = \{ x \in L; \kappa( x, y ) = 0 \hbox{ for all }
##  y \in L \}</M>.
##  <P/>
##  <M>U^{{\perp}}</M> is a subspace of <A>L</A>, and if <A>U</A> is an ideal
##  of <A>L</A> then <M>U^{{\perp}}</M> is a subalgebra of <A>L</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> b:= BasisVectors( Basis( L ) );;
##  gap> V:= VectorSpace( Rationals, [b[1],b[2]] );;
##  gap> KappaPerp( L, V );
##  <vector space of dimension 1 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "KappaPerp",
    [ IsAlgebra and IsLieAlgebra, IsVectorSpace ] );


#############################################################################
##
#O  PowerSi( <one>, <i> )
#A  PowerS( <L> )
##
##  <ManSection>
##  <Oper Name="PowerSi" Arg='one, i'/>
##  <Attr Name="PowerS" Arg='L'/>
##
##  <Description>
##  <A>one</A> is the identity in a field <M>F</M> of characteristic <M>p</M>.
##  The <M>p</M>-th power map of a restricted Lie algebra over <M>F</M>
##  satisfies the following relation.
##  <M>(x+y)^{[p]} = x^{[p]} + y^{[p]} + \sum_{i=1}^{p-1} s_i(x,y)</M>
##  where <M>i s_i(x,y)</M> is the coefficient of <M>T^{i-1}</M> in the polynomial
##  <M>( ad (Tx+y) )^{p-1} (x)</M> (see Jacobson, p. 187f.).
##  From this it follows that
##  <M>i s_i(x,y) = \sum [ \ldots [[[x,y],a_1],a_2]\ldots, a_{p-2}]</M> where
##  <M>a_j</M> is <M>x</M> or <M>y</M> where the sum is taken over all words
##  <M>w = a_1 \cdots a_n</M> such that <M>w</M> contains <M>i-1</M> <M>x</M>'s and <M>p-2-i+1</M>
##  <M>y</M>'s.
##  <P/>
##  <C>PowerSi</C> returns the function <M>s_i</M>, which only depends on <M>p</M> and
##  <M>i</M> and not on the Lie algebra or on <M>F</M>.
##  <P/>
##  <C>PowerS</C> returns the list <M>[ s_1, \ldots, s_{p-1} ]</M> of all s-functions
##  as computed by <C>PowerSi</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PowerSi" );

DeclareAttribute( "PowerS", IsAlgebra and IsLieAlgebra );


#############################################################################
##
#O  PthPowerImage( <B>, <x> )
##
##  <#GAPDoc Label="PthPowerImage">
##  <ManSection>
##  <Oper Name="PthPowerImage" Arg='B, x' Label="for basis and element" />
##  <Oper Name="PthPowerImage" Arg='x'    Label="for element" />
##  <Oper Name="PthPowerImage" Arg='x, n' Label="for element and integer" />
##
##  <Description>
##  This function computes the image of an element <A>x</A> of a restricted
##  Lie algebra under its <M>p</M>-map.
##  <P/>
##  In the first form, a basis of the Lie algebra is provided; this basis
##  stores the <M>p</M>th powers of its elements. It is the traditional
##  form, provided for backwards compatibility.
##  <P/>
##  In its second form, only the element <A>x</A> is provided. It is the only
##  form for elements of Lie algebras with no predetermined basis, such as
##  those constructed by <Ref Attr="LieObject"/>.
##  <P/>
##  In its third form, an extra non-negative integer <A>n</A> is specified;
##  the <M>p</M>-mapping is iterated <A>n</A> times on the element <A>x</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "W", [1], GF(11) );;
##  gap> B:= Basis( L );;
##  gap> x:= B[1]+B[11];
##  v.1+v.11
##  gap> PthPowerImage( B, x );
##  v.1+v.11
##  gap> PthPowerImage( x, 2 );
##  v.1+v.11
##  gap> f := FreeAssociativeAlgebra(GF(2),"x","y");
##  <algebra over GF(2), with 2 generators>
##  gap> x := LieObject(f.1);; y := LieObject(f.2);;
##  gap> x*y; x^2; PthPowerImage(x);
##  LieObject( (Z(2)^0)*x*y+(Z(2)^0)*y*x )
##  LieObject( <zero> of ... )
##  LieObject( (Z(2)^0)*x^2 )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "PthPowerImage", [ IsBasis, IsRingElement ] );
DeclareOperation( "PthPowerImage", [ IsJacobianElement ] );
DeclareOperation( "PthPowerImage", [ IsJacobianElement, IsInt ] );

#############################################################################
##
#O  PClosureSubalgebra( <A> )
##
##  <#GAPDoc Label="PClosureSubalgebra">
##  <ManSection>
##  <Oper Name="PClosureSubalgebra" Arg='A'/>
##
##  <Description>
##  This function computes the smallest restricted Lie algebra that contains
##  <A>A</A>.
##  <Example><![CDATA[
##  gap> L := JenningsLieAlgebra(SmallGroup(4,1)); # group C_4
##  <Lie algebra of dimension 2 over GF(2)>
##  gap> L0 := Subalgebra(L,GeneratorsOfAlgebra(L){[1]});
##  <Lie algebra over GF(2), with 1 generator>
##  gap> Dimension(L0);
##  1
##  gap> PClosureSubalgebra(L0); last=L;
##  <vector space of dimension 2 over GF(2)>
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("PClosureSubalgebra", [IsLieAlgebra and IsJacobianElementCollection]);

#############################################################################
##
#O  FindSl2( <L>, <x> )
##
##  <#GAPDoc Label="FindSl2">
##  <ManSection>
##  <Func Name="FindSl2" Arg='L, x'/>
##
##  <Description>
##  This function tries to find a subalgebra <M>S</M> of the Lie algebra
##  <A>L</A> with <M>S</M> isomorphic to <M>sl_2</M> and such that the
##  nilpotent element <A>x</A> of <A>L</A> is contained in <M>S</M>.
##  If such an algebra exists then it is returned,
##  otherwise <K>fail</K> is returned.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "G", 2, Rationals );;
##  gap> b:= BasisVectors( Basis( L ) );;
##  gap> IsNilpotentElement( L, b[1] );
##  true
##  gap> FindSl2( L, b[1] );
##  <Lie algebra of dimension 3 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FindSl2" );


############################################################################
##
#C  IsRootSystem( <obj> )
##
##  <#GAPDoc Label="IsRootSystem">
##  <ManSection>
##  <Filt Name="IsRootSystem" Arg='obj' Type='Category'/>
##
##  <Description>
##  Category of root systems.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsRootSystem", IsObject );


############################################################################
##
#C  IsRootSystemFromLieAlgebra( <obj> )
##
##  <#GAPDoc Label="IsRootSystemFromLieAlgebra">
##  <ManSection>
##  <Filt Name="IsRootSystemFromLieAlgebra" Arg='obj' Type='Category'/>
##
##  <Description>
##  Category of root systems that come from (semisimple) Lie algebras.
##  They often have special attributes such as
##  <Ref Attr="UnderlyingLieAlgebra"/>,
##  <Ref Attr="PositiveRootVectors"/>,
##  <Ref Attr="NegativeRootVectors"/>,
##  <Ref Attr="CanonicalGenerators"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsRootSystemFromLieAlgebra", IsRootSystem );


##############################################################################
##
#A  UnderlyingLieAlgebra( <R> )
##
##  <#GAPDoc Label="UnderlyingLieAlgebra">
##  <ManSection>
##  <Attr Name="UnderlyingLieAlgebra" Arg='R'/>
##
##  <Description>
##  For a root system <A>R</A> coming from a semisimple Lie algebra <C>L</C>,
##  returns the Lie algebra <C>L</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "UnderlyingLieAlgebra", IsRootSystemFromLieAlgebra );


##############################################################################
##
#A  RootSystem( <L> )
##
##  <#GAPDoc Label="RootSystem">
##  <ManSection>
##  <Attr Name="RootSystem" Arg='L'/>
##
##  <Description>
##  <Ref Attr="RootSystem"/> calculates the root system of the semisimple
##  Lie algebra <A>L</A> with a split Cartan subalgebra.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "G", 2, Rationals );
##  <Lie algebra of dimension 14 over Rationals>
##  gap> R:= RootSystem( L );
##  <root system of rank 2>
##  gap> IsRootSystem( R );
##  true
##  gap> IsRootSystemFromLieAlgebra( R );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RootSystem", IsAlgebra and IsLieAlgebra );


############################################################################
##
#A  PositiveRoots( <R> )
##
##  <#GAPDoc Label="PositiveRoots">
##  <ManSection>
##  <Attr Name="PositiveRoots" Arg='R'/>
##
##  <Description>
##  The list of positive roots of the root system <A>R</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PositiveRoots", IsRootSystem );


############################################################################
##
#A  NegativeRoots( <R> )
##
##  <#GAPDoc Label="NegativeRoots">
##  <ManSection>
##  <Attr Name="NegativeRoots" Arg='R'/>
##
##  <Description>
##  The list of negative roots of the root system <A>R</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NegativeRoots", IsRootSystem );


############################################################################
##
#A  PositiveRootVectors( <R> )
##
##  <#GAPDoc Label="PositiveRootVectors">
##  <ManSection>
##  <Attr Name="PositiveRootVectors" Arg='R'/>
##
##  <Description>
##  A list of positive root vectors of the root system <A>R</A> that comes
##  from a Lie algebra <C>L</C>. This is a list in bijection with the list
##  <C>PositiveRoots( L )</C> (see&nbsp;<Ref Attr="PositiveRoots"/>). The
##  root vector is a non-zero element of the root space (in <C>L</C>) of
##  the corresponding root.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PositiveRootVectors", IsRootSystemFromLieAlgebra );


############################################################################
##
#A  NegativeRootVectors( <R> )
##
##  <#GAPDoc Label="NegativeRootVectors">
##  <ManSection>
##  <Attr Name="NegativeRootVectors" Arg='R'/>
##
##  <Description>
##  A list of negative root vectors of the root system <A>R</A> that comes
##  from a Lie algebra <C>L</C>. This is a list in bijection with the list
##  <C>NegativeRoots( L )</C> (see&nbsp;<Ref Attr="NegativeRoots"/>). The
##  root vector is a non-zero element of the root space (in <C>L</C>) of
##  the corresponding root.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NegativeRootVectors", IsRootSystemFromLieAlgebra );


############################################################################
##
#A  SimpleSystem( <R> )
##
##  <#GAPDoc Label="SimpleSystem">
##  <ManSection>
##  <Attr Name="SimpleSystem" Arg='R'/>
##
##  <Description>
##  A list of simple roots of the root system <A>R</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SimpleSystem", IsRootSystem );


############################################################################
##
#A  CartanMatrix( <R> )
##
##  <#GAPDoc Label="CartanMatrix">
##  <ManSection>
##  <Attr Name="CartanMatrix" Arg='R'/>
##
##  <Description>
##  The Cartan matrix of the root system <A>R</A>, relative to the simple
##  roots in <C>SimpleSystem( <A>R</A> )</C> (see&nbsp;<Ref Attr="SimpleSystem"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CartanMatrix", IsRootSystem );


############################################################################
##
#A  BilinearFormMat( <R> )
##
##  <#GAPDoc Label="BilinearFormMat">
##  <ManSection>
##  <Attr Name="BilinearFormMat" Arg='R'/>
##
##  <Description>
##  The matrix of the bilinear form of the root system <A>R</A>.
##  If we denote this matrix by <M>B</M>, then we have
##  <M>B(i,j) = (\alpha_i, \alpha_j)</M>,
##  where the <M>\alpha_i</M> are the simple roots of <A>R</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BilinearFormMat", IsRootSystem );


############################################################################
##
#A  CanonicalGenerators( <R> )
##
##  <#GAPDoc Label="CanonicalGenerators">
##  <ManSection>
##  <Attr Name="CanonicalGenerators" Arg='R'/>
##
##  <Description>
##  Here <A>R</A> must be a root system coming from a semisimple Lie algebra
##  <C>L</C>.
##  This function returns <M>3l</M> generators of <A>L</A>,
##  <M>x_1, \ldots, x_l, y_1, \ldots, y_l, h_1, \ldots, h_l</M>,
##  where <M>x_i</M> lies in the root space corresponding to the
##  <M>i</M>-th simple root of the root system of <A>L</A>,
##  <M>y_i</M> lies in the root space corresponding to <M>-</M> the
##  <M>i</M>-th simple root,
##  and the <M>h_i</M> are elements of the Cartan subalgebra.
##  These elements satisfy the relations
##  <M>h_i * h_j = 0</M>,
##  <M>x_i * y_j = \delta_{ij} h_i</M>,
##  <M>h_j * x_i = c_{ij} x_i</M>,
##  <M>h_j * y_i = -c_{ij} y_i</M>,
##  where <M>c_{ij}</M> is the entry of the Cartan matrix on position
##  <M>ij</M>.
##  <P/>
##  Also if <M>a</M> is a root of the root system <A>R</A>
##  (so <M>a</M> is a list of numbers),
##  then we have the relation <M>h_i * x = a[i] x</M>,
##  where <M>x</M> is a root vector corresponding to <M>a</M>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "G", 2, Rationals );;
##  gap> R:= RootSystem( L );;
##  gap> UnderlyingLieAlgebra( R );
##  <Lie algebra of dimension 14 over Rationals>
##  gap> PositiveRoots( R );
##  [ [ 2, -1 ], [ -3, 2 ], [ -1, 1 ], [ 1, 0 ], [ 3, -1 ], [ 0, 1 ] ]
##  gap> x:= PositiveRootVectors( R );
##  [ v.1, v.2, v.3, v.4, v.5, v.6 ]
##  gap> g:=CanonicalGenerators( R );
##  [ [ v.1, v.2 ], [ v.7, v.8 ], [ v.13, v.14 ] ]
##  gap> g[3][1]*x[1];
##  (2)*v.1
##  gap> g[3][2]*x[1];
##  (-1)*v.1
##  gap> # i.e., x[1] is the root vector belonging to the root [ 2, -1 ]
##  gap> BilinearFormMat( R );
##  [ [ 1/12, -1/8 ], [ -1/8, 1/4 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CanonicalGenerators", IsRootSystemFromLieAlgebra );

##############################################################################
##
#A  ChevalleyBasis( <L> )
##
##  <#GAPDoc Label="ChevalleyBasis">
##  <ManSection>
##  <Attr Name="ChevalleyBasis" Arg='L'/>
##
##  <Description>
##  Here <A>L</A> must be a semisimple Lie algebra with a split Cartan
##  subalgebra. Then <C>ChevalleyBasis(<A>L</A>)</C> returns a list
##  consisting of three sublists.
##  Together these sublists form a Chevalley basis of <A>L</A>. The first
##  list contains the positive root vectors, the second list contains the
##  negative root vectors, and the third list the Cartan elements of the
##  Chevalley basis.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "G", 2, Rationals );
##  <Lie algebra of dimension 14 over Rationals>
##  gap> ChevalleyBasis( L );
##  [ [ v.1, v.2, v.3, v.4, v.5, v.6 ],
##    [ v.7, v.8, v.9, v.10, v.11, v.12 ], [ v.13, v.14 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ChevalleyBasis", IsLieAlgebra );


##############################################################################
##
#F  SimpleLieAlgebra( <type>, <n>, <F> )
##
##  <#GAPDoc Label="SimpleLieAlgebra">
##  <ManSection>
##  <Func Name="SimpleLieAlgebra" Arg='type, n, F'/>
##
##  <Description>
##  This function constructs the simple Lie algebra of type given by the
##  string <A>type</A> and rank <A>n</A> over the field <A>F</A>. The string
##  <A>type</A> must be one of <C>"A"</C>, <C>"B"</C>, <C>"C"</C>, <C>"D"</C>,
##  <C>"E"</C>, <C>"F"</C>, <C>"G"</C>, <C>"H"</C>, <C>"K"</C>, <C>"S"</C>,
##  <C>"W"</C> or <C>"M"</C>. For the types <C>A</C> to <C>G</C>, <A>n</A>
##  must be a positive integer. The last five types only exist over fields of
##  characteristic <M>p>0</M>. If the type is <C>H</C>, then <A>n</A> must be
##  a list of positive integers of even length.
##  If the type is <C>K</C>, then <A>n</A> must be a list of positive
##  integers of odd length.
##  For the types <C>S</C> and <C>W</C>, <A>n</A> must be a list of positive
##  integers of any length.
##  If the type is <C>M</C>, then the Melikyan algebra is constructed.
##  In this case <A>n</A> must be a list of two positive integers.
##  This Lie algebra only exists over fields of characteristic <M>5</M>.
##  This Lie algebra is <M>&ZZ; \times &ZZ;</M> graded;
##  and the grading can be accessed via the attribute <C>Grading(L)</C>
##  (see&nbsp;<Ref Attr="Grading"/>).
##  In some cases the Lie algebra returned by this function is not simple.
##  Examples are the Lie algebras of type <M>A_n</M> over a field
##  of characteristic <M>p>0</M> where <M>p</M> divides <M>n+1</M>,
##  and the Lie algebras of type <M>K_n</M> where <M>n</M> is a list of
##  length 1.
##  <P/>
##  If <A>type</A> is one of <C>A</C>, <C>B</C>, <C>C</C>, <C>D</C>,
##  <C>E</C>, <C>F</C>, <C>G</C>, and <A>F</A> is a field of characteristic
##  zero, then the basis of the returned Lie algebra is a Chevalley basis.
##  <P/>
##  <Example><![CDATA[
##  gap> SimpleLieAlgebra( "E", 6, Rationals );
##  <Lie algebra of dimension 78 over Rationals>
##  gap> SimpleLieAlgebra( "A", 6, GF(5) );
##  <Lie algebra of dimension 48 over GF(5)>
##  gap> SimpleLieAlgebra( "W", [1,2], GF(5) );
##  <Lie algebra of dimension 250 over GF(5)>
##  gap> SimpleLieAlgebra( "H", [1,2], GF(5) );
##  <Lie algebra of dimension 123 over GF(5)>
##  gap> L:= SimpleLieAlgebra( "M", [1,1], GF(5) );
##  <Lie algebra of dimension 125 over GF(5)>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SimpleLieAlgebra" );


#############################################################################
##
#F  DescriptionOfNormalizedUEAElement( <T>, <listofpairs> )
##
##  <ManSection>
##  <Func Name="DescriptionOfNormalizedUEAElement" Arg='T, listofpairs'/>
##
##  <Description>
##  <A>T</A> is the structure constants table of a finite dim. Lie algebra <M>L</M>.
##  <P/>
##  <A>listofpairs</A> is a list of the form
##  <M>[ l_1, c_1, l_2, c_2, \ldots, l_n, c_n ]</M>
##  where the <M>c_i</M> are coefficients and the <M>l_i</M> encode monomials
##  <M>x_{i_1}^{e_1} x_{i_2}^{e_2} \cdots x_{i_m}^{e_m}</M> as lists
##  <M>[ i_1, e_1, i_2, e_2, \ldots, i_m, e_m ]</M>.
##  (All <M>e_k</M> are nonzero.)
##  Here the generator <M>x_k</M> of the universal enveloping algebra corresponds
##  to the <M>k</M>-th basis vector of <M>L</M>.
##  <P/>
##  <C>DescriptionOfNormalizedUEAElement</C> applies successively the rewriting
##  rules of the universal enveloping algebra of <M>L</M> such that the final
##  value describes the same element as <A>listofpairs</A>, each monomial is
##  normalized, and the monomials are ordered lexicographically.
##  This list is the return value.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "DescriptionOfNormalizedUEAElement" );


#############################################################################
##
#A  UniversalEnvelopingAlgebra( <L>[, <B>] )  . . . . . . . for a Lie algebra
##
##  <#GAPDoc Label="UniversalEnvelopingAlgebra">
##  <ManSection>
##  <Attr Name="UniversalEnvelopingAlgebra" Arg='L[, B]'/>
##
##  <Description>
##  Returns the universal enveloping algebra of the Lie algebra <A>L</A>.
##  The elements of this algebra are written on a Poincare-Birkhoff-Witt
##  basis.
##  <P/>
##  If a second argument <A>B</A> is given, it must be a basis of <A>L</A>,
##  and an isomorphic copy of the universal enveloping algebra
##  is returned, generated by the images (in the universal enveloping
##  algebra) of the elements of <A>B</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> UL:= UniversalEnvelopingAlgebra( L );
##  <algebra-with-one of dimension infinity over Rationals>
##  gap> g:= GeneratorsOfAlgebraWithOne( UL );
##  [ [(1)*x.1], [(1)*x.2], [(1)*x.3] ]
##  gap> g[3]^2*g[2]^2*g[1]^2;
##  [(-4)*x.1*x.2*x.3^3+(1)*x.1^2*x.2^2*x.3^2+(2)*x.3^3+(2)*x.3^4]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "UniversalEnvelopingAlgebra",
    IsLieAlgebra );


#############################################################################
##
#F  FreeLieAlgebra( <R>, <rank>[, <name>] )
#F  FreeLieAlgebra( <R>, <name1>, <name2>, ... )
##
##  <#GAPDoc Label="FreeLieAlgebra">
##  <ManSection>
##  <Func Name="FreeLieAlgebra" Arg='R, rank[, name]'
##   Label="for ring, rank (and name)"/>
##  <Func Name="FreeLieAlgebra" Arg='R, name1, name2, ...'
##   Label="for ring and several names"/>
##
##  <Description>
##  Returns a free Lie algebra of rank <A>rank</A> over the ring <A>R</A>.
##  <C>FreeLieAlgebra( <A>R</A>, <A>name1</A>, <A>name2</A>,...)</C> returns
##  a free Lie algebra over <A>R</A> with generators named <A>name1</A>,
##  <A>name2</A>, and so on.
##  The elements of a free Lie algebra are written on the Hall-Lyndon
##  basis.
##  <Example><![CDATA[
##  gap> L:= FreeLieAlgebra( Rationals, "x", "y", "z" );
##  <Lie algebra over Rationals, with 3 generators>
##  gap> g:= GeneratorsOfAlgebra( L );; x:= g[1];; y:=g[2];; z:= g[3];;
##  gap> z*(y*(x*(z*y)));
##  (-1)*((x*(y*z))*(y*z))+(-1)*((x*((y*z)*z))*y)+(-1)*(((x*z)*(y*z))*y)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeLieAlgebra" );


#############################################################################
##
#C  IsFamilyElementOfFreeLieAlgebra( <Fam> )
##
##  <ManSection>
##  <Filt Name="IsFamilyElementOfFreeLieAlgebra" Arg='Fam' Type='Category'/>
##
##  <Description>
##  We need this for the normalization method, which takes a family as first
##  argument.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsFamilyElementOfFreeLieAlgebra",
    IsElementOfMagmaRingModuloRelationsFamily );


#############################################################################
##
#C  IsFptoSCAMorphism( <map> )
##
##  <ManSection>
##  <Filt Name="IsFptoSCAMorphism" Arg='map' Type='Category'/>
##
##  <Description>
##  A morphism from a finitely presented algebra to an isomorphic
##  structure constants algebra. Needs a special method for image
##  because the default method tries to compute a basis of the source.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsFptoSCAMorphism", IsAlgebraGeneralMapping and IsTotal and
                                      IsSingleValued );

##############################################################################
##
#F  FpLieAlgebraByCartanMatrix( <C> )
##
##  <#GAPDoc Label="FpLieAlgebraByCartanMatrix">
##  <ManSection>
##  <Func Name="FpLieAlgebraByCartanMatrix" Arg='C'/>
##
##  <Description>
##  Here <A>C</A> must be a Cartan matrix. The function returns the
##  finitely-presented Lie algebra over the field of rational numbers
##  defined by this Cartan matrix. By Serre's theorem, this Lie algebra is a
##  semisimple Lie algebra, and its root system has Cartan matrix <A>C</A>.
##  <Example><![CDATA[
##  gap> C:= [ [ 2, -1 ], [ -3, 2 ] ];;
##  gap> K:= FpLieAlgebraByCartanMatrix( C );
##  <Lie algebra over Rationals, with 6 generators>
##  gap> h:= NiceAlgebraMonomorphism( K );
##  [ [(1)*x1], [(1)*x2], [(1)*x3], [(1)*x4], [(1)*x5], [(1)*x6] ] ->
##  [ v.1, v.2, v.3, v.4, v.5, v.6 ]
##  gap> SemiSimpleType( Range( h ) );
##  "G2"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FpLieAlgebraByCartanMatrix" );


#############################################################################
##
#F  FpLieAlgebraEnumeration( <FpL> )
#F  FpLieAlgebraEnumeration( <FpL>, <max>, <weights>, <ishom> )
##
##  <ManSection>
##  <Func Name="FpLieAlgebraEnumeration" Arg='FpL'/>
##  <Func Name="FpLieAlgebraEnumeration" Arg='FpL, max, weights, ishom'/>
##
##  <Description>
##  When called with one argument, which is a finitely presented Lie
##  algebra, this function computes a homomorphism to an sc algebra.
##  More arguments can be used to compute nilpotent quotients (see comments
##  to this function in the file alglie.gi).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "FpLieAlgebraEnumeration" );


#############################################################################
##
#F  NilpotentQuotientOfFpLieAlgebra( <FpL>, <max>[, <weights>] )
##
##  <#GAPDoc Label="NilpotentQuotientOfFpLieAlgebra">
##  <ManSection>
##  <Func Name="NilpotentQuotientOfFpLieAlgebra" Arg='FpL, max[, weights]'/>
##
##  <Description>
##
##  Here <A>FpL</A> is a finitely presented Lie algebra.
##  Let <M>K</M> be the quotient of <A>FpL</A> by the <A>max</A>+1-th term
##  of its lower central series.
##  This function calculates a surjective homomorphism from <A>FpL</A>
##  onto <M>K</M>.
##  When called with the third argument <A>weights</A>,
##  the <M>k</M>-th generator of <A>FpL</A> gets assigned the <M>k</M>-th
##  element of the list <A>weights</A>.
##  In that case a quotient is calculated of <A>FpL</A>
##  by the ideal generated by all elements of weight <A>max</A>+1.
##  If the list <A>weights</A> only consists of <M>1</M>'s
##  then the two calls are equivalent.
##  The default value of <A>weights</A> is a list (of length equal to the
##  number of generators of <A>FpL</A>) consisting of <M>1</M>'s.
##  <P/>
##  If the relators of <A>FpL</A> are homogeneous,
##  then the resulting  algebra is naturally graded.
##  <Example><![CDATA[
##  gap> L:= FreeLieAlgebra( Rationals, "x", "y" );;
##  gap> g:= GeneratorsOfAlgebra(L);; x:= g[1]; y:= g[2];
##  (1)*x
##  (1)*y
##  gap> rr:=[ ((y*x)*x)*x-6*(y*x)*y,
##  >          3*((((y*x)*x)*x)*x)*x-20*(((y*x)*x)*x)*y ];
##  [ (-1)*(x*(x*(x*y)))+(6)*((x*y)*y),
##    (-3)*(x*(x*(x*(x*(x*y)))))+(20)*(x*(x*((x*y)*y)))+(
##      -20)*((x*(x*y))*(x*y)) ]
##  gap> K:= L/rr;
##  <Lie algebra over Rationals, with 2 generators>
##  gap> h:=NilpotentQuotientOfFpLieAlgebra(K, 50, [1,2] );
##  [ [(1)*x], [(1)*y] ] -> [ v.1, v.2 ]
##  gap> L:= Range( h );
##  <Lie algebra of dimension 50 over Rationals>
##  gap> Grading( L );
##  rec( hom_components := function( d ) ... end, max_degree := 50,
##    min_degree := 1, source := Integers )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NilpotentQuotientOfFpLieAlgebra" );


##############################################################################
##
#A  JenningsLieAlgebra( <G> )
##
##  <#GAPDoc Label="JenningsLieAlgebra">
##  <ManSection>
##  <Attr Name="JenningsLieAlgebra" Arg='G'/>
##
##  <Description>
##  Let <A>G</A> be a nontrivial <M>p</M>-group,
##  and let <M><A>G</A> = G_1 \supset G_2 \supset \cdots \supset G_m = 1</M>
##  be its Jennings series (see&nbsp;<Ref Attr="JenningsSeries"/>).
##  Then the quotients <M>G_i / G_{{i+1}}</M> are elementary abelian
##  <M>p</M>-groups,
##  i.e., they can be viewed as vector spaces over <C>GF</C><M>(p)</M>.
##  Now the Jennings-Lie algebra <M>L</M> of <A>G</A> is the direct sum
##  of those vector spaces.
##  The Lie bracket on <M>L</M> is induced by the commutator in <A>G</A>.
##  Furthermore, the map <M>g \mapsto g^p</M> in <A>G</A> induces a
##  <M>p</M>-map in <M>L</M> making <M>L</M> into a restricted Lie algebra.
##  In the canonical basis of <M>L</M> this <M>p</M>-map is added as an
##  attribute.
##  A Lie algebra created by <Ref Attr="JenningsLieAlgebra"/> is naturally
##  graded. The attribute <Ref Attr="Grading"/> is set.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "JenningsLieAlgebra", IsGroup );


###########################################################################
##
#A  PCentralLieAlgebra( <G> )
##
##  <#GAPDoc Label="PCentralLieAlgebra">
##  <ManSection>
##  <Attr Name="PCentralLieAlgebra" Arg='G'/>
##
##  <Description>
##  Here <A>G</A> is a nontrivial <M>p</M>-group.
##  <C>PCentralLieAlgebra( <A>G</A> )</C> does the same as
##  <Ref Attr="JenningsLieAlgebra"/> except that the
##  <M>p</M>-central series is used instead of the Jennings series
##  (see&nbsp;<Ref Oper="PCentralSeries"/>). This function also returns
##  a graded Lie algebra. However, it is not necessarily restricted.
##  <Example><![CDATA[
##  gap> G:= SmallGroup( 3^6, 123 );
##  <pc group of size 729 with 6 generators>
##  gap> L:= JenningsLieAlgebra( G );
##  <Lie algebra of dimension 6 over GF(3)>
##  gap> HasPthPowerImages( Basis( L ) );
##  true
##  gap> PthPowerImages( Basis( L ) );
##  [ v.6, 0*v.1, 0*v.1, 0*v.1, 0*v.1, 0*v.1 ]
##  gap> g:= Grading( L );
##  rec( hom_components := function( d ) ... end, max_degree := 3,
##    min_degree := 1, source := Integers )
##  gap> List( [1,2,3], g.hom_components );
##  [ <vector space over GF(3), with 3 generators>,
##    <vector space over GF(3), with 2 generators>,
##    <vector space over GF(3), with 1 generator> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PCentralLieAlgebra", IsGroup );

#############################################################################
##
#A  NaturalHomomorphismOfLieAlgebraFromNilpotentGroup( <L> )
##
##  <#GAPDoc Label="NaturalHomomorphismOfLieAlgebraFromNilpotentGroup">
##  <ManSection>
##  <Attr Name="NaturalHomomorphismOfLieAlgebraFromNilpotentGroup" Arg='L'/>
##
##  <Description>
##  This is an attribute of Lie algebras created by
##  <Ref Attr="JenningsLieAlgebra"/> or <Ref Attr="PCentralLieAlgebra"/>.
##  Then <A>L</A> is the direct sum of quotients of successive terms of the
##  Jennings, or <M>p</M>-central series of a <M>p</M>-group G. Let <C>Gi</C>
##  be the <M>i</M>-th term in this series, and let
##  <C>f = NaturalHomomorphismOfLieAlgebraFromNilpotentGroup( <A>L</A> )</C>,
##  then for <C>g</C> in <C>Gi</C>, <C>f( <A>g</A>, <A>i</A> )</C> returns the
##  element of <A>L</A> (lying in the <M>i</M>-th homogeneous component)
##  corresponding to <C>g</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NaturalHomomorphismOfLieAlgebraFromNilpotentGroup",
    IsAlgebra and IsLieAlgebra );
