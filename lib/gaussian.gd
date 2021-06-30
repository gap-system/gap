#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This files's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations for Gaussian rationals and Gaussian
##  integers.
##
##  Gaussian rationals are elements of the form $a + b * I$ where $I$ is the
##  square root of -1 and $a,b$ are rationals.
##  Note that $I$ is written as `E(4)', i.e., as a fourth root of unity in
##  {\GAP}.
##  Gauss was the first to investigate such numbers, and already proved that
##  the ring of integers of this field, i.e., the elements of the form
##  $a + b * I$ where $a,b$ are integers, forms a Euclidean Ring.
##  It follows that this ring is a Unique Factorization Domain.
##


#############################################################################
##
#F  IsGaussInt( <x> ) . . . . . . . . test if an object is a Gaussian integer
##
##  <#GAPDoc Label="IsGaussInt">
##  <ManSection>
##  <Func Name="IsGaussInt" Arg='x'/>
##
##  <Description>
##  <Ref Func="IsGaussInt"/> returns <K>true</K> if the object <A>x</A> is
##  a Gaussian integer (see&nbsp;<Ref Var="GaussianIntegers"/>),
##  and <K>false</K> otherwise.
##  Gaussian integers are of the form <M>a + b</M><C>*E(4)</C>,
##  where <M>a</M> and <M>b</M> are integers.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsGaussInt" );


#############################################################################
##
#F  IsGaussRat( <x> ) . . . . . . .  test if an object is a Gaussian rational
##
##  <#GAPDoc Label="IsGaussRat">
##  <ManSection>
##  <Func Name="IsGaussRat" Arg='x'/>
##
##  <Description>
##  <Ref Func="IsGaussRat"/> returns <K>true</K> if the object <A>x</A> is
##  a Gaussian rational (see&nbsp;<Ref Var="GaussianRationals"/>),
##  and <K>false</K> otherwise.
##  Gaussian rationals are of the form <M>a + b</M><C>*E(4)</C>,
##  where <M>a</M> and <M>b</M> are rationals.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IsGaussRat" );


#############################################################################
##
#C  IsGaussianIntegers( <obj> )
##
##  <#GAPDoc Label="IsGaussianIntegers">
##  <ManSection>
##  <Filt Name="IsGaussianIntegers" Arg='obj' Type='Category'/>
##
##  <Description>
##  is the defining category for the domain <Ref Var="GaussianIntegers"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsGaussianIntegers", IsEuclideanRing and IsFLMLOR
  and IsFiniteDimensional );


#############################################################################
##
#V  GaussianIntegers  . . . . . . . . . . . . . . . ring of Gaussian integers
##
##  <#GAPDoc Label="GaussianIntegers">
##  <ManSection>
##  <Var Name="GaussianIntegers"/>
##
##  <Description>
##  <Ref Var="GaussianIntegers"/> is the ring <M>&ZZ;[\sqrt{{-1}}]</M>
##  of Gaussian integers.
##  This is a subring of the cyclotomic field
##  <Ref Var="GaussianRationals"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalName( "GaussianIntegers");
