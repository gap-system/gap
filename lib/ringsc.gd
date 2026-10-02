#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains declarations for elements of rings, given as Z-modules
##  with structure constants for multiplication. It is based on algsc.gd
##

#############################################################################
##
#C  IsSCRingObj( <obj> )
#C  IsSCRingObjCollection( <obj> )
#C  IsSCRingObjFamily( <obj> )
##
##  S.~c. ring elements may have inverses, in order to allow `One' and
##  `Inverse' we make them scalars.
##
DeclareCategory( "IsSCRingObj", IsScalar );
DeclareCategoryCollections( "IsSCRingObj" );
DeclareCategoryCollections( "IsSCRingObjCollection" );
DeclareCategoryCollections( "IsSCRingObjCollColl" );
DeclareCategoryFamily( "IsSCRingObj" );

DeclareSynonym("IsSubringSCRing",IsRing and IsSCRingObjCollection);

#############################################################################
##
#F  RingByStructureConstants( <moduli>, <sctable>[, <nameinfo>] )
##
##  <#GAPDoc Label="RingByStructureConstants">
##  <ManSection>
##  <Func Name="RingByStructureConstants" Arg='moduli, sctable[, nameinfo]'/>
##
##  <Description>
##  returns a ring <M>R</M> whose additive group is described by the list
##  <A>moduli</A>,
##  with multiplication defined by the structure constants table
##  <A>sctable</A>.
##  The optional argument <A>nameinfo</A> can be used to prescribe names for
##  the elements of the canonical generators of <M>R</M>;
##  it can be either a string <A>name</A>
##  (then <A>name</A><C>1</C>, <A>name</A><C>2</C> etc. are chosen)
##  or a list of strings which are then chosen.
##  <Example><![CDATA[
##  gap> T:=EmptySCTable( 1, 0 );;
##  gap> SetEntrySCTable( T, 1, 1, [ 1, 1 ] );
##  gap> R:=RingByStructureConstants([9], T);   # Z/9Z
##  <ring with 1 generator>
##  gap> Elements(R);
##  [ 0*r.1, r.1, 2*r.1, 3*r.1, 4*r.1, 5*r.1, 6*r.1, 7*r.1, -r.1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "RingByStructureConstants" );

#############################################################################
##
#F  StandardGeneratorsSubringSCRing( <S> )
##
##  for a subring <S> of an SC ring <R> this command returns a list of length 3.
##  The first entries are generators for <S> as additive group, given with
##  respect to the additive group basis for <R> and being in hermite normal
##  form. The second entries are pivot positions for these generators. The third
##  entries are the generators as actual ring elements.
DeclareAttribute("StandardGeneratorsSubringSCRing",IsSubringSCRing);

#############################################################################
##
#A  Subrings( <R> )
##
##  <#GAPDoc Label="Subrings">
##  <ManSection>
##  <Attr Name="Subrings" Arg='R'/>
##
##  <Description>
##  for a finite ring <A>R</A> this function returns a list of all
##  subrings of <A>R</A>.
##  <Example><![CDATA[
##  gap> Subrings(SmallRing(8,37));
##  [ <ring with 1 generator>, <ring with 1 generator>,
##    <ring with 1 generator>, <ring with 1 generator>,
##    <ring with 1 generator>, <ring with 1 generator>,
##    <ring with 2 generators>, <ring with 2 generators>,
##    <ring with 2 generators>, <ring with 2 generators>,
##    <ring with 3 generators> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("Subrings",IsRing);

#############################################################################
##
#A  Ideals( <R> )
##
##  <#GAPDoc Label="Ideals">
##  <ManSection>
##  <Attr Name="Ideals" Arg='R'/>
##
##  <Description>
##  for a finite ring <A>R</A> this function returns a list of all
##  ideals of <A>R</A>.
##  <Example><![CDATA[
##  gap> Ideals(SmallRing(8,37));
##  [ <ring with 1 generator>, <ring with 1 generator>,
##    <ring with 1 generator>, <ring with 2 generators>,
##    <ring with 3 generators> ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("Ideals",IsRing);

#############################################################################
##
#F  NumberSmallRings( <s> )
##
##  <#GAPDoc Label="NumberSmallRings">
##  <ManSection>
##  <Func Name="NumberSmallRings" Arg='s'/>
##
##  <Description>
##  returns the number of (nonisomorphic) rings of order <M>s</M>
##  stored in the library of small rings.
##  <Example><![CDATA[
##  gap> List([1..15],NumberSmallRings);
##  [ 1, 2, 2, 11, 2, 4, 2, 52, 11, 4, 2, 22, 2, 4, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NumberSmallRings");

#############################################################################
##
#F  SmallRing( <s>,<n> )
##
##  <#GAPDoc Label="SmallRing">
##  <ManSection>
##  <Func Name="SmallRing" Arg='s n'/>
##
##  <Description>
##  returns the <M>n</M>-th ring of order <M>s</M> from a library of
##  rings of small order (up to isomorphism).
##  <Example><![CDATA[
##  gap> R:=SmallRing(8,37);
##  <ring with 3 generators>
##  gap> ShowMultiplicationTable(R);
##  *     | 0*a   c     b     b+c   a     a+c   a+b   a+b+c
##  ------+------------------------------------------------
##  0*a   | 0*a   0*a   0*a   0*a   0*a   0*a   0*a   0*a
##  c     | 0*a   0*a   0*a   0*a   0*a   0*a   0*a   0*a
##  b     | 0*a   0*a   0*a   0*a   b     b     b     b
##  b+c   | 0*a   0*a   0*a   0*a   b     b     b     b
##  a     | 0*a   c     b     b+c   a+b   a+b+c a     a+c
##  a+c   | 0*a   c     b     b+c   a+b   a+b+c a     a+c
##  a+b   | 0*a   c     b     b+c   a     a+c   a+b   a+b+c
##  a+b+c | 0*a   c     b     b+c   a     a+c   a+b   a+b+c
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("SmallRing");

#############################################################################
##
#F  DirectSum( <R>{, <S>} )
#O  DirectSumOp( <list>, <expl> )
##
##  <#GAPDoc Label="DirectSum">
##  <ManSection>
##  <Func Name="DirectSum" Arg='R{, S}'/>
##  <Oper Name="DirectSumOp" Arg='list, expl'/>
##
##  <Description>
##  These functions construct the direct sum of the rings given as
##  arguments.
##  <C>DirectSum</C> takes an arbitrary positive number of arguments
##  and calls the operation <C>DirectSumOp</C>, which takes exactly two
##  arguments, namely a nonempty list of rings and one of these rings.
##  (This somewhat strange syntax allows the method selection to choose
##  a reasonable method for special cases.)
##  <Example><![CDATA[
##  gap> R5 := SmallRing( 5, 2 );; SetName( R5, "R5" );
##  gap> R7 := SmallRing( 7, 2 );; SetName( R7, "R7" );
##  gap> R57 := DirectSum( R5, R7 );
##  <ring with 2 generators>
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DirectSum" );
DeclareOperation( "DirectSumOp", [ IsList, IsRing ] );

#############################################################################
##
#A  DirectSumInfo( <R> )
##
##  <#GAPDoc Label="DirectSumInfo:rings">
##  <ManSection>
##  <Attr Name="DirectSumInfo" Arg='R'/>
##
##  <Description>
##  A direct sum of rings comes equipped with an information record
##  having fields <A>rings</A>; <A>first</A>;
##  <A>embeddings</A> and <A>projections</A>.
##  <P/>
##  As embeddings and projections are created (see below)
##  they are stored in the fields <A>embeddings</A> and <A>projections</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> DirectSumInfo( R57 );
##  rec( embeddings := [  ], first := [ 0, 1, 2 ], projections := [  ],
##    rings := [ R5, R7 ] )
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareAttribute( "DirectSumInfo", IsRing, "mutable" );

#############################################################################
##
#A  Embedding( <R> <i> )
##
##  <#GAPDoc Label="Embedding:rings">
##  <ManSection>
##  <Attr Name="Embedding" Arg='R i'
##    Label="for a direct sum of rings and a positive integer"/>
##
##  <Description>
##  If ring <M>R</M> is the direct sum of rings <M>[R_1,\ldots,R_k]</M>
##  then <A>Embedding(R,i)</A> for <M>1 \leq i \leq k</M> returns a ring
##  homomorphism mapping <M>R_i</M> into <M>R</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> emb1 := Embedding( R12, 1 );
##  [ a ] -> [ Aa ]
##  gap> a := GeneratorsOfRing(R1)[1];;
##  gap> ImageElm( emb1, 3*a );
##  3*Aa
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

#############################################################################
##
#A  Projection( <R> <i> )
##
##  <#GAPDoc Label="Projection:rings">
##  <ManSection>
##  <Attr Name="Projection" Arg='R i'
##    Label="for a direct sum of rings and a positive integer"/>
##
##  <Description>
##  If ring <M>R</M> is the direct sum of rings <M>[R_1,\ldots,R_k]</M>
##  then <A>Projection(R,i)</A> for <M>1 \leq i \leq k</M> returns a ring
##  homomorphism mapping <M>R</M> onto <M>R_i</M>.
##  <P/>
##  <Example><![CDATA[
##  gap> pro2 := Projection( R12, 2 );
##  [ Aa, Ba ] -> [ 0*a, a ]
##  gap> b := GeneratorsOfRing(R12)[2];;
##  gap> ImageElm( pro2, 4*b );
##  4*a
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
