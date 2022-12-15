#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations of operations for the 1-Cohomology
##


#############################################################################
##
#V  InfoCoh
##
##  <#GAPDoc Label="InfoCoh">
##  <ManSection>
##  <InfoClass Name="InfoCoh"/>
##
##  <Description>
##  The info class for the cohomology calculations is
##  <Ref InfoClass="InfoCoh"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoCoh");


#############################################################################
##
#O  TriangulizedGeneratorsByMatrix( <gens>, <M>, <F> )
##                                                  triangulize and make base
##
##  <ManSection>
##  <Oper Name="TriangulizedGeneratorsByMatrix" Arg='gens, M, F'/>
##
##  <Description>
##  AKA <C>AbstractBaseMat</C>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("TriangulizedGeneratorsByMatrix");


##  For all following functions, the group is given as second argument to
##  allow dispatching after the group type

#############################################################################
##
#O  OCAddGenerators( <ocr>, <G> ) . . . . . . . . . . . add generators, local
##
##  <ManSection>
##  <Oper Name="OCAddGenerators" Arg='ocr, G'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "OCAddGenerators" );

#############################################################################
##
#O  OCAddMatrices( <ocr>, <gens> )  . . . . . . add operation matrices, local
##
##  <ManSection>
##  <Oper Name="OCAddMatrices" Arg='ocr, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "OCAddMatrices" );

#############################################################################
##
#O  OCAddToFunctions( <ocr> )  . . . . add operation matrices, local
##
##  <ManSection>
##  <Oper Name="OCAddToFunctions" Arg='ocr'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction( "OCAddToFunctions" );
DeclareOperation( "OCAddToFunctions2", [IsRecord, IsListOrCollection] );


#############################################################################
##
#O  OCAddRelations( <ocr>,<gens> ) . . . . . . . . . .  add relations, local
##
##  <ManSection>
##  <Oper Name="OCAddRelations" Arg='ocr,gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "OCAddRelations",
  [IsRecord, IsListOrCollection] );

#############################################################################
##
#O  OCNormalRelations( <ocr>,<G>,<gens> )  rels for normal complements, local
##
##  <ManSection>
##  <Oper Name="OCNormalRelations" Arg='ocr,G,gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "OCNormalRelations",
  [IsRecord,IsGroup,IsListOrCollection] );


#############################################################################
##
#O  OCAddSumMatrices( <ocr>, <gens> )  . . . . . . . . . . . add sums, local
##
##  <ManSection>
##  <Oper Name="OCAddSumMatrices" Arg='ocr, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation("OCAddSumMatrices",
  [IsRecord,IsListOrCollection]);


#############################################################################
##
#O  OCAddBigMatrices( <ocr>, <gens> )  . . . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="OCAddBigMatrices" Arg='ocr, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "OCAddBigMatrices",
  [IsRecord,IsListOrCollection] );


#############################################################################
##
#O  OCCoprimeComplement( <ocr>, <gens> ) . . . . . . . .  coprime complement
##
##  <ManSection>
##  <Oper Name="OCCoprimeComplement" Arg='ocr, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "OCCoprimeComplement",
  [IsRecord,IsListOrCollection] );


#############################################################################
##
#O  OneCoboundaries( <G>, <M> ) . . . . . . . . . . one cobounds of <G> / <M>
##
##  <#GAPDoc Label="OneCoboundaries">
##  <ManSection>
##  <Func Name="OneCoboundaries" Arg='G, M'/>
##
##  <Description>
##  computes the group of 1-coboundaries.
##  Syntax of input and output otherwise is the same as with
##  <Ref Func="OneCocycles" Label="for two groups"/> except that entries that
##  refer to cocycles are not computed.
##  <P/>
##  The operations <Ref Func="OneCocycles" Label="for two groups"/> and
##  <Ref Func="OneCoboundaries"/> return a record with
##  (at least) the components:
##  <P/>
##  <List>
##  <Mark><C>generators</C></Mark>
##  <Item>
##  Is a list of representatives for a generating set of <A>G</A>/<A>M</A>.
##  Cocycles are represented with respect to these generators.
##  </Item>
##  <Mark><C>oneCocycles</C></Mark>
##  <Item>
##  A space of row vectors over GF(<M>p</M>), representing <M>Z^1</M>.
##  The vectors are represented in dimension <M>a \cdot b</M> where <M>a</M>
##  is the length of <C>generators</C> and <M>p^b</M> the size of <A>M</A>.
##  </Item>
##  <Mark><C>oneCoboundaries</C></Mark>
##  <Item>
##  A space of row vectors that represents <M>B^1</M>.
##  </Item>
##  <Mark><C>cocycleToList</C></Mark>
##  <Item>
##  is a function to convert a cocycle (a row vector in <C>oneCocycles</C>) to
##  a corresponding list of elements of <A>M</A>.
##  </Item>
##  <Mark><C>listToCocycle</C></Mark>
##  <Item>
##  is a function to convert a list of elements of <A>M</A> to a cocycle.
##  </Item>
##  <Mark><C>isSplitExtension</C></Mark>
##  <Item>
##  indicates whether <A>G</A> splits over <A>M</A>.
##  The following components are only bound if the extension splits.
##  Note that if <A>M</A> is given by a modulo pcgs all subgroups are given
##  as subgroups of <A>G</A> by generators corresponding to <C>generators</C>
##  and thus may not contain the denominator of the modulo pcgs.
##  In this case taking the closure with this denominator will give the full
##  preimage of the complement in the factor group.
##  </Item>
##  <Mark><C>complement</C></Mark>
##  <Item>
##  One complement to <A>M</A> in <A>G</A>.
##  </Item>
##  <Mark><C>cocycleToComplement( cyc )</C></Mark>
##  <Item>
##  is a function that takes a cocycle from <C>oneCocycles</C> and returns
##  the corresponding complement to <A>M</A> in <A>G</A>
##  (with respect to the fixed complement <C>complement</C>).
##  </Item>
##  <Mark><C>complementToCocycle(<A>U</A>)</C></Mark>
##  <Item>
##  is a function that takes a complement and returns the corresponding
##  cocycle.
##  </Item>
##  </List>
##  <P/>
##  If the factor <A>G</A>/<A>M</A> is given by a (modulo) pcgs <A>gens</A>
##  then special methods are used that compute a presentation for the factor
##  implicitly from the pcgs.
##  <P/>
##  Note that the groups of 1-cocycles and 1-coboundaries are not groups in
##  the sense of <Ref Func="Group" Label="for several generators"/> for &GAP;
##  but vector spaces.
##  <P/>
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> n:=Group((1,2)(3,4),(1,3)(2,4));;
##  gap> oc:=OneCocycles(g,n);
##  rec( cocycleToComplement := function( c ) ... end,
##    cocycleToList := function( c ) ... end,
##    complement := Group([ (3,4), (2,4,3) ]),
##    complementGens := [ (3,4), (2,4,3) ],
##    complementToCocycle := function( K ) ... end,
##    factorGens := [ (3,4), (2,4,3) ], generators := [ (3,4), (2,4,3) ],
##    isSplitExtension := true, listToCocycle := function( L ) ... end,
##    oneCoboundaries := <vector space over GF(2), with 2 generators>,
##    oneCocycles := <vector space over GF(2), with 2 generators> )
##  gap> oc.cocycleToList([ 0*Z(2), Z(2)^0, 0*Z(2), Z(2)^0 ]);
##  [ (1,2)(3,4), (1,2)(3,4) ]
##  gap> oc.listToCocycle([(),(1,3)(2,4)]) = Z(2) * [ 0, 0, 1, 0];
##  true
##  gap> oc.cocycleToComplement([ 0*Z(2), 0*Z(2), Z(2)^0, 0*Z(2) ]);
##  Group([ (3,4), (1,3,4) ])
##  gap> oc.complementToCocycle(Group((1,2,4),(1,4))) = Z(2) * [ 0, 1, 1, 1 ];
##  true
##  ]]></Example>
##  <P/>
##  The factor group
##  <M>H^1(<A>G</A>/<A>M</A>, <A>M</A>) =
##  Z^1(<A>G</A>/<A>M</A>, <A>M</A>) / B^1(<A>G</A>/<A>M</A>, <A>M</A>)</M>
##  is called the first cohomology group.
##  Currently there is no function which explicitly computes this group.
##  The easiest way to represent it is as a vector space complement to
##  <M>B^1</M> in <M>Z^1</M>.
##  <P/>
##  If the only purpose of the calculation of <M>H^1</M> is the determination
##  of complements it might be desirable to stop calculations
##  once it is known that the extension cannot split.
##  This can be achieved via the more technical function
##  <Ref Func="OCOneCocycles"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OneCoboundaries" );


#############################################################################
##
#O  OneCocycles( <G>, <M> )
#O  OneCocycles( <gens>, <M> )
#O  OneCocycles( <G>, <mpcgs> )
#O  OneCocycles( <gens>, <mpcgs> )
##
##  <#GAPDoc Label="OneCocycles">
##  <ManSection>
##  <Heading>OneCocycles</Heading>
##  <Func Name="OneCocycles" Arg='G, M' Label="for two groups"/>
##  <Func Name="OneCocycles" Arg='G, mpcgs' Label="for a group and a pcgs"/>
##  <Func Name="OneCocycles" Arg='gens, M'
##   Label="for generators and a group"/>
##  <Func Name="OneCocycles" Arg='gens, mpcgs'
##   Label="for generators and a pcgs"/>
##
##  <Description>
##  Computes the group of 1-cocycles <M>Z^1(<A>G</A>/<A>M</A>,<A>M</A>)</M>.
##  The normal subgroup <A>M</A> may be given by a (Modulo)Pcgs <A>mpcgs</A>.
##  In this case the whole calculation is performed modulo the normal
##  subgroup defined by <C>DenominatorOfModuloPcgs(<A>mpcgs</A>)</C>
##  (see&nbsp;<Ref Sect="Polycyclic Generating Systems"/>).
##  Similarly the group <A>G</A> may instead be specified by a set of
##  elements <A>gens</A> that are representatives for a generating system for
##  the factor group <A>G</A>/<A>M</A>.
##  If this is done the 1-cocycles are computed
##  with respect to these generators (otherwise the routines try to select
##  suitable generators themselves).
##  The current version of the code assumes that <A>G</A> is a permutation
##  group or a pc group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "OneCocycles" );


#############################################################################
##
#O  OCOneCoboundaries( <ocr> )  . . . . . . . . . . one cobounds main routine
##
##  <ManSection>
##  <Oper Name="OCOneCoboundaries" Arg='ocr'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("OCOneCoboundaries");


#############################################################################
##
#O  OCConjugatingWord( <ocr>, <c1>, <c2> )  . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="OCConjugatingWord" Arg='ocr, c1, c2'/>
##
##  <Description>
##  Compute a Word n in <A>ocr.module</A> such that <A>c1</A> ^ n = <A>c2</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("OCConjugatingWord");


#############################################################################
##
#O  OCEquationMatrix( <ocr>, <r>, <n> )  . . . . . . . . . . . . . . .  local
##
##  <ManSection>
##  <Oper Name="OCEquationMatrix" Arg='ocr, r, n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("OCEquationMatrix");


#############################################################################
##
#O  OCSmallEquationMatrix( <ocr>, <r>, <n> )  . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="OCSmallEquationMatrix" Arg='ocr, r, n'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("OCSmallEquationMatrix");


#############################################################################
##
#O  OCEquationVector( <ocr>, <r> )  . . . . . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="OCEquationVector" Arg='ocr, r'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("OCEquationVector");


#############################################################################
##
#O  OCSmallEquationVector( <ocr>, <r> ) . . . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="OCSmallEquationVector" Arg='ocr, r'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("OCSmallEquationVector");


#############################################################################
##
#O  OCAddComplement( <ocr>, <ocr.group>, <K> ) . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="OCAddComplement" Arg='ocr, ocr.group, K'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation("OCAddComplement",
  [IsRecord,IsGroup,IsListOrCollection]);


#############################################################################
##
#O  OCOneCocycles( <ocr>, <onlySplit> ) . . . . . . one cocycles main routine
##
##  <#GAPDoc Label="OCOneCocycles">
##  <ManSection>
##  <Func Name="OCOneCocycles" Arg='ocr, onlySplit'/>
##
##  <Description>
##  is the more technical function to compute 1-cocycles. It takes a record
##  <A>ocr</A> as first argument which must contain at least the components
##  <C>group</C> for the group and <C>modulePcgs</C> for a (modulo) pcgs of
##  the module. This record
##  will also be returned with components as described under
##  <Ref Func="OneCocycles" Label="for two groups"/>
##  (with the exception of <C>isSplitExtension</C> which is indicated by the
##  existence of a <C>complement</C>)
##  but components such as <C>oneCoboundaries</C> will only be
##  computed if not already present.
##  <P/>
##  If <A>onlySplit</A> is <K>true</K>,
##  <Ref Func="OCOneCocycles"/> returns <K>false</K> as soon as
##  possible if the extension does not split.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("OCOneCocycles");


#############################################################################
##
#O  ComplementClassesRepresentativesEA(<G>,<N>) . complement classes to el.ab. N by 1-Cohom.
##
##  <#GAPDoc Label="ComplementClassesRepresentativesEA">
##  <ManSection>
##  <Func Name="ComplementClassesRepresentativesEA" Arg='G, N'/>
##
##  <Description>
##  computes complement classes to an elementary abelian normal subgroup
##  <A>N</A> via 1-Cohomology. Normally, a user program should call
##  <Ref Oper="ComplementClassesRepresentatives"/> instead, which also works
##  for a solvable (not necessarily elementary abelian) <A>N</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ComplementClassesRepresentativesEA");


#############################################################################
##
#o  OCPPrimeSets( <U> ) . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Construct  a  generating  set, which has the generators of Hall-subgroups
##  of a Sylow complement system as sublist.
##
#T DeclareGlobalFunction("OCPPrimeSets");
#T up to now no function is installed
