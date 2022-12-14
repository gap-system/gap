#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
#F  AbelianPQuotient  . . . . . . . . . . .  initialize an abelian p-quotient
##
##  <ManSection>
##  <Func Name="AbelianPQuotient" Arg='qs'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "AbelianPQuotient" );


#############################################################################
##
#F  PQuotient(<F>, <p>[, <c>][, <logord>][, <ctype>])  . .  pq of an fp group
##
##  <#GAPDoc Label="PQuotient">
##  <ManSection>
##  <Func Name="PQuotient" Arg='F, p[, c][, logord][, ctype]'/>
##
##  <Description>
##  computes a factor <A>p</A>-group of a finitely presented group <A>F</A>
##  in form  of a quotient system.
##  The quotient system can be converted into an epimorphism from <A>F</A>
##  onto the <A>p</A>-group computed by the function
##  <Ref Oper="EpimorphismQuotientSystem"/>.
##  <P/>
##  For a group <M>G</M> define the exponent-<M>p</M> central series of
##  <M>G</M> inductively by <M>{\cal P}_1(G) = G</M> and
##  <M>{\cal P}_{{i+1}}(G) = [{\cal P}_i(G),G]{\cal P}_{{i+1}}(G)^p</M>.
##  The factor groups modulo the terms of the lower
##  exponent-<M>p</M> central series are <M>p</M>-groups.
##  The group <M>G</M> has <M>p</M>-class
##  <M>c</M> if <M>{\cal P}_c(G) \neq {\cal P}_{{c+1}}(G) = 1</M>.
##  <P/>
##  The algorithm computes successive quotients modulo the terms of the
##  exponent-<M>p</M> central series of <A>F</A>.
##  If the parameter <A>c</A> is present,
##  then the factor group modulo the <M>(c+1)</M>-th term of the
##  exponent-<M>p</M> central series of <A>F</A> is returned.
##  If <A>c</A> is not present, then the algorithm attempts to compute the
##  largest factor <A>p</A>-group of <A>F</A>.
##  In case <A>F</A> does not have a largest factor <A>p</A>-group,
##  the algorithm will not terminate.
##  <P/>
##  By default the algorithm computes only with factor groups of order at
##  most <M>p^{256}</M>. If the parameter <A>logord</A> is present, it will
##  compute with factor groups of order at most <M>p^{<A>logord</A>}</M>.
##  If this parameter is specified, then the parameter <A>c</A> must also be
##  given.  The present
##  implementation produces an error message if the order of a
##  <M>p</M>-quotient exceeds <M>p^{256}</M> or <M>p^{<A>logord</A>}</M>,
##  respectively.
##  Note that the order of intermediate <M>p</M>-groups may be larger than
##  the final order of a <M>p</M>-quotient.
##  <P/>
##  The parameter <A>ctype</A> determines the type of collector that is used
##  for computations within the factor <A>p</A>-group.
##  <A>ctype</A> must either be <C>"single"</C> in which case a simple
##  collector from the left is used or <C>"combinatorial"</C> in which case
##  a combinatorial collector from the left is used.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PQuotient" );


#############################################################################
##
#O  EpimorphismPGroup( <fpgrp>, <p>[, <cl>] )  factor p-group of a f.p. group
##
##  <#GAPDoc Label="EpimorphismPGroup">
##  <ManSection>
##  <Oper Name="EpimorphismPGroup" Arg='fpgrp, p[, cl]'/>
##
##  <Description>
##  computes an epimorphism from the finitely presented group <A>fpgrp</A> to
##  the largest <M>p</M>-group of <M>p</M>-class <A>cl</A> which is
##  a quotient of <A>fpgrp</A>.
##  If <A>cl</A> is omitted, the largest finite <M>p</M>-group quotient
##  (of <M>p</M>-class up to <M>1000</M>) is determined.
##  <P/>
##  <Example><![CDATA[
##  gap> hom:=EpimorphismPGroup(fp,2);
##  [ f1, f2 ] -> [ a1, a2 ]
##  gap> Size(Image(hom));
##  8
##  gap> hom:=EpimorphismPGroup(fp,3,7);
##  [ f1, f2 ] -> [ a1, a2 ]
##  gap> Size(Image(hom));
##  6561
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "EpimorphismPGroup", [IsGroup, IsPosInt ] );
DeclareOperation( "EpimorphismPGroup", [IsGroup, IsPosInt, IsPosInt] );


#############################################################################
##
#O  EpimorphismQuotientSystem(<quotsys>)
##
##  <#GAPDoc Label="EpimorphismQuotientSystem">
##  <ManSection>
##  <Oper Name="EpimorphismQuotientSystem" Arg='quotsys'/>
##
##  <Description>
##  For a quotient system <A>quotsys</A> obtained from the function
##  <Ref Func="PQuotient"/>, this operation returns an epimorphism
##  <M><A>F</A> \rightarrow <A>P</A></M> where <M><A>F</A></M> is the
##  finitely presented group of which <A>quotsys</A> is a quotient system and
##  <M><A>P</A></M> is a pc group isomorphic to the quotient of <A>F</A>
##  determined by <A>quotsys</A>.
##  <P/>
##  Different calls to this operation will create different groups <A>P</A>,
##  each with its own family.
##  <P/>
##  <Example><![CDATA[
##  gap> PQuotient( FreeGroup(2), 5, 10, 1024, "combinatorial" );
##  <5-quotient system of 5-class 10 with 520 generators>
##  gap> phi := EpimorphismQuotientSystem( last );
##  [ f1, f2 ] -> [ a1, a2 ]
##  gap> Collected( Factors( Size( Image( phi ) ) ) );
##  [ [ 5, 520 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "EpimorphismQuotientSystem", [IsQuotientSystem] );


#############################################################################
##
#F  EpimorphismNilpotentQuotient( <fpgrp>[, <n>] )
##
##  <#GAPDoc Label="EpimorphismNilpotentQuotient">
##  <ManSection>
##  <Func Name="EpimorphismNilpotentQuotient" Arg='fpgrp[, n]'/>
##
##  <Description>
##  returns an epimorphism on the class <A>n</A> finite nilpotent quotient of
##  the finitely presented group <A>fpgrp</A>.
##  If <A>n</A> is omitted, the largest finite nilpotent quotient
##  (of <M>p</M>-class up to <M>1000</M>) is taken.
##  <P/>
##  <Example><![CDATA[
##  gap> hom:=EpimorphismNilpotentQuotient(fp,7);
##  [ f1, f2 ] -> [ f1*f4, f2*f5 ]
##  gap> Size(Image(hom));
##  52488
##  ]]></Example>
##  <P/>
##  A related operation which is also applicable to finitely presented groups is
##  <Ref Oper="GQuotients"/>, which computes all epimorphisms from a
##  (finitely presented) group <A>F</A> onto a given (finite) group <A>G</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> GQuotients(fp,Group((1,2,3),(1,2)));
##  [ [ f1, f2 ] -> [ (1,2), (2,3) ], [ f1, f2 ] -> [ (2,3), (1,2,3) ],
##    [ f1, f2 ] -> [ (1,2,3), (2,3) ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("EpimorphismNilpotentQuotientOp",[IsGroup,IsObject]);
DeclareGlobalFunction("EpimorphismNilpotentQuotient");


#############################################################################
##
#O  Nucleus . . . . . . . . . . . . . . . . . . . .  the nucleus of a p-cover
##
##  <ManSection>
##  <Func Name="Nucleus" Arg='pq, G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation("Nucleus",[IsPQuotientSystem,IsGroup]);
