#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel, Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#V  InfoSchur
##
##  <ManSection>
##  <InfoClass Name="InfoSchur"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareInfoClass( "InfoSchur" );

#############################################################################
##
#O  SchurCover(<G>)
##
##  <#GAPDoc Label="SchurCover">
##  <ManSection>
##  <Attr Name="SchurCover" Arg='G'/>
##
##  <Description>
##  returns one (of possibly several) Schur covers of the group <A>G</A>.
##  <P/>
##  At the moment this cover is represented as a finitely presented group
##  and <Ref Attr="IsomorphismPermGroup"/> would be needed to convert it to a
##  permutation group.
##  <P/>
##  If also the relation to <A>G</A> is needed,
##  <Ref Attr="EpimorphismSchurCover"/> should be used.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> epi:=EpimorphismSchurCover(g);
##  [ F1, F2, F3 ] -> [ (1,2), (2,3), (3,4) ]
##  gap> Size(Source(epi));
##  48
##  gap> f:=FreeGroup("a","b");;
##  gap> g:=f/ParseRelators(f,"a2,b3,(ab)5");;
##  gap> epi:=EpimorphismSchurCover(g);
##  [ a, b ] -> [ a, b ]
##  gap> Size(Kernel(epi));
##  2
##  ]]></Example>
##  <P/>
##  If the group becomes bigger, Schur Cover calculations might become
##  unfeasible.
##  <P/>
##  There is another operation, <Ref Attr="AbelianInvariantsMultiplier"/>,
##  which only returns the structure of the Schur Multiplier,
##  and which should work for larger groups as well.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "SchurCover", IsGroup );

##############################################################################
##
#O  EpimorphismSchurCover(<G>[,<pl>])
##
##  <#GAPDoc Label="EpimorphismSchurCover">
##  <ManSection>
##  <Attr Name="EpimorphismSchurCover" Arg='G[, pl]'/>
##
##  <Description>
##  returns an epimorphism <M>epi</M> from a group <M>D</M> onto <A>G</A>.
##  The group <M>D</M> is one (of possibly several) Schur covers of <A>G</A>.
##  The group <M>D</M> can be obtained as the <Ref Attr="Source"/> value of
##  <A>epi</A>.
##  The kernel of <M>epi</M> is the Schur multiplier of <A>G</A>.
##  If <A>pl</A> is given as a list of primes,
##  only the multiplier part for these primes is realized.
##  At the moment, <M>D</M> is represented as a finitely presented group.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "EpimorphismSchurCover", IsGroup );

##############################################################################
##
#A  AbelianInvariantsMultiplier(<G>)
##
##  <#GAPDoc Label="AbelianInvariantsMultiplier">
##  <ManSection>
##  <Attr Name="AbelianInvariantsMultiplier" Arg='G'/>
##
##  <Description>
##  <Index>Multiplier</Index>
##  <Index>Schur multiplier</Index>
##  returns a list of the abelian invariants of the Schur multiplier of
##  <A>G</A>.
##  <P/>
##  At the moment, this operation will not give any information about how to
##  extend the multiplier to a Schur Cover.
##  <Example><![CDATA[
##  gap> AbelianInvariantsMultiplier(g);
##  [ 2 ]
##  gap> AbelianInvariantsMultiplier(AlternatingGroup(6));
##  [ 2, 3 ]
##  gap> AbelianInvariantsMultiplier(SL(2,3));
##  [  ]
##  gap> AbelianInvariantsMultiplier(SL(3,2));
##  [ 2 ]
##  gap> AbelianInvariantsMultiplier(PSU(4,2));
##  [ 2 ]
##  ]]></Example>
##  (Note that the last command from the example will take some time.)
##  <P/>
##  The &GAP;&nbsp;4.4.12 manual contained examples for larger groups e.g.
##  <M>M_{22}</M>. However, some issues that may very rarely (and not
##  easily reproducibly) lead to wrong results were discovered in the code
##  capable of handling larger groups, and in &GAP;&nbsp;4.5 it was replaced
##  by a more reliable basic method. To deal with larger groups, one can use
##  the function <Ref BookName="cohomolo" Func="SchurMultiplier"/> from the
##  <Package>cohomolo</Package> package. Also, additional methods for
##  <Ref Attr="AbelianInvariantsMultiplier"/> are installed in the
##  <Package>Polycyclic</Package> package for pcp-groups.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "AbelianInvariantsMultiplier", IsGroup );

##############################################################################
####  Derived functions.                                       Robert F. Morse
####
##############################################################################
##
#A  Epicentre(<G>)
#A  ExteriorCentre(<G>)
##
##  <#GAPDoc Label="Epicentre">
##  <ManSection>
##  <Attr Name="Epicentre" Arg='G'/>
##  <Attr Name="ExteriorCentre" Arg='G'/>
##
##  <Description>
##  There are various ways of describing the epicentre of a group <A>G</A>.
##  It is the smallest normal subgroup <M>N</M> of <A>G</A> such that
##  <M><A>G</A>/N</M> is a central quotient of a group.
##  It is also equal to the Exterior Center of <A>G</A>,
##  see <Cite Key="Ellis98"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("Epicentre", IsGroup );
DeclareSynonymAttr("Epicenter", Epicentre);
DeclareSynonymAttr("ExteriorCentre", Epicentre);
DeclareSynonymAttr("ExteriorCenter", Epicentre);

##############################################################################
##
#O  NonabelianExteriorSquare(<G>)
##
##  <#GAPDoc Label="NonabelianExteriorSquare">
##  <ManSection>
##  <Oper Name="NonabelianExteriorSquare" Arg='G'/>
##
##  <Description>
##  Computes the nonabelian exterior square <M><A>G</A> \wedge <A>G</A></M>
##  of the group <A>G</A>, which for a finitely presented group is the
##  derived subgroup of any Schur cover of <A>G</A>
##  (see <Cite Key="BJR87"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("NonabelianExteriorSquare", [IsGroup]);

##############################################################################
##
#O  EpimorphismNonabelianExteriorSquare(<G>)
##
##  <#GAPDoc Label="EpimorphismNonabelianExteriorSquare">
##  <ManSection>
##  <Oper Name="EpimorphismNonabelianExteriorSquare" Arg='G'/>
##
##  <Description>
##  Computes the mapping
##  <M><A>G</A> \wedge <A>G</A> \rightarrow <A>G</A></M>.
##  The kernel of this mapping is equal to the Schur multiplier of <A>G</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("EpimorphismNonabelianExteriorSquare", [IsGroup]);

##############################################################################
##
#P  IsCentralFactor(<G>)
##
##  <#GAPDoc Label="IsCentralFactor">
##  <ManSection>
##  <Prop Name="IsCentralFactor" Arg='G'/>
##
##  <Description>
##  This function determines if there exists a group <M>H</M> such that
##  <A>G</A> is isomorphic to the quotient <M>H/Z(H)</M>.
##  A group with this property is called in literature <E>capable</E>.
##  A group being capable is
##  equivalent to the epicentre of <A>G</A> being trivial,
##  see <Cite Key="BFS79"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsCentralFactor", IsGroup);

##############################################################################
###########################END RFM############################################


##############################################################################
##
#F  SchuMu(<G>,<p>)
##
##  <ManSection>
##  <Func Name="SchuMu" Arg='G,p'/>
##
##  <Description>
##  returns epimorphism from p-part of multiplier.p-Sylow (note: This
##  extension is <E>not</E> necessarily isomorphic to a Sylow subgroup of a
##  Darstellungsgruppe!) onto p-Sylow, the
##  kernel is the p-part of the multiplier.
##  The implemented algorithm is based on section 7 in Derek Holt's paper.
##  However we use some of the general homomorphism setup to avoid having to
##  remember certain relations.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("SchuMu");

##############################################################################
##
#F  CorestEval(<FG>,<s>)
##
##  <ManSection>
##  <Func Name="CorestEval" Arg='FG,s'/>
##
##  <Description>
##  evaluate corestriction mapping.
##  <A>FH</A> is a homomorphism from a finitely presented group onto a finite
##  group <A>G</A>. <A>s</A> an epimorphism onto a p-Sylow subgroup of <A>G</A> as obtained
##  from <C>SchuMu</C>.
##  This function evaluates the relators of the source of <A>FH</A> in the
##  extension M_p.<A>G</A>. It returns a list whose entries are of the form
##  [<A>rel</A>,<A>val</A>], where <A>rel</A> is a relator of <A>G</A> and <A>val</A> its evaluation as
##  an element of M_p.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CorestEval");

##############################################################################
##
#F  RelatorFixedMultiplier(<hom>,<p>)
##
##  <ManSection>
##  <Func Name="RelatorFixedMultiplier" Arg='hom,p'/>
##
##  <Description>
##  Let <A>hom</A> an epimorphism from an fp group onto a finite group <A>G</A>. This
##  function returns an epimorphism onto the <A>p</A>-Sylow subgroup of <A>G</A>,
##  whose kernel is the largest quotient of the multiplier, that can lift
##  <A>hom</A> to a larger quotient. (The source of this map thus is <M>M_R(B)</M>
##  of&nbsp;<Cite Key="HulpkeQuot"/>.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelatorFixedMultiplier");
