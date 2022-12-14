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
#I  InfoSQ
##
DeclareInfoClass( "InfoSQ" );

#############################################################################
##
#F  PcGroupFpGroup( <G> )
##
##  <#GAPDoc Label="PcGroupFpGroup">
##  <ManSection>
##  <Func Name="PcGroupFpGroup" Arg='G'/>
##
##  <Description>
##  creates a pc group <A>P</A> from an fp group
##  (see Chapter <Ref Chap="Finitely Presented Groups"/>) <A>G</A>
##  whose presentation is polycyclic. The resulting group <A>P</A>
##  has generators corresponding to the generators of <A>G</A>.
##  They are printed in the same way as generators of <A>G</A>,
##  but they lie in a different family.
##  If the pc presentation of <A>G</A> is not confluent,
##  an error message occurs.
##  <P/>
##  <Example><![CDATA[
##  gap> F := FreeGroup(IsSyllableWordsFamily,"a","b","c","d");;
##  gap> a := F.1;; b := F.2;; c := F.3;; d := F.4;;
##  gap> rels := [a^2, b^3, c^2, d^2, Comm(b,a)/b, Comm(c,a)/d, Comm(d,a),
##  >             Comm(c,b)/(c*d), Comm(d,b)/c, Comm(d,c)];
##  [ a^2, b^3, c^2, d^2, b^-1*a^-1*b*a*b^-1, c^-1*a^-1*c*a*d^-1,
##    d^-1*a^-1*d*a, c^-1*b^-1*c*b*d^-1*c^-1, d^-1*b^-1*d*b*c^-1,
##    d^-1*c^-1*d*c ]
##  gap> G := F / rels;
##  <fp group on the generators [ a, b, c, d ]>
##  gap> H := PcGroupFpGroup( G );
##  <pc group of size 24 with 4 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
#T  should this become a method?
##
DeclareGlobalFunction( "PcGroupFpGroup" );
DeclareGlobalFunction( "PcGroupFpGroupNC" );

#############################################################################
##
#F  InitEpimorphismSQ( F )
#F  InitEpimorphismSQ(<hom>)
##
##  <ManSection>
##  <Func Name="InitEpimorphismSQ" Arg='F'/>
##  <Func Name="InitEpimorphismSQ" Arg='hom'/>
##
##  <Description>
##  If <A>F</A> is a finitiely presented group, this operation returns the SQ
##  epimorphism system corresponding to the largest abelian quotient of
##  <A>F</A>.
##  If <A>hom</A> is a epimorphism from a finitely presented group to a pc
##  group, it returns the system corresponding to this epimorphism.
##  No argument checking is performed.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "InitEpimorphismSQ" );

#############################################################################
##
#F  LiftEpimorphismSQ( epi, M, c )
##
##  <ManSection>
##  <Func Name="LiftEpimorphismSQ" Arg='epi, M, c'/>
##
##  <Description>
##  if c is an integer, split extensions are searched. if c=0 only one is
##  returned, otherwise the subdirect product of all such extensions is
##  found.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "LiftEpimorphismSQ" );

#############################################################################
##
#F  BlowUpCocycleSQ( v, K, F )
##
##  <ManSection>
##  <Func Name="BlowUpCocycleSQ" Arg='v, K, F'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "BlowUpCocycleSQ" );

#############################################################################
##
#F  TryModuleSQ( epi, M )
##
##  <ManSection>
##  <Func Name="TryModuleSQ" Arg='epi, M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "TryModuleSQ" );

#############################################################################
##
#F  TryLayerSQ( epi, layer )
##
##  <ManSection>
##  <Func Name="TryLayerSQ" Arg='epi, layer'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "TryLayerSQ" );

#############################################################################
##
#F  SolvableQuotient(<F>,<size> )
#F  SolvableQuotient(<F>,<primes> )
#F  SolvableQuotient(<F>,<tuples> )
#F  SQ(<F>,<...> )
##
##  <#GAPDoc Label="SolvableQuotient">
##  <Heading>SolvableQuotient</Heading>
##  <ManSection>
##  <Func Name="SolvableQuotient" Arg='F, size'
##   Label="for a f.p. group and a size"/>
##  <Func Name="SolvableQuotient" Arg='F, primes'
##   Label="for a f.p. group and a list of primes"/>
##  <Func Name="SolvableQuotient" Arg='F, tuples'
##   Label="for a f.p. group and a list of tuples"/>
##  <Func Name="SQ" Arg='F, ...' Label="synonym of SolvableQuotient"/>
##
##  <Description>
##  This routine calls the solvable quotient algorithm for a finitely
##  presented group <A>F</A>.
##  The quotient to be found can be specified in the following ways:
##  Specifying an integer <A>size</A> finds a quotient of size up
##  to <A>size</A> (if such large quotients exist).
##  Specifying a list of primes in <A>primes</A> finds the largest quotient
##  involving the given primes.
##  Finally <A>tuples</A> can be used to prescribe a chief series.
##  <P/>
##  <Ref Func="SQ" Label="synonym of SolvableQuotient"/> can be used as a
##  synonym for
##  <Ref Func="SolvableQuotient" Label="for a f.p. group and a size"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SolvableQuotient" );
DeclareSynonym( "SQ", SolvableQuotient);

#############################################################################
##
#F  EpimorphismSolvableQuotient( <F>, <param> )
##
##  <#GAPDoc Label="EpimorphismSolvableQuotient">
##  <ManSection>
##  <Func Name="EpimorphismSolvableQuotient" Arg='F, param'/>
##
##  <Description>
##  computes an epimorphism from the finitely presented group <A>fpgrp</A>
##  to the largest solvable quotient given by <A>param</A> (specified as in
##  <Ref Func="SolvableQuotient" Label="for a f.p. group and a size"/>).
##  <P/>
##  <Example><![CDATA[
##  gap> f := FreeGroup( "a", "b", "c", "d" );;
##  gap> fp := f / [ f.1^2, f.2^2, f.3^2, f.4^2, f.1*f.2*f.1*f.2*f.1*f.2,
##  >  f.2*f.3*f.2*f.3*f.2*f.3*f.2*f.3, f.3*f.4*f.3*f.4*f.3*f.4,
##  > f.1^-1*f.3^-1*f.1*f.3, f.1^-1*f.4^-1*f.1*f.4,
##  > f.2^-1*f.4^-1*f.2*f.4 ];;
##  gap> hom:=EpimorphismSolvableQuotient(fp,300);Size(Image(hom));
##  [ a, b, c, d ] -> [ f1*f2, f1*f2, f2*f3, f2 ]
##  12
##  gap> hom:=EpimorphismSolvableQuotient(fp,[2,3]);Size(Image(hom));
##  [ a, b, c, d ] -> [ f1*f2*f4, f1*f2*f6*f8, f2*f3, f2 ]
##  1152
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("EpimorphismSolvableQuotient");

#############################################################################
##
#F  AllModulesSQ( epi, M )
##
##  <ManSection>
##  <Func Name="AllModulesSQ" Arg='epi, M'/>
##
##  <Description>
##  returns a list of all permissible extensions of <A>epi</A> with the module
##  <A>M</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("AllModulesSQ");

#############################################################################
##
#F  EAPrimeLayerSQ( epi, prime )
##
##  <ManSection>
##  <Func Name="EAPrimeLayerSQ" Arg='epi, prime'/>
##
##  <Description>
##  returns the largest elementary abelian <A>prime</A> layer extending <A>epi</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("EAPrimeLayerSQ");
