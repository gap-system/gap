#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for unknowns.
##


#############################################################################
##
##  <#GAPDoc Label="[1]{unknown}">
##  Sometimes the result of an operation does not allow further
##  computations with it.
##  In many cases, then an error is signalled,
##  and the computation is stopped.
##  <P/>
##  This is not appropriate for some applications in character theory.
##  For example, if one wants to induce a character of a group to a
##  supergroup (see&nbsp;<Ref Oper="InducedClassFunction"
##  Label="for the character table of a supergroup"/>)
##  but the class fusion is only a parametrized map
##  (see Chapter&nbsp;<Ref Chap="Maps Concerning Character Tables"/>),
##  there may be values of the induced character which are determined by the
##  fusion map, whereas other values are not known.
##  <P/>
##  For this and other situations, &GAP; provides the data type
##  <E>unknown</E>.
##  An object of this type, further on called an <E>unknown</E>,
##  may stand for any cyclotomic
##  (see Chapter&nbsp;<Ref Chap="Cyclotomic Numbers"/>),
##  in particular its family (see&nbsp;<Ref Sect="Families"/>)
##  is <C>CyclotomicsFamily</C>.
##  <P/>
##  Unknowns are parametrized by positive integers.
##  When a &GAP; session is started, no unknowns exist.
##  <P/>
##  The only ways to create unknowns are to call the function
##  <Ref Oper="Unknown"/> or a function that calls it,
##  or to do arithmetical operations with unknowns.
##  <P/>
##  &GAP; objects containing unknowns will contain <E>fixed</E> unknowns
##  when they are printed to files, i.e.,
##  function calls <C>Unknown(</C><M>n</M><C>)</C> instead of
##  <C>Unknown()</C>.
##  So be careful to read files printed in different &GAP; sessions,
##  since there may be the same unknown at different places.
##  <P/>
##  The rest of this chapter contains information about the unknown
##  constructor, the category,
##  and comparison of and arithmetical operations for unknowns.
##  More is not known about unknowns in &GAP;.
##  <#/GAPDoc>
##


#############################################################################
##
##  <#GAPDoc Label="[2]{unknown}">
##  <Subsection>
##  <Heading>Comparison of Unknowns</Heading>
##
##  Unknowns can be <E>compared</E> via <C>=</C> and <C>&lt;</C>
##  with all cyclotomics and with certain other &GAP; objects
##  (see&nbsp;<Ref Sect="Comparisons"/>).
##  We have <C>Unknown( <A>n</A> ) >= Unknown( <A>m</A> )</C>
##  if and only if <C><A>n</A> >= <A>m</A></C> holds,
##  unknowns are larger than all cyclotomics that are not unknowns.
##  <P/>
##  <Example><![CDATA[
##  gap> Unknown() >= Unknown();  Unknown(2) < Unknown(3);
##  false
##  true
##  gap> Unknown() > 3;  Unknown() > E(3);
##  true
##  true
##  gap> Unknown() > Z(8);  Unknown() > [];
##  false
##  false
##  ]]></Example>
##  </Subsection>
##  <#/GAPDoc>
##


#############################################################################
##
##  <#GAPDoc Label="[3]{unknown}">
##  <Subsection>
##  <Heading>Arithmetical Operations for Unknowns</Heading>
##
##  The usual arithmetic operations <C>+</C>, <C>-</C>, <C>*</C> and <C>/</C>
##  are defined for addition, subtraction, multiplication and division
##  of unknowns and cyclotomics.
##  The result will be a new unknown except in one of the following cases.
##  <P/>
##  Multiplication with zero yields zero,
##  and multiplication with one or addition of zero yields the old unknown.
##  <E>Note</E> that division by an unknown causes an error,
##  since an unknown might stand for zero.
##  <P/>
##  As unknowns are cyclotomics, dense lists of unknowns and other
##  cyclotomics are row vectors and
##  they can be added and multiplied in the usual way.
##  Consequently, lists of such row vectors of equal length are (ordinary)
##  matrices (see&nbsp;<Ref Filt="IsOrdinaryMatrix"/>).
##  </Subsection>
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsUnknown( <obj> )
##
##  <#GAPDoc Label="IsUnknown">
##  <ManSection>
##  <Filt Name="IsUnknown" Arg='obj' Type='Category'/>
##
##  <Description>
##  is the category of unknowns in &GAP;.
##  <Example><![CDATA[
##  gap> Unknown();  List( [ 1 .. 20 ], i -> Unknown() );;
##  Unknown(1)
##  gap> Unknown();   # note that we have already created 21 unknowns.
##  Unknown(22)
##  gap> Unknown(2000);  Unknown();
##  Unknown(2000)
##  Unknown(2001)
##  gap> LargestUnknown;
##  2001
##  gap> IsUnknown( Unknown );  IsUnknown( Unknown() );
##  false
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsUnknown", IsCyclotomic );


#############################################################################
##
#V  LargestUnknown  . . . . . . . . . . . . largest used index for an unknown
##
##  <#GAPDoc Label="LargestUnknown">
##  <ManSection>
##  <Var Name="LargestUnknown"/>
##
##  <Description>
##  <Ref Var="LargestUnknown"/> is the largest <A>n</A> that is used in any
##  <C>Unknown( <A>n</A> )</C> in the current &GAP; session.
##  This is used in <Ref Oper="Unknown"/> which increments this value
##  when asked to make a new unknown.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
LargestUnknown := 0;


#############################################################################
##
#O  Unknown( [<n>] )
##
##  <#GAPDoc Label="Unknown">
##  <ManSection>
##  <Oper Name="Unknown" Arg='[n]'/>
##
##  <Description>
##  Called without argument, <Ref Oper="Unknown"/> returns a new unknown
##  value, i.e., the first one that is larger than all unknowns which exist
##  in the current &GAP; session.
##  <P/>
##  Called with a positive integer <A>n</A>, <Ref Oper="Unknown"/> returns
##  the <A>n</A>-th unknown; if this did not exist yet, it is created.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "Unknown", [] );
DeclareOperation( "Unknown", [ IsPosInt ] );
