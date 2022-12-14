#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Willem de Graaf, and Craig A. Struble.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declaration of attributes, properties, and
##  operations for modules over Lie algebras.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{lierep}">
##
##  An <M>s</M>-cochain of a module <M>V</M> over a Lie algebra <M>L</M>
##  is an <M>s</M>-linear map
##  <Display Mode="M">
##  c: L \times \cdots \times L \rightarrow V ,
##  </Display>
##  with <M>s</M> factors <M>L</M>,
##  that is skew-symmetric (meaning that if any of the arguments are
##  interchanged, <M>c</M> changes to <M>-c</M>).
##  <P/>
##  Let <M>(x_1, \ldots, x_n)</M> be a basis of <M>L</M>.
##  Then any <M>s</M>-cochain is
##  determined by the values <M>c( x_{{i_1}}, \ldots, x_{{i_s}} )</M>,
##  where <M>1 \leq i_1 &lt; i_2 &lt; \cdots &lt; i_s \leq \dim L</M>.
##  Now this value again is a linear combination of basis elements of <M>V</M>:
##  <M>c( x_{{i_1}}, \ldots, x_{{i_s}} ) =
##  \sum \lambda^k_{{i_1,\ldots, i_s}} v_k</M>.
##  Denote the dimension of <M>V</M> by <M>r</M>.
##  Then we represent an <M>s</M>-cocycle by a list of <M>r</M> lists.
##  The <M>j</M>-th of those lists consists of entries of the form
##  <Display Mode="M">
##  [ [ i_1, i_2, \ldots, i_s ], \lambda^j_{{i_1, \ldots, i_s}} ]
##  </Display>
##  where the coefficient on the second position is non-zero.
##  (We only store those entries for which this coefficient is non-zero.)
##  It follows that every <M>s</M>-tuple <M>(i_1, \ldots, i_s)</M> gives rise
##  to <M>r</M>  basis elements.
##  <P/>
##  So the zero cochain is represented by a list of the form
##  <C>[ [ ], [ ], \ldots, [ ] ]</C>. Furthermore, if <M>V</M> is, e.g.,
##  <M>4</M>-dimensional, then the <M>2</M>-cochain represented by
##  <P/>
##  <Log><![CDATA[
##  [ [ [ [1,2], 2] ], [ ], [ [ [1,2], 1/2 ] ], [ ] ]
##  ]]></Log>
##  <P/>
##  maps the pair <M>(x_1, x_2)</M> to <M>2v_1 + 1/2 v_3</M>
##  (where <M>v_1</M> is the first basis element of <M>V</M>,
##  and <M>v_3</M> the third), and all other pairs to zero.
##  <P/>
##  By definition, <M>0</M>-cochains are constant maps
##  <M>c( x ) = v_c \in V</M> for all <M>x \in L</M>.
##  So <M>0</M>-cochains have a different representation: they are just
##  represented by the list <C>[ v_c ]</C>.
##  <P/>
##  Cochains are constructed using the function <Ref Oper="Cochain"/>,
##  if <A>c</A> is a cochain, then its corresponding list is returned by
##  <C>ExtRepOfObj( <A>c</A> )</C>.
##  <#/GAPDoc>
##


##############################################################################
##
#C  IsCochain( <obj> )
#C  IsCochainCollection( <obj> )
##
##  <#GAPDoc Label="IsCochain">
##  <ManSection>
##  <Filt Name="IsCochain" Arg='obj' Type='Category'/>
##  <Filt Name="IsCochainCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  Categories of cochains and of collections of cochains.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsCochain", IsVector );
DeclareCategoryCollections( "IsCochain" );

#############################################################################
##
#O  Cochain( <V>, <s>, <obj> )
##
##  <#GAPDoc Label="Cochain">
##  <ManSection>
##  <Oper Name="Cochain" Arg='V, s, obj'/>
##
##  <Description>
##  Constructs a <A>s</A>-cochain given by the data in <A>obj</A>, with
##  respect to the Lie algebra module <A>V</A>. If <A>s</A> is non-zero,
##  then <A>obj</A> must be a list.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> V:= AdjointModule( L );
##  <3-dimensional left-module over <Lie algebra of dimension
##  3 over Rationals>>
##  gap> c1:= Cochain( V, 2,
##  >               [ [ [ [ 1, 3 ], -1 ] ], [ ], [ [ [ 2, 3 ], 1/2 ] ] ]);
##  <2-cochain>
##  gap> ExtRepOfObj( c1 );
##  [ [ [ [ 1, 3 ], -1 ] ], [  ], [ [ [ 2, 3 ], 1/2 ] ] ]
##  gap> c2:= Cochain( V, 0, Basis( V )[1] );
##  <0-cochain>
##  gap> ExtRepOfObj( c2 );
##  v.1
##  gap> IsCochain( c2 );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Cochain", [ IsLeftModule, IsInt, IsObject ] );

#############################################################################
##
#O  CochainSpace( <V>, <s> )
##
##  <#GAPDoc Label="CochainSpace">
##  <ManSection>
##  <Oper Name="CochainSpace" Arg='V, s'/>
##
##  <Description>
##  Returns the space of all <A>s</A>-cochains with respect to <A>V</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> V:= AdjointModule( L );;
##  gap> C:=CochainSpace( V, 2 );
##  <vector space of dimension 9 over Rationals>
##  gap> BasisVectors( Basis( C ) );
##  [ <2-cochain>, <2-cochain>, <2-cochain>, <2-cochain>, <2-cochain>,
##    <2-cochain>, <2-cochain>, <2-cochain>, <2-cochain> ]
##  gap> ExtRepOfObj( last[1] );
##  [ [ [ [ 1, 2 ], 1 ] ], [  ], [  ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "CochainSpace", [ IsAlgebraModule, IS_INT ] );

#############################################################################
##
#F  ValueCochain( <c>, <y1>, <y2>,...,<ys> )
##
##  <#GAPDoc Label="ValueCochain">
##  <ManSection>
##  <Func Name="ValueCochain" Arg='c, y1, y2,...,ys'/>
##
##  <Description>
##  Here <A>c</A> is an <C>s</C>-cochain. This function returns the value of
##  <A>c</A> when applied to the <C>s</C> elements <A>y1</A> to <A>ys</A>
##  (that lie in the Lie algebra acting on the module corresponding to
##  <A>c</A>). It is also possible to call this function with two arguments:
##  first <A>c</A> and then the list containing <C><A>y1</A>,...,<A>ys</A></C>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> V:= AdjointModule( L );;
##  gap> C:= CochainSpace( V, 2 );;
##  gap> c:= Basis( C )[1];
##  <2-cochain>
##  gap>  ValueCochain( c, Basis(L)[2], Basis(L)[1] );
##  (-1)*v.1
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ValueCochain" );

#############################################################################
##
#F  LieCoboundaryOperator( <c> )
##
##  <#GAPDoc Label="LieCoboundaryOperator">
##  <ManSection>
##  <Func Name="LieCoboundaryOperator" Arg='c'/>
##
##  <Description>
##  This is a function that takes an <C>s</C>-cochain <A>c</A>,
##  and returns an <C>s+1</C>-cochain. The coboundary operator is applied.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
##  gap> V:= AdjointModule( L );;
##  gap> C:= CochainSpace( V, 2 );;
##  gap> c:= Basis( C )[1];;
##  gap> c1:= LieCoboundaryOperator( c );
##  <3-cochain>
##  gap> c2:= LieCoboundaryOperator( c1 );
##  <4-cochain>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "LieCoboundaryOperator" );

#############################################################################
##
#O  Cocycles( <V>, <s> )
##
##  <#GAPDoc Label="Cocycles">
##  <ManSection>
##  <Oper Name="Cocycles" Arg='V, s' Label="for Lie algebra module"/>
##
##  <Description>
##  is the space of all <A>s</A>-cocycles with respect to the Lie algebra
##  module <A>V</A>. That is the kernel of the coboundary operator when
##  restricted to the space of <A>s</A>-cochains.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Cocycles", [ IsAlgebraModule, IS_INT  ] );

#############################################################################
##
#O  Coboundaries( <V>, <s> )
##
##  <#GAPDoc Label="Coboundaries">
##  <ManSection>
##  <Oper Name="Coboundaries" Arg='V, s'/>
##
##  <Description>
##  is the space of all <A>s</A>-coboundaries with respect to the Lie algebra
##  module <A>V</A>. That is the image of the coboundary operator, when applied
##  to the space of <A>s</A>-1-cochains. By definition the space of all
##  0-coboundaries is zero.
##  <Example><![CDATA[
##  gap> T:= EmptySCTable( 3, 0, "antisymmetric" );;
##  gap> SetEntrySCTable( T, 1, 2, [ 1, 3 ] );
##  gap> L:= LieAlgebraByStructureConstants( Rationals, T );;
##  gap> V:= FaithfulModule( L );
##  <left-module over <Lie algebra of dimension 3 over Rationals>>
##  gap> Cocycles( V, 2 );
##  <vector space of dimension 7 over Rationals>
##  gap> Coboundaries( V, 2 );
##  <vector space over Rationals, with 9 generators>
##  gap> Dimension( last );
##  5
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Coboundaries", [ IsAlgebraModule, IS_INT ] );


############################################################################
##
#P  IsWeylGroup( <G> )
##
##  <#GAPDoc Label="IsWeylGroup">
##  <ManSection>
##  <Prop Name="IsWeylGroup" Arg='G'/>
##
##  <Description>
##  A Weyl group is a group generated by reflections, with the attribute
##  <Ref Attr="SparseCartanMatrix"/> set.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsWeylGroup", IsGroup );
InstallTrueMethod( IsGroup, IsWeylGroup );

############################################################################
##
#A  WeylGroup( <R> )
##
##  <#GAPDoc Label="WeylGroup">
##  <ManSection>
##  <Attr Name="WeylGroup" Arg='R'/>
##
##  <Description>
##  The Weyl group of the root system <A>R</A>. It is generated by the simple
##  reflections. A simple reflection is represented by a matrix, and the
##  result of letting a simple reflection <C>m</C> act on a weight <C>w</C>
##  is obtained by <C>w*m</C>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "F", 4, Rationals );;
##  gap> R:= RootSystem( L );;
##  gap> W:= WeylGroup( R );
##  <matrix group with 4 generators>
##  gap> IsWeylGroup( W );
##  true
##  gap> SparseCartanMatrix( W );
##  [ [ [ 1, 2 ], [ 3, -1 ] ], [ [ 2, 2 ], [ 4, -1 ] ],
##    [ [ 1, -1 ], [ 3, 2 ], [ 4, -1 ] ],
##    [ [ 2, -1 ], [ 3, -2 ], [ 4, 2 ] ] ]
##  gap> g:= GeneratorsOfGroup( W );;
##  gap> [ 1, 1, 1, 1 ]*g[2];
##  [ 1, -1, 1, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "WeylGroup", IsRootSystem );

############################################################################
##
#A  SparseCartanMatrix( <W> )
##
##  <#GAPDoc Label="SparseCartanMatrix">
##  <ManSection>
##  <Attr Name="SparseCartanMatrix" Arg='W'/>
##
##  <Description>
##  This is a sparse form of the Cartan matrix of the corresponding root
##  system. If we denote the Cartan matrix by <C>C</C>, then the sparse
##  Cartan matrix of <A>W</A> is a list (of length equal to the length of
##  the Cartan matrix), where the <C>i</C>-th entry is a list consisting
##  of elements <C>[ j, C[i][j] ]</C>, where <C>j</C> is such that
##  <C>C[i][j]</C> is non-zero.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SparseCartanMatrix", IsWeylGroup );

############################################################################
##
#O  ApplySimpleReflection( <SC>, <i>, <wt> )
##
##  <#GAPDoc Label="ApplySimpleReflection">
##  <ManSection>
##  <Oper Name="ApplySimpleReflection" Arg='SC, i, wt'/>
##
##  <Description>
##  Here <A>SC</A> is the sparse Cartan matrix of a Weyl group. This
##  function applies the <A>i</A>-th simple reflection to the weight
##  <A>wt</A>, thus changing <A>wt</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "F", 4, Rationals );;
##  gap> W:= WeylGroup( RootSystem( L ) );;
##  gap> C:= SparseCartanMatrix( W );;
##  gap> w:= [ 1, 1, 1, 1 ];;
##  gap> ApplySimpleReflection( C, 2, w );
##  gap> w;
##  [ 1, -1, 1, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ApplySimpleReflection", [ IsList, IS_INT, IsList ] );

############################################################################
##
#A  LongestWeylWordPerm( <W> )
##
##  <#GAPDoc Label="LongestWeylWordPerm">
##  <ManSection>
##  <Attr Name="LongestWeylWordPerm" Arg='W'/>
##
##  <Description>
##  Let <M>g_0</M> be the longest element in the Weyl group <A>W</A>,
##  and let <M>\{ \alpha_1, \ldots, \alpha_l \}</M> be a simple system
##  of the corresponding root system.
##  Then <M>g_0</M> maps <M>\alpha_i</M> to <M>-\alpha_{{\sigma(i)}}</M>,
##  where <M>\sigma</M> is a permutation of <M>(1, \ldots, l)</M>.
##  This function returns that permutation.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "E", 6, Rationals );;
##  gap> W:= WeylGroup( RootSystem( L ) );;
##  gap> LongestWeylWordPerm( W );
##  (1,6)(3,5)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LongestWeylWordPerm", IsWeylGroup );

############################################################################
##
#O  ConjugateDominantWeight( <W>, <wt> )
#O  ConjugateDominantWeightWithWord( <W>, <wt> )
##
##  <#GAPDoc Label="ConjugateDominantWeight">
##  <ManSection>
##  <Oper Name="ConjugateDominantWeight" Arg='W, wt'/>
##  <Oper Name="ConjugateDominantWeightWithWord" Arg='W, wt'/>
##
##  <Description>
##  Here <A>W</A> is a Weyl group and <A>wt</A> a weight (i.e., a list of
##  integers). <Ref Oper="ConjugateDominantWeight"/> returns the unique
##  dominant weight conjugate to <A>wt</A> under <A>W</A>.
##  <P/>
##  <Ref Oper="ConjugateDominantWeightWithWord"/> returns a list of two
##  elements. The first of these is the dominant weight conjugate to <A>wt</A>.
##  The second element is a list of indices of simple reflections that have to
##  be applied to <A>wt</A> in order to get the dominant weight conjugate to it.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "E", 6, Rationals );;
##  gap> W:= WeylGroup( RootSystem( L ) );;
##  gap> C:= SparseCartanMatrix( W );;
##  gap> w:= [ 1, -1, 2, -2, 3, -3 ];;
##  gap> ConjugateDominantWeight( W, w );
##  [ 2, 1, 0, 0, 0, 0 ]
##  gap> c:= ConjugateDominantWeightWithWord( W, w );
##  [ [ 2, 1, 0, 0, 0, 0 ], [ 2, 4, 2, 3, 6, 5, 4, 2, 3, 1 ] ]
##  gap> for i in [1..Length(c[2])] do
##  > ApplySimpleReflection( C, c[2][i], w );
##  > od;
##  gap> w;
##  [ 2, 1, 0, 0, 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ConjugateDominantWeight", [ IsWeylGroup, IsList ] );
DeclareOperation( "ConjugateDominantWeightWithWord", [ IsWeylGroup, IsList ]);


############################################################################
##
#O  WeylOrbitIterator( <W>, <wt> )
##
##  <#GAPDoc Label="WeylOrbitIterator">
##  <ManSection>
##  <Oper Name="WeylOrbitIterator" Arg='W, wt'/>
##
##  <Description>
##  Returns an iterator for the orbit of the weight <A>wt</A> under the
##  action of the Weyl group <A>W</A>.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "E", 6, Rationals );;
##  gap> W:= WeylGroup( RootSystem( L ) );;
##  gap> orb:= WeylOrbitIterator( W, [ 1, 1, 1, 1, 1, 1 ] );
##  <iterator>
##  gap> NextIterator( orb );
##  [ 1, 1, 1, 1, 1, 1 ]
##  gap> NextIterator( orb );
##  [ -1, -1, -1, -1, -1, -1 ]
##  gap> orb:= WeylOrbitIterator( W, [ 1, 1, 1, 1, 1, 1 ] );
##  <iterator>
##  gap> k:= 0;
##  0
##  gap> while not IsDoneIterator( orb ) do
##  > w:= NextIterator( orb ); k:= k+1;
##  > od;
##  gap> k;  # this is the size of the Weyl group of E6
##  51840
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "WeylOrbitIterator", [ IsWeylGroup, IsList ] );

############################################################################
##
#A  PositiveRootsAsWeights( <R> )
##
##  <ManSection>
##  <Attr Name="PositiveRootsAsWeights" Arg='R'/>
##
##  <Description>
##  Returns the list of positive roots of <A>R</A>, represented in the basis
##  of fundamental weights.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "PositiveRootsAsWeights", IsRootSystem );

############################################################################
##
#O  DominantWeights( <R>, <maxw> )
##
##  <#GAPDoc Label="DominantWeights">
##  <ManSection>
##  <Oper Name="DominantWeights" Arg='R, maxw'/>
##
##  <Description>
##  Returns a list consisting of two lists. The first of these contains
##  the dominant weights (written on the basis of fundamental weights)
##  of the irreducible highest-weight module, with highest weight <A>maxw</A>,
##  over the Lie algebra with the root system <A>R</A>.
##  The <M>i</M>-th element of the second list is the level of the
##  <M>i</M>-th dominant weight.
##  (Where the level is defined as follows.
##  For a weight <M>\mu</M> we write
##  <M>\mu = \lambda - \sum_i k_i \alpha_i</M>, where
##  the <M>\alpha_i</M> are the simple roots,
##  and <M>\lambda</M> the highest weight.
##  Then the level of <M>\mu</M> is <M>\sum_i k_i</M>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DominantWeights", [ IsRootSystem, IsList ] );


############################################################################
##
#O  DominantCharacter( <L>, <maxw> )
#O  DominantCharacter( <R>, <maxw> )
##
##  <#GAPDoc Label="DominantCharacter">
##  <ManSection>
##  <Oper Name="DominantCharacter" Arg='L, maxw'
##   Label="for a semisimple Lie algebra and a highest weight"/>
##  <Oper Name="DominantCharacter" Arg='R, maxw'
##   Label="for a root system and a highest weight"/>
##
##  <Description>
##  For a highest weight <A>maxw</A> and a semisimple Lie algebra <A>L</A>,
##  this returns the dominant weights of the highest-weight module over
##  <A>L</A>, with highest weight <A>maxw</A>.
##  The output is a list of two lists,
##  the first list contains the dominant weights;
##  the second list contains their multiplicities.
##  <P/>
##  The first argument can also be a root system, in which case
##  the dominant character of the highest-weight module over the
##  corresponding semisimple Lie algebra is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DominantCharacter", [ IsRootSystem, IsList ] );


#############################################################################
##
#O  DecomposeTensorProduct( <L>, <w1>, <w2> )
##
##  <#GAPDoc Label="DecomposeTensorProduct">
##  <ManSection>
##  <Oper Name="DecomposeTensorProduct" Arg='L, w1, w2'/>
##
##  <Description>
##  Here <A>L</A> is a semisimple Lie algebra and <A>w1</A>, <A>w2</A> are
##  dominant weights.
##  Let <M>V_i</M> be the irreducible highest-weight module over <A>L</A>
##  with highest weight <M>w_i</M> for <M>i = 1, 2</M>.
##  Let <M>W = V_1 \otimes V_2</M>.
##  Then in general <M>W</M> is a reducible <A>L</A>-module. Now this function
##  returns a list of two lists. The first of these is the sorted list of highest
##  weights of the irreducible modules occurring in the decomposition of
##  <M>W</M> as a direct sum of irreducible modules. The second list contains
##  the multiplicities of these weights (i.e., the number of copies of
##  the irreducible module with the corresponding highest weight that occur
##  in <M>W</M>). The algorithm uses Klimyk's formula
##  (see&nbsp;<Cite Key="Klimyk68"/> or <Cite Key="Klimyk66"/>
##  for the original Russian version).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DecomposeTensorProduct", [ IsLieAlgebra, IsList, IsList ] );


#############################################################################
##
#O  DimensionOfHighestWeightModule( <L>, <w> )
##
##  <#GAPDoc Label="DimensionOfHighestWeightModule">
##  <ManSection>
##  <Oper Name="DimensionOfHighestWeightModule" Arg='L, w'/>
##
##  <Description>
##  Here <A>L</A> is a semisimple Lie algebra, and <A>w</A> a dominant weight.
##  This function returns the dimension of the highest-weight module
##  over <A>L</A> with highest weight <A>w</A>. The algorithm
##  uses Weyl's dimension formula.
##  <Example><![CDATA[
##  gap> L:= SimpleLieAlgebra( "F", 4, Rationals );;
##  gap> R:= RootSystem( L );;
##  gap> DominantWeights( R, [ 1, 1, 0, 0 ] );
##  [ [ [ 1, 1, 0, 0 ], [ 2, 0, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 1, 0, 0 ],
##        [ 1, 0, 0, 0 ], [ 0, 0, 0, 0 ] ], [ 0, 3, 4, 8, 11, 19 ] ]
##  gap> DominantCharacter( L, [ 1, 1, 0, 0 ] );
##  [ [ [ 1, 1, 0, 0 ], [ 2, 0, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 1, 0, 0 ],
##        [ 1, 0, 0, 0 ], [ 0, 0, 0, 0 ] ], [ 1, 1, 4, 6, 14, 21 ] ]
##  gap> DecomposeTensorProduct( L, [ 1, 0, 0, 0 ], [ 0, 0, 1, 0 ] );
##  [ [ [ 0, 0, 0, 1 ], [ 0, 0, 1, 0 ], [ 0, 1, 0, 0 ], [ 1, 0, 0, 0 ],
##        [ 1, 0, 1, 0 ], [ 1, 1, 0, 0 ], [ 2, 0, 0, 0 ] ],
##    [ 1, 1, 1, 1, 1, 1, 1 ] ]
##  gap> DimensionOfHighestWeightModule( L, [ 1, 2, 3, 4 ] );
##  79316832731136
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "DimensionOfHighestWeightModule", [ IsLieAlgebra, IsList ] );


#############################################################################
##
##  <#GAPDoc Label="[2]{lierep}">
##  Let <M>L</M> be a semisimple Lie algebra over a field of characteristic
##  <M>0</M>, and let <M>R</M> be its root system.
##  For a positive root <M>\alpha</M> we let <M>x_{\alpha}</M> and
##  <M>y_{\alpha}</M> be positive and negative root vectors,
##  respectively, both from a fixed Chevalley basis of <M>L</M>. Furthermore,
##  <M>h_1, \ldots, h_l</M> are the Cartan elements from the same Chevalley
##  basis. Also we set
##  <Display Mode="M">
##  x_{\alpha}^{(n)} = {{x_{\alpha}^n \over n!}},
##  y_{\alpha}^{(n)} = {{y_{\alpha}^n \over n!}} .
##  </Display>
##  Furthermore, let <M>\alpha_1, \ldots, \alpha_s</M> denote the positive
##  roots of <M>R</M>.
##  For multi-indices <M>N = (n_1, \ldots, n_s)</M>,
##  <M>M = (m_1, \ldots, m_s)</M>
##  and <M>K = (k_1, \ldots, k_s)</M> (where <M>n_i, m_i, k_i \geq 0</M>) set
##  <Table Align="lcl">
##  <Row>
##    <Item><M>x^N</M></Item>
##    <Item>=</Item>
##    <Item><M>x_{{\alpha_1}}^{(n_1)} \cdots x_{{\alpha_s}}^{(n_s)}</M>,</Item>
##  </Row>
##  <Row>
##    <Item><M>y^M</M></Item>
##    <Item>=</Item>
##    <Item><M>y_{{\alpha_1}}^{(m_1)} \cdots y_{{\alpha_s}}^{(m_s)}</M>,</Item>
##  </Row>
##  <Row>
##    <Item><M>h^K</M></Item>
##    <Item>=</Item>
##    <Item><M>{{h_1 \choose k_1}} \cdots {{h_l \choose k_l}}</M></Item>
##  </Row>
##  </Table>
##  Then by a theorem of Kostant, the <M>x_{\alpha}^{(n)}</M> and
##  <M>y_{\alpha}^{(n)}</M> generate a subring of the universal enveloping algebra
##  <M>U(L)</M> spanned (as a free <M>Z</M>-module) by the elements
##  <Display Mode="M">
##  y^M h^K x^N
##  </Display>
##  (see, e.g., <Cite Key="Hum72"/> or <Cite Key="Hum78" Where="Section 26"/>)
##  So by the Poincare-Birkhoff-Witt theorem
##  this subring is a lattice in <M>U(L)</M>. Furthermore, this lattice is
##  invariant under the <M>x_{\alpha}^{(n)}</M> and <M>y_{\alpha}^{(n)}</M>.
##  Therefore, it is called an admissible lattice in <M>U(L)</M>.
##  <P/>
##  The next functions enable us to construct the generators of such an
##  admissible lattice.
##  <#/GAPDoc>
##


##############################################################################
##
#C  IsUEALatticeElement( <obj> )
#C  IsUEALatticeElementCollection( <obj> )
#C  IsUEALatticeElementFamily( <fam> )
##
##  <#GAPDoc Label="IsUEALatticeElement">
##  <ManSection>
##  <Filt Name="IsUEALatticeElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsUEALatticeElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsUEALatticeElementFamily" Arg='fam' Type='Category'/>
##
##  <Description>
##  is the category of elements of an admissible lattice in the universal
##  enveloping algebra of a semisimple Lie algebra <C>L</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsUEALatticeElement", IsVector and IsRingElement and
                     IsMultiplicativeElementWithOne );
DeclareCategoryCollections( "IsUEALatticeElement" );
DeclareCategoryFamily( "IsUEALatticeElement" );


##############################################################################
##
#A  LatticeGeneratorsInUEA( <L> )
##
##  <#GAPDoc Label="LatticeGeneratorsInUEA">
##  <ManSection>
##  <Attr Name="LatticeGeneratorsInUEA" Arg='L'/>
##
##  <Description>
##  Here <A>L</A> must be a semisimple Lie algebra of characteristic <M>0</M>.
##  This function returns a list of generators of an admissible lattice
##  in the universal enveloping algebra of <A>L</A>, relative to the
##  Chevalley basis contained in <C>ChevalleyBasis( <A>L</A> )</C>
##  (see&nbsp;<Ref Attr="ChevalleyBasis"/>). First are listed the negative
##  root vectors (denoted by <M>y_1, \ldots, y_s</M>),
##  then the positive root vectors (denoted by <M>x_1, \ldots, x_s</M>).
##  At the end of the list there are the Cartan elements. They are printed as
##  <C>( hi/1 )</C>, which means
##  <Display Mode="M">
##  {{h_i \choose 1}}.
##  </Display>
##  In general the printed form <C>( hi/ k )</C> means
##  <Display Mode="M">
##  {{h_i \choose k}}.
##  </Display>
##  <P/>
##  Also <M>y_i^{(m)}</M> is printed as <C>yi^(m)</C>, which means that entering
##  <C>yi^m</C> at the &GAP; prompt results in the output <C>m!*yi^(m)</C>.
##  <P/>
##  Products of lattice generators are collected using the following order:
##  first come the <M>y_i^{(m_i)}</M>
##  (in the same order as the positive roots),
##  then the <M>{h_i \choose k_i}</M>,
##  and then the <M>x_i^{(n_i)}</M>
##  (in the same order as the positive roots).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LatticeGeneratorsInUEA", IsLieAlgebra );

##############################################################################
##
#F  CollectUEALatticeElement( <noPosR>, <BH>, <f>, <vars>, <Rvecs>, <RT>,
##                                                          <posR>, <lst> )
##
##  <ManSection>
##  <Func Name="CollectUEALatticeElement" Arg='noPosR, BH, f, vars, Rvecs, RT, posR, lst'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "CollectUEALatticeElement" );


##############################################################################
##
#C  IsWeightRepElement( <obj> )
#C  IsWeightRepElementCollection( <obj> )
#C  IsWeightRepElementFamily( <fam> )
##
##  <#GAPDoc Label="IsWeightRepElement">
##  <ManSection>
##  <Filt Name="IsWeightRepElement" Arg='obj' Type='Category'/>
##  <Filt Name="IsWeightRepElementCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsWeightRepElementFamily" Arg='fam' Type='Category'/>
##
##  <Description>
##  Is a category of vectors, that is used to construct elements of
##  highest-weight modules (by <Ref Oper="HighestWeightModule"/>).
##  <P/>
##  <C>WeightRepElement</C>s are represented by a list of the form
##  <C>[ v1, c1, v2, c2, ....]</C>, where the <C>vi</C> are basis vectors,
##  and the <C>ci</C> are coefficients. Furthermore a basis vector <C>v</C>
##  is a weight vector. It is represented by a list of the form
##  <C>[ k, mon, wt ]</C>, where <C>k</C> is an integer (the basis vectors
##  are numbered from <M>1</M> to <M>\dim V</M>, where <M>V</M> is the highest
##  weight module), <C>mon</C> is an <C>UEALatticeElement</C> (which means
##  that the result of applying <C>mon</C> to a highest weight vector is <C>v</C>;
##  see&nbsp;<Ref Filt="IsUEALatticeElement"/>) and <C>wt</C> is the weight
##  of <C>v</C>. A <C>WeightRepElement</C> is printed as <C>mon*v0</C>,
##  where <C>v0</C> denotes a fixed highest weight vector.
##  <P/>
##  If <C>v</C> is a <C>WeightRepElement</C>, then <C>ExtRepOfObj( v )</C>
##  returns the corresponding list, and if <C>list</C> is such a list and
##  <A>fam</A> a <C>WeightRepElementFamily</C>, then
##  <C>ObjByExtRep( <A>list</A>, <A>fam</A> )</C> returns the corresponding
##  <C>WeightRepElement</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsWeightRepElement", IsVector );
DeclareCategoryCollections( "IsWeightRepElement" );
DeclareCategoryFamily( "IsWeightRepElement" );

##############################################################################
##
#C  IsBasisOfWeightRepElementSpace( <B> )
##
##  <ManSection>
##  <Filt Name="IsBasisOfWeightRepElementSpace" Arg='B' Type='Category'/>
##
##  <Description>
##  A basis that lies in this category is a basis of a space of weight
##  rep elements. If a basis <A>B</A> lies in this category, then it has the
##  record components <C><A>B</A>!.echelonBasis</C> (a list of basis vectors of
##  the same module as where <A>B</A> is a basis of, but in echelon form),
##  <C><A>B</A>!.heads</C> (if <C><A>B</A>!.heads[i] = k</C>, then the number of the first
##  weight vector of <C><A>B</A>!.echelonBasis[i]</C> is <C>k</C>; recall that all weight
##  vectors carry a number), and <C><A>B</A>!.baseChange</C> (if <C><A>B</A>!.baseChange[i]=
##  [ [m1,c1],...,[ms,cs] ]</C> then the <C>i</C>-th element of <C><A>B</A>!.echelonBasis</C>
##  is of the form <M>c1 v_{m1}+\cdots +cs v_{ms}</M>, where the <M>v_j</M> are the
##  basis vectors of <A>B</A>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsBasisOfWeightRepElementSpace", IsBasis );


#############################################################################
##
#F  HighestWeightModule( <L>, <wt> )
##
##  <#GAPDoc Label="HighestWeightModule">
##  <ManSection>
##  <Oper Name="HighestWeightModule" Arg='L, wt'/>
##
##  <Description>
##  returns the highest weight module with highest weight <A>wt</A> of the
##  semisimple Lie algebra <A>L</A> of characteristic <M>0</M>.
##  <P/>
##  Note that the elements of such a module lie in the category
##  <Ref Filt="IsLeftAlgebraModuleElement"/> (and in particular they do not
##  lie in the category <Ref Filt="IsWeightRepElement"/>). However, if
##  <C>v</C> is an element of such a module, then <C>ExtRepOfObj( v )</C>
##  is a <C>WeightRepElement</C>.
##  <P/>
##  Note that for the following examples of this chapter we increase the line
##  length limit from its default value 80 to 81 in order to make some long
##  output expressions fit into the lines.
##  <P/>
##  <Example><![CDATA[
##  gap> K1:= SimpleLieAlgebra( "G", 2, Rationals );;
##  gap> K2:= SimpleLieAlgebra( "B", 2, Rationals );;
##  gap> L:= DirectSumOfAlgebras( K1, K2 );
##  <Lie algebra of dimension 24 over Rationals>
##  gap> V:= HighestWeightModule( L, [ 0, 1, 1, 1 ] );
##  <224-dimensional left-module over <Lie algebra of dimension
##  24 over Rationals>>
##  gap> vv:= GeneratorsOfLeftModule( V );;
##  gap> vv[100];
##  y5*y7*y10*v0
##  gap> e:= ExtRepOfObj( vv[100] );
##  y5*y7*y10*v0
##  gap> ExtRepOfObj( e );
##  [ [ 100, y5*y7*y10, [ -3, 2, -1, 1 ] ], 1 ]
##  gap> Basis(L)[17]^vv[100];
##  -1*y5*y7*y8*v0-1*y5*y9*v0
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "HighestWeightModule", [ IsAlgebra, IsList ] );

#############################################################################
##
#F  LeadingUEALatticeMonomial( <novar>, <f> )
##
##  <ManSection>
##  <Func Name="LeadingUEALatticeMonomial" Arg='novar, f'/>
##
##  <Description>
##  Here <A>f</A> is an <C>UEALatticeElement</C>, and <A>novar</A> the number of generators
##  of the algebra containing <A>f</A>. This function returns a list of four
##  elements. The first element is the leading monomial of <A>f</A> (as it
##  occurs in the external representation of <A>f</A>). The second element is the
##  leading monomial of <A>f</A> represented as a list of length <A>novar</A>. The
##  i-th entry in this list is the exponent of the i-th generator in
##  the leading monomial. The third and fourth elements are, respectively,
##  the coefficient of the leading monomial and the index at which it
##  occurs in <A>f</A> (so that <A>f</A>!.[1][ind] is equal to the first element of
##  the output).
##  </Description>
##  </ManSection>
##
DeclareOperation( "LeadingUEALatticeMonomial",
                                   [ IsInt, IsUEALatticeElement ] );

##############################################################################
##
#F  LeftReduceUEALatticeElement( <novar>, <G>, <lms>, <p> )
##
##  <ManSection>
##  <Func Name="LeftReduceUEALatticeElement" Arg='novar, G, lms, p'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "LeftReduceUEALatticeElement" );


##############################################################################
##
#F  ExtendRepresentation( <L>, <newelts>, <I>, <mats> )
##
##  <ManSection>
##  <Func Name="ExtendRepresentation" Arg='L, newelts, I, mats'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ExtendRepresentation" );


#############################################################################
##
#F  IsCochainsSpace( <V> )
##
##  <ManSection>
##  <Func Name="IsCochainsSpace" Arg='V'/>
##
##  <Description>
##  ...
##  </Description>
##  </ManSection>
##
DeclareHandlingByNiceBasis( "IsCochainsSpace",
    "for free left modules of cochains" );


#############################################################################
##
#V  InfoSearchTable
##
##  <ManSection>
##  <InfoClass Name="InfoSearchTable"/>
##
##  <Description>
##  is the info class for methods and functions applicable to search tables.
##  (see&nbsp;<Ref Sect="Info Functions"/>).
##  </Description>
##  </ManSection>
##
DeclareInfoClass( "InfoSearchTable" );

#############################################################################
##
#C  IsSearchTable( <obj> )
##
##  <ManSection>
##  <Filt Name="IsSearchTable" Arg='obj' Type='Category'/>
##
##  <Description>
##  A search table stores elements and provides methods for efficient
##  search of particular kinds of elements.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsSearchTable", IsObject );


#############################################################################
##
#O  Search( <T>, <key> )
##
##  <ManSection>
##  <Oper Name="Search" Arg='T, key'/>
##
##  <Description>
##  is the operation for finding element labelled with <A>key</A> in table <A>T</A>.
##  The return value depends on the specific implementation of the search
##  table, but this will always return <K>fail</K> if an element in <M>T</M> does not
##  satisfy the necessary criterion for <A>key</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "Search", [ IsSearchTable, IsObject ] );

#############################################################################
##
#O  Insert( <T>, <key>, <data> )
##
##  <ManSection>
##  <Oper Name="Insert" Arg='T, key, data'/>
##
##  <Description>
##  is the operation for inserting data into the search table.
##  The data <A>data</A> is stored in the table under the key <A>key</A>.
##  The operation returns <K>true</K> if the insertion occurs, and
##  <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##
DeclareOperation( "Insert", [ IsSearchTable, IsObject, IsObject ] );


#############################################################################
##
#C  IsVectorSearchTable( <obj> )
##
##  <ManSection>
##  <Filt Name="IsVectorSearchTable" Arg='obj' Type='Category'/>
##
##  <Description>
##  is a search table encoding integer vectors representing a
##  variable/exponent pair for monomials in a commutative polynomial ring
##  or in a semisimple Lie algebra given by a PBW basis.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsVectorSearchTable", IsSearchTable );


#############################################################################
##
#F  VectorSearchTable( )
#F  VectorSearchTable( <keys>, <data> )
##
##  <ManSection>
##  <Func Name="VectorSearchTable" Arg=''/>
##  <Func Name="VectorSearchTable" Arg='keys, data'/>
##
##  <Description>
##  construct an empty search table or a search table containing <A>data</A>
##  keyed by <A>keys</A>. The list <A>keys</A> must contain integer lists which are
##  interpreted as exponents for variables.
##  <P/>
##  The lists <A>keys</A> and <A>data</A> must be the same length as well.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "VectorSearchTable" );
