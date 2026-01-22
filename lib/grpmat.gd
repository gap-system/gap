#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for matrix groups.
##


#############################################################################
##
#C  IsMatrixGroup(<grp>)
##
##  <#GAPDoc Label="IsMatrixGroup">
##  <ManSection>
##  <Filt Name="IsMatrixGroup" Arg='grp' Type='Category'/>
##
##  <Description>
##  The category of matrix groups.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonym( "IsMatrixGroup", IsRingElementCollCollColl and IsGroup );

#############################################################################
##
#M  IsHandledByNiceMonomorphism( <mat-grp> )
##
##  For finite matrix groups, there is a default method for
##  `NiceMonomorphism' based on the action on vectors from the right.
##
InstallTrueMethod( IsHandledByNiceMonomorphism, IsMatrixGroup and IsFinite );


#############################################################################
##
#M  CanComputeSize( <mat-grp> )
##
InstallTrueMethod(CanComputeSize,IsMatrixGroup and IsFinite);

#############################################################################
##
##  Operations of Matrix Groups
##  <#GAPDoc Label="[1]{grpmat}">
##  The basic operations for groups are described
##  in Chapter&nbsp;<Ref Chap="Group Actions"/>,
##  special actions for <E>matrix</E> groups mentioned there are
##  <Ref Func="OnLines"/>, <Ref Func="OnRight"/>,
##  and <Ref Func="OnSubspacesByCanonicalBasis"/>.
##  <!-- what about acting directly on subspace objects via <C>OnRight</C>? -->
##  <P/>
##  For subtleties concerning multiplication from the left or from the
##  right,
##  see&nbsp;<Ref Sect="Acting OnRight and OnLeft"/>.
##  <#/GAPDoc>
##


#############################################################################
##
#F  ProjectiveActionHomomorphismMatrixGroup(<G>)
##
##  <#GAPDoc Label="ProjectiveActionHomomorphismMatrixGroup">
##  <ManSection>
##  <Func Name="ProjectiveActionHomomorphismMatrixGroup" Arg='G'/>
##
##  <Description>
##  returns an action homomorphism for a faithful projective action of
##  <A>G</A> on the underlying vector space.
##  (Note: The action is not necessarily on the full space,
##  if a smaller subset can be found on which the action is faithful.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ProjectiveActionHomomorphismMatrixGroup");

#############################################################################
##
#A  DefaultFieldOfMatrixGroup( <mat-grp> )
##
##  <#GAPDoc Label="DefaultFieldOfMatrixGroup">
##  <ManSection>
##  <Attr Name="DefaultFieldOfMatrixGroup" Arg='mat-grp'/>
##
##  <Description>
##  Is a field containing all the matrix entries. It is not guaranteed to be
##  the smallest field with this property.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "DefaultFieldOfMatrixGroup",
    IsMatrixGroup );

InstallSubsetMaintenance( DefaultFieldOfMatrixGroup,
        IsMatrixGroup and HasDefaultFieldOfMatrixGroup, IsMatrixGroup );

#############################################################################
##
#A  DimensionOfMatrixGroup( <mat-grp> )
##
##  <#GAPDoc Label="DimensionOfMatrixGroup">
##  <ManSection>
##  <Attr Name="DimensionOfMatrixGroup" Arg='mat-grp'/>
##
##  <Description>
##  The dimension of the matrix group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "DimensionOfMatrixGroup",
    IsMatrixGroup );


InstallSubsetMaintenance( DimensionOfMatrixGroup,
        IsMatrixGroup and HasDimensionOfMatrixGroup, IsMatrixGroup );


#############################################################################
##
#A  FieldOfMatrixGroup( <matgrp> )
##
##  <#GAPDoc Label="FieldOfMatrixGroup">
##  <ManSection>
##  <Attr Name="FieldOfMatrixGroup" Arg='matgrp'/>
##
##  <Description>
##  The smallest field containing all the matrix entries of all elements
##  of the matrix group <A>matgrp</A>.
##  As the calculation of this can be hard, this should only be used if one
##  <E>really</E> needs the smallest field,
##  use <Ref Attr="DefaultFieldOfMatrixGroup"/> to get (for example)
##  the characteristic.
##  <Example><![CDATA[
##  gap> DimensionOfMatrixGroup(m);
##  3
##  gap> DefaultFieldOfMatrixGroup(m);
##  GF(3)
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "FieldOfMatrixGroup",
    IsMatrixGroup );


#############################################################################
##
#A  TransposedMatrixGroup( <matgrp> ) . . . . . . transpose of a matrix group
##
##  <#GAPDoc Label="TransposedMatrixGroup">
##  <ManSection>
##  <Attr Name="TransposedMatrixGroup" Arg='matgrp'/>
##
##  <Description>
##  returns the transpose of the matrix group <A>matgrp</A>. The transpose of
##  the transpose of <A>matgrp</A> is identical to <A>matgrp</A>.
##  <Example><![CDATA[
##  gap> G := Group( [[0,-1],[1,0]] );
##  Group([ [ [ 0, -1 ], [ 1, 0 ] ] ])
##  gap> T := TransposedMatrixGroup( G );
##  Group([ [ [ 0, 1 ], [ -1, 0 ] ] ])
##  gap> IsIdenticalObj( G, TransposedMatrixGroup( T ) );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "TransposedMatrixGroup", IsMatrixGroup );

#############################################################################
##
#F  NaturalActedSpace( [<G>, ]<acts>, <veclist> )
##
##  <ManSection>
##  <Func Name="NaturalActedSpace" Arg='[G, ]acts, veclist'/>
##
##  <Description>
##  returns the space in which the action of <A>G</A> via the matrix list
##  <A>acts</A>,
##  acting on the orbits of the vectors in <A>veclist</A> takes place. This
##  function is used for example by orbit calculations to obtain a suitable
##  domain for hashing.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("NaturalActedSpace");

#############################################################################
##
#P  IsGeneralLinearGroup( <grp> )
#P  IsGL(<grp>)
##
##  <#GAPDoc Label="IsGeneralLinearGroup">
##  <ManSection>
##  <Prop Name="IsGeneralLinearGroup" Arg='grp'/>
##  <Prop Name="IsGL" Arg='grp'/>
##
##  <Description>
##  The General Linear group is the group of all invertible matrices over a
##  ring. This property tests, whether a group is isomorphic to a General
##  Linear group. (Note that currently only a few trivial methods are
##  available for this operation. We hope to improve this in the future.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsGeneralLinearGroup", IsGroup );
DeclareSynonymAttr( "IsGL", IsGeneralLinearGroup );

InstallTrueMethod( IsGroup, IsGeneralLinearGroup );


#############################################################################
##
#P  IsNaturalGL( <matgrp> )
##
##  <#GAPDoc Label="IsNaturalGL">
##  <ManSection>
##  <Prop Name="IsNaturalGL" Arg='matgrp'/>
##
##  <Description>
##  This property tests, whether a matrix group is the General Linear group
##  in the right dimension over the (smallest) ring which contains all
##  entries of its elements. (Currently, only a trivial test that computes
##  the order of the group is available.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsNaturalGL", IsMatrixGroup );
InstallTrueMethod(IsGeneralLinearGroup,IsNaturalGL);

#############################################################################
##
#P  IsSpecialLinearGroup( <grp> )
#P  IsSL(<grp>)
##
##  <#GAPDoc Label="IsSpecialLinearGroup">
##  <ManSection>
##  <Prop Name="IsSpecialLinearGroup" Arg='grp'/>
##  <Prop Name="IsSL" Arg='grp'/>
##
##  <Description>
##  The Special Linear group is the group of all invertible matrices over a
##  ring, whose determinant is equal to 1. This property tests, whether a
##  group is isomorphic to a Special Linear group. (Note that currently
##  only a few trivial methods are available for this operation. We hope
##  to improve this in the future.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSpecialLinearGroup", IsGroup );
DeclareSynonymAttr( "IsSL", IsSpecialLinearGroup );

InstallTrueMethod( IsGroup, IsSpecialLinearGroup );

#############################################################################
##
#P  IsNaturalSL( <matgrp> )
##
##  <#GAPDoc Label="IsNaturalSL">
##  <ManSection>
##  <Prop Name="IsNaturalSL" Arg='matgrp'/>
##
##  <Description>
##  This property tests, whether a matrix group is the Special Linear group
##  in the right dimension over the (smallest) ring which contains all
##  entries of its elements. (Currently, only a trivial test that computes
##  the order of the group is available.)
##  <Example><![CDATA[
##  gap> IsNaturalGL(m);
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsNaturalSL", IsMatrixGroup );
InstallTrueMethod(IsSpecialLinearGroup,IsNaturalSL);

#############################################################################
##
#P  IsSubgroupSL( <matgrp> )
##
##  <#GAPDoc Label="IsSubgroupSL">
##  <ManSection>
##  <Prop Name="IsSubgroupSL" Arg='matgrp'/>
##
##  <Description>
##  This property tests, whether a matrix group is a subgroup of the Special
##  Linear group in the right dimension over the (smallest) ring which
##  contains all entries of its elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsSubgroupSL", IsMatrixGroup );
InstallTrueMethod(IsSubgroupSL,IsNaturalSL);


#############################################################################
##
#A  InvariantBilinearForm( <matgrp> )
##
##  <#GAPDoc Label="InvariantBilinearForm">
##  <ManSection>
##  <Attr Name="InvariantBilinearForm" Arg='matgrp'/>
##
##  <Description>
##  For a matrix group <A>matgrp</A>, <Ref Attr="InvariantBilinearForm"/>
##  returns a record containing at least the components <C>matrix</C>,
##  whose value is a matrix <M>M</M>,
##  and <C>baseDomain</C>, whose value is a field.
##  <P/>
##  This record describes a bilinear form that is invariant under
##  <A>matgrp</A>.
##  For every generator <M>g</M> of <A>matgrp</A>,
##  the equation <M>g \cdot M \cdot g^{tr} = M</M> holds.
##  <P/>
##  The attribute value is set for example in groups constructed with
##  <Ref Func="SymplecticGroup" Label="for dimension and field size"/>.
##  Together with <Ref Prop="IsFullSubgroupGLorSLRespectingBilinearForm"/>,
##  it can be used for efficient membership tests in <A>matgrp</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InvariantBilinearForm", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLorSLRespectingBilinearForm(<matgrp>)
##
##  <#GAPDoc Label="IsFullSubgroupGLorSLRespectingBilinearForm">
##  <ManSection>
##  <Prop Name="IsFullSubgroupGLorSLRespectingBilinearForm" Arg='matgrp'/>
##
##  <Description>
##  If this property is set then the matrix group <A>matgrp</A> is the full
##  subgroup of <C>GL</C><M>(d, q)</M> or <C>SL</C><M>(d, q)</M>
##  respecting the form stored as the value of
##  <Ref Attr="InvariantBilinearForm"/> for <A>matgrp</A>.
##  <P/>
##  The value <M>d</M> is the <Ref Attr="DimensionOfMatrixGroup"/> value of
##  <A>matgrp</A>,
##  and <M>q</M> is the size of the <C>baseDomain</C> component of the
##  record stored as <Ref Attr="InvariantBilinearForm"/>.
##  <P/>
##  The property <Ref Prop="IsSubgroupSL"/> of <A>matgrp</A> determines
##  whether <C>GL</C> or <C>SL</C> is meant for
##  <Ref Prop="IsFullSubgroupGLorSLRespectingBilinearForm"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullSubgroupGLorSLRespectingBilinearForm", IsMatrixGroup );
InstallTrueMethod( IsGroup, IsFullSubgroupGLorSLRespectingBilinearForm );


#############################################################################
##
#A  InvariantSesquilinearForm( <matgrp> )
##
##  <#GAPDoc Label="InvariantSesquilinearForm">
##  <ManSection>
##  <Attr Name="InvariantSesquilinearForm" Arg='matgrp'/>
##
##  <Description>
##  For a matrix group <A>matgrp</A>, <Ref Attr="InvariantSesquilinearForm"/>
##  returns a record containing at least the components <C>matrix</C>,
##  whose value is a matrix <M>M</M>,
##  and <C>baseDomain</C>, whose value is a field <M>F</M>.
##  <P/>
##  This record describes a sesquilinear form that is invariant under
##  <A>matgrp</A>.
##  For every generator <M>g</M> of <A>matgrp</A>,
##  the equation <M>g \cdot M \cdot (g^{tr})^f = M</M> holds,
##  where <M>f</M> is an automorphism of <M>F</M>.
##  If <M>F</M> has <M>q^2</M> elements then <M>f</M> raises each element
##  of <M>F</M> to its <M>q</M>-th power.
##  (<M>f</M> can be obtained as a power of the
##  <Ref Attr="FrobeniusAutomorphism"/> value of <M>F</M>.)
##  <P/>
##  The attribute value is set for example in groups constructed with
##  <Ref Func="GeneralUnitaryGroup"/>. Together with
##  <Ref Prop="IsFullSubgroupGLorSLRespectingSesquilinearForm"/>,
##  it can be used for efficient membership tests in <A>matgrp</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InvariantSesquilinearForm", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLorSLRespectingSesquilinearForm(<matgrp>)
##
##  <#GAPDoc Label="IsFullSubgroupGLorSLRespectingSesquilinearForm">
##  <ManSection>
##  <Prop Name="IsFullSubgroupGLorSLRespectingSesquilinearForm" Arg='matgrp'/>
##
##  <Description>
##  If this property is set then the matrix group <A>matgrp</A> is the full
##  subgroup of <C>GL</C><M>(d, q)</M> or <C>SL</C><M>(d, q)</M>
##  respecting the form stored as the value of
##  <Ref Attr="InvariantSesquilinearForm"/> for <A>matgrp</A>.
##  <P/>
##  The value <M>d</M> is the <Ref Attr="DimensionOfMatrixGroup"/> value of
##  <A>matgrp</A>,
##  and <M>q</M> is the size of the <C>baseDomain</C> component of the
##  record stored as <Ref Attr="InvariantSesquilinearForm"/>.
##  <P/>
##  The property <Ref Prop="IsSubgroupSL"/> of <A>matgrp</A> determines
##  whether <C>GL</C> or <C>SL</C> is meant for
##  <Ref Prop="IsFullSubgroupGLorSLRespectingSesquilinearForm"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullSubgroupGLorSLRespectingSesquilinearForm",
  IsMatrixGroup );
InstallTrueMethod( IsGroup, IsFullSubgroupGLorSLRespectingSesquilinearForm );


#############################################################################
##
#A  InvariantQuadraticForm( <matgrp> )
##
##  <#GAPDoc Label="InvariantQuadraticForm">
##  <ManSection>
##  <Attr Name="InvariantQuadraticForm" Arg='matgrp'/>
##
##  <Description>
##  For a matrix group <A>matgrp</A>, <Ref Attr="InvariantQuadraticForm"/>
##  returns a record containing at least the components <C>matrix</C>,
##  whose value is a matrix <M>Q</M>,
##  and <C>baseDomain</C>, whose value is a field <M>F</M>.
##  <P/>
##  The quadratic form <M>q</M> on the natural <M>F</M>-vector space <M>V</M>
##  on which <A>matgrp</A> acts is given by <M>q(v) = v Q v^{tr}</M>,
##  and the invariance under <A>matgrp</A> is given by the equation
##  <M>q(v) = q(v M)</M> for all <M>v \in V</M> and <M>M</M> in
##  <A>matgrp</A>.
##  (Note that the invariance of <M>q</M> does <E>not</E> imply that the
##  matrix <M>Q</M> is invariant under <A>matgrp</A>.)
##  <P/>
##  The function <M>q</M> is defined relative to an invariant symmetric
##  bilinear form <M>b</M> (see&nbsp;<Ref Attr="InvariantBilinearForm"/>),
##  via the equation
##  <M>q(\lambda x + \mu y) =
##  \lambda^2 q(x) + \lambda \mu b(x,y) + \mu^2 q(y)</M>,
##  see <Cite Key="CCN85" Where="Chapter 3.4"/>.
##  If <M>b</M> is represented by the matrix <M>B</M> then this implies
##  <M>B = Q + Q^{tr}</M>.
##  In characteristic different from <M>2</M>, we have <M>q(x) = b(x,x)/2</M>,
##  so <M>Q</M> can be chosen as the strictly upper triangular part of
##  <M>B</M> plus half of the diagonal part of <M>B</M>.
##  In characteristic <M>2</M>, <M>B</M> does not determine <M>Q</M>
##  but still <M>Q</M> can be chosen as an upper (or lower) triangular matrix.
##  <P/>
##  Whenever the <Ref Attr="InvariantQuadraticForm"/> value is set in a
##  matrix group then also the <Ref Attr="InvariantBilinearForm"/> value
##  can be accessed,
##  and the two values are compatible in the above sense.
##  <P/>
##  The attribute value is set for example in groups constructed with
##  <Ref Func="GeneralOrthogonalGroup"/>. Together with
##  <Ref Prop="IsFullSubgroupGLorSLRespectingQuadraticForm"/>,
##  it can be used for efficient membership tests in <A>matgrp</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "InvariantQuadraticForm", IsMatrixGroup );


#############################################################################
##
#P  IsFullSubgroupGLorSLRespectingQuadraticForm( <matgrp> )
##
##  <#GAPDoc Label="IsFullSubgroupGLorSLRespectingQuadraticForm">
##  <ManSection>
##  <Prop Name="IsFullSubgroupGLorSLRespectingQuadraticForm" Arg='matgrp'/>
##
##  <Description>
##  If this property is set then the matrix group <A>matgrp</A> is the full
##  subgroup of <C>GL</C><M>(d, q)</M> or <C>SL</C><M>(d, q)</M>
##  respecting the form stored as the value of
##  <Ref Attr="InvariantQuadraticForm"/> for <A>matgrp</A>.
##  <P/>
##  The value <M>d</M> is the <Ref Attr="DimensionOfMatrixGroup"/> value of
##  <A>matgrp</A>,
##  and <M>q</M> is the size of the <C>baseDomain</C> component of the
##  record stored as <Ref Attr="InvariantQuadraticForm"/>.
##  <P/>
##  The property <Ref Prop="IsSubgroupSL"/> of <A>matgrp</A> determines
##  whether <C>GL</C> or <C>SL</C> is meant for
##  <Ref Prop="IsFullSubgroupGLorSLRespectingQuadraticForm"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> g:= Sp( 2, 3 );;
##  gap> m:= InvariantBilinearForm( g ).matrix;
##  [ [ 0*Z(3), Z(3)^0 ], [ Z(3), 0*Z(3) ] ]
##  gap> [ 0, 1 ] * m * [ 1, -1 ];       # evaluate the bilinear form
##  Z(3)
##  gap> IsFullSubgroupGLorSLRespectingBilinearForm( g );
##  true
##  gap> g:= SU( 2, 4 );;
##  gap> m:= InvariantSesquilinearForm( g ).matrix;
##  [ [ 0*Z(2), Z(2)^0 ], [ Z(2)^0, 0*Z(2) ] ]
##  gap> [ 0, 1 ] * m * [ 1, 1 ];        # evaluate the sesquilinear form
##  Z(2)^0
##  gap> IsFullSubgroupGLorSLRespectingSesquilinearForm( g );
##  true
##  gap> IsSubgroupSL( g );
##  true
##  gap> g:= GO( 1, 2, 3 );;
##  gap> m:= InvariantBilinearForm( g ).matrix;
##  [ [ 0*Z(3), Z(3)^0 ], [ Z(3)^0, 0*Z(3) ] ]
##  gap> [ 0, 1 ] * m * [ 1, 1 ];        # evaluate the bilinear form
##  Z(3)^0
##  gap> q:= InvariantQuadraticForm( g ).matrix;
##  [ [ 0*Z(3), Z(3)^0 ], [ 0*Z(3), 0*Z(3) ] ]
##  gap> [ 0, 1 ] * q * [ 0, 1 ];        # evaluate the quadratic form
##  0*Z(3)
##  gap> IsFullSubgroupGLorSLRespectingQuadraticForm( g );
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsFullSubgroupGLorSLRespectingQuadraticForm",
    IsMatrixGroup );
InstallTrueMethod( IsGroup, IsFullSubgroupGLorSLRespectingQuadraticForm );

#############################################################################
##
#F  AffineActionByMatrixGroup( <M> )
##
##  <ManSection>
##  <Func Name="AffineActionByMatrixGroup" Arg='M'/>
##
##  <Description>
##  takes a group <A>M</A> of <M>n \times n</M> matrices over the finite
##  field <M>F</M> and returns an affine permutation group
##  <M>F^n :</M> <A>M</A>
##  for the natural action of <A>M</A> on the vector space <M>F^n</M>.
##  The labelling of the points of the resulting group is not guaranteed.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AffineActionByMatrixGroup" );


#############################################################################
##
#F  BlowUpIsomorphism( <matgrp>, <B> )
##
##  <#GAPDoc Label="BlowUpIsomorphism">
##  <ManSection>
##  <Func Name="BlowUpIsomorphism" Arg='matgrp, B'/>
##
##  <Description>
##  For a matrix group <A>matgrp</A> and a basis <A>B</A> of a field
##  extension <M>L / K</M> such that the entries of all matrices in
##  <A>matgrp</A> lie in <M>L</M>,
##  <Ref Func="BlowUpIsomorphism"/> returns the isomorphism with source
##  <A>matgrp</A> that is defined by mapping the matrix <M>A</M> to
##  <C>BlownUpMat</C><M>( A, <A>B</A> )</M>,
##  see&nbsp;<Ref Func="BlownUpMat"/>.
##  <Example><![CDATA[
##  gap> g:= GL(2,4);;
##  gap> B:= CanonicalBasis( GF(4) );;  BasisVectors( B );
##  [ Z(2)^0, Z(2^2) ]
##  gap> iso:= BlowUpIsomorphism( g, B );;
##  gap> Display( Image( iso, [ [ Z(4), Z(2) ], [ 0*Z(2), Z(4)^2 ] ] ) );
##   . 1 1 .
##   1 1 . 1
##   . . 1 1
##   . . 1 .
##  gap> img:= Image( iso, g );
##  <matrix group with 2 generators>
##  gap> Index( GL(4,2), img );
##  112
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "BlowUpIsomorphism" );

DeclareGlobalFunction( "BasisVectorsForMatrixAction" );
