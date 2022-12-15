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

DeclareInfoClass( "InfoRandIso" );
DeclareAttribute( "OmegaAndLowerPCentralSeries", IsGroup );

#############################################################################
##
#F  CodePcgs( <pcgs> )
##
##  <#GAPDoc Label="CodePcgs">
##  <ManSection>
##  <Func Name="CodePcgs" Arg='pcgs'/>
##
##  <Description>
##  returns the code corresponding to <A>pcgs</A>.
##  <Example><![CDATA[
##  gap> G := CyclicGroup(512);;
##  gap> p := Pcgs( G );;
##  gap> CodePcgs( p );
##  162895587718739690298008513020159
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CodePcgs" );

#############################################################################
##
#F  CodePcGroup( <G> )
##
##  <#GAPDoc Label="CodePcGroup">
##  <ManSection>
##  <Func Name="CodePcGroup" Arg='G'/>
##
##  <Description>
##  returns the code for a pcgs of <A>G</A>.
##  <Example><![CDATA[
##  gap> G := DihedralGroup(512);;
##  gap> CodePcGroup( G );
##  2940208627577393070560341803949986912431725641726
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "CodePcGroup" );

#############################################################################
##
#F  PcGroupCode( <code>, <size> )
##
##  <#GAPDoc Label="PcGroupCode">
##  <ManSection>
##  <Func Name="PcGroupCode" Arg='code, size'/>
##
##  <Description>
##  returns a pc group of size <A>size</A> corresponding to <A>code</A>.
##  The argument <A>code</A> must be a valid code for a pcgs,
##  otherwise anything may happen.
##  Valid codes are usually obtained by one of the functions
##  <Ref Func="CodePcgs"/> or <Ref Func="CodePcGroup"/>.
##  <Example><![CDATA[
##  gap> G := SmallGroup( 24, 12 );;
##  gap> p := Pcgs( G );;
##  gap> code := CodePcgs( p );
##  5790338948
##  gap> H := PcGroupCode( code, 24 );
##  <pc group of size 24 with 4 generators>
##  gap> map := GroupHomomorphismByImages( G, H, p, FamilyPcgs(H) );
##  Pcgs([ f1, f2, f3, f4 ]) -> Pcgs([ f1, f2, f3, f4 ])
##  gap> IsBijective(map);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "PcGroupCode" );

#############################################################################
##
#F  PcGroupCodeRec( <rec> )
##
##  <ManSection>
##  <Func Name="PcGroupCodeRec" Arg='record'/>
##
##  <Description>
##  Here <A>record</A> needs to have entries .code and .order.
##  Then <Ref Func="PcGroupCode"/> returns a pc group of size .order
##  corresponding to .code.
##  <Example><![CDATA[
##  gap> G := SmallGroup( 24, 12 );;
##  gap> p := Pcgs( G );;
##  gap> coderec:=rec( code:=CodePcgs(p), order:=Size(G) );
##  rec( code := 5790338948, order := 24 )
##  gap> H := PcGroupCodeRec( coderec );
##  <pc group of size 24 with 4 generators>
##  gap> map := GroupHomomorphismByImages( G, H, p, FamilyPcgs(H) );
##  Pcgs([ f1, f2, f3, f4 ]) -> Pcgs([ f1, f2, f3, f4 ])
##  gap> IsBijective(map);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "PcGroupCodeRec" );


#############################################################################
##
#F  RandomSpecialPcgsCoded( <G> )
##
##  <ManSection>
##  <Func Name="RandomSpecialPcgsCoded" Arg='G'/>
##
##  <Description>
##  returns a code for a random special pcgs of <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "RandomSpecialPcgsCoded" );

#############################################################################
##
#F  RandomIsomorphismTest( <list>, <n> )
##
##  <#GAPDoc Label="RandomIsomorphismTest">
##  <ManSection>
##  <Func Name="RandomIsomorphismTest" Arg='coderecs, n'/>
##
##  <Description>
##  The first argument is a list <A>coderecs</A> containing records describing
##  groups, and the second argument is a non-negative integer <A>n</A>.
##  <P/>
##  The test returns a sublist of <A>coderecs</A> where isomorphic copies
##  detected by the probabilistic test have been removed.
##  <P/>
##  The list <A>coderecs</A> should contain records with two components,
##  <C>code</C> and <C>order</C>, describing a group via
##  <C>PcGroupCode( code, order )</C> (see <Ref Func="PcGroupCode"/>).
##  <P/>
##  The integer <A>n</A> gives a certain amount of control over the
##  probability to detect all isomorphisms. If it is <M>0</M>, then nothing
##  will be done at all. The larger <A>n</A> is, the larger is the probability
##  of finding all isomorphisms. However, due to the underlying method we
##  cannot guarantee that the algorithm finds all isomorphisms, no matter how
##  large <A>n</A> is.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RandomIsomorphismTest" );

#############################################################################
##
#F  ReducedByIsomorphism( <list>, <n> )
##
##  <ManSection>
##  <Func Name="ReducedByIsomorphism" Arg='list, n'/>
##
##  <Description>
##  returns a list of disjoint sublist of <A>list</A> such that no two isomorphic
##  groups can be in the same sublist.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "ReducedByIsomorphisms" );
