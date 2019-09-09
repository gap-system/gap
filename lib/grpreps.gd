#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#O  AbsolutelyIrreducibleModules( <G>, <F>, <dim> )
#O  AbsoluteIrreducibleModules( <G>, <F>, <dim> )
#O  AbsolutIrreducibleModules( <G>, <F>, <dim> )
##
##  <#GAPDoc Label="AbsoluteIrreducibleModules">
##  <ManSection>
##  <Oper Name="AbsolutelyIrreducibleModules" Arg='G, F, dim'/>
##  <Oper Name="AbsoluteIrreducibleModules" Arg='G, F, dim'/>
##  <Oper Name="AbsolutIrreducibleModules" Arg='G, F, dim'/>
##
##  <Description>
##  returns a list of length 2. The first entry is a generating system of
##  <A>G</A>. The second entry is a list of all absolute irreducible modules of
##  <A>G</A> over the field <A>F</A> in dimension <A>dim</A>, given as MeatAxe modules
##  (see&nbsp;<Ref Func="GModuleByMats" Label="for generators and a field"/>).
##  The other two names are just synonyms.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AbsolutIrreducibleModules",   [ IsGroup, IsField, IsInt ] );
DeclareSynonym(   "AbsoluteIrreducibleModules",   AbsolutIrreducibleModules  );
DeclareSynonym(   "AbsolutelyIrreducibleModules", AbsolutIrreducibleModules  );

#############################################################################
##
#O  IrreducibleModules( <G>, <F>, <dim> )
##
##  <#GAPDoc Label="IrreducibleModules">
##  <ManSection>
##  <Oper Name="IrreducibleModules" Arg='G, F, dim'/>
##
##  <Description>
##  returns a list of length 2. The first entry is a generating system of
##  <A>G</A>. The second entry is a list of all irreducible modules of
##  <A>G</A> over the field <A>F</A> in dimension <A>dim</A>, given as MeatAxe modules
##  (see&nbsp;<Ref Func="GModuleByMats" Label="for generators and a field"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "IrreducibleModules", [ IsGroup, IsField, IsInt ] );

#############################################################################
##
#O  RegularModule( <G>, <F> )
##
##  <#GAPDoc Label="RegularModule">
##  <ManSection>
##  <Oper Name="RegularModule" Arg='G, F'/>
##
##  <Description>
##  returns a list of length 2. The first entry is a generating system of
##  <A>G</A>.
##  The second entry is the regular module of <A>G</A> over <A>F</A>,
##  given as a MeatAxe module
##  (see&nbsp;<Ref Func="GModuleByMats" Label="for generators and a field"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "RegularModule", [ IsGroup, IsField ] );

#############################################################################
DeclareGlobalFunction( "RegularModuleByGens" );
