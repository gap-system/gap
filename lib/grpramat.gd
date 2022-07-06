#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Franz Gähler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for matrix groups over the rationals
##

#############################################################################
##
#C  IsCyclotomicMatrixGroup( <G> )
##
##  <#GAPDoc Label="IsCyclotomicMatrixGroup">
##  <ManSection>
##  <Filt Name="IsCyclotomicMatrixGroup" Arg='G' Type='Category'/>
##
##  <Description>
##  tests whether all matrices in <A>G</A> have cyclotomic entries.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsCyclotomicMatrixGroup", IsCyclotomicCollCollColl and IsMatrixGroup );

#############################################################################
##
#P  IsRationalMatrixGroup( <G> )
##
##  <#GAPDoc Label="IsRationalMatrixGroup">
##  <ManSection>
##  <Prop Name="IsRationalMatrixGroup" Arg='G'/>
##
##  <Description>
##  tests whether all matrices in <A>G</A> have rational entries.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsRationalMatrixGroup", IsCyclotomicMatrixGroup );
InstallTrueMethod( IsCyclotomicMatrixGroup, IsRationalMatrixGroup );

#############################################################################
##
#P  IsIntegerMatrixGroup( <G> )
##
##  <#GAPDoc Label="IsIntegerMatrixGroup">
##  <ManSection>
##  <Prop Name="IsIntegerMatrixGroup" Arg='G'/>
##
##  <Description>
##  tests whether all matrices in <A>G</A> have integer entries.
##  <!--  Not <C>IsIntegralMatrixGroup</C> to avoid confusion with matrix groups of-->
##  <!--  integral cyclotomic numbers. -->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsIntegerMatrixGroup", IsCyclotomicMatrixGroup );
InstallTrueMethod( IsRationalMatrixGroup, IsIntegerMatrixGroup );

#############################################################################
##
#P  IsNaturalGLnZ( <G> )
##
##  <#GAPDoc Label="IsNaturalGLnZ">
##  <ManSection>
##  <Prop Name="IsNaturalGLnZ" Arg='G'/>
##
##  <Description>
##  tests whether <A>G</A> is <M>GL_n(&ZZ;)</M> in its natural representation
##  by <M>n \times n</M> integer matrices.
##  (The dimension <M>n</M> will be read off the generating matrices.)
##  <Example><![CDATA[
##  gap> IsNaturalGLnZ( GL( 2, Integers ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsNaturalGLnZ", IsNaturalGL and IsIntegerMatrixGroup );

#############################################################################
##
#P  IsNaturalSLnZ( <G> )
##
##  <#GAPDoc Label="IsNaturalSLnZ">
##  <ManSection>
##  <Prop Name="IsNaturalSLnZ" Arg='G'/>
##
##  <Description>
##  tests whether <A>G</A> is <M>SL_n(&ZZ;)</M> in its natural representation
##  by <M>n \times n</M> integer matrices.
##  (The dimension <M>n</M> will be read off the generating matrices.)
##  <Example><![CDATA[
##  gap> IsNaturalSLnZ( SL( 2, Integers ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsNaturalSLnZ", IsNaturalSL and IsIntegerMatrixGroup );

#############################################################################
##
#A  ZClassRepsQClass( G ) . . . . . . . . . . .  Z-class reps in Q-class of G
##
##  <#GAPDoc Label="ZClassRepsQClass">
##  <ManSection>
##  <Attr Name="ZClassRepsQClass" Arg='G'/>
##
##  <Description>
##  The conjugacy class in <M>GL_n(&QQ;)</M> of the finite integer matrix
##  group <A>G</A> splits into finitely many conjugacy classes in
##  <M>GL_n(&ZZ;)</M>.
##  <C>ZClassRepsQClass( <A>G</A> )</C> returns representative groups for these.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "ZClassRepsQClass", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  NormalizerInGLnZ( G ) . . . . . . . . . . . . . . . . .  NormalizerInGLnZ
##
##  <#GAPDoc Label="NormalizerInGLnZ">
##  <ManSection>
##  <Attr Name="NormalizerInGLnZ" Arg='G'/>
##
##  <Description>
##  is an attribute used to store the normalizer of <A>G</A> in
##  <M>GL_n(&ZZ;)</M>, where <A>G</A> is an integer matrix group of dimension
##  <A>n</A>. This attribute
##  is used by <C>Normalizer( GL( n, Integers ), G )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NormalizerInGLnZ", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  CentralizerInGLnZ( G ) . . . . . . . . . . . . . . . . .CentralizerInGLnZ
##
##  <#GAPDoc Label="CentralizerInGLnZ">
##  <ManSection>
##  <Attr Name="CentralizerInGLnZ" Arg='G'/>
##
##  <Description>
##  is an attribute used to store the centralizer of <A>G</A> in
##  <M>GL_n(&ZZ;)</M>, where <A>G</A> is an integer matrix group of dimension
##  <A>n</A>. This attribute
##  is used by <C>Centralizer( GL( n, Integers ), G )</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "CentralizerInGLnZ", IsCyclotomicMatrixGroup );


#############################################################################
##
##  RightAction or LeftAction
##
##  <#GAPDoc Label="[1]{grpramat}">
##  In &GAP;, matrices by convention act on row vectors from the right,
##  whereas in crystallography the convention is to act on column vectors
##  from the left. The definition of certain algebraic objects important
##  in crystallography implicitly depends on which action is assumed.
##  This holds true in particular for quadratic forms invariant under
##  a matrix group. In a similar way, the representation of affine
##  crystallographic groups, as they are provided by the &GAP; package
##  <Package>CrystGap</Package>, depends on which action is assumed.
##  Crystallographers are used to the action from the left,
##  whereas the action from the right is the natural one for &GAP;.
##  For this reason, a number of functions which are important in
##  crystallography, and whose result depends on which action is assumed,
##  are provided in two versions,
##  one for the usual action from the right, and one for the
##  crystallographic action from the left.
##  <P/>
##  For every such function, this fact is explicitly mentioned.
##  The naming scheme is as follows: If <C>SomeThing</C> is such a function,
##  there will be functions <C>SomeThingOnRight</C> and <C>SomeThingOnLeft</C>,
##  assuming action from the right and from the left, respectively.
##  In addition, there is a generic function <C>SomeThing</C>, which returns
##  either the result of <C>SomeThingOnRight</C> or <C>SomeThingOnLeft</C>,
##  depending on the global variable <Ref Var="CrystGroupDefaultAction"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#V  CrystGroupDefaultAction
##
##  <#GAPDoc Label="CrystGroupDefaultAction">
##  <ManSection>
##  <Var Name="CrystGroupDefaultAction"/>
##
##  <Description>
##  can have either of the two values <C>RightAction</C> and <C>LeftAction</C>.
##  The initial value is <C>RightAction</C>. For functions which have
##  variants OnRight and OnLeft, this variable determines which
##  variant is returned by the generic form. The value of
##  <Ref Var="CrystGroupDefaultAction"/> can be changed with the
##  function <Ref Func="SetCrystGroupDefaultAction"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalName( "CrystGroupDefaultAction" );

BindGlobal( "LeftAction",  Immutable( "LeftAction"  ) );
BindGlobal( "RightAction", Immutable( "RightAction" ) );

#############################################################################
##
#F  SetCrystGroupDefaultAction( <action> ) . . . . .RightAction or LeftAction
##
##  <#GAPDoc Label="SetCrystGroupDefaultAction">
##  <ManSection>
##  <Func Name="SetCrystGroupDefaultAction" Arg='action'/>
##
##  <Description>
##  allows one to set the value of the global variable
##  <Ref Var="CrystGroupDefaultAction"/>.
##  Only the arguments <C>RightAction</C> and <C>LeftAction</C> are allowed.
##  Initially, the value of <Ref Var="CrystGroupDefaultAction"/> is
##  <C>RightAction</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SetCrystGroupDefaultAction" );

#############################################################################
##
#P  IsBravaisGroup( <G> ) . . . . . . . . . . . . . . . . . . .IsBravaisGroup
##
##  <#GAPDoc Label="IsBravaisGroup">
##  <ManSection>
##  <Prop Name="IsBravaisGroup" Arg='G'/>
##
##  <Description>
##  test whether <A>G</A> coincides with its Bravais group
##  (see <Ref Attr="BravaisGroup"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsBravaisGroup", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  BravaisGroup( <G> ) . . . . . . . . Bravais group of integer matrix group
##
##  <#GAPDoc Label="BravaisGroup">
##  <ManSection>
##  <Attr Name="BravaisGroup" Arg='G'/>
##
##  <Description>
##  returns the Bravais group of a finite integer matrix group <A>G</A>.
##  If <M>C</M> is the cone of positive definite quadratic forms <M>Q</M>
##  invariant under <M>g \mapsto g Q g^{tr}</M> for all <M>g \in <A>G</A></M>,
##  then the Bravais group of <A>G</A> is the maximal subgroup of
##  <M>GL_n(&ZZ;)</M> leaving the forms in that same cone invariant.
##  Alternatively, the Bravais group of <A>G</A>
##  can also be defined with respect to the action <M>g \mapsto g^{tr} Q g</M>
##  on positive definite quadratic forms <M>Q</M>. This latter definition
##  is appropriate for groups <A>G</A> acting from the right on row vectors,
##  whereas the former definition is appropriate for groups acting from
##  the left on column vectors. Both definitions yield the same
##  Bravais group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BravaisGroup", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  BravaisSubgroups( <G> ) . . . . . . . .Bravais subgroups of Bravais group
##
##  <#GAPDoc Label="BravaisSubgroups">
##  <ManSection>
##  <Attr Name="BravaisSubgroups" Arg='G'/>
##
##  <Description>
##  returns the subgroups of the Bravais group of <A>G</A>, which are
##  themselves Bravais groups.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BravaisSubgroups", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  BravaisSupergroups( <G> ) . . . . . .Bravais supergroups of Bravais group
##
##  <#GAPDoc Label="BravaisSupergroups">
##  <ManSection>
##  <Attr Name="BravaisSupergroups" Arg='G'/>
##
##  <Description>
##  returns the subgroups of <M>GL_n(&ZZ;)</M> that contain the Bravais group
##  of <A>G</A> and are Bravais groups themselves.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "BravaisSupergroups", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  NormalizerInGLnZBravaisGroup( <G> ) . norm. of Bravais group of G in GLnZ
##
##  <#GAPDoc Label="NormalizerInGLnZBravaisGroup">
##  <ManSection>
##  <Attr Name="NormalizerInGLnZBravaisGroup" Arg='G'/>
##
##  <Description>
##  returns the normalizer of the Bravais group of <A>G</A> in the
##  appropriate <M>GL_n(&ZZ;)</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "NormalizerInGLnZBravaisGroup", IsCyclotomicMatrixGroup );

#############################################################################
##
#A  InvariantLattice( G )
##
##  <#GAPDoc Label="InvariantLattice">
##  <ManSection>
##  <Attr Name="InvariantLattice" Arg='G'/>
##
##  <Description>
##  returns a matrix <M>B</M>, whose rows form a basis of a
##  <M>&ZZ;</M>-lattice that is invariant under the rational matrix group
##  <A>G</A> acting from the right.
##  It returns <K>fail</K> if the group is not unimodular. The columns of the
##  inverse of <M>B</M> span a <M>&ZZ;</M>-lattice invariant under <A>G</A>
##  acting from  the left.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InvariantLattice", IsCyclotomicMatrixGroup );
