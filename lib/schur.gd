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
##  returns one (of possibly several) Schur covers of the group <A>G</A>,
##  namely the <Ref Attr="Source"/> value of
##  <Ref Attr="EpimorphismSchurCover"/>; in particular no specific
##  representation is guaranteed.
##  <P/>
##  If also the relation to <A>G</A> is needed,
##  <Ref Attr="EpimorphismSchurCover"/> should be used.
##  <Example><![CDATA[
##  gap> g:=Group((1,2,3,4),(1,2));;
##  gap> epi:=EpimorphismSchurCover(g);
##  [ f1, f2, f3, f4 ] -> [ (1,2), (2,3), (3,4), () ]
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
##  The group <M>D</M> is one (of possibly several) Schur covers of <A>G</A>,
##  that is, a central extension of the Schur multiplier of <A>G</A> by
##  <A>G</A> in which the kernel is contained in the derived subgroup of
##  <M>D</M>.
##  The group <M>D</M> can be obtained as the <Ref Attr="Source"/> value of
##  <A>epi</A>.
##  The kernel of <M>epi</M> is (isomorphic to) the Schur multiplier of
##  <A>G</A>.
##  If <A>pl</A> is given as a list of primes,
##  only the multiplier part for these primes is realized.
##  <P/>
##  No particular representation of <M>D</M> is guaranteed: for a
##  <M>p</M>-group it is a pc group, for a natural symmetric or alternating
##  group a matrix group (see
##  <Ref Oper="SchurCoverOfSymmetricGroup"/>), for a pcp group a pcp group if
##  the <Package>Polycyclic</Package> package is loaded, and a finitely
##  presented group otherwise. Moreover, if the multiplier of <A>G</A> is
##  trivial (or if <A>pl</A> contains no relevant prime), the returned map may
##  simply be the identity mapping of <A>G</A>.
##  <P/>
##  The default method for finite groups which are not <M>p</M>-groups uses
##  a Sylow subgroup based algorithm due
##  to&nbsp;<Cite Key="Holt85"/>; see also
##  <Ref Attr="AbelianInvariantsMultiplier"/> if only the isomorphism type
##  of the multiplier is of interest, as that is usually much cheaper to
##  compute.
##  <Example><![CDATA[
##  gap> epi:=EpimorphismSchurCover(MathieuGroup(11));;
##  gap> Size(Kernel(epi));
##  1
##  gap> epi:=EpimorphismSchurCover(SymmetricGroup(4));;
##  gap> Size(Source(epi));
##  48
##  gap> epi:=EpimorphismSchurCover(SymmetricGroup(4),[3]);;
##  gap> Size(Source(epi));
##  24
##  ]]></Example>
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
##  This operation will not give any information about how to
##  extend the multiplier to a Schur cover;
##  use <Ref Attr="EpimorphismSchurCover"/> if such information is needed.
##  <P/>
##  For a finite group <A>G</A> which is not a <M>p</M>-group, the multiplier
##  is computed one prime at a time: for each prime <M>p</M> dividing the
##  order of <A>G</A>, the <M>p</M>-part of the multiplier is obtained as a
##  quotient of the multiplier of a Sylow <M>p</M>-subgroup <M>P</M> of
##  <A>G</A>, by imposing the relations that come from the fusion of
##  subgroups of <M>P</M> in <A>G</A>, following&nbsp;<Cite Key="Holt85"/>.
##  This is usually much faster than computing a Schur cover.
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
##  gap> AbelianInvariantsMultiplier(MathieuGroup(22));
##  [ 3, 4 ]
##  ]]></Example>
##  <P/>
##  Additional methods for <Ref Attr="AbelianInvariantsMultiplier"/> are
##  installed in the <Package>Polycyclic</Package> package for pcp groups.
##  An independent implementation for permutation groups is available as
##  <Ref BookName="cohomolo" Func="SchurMultiplier"/> in the
##  <Package>cohomolo</Package> package.
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
##  The implemented algorithm is based on section 7
##  of&nbsp;<Cite Key="Holt85"/>: the p-part of the multiplier of <A>G</A>
##  is the largest quotient of the multiplier of a Sylow p-subgroup <M>P</M>
##  on which the fusion of subgroups of <M>P</M> in <A>G</A> acts trivially.
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
##  Let <A>hom</A> be an epimorphism from an fp group onto a finite group <A>G</A>. This
##  function returns an epimorphism onto the <A>p</A>-Sylow subgroup of <A>G</A>,
##  whose kernel is the largest quotient of the multiplier, that can lift
##  <A>hom</A> to a larger quotient. (The source of this map thus is <M>M_R(B)</M>
##  of&nbsp;<Cite Key="HulpkeQuot"/>.)
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("RelatorFixedMultiplier");
