#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Volkmar Felsch.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for finitely presented groups
##  (fp groups).
##


############################################################################
##
#F  AbelianInvariantsNormalClosureFpGroupRrs(<G>,<H>)
##
##  <#GAPDoc Label="AbelianInvariantsNormalClosureFpGroupRrs">
##  <ManSection>
##  <Func Name="AbelianInvariantsNormalClosureFpGroupRrs" Arg='G, H'/>
##
##  <Description>
##  uses the Reduced Reidemeister-Schreier method to compute the abelian
##  invariants of the normal closure of a subgroup <A>H</A> of a finitely
##  presented group <A>G</A>.
##  See <Ref Sect="Subgroup Presentations"/> for details on the different
##  strategies.
##  <P/>
##  The following example shows a calculation for the Coxeter group
##  <M>B_1</M>.
##  This calculation and a similar one for <M>B_0</M> have been used
##  to prove that <M>B_1' / B_1'' \cong Z_2^9 \times Z^3</M> and
##  <M>B_0' / B_0'' \cong Z_2^{91} \times Z^{27}</M> as stated in
##  in <Cite Key="FJNT95" Where="Proposition 5"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> # Define the Coxeter group E1.
##  gap> F := FreeGroup( "x1", "x2", "x3", "x4", "x5" );
##  <free group on the generators [ x1, x2, x3, x4, x5 ]>
##  gap> x1 := F.1;; x2 := F.2;; x3 := F.3;; x4 := F.4;; x5 := F.5;;
##  gap> rels := [ x1^2, x2^2, x3^2, x4^2, x5^2,
##  >  (x1 * x3)^2, (x2 * x4)^2, (x1 * x2)^3, (x2 * x3)^3, (x3 * x4)^3,
##  >  (x4 * x1)^3, (x1 * x5)^3, (x2 * x5)^2, (x3 * x5)^3, (x4 * x5)^2,
##  >  (x1 * x2 * x3 * x4 * x3 * x2)^2 ];;
##  gap> E1 := F / rels;
##  <fp group on the generators [ x1, x2, x3, x4, x5 ]>
##  gap> x1 := E1.1;; x2 := E1.2;; x3 := E1.3;; x4 := E1.4;; x5 := E1.5;;
##  gap> # Get normal subgroup generators for B1.
##  gap> H := Subgroup( E1, [ x5 * x2^-1, x5 * x4^-1 ] );;
##  gap> # Compute the abelian invariants of B1/B1'.
##  gap> A := AbelianInvariantsNormalClosureFpGroup( E1, H );
##  [ 2, 2, 2, 2, 2, 2, 2, 2 ]
##  gap> # Compute a presentation for B1.
##  gap> P := PresentationNormalClosure( E1, H );
##  <presentation with 18 gens and 46 rels of total length 132>
##  gap> SimplifyPresentation( P );
##  #I  there are 8 generators and 30 relators of total length 148
##  gap> B1 := FpGroupPresentation( P );
##  <fp group on the generators [ _x1, _x2, _x3, _x4, _x6, _x7, _x8, _x11
##   ]>
##  gap> # Compute normal subgroup generators for B1'.
##  gap> gens := GeneratorsOfGroup( B1 );;
##  gap> numgens := Length( gens );;
##  gap> comms := [ ];;
##  gap> for i in [ 1 .. numgens - 1 ] do
##  >     for j in [i+1 .. numgens ] do
##  >         Add( comms, Comm( gens[i], gens[j] ) );
##  >     od;
##  > od;
##  gap> # Compute the abelian invariants of B1'/B1".
##  gap> K := Subgroup( B1, comms );;
##  gap> A := AbelianInvariantsNormalClosureFpGroup( B1, K );
##  [ 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AbelianInvariantsNormalClosureFpGroupRrs");

############################################################################
##
#F  AbelianInvariantsNormalClosureFpGroup(<G>,<H>)
##
##  <#GAPDoc Label="AbelianInvariantsNormalClosureFpGroup">
##  <ManSection>
##  <Func Name="AbelianInvariantsNormalClosureFpGroup" Arg='G, H'/>
##
##  <Description>
##  <Ref Func="AbelianInvariantsNormalClosureFpGroup"/> is a synonym for
##  <Ref Func="AbelianInvariantsNormalClosureFpGroupRrs"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
AbelianInvariantsNormalClosureFpGroup :=
    AbelianInvariantsNormalClosureFpGroupRrs;


############################################################################
##
#F  AbelianInvariantsSubgroupFpGroupMtc(<G>,<H>)
##
##  <#GAPDoc Label="AbelianInvariantsSubgroupFpGroupMtc">
##  <ManSection>
##  <Func Name="AbelianInvariantsSubgroupFpGroupMtc" Arg='G, H'/>
##
##  <Description>
##  uses the Modified Todd-Coxeter method to compute the abelian
##  invariants of a subgroup <A>H</A> of a finitely presented group <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AbelianInvariantsSubgroupFpGroupMtc");


#############################################################################
##
#F  AbelianInvariantsSubgroupFpGroupRrs( <G>, <H> )
#F  AbelianInvariantsSubgroupFpGroupRrs( <G>, <table> )
##
##  <#GAPDoc Label="AbelianInvariantsSubgroupFpGroupRrs">
##  <ManSection>
##  <Heading>AbelianInvariantsSubgroupFpGroupRrs</Heading>
##  <Func Name="AbelianInvariantsSubgroupFpGroupRrs" Arg='G, H'
##   Label="for two groups"/>
##  <Func Name="AbelianInvariantsSubgroupFpGroupRrs" Arg='G, table'
##   Label="for a group and a coset table"/>
##
##  <Description>
##  uses the Reduced Reidemeister-Schreier method to compute the abelian
##  invariants of a subgroup <A>H</A> of a finitely presented group <A>G</A>.
##  <P/>
##  Alternatively to the subgroup <A>H</A>, its coset table <A>table</A> in
##  <A>G</A> may be given as second argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AbelianInvariantsSubgroupFpGroupRrs");


############################################################################
##
#F  AbelianInvariantsSubgroupFpGroup(<G>,<H>)
##
##  <#GAPDoc Label="AbelianInvariantsSubgroupFpGroup">
##  <ManSection>
##  <Func Name="AbelianInvariantsSubgroupFpGroup" Arg='G,H'/>
##
##  <Description>
##  <Ref Func="AbelianInvariantsSubgroupFpGroup"/> is a synonym for
##  <Ref Func="AbelianInvariantsSubgroupFpGroupRrs"
##  Label="for a group and a coset table"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
AbelianInvariantsSubgroupFpGroup := AbelianInvariantsSubgroupFpGroupRrs;


#############################################################################
##
#O  AugmentedCosetTableInWholeGroup(< H >[, <gens>])
##
##  <#GAPDoc Label="AugmentedCosetTableInWholeGroup">
##  <ManSection>
##  <Func Name="AugmentedCosetTableInWholeGroup" Arg='H[, gens]'/>
##
##  <Description>
##  For a subgroup <A>H</A> of a finitely presented group, this function
##  returns an augmented coset table.
##  If a generator set <A>gens</A> is given, it is
##  guaranteed that <A>gens</A> will be a subset of the primary and secondary
##  subgroup generators of this coset table.
##  <P/>
##  It is mutable so we are permitted to add further entries. However
##  existing entries may not be changed. Any entries added however should
##  correspond to the subgroup only and not to a homomorphism.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "AugmentedCosetTableInWholeGroup" );

##  values for table types
BindGlobal("TABLE_TYPE_RRS",1);
BindGlobal("TABLE_TYPE_MTC",2);


#############################################################################
##
#A  AugmentedCosetTableMtcInWholeGroup(< H >)
##
##  <ManSection>
##  <Attr Name="AugmentedCosetTableMtcInWholeGroup" Arg='H'/>
##
##  <Description>
##  For a subgroup <A>H</A> of a finitely presented group, this attribute
##  contains an augmented coset table for <A>H</A>. It is guaranteed that the
##  primary subgroup generators for this coset table will correspond to the
##  <C>GeneratorsOfGroup(<A>H</A>)</C>.
##  <P/>
##  It is mutable so we are permitted to add further entries, however
##  existing entries may not be changed. Any entries added however should
##  correspond to the subgroup only and not to a homomorphism.
##  </Description>
##  </ManSection>
##
DeclareAttribute("AugmentedCosetTableMtcInWholeGroup",IsGroup,"mutable");


#############################################################################
##
#A  AugmentedCosetTableRrsInWholeGroup(< H >)
##
##  <ManSection>
##  <Attr Name="AugmentedCosetTableRrsInWholeGroup" Arg='H'/>
##
##  <Description>
##  For a subgroup <A>H</A> of a finitely presented group, this attribute
##  contains an augmented coset table for <A>H</A>. The corresponding generator
##  set for <A>H</A> is not specified by this operation.
##  <P/>
##  It is mutable so we are permitted to add further entries, however
##  existing entries may not be changed. Any entries added however should
##  correspond to the subgroup only and not to a homomorphism.
##  </Description>
##  </ManSection>
##
DeclareAttribute("AugmentedCosetTableRrsInWholeGroup",IsGroup,"mutable");


#############################################################################
##
#A  AugmentedCosetTableNormalClosureInWholeGroup(< H >)
##
##  <ManSection>
##  <Attr Name="AugmentedCosetTableNormalClosureInWholeGroup" Arg='H'/>
##
##  <Description>
##  For a subgroup <A>H</A> of a finitely presented group, this attribute
##  contains an augmented coset table of the normal closure of <A>H</A> in its
##  whole group.
##  <P/>
##  It is mutable so we are permitted to add further entries.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "AugmentedCosetTableNormalClosureInWholeGroup",
    IsGroup, "mutable" );


#############################################################################
##
#F  AugmentedCosetTableMtc( <G>, <H>, <type>, <string> )
##
##  <#GAPDoc Label="AugmentedCosetTableMtc">
##  <ManSection>
##  <Func Name="AugmentedCosetTableMtc" Arg='G, H, type, string'/>
##
##  <Description>
##  is an internal function used by the subgroup presentation functions
##  described in <Ref Sect="Subgroup Presentations"/>.
##  It applies a Modified Todd-Coxeter coset representative enumeration to
##  construct an augmented coset table
##  (see <Ref Sect="Subgroup Presentations"/>) for the given subgroup
##  <A>H</A> of <A>G</A>.
##  The subgroup generators will be named <A>string</A><C>1</C>,
##  <A>string</A><C>2</C>, <M>\ldots</M>.
##  <P/>
##  The function accepts the options <C>max</C> and <C>silent</C>
##  as described for the function <Ref Func="CosetTableFromGensAndRels"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AugmentedCosetTableMtc");


#############################################################################
##
#F  AugmentedCosetTableRrs( <G>, <table>, <type>, <string> )  . . . . .
##
##  <#GAPDoc Label="AugmentedCosetTableRrs">
##  <ManSection>
##  <Func Name="AugmentedCosetTableRrs" Arg='G, table, type, string'/>
##
##  <Description>
##  is an internal function used by the subgroup presentation functions
##  described in <Ref Sect="Subgroup Presentations"/>.
##  It applies the Reduced Reidemeister-Schreier
##  method to construct an augmented coset table for the subgroup of <A>G</A>
##  which is defined by the given coset table <A>table</A>.
##  The new subgroup generators will be named <A>string</A><C>1</C>,
##  <A>string</A><C>2</C>, <M>\ldots</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("AugmentedCosetTableRrs");


#############################################################################
##
#O  AugmentedCosetTableNormalClosure( <G>, <H> )
##
##  <ManSection>
##  <Oper Name="AugmentedCosetTableNormalClosure" Arg='G, H'/>
##
##  <Description>
##  returns the augmented coset table  of the finitely presented group <A>G</A> on
##  the cosets of the normal closure of the subgroup <A>H</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "AugmentedCosetTableNormalClosure", [ IsGroup, IsGroup ] );


#############################################################################
##
#O  CosetTableBySubgroup( <G>, <H> )
##
##  <#GAPDoc Label="CosetTableBySubgroup">
##  <ManSection>
##  <Oper Name="CosetTableBySubgroup" Arg='G, H'/>
##
##  <Description>
##  returns a coset table for the action of <A>G</A> on the cosets of
##  <A>H</A>.
##  The columns of the table correspond to the
##  <Ref Attr="GeneratorsOfGroup"/> value of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("CosetTableBySubgroup",[IsGroup,IsGroup]);


#############################################################################
##
#F  CanonicalRelator( <rel> )
##
##  <ManSection>
##  <Func Name="CanonicalRelator" Arg='rel'/>
##
##  <Description>
##  returns the  canonical  representative  of the  given relator <A>rel</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CanonicalRelator");


#############################################################################
##
#F  CheckCosetTableFpGroup( <G>, <table> )
##
##  <ManSection>
##  <Func Name="CheckCosetTableFpGroup" Arg='G, table'/>
##
##  <Description>
##  checks whether <A>table</A> is a legal coset table of the finitely presented
##  group <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CheckCosetTableFpGroup");


############################################################################
##
#F  IsStandardized(<table>)
##
##  <ManSection>
##  <Func Name="IsStandardized" Arg='table'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("IsStandardized");


############################################################################
##
#C  IsPresentation( <obj> )
##
##  <ManSection>
##  <Filt Name="IsPresentation" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsPresentation", IsCopyable );


############################################################################
##
#V  PresentationsFamily
##
##  <ManSection>
##  <Var Name="PresentationsFamily"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
PresentationsFamily := NewFamily( "PresentationsFamily", IsPresentation );


#############################################################################
##
#F  PresentationAugmentedCosetTable(<aug>,<string>,[,<pl> [,<img>]] )
##
##  <ManSection>
##  <Func Name="PresentationAugmentedCosetTable" Arg='aug,string,[,pl [,img]]'/>
##
##  <Description>
##  creates a presentation from the given augmented coset table. It assumes
##  that <A>aug</A> is an augmented coset table of type 2.
##  The generators will be named <A>string</A>1,
##  <A>string</A>2, ... .
##  The optional argument <A>pl</A> set the printlevel for the presentation.
##  <P/>
##  <C>PresentationAugmentedCosetTable</C> will call <C>TzHandleLength1Or2Relators</C>
##  on the resulting presentation. this might eliminate generators and thus
##  makes it impossible to relate the presentation to the coset table. To
##  avoid this problem, if the optional argument <A>img</A> is set to <K>true</K>,
##  <C>TzInitGeneratorImages</C> will be called, <E>before</E> starting this
##  elimination, thus preserving a way to connect the coset table with the
##  presentation.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("PresentationAugmentedCosetTable");


#############################################################################
##
#F  PresentationNormalClosureRrs( <G>, <H>[, <string>] )
##
##  <#GAPDoc Label="PresentationNormalClosureRrs">
##  <ManSection>
##  <Func Name="PresentationNormalClosureRrs" Arg='G, H[, string]'/>
##
##  <Description>
##  uses the Reduced Reidemeister-Schreier method to compute a presentation
##  <M>P</M> for the normal closure of a subgroup <A>H</A> of a
##  finitely presented group <A>G</A>.
##  The generators in the resulting presentation will be named
##  <A>string</A><C>1</C>, <A>string</A><C>2</C>, <M>\ldots</M>,
##  the default string is <C>"_x"</C>.
##  You may access the <M>i</M>-th of these generators by
##  <M>P</M><C>!.</C><M>i</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PresentationNormalClosureRrs");


#############################################################################
##
#F  PresentationNormalClosure(<G>,<H>[,<string>])
##
##  <#GAPDoc Label="PresentationNormalClosure">
##  <ManSection>
##  <Func Name="PresentationNormalClosure" Arg='G,H[,string]'/>
##
##  <Description>
##  <Ref Func="PresentationNormalClosure"/> is a synonym for
##  <Ref Func="PresentationNormalClosureRrs"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
PresentationNormalClosure := PresentationNormalClosureRrs;


#############################################################################
##
#F  PresentationSubgroupMtc(<G>, <H>[, <string>][, <print level>] )
##
##  <#GAPDoc Label="PresentationSubgroupMtc">
##  <ManSection>
##  <Func Name="PresentationSubgroupMtc" Arg='G, H[, string][, print level]'/>
##
##  <Description>
##  uses the Modified Todd-Coxeter coset representative enumeration method
##  to compute a presentation <M>P</M> for a subgroup <A>H</A> of a
##  finitely presented group <A>G</A>.
##  The presentation returned is in generators corresponding to the
##  generators of <A>H</A>. The generators in the resulting
##  presentation will be named <A>string</A><C>1</C>, <A>string</A><C>2</C>,
##  <M>\ldots</M>, the default string is <C>"_x"</C>.
##  You may access the <M>i</M>-th of these generators by
##  <M>P</M><C>!.</C><M>i</M>.
##  <P/>
##  The default print level is <M>1</M>.
##  If the print level is set to <M>0</M>, then the printout of the
##  implicitly called function <Ref Func="DecodeTree"/> will be suppressed.
##  <Example><![CDATA[
##  gap> p := PresentationSubgroupMtc( g, u );
##  <presentation with 2 gens and 3 rels of total length 14>
##  ]]></Example>
##  <P/>
##  The so called Modified Todd-Coxeter method was proposed, in slightly
##  different forms, by Nathan S.&nbsp;Mendelsohn and
##  William O.&nbsp;J.&nbsp;Moser in 1966.
##  Moser's method was proved in <Cite Key="BC76"/>.
##  It has been generalized to cover a broad spectrum of different versions
##  (see the survey <Cite Key="Neu82"/>).
##  <P/>
##  The <E>Modified Todd-Coxeter</E> method performs an enumeration of coset
##  representatives. It proceeds like an ordinary coset enumeration (see
##  <Ref Sect="Coset Tables and Coset Enumeration"/>),
##  but as the product of a coset
##  representative by a group generator or its inverse need not be a coset
##  representative itself, the Modified Todd-Coxeter has to store a kind of
##  correction element for each coset table entry. Hence it builds up a so
##  called <E>augmented coset table</E> of <A>H</A> in <A>G</A> consisting of
##  the ordinary coset table and a second table in parallel which contains
##  the associated subgroup elements.
##  <P/>
##  Theoretically, these subgroup elements could be expressed as words in the
##  given generators of <A>H</A>, but in general these words tend to become
##  unmanageable because of their enormous lengths. Therefore, a highly
##  redundant list of subgroup generators is built up starting from the given
##  (<Q>primary</Q>) generators of <A>H</A> and adding additional
##  (<Q>secondary</Q>) generators which are defined as abbreviations of
##  suitable words of length two in the preceding generators such that each
##  of the subgroup elements in the augmented coset table can be expressed as
##  a word of length at most one in the resulting
##  (primary <E>and</E> secondary) subgroup generators.
##  <P/>
##  Then a rewriting process (which is essentially a kind of Reidemeister
##  rewriting process) is used to get relators for <A>H</A> from the defining
##  relators of <A>G</A>.
##  <P/>
##  The resulting presentation involves all the primary, but not all the
##  secondary generators of <A>H</A>.
##  In fact, it contains only those secondary generators which explicitly
##  occur in the augmented coset table.
##  If we extended this presentation by those secondary generators which are
##  not yet contained in it as additional generators, and by the definitions
##  of all secondary generators as additional relators, we would get a
##  presentation of <A>H</A>, but, in general,
##  we would end up with a large number of generators and relators.
##  <P/>
##  On the other hand, if we avoid this extension, the current presentation
##  will not necessarily define <A>H</A> although we have used the same
##  rewriting process which in the case of the
##  <Ref Func="PresentationSubgroupRrs"
##  Label="for a group and a coset table (and a string)"/> command computes
##  a defining set of relators for <A>H</A> from an augmented coset table
##  and defining relators of <A>G</A>.
##  The different behaviour here is caused by the fact that coincidences may
##  have occurred in the Modified Todd-Coxeter coset enumeration.
##  <P/>
##  To overcome this problem without extending the presentation by all
##  secondary generators, the <Ref Func="PresentationSubgroupMtc"/> command
##  applies the so called <E>decoding tree</E> algorithm which provides a
##  more economical approach.
##  The reader is strongly recommended to carefully read section
##  <Ref Sect="sect:DecodeTree"/> where this algorithm is described in more
##  detail.
##  Here we will only mention that this procedure may add a lot of
##  intermediate generators and relators (and even change the isomorphism
##  type) in a process which in fact eliminates all
##  secondary generators from the presentation and hence finally provides
##  a presentation of <A>H</A> on the primary, i.e., the originally given,
##  generators of <A>H</A>. This is a remarkable advantage of the command
##  <Ref Func="PresentationSubgroupMtc"/> compared to the command
##  <Ref Func="PresentationSubgroupRrs"
##  Label="for a group and a coset table (and a string)"/>.
##  But note that, for some particular subgroup <A>H</A>, the Reduced
##  Reidemeister-Schreier method might quite well produce a more concise
##  presentation.
##  <P/>
##  The resulting presentation is returned in the form of a presentation,
##  <M>P</M> say.
##  <P/>
##  As the function <Ref Func="PresentationSubgroupRrs"
##  Label="for a group and a coset table (and a string)"/> described above
##  (see there for details),
##  the function <Ref Func="PresentationSubgroupMtc"/> returns a list of the
##  primary subgroup generators of <A>H</A> in the attribute
##  <Ref Attr="PrimaryGeneratorWords"/> of <M>P</M>.
##  In fact, this list is not very exciting here
##  because it is just a shallow copy of the value of
##  <Ref Func="GeneratorsOfPresentation"/> of <A>H</A>, however it is
##  needed to guarantee a certain consistency between the results of the
##  different functions for computing subgroup presentations.
##  <P/>
##  Though the decoding tree routine already involves a lot of Tietze
##  transformations, we recommend that you try to further simplify the
##  resulting presentation by appropriate Tietze transformations
##  (see <Ref Sect="Tietze Transformations"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PresentationSubgroupMtc");


#############################################################################
##
#F  PresentationSubgroupRrs( <G>, <H>[, <string>] )
#F  PresentationSubgroupRrs( <G>, <table>[, <string>] )
##
##  <#GAPDoc Label="PresentationSubgroupRrs">
##  <ManSection>
##  <Heading>PresentationSubgroupRrs</Heading>
##  <Func Name="PresentationSubgroupRrs" Arg='G, H[, string]'
##   Label="for two groups (and a string)"/>
##  <Func Name="PresentationSubgroupRrs" Arg='G, table[, string]'
##   Label="for a group and a coset table (and a string)"/>
##
##  <Description>
##  uses the  Reduced Reidemeister-Schreier method to compute a presentation
##  <A>P</A> for a subgroup <A>H</A> of a finitely presented group
##  <A>G</A>.
##  The generators in the resulting presentation will be named
##  <A>string</A><C>1</C>, <A>string</A><C>2</C>, <M>\ldots</M>,
##  the default string is <C>"_x"</C>.
##  You may access the <M>i</M>-th of these generators by
##  <A>P</A><C>!.</C><M>i</M>.
##  <P/>
##  Alternatively to the subgroup <A>H</A>,
##  its coset table <A>table</A> in <A>G</A> may be given as second argument.
##  <Example><![CDATA[
##  gap> f := FreeGroup( "a", "b" );;
##  gap> g := f / [ f.1^2, f.2^3, (f.1*f.2)^5 ];
##  <fp group on the generators [ a, b ]>
##  gap> g1 := Size( g );
##  60
##  gap> u := Subgroup( g, [ g.1, g.1^g.2 ] );
##  Group([ a, b^-1*a*b ])
##  gap> p := PresentationSubgroup( g, u, "g" );
##  <presentation with 3 gens and 4 rels of total length 12>
##  gap> gens := GeneratorsOfPresentation( p );
##  [ g1, g2, g3 ]
##  gap> TzPrintRelators( p );
##  #I  1. g1^2
##  #I  2. g2^2
##  #I  3. g3*g2*g1
##  #I  4. g3^5
##  ]]></Example>
##  <P/>
##  Note that you cannot call the generators by their names. These names are
##  not variables, but just display figures. So, if you want to access the
##  generators by their names, you first will have to introduce the respective
##  variables and to assign the generators to them.
##  <P/>
##  <Example><![CDATA[
##  gap> gens[1] = g1;
##  false
##  gap> g1;
##  60
##  gap> g1 := gens[1];; g2 := gens[2];; g3 := gens[3];;
##  gap> g1;
##  g1
##  ]]></Example>
##  <P/>
##  The Reduced Reidemeister-Schreier algorithm is a modification of the
##  Reidemeister-Schreier algorithm of George Havas <Cite Key="Hav74b"/>.
##  It was proposed by Joachim Neubüser and first implemented in 1986 by
##  Andrea Lucchini and Volkmar Felsch in the SPAS system
##  <Cite Key="Spa89"/>.
##  Like the Reidemeister-Schreier algorithm of George Havas, it needs only
##  the presentation of <A>G</A> and a coset table of <A>H</A> in <A>G</A>
##  to construct a presentation of <A>H</A>.
##  <P/>
##  Whenever you call the command <Ref Func="PresentationSubgroupRrs"
##  Label="for a group and a coset table (and a string)"/>,
##  it first obtains a coset table of <A>H</A> in <A>G</A> if not given.
##  Next, a set of generators of <A>H</A> is determined by reconstructing the
##  coset table and introducing in that process as many Schreier generators
##  of <A>H</A> in <A>G</A> as are needed to do a Felsch strategy coset
##  enumeration without any coincidences.
##  (In general, though containing redundant generators, this set will be
##  much smaller than the set of all Schreier generators.
##  That is why we call the method the <E>Reduced</E> Reidemeister-Schreier.)
##  <P/>
##  After having constructed this set of <E>primary subgroup generators</E>,
##  say, the coset table is extended to an <E>augmented coset table</E> which
##  describes the action of the group generators on coset representatives,
##  i.e., on elements instead of cosets.
##  For this purpose, suitable words in the (primary) subgroup generators
##  have to be associated to the coset table entries.
##  In order to keep the lengths of these words short, additional
##  <E>secondary subgroup generators</E> are introduced as abbreviations of
##  subwords. Their number may be large.
##  <P/>
##  Finally, a Reidemeister rewriting process is used to get defining
##  relators for <A>H</A> from the relators of <A>G</A>.
##  As the resulting presentation of <A>H</A> is a presentation on primary
##  <E>and</E> secondary generators, in general you will have to simplify it
##  by appropriate Tietze transformations
##  (see <Ref Sect="Tietze Transformations"/>) or by the command
##  <Ref Func="DecodeTree"/> before you can use it. Therefore it is
##  returned in the form of a presentation, <A>P</A> say.
##  <P/>
##  Compared with the Modified Todd-Coxeter method described below, the
##  Reduced Reidemeister-Schreier method (as well as Havas' original
##  Reidemeister-Schreier program) has the advantage that it does not require
##  generators of <A>H</A> to be given if a coset table of <A>H</A> in
##  <A>G</A> is known.
##  This provides a possibility to compute a presentation of the normal
##  closure of a given subgroup
##  (see <Ref Func="PresentationNormalClosureRrs"/>).
##  <P/>
##  For certain applications you may be interested in getting not only just a
##  presentation for <A>H</A>, but also a relation between the involved
##  generators of <A>H</A> and the generators of <A>G</A>.
##  The subgroup generators in the presentation
##  are sorted such that the primary generators precede the secondary ones.
##  Moreover, for each secondary subgroup generator there is a relator in the
##  presentation which expresses this generator as a word in preceding ones.
##  Hence, all we need in addition is a list of words in the generators of
##  <A>G</A> which express the primary subgroup generators.
##  In fact, such a list is provided in the attribute
##  <Ref Attr="PrimaryGeneratorWords"/> of the resulting presentation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("PresentationSubgroupRrs");


#############################################################################
##
#F  PresentationSubgroup( <G>, <H>[, <string>] )
##
##  <#GAPDoc Label="PresentationSubgroup">
##  <ManSection>
##  <Func Name="PresentationSubgroup" Arg='G, H[, string]'/>
##
##  <Description>
##  <Ref Func="PresentationSubgroup"/> is a synonym for
##  <Ref Func="PresentationSubgroupRrs"
##  Label="for a group and a coset table (and a string)"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
PresentationSubgroup := PresentationSubgroupRrs;


#############################################################################
##
#A  PrimaryGeneratorWords( <P> )
##
##  <#GAPDoc Label="PrimaryGeneratorWords">
##  <ManSection>
##  <Attr Name="PrimaryGeneratorWords" Arg='P'/>
##
##  <Description>
##  is an attribute of the presentation <A>P</A> which holds a list of words
##  in the associated group generators (of the underlying free group) which
##  express the primary subgroup generators of <A>P</A>.
##  <Example><![CDATA[
##  gap> PrimaryGeneratorWords( p );
##  [ a, b^-1*a*b ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("PrimaryGeneratorWords",IsPresentation);

#############################################################################
##
#F  ReducedRrsWord( <word> )
##
##  <ManSection>
##  <Func Name="ReducedRrsWord" Arg='word'/>
##
##  <Description>
##  freely reduces the given RRS word and returns the result.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ReducedRrsWord");


#############################################################################
##
#F  RelatorMatrixAbelianizedNormalClosureRrs( <G>, <H> )
##
##  <ManSection>
##  <Func Name="RelatorMatrixAbelianizedNormalClosureRrs" Arg='G, H'/>
##
##  <Description>
##  uses the Reduced Reidemeister-Schreier method  to compute a matrix of
##  abelianized defining relators for the  normal  closure of a subgroup <A>H</A>
##  of a  finitely presented  group <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelatorMatrixAbelianizedNormalClosureRrs");


#############################################################################
##
#F  RelatorMatrixAbelianizedSubgroupMtc( <G>, <H> )
##
##  <ManSection>
##  <Func Name="RelatorMatrixAbelianizedSubgroupMtc" Arg='G, H'/>
##
##  <Description>
##  uses  the  Modified  Todd-Coxeter coset representative enumeration
##  method  to compute  a matrix of abelianized defining relators for a
##  subgroup <A>H</A> of a finitely presented group <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelatorMatrixAbelianizedSubgroupMtc");


#############################################################################
##
#F  RelatorMatrixAbelianizedSubgroupRrs( <G>, <H> )
#F  RelatorMatrixAbelianizedSubgroupRrs( <G>, <table> )
##
##  <ManSection>
##  <Func Name="RelatorMatrixAbelianizedSubgroupRrs" Arg='G, H'/>
##  <Func Name="RelatorMatrixAbelianizedSubgroupRrs" Arg='G, table'/>
##
##  <Description>
##  uses the Reduced Reidemeister-Schreier method to compute a matrix of
##  abelianized defining relators for a subgroup <A>H</A> of a finitely presented
##  group <A>G</A>.
##  <P/>
##  Alternatively to the subgroup <A>H</A>, its coset table <A>table</A> in <A>G</A> may be
##  given as second argument.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelatorMatrixAbelianizedSubgroupRrs");

#############################################################################
##
#F  RelatorMatrixAbelianizedSubgroup(<G>,<H>)
#F  RelatorMatrixAbelianizedSubgroup(<G>,<table>)
##
##  <ManSection>
##  <Func Name="RelatorMatrixAbelianizedSubgroup" Arg='G,H'/>
##  <Func Name="RelatorMatrixAbelianizedSubgroup" Arg='G,table'/>
##
##  <Description>
##  is a synonym for <C>RelatorMatrixAbelianizedSubgroupRrs(<A>G</A>,<A>H</A>)</C> or
##  <C>RelatorMatrixAbelianizedSubgroupRrs(<A>G</A>,<A>table</A>)</C>, respectively.
##  </Description>
##  </ManSection>
##
RelatorMatrixAbelianizedSubgroup := RelatorMatrixAbelianizedSubgroupRrs;


#############################################################################
##
#F  RenumberTree( <augmented coset table> )
##
##  <ManSection>
##  <Func Name="RenumberTree" Arg='augmented coset table'/>
##
##  <Description>
##  is  a  subroutine  of  the  Reduced Reidemeister-Schreier
##  routines.  It renumbers the generators  such that the  primary generators
##  precede the secondary ones.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RenumberTree");


#############################################################################
##
#F  RewriteAbelianizedSubgroupRelators( <aug>,<prels> )
##
##  <ManSection>
##  <Func Name="RewriteAbelianizedSubgroupRelators" Arg='aug,prels'/>
##
##  <Description>
##  is  a  subroutine  of  the  Reduced
##  Reidemeister-Schreier and the Modified Todd-Coxeter routines. It computes
##  a set of subgroup relators  from the  coset factor table  of an augmented
##  coset table <A>aug</A> of type 0 and the relators <A>prels</A> of the parent group.
##  <P/>
##  It returns the rewritten relators as list of integers
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RewriteAbelianizedSubgroupRelators");

#############################################################################
##
#F  RewriteSubgroupRelators( <aug>, <prels> )
##
##  <ManSection>
##  <Func Name="RewriteSubgroupRelators" Arg='aug, prels'/>
##
##  <Description>
##  is a subroutine  of the  Reduced
##  Reidemeister-Schreier and the  Modified Todd-Coxeter  routines.  It
##  computes  a set of subgroup relators from the coset factor table of an
##  augmented coset table <A>aug</A> and the  relators <A>prels</A> of the  parent
##  group.  It assumes  that  <A>aug</A> is an augmented coset table of type 2.
##  <P/>
##  It returns the rewritten relators as list of integers
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RewriteSubgroupRelators");


#############################################################################
##
#F  SortRelsSortedByStartGen(<relsGen>)
##
##  <ManSection>
##  <Func Name="SortRelsSortedByStartGen" Arg='relsGen'/>
##
##  <Description>
##  sorts the relators lists  sorted  by  starting
##  generator to get better  results  of  the  Reduced  Reidemeister-Schreier
##  (this is not needed for the Felsch Todd-Coxeter).
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SortRelsSortedByStartGen");


#############################################################################
##
#F  SpanningTree( <table> )
##
##  <ManSection>
##  <Func Name="SpanningTree" Arg='table'/>
##
##  <Description>
##  <C>SpanningTree</C>  returns a spanning tree for the given coset table
##  <A>table</A>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SpanningTree");

#############################################################################
##
#F  RewriteWord( <aug>, <word> )
##
##  <#GAPDoc Label="RewriteWord">
##  <ManSection>
##  <Func Name="RewriteWord" Arg='aug, word'/>
##
##  <Description>
##  <Ref Func="RewriteWord"/> rewrites <A>word</A> (which must be a word in
##  the underlying free group with respect to which the augmented coset table
##  <A>aug</A> is given) in the subgroup generators given by the augmented
##  coset table <A>aug</A>.
##  It returns a Tietze-type word (i.e.&nbsp;a list of integers),
##  referring to the primary and secondary generators of <A>aug</A>.
##  <P/>
##  If <A>word</A> is not contained in the subgroup, <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("RewriteWord");


#############################################################################
##
#F  DecodedTreeEntry(<tree>,<imgs>,<nr>)
##
##  <ManSection>
##  <Func Name="DecodedTreeEntry" Arg='tree,imgs,nr'/>
##
##  <Description>
##  returns tree element <A>nr</A>, when mapping the first elements of <A>tree</A>
##  onto <A>imgs</A>. (Conventions for trees are as with augmented coset tables.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("DecodedTreeEntry");

#############################################################################
##
#F  GeneratorTranslationAugmentedCosetTable(<aug>)
##
##  <ManSection>
##  <Func Name="GeneratorTranslationAugmentedCosetTable" Arg='aug'/>
##
##  <Description>
##  decode all the secondary generators as words in the primary generators,
##  using the <C>.subgroupGenerators</C> and creating their subset
##  <C>.primarySubgroupGenerators</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("GeneratorTranslationAugmentedCosetTable");

#############################################################################
##
#F  SecondaryGeneratorWordsAugmentedCosetTable(<aug>)
##
##  <ManSection>
##  <Func Name="SecondaryGeneratorWordsAugmentedCosetTable" Arg='aug'/>
##
##  <Description>
##  returns words in the (underlying free) groups generators for the coset
##  table's secondary generators.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SecondaryGeneratorWordsAugmentedCosetTable");

#############################################################################
##
#F  CopiedAugmentedCosetTable(<aug>)
##
##  <ManSection>
##  <Func Name="CopiedAugmentedCosetTable" Arg='aug'/>
##
##  <Description>
##  returns a new augmented coset table, equal to the old one. The
##  components of this new table are immutable, but new components may be
##  added.
##  (This function is needed to have different homomorphisms share the same
##  augmented coset table data.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CopiedAugmentedCosetTable");

# forward declaration of the new mtc worker and presentation builder fct.
DeclareGlobalFunction("NEWTC_CosetEnumerator");
DeclareGlobalFunction("NEWTC_PresentationMTC");
DeclareGlobalFunction("NEWTC_CyclicSubgroupOrder");
