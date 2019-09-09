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
##  This file declares the operations for external left sets.
##


#############################################################################
##
#C  IsExtLSet( <D> )
##
##  <ManSection>
##  <Filt Name="IsExtLSet" Arg='D' Type='Category'/>
##
##  <Description>
##  An external left set is a domain with an action of a domain
##  from the left.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsExtLSet", IsDomain );


#############################################################################
##
#C  IsAssociativeLOpDProd( <D> )
##
##  <ManSection>
##  <Filt Name="IsAssociativeLOpDProd" Arg='D' Type='Category'/>
##
##  <Description>
##  is <K>true</K> iff <M>a * ( x * y ) = ( a * x ) * y</M>
##  for <M>a \in E</M> and <M>x, y \in D</M>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsAssociativeLOpDProd", IsExtLSet );


#############################################################################
##
#C  IsAssociativeLOpEProd( <D> )
##
##  <ManSection>
##  <Filt Name="IsAssociativeLOpEProd" Arg='D' Type='Category'/>
##
##  <Description>
##  is <K>true</K> iff <M>a * ( b * x ) = ( a * b ) * x</M>
##  for <M>a, b \in E</M> and <M>x \in D</M>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsAssociativeLOpEProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpDProd( <D> )
##
##  <ManSection>
##  <Filt Name="IsDistributiveLOpDProd" Arg='D' Type='Category'/>
##
##  <Description>
##  is <K>true</K> iff <M>a * ( x * y ) = ( a * x ) * ( a * y )</M>
##  for <M>a \in E</M> and <M>x, y \in D</M>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsDistributiveLOpDProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpDSum( <D> )
##
##  <ManSection>
##  <Filt Name="IsDistributiveLOpDSum" Arg='D' Type='Category'/>
##
##  <Description>
##  is <K>true</K> iff <M>a * ( x + y ) = ( a * x ) + ( a * y )</M>
##  for <M>a \in E</M> and <M>x, y \in D</M>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsDistributiveLOpDSum", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpEProd( <D> )
##
##  <ManSection>
##  <Filt Name="IsDistributiveLOpEProd" Arg='D' Type='Category'/>
##
##  <Description>
##  is <K>true</K> iff <M>( a * b ) * x = ( a * x ) * ( b * x )</M>
##  for <M>a, b \in E</M> and <M>x \in D</M>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsDistributiveLOpEProd", IsExtLSet );


#############################################################################
##
#C  IsDistributiveLOpESum( <D> )
##
##  <ManSection>
##  <Filt Name="IsDistributiveLOpESum" Arg='D' Type='Category'/>
##
##  <Description>
##  is <K>true</K> iff <M>( a + b ) * x = ( a * x ) + ( b * x )</M>
##  for <M>a, b \in E</M> and <M>x \in D</M>.
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsDistributiveLOpESum", IsExtLSet );


#############################################################################
##
#C  IsTrivialLOpEOne( <D> )
##
##  <ManSection>
##  <Filt Name="IsTrivialLOpEOne" Arg='D' Type='Category'/>
##
##  <Description>
##  is <K>true</K> iff the identity element <M>e \in E</M> acts trivially on <M>D</M>,
##  that is, <M>e * x = x</M> for <M>x \in D</M>.
##  <!-- necessary?-->
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsTrivialLOpEOne", IsExtLSet );


#############################################################################
##
#C  IsTrivialLOpEZero( <D> )
##
##  <ManSection>
##  <Filt Name="IsTrivialLOpEZero" Arg='D' Type='Category'/>
##
##  <Description>
##  is <K>true</K> iff the zero element <M>z \in E</M> acts trivially on <M>D</M>,
##  that is, <M>z * x = Z</M> for <M>x \in D</M> and the zero element <M>Z</M> of <M>D</M>.
##  <!-- necessary?-->
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsTrivialLOpEZero", IsExtLSet );


#############################################################################
##
#C  IsLeftActedOnByRing( <D> )
##
##  <ManSection>
##  <Filt Name="IsLeftActedOnByRing" Arg='D' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsLeftActedOnByRing", IsExtLSet );


#############################################################################
##
#P  IsLeftActedOnByDivisionRing( <D> )
##
##  <ManSection>
##  <Prop Name="IsLeftActedOnByDivisionRing" Arg='D'/>
##
##  <Description>
##  This is a property because then we need not duplicate code that creates
##  either left modules or left vector spaces.
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsLeftActedOnByDivisionRing",
    IsExtLSet and IsLeftActedOnByRing );


#############################################################################
##
#C  IsLeftActedOnBySuperset( <D> )
##
##  <ManSection>
##  <Filt Name="IsLeftActedOnBySuperset" Arg='D' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsLeftActedOnBySuperset",
    IsExtLSet );


#############################################################################
##
#A  GeneratorsOfExtLSet( <D> )
##
##  <ManSection>
##  <Attr Name="GeneratorsOfExtLSet" Arg='D'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "GeneratorsOfExtLSet", IsExtLSet );


#############################################################################
##
#A  LeftActingDomain( <D> )
##
##  <#GAPDoc Label="LeftActingDomain">
##  <ManSection>
##  <Attr Name="LeftActingDomain" Arg='D'/>
##
##  <Description>
##  Let <A>D</A> be an external left set, that is, <A>D</A> is closed under the action
##  of a domain <M>L</M> by multiplication from the left.
##  Then <M>L</M> can be accessed as value of <C>LeftActingDomain</C> for <A>D</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "LeftActingDomain", IsExtLSet );
