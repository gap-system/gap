#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Stefan Kohl.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations of functions for computing (with)
##  continued fraction expansions of real numbers.
##

#############################################################################
##
#F  ContinuedFractionExpansionOfRoot( <f>, <n> )
##
##  <#GAPDoc Label="ContinuedFractionExpansionOfRoot">
##  <ManSection>
##  <Func Name="ContinuedFractionExpansionOfRoot" Arg='f, n'/>
##
##  <Description>
##  The first <A>n</A> terms of the continued fraction expansion of the only
##  positive real root of the polynomial <A>f</A> with integer coefficients.
##  The leading coefficient of <A>f</A> must be positive and the value of <A>f</A> at 0
##  must be negative. If the degree of <A>f</A> is 2 and <A>n</A> = 0, the function
##  computes one period of the continued fraction expansion of the root in
##  question. Anything may happen if <A>f</A> has three or more positive real
##  roots.
##  <Example><![CDATA[
##  gap> x := Indeterminate(Integers);;
##  gap> ContinuedFractionExpansionOfRoot(x^2-7,20);
##  [ 2, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1, 4, 1, 1, 1 ]
##  gap> ContinuedFractionExpansionOfRoot(x^2-7,0);
##  [ 2, 1, 1, 1, 4 ]
##  gap> ContinuedFractionExpansionOfRoot(x^3-2,20);
##  [ 1, 3, 1, 5, 1, 1, 4, 1, 1, 8, 1, 14, 1, 10, 2, 1, 4, 12, 2, 3 ]
##  gap> ContinuedFractionExpansionOfRoot(x^5-x-1,50);
##  [ 1, 5, 1, 42, 1, 3, 24, 2, 2, 1, 16, 1, 11, 1, 1, 2, 31, 1, 12, 5,
##    1, 7, 11, 1, 4, 1, 4, 2, 2, 3, 4, 2, 1, 1, 11, 1, 41, 12, 1, 8, 1,
##    1, 1, 1, 1, 9, 2, 1, 5, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ContinuedFractionExpansionOfRoot" );

#############################################################################
##
#F  ContinuedFractionApproximationOfRoot( <f>, <n> )
##
##  <#GAPDoc Label="ContinuedFractionApproximationOfRoot">
##  <ManSection>
##  <Func Name="ContinuedFractionApproximationOfRoot" Arg='f, n'/>
##
##  <Description>
##  The <A>n</A>th continued fraction approximation of the only positive real root
##  of the polynomial <A>f</A> with integer coefficients. The leading coefficient
##  of <A>f</A> must be positive and the value of <A>f</A> at 0 must be negative.
##  Anything may happen if <A>f</A> has three or more positive real roots.
##  <Example><![CDATA[
##  gap> ContinuedFractionApproximationOfRoot(x^2-2,10);
##  3363/2378
##  gap> 3363^2-2*2378^2;
##  1
##  gap> z := ContinuedFractionApproximationOfRoot(x^5-x-1,20);
##  499898783527/428250732317
##  gap> z^5-z-1;
##  486192462527432755459620441970617283/
##  14404247382319842421697357558805709031116987826242631261357
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ContinuedFractionApproximationOfRoot" );

