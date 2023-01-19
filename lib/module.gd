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
##  This file declares the operations for left modules, right modules,
##  and bimodules.
##


#############################################################################
##
#C  IsLeftOperatorAdditiveGroup( <D> )
##
##  <#GAPDoc Label="IsLeftOperatorAdditiveGroup">
##  <ManSection>
##  <Filt Name="IsLeftOperatorAdditiveGroup" Arg='D' Type='Category'/>
##
##  <Description>
##  A domain <A>D</A> lies in <C>IsLeftOperatorAdditiveGroup</C>
##  if it is an additive group that is closed under scalar multiplication
##  from the left, and such that
##  <M>\lambda * ( x + y ) = \lambda * x + \lambda * y</M>
##  for all scalars <M>\lambda</M> and elements <M>x, y \in D</M>
##  (here and below by scalars we mean elements of a domain acting
##  on <A>D</A> from left or right as appropriate).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsLeftOperatorAdditiveGroup",
        IsAdditiveGroup
    and IsExtLSet
    and IsDistributiveLOpDSum );


#############################################################################
##
#C  IsLeftModule( <M> )
##
##  <#GAPDoc Label="IsLeftModule">
##  <ManSection>
##  <Filt Name="IsLeftModule" Arg='M' Type='Category'/>
##
##  <Description>
##  A domain <A>M</A> lies in <C>IsLeftModule</C>
##  if it lies in <C>IsLeftOperatorAdditiveGroup</C>,
##  <E>and</E> the set of scalars forms a ring,
##  <E>and</E> <M>(\lambda + \mu) * x = \lambda * x + \mu * x</M>
##  for scalars <M>\lambda, \mu</M> and <M>x \in M</M>,
##  <E>and</E> scalar multiplication satisfies
##  <M>\lambda * (\mu * x) = (\lambda * \mu) * x</M>
##  for scalars <M>\lambda, \mu</M> and <M>x \in M</M>.
##  <Example><![CDATA[
##  gap> V:= FullRowSpace( Rationals, 3 );
##  ( Rationals^3 )
##  gap> IsLeftModule( V );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsLeftModule",
        IsLeftOperatorAdditiveGroup
    and IsLeftActedOnByRing
    and IsDistributiveLOpESum
    and IsAssociativeLOpEProd
    and IsTrivialLOpEOne );


#############################################################################
##
#C  IsRightOperatorAdditiveGroup( <D> )
##
##  <#GAPDoc Label="IsRightOperatorAdditiveGroup">
##  <ManSection>
##  <Filt Name="IsRightOperatorAdditiveGroup" Arg='D' Type='Category'/>
##
##  <Description>
##  A domain <A>D</A> lies in <C>IsRightOperatorAdditiveGroup</C>
##  if it is an additive group that is closed under scalar multiplication
##  from the right,
##  and such that <M>( x + y ) * \lambda = x * \lambda + y * \lambda</M>
##  for all scalars <M>\lambda</M> and elements <M>x, y \in D</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsRightOperatorAdditiveGroup",
        IsAdditiveGroup
    and IsExtRSet
    and IsDistributiveROpDSum );


#############################################################################
##
#C  IsRightModule( <M> )
##
##  <#GAPDoc Label="IsRightModule">
##  <ManSection>
##  <Filt Name="IsRightModule" Arg='M' Type='Category'/>
##
##  <Description>
##  A domain <A>M</A> lies in <C>IsRightModule</C> if it lies in
##  <C>IsRightOperatorAdditiveGroup</C>,
##  <E>and</E> the set of scalars forms a ring,
##  <E>and</E> <M>x * (\lambda + \mu) = x * \lambda + x * \mu</M>
##  for scalars <M>\lambda, \mu</M> and <M>x \in M</M>,
##  <E>and</E> scalar multiplication satisfies
##  <M>(x * \mu) * \lambda = x * (\mu * \lambda)</M>
##  for scalars <M>\lambda, \mu</M> and <M>x \in M</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsRightModule",
        IsRightOperatorAdditiveGroup
    and IsRightActedOnByRing
    and IsDistributiveROpESum
    and IsAssociativeROpEProd
    and IsTrivialROpEOne );


#############################################################################
##
#C  IsFreeLeftModule( <M> )
##
##  <#GAPDoc Label="IsFreeLeftModule">
##  <ManSection>
##  <Filt Name="IsFreeLeftModule" Arg='M' Type='Category'/>
##
##  <Description>
##  A left module is free as module if it is isomorphic to a direct sum of
##  copies of its left acting domain.
##  <P/>
##  Free left modules can have bases.
##  <P/>
##  The characteristic (see&nbsp;<Ref Attr="Characteristic"/>) of a
##  free left module is defined as the characteristic of its left acting
##  domain (see&nbsp;<Ref Attr="LeftActingDomain"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsFreeLeftModule", IsLeftModule );


#############################################################################
##
#P  IsFiniteDimensional( <M> )
##
##  <#GAPDoc Label="IsFiniteDimensional">
##  <ManSection>
##  <Prop Name="IsFiniteDimensional" Arg='M'/>
##
##  <Description>
##  is <K>true</K> if <A>M</A> is a free left module that is finite dimensional
##  over its left acting domain, and <K>false</K> otherwise.
##  <Example><![CDATA[
##  gap> V:= FreeLeftModule( Rationals, [ [ 1, 0 ], [ 0, 1 ], [ 1, 1 ] ] );;
##  gap> IsFiniteDimensional( V );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFiniteDimensional", IsFreeLeftModule );

InstallSubsetMaintenance( IsFiniteDimensional,
    IsFreeLeftModule and IsFiniteDimensional, IsFreeLeftModule );

InstallFactorMaintenance( IsFiniteDimensional,
    IsFreeLeftModule and IsFiniteDimensional,
    IsObject, IsFreeLeftModule );

InstallTrueMethod( IsFiniteDimensional, IsFreeLeftModule and IsFinite );


#############################################################################
##
#P  IsFullRowModule( <M> )
##
##  <#GAPDoc Label="IsFullRowModule">
##  <ManSection>
##  <Prop Name="IsFullRowModule" Arg='M'/>
##
##  <Description>
##  A <E>full row module</E> is a module <M>R^n</M>,
##  for a ring <M>R</M> and a nonnegative integer <M>n</M>.
##  <P/>
##  More precisely, a full row module is a free left module over a ring
##  <M>R</M> such that the elements are row vectors of the same length
##  <M>n</M> and with entries in <M>R</M> and such that the dimension is
##  equal to <M>n</M>.
##  <P/>
##  Several functions delegate their tasks to full row modules,
##  for example <Ref Oper="Iterator"/> and <Ref Attr="Enumerator"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullRowModule", IsFreeLeftModule, 20 );


#############################################################################
##
#P  IsFullMatrixModule( <M> )
##
##  <#GAPDoc Label="IsFullMatrixModule">
##  <ManSection>
##  <Prop Name="IsFullMatrixModule" Arg='M'/>
##
##  <Description>
##  A <E>full matrix module</E> is a module <M>R^{{[m,n]}}</M>,
##  for a ring <M>R</M> and two nonnegative integers <M>m</M>, <M>n</M>.
##  <P/>
##  More precisely, a full matrix module is a free left module over a ring
##  <M>R</M> such that the elements are <M>m</M> by <M>n</M> matrices with
##  entries in <M>R</M> and such that the dimension is equal to <M>m n</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullMatrixModule", IsFreeLeftModule, 20 );


#############################################################################
##
#C  IsHandledByNiceBasis( <M> )
##
##  <#GAPDoc Label="IsHandledByNiceBasis">
##  <ManSection>
##  <Filt Name="IsHandledByNiceBasis" Arg='M' Type='Category'/>
##
##  <Description>
##  For a free left module <A>M</A> in this category, essentially all operations
##  are performed using a <Q>nicer</Q> free left module,
##  which is usually a row module.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsHandledByNiceBasis", IsFreeLeftModule, 3 );
# We want that 'IsFreeLeftModule and IsHandledByNiceBasis' has a higher rank
# than 'IsFreeLeftModule and IsFiniteDimensional'.
# (There are concurrent '\in' methods for the two situations.)


#############################################################################
##
#A  Dimension( <M> )
##
##  <#GAPDoc Label="Dimension">
##  <ManSection>
##  <Attr Name="Dimension" Arg='M'/>
##
##  <Description>
##  A free left module has dimension <M>n</M> if it is isomorphic to a direct sum
##  of <M>n</M> copies of its left acting domain.
##  <P/>
##  (We do <E>not</E> mark <Ref Attr="Dimension"/> as invariant under isomorphisms
##  since we want to call <Ref Oper="UseIsomorphismRelation"/> also for free left modules
##  over different left acting domains.)
##  <Example><![CDATA[
##  gap> V:= FreeLeftModule( Rationals, [ [ 1, 0 ], [ 0, 1 ], [ 1, 1 ] ] );;
##  gap> Dimension( V );
##  2
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "Dimension", IsFreeLeftModule );


############################################################################
##
#A  GeneratorsOfLeftOperatorAdditiveGroup( <D> )
##
##  <#GAPDoc Label="GeneratorsOfLeftOperatorAdditiveGroup">
##  <ManSection>
##  <Attr Name="GeneratorsOfLeftOperatorAdditiveGroup" Arg='D'/>
##
##  <Description>
##  returns a list of elements of <A>D</A> that generates <A>D</A> as a left operator
##  additive group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfLeftOperatorAdditiveGroup",
    IsLeftOperatorAdditiveGroup );


############################################################################
##
#A  GeneratorsOfLeftModule( <M> )
##
##  <#GAPDoc Label="GeneratorsOfLeftModule">
##  <ManSection>
##  <Attr Name="GeneratorsOfLeftModule" Arg='M'/>
##
##  <Description>
##  returns a list of elements of <A>M</A> that generate <A>M</A> as a left module.
##  <Example><![CDATA[
##  gap> V:= FullRowSpace( Rationals, 3 );;
##  gap> GeneratorsOfLeftModule( V );
##  [ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "GeneratorsOfLeftModule",
    GeneratorsOfLeftOperatorAdditiveGroup );


#############################################################################
##
#A  GeneratorsOfRightOperatorAdditiveGroup( <D> )
##
##  <#GAPDoc Label="GeneratorsOfRightOperatorAdditiveGroup">
##  <ManSection>
##  <Attr Name="GeneratorsOfRightOperatorAdditiveGroup" Arg='D'/>
##
##  <Description>
##  returns a list of elements of <A>D</A> that generates <A>D</A> as a right operator
##  additive group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "GeneratorsOfRightOperatorAdditiveGroup",
    IsRightOperatorAdditiveGroup );


#############################################################################
##
#A  GeneratorsOfRightModule( <M> )
##
##  <#GAPDoc Label="GeneratorsOfRightModule">
##  <ManSection>
##  <Attr Name="GeneratorsOfRightModule" Arg='M'/>
##
##  <Description>
##  returns a list of elements of <A>M</A> that generate <A>M</A> as a left module.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "GeneratorsOfRightModule",
    GeneratorsOfRightOperatorAdditiveGroup );


#############################################################################
##
#A  TrivialSubmodule( <M> )
##
##  <#GAPDoc Label="TrivialSubmodule">
##  <ManSection>
##  <Attr Name="TrivialSubmodule" Arg='M'/>
##
##  <Description>
##  returns the zero submodule of <A>M</A>.
##  <Example><![CDATA[
##  gap> V:= LeftModuleByGenerators(Rationals, [[ 1, 0, 0 ], [ 0, 1, 0 ]]);;
##  gap> TrivialSubmodule( V );
##  <vector space of dimension 0 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr( "TrivialSubmodule", TrivialSubadditiveMagmaWithZero );


#############################################################################
##
#O  AsLeftModule( <R>, <D> )
##
##  <#GAPDoc Label="AsLeftModule">
##  <ManSection>
##  <Oper Name="AsLeftModule" Arg='R, D'/>
##
##  <Description>
##  if the domain <A>D</A> forms an additive group and is closed under left
##  multiplication by the elements of <A>R</A>, then <C>AsLeftModule( <A>R</A>, <A>D</A> )</C>
##  returns the domain <A>D</A> viewed as a left module.
##  <Example><![CDATA[
##  gap> coll:= [[0*Z(2),0*Z(2)], [Z(2),0*Z(2)], [0*Z(2),Z(2)], [Z(2),Z(2)]];
##  [ [ 0*Z(2), 0*Z(2) ], [ Z(2)^0, 0*Z(2) ], [ 0*Z(2), Z(2)^0 ],
##    [ Z(2)^0, Z(2)^0 ] ]
##  gap> AsLeftModule( GF(2), coll );
##  <vector space of dimension 2 over GF(2)>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AsLeftModule", [ IsRing, IsCollection ] );


#############################################################################
##
#O  ClosureLeftModule( <M>, <m> )
##
##  <#GAPDoc Label="ClosureLeftModule">
##  <ManSection>
##  <Oper Name="ClosureLeftModule" Arg='M, m'/>
##
##  <Description>
##  is the left module generated by the left module generators of <A>M</A> and the
##  element <A>m</A>.
##  <Example><![CDATA[
##  gap> V:= LeftModuleByGenerators(Rationals, [ [ 1, 0, 0 ], [ 0, 1, 0 ] ]);
##  <vector space over Rationals, with 2 generators>
##  gap> ClosureLeftModule( V, [ 1, 1, 1 ] );
##  <vector space over Rationals, with 3 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ClosureLeftModule", [ IsLeftModule, IsVector ] );


#############################################################################
##
#O  LeftModuleByGenerators( <R>, <gens>[, <zero>] )
##
##  <#GAPDoc Label="LeftModuleByGenerators">
##  <ManSection>
##  <Oper Name="LeftModuleByGenerators" Arg='R, gens[, zero]'/>
##
##  <Description>
##  returns the left module over <A>R</A> generated by <A>gens</A>.
##  <Example><![CDATA[
##  gap> coll:= [ [Z(2),0*Z(2)], [0*Z(2),Z(2)], [Z(2),Z(2)] ];;
##  gap> V:= LeftModuleByGenerators( GF(16), coll );
##  <vector space over GF(2^4), with 3 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "LeftModuleByGenerators", [ IsRing, IsCollection ] );
DeclareOperation( "LeftModuleByGenerators",
    [ IsRing, IsListOrCollection, IsObject ] );


#############################################################################
##
#O  UseBasis( <V>, <gens> )
##
##  <#GAPDoc Label="UseBasis">
##  <ManSection>
##  <Oper Name="UseBasis" Arg='V, gens'/>
##
##  <Description>
##  The vectors in the list <A>gens</A> are known to form a basis of the
##  free left module <A>V</A>.
##  <Ref Oper="UseBasis"/> stores information in <A>V</A> that can be derived form this fact,
##  namely
##  <List>
##  <Item>
##    <A>gens</A> are stored as left module generators if no such generators were
##    bound (this is useful especially if <A>V</A> is an algebra),
##  </Item>
##  <Item>
##    the dimension of <A>V</A> is stored.
##  </Item>
##  </List>
##  <Example><![CDATA[
##  gap> V:= FreeLeftModule( Rationals, [ [ 1, 0 ], [ 0, 1 ], [ 1, 1 ] ] );;
##  gap> UseBasis( V, [ [ 1, 0 ], [ 1, 1 ] ] );
##  gap> V;  # now V knows its dimension
##  <vector space of dimension 2 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "UseBasis", [ IsFreeLeftModule, IsHomogeneousList ] );


#############################################################################
##
#F  FreeLeftModule( <R>, <gens>[, <zero>][, "basis"] )
##
##  <#GAPDoc Label="FreeLeftModule">
##  <ManSection>
##  <Func Name="FreeLeftModule" Arg='R, gens[, zero][, "basis"]'/>
##
##  <Description>
##  <C>FreeLeftModule( <A>R</A>, <A>gens</A> )</C> is the free left module
##  over the ring <A>R</A>, generated by the vectors in the collection
##  <A>gens</A>.
##  <P/>
##  If there are three arguments, a ring <A>R</A> and a collection
##  <A>gens</A> and an element <A>zero</A>,
##  then <C>FreeLeftModule( <A>R</A>, <A>gens</A>, <A>zero</A> )</C> is the
##  <A>R</A>-free left module generated by <A>gens</A>,
##  with zero element <A>zero</A>.
##  <P/>
##  If the last argument is the string <C>"basis"</C> then the vectors in
##  <A>gens</A> are known to form a basis of the free module.
##  <P/>
##  It should be noted that the generators <A>gens</A> must be vectors,
##  that is, they must support an addition and a scalar action of <A>R</A>
##  via left multiplication.
##  (See also Section&nbsp;<Ref Sect="Constructing Domains"/>
##  for the general meaning of <Q>generators</Q> in &GAP;.)
##  In particular, <Ref Func="FreeLeftModule"/> is <E>not</E> an equivalent
##  of commands such as <Ref Func="FreeGroup" Label="for given rank"/>
##  in the sense of a constructor of a free group on abstract generators.
##  Such a construction seems to be unnecessary for vector spaces,
##  for that one can use for example row spaces
##  (see&nbsp;<Ref Func="FullRowSpace"/>) in the finite dimensional case
##  and polynomial rings
##  (see&nbsp;<Ref Oper="PolynomialRing" Label="for a ring and a rank (and an exclusion list)"/>)
##  in the infinite dimensional case.
##  Moreover, the definition of a <Q>natural</Q> addition for elements of a
##  given magma (for example a permutation group) is possible via the
##  construction of magma rings (see Chapter <Ref Chap="Magma Rings"/>).
##  <Example><![CDATA[
##  gap> V:= FreeLeftModule(Rationals, [[ 1, 0, 0 ], [ 0, 1, 0 ]], "basis");
##  <vector space of dimension 2 over Rationals>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FreeLeftModule" );


#############################################################################
##
#F  FullRowModule( <R>, <n> )
##
##  <#GAPDoc Label="FullRowModule">
##  <ManSection>
##  <Func Name="FullRowModule" Arg='R, n'/>
##
##  <Description>
##  is the row module <C><A>R</A>^<A>n</A></C>,
##  for a ring <A>R</A> and a nonnegative integer <A>n</A>.
##  <Example><![CDATA[
##  gap> V:= FullRowModule( Integers, 5 );
##  ( Integers^5 )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FullRowModule" );


#############################################################################
##
#F  FullMatrixModule( <R>, <m>, <n> )
##
##  <#GAPDoc Label="FullMatrixModule">
##  <ManSection>
##  <Func Name="FullMatrixModule" Arg='R, m, n'/>
##
##  <Description>
##  is the matrix module <C><A>R</A>^[<A>m</A>,<A>n</A>]</C>,
##  for a ring <A>R</A> and nonnegative integers <A>m</A> and <A>n</A>.
##  <Example><![CDATA[
##  gap> FullMatrixModule( GaussianIntegers, 3, 6 );
##  ( GaussianIntegers^[ 3, 6 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "FullMatrixModule" );


#############################################################################
##
#F  StandardGeneratorsOfFullMatrixModule( <M> )
##
##  <ManSection>
##  <Func Name="StandardGeneratorsOfFullMatrixModule" Arg='M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "StandardGeneratorsOfFullMatrixModule" );


#############################################################################
##
#F  Submodule( <M>, <gens>[, "basis"] )  submodule of <M> generated by <gens>
##
##  <#GAPDoc Label="Submodule">
##  <ManSection>
##  <Func Name="Submodule" Arg='M, gens[, "basis"]'/>
##
##  <Description>
##  is the left module generated by the collection <A>gens</A>,
##  with parent module <A>M</A>.
##  If the string <C>"basis"</C> is entered as the third argument then
##  the submodule of <A>M</A> is created for which the list <A>gens</A>
##  is known to be a list of basis vectors;
##  in this case, it is <E>not</E> checked whether <A>gens</A> really is
##  linearly independent and whether all in <A>gens</A> lie in <A>M</A>.
##  <Example><![CDATA[
##  gap> coll:= [ [Z(2),0*Z(2)], [0*Z(2),Z(2)], [Z(2),Z(2)] ];;
##  gap> V:= LeftModuleByGenerators( GF(16), coll );;
##  gap> W:= Submodule( V, [ coll[1], coll[2] ] );
##  <vector space over GF(2^4), with 2 generators>
##  gap> Parent( W ) = V;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "Submodule" );


#############################################################################
##
#F  SubmoduleNC( <M>, <gens>[, "basis"] )
##
##  <#GAPDoc Label="SubmoduleNC">
##  <ManSection>
##  <Func Name="SubmoduleNC" Arg='M, gens[, "basis"]'/>
##
##  <Description>
##  <Ref Func="SubmoduleNC"/> does the same as <Ref Func="Submodule"/>,
##  except that it does not check whether all in <A>gens</A> lie in <A>M</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SubmoduleNC" );


#############################################################################
##
#P  IsRowModule( <V> )
##
##  <#GAPDoc Label="IsRowModule">
##  <ManSection>
##  <Prop Name="IsRowModule" Arg='V'/>
##
##  <Description>
##  A <E>row module</E> is a free left module whose elements are row vectors.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsRowModule", IsFreeLeftModule );
InstallTrueMethod( IsFreeLeftModule, IsRowModule );

InstallTrueMethod( IsRowModule, IsFullRowModule );


#############################################################################
##
#P  IsMatrixModule( <V> )
##
##  <#GAPDoc Label="IsMatrixModule">
##  <ManSection>
##  <Prop Name="IsMatrixModule" Arg='V'/>
##
##  <Description>
##  A <E>matrix module</E> is a free left module whose elements are matrices.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsMatrixModule", IsFreeLeftModule );
InstallTrueMethod( IsFreeLeftModule, IsMatrixModule );

InstallTrueMethod( IsMatrixModule, IsFullMatrixModule );


#############################################################################
##
#A  DimensionOfVectors( <M> ) . . . . . . . . . .  for row and matrix modules
##
##  <#GAPDoc Label="DimensionOfVectors">
##  <ManSection>
##  <Attr Name="DimensionOfVectors" Arg='M'/>
##
##  <Description>
##  For a left module <A>M</A> that consists of row vectors
##  (see&nbsp;<Ref Prop="IsRowModule"/>),
##  <Ref Attr="DimensionOfVectors"/> returns the common length of all row
##  vectors in <A>M</A>.
##  For a left module <A>M</A> that consists of matrices
##  (see&nbsp;<Ref Prop="IsMatrixModule"/>),
##  <Ref Attr="DimensionOfVectors"/> returns the common matrix dimensions
##  (see&nbsp;<Ref Attr="DimensionsMat"/>) of all matrices in <A>M</A>.
##  <Example><![CDATA[
##  gap> DimensionOfVectors( GF(2)^5 );
##  5
##  gap> DimensionOfVectors( GF(2)^[2,3] );
##  [ 2, 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "DimensionOfVectors", IsFreeLeftModule );


#############################################################################
##
#M  IsFiniteDimensional( <M> )  . . . . . .  row modules are always fin. dim.
#M  IsFiniteDimensional( <M> )  . . . . . matrix modules are always fin. dim.
##
##  Any free left module in the filter `IsRowModule' or `IsMatrixModule'
##  is finite dimensional.
##
InstallTrueMethod( IsFiniteDimensional, IsRowModule and IsFreeLeftModule );
InstallTrueMethod( IsFiniteDimensional,
    IsMatrixModule and IsFreeLeftModule );
