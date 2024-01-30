#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for `FLMLOR's and algebras.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{algebra}">
##  An algebra is a vector space equipped with a bilinear map
##  (multiplication).
##  This chapter describes the functions in &GAP; that deal with
##  general algebras and associative algebras.
##  <P/>
##  Algebras in &GAP; are vector spaces in a natural way.
##  So all the functionality for vector spaces
##  (see Chapter&nbsp;<Ref Chap="Vector Spaces"/>)
##  is also applicable to algebras.
##  <#/GAPDoc>
##


#############################################################################
##
#V  InfoAlgebra
##
##  <#GAPDoc Label="InfoAlgebra">
##  <ManSection>
##  <InfoClass Name="InfoAlgebra"/>
##
##  <Description>
##  is the info class for the functions dealing with algebras
##  (see&nbsp;<Ref Sect="Info Functions"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass( "InfoAlgebra" );


#############################################################################
##
#C  IsFLMLOR( <obj> )
##
##  <#GAPDoc Label="IsFLMLOR">
##  <ManSection>
##  <Filt Name="IsFLMLOR" Arg='obj' Type='Category'/>
##
##  <Description>
##  A FLMLOR (<Q>free left module left operator ring</Q>) in &GAP; is a ring
##  that is also a free left module.
##  <P/>
##  Note that this means that being a FLMLOR is not a property a
##  ring can get,
##  since a ring is usually not represented as an external left set.
##  <P/>
##  Examples are magma rings (e.g. over the integers) or algebras.
##  <Example><![CDATA[
##  gap> A:= FullMatrixAlgebra( Rationals, 2 );;
##  gap> IsFLMLOR ( A );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsFLMLOR", IsFreeLeftModule and IsLeftOperatorRing );


#############################################################################
##
#C  IsFLMLORWithOne( <obj> )
##
##  <#GAPDoc Label="IsFLMLORWithOne">
##  <ManSection>
##  <Filt Name="IsFLMLORWithOne" Arg='obj' Type='Category'/>
##
##  <Description>
##  A FLMLOR-with-one in &GAP; is a ring-with-one that is also a free left
##  module.
##  <P/>
##  Note that this means that being a FLMLOR-with-one is not a property a
##  ring-with-one can get,
##  since a ring-with-one is usually not represented as an external left set.
##  <P/>
##  Examples are magma rings-with-one or algebras-with-one (but also over the
##  integers).
##  <Example><![CDATA[
##  gap> A:= FullMatrixAlgebra( Rationals, 2 );;
##  gap> IsFLMLORWithOne ( A );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsFLMLORWithOne",
    IsFreeLeftModule and IsLeftOperatorRingWithOne );


#############################################################################
##
#C  IsAlgebra( <obj> )
##
##  <#GAPDoc Label="IsAlgebra">
##  <ManSection>
##  <Filt Name="IsAlgebra" Arg='obj' Type='Category'/>
##
##  <Description>
##  An algebra in &GAP; is a ring that is also a left vector space.
##  Note that this means that being an algebra is not a property a ring can
##  get, since a ring is usually not represented as an external left set.
##  <Example><![CDATA[
##  gap> A:= MatAlgebra( Rationals, 3 );;
##  gap> IsAlgebra( A );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsAlgebra", IsLeftVectorSpace and IsLeftOperatorRing );


#############################################################################
##
#C  IsAlgebraWithOne( <obj> )
##
##  <#GAPDoc Label="IsAlgebraWithOne">
##  <ManSection>
##  <Filt Name="IsAlgebraWithOne" Arg='obj' Type='Category'/>
##
##  <Description>
##  An algebra-with-one in &GAP; is a ring-with-one that is also
##  a left vector space.
##  Note that this means that being an algebra-with-one is not a property a
##  ring-with-one can get,
##  since a ring-with-one is usually not represented as an external left set.
##  <Example><![CDATA[
##  gap> A:= MatAlgebra( Rationals, 3 );;
##  gap> IsAlgebraWithOne( A );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsAlgebraWithOne",
    IsLeftVectorSpace and IsLeftOperatorRingWithOne );


#############################################################################
##
#P  IsLieAlgebra( <A> )
##
##  <#GAPDoc Label="IsLieAlgebra">
##  <ManSection>
##  <Filt Name="IsLieAlgebra" Arg='A'/>
##
##  <Description>
##  An algebra <A>A</A> is called Lie algebra if <M>a * a = 0</M>
##  for all <M>a</M> in <A>A</A>
##  and <M>( a * ( b * c ) ) + ( b * ( c * a ) ) + ( c * ( a * b ) ) = 0</M>
##  for all <M>a, b, c \in </M><A>A</A> (Jacobi identity).
##  <Example><![CDATA[
##  gap> A:= FullMatrixLieAlgebra( Rationals, 3 );;
##  gap> IsLieAlgebra( A );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "IsLieAlgebra",
    IsAlgebra and IsZeroSquaredRing and IsJacobianRing );

#############################################################################
##
#P  IsSimpleAlgebra( <A> )
##
##  <#GAPDoc Label="IsSimpleAlgebra">
##  <ManSection>
##  <Prop Name="IsSimpleAlgebra" Arg='A'/>
##
##  <Description>
##  is <K>true</K> if the algebra <A>A</A> is simple,
##  and <K>false</K> otherwise.
##  This  function is only implemented for the cases where <A>A</A> is
##  an associative or a Lie algebra.
##  And for Lie algebras it is only implemented for the
##  case where the ground field is of characteristic zero.
##  <Example><![CDATA[
##  gap> A:= FullMatrixLieAlgebra( Rationals, 3 );;
##  gap> IsSimpleAlgebra( A );
##  false
##  gap> A:= MatAlgebra( Rationals, 3 );;
##  gap> IsSimpleAlgebra( A );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSimpleAlgebra", IsAlgebra );


#############################################################################
##
#A  GeneratorsOfLeftOperatorRing
##
##  <ManSection>
##  <Attr Name="GeneratorsOfLeftOperatorRing" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "GeneratorsOfLeftOperatorRing", IsLeftOperatorRing );


#############################################################################
##
#A  GeneratorsOfLeftOperatorRingWithOne
##
##  <ManSection>
##  <Attr Name="GeneratorsOfLeftOperatorRingWithOne" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "GeneratorsOfLeftOperatorRingWithOne",
    IsLeftOperatorRingWithOne );


#############################################################################
##
#A  GeneratorsOfAlgebra( <A> )
##
##  <#GAPDoc Label="GeneratorsOfAlgebra">
##  <ManSection>
##  <Attr Name="GeneratorsOfAlgebra" Arg='A'/>
##
##  <Description>
##  returns a list of elements that generate <A>A</A> as an algebra.
##  <P/>
##  For a free algebra, each generator can also be accessed using
##  the <C>.</C> operator (see <Ref Attr="GeneratorsOfDomain"/>).
##  <Example><![CDATA[
##  gap> m:= [ [ 0, 1, 2 ], [ 0, 0, 3 ], [ 0, 0, 0 ] ];;
##  gap> A:= AlgebraWithOne( Rationals, [ m ] );
##  <algebra-with-one over Rationals, with 1 generator>
##  gap> GeneratorsOfAlgebra( A );
##  [ [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ],
##    [ [ 0, 1, 2 ], [ 0, 0, 3 ], [ 0, 0, 0 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "GeneratorsOfAlgebra", GeneratorsOfLeftOperatorRing );
DeclareSynonymAttr( "GeneratorsOfFLMLOR", GeneratorsOfLeftOperatorRing );


#############################################################################
##
#A  GeneratorsOfAlgebraWithOne( <A> )
##
##  <#GAPDoc Label="GeneratorsOfAlgebraWithOne">
##  <ManSection>
##  <Attr Name="GeneratorsOfAlgebraWithOne" Arg='A'/>
##
##  <Description>
##  returns a list of elements of <A>A</A>
##  that generate <A>A</A> as an algebra with one.
##  <P/>
##  For a free algebra with one, each generator can also be accessed using
##  the <C>.</C> operator (see <Ref Attr="GeneratorsOfDomain"/>).
##  <Example><![CDATA[
##  gap> m:= [ [ 0, 1, 2 ], [ 0, 0, 3 ], [ 0, 0, 0 ] ];;
##  gap> A:= AlgebraWithOne( Rationals, [ m ] );
##  <algebra-with-one over Rationals, with 1 generator>
##  gap> GeneratorsOfAlgebraWithOne( A );
##  [ [ [ 0, 1, 2 ], [ 0, 0, 3 ], [ 0, 0, 0 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "GeneratorsOfAlgebraWithOne",
    GeneratorsOfLeftOperatorRingWithOne );

DeclareSynonymAttr( "GeneratorsOfFLMLORWithOne",
    GeneratorsOfLeftOperatorRingWithOne );


#############################################################################
##
#A  PowerSubalgebraSeries( <A> )
##
##  <#GAPDoc Label="PowerSubalgebraSeries">
##  <ManSection>
##  <Attr Name="PowerSubalgebraSeries" Arg='A'/>
##
##  <Description>
##  returns a list of subalgebras of <A>A</A>,
##  the first term of which is <A>A</A>;
##  and every next term is the product space of the previous term with itself.
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );
##  <algebra-with-one of dimension 4 over Rationals>
##  gap> PowerSubalgebraSeries( A );
##  [ <algebra-with-one of dimension 4 over Rationals> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "PowerSubalgebraSeries", IsAlgebra );


#############################################################################
##
#A  AdjointBasis( <B> )
##
##  <#GAPDoc Label="AdjointBasis">
##  <ManSection>
##  <Attr Name="AdjointBasis" Arg='B'/>
##
##  <Description>
##  The <E>adjoint map</E> <M>ad(x)</M> of an element <M>x</M> in an
##  <M>F</M>-algebra <M>A</M> is the left multiplication by <M>x</M>.
##  This map is <M>F</M>-linear and thus, w.r.t. the given basis
##  <A>B</A><M> = (x_1, x_2, \ldots, x_n)</M> of <M>A</M>,
##  <M>ad(x)</M> can be represented by a matrix over <M>F</M>.
##  Let <M>V</M> denote the <M>F</M>-vector space of the matrices
##  corresponding to <M>ad(x)</M>, for <M>x \in A</M>.
##  Then <Ref Attr="AdjointBasis"/> returns the basis of <M>V</M> that
##  consists of the matrices for <M>ad(x_1), \ldots, ad(x_n)</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> AdjointBasis( Basis( A ) );
##  Basis( <vector space over Rationals, with 4 generators>,
##  [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ],
##    [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ]
##      ,
##    [ [ 0, 0, -1, 0 ], [ 0, 0, 0, 1 ], [ 1, 0, 0, 0 ], [ 0, -1, 0, 0 ] ]
##      ,
##    [ [ 0, 0, 0, -1 ], [ 0, 0, -1, 0 ], [ 0, 1, 0, 0 ], [ 1, 0, 0, 0 ]
##       ] ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AdjointBasis", IsBasis );


#############################################################################
##
#A  IndicesOfAdjointBasis( <B> )
##
##  <#GAPDoc Label="IndicesOfAdjointBasis">
##  <ManSection>
##  <Attr Name="IndicesOfAdjointBasis" Arg='B'/>
##
##  <Description>
##  Let <A>A</A> be an algebra and let <A>B</A>
##  be the basis that is output by <C>AdjointBasis( Basis( <A>A</A> ) )</C>.
##  This function returns a list of indices.
##  If <M>i</M> is an index belonging to this list,
##  then <M>ad x_i</M> is a basis vector of the matrix space
##  spanned by <M>ad A</M>,
##  where <M>x_i</M> is the <M>i</M>-th basis vector of the basis <A>B</A>.
##  <Example><![CDATA[
##  gap> L:= FullMatrixLieAlgebra( Rationals, 3 );;
##  gap> B:= AdjointBasis( Basis( L ) );;
##  gap> IndicesOfAdjointBasis( B );
##  [ 1, 2, 3, 4, 5, 6, 7, 8 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "IndicesOfAdjointBasis", IsBasis );


#############################################################################
##
#A  RadicalOfAlgebra( <A> )
##
##  <#GAPDoc Label="RadicalOfAlgebra">
##  <ManSection>
##  <Attr Name="RadicalOfAlgebra" Arg='A'/>
##
##  <Description>
##  is the maximal nilpotent ideal of <A>A</A>,
##  where <A>A</A> is an associative algebra.
##  <Example><![CDATA[
##  gap> m:= [ [ 0, 1, 2 ], [ 0, 0, 3 ], [ 0, 0, 0 ] ];;
##  gap> A:= AlgebraWithOneByGenerators( Rationals, [ m ] );
##  <algebra-with-one over Rationals, with 1 generator>
##  gap> RadicalOfAlgebra( A );
##  <algebra of dimension 2 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RadicalOfAlgebra", IsAlgebra );


#############################################################################
##
#A  DirectSumDecomposition( <L> )
##
##  <#GAPDoc Label="DirectSumDecomposition">
##  <ManSection>
##  <Attr Name="DirectSumDecomposition" Arg='L' Label="for Lie algebras"/>
##
##  <Description>
##  This function calculates a list of ideals of the algebra <A>L</A> such
##  that <A>L</A> is equal to their direct sum.
##  Currently this is only implemented for semisimple associative algebras,
##  and for Lie algebras (semisimple or not).
##  <Example><![CDATA[
##  gap> G:= SymmetricGroup( 4 );;
##  gap> A:= GroupRing( Rationals, G );
##  <algebra-with-one over Rationals, with 2 generators>
##  gap> dd:= DirectSumDecomposition( A );
##  [ <two-sided ideal in
##        <algebra-with-one of dimension 24 over Rationals>,
##        (1 generator)>,
##    <two-sided ideal in
##        <algebra-with-one of dimension 24 over Rationals>,
##        (1 generator)>,
##    <two-sided ideal in
##        <algebra-with-one of dimension 24 over Rationals>,
##        (1 generator)>,
##    <two-sided ideal in
##        <algebra-with-one of dimension 24 over Rationals>,
##        (1 generator)>,
##    <two-sided ideal in
##        <algebra-with-one of dimension 24 over Rationals>,
##        (1 generator)> ]
##  gap> List( dd, Dimension );
##  [ 1, 1, 4, 9, 9 ]
##  ]]></Example>
##  <Example><![CDATA[
##  gap> L:= FullMatrixLieAlgebra( Rationals, 5 );;
##  gap> DirectSumDecomposition( L );
##  [ <two-sided ideal in
##        <two-sided ideal in <Lie algebra of dimension 25 over Rationals>
##              , (dimension 1)>, (dimension 1)>,
##    <two-sided ideal in
##        <two-sided ideal in <Lie algebra of dimension 25 over Rationals>
##              , (dimension 24)>, (dimension 24)> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DirectSumDecomposition", IsAlgebra );


#############################################################################
##
#A  TrivialSubalgebra( <A> )
##
##  <#GAPDoc Label="TrivialSubalgebra">
##  <ManSection>
##  <Attr Name="TrivialSubalgebra" Arg='A'/>
##
##  <Description>
##  The zero dimensional subalgebra of the algebra <A>A</A>.
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> B:= TrivialSubalgebra( A );
##  <algebra of dimension 0 over Rationals>
##  gap> Dimension( B );
##  0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "TrivialSubFLMLOR", TrivialSubadditiveMagmaWithZero );
DeclareSynonymAttr( "TrivialSubalgebra", TrivialSubFLMLOR );


#############################################################################
##
#A  NullAlgebra( <R> )  . . . . . . . . . . zero dimensional algebra over <R>
##
##  <#GAPDoc Label="NullAlgebra">
##  <ManSection>
##  <Attr Name="NullAlgebra" Arg='R'/>
##
##  <Description>
##  The zero-dimensional algebra over <A>R</A>.
##  <!-- or store this in the family ?-->
##  <Example><![CDATA[
##  gap> A:= NullAlgebra( Rationals );
##  <algebra of dimension 0 over Rationals>
##  gap> Dimension( A );
##  0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NullAlgebra", IsRing );


#############################################################################
##
#O  ProductSpace( <U>, <V> )
##
##  <#GAPDoc Label="ProductSpace">
##  <ManSection>
##  <Oper Name="ProductSpace" Arg='U, V'/>
##
##  <Description>
##  is the vector space <M>\langle u * v ; u \in U, v \in V \rangle</M>,
##  where <M>U</M> and <M>V</M> are subspaces of the same algebra.
##  <P/>
##  If <M><A>U</A> = <A>V</A></M> is known to be an algebra
##  then the product space is also an algebra,
##  moreover it is an ideal in <A>U</A>.
##  If <A>U</A> and <A>V</A> are known to be ideals in an algebra <M>A</M>
##  then the product space is known to be an algebra and an ideal
##  in <M>A</M>.
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> b:= BasisVectors( Basis( A ) );;
##  gap> B:= Subalgebra( A, [ b[4] ] );
##  <algebra over Rationals, with 1 generator>
##  gap> ProductSpace( A, B );
##  <vector space of dimension 4 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ProductSpace", [ IsFreeLeftModule, IsFreeLeftModule ] );


#############################################################################
##
#O  DirectSumOfAlgebras( <A1>, <A2> )
#O  DirectSumOfAlgebras( <list> )
##
##  <#GAPDoc Label="DirectSumOfAlgebras">
##  <ManSection>
##  <Oper Name="DirectSumOfAlgebras" Arg='A1, A2'
##   Label="for two algebras"/>
##  <Oper Name="DirectSumOfAlgebras" Arg='list'
##   Label="for a list of algebras"/>
##
##  <Description>
##  is the direct sum of the two algebras <A>A1</A> and <A>A2</A>
##  respectively of the algebras in the list <A>list</A>.
##  <P/>
##  If all involved algebras are associative algebras then the result is also
##  known to be associative.
##  If all involved algebras are Lie algebras then the result is also known
##  to be a Lie algebra.
##  <P/>
##  All involved algebras must have the same left acting domain.
##  <P/>
##  The default case is that the result is a structure constants algebra.
##  If all involved algebras are matrix algebras, and either both are Lie
##  algebras or both are associative then the result is again a
##  matrix algebra of the appropriate type.
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> DirectSumOfAlgebras( [A, A, A] );
##  <algebra of dimension 12 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DirectSumOfAlgebras", [ IsDenseList ] );


#############################################################################
##
#F  FullMatrixAlgebraCentralizer( <F>, <lst> )
##
##  <#GAPDoc Label="FullMatrixAlgebraCentralizer">
##  <ManSection>
##  <Func Name="FullMatrixAlgebraCentralizer" Arg='F, lst'/>
##
##  <Description>
##  Let <A>lst</A>  be a nonempty list of square matrices of the same
##  dimension <M>n</M> with entries in the field <A>F</A>.
##  <Ref Func="FullMatrixAlgebraCentralizer"/> returns
##  the (pointwise) centralizer of all matrices in <A>lst</A>, inside
##  the full matrix algebra of <M>n \times n</M> matrices over <A>F</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> b:= Basis( A );;
##  gap> mats:= List( BasisVectors( b ), x -> AdjointMatrix( b, x ) );;
##  gap> FullMatrixAlgebraCentralizer( Rationals, mats );
##  <algebra-with-one of dimension 4 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FullMatrixAlgebraCentralizer" );


#############################################################################
##
#O  AsAlgebra( <F>, <A> ) . . . . . . . . . . .  view <A> as algebra over <F>
##
##  <#GAPDoc Label="AsAlgebra">
##  <ManSection>
##  <Oper Name="AsAlgebra" Arg='F, A'/>
##
##  <Description>
##  Returns the algebra over <A>F</A> generated by <A>A</A>.
##  <Example><![CDATA[
##  gap> V:= VectorSpace( Rationals, [ IdentityMat( 2 ) ] );;
##  gap> AsAlgebra( Rationals, V );
##  <algebra of dimension 1 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AsFLMLOR", [ IsRing, IsCollection ] );

DeclareSynonym( "AsAlgebra", AsFLMLOR );


#############################################################################
##
#O  AsAlgebraWithOne( <F>, <A> )  . . . view <A> as algebra-with-one over <F>
##
##  <#GAPDoc Label="AsAlgebraWithOne">
##  <ManSection>
##  <Oper Name="AsAlgebraWithOne" Arg='F, A'/>
##
##  <Description>
##  If the algebra <A>A</A> has an identity, then it can be viewed as an
##  algebra with one over <A>F</A>.
##  This function returns this algebra with one.
##  <Example><![CDATA[
##  gap> V:= VectorSpace( Rationals, [ IdentityMat( 2 ) ] );;
##  gap> A:= AsAlgebra( Rationals, V );;
##  gap> AsAlgebraWithOne( Rationals, A );
##  <algebra-with-one over Rationals, with 1 generator>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AsFLMLORWithOne", [ IsRing, IsCollection ] );

DeclareSynonym( "AsAlgebraWithOne", AsFLMLORWithOne );


#############################################################################
##
#O  AsSubalgebra( <A>, <B> )  . . . . . . . . . view <B> as subalgebra of <A>
##
##  <#GAPDoc Label="AsSubalgebra">
##  <ManSection>
##  <Oper Name="AsSubalgebra" Arg='A, B'/>
##
##  <Description>
##  If all elements of the algebra <A>B</A> happen to be contained in the
##  algebra <A>A</A>,
##  then <A>B</A> can be viewed as a subalgebra of <A>A</A>.
##  This  function returns this subalgebra.
##  <Example><![CDATA[
##  gap> A:= FullMatrixAlgebra( Rationals, 2 );;
##  gap> V:= VectorSpace( Rationals, [ IdentityMat( 2 ) ] );;
##  gap> B:= AsAlgebra( Rationals, V );;
##  gap> BA:= AsSubalgebra( A, B );
##  <algebra of dimension 1 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AsSubFLMLOR", [ IsFLMLOR, IsFLMLOR ] );

DeclareSynonym( "AsSubalgebra", AsSubFLMLOR );


#############################################################################
##
#O  AsSubalgebraWithOne( <A>, <B> ) . . view <B> as subalgebra-wth-one of <A>
##
##  <#GAPDoc Label="AsSubalgebraWithOne">
##  <ManSection>
##  <Oper Name="AsSubalgebraWithOne" Arg='A, B'/>
##
##  <Description>
##  If <A>B</A> is an algebra with one, all elements of which happen to be
##  contained in the algebra with one <A>A</A>, then <A>B</A> can be viewed
##  as a subalgebra with one of <A>A</A>.
##  This function returns this subalgebra with one.
##  <Example><![CDATA[
##  gap> A:= FullMatrixAlgebra( Rationals, 2 );;
##  gap> V:= VectorSpace( Rationals, [ IdentityMat( 2 ) ] );;
##  gap> B:= AsAlgebra( Rationals, V );;
##  gap> C:= AsAlgebraWithOne( Rationals, B );;
##  gap> AC:= AsSubalgebraWithOne( A, C );
##  <algebra-with-one over Rationals, with 1 generator>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AsSubFLMLORWithOne", [ IsFLMLOR, IsFLMLOR ] );

DeclareSynonym( "AsSubalgebraWithOne", AsSubFLMLORWithOne );


#############################################################################
##
##  <#GAPDoc Label="[2]{algebra}">
##  For an introduction into structure constants and how they are handled
##  by &GAP;, we refer to Section <Ref Sect="Algebras" BookName="tut"/>
##  of the user's tutorial.
##  <#/GAPDoc>
##


#############################################################################
##
#F  EmptySCTable( <dim>, <zero>[, <flag>] )
##
##  <#GAPDoc Label="EmptySCTable">
##  <ManSection>
##  <Func Name="EmptySCTable" Arg='dim, zero[, flag]'/>
##
##  <Description>
##  <Ref Func="EmptySCTable"/> returns a structure constants table for an
##  algebra of dimension <A>dim</A>, describing trivial multiplication.
##  <A>zero</A> must be the zero of the coefficients domain.
##  If the multiplication is known to be (anti)commutative then
##  this can be indicated by the optional third argument <A>flag</A>,
##  which must be one of the strings <C>"symmetric"</C>,
##  <C>"antisymmetric"</C>.
##  <P/>
##  For filling up the structure constants table,
##  see <Ref Func="SetEntrySCTable"/>.
##  <Example><![CDATA[
##  gap> EmptySCTable( 2, Zero( GF(5) ), "antisymmetric" );
##  [ [ [ [  ], [  ] ], [ [  ], [  ] ] ],
##    [ [ [  ], [  ] ], [ [  ], [  ] ] ], -1, 0*Z(5) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "EmptySCTable" );


#############################################################################
##
#F  SetEntrySCTable( <T>, <i>, <j>, <list> )
##
##  <#GAPDoc Label="SetEntrySCTable">
##  <ManSection>
##  <Func Name="SetEntrySCTable" Arg='T, i, j, list'/>
##
##  <Description>
##  sets the entry of the structure constants table <A>T</A> that describes
##  the product of the <A>i</A>-th basis element with the <A>j</A>-th
##  basis element to the value given by the list <A>list</A>.
##  <P/>
##  If <A>T</A> is known to be antisymmetric or symmetric then also the value
##  <C><A>T</A>[<A>j</A>][<A>i</A>]</C> is set.
##  <P/>
##  <A>list</A> must be of the form
##  <M>[ c_{ij}^{{k_1}}, k_1, c_{ij}^{{k_2}}, k_2, \ldots ]</M>.
##  <P/>
##  The entries at the odd positions of <A>list</A> must be compatible with
##  the zero element stored in <A>T</A>.
##  For convenience, these entries may also be rational numbers that are
##  automatically replaced by the corresponding elements in the appropriate
##  prime field in finite characteristic if necessary.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
##  gap> T;
##  [ [ [ [ 1, 2 ], [ 1/2, 2/3 ] ], [ [  ], [  ] ] ],
##    [ [ [  ], [  ] ], [ [  ], [  ] ] ], 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SetEntrySCTable" );


#############################################################################
##
#F  ReducedSCTable( <T>, <one> )
##
##  <ManSection>
##  <Func Name="ReducedSCTable" Arg='T, one'/>
##
##  <Description>
##  returns an immutable structure constants table obtained by reducing the
##  (rational) coefficients of the structure constants table <A>T</A> by
##  multiplication with <A>one</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ReducedSCTable" );


#############################################################################
##
#F  GapInputSCTable( <T>, <varname> )
##
##  <#GAPDoc Label="GapInputSCTable">
##  <ManSection>
##  <Func Name="GapInputSCTable" Arg='T, varname'/>
##
##  <Description>
##  is a string that describes the structure constants table <A>T</A>
##  in terms of <Ref Func="EmptySCTable"/> and <Ref Func="SetEntrySCTable"/>.
##  The assignments are made to the variable <A>varname</A>.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 2, [ 1, 2 ] );
##  gap> SetEntrySCTable( T, 2, 1, [ 1, 2 ] );
##  gap> GapInputSCTable( T, "T" );
##  "T:= EmptySCTable( 2, 0 );\nSetEntrySCTable( T, 1, 2, [1,2] );\nSetEnt\
##  rySCTable( T, 2, 1, [1,2] );\n"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "GapInputSCTable" );


#############################################################################
##
#F  IdentityFromSCTable( <T> )
##
##  <#GAPDoc Label="IdentityFromSCTable">
##  <ManSection>
##  <Func Name="IdentityFromSCTable" Arg='T'/>
##
##  <Description>
##  Let <A>T</A> be a structure constants table of an algebra <M>A</M>
##  of dimension <M>n</M>.
##  <C>IdentityFromSCTable( <A>T</A> )</C> is either <K>fail</K> or
##  the vector of length <M>n</M> that contains the coefficients of the
##  multiplicative identity of <M>A</M>
##  with respect to the basis that belongs to <A>T</A>.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [ 1, 1 ] );;
##  gap> SetEntrySCTable( T, 1, 2, [ 1, 2 ] );;
##  gap> SetEntrySCTable( T, 2, 1, [ 1, 2 ] );;
##  gap> IdentityFromSCTable( T );
##  [ 1, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IdentityFromSCTable" );


#############################################################################
##
#F  QuotientFromSCTable( <T>, <num>, <den> )
##
##  <#GAPDoc Label="QuotientFromSCTable">
##  <ManSection>
##  <Func Name="QuotientFromSCTable" Arg='T, num, den'/>
##
##  <Description>
##  Let <A>T</A> be a structure constants table of an algebra <M>A</M>
##  of dimension <M>n</M>.
##  <C>QuotientFromSCTable( <A>T</A> )</C> is either <K>fail</K> or
##  the vector of length <M>n</M> that contains the coefficients of the
##  quotient of <A>num</A> and <A>den</A> with respect to the basis
##  that belongs to <A>T</A>.
##  <P/>
##  We solve the equation system <A>num</A><M> = x *</M> <A>den</A>.
##  If no solution exists, <K>fail</K> is returned.
##  <P/>
##  In terms of the basis <M>B</M> with vectors <M>b_1, \ldots, b_n</M>
##  this means
##  for <M><A>num</A> = \sum_{{i = 1}}^n a_i b_i</M>,
##      <M><A>den</A> = \sum_{{i = 1}}^n c_i b_i</M>,
##      <M>x = \sum_{{i = 1}}^n x_i b_i</M> that
##  <M>a_k = \sum_{{i,j}} c_i x_j c_{ijk}</M> for all <M>k</M>.
##  Here <M>c_{ijk}</M> denotes the structure constants
##  with respect to <M>B</M>.
##  This means that (as a vector) <M>a = x M</M> with
##  <M>M_{jk} = \sum_{{i = 1}}^n c_{ijk} c_i</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [ 1, 1 ] );;
##  gap> SetEntrySCTable( T, 2, 1, [ 1, 2 ] );;
##  gap> SetEntrySCTable( T, 1, 2, [ 1, 2 ] );;
##  gap> QuotientFromSCTable( T, [0,1], [1,0] );
##  [ 0, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "QuotientFromSCTable" );


#############################################################################
##
#F  TestJacobi( <T> )
##
##  <#GAPDoc Label="TestJacobi">
##  <ManSection>
##  <Func Name="TestJacobi" Arg='T'/>
##
##  <Description>
##  tests whether the structure constants table <A>T</A> satisfies the Jacobi
##  identity
##  <M>v_i * (v_j * v_k) + v_j * (v_k * v_i) + v_k * (v_i * v_j) = 0</M>
##  for all basis vectors <M>v_i</M> of the underlying algebra,
##  where <M>i \leq j \leq k</M>.
##  (Thus antisymmetry is assumed.)
##  <P/>
##  The function returns <K>true</K> if the Jacobi identity is satisfied,
##  and a failing triple <M>[ i, j, k ]</M> otherwise.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0, "antisymmetric" );;
##  gap> SetEntrySCTable( T, 1, 2, [ 1, 2 ] );;
##  gap> TestJacobi( T );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "TestJacobi" );


#############################################################################
##
#O  ClosureLeftOperatorRing( <A>, <a> )
#O  ClosureLeftOperatorRing( <A>, <S> )
##
##  <ManSection>
##  <Oper Name="ClosureLeftOperatorRing" Arg='A, a'/>
##  <Oper Name="ClosureLeftOperatorRing" Arg='A, S'/>
##
##  <Description>
##  For a left operator ring <A>A</A> and either an element <A>a</A> of its
##  elements family or a left operator ring <A>S</A>
##  (over the same left acting domain),
##  <Ref Oper="ClosureLeftOperatorRing"/> returns the left operator ring
##  generated by both arguments.
##  </Description>
##  </ManSection>
##
DeclareOperation( "ClosureLeftOperatorRing",
    [ IsLeftOperatorRing, IsObject ] );

DeclareSynonym( "ClosureAlgebra", ClosureLeftOperatorRing );


#############################################################################
##
#F  MutableBasisOfClosureUnderAction( <F>, <Agens>, <from>, <init>, <opr>,
#F                                    <zero>, <maxdim> )
##
##  <#GAPDoc Label="MutableBasisOfClosureUnderAction">
##  <ManSection>
##  <Func Name="MutableBasisOfClosureUnderAction"
##   Arg='F, Agens, from, init, opr, zero, maxdim'/>
##
##  <Description>
##  Let <A>F</A> be a ring, <A>Agens</A> a list of generators for an
##  <A>F</A>-algebra <M>A</M>, and <A>from</A> one of <C>"left"</C>,
##  <C>"right"</C>, <C>"both"</C>; this means that elements
##  of <M>A</M> act via multiplication from the respective side(s).
##  <A>init</A> must be a list of initial generating vectors,
##  and <A>opr</A> the operation (a function of two arguments).
##  <P/>
##  <Ref Func="MutableBasisOfClosureUnderAction"/> returns a mutable basis of
##  the <A>F</A>-free left module generated by the vectors in <A>init</A>
##  and their images under the action of <A>Agens</A>
##  from the respective side(s).
##  <P/>
##  <A>zero</A> is the zero element of the desired module.
##  <A>maxdim</A> is an upper bound for the dimension of the closure;
##  if no such upper bound is known then the value of <A>maxdim</A>
##  must be <Ref Var="infinity"/>.
##  <P/>
##  <Ref Func="MutableBasisOfClosureUnderAction"/> can be used to compute
##  a basis of an <E>associative</E> algebra generated by the elements in
##  <A>Agens</A>.
##  In this  case <A>from</A> may be <C>"left"</C> or <C>"right"</C>,
##  <A>opr</A> is the multiplication <C>*</C>,
##  and <A>init</A> is a list containing either the identity of the algebra
##  or a list of algebra generators.
##  (Note that if the algebra has an identity then it is in general not
##  sufficient to take algebra-with-one generators as <A>init</A>,
##  whereas of course <A>Agens</A> need not contain the identity.)
##  <P/>
##  (Note that bases of <E>not</E> necessarily associative algebras can be
##  computed using <Ref Func="MutableBasisOfNonassociativeAlgebra"/>.)
##  <P/>
##  Other applications of <Ref Func="MutableBasisOfClosureUnderAction"/> are
##  the computations of bases for (left/ right/ two-sided) ideals <M>I</M> in
##  an <E>associative</E> algebra <M>A</M> from ideal generators of <M>I</M>;
##  in these cases <A>Agens</A> is a list of algebra generators of <M>A</M>,
##  <A>from</A> denotes the appropriate side(s),
##  <A>init</A> is a list of ideal generators of <M>I</M>,
##  and <A>opr</A> is again <C>*</C>.
##  <P/>
##  (Note that bases of ideals in <E>not</E> necessarily associative algebras
##  can be computed using
##  <Ref Func="MutableBasisOfIdealInNonassociativeAlgebra"/>.)
##  <P/>
##  Finally, bases of right <M>A</M>-modules also can be computed using
##  <Ref Func="MutableBasisOfClosureUnderAction"/>.
##  The only difference to the ideal case is that <A>init</A> is now a list
##  of right module generators,
##  and <A>opr</A> is the operation of the module.
##  <P/>
##  <!--  (Remark:
##        It would be possible to use vector space generators of the algebra
##        <M>A</M> if they are known; but in the associative case,
##        it is cheaper to multiply only with generators
##        until the vector space becomes stable.) -->
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> g:= GeneratorsOfAlgebra( A );;
##  gap> B:= MutableBasisOfClosureUnderAction( Rationals,
##  >                                g, "left", [ g[1] ], \*, Zero(A), 4 );
##  <mutable basis over Rationals, 4 vectors>
##  gap> BasisVectors( B );
##  [ e, i, j, k ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MutableBasisOfClosureUnderAction" );


#############################################################################
##
#F  MutableBasisOfNonassociativeAlgebra( <F>, <Agens>, <zero>, <maxdim> )
##
##  <#GAPDoc Label="MutableBasisOfNonassociativeAlgebra">
##  <ManSection>
##  <Func Name="MutableBasisOfNonassociativeAlgebra"
##   Arg='F, Agens, zero, maxdim'/>
##
##  <Description>
##  is a mutable basis of the (not necessarily associative) <A>F</A>-algebra
##  that is generated by <A>Agens</A>, has zero element <A>zero</A>,
##  and has dimension at most <A>maxdim</A>.
##  If no finite bound for the dimension is known then <Ref Var="infinity"/> must be
##  the value of <A>maxdim</A>.
##  <P/>
##  The difference to <Ref Func="MutableBasisOfClosureUnderAction"/> is that
##  in general it is not sufficient to multiply just with algebra generators.
##  (For special cases of nonassociative algebras, especially for Lie
##  algebras, multiplying with algebra generators suffices.)
##  <Example><![CDATA[
##  gap> L:= FullMatrixLieAlgebra( Rationals, 4 );;
##  gap> m1:= Random( L );;
##  gap> m2:= Random( L );;
##  gap> MutableBasisOfNonassociativeAlgebra( Rationals, [ m1, m2 ],
##  > Zero( L ), 16 );
##  <mutable basis over Rationals, 16 vectors>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MutableBasisOfNonassociativeAlgebra" );


#############################################################################
##
#F  MutableBasisOfIdealInNonassociativeAlgebra( <F>, <Vgens>, <Igens>,
#F                                              <zero>, <from>, <maxdim> )
##
##  <#GAPDoc Label="MutableBasisOfIdealInNonassociativeAlgebra">
##  <ManSection>
##  <Func Name="MutableBasisOfIdealInNonassociativeAlgebra"
##   Arg='F, Vgens, Igens, zero, from, maxdim'/>
##
##  <Description>
##  is a mutable basis of the ideal generated by <A>Igens</A> under the
##  action of the (not necessarily associative) <A>F</A>-algebra with
##  vector space generators <A>Vgens</A>.
##  The zero element of the ideal is <A>zero</A>,
##  <A>from</A> is one of <C>"left"</C>, <C>"right"</C>, <C>"both"</C>
##  (with the same meaning as in
##  <Ref Func="MutableBasisOfClosureUnderAction"/>),
##  and <A>maxdim</A> is a known upper bound on the dimension of the ideal;
##  if no finite bound for the dimension is known then <Ref Var="infinity"/> must be
##  the value of <A>maxdim</A>.
##  <P/>
##  The difference to <Ref Func="MutableBasisOfClosureUnderAction"/> is that
##  in general it is not sufficient to multiply just with algebra generators.
##  (For special cases of nonassociative algebras, especially for Lie
##  algebras, multiplying with algebra generators suffices.)
##  <Example><![CDATA[
##  gap> mats:= [  [[ 1, 0 ], [ 0, -1 ]], [[0,1],[0,0]] ];;
##  gap> A:= Algebra( Rationals, mats );;
##  gap> basA:= BasisVectors( Basis( A ) );;
##  gap> B:= MutableBasisOfIdealInNonassociativeAlgebra( Rationals, basA,
##  > [ mats[2] ], 0*mats[1], "both", infinity );
##  <mutable basis over Rationals, 1 vector>
##  gap> BasisVectors( B );
##  [ [ [ 0, 1 ], [ 0, 0 ] ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "MutableBasisOfIdealInNonassociativeAlgebra" );


#############################################################################
##
##  Domain constructors
##

#############################################################################
##
#O  AlgebraByGenerators( <F>, <gens>[, <zero>] )  . <F>-algebra by generators
##
##  <ManSection>
##  <Oper Name="AlgebraByGenerators" Arg='F, gens[, zero]'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "FLMLORByGenerators",
    [ IsRing, IsCollection ] );

DeclareSynonym( "AlgebraByGenerators", FLMLORByGenerators );


#############################################################################
##
#F  Algebra( <F>, <gens>[, <zero>][, "basis"] )
##
##  <#GAPDoc Label="Algebra">
##  <ManSection>
##  <Func Name="Algebra" Arg='F, gens[, zero][, "basis"]'/>
##
##  <Description>
##  <C>Algebra( <A>F</A>, <A>gens</A> )</C> is the algebra over the division
##  ring <A>F</A>, generated by the vectors in the list <A>gens</A>.
##  <P/>
##  If there are three arguments, a division ring <A>F</A> and a list
##  <A>gens</A> and an element <A>zero</A>,
##  then <C>Algebra( <A>F</A>, <A>gens</A>, <A>zero</A> )</C> is the
##  <A>F</A>-algebra generated by <A>gens</A>, with zero element <A>zero</A>.
##  <P/>
##  If the last argument is the string <C>"basis"</C> then the vectors in
##  <A>gens</A> are known to form a basis of the algebra
##  (as an <A>F</A>-vector space).
##  <Example><![CDATA[
##  gap> m:= [ [ 0, 1, 2 ], [ 0, 0, 3], [ 0, 0, 0 ] ];;
##  gap> A:= Algebra( Rationals, [ m ] );
##  <algebra over Rationals, with 1 generator>
##  gap> Dimension( A );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FLMLOR" );

DeclareSynonym( "Algebra", FLMLOR );


#############################################################################
##
#F  Subalgebra( <A>, <gens>[, "basis"] )
##
##  <#GAPDoc Label="Subalgebra">
##  <ManSection>
##  <Func Name="Subalgebra" Arg='A, gens[, "basis"]'/>
##
##  <Description>
##  is the <M>F</M>-algebra generated by <A>gens</A>,
##  with parent algebra <A>A</A>,
##  where <M>F</M> is the left acting domain of <A>A</A>.
##  <P/>
##  <E>Note</E> that being a subalgebra of <A>A</A> means to be an algebra,
##  to be contained in <A>A</A>,
##  <E>and</E> to have the same left acting domain as <A>A</A>.
##  <P/>
##  An optional argument <C>"basis"</C> may be added if it is known that
##  the generators already form a basis of the algebra.
##  Then it is <E>not</E> checked whether <A>gens</A> really are linearly
##  independent and whether all elements in <A>gens</A> lie in <A>A</A>.
##  <Example><![CDATA[
##  gap> m:= [ [ 0, 1, 2 ], [ 0, 0, 3], [ 0, 0, 0 ] ];;
##  gap> A:= Algebra( Rationals, [ m ] );
##  <algebra over Rationals, with 1 generator>
##  gap> B:= Subalgebra( A, [ m^2 ] );
##  <algebra over Rationals, with 1 generator>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubFLMLOR" );

DeclareSynonym( "Subalgebra", SubFLMLOR );


#############################################################################
##
#F  SubalgebraNC( <A>, <gens>[, "basis"] )
##
##  <#GAPDoc Label="SubalgebraNC">
##  <ManSection>
##  <Func Name="SubalgebraNC" Arg='A, gens[, "basis"]'/>
##
##  <Description>
##  <Ref Func="SubalgebraNC"/> does the same as
##  <Ref Func="Subalgebra"/>, except that it does not check
##  whether all elements in <A>gens</A> lie in <A>A</A>.
##  <Example><![CDATA[
##  gap> m:= RandomMat( 3, 3 );;
##  gap> A:= Algebra( Rationals, [ m ] );
##  <algebra over Rationals, with 1 generator>
##  gap> SubalgebraNC( A, [ IdentityMat( 3, 3 ) ], "basis" );
##  <algebra of dimension 1 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubFLMLORNC" );

DeclareSynonym( "SubalgebraNC", SubFLMLORNC );


#############################################################################
##
#O  AlgebraWithOneByGenerators( <F>, <gens>[, <zero>] )
##
##  <ManSection>
##  <Oper Name="AlgebraWithOneByGenerators" Arg='F, gens[, zero]'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "FLMLORWithOneByGenerators", [ IsRing, IsCollection ] );

DeclareSynonym( "AlgebraWithOneByGenerators", FLMLORWithOneByGenerators );


#############################################################################
##
#F  AlgebraWithOne( <F>, <gens>[, <zero>][, "basis"] )
##
##  <#GAPDoc Label="AlgebraWithOne">
##  <ManSection>
##  <Func Name="AlgebraWithOne" Arg='F, gens[, zero][, "basis"]'/>
##
##  <Description>
##  <C>AlgebraWithOne( <A>F</A>, <A>gens</A> )</C> is the algebra-with-one
##  over the division ring <A>F</A>,
##  generated by the vectors in the list <A>gens</A>.
##  <P/>
##  If there are three arguments, a division ring <A>F</A>
##  and a list <A>gens</A> and an element <A>zero</A>,
##  then <C>AlgebraWithOne( <A>F</A>, <A>gens</A>, <A>zero</A> )</C> is the
##  <A>F</A>-algebra-with-one generated by <A>gens</A>,
##  with zero element <A>zero</A>.
##  <P/>
##  If the last argument is the string <C>"basis"</C> then the vectors in
##  <A>gens</A> are known to form a basis of the algebra
##  (as an <A>F</A>-vector space).
##  <Example><![CDATA[
##  gap> m:= [ [ 0, 1, 2 ], [ 0, 0, 3], [ 0, 0, 0 ] ];;
##  gap> A:= AlgebraWithOne( Rationals, [ m ] );
##  <algebra-with-one over Rationals, with 1 generator>
##  gap> Dimension( A );
##  3
##  gap> One(A);
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FLMLORWithOne" );

DeclareSynonym( "AlgebraWithOne", FLMLORWithOne );


#############################################################################
##
#F  SubalgebraWithOne( <A>, <gens>[, "basis"] )
##
##  <#GAPDoc Label="SubalgebraWithOne">
##  <ManSection>
##  <Func Name="SubalgebraWithOne" Arg='A, gens[, "basis"]'/>
##
##  <Description>
##  is the algebra-with-one generated by <A>gens</A>,
##  with parent algebra <A>A</A>.
##  <P/>
##  The optional third argument, the string <C>"basis"</C>, may be added if
##  it is known that the elements from <A>gens</A> are linearly independent.
##  Then it is <E>not</E> checked whether <A>gens</A> really are linearly
##  independent and whether all elements in <A>gens</A> lie in <A>A</A>.
##  <Example><![CDATA[
##  gap> m:= [ [ 0, 1, 2 ], [ 0, 0, 3], [ 0, 0, 0 ] ];;
##  gap> A:= AlgebraWithOne( Rationals, [ m ] );
##  <algebra-with-one over Rationals, with 1 generator>
##  gap> B1:= SubalgebraWithOne( A, [ m ] );;
##  gap> B2:= Subalgebra( A, [ m ] );;
##  gap> Dimension( B1 );
##  3
##  gap> Dimension( B2 );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubFLMLORWithOne" );

DeclareSynonym( "SubalgebraWithOne", SubFLMLORWithOne );


#############################################################################
##
#F  SubalgebraWithOneNC( <A>, <gens>[, "basis"] )
##
##  <#GAPDoc Label="SubalgebraWithOneNC">
##  <ManSection>
##  <Func Name="SubalgebraWithOneNC" Arg='A, gens[, "basis"]'/>
##
##  <Description>
##  <Ref Func="SubalgebraWithOneNC"/> does the same as
##  <Ref Func="SubalgebraWithOne"/>, except that it does not check
##  whether all elements in <A>gens</A> lie in <A>A</A>.
##  <Example><![CDATA[
##  gap> m:= RandomMat( 3, 3 );; A:= Algebra( Rationals, [ m ] );;
##  gap> SubalgebraWithOneNC( A, [ m ] );
##  <algebra-with-one over Rationals, with 1 generator>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubFLMLORWithOneNC" );

DeclareSynonym( "SubalgebraWithOneNC", SubFLMLORWithOneNC );


#############################################################################
##
#F  LieAlgebra( <L> )
#F  LieAlgebra( <F>, <gens>[, <zero>][, "basis"] )
##
##  <#GAPDoc Label="LieAlgebra">
##  <ManSection>
##  <Func Name="LieAlgebra" Arg='L' Label="for an associative algebra"/>
##  <Func Name="LieAlgebra" Arg='F, gens[, zero][, "basis"]'
##   Label="for field and generators"/>
##
##  <Description>
##  For an associative algebra <A>L</A>, <C>LieAlgebra( <A>L</A> )</C> is the
##  Lie algebra isomorphic to <A>L</A> as a vector space
##  but with the Lie bracket as product.
##  <P/>
##  <C>LieAlgebra( <A>F</A>, <A>gens</A> )</C> is the Lie algebra over the
##  division ring <A>F</A>, generated <E>as Lie algebra</E>
##  by the Lie objects corresponding to the vectors in the list <A>gens</A>.
##  <P/>
##  <E>Note</E> that the algebra returned by
##  <Ref Func="LieAlgebra" Label="for field and generators"/>
##  does not contain the vectors in <A>gens</A>.
##  The elements in <A>gens</A> are wrapped up as Lie objects
##  (see <Ref Sect="Lie Objects"/>).
##  This allows one to create Lie algebras from ring elements with respect to
##  the Lie bracket as product.  But of course the product in the Lie
##  algebra is the usual <C>*</C>.
##  <P/>
##  If there are three arguments, a division ring <A>F</A> and a list
##  <A>gens</A> and an element <A>zero</A>,
##  then <C>LieAlgebra( <A>F</A>, <A>gens</A>, <A>zero</A> )</C> is the
##  corresponding <A>F</A>-Lie algebra with zero element the Lie object
##  corresponding to <A>zero</A>.
##  <P/>
##  If the last argument is the string <C>"basis"</C> then the vectors in
##  <A>gens</A> are known to form a basis of the algebra
##  (as an <A>F</A>-vector space).
##  <P/>
##  <E>Note</E> that even if each element in <A>gens</A> is already
##  a Lie element, i.e., is of the form <C>LieElement( <A>elm</A> )</C>
##  for an object <A>elm</A>,
##  the elements of the result lie in the Lie family of the family that
##  contains <A>gens</A> as a subset.
##  <Example><![CDATA[
##  gap> A:= FullMatrixAlgebra( GF( 7 ), 4 );;
##  gap> L:= LieAlgebra( A );
##  <Lie algebra of dimension 16 over GF(7)>
##  gap> mats:= [ [ [ 1, 0 ], [ 0, -1 ] ], [ [ 0, 1 ], [ 0, 0 ] ],
##  >             [ [ 0, 0 ], [ 1, 0] ] ];;
##  gap> L:= LieAlgebra( Rationals, mats );
##  <Lie algebra over Rationals, with 3 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LieAlgebra" );


#############################################################################
##
#A  LieAlgebraByDomain( <A> )
##
##  <ManSection>
##  <Attr Name="LieAlgebraByDomain" Arg='A'/>
##
##  <Description>
##  is a Lie algebra isomorphic to the algebra <A>A</A> as a vector space,
##  but with the Lie bracket as product.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "LieAlgebraByDomain", IsAlgebra );


#############################################################################
##
#O  AsLieAlgebra( <F>, <A> ) . . . . . . . . view <A> as Lie algebra over <F>
##
##  <ManSection>
##  <Oper Name="AsLieAlgebra" Arg='F, A'/>
##
##  <Description>
##  Note that the multiplication in <A>A</A> is the same as in the result.
##  </Description>
##  </ManSection>
##
DeclareOperation( "AsLieAlgebra", [ IsDivisionRing, IsCollection ] );


#############################################################################
##
#F  FreeAlgebra( <R>, <rank>[, <name>] )
#F  FreeAlgebra( <R>, <name1>, <name2>, ... )
##
##  <#GAPDoc Label="FreeAlgebra">
##  <ManSection>
##  <Func Name="FreeAlgebra" Arg='R, rank[, name]'
##   Label="for ring, rank (and name)"/>
##  <Func Name="FreeAlgebra" Arg='R, name1, name2, ...'
##   Label="for ring and several names"/>
##
##  <Description>
##  is a free (nonassociative) algebra of rank <A>rank</A>
##  over the division ring <A>R</A>.
##  Here <A>name</A>, and <A>name1</A>, <A>name2</A>, ... are optional strings
##  that can be used to provide names for the generators.
##  <Example><![CDATA[
##  gap> A:= FreeAlgebra( Rationals, "a", "b" );
##  <algebra over Rationals, with 2 generators>
##  gap> g:= GeneratorsOfAlgebra( A );
##  [ (1)*a, (1)*b ]
##  gap> (g[1]*g[2])*((g[2]*g[1])*g[1]);
##  (1)*((a*b)*((b*a)*a))
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeAlgebra" );


#############################################################################
##
#F  FreeAlgebraWithOne( <R>, <rank>[, <name>] )
#F  FreeAlgebraWithOne( <R>, <name1>, <name2>, ... )
##
##  <#GAPDoc Label="FreeAlgebraWithOne">
##  <ManSection>
##  <Func Name="FreeAlgebraWithOne" Arg='R, rank[, name]'
##   Label="for ring, rank (and name)"/>
##  <Func Name="FreeAlgebraWithOne" Arg='R, name1, name2, ...'
##   Label="for ring and several names"/>
##
##  <Description>
##  is a free (nonassociative) algebra-with-one of rank <A>rank</A>
##  over the division ring <A>R</A>.
##  Here <A>name</A>, and <A>name1</A>, <A>name2</A>, ... are optional strings
##  that can be used to provide names for the generators.
##  <Example><![CDATA[
##  gap> A:= FreeAlgebraWithOne( Rationals, 4, "q" );
##  <algebra-with-one over Rationals, with 4 generators>
##  gap> GeneratorsOfAlgebra( A );
##  [ (1)*<identity ...>, (1)*q.1, (1)*q.2, (1)*q.3, (1)*q.4 ]
##  gap> One( A );
##  (1)*<identity ...>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeAlgebraWithOne" );


#############################################################################
##
#F  FreeAssociativeAlgebra( <R>, <rank>[, <name>] )
#F  FreeAssociativeAlgebra( <R>, <name1>, <name2>, ... )
##
##  <#GAPDoc Label="FreeAssociativeAlgebra">
##  <ManSection>
##  <Func Name="FreeAssociativeAlgebra" Arg='R, rank[, name]'
##   Label="for ring, rank (and name)"/>
##  <Func Name="FreeAssociativeAlgebra" Arg='R, name1, name2, ...'
##   Label="for ring and several names"/>
##
##  <Description>
##  is a free associative algebra of rank <A>rank</A> over the
##  division ring <A>R</A>.
##  Here <A>name</A>, and <A>name1</A>, <A>name2</A>, ... are optional strings
##  that can be used to provide names for the generators.
##  <Example><![CDATA[
##  gap> A:= FreeAssociativeAlgebra( GF( 5 ), 4, "a" );
##  <algebra over GF(5), with 4 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeAssociativeAlgebra" );


#############################################################################
##
#F  FreeAssociativeAlgebraWithOne( <R>, <rank>[, <name>] )
#F  FreeAssociativeAlgebraWithOne( <R>, <name1>, <name2>, ... )
##
##  <#GAPDoc Label="FreeAssociativeAlgebraWithOne">
##  <ManSection>
##  <Func Name="FreeAssociativeAlgebraWithOne" Arg='R, rank[, name]'
##   Label="for ring, rank (and name)"/>
##  <Func Name="FreeAssociativeAlgebraWithOne" Arg='R, name1, name2, ...'
##   Label="for ring and several names"/>
##
##  <Description>
##  is a free associative algebra-with-one of rank <A>rank</A> over the
##  division ring <A>R</A>.
##  Here <A>name</A>, and <A>name1</A>, <A>name2</A>, ... are optional strings
##  that can be used to provide names for the generators.
##  <Example><![CDATA[
##  gap> A:= FreeAssociativeAlgebraWithOne( Rationals, "a", "b", "c" );
##  <algebra-with-one over Rationals, with 3 generators>
##  gap> GeneratorsOfAlgebra( A );
##  [ (1)*<identity ...>, (1)*a, (1)*b, (1)*c ]
##  gap> One( A );
##  (1)*<identity ...>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeAssociativeAlgebraWithOne" );


#############################################################################
##
#F  AlgebraByStructureConstants( <R>, <sctable>[, <nameinfo>] )
##
##  <#GAPDoc Label="AlgebraByStructureConstants">
##  <ManSection>
##  <Func Name="AlgebraByStructureConstants" Arg='R, sctable[, nameinfo]'/>
##
##  <Description>
##  returns a free left module <M>A</M> over the division ring <A>R</A>,
##  with multiplication defined by the structure constants table
##  <A>sctable</A>.
##  The optional argument <A>nameinfo</A> can be used to prescribe names for
##  the elements of the canonical basis of <M>A</M>;
##  it can be either a string <A>name</A>
##  (then <A>name</A><C>1</C>, <A>name</A><C>2</C> etc. are chosen)
##  or a list of strings which are then chosen.
##  The vectors of the canonical basis of <M>A</M> correspond to the vectors
##  of the basis given by <A>sctable</A>.
##  <P/>
##  <!-- The algebra generators of <M>A</M> are linearly independent
##    abstract vector space generators
##    <M>x_1, x_2, \ldots, x_n</M> which are multiplied according to the
##    formula <M> x_i x_j = \sum_{k=1}^n c_{ijk} x_k</M>
##    where <C><M>c_{ijk}</M> = <A>sctable</A>[i][j][1][i_k]</C>
##    and <C><A>sctable</A>[i][j][2][i_k] = k</C>. -->
##  It is <E>not</E> checked whether the coefficients in <A>sctable</A>
##  are really elements in <A>R</A>.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
##  gap> A:= AlgebraByStructureConstants( Rationals, T );
##  <algebra of dimension 2 over Rationals>
##  gap> b:= BasisVectors( Basis( A ) );;
##  gap> b[1]^2;
##  (1/2)*v.1+(2/3)*v.2
##  gap> b[1]*b[2];
##  0*v.1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AlgebraByStructureConstants" );


#############################################################################
##
#F  AlgebraWithOneByStructureConstants( <R>, <sctable>[, <nameinfo>],
#F                                      <onecoeffs> )
##
##  <#GAPDoc Label="AlgebraWithOneByStructureConstants">
##  <ManSection>
##  <Func Name="AlgebraWithOneByStructureConstants"
##   Arg="R, sctable[, nameinfo], onecoeffs"/>
##
##  <Description>
##  The only differences between this function and
##  <Ref Func="AlgebraByStructureConstants"/> are that
##  <Ref Func="AlgebraWithOneByStructureConstants"/> takes an additional
##  argument <A>onecoeffs</A>, the coefficients vector over the ring <A>R</A>
##  that describes the unique multiplicative identity element of the returned
##  algebra w. r. t. the defining basis of this algebra,
##  and that the returned algebra is an algebra-with-one
##  (see <Ref Filt="IsAlgebraWithOne"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> A:= GF(2)^[2,2];;
##  gap> B:= Basis( A );;
##  gap> onecoeffs:= Coefficients( B, One( A ) );
##  [ Z(2)^0, 0*Z(2), 0*Z(2), Z(2)^0 ]
##  gap> T:= StructureConstantsTable( B );;
##  gap> sc1:= AlgebraByStructureConstants( GF(2), T );
##  <algebra of dimension 4 over GF(2)>
##  gap> HasOne( sc1 );
##  false
##  gap> One( sc1 );
##  v.1+v.4
##  gap> sc2:= AlgebraWithOneByStructureConstants( GF(2), T, onecoeffs );
##  <algebra-with-one of dimension 4 over GF(2)>
##  gap> HasOne( sc2 );
##  true
##  gap> One( sc2 );
##  v.1+v.4
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AlgebraWithOneByStructureConstants" );


#############################################################################
##
#F  LieAlgebraByStructureConstants( <R>, <sctable>[, <nameinfo>] )
##
##  <#GAPDoc Label="LieAlgebraByStructureConstants">
##  <ManSection>
##  <Func Name="LieAlgebraByStructureConstants"
##   Arg='R, sct[, nameinfo]'/>
##
##  <Description>
##  <Ref Func="LieAlgebraByStructureConstants"/> does the same as
##  <Ref Func="AlgebraByStructureConstants"/>, and has the same meaning
##  of arguments, except that the result is assumed to be a Lie algebra.
##  Note that the function does not check whether
##  <A>sct</A> satisfies the Jacobi identity.
##  (So if one creates a Lie algebra this way with a table that does not
##  satisfy the Jacobi identity, errors may occur later on.)
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 2, 0, "antisymmetric" );;
##  gap> SetEntrySCTable( T, 1, 2, [ 1/2, 1 ] );
##  gap> L:= LieAlgebraByStructureConstants( Rationals, T );
##  <Lie algebra of dimension 2 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LieAlgebraByStructureConstants" );

#############################################################################
##
#F  RestrictedLieAlgebraByStructureConstants( <R>, <sct>[, <nameinfo>], pmapping )
##
##  <#GAPDoc Label="RestrictedLieAlgebraByStructureConstants">
##  <ManSection>
##  <Func Name="RestrictedLieAlgebraByStructureConstants"
##   Arg='R, sct[, nameinfo], pmapping'/>
##
##  <Description>
##  <Ref Func="RestrictedLieAlgebraByStructureConstants"/> does the same as
##  <Ref Func="LieAlgebraByStructureConstants"/>, and has the same meaning of
##  all arguments, except that the result is assumed to be a restricted Lie
##  algebra (see <Ref Label="Restricted Lie algebras"/>) with the <M>p</M>-map
##  given by the additional argument <A>pmapping</A>. This last argument is a
##  list of the length equal to the dimension of the algebra; its <M>i</M>-th
##  entry specifies the <M>p</M>-th power of the <M>i</M>-th basis vector
##  in the same format <C>[ coeff1, position1, coeff2, position2, ... ]</C> as
##  <Ref Func="SetEntrySCTable"/> uses to specify entries of the structure
##  constants table.
##  <P/>
##  Note that the function does not check whether
##  <A>sct</A> satisfies the Jacobi identity, of whether <A>pmapping</A>
##  specifies a legitimate <M>p</M>-mapping.
##  <P/>
##  The following example creates a commutative restricted Lie algebra of dimension
##  3, in which the <M>p</M>-th power of the <M>i</M>-th basis element is
##  the <M>i+1</M>-th basis element (except for the 3rd basis element which
##  goes to zero).
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 3, Zero(GF(5)), "antisymmetric" );;
##  gap> L:= RestrictedLieAlgebraByStructureConstants(
##  >                                     GF(5), T, [[1,2],[1,3],[]] );
##  <Lie algebra of dimension 3 over GF(5)>
##  gap> List(Basis(L),PthPowerImage);
##  [ v.2, v.3, 0*v.1 ]
##  gap> PthPowerImage(L.1+L.2);
##  v.2+v.3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RestrictedLieAlgebraByStructureConstants" );


#############################################################################
##
#C  IsQuaternion( <obj> )
#C  IsQuaternionCollection(<obj>)
#C  IsQuaternionCollColl(<obj>)
##
##  <#GAPDoc Label="IsQuaternion">
##  <ManSection>
##  <Filt Name="IsQuaternion" Arg='obj' Type='Category'/>
##  <Filt Name="IsQuaternionCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsQuaternionCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsQuaternion"/> is the category of elements in an algebra
##  constructed by <Ref Func="QuaternionAlgebra"/>.
##  A collection of quaternions lies in the category
##  <Ref Filt="IsQuaternionCollection"/>.
##  Finally, a collection of quaternion collections
##  (e.g., a matrix of quaternions) lies in the category
##  <Ref Filt="IsQuaternionCollColl"/>.
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> b:= BasisVectors( Basis( A ) );
##  [ e, i, j, k ]
##  gap> IsQuaternion( b[1] );
##  true
##  gap> IsQuaternionCollColl( [ [ b[1], b[2] ], [ b[3], b[4] ] ] );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsQuaternion", IsScalar and IsAssociative );
DeclareCategoryCollections( "IsQuaternion" );
DeclareCategoryCollections( "IsQuaternionCollection" );


#############################################################################
##
#F  QuaternionAlgebra( <F>[, <a>, <b>] )
##
##  <#GAPDoc Label="QuaternionAlgebra">
##  <ManSection>
##  <Func Name="QuaternionAlgebra" Arg='F[, a, b]'/>
##
##  <Returns>
##  a quaternion algebra over <A>F</A>,
##  with parameters <A>a</A> and <A>b</A>.
##  </Returns>
##  <Description>
##  Let <A>F</A> be a field or a list of field elements,
##  let <M>F</M> be the field generated by <A>F</A>,
##  and let <A>a</A> and <A>b</A> two elements in <M>F</M>.
##  <Ref Func="QuaternionAlgebra"/> returns a quaternion algebra over
##  <M>F</M>, with parameters <A>a</A> and <A>b</A>,
##  i.e., a four-dimensional associative <M>F</M>-algebra with basis
##  <M>(e,i,j,k)</M> and multiplication defined by
##  <M>e e = e</M>, <M>e i = i e = i</M>, <M>e j = j e = j</M>,
##  <M>e k = k e = k</M>, <M>i i = <A>a</A> e</M>, <M>i j = - j i = k</M>,
##  <M>i k = - k i = <A>a</A> j</M>, <M>j j = <A>b</A> e</M>,
##  <M>k j = - j k = <A>b</A> i</M>, <M>k k = - <A>a</A> <A>b</A> e</M>.
##  The default value for both <A>a</A> and <A>b</A> is
##  <M>-1 \in F</M>.
##  <P/>
##  The <Ref Attr="GeneratorsOfAlgebra"/> and <Ref Attr="CanonicalBasis"/>
##  value of an algebra constructed with <Ref Func="QuaternionAlgebra"/>
##  is the list <M>[ e, i, j, k ]</M>.
##  <P/>
##  Two quaternion algebras with the same parameters <A>a</A>, <A>b</A>
##  lie in the same family, so it makes sense to consider their intersection
##  or to ask whether they are contained in each other.
##  (This is due to the fact that the results of
##  <Ref Func="QuaternionAlgebra"/> are cached,
##  in the global variable <C>QuaternionAlgebraData</C>.)
##  <P/>
##  The embedding of the field <Ref Var="GaussianRationals"/> into
##  a quaternion algebra <M>A</M> over <Ref Var="Rationals"/>
##  is not uniquely determined.
##  One can specify one embedding as a vector space homomorphism
##  that maps <C>1</C> to the first algebra generator of <M>A</M>,
##  and <C>E(4)</C> to one of the others.
##  <Example><![CDATA[
##  gap> QuaternionAlgebra( Rationals );
##  <algebra-with-one of dimension 4 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "QuaternionAlgebra" );


#############################################################################
##
#V  QuaternionAlgebraData
##
##  <ManSection>
##  <Var Name="QuaternionAlgebraData"/>
##
##  <Description>
##  is a list of quadruples of the form
##  <C>[ <A>a</A>, <A>b</A>, <A>fam</A>, <A>A</A> ]</C>
##  where <A>a</A> and <A>b</A> are the parameters for the call of
##  <Ref Func="QuaternionAlgebra"/>,
##  <A>fam</A> is the family of the desired algebra,
##  and <A>A</A> is a quaternion algebra in this family.
##  </Description>
##  </ManSection>
##
BindGlobal( "QuaternionAlgebraData", NEW_SORTED_CACHE(true) );


#############################################################################
##
#F  ComplexificationQuat( <vector> )
#F  ComplexificationQuat( <matrix> )
##
##  <#GAPDoc Label="ComplexificationQuat">
##  <ManSection>
##  <Func Name="ComplexificationQuat" Arg='vector' Label="for a vector"/>
##  <Func Name="ComplexificationQuat" Arg='matrix' Label="for a matrix"/>
##
##  <Description>
##  Let <M>A = e F \oplus i F \oplus j F \oplus k F</M> be
##  a quaternion algebra over the field <M>F</M> of cyclotomics,
##  with basis <M>(e,i,j,k)</M>.
##  <P/>
##  If <M>v = v_1 + v_2 j</M> is a row vector over <M>A</M>
##  with <M>v_1 = e w_1 + i w_2</M>
##  and <M>v_2 = e w_3 + i w_4</M> then
##  <Ref Func="ComplexificationQuat" Label="for a vector"/>
##  called with argument <M>v</M> returns the
##  concatenation of <M>w_1 + </M><C>E(4)</C><M> w_2</M> and
##  <M>w_3 + </M><C>E(4)</C><M> w_4</M>.
##  <P/>
##  If <M>M = M_1 + M_2 j</M> is a matrix over <M>A</M>
##  with <M>M_1 = e N_1 + i N_2</M>
##  and <M>M_2 = e N_3 + i N_4</M> then
##  <Ref Func="ComplexificationQuat" Label="for a matrix"/>
##  called with argument <M>M</M> returns the
##  block matrix <M>A</M> over <M>e F \oplus i F</M> such that
##  <M>A(1,1) = N_1 + </M><C>E(4)</C><M> N_2</M>,
##  <M>A(2,2) = N_1 - </M><C>E(4)</C><M> N_2</M>,
##  <M>A(1,2) = N_3 + </M><C>E(4)</C><M> N_4</M>, and
##  <M>A(2,1) = - N_3 + </M><C>E(4)</C><M> N_4</M>.
##  <P/>
##  Then <C>ComplexificationQuat(<A>v</A>) * ComplexificationQuat(<A>M</A>)=
##        ComplexificationQuat(<A>v</A> * <A>M</A>)</C>, since
##  <Display Mode="M">
##  v M = v_1 M_1 + v_2 j M_1 + v_1 M_2 j + v_2 j M_2 j
##      =   ( v_1 M_1 - v_2 \overline{{M_2}} )
##        + ( v_1 M_2 + v_2 \overline{{M_1}} ) j.
##  </Display>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ComplexificationQuat" );


#############################################################################
##
#F  OctaveAlgebra( <F> )
##
##  <#GAPDoc Label="OctaveAlgebra">
##  <ManSection>
##  <Func Name="OctaveAlgebra" Arg='F'/>
##
##  <Description>
##  The algebra of octonions over <A>F</A>.
##  <Example><![CDATA[
##  gap> OctaveAlgebra( Rationals );
##  <algebra of dimension 8 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OctaveAlgebra" );


#############################################################################
##
#F  FullMatrixFLMLOR( <R>, <n> )
#F  FullMatrixAlgebra( <R>, <n> )
#F  MatrixAlgebra( <R>, <n> )
#F  MatAlgebra( <R>, <n> )
##
##  <#GAPDoc Label="FullMatrixAlgebra">
##  <ManSection>
##  <Func Name="FullMatrixAlgebra" Arg='R, n'/>
##  <Func Name="MatrixAlgebra" Arg='R, n'/>
##  <Func Name="MatAlgebra" Arg='R, n'/>
##
##  <Description>
##  is the full matrix algebra of <M><A>n</A> \times <A>n</A></M> matrices
##  over the ring <A>R</A>,
##  for a nonnegative integer <A>n</A>.
##  <Example><![CDATA[
##  gap> A:=FullMatrixAlgebra( Rationals, 20 );
##  ( Rationals^[ 20, 20 ] )
##  gap> Dimension( A );
##  400
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FullMatrixFLMLOR" );

DeclareSynonym( "FullMatrixAlgebra", FullMatrixFLMLOR );
DeclareSynonym( "MatrixAlgebra", FullMatrixFLMLOR );
DeclareSynonym( "MatAlgebra", FullMatrixFLMLOR );


#############################################################################
##
#F  FullMatrixLieAlgebra( <R>, <n> )
#F  MatrixLieAlgebra( <R>, <n> )
#F  MatLieAlgebra( <R>, <n> )
##
##  <#GAPDoc Label="FullMatrixLieAlgebra">
##  <ManSection>
##  <Func Name="FullMatrixLieAlgebra" Arg='R, n'/>
##  <Func Name="MatrixLieAlgebra" Arg='R, n'/>
##  <Func Name="MatLieAlgebra" Arg='R, n'/>
##
##  <Description>
##  is the full matrix Lie algebra of <M><A>n</A> \times <A>n</A></M>
##  matrices over the ring <A>R</A>,
##  for a nonnegative integer <A>n</A>.
##  <Example><![CDATA[
##  gap> FullMatrixLieAlgebra( GF(9), 10 );
##  <Lie algebra over GF(3^2), with 19 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FullMatrixLieFLMLOR" );

DeclareSynonym( "FullMatrixLieAlgebra", FullMatrixLieFLMLOR );
DeclareSynonym( "MatrixLieAlgebra", FullMatrixLieFLMLOR );
DeclareSynonym( "MatLieAlgebra", FullMatrixLieFLMLOR );


#############################################################################
##
#C  IsMatrixFLMLOR( <obj> ) . . . . . .  test if an object is a matrix FLMLOR
##
##  <ManSection>
##  <Filt Name="IsMatrixFLMLOR" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonym( "IsMatrixFLMLOR", IsFLMLOR and IsRingElementCollCollColl );


#############################################################################
##
#M  IsFiniteDimensional( <A> )  . . . . matrix FLMLORs are finite dimensional
##
InstallTrueMethod( IsFiniteDimensional, IsMatrixFLMLOR );


#############################################################################
##
#A  CentralIdempotentsOfAlgebra( <A> )
##
##  <#GAPDoc Label="CentralIdempotentsOfAlgebra">
##  <ManSection>
##  <Attr Name="CentralIdempotentsOfAlgebra" Arg='A'/>
##
##  <Description>
##  For an associative algebra <A>A</A>, this function returns
##  a list of central primitive idempotents such that their sum is
##  the identity element of <A>A</A>.
##  Therefore <A>A</A> is required to have an identity.
##  <P/>
##  (This is a synonym of <C>CentralIdempotentsOfSemiring</C>.)
##  <!-- add crossref. as soon as this is available -->
##  <Example><![CDATA[
##  gap> A:= QuaternionAlgebra( Rationals );;
##  gap> B:= DirectSumOfAlgebras( [A, A, A] );
##  <algebra of dimension 12 over Rationals>
##  gap> CentralIdempotentsOfAlgebra( B );
##  [ v.9, v.5, v.1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "CentralIdempotentsOfAlgebra",
    CentralIdempotentsOfSemiring );


#############################################################################
##
#A  LeviMalcevDecomposition( <L> )
##
##  <#GAPDoc Label="LeviMalcevDecomposition">
##  <ManSection>
##  <Attr Name="LeviMalcevDecomposition" Arg='L' Label="for Lie algebras"/>
##
##  <Description>
##  A Levi-Malcev subalgebra of the algebra <A>L</A> is a semisimple
##  subalgebra complementary to the radical of <A>L</A>.
##  This function returns a list with two components.
##  The first component is a Levi-Malcev subalgebra, the second the radical.
##  This function is implemented for associative and Lie algebras.
##  <Example><![CDATA[
##  gap> m:= [ [ 1, 2, 0 ], [ 0, 1, 3 ], [ 0, 0, 1] ];;
##  gap> A:= Algebra( Rationals, [ m ] );;
##  gap> LeviMalcevDecomposition( A );
##  [ <algebra of dimension 1 over Rationals>,
##    <algebra of dimension 2 over Rationals> ]
##  ]]></Example>
##  <Example><![CDATA[
##  gap> L:= FullMatrixLieAlgebra( Rationals, 5 );;
##  gap> LeviMalcevDecomposition( L );
##  [ <Lie algebra of dimension 24 over Rationals>,
##    <two-sided ideal in <Lie algebra of dimension 25 over Rationals>,
##        (dimension 1)> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LeviMalcevDecomposition", IsAlgebra );


#############################################################################
##
#F  CentralizerInFiniteDimensionalAlgebra( <A>, <S>, <issubset> )
##
##  <ManSection>
##  <Func Name="CentralizerInFiniteDimensionalAlgebra" Arg='A, S, issubset'/>
##
##  <Description>
##  is the centralizer of the list <A>S</A> in the algebra <A>A</A>,
##  that is, the set
##  <M>\{ a \in A; a s = s a \forall s \in S \}</M>.
##  <P/>
##  <A>issubset</A> must be either <K>true</K> or <K>false</K>,
##  where the former means that
##  <A>S</A> is known to be contained in <A>A</A>.
##  If <A>S</A> is not known to be contained in <A>A</A> then the centralizer
##  of <A>S</A> in the closure of <A>A</A> and <A>S</A> is computed,
##  the result is the intersection of this with <A>A</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CentralizerInFiniteDimensionalAlgebra" );


#############################################################################
##
#O  IsNilpotentElement( <L>, <x> )
##
##  <#GAPDoc Label="IsNilpotentElement">
##  <ManSection>
##  <Oper Name="IsNilpotentElement" Arg='L, x'/>
##
##  <Description>
##  <A>x</A> is nilpotent in <A>L</A> if its adjoint matrix is
##  a nilpotent matrix.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> IsNilpotentElement( L, Basis( L )[1] );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IsNilpotentElement", [ IsAlgebra, IsRingElement ] );
DeclareSynonym( "IsLieNilpotentElement", IsNilpotentElement);


#############################################################################
##
#A  Grading( <A> )
##
##  <#GAPDoc Label="Grading">
##  <ManSection>
##  <Attr Name="Grading" Arg='A'/>
##
##  <Description>
##  Let <M>G</M> be an Abelian group and <M>A</M> an algebra.
##  Then <M>A</M> is said to be graded over <M>G</M> if for every
##  <M>g \in G</M> there is a subspace <M>A_g</M> of <M>A</M> such that
##  <M>A_g \cdot A_h \subset A_{{g+h}}</M> for <M>g, h \in G</M>.
##  In &GAP;&nbsp;4 a <E>grading</E> of an algebra is a record containing the
##  following components.
##  <List>
##  <Mark><C>source</C></Mark>
##  <Item>
##    the Abelian group over which the algebra is graded.
##  </Item>
##  <Mark><C>hom_components</C></Mark>
##  <Item>
##    a function assigning to each element from the
##    source a subspace of the algebra.
##  </Item>
##  <Mark><C>min_degree</C></Mark>
##  <Item>
##    in the case where the algebra is graded over the integers
##    this is the minimum number for which <C>hom_components</C> returns
##    a nonzero subspace.
##  </Item>
##  <Mark><C>max_degree</C></Mark>
##  <Item>
##    is analogous to <C>min_degree</C>.
##  </Item>
##  </List>
##  We note that there are no methods to compute a grading of an
##  arbitrary algebra; however some algebras get a natural grading when
##  they are constructed (see <Ref Attr="JenningsLieAlgebra"/>,
##  <Ref Func="NilpotentQuotientOfFpLieAlgebra"/>).
##  <P/>
##  We note also that these components may be not enough to handle
##  the grading efficiently, and another record component may be needed.
##  For instance in a Lie algebra <M>L</M> constructed by
##  <Ref Attr="JenningsLieAlgebra"/>, the length of the of the range
##  <C>[ Grading(L)!.min_degree .. Grading(L)!.max_degree ]</C> may be
##  non-polynomial in the dimension of <M>L</M>.
##  To handle efficiently this situation, an optional component can be
##  used:
##  <List>
##  <Mark><C>non_zero_hom_components</C></Mark>
##  <Item>
##    the subset of <C>source</C> for which <C>hom_components</C> returns
##    a nonzero subspace.
##  </Item>
##  </List>
##  <Example><![CDATA[
##  gap> G:= SmallGroup(3^6, 100 );
##  <pc group of size 729 with 6 generators>
##  gap> L:= JenningsLieAlgebra( G );
##  <Lie algebra of dimension 6 over GF(3)>
##  gap> g:= Grading( L );
##  rec( hom_components := function( d ) ... end, max_degree := 9,
##    min_degree := 1, source := Integers )
##  gap> g.hom_components( 3 );
##  <vector space over GF(3), with 1 generator>
##  gap> g.hom_components( 14 );
##  <vector space of dimension 0 over GF(3)>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Grading", IsAlgebra );
