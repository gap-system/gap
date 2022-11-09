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
##  This file contains the operations for the computation of complements in
##  pc groups
##

#############################################################################
##
#V  InfoComplement
##
##  <#GAPDoc Label="InfoComplement">
##  <ManSection>
##  <InfoClass Name="InfoComplement"/>
##
##  <Description>
##  Info class for the complement routines.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareInfoClass("InfoComplement");

#############################################################################
##
#F  COAffineBlocks( <S>,<Sgens>,<mats>,<orbs> )
##
##  <ManSection>
##  <Func Name="COAffineBlocks" Arg='S,Sgens,mats,orbs'/>
##
##  <Description>
##  Let <A>S</A> be a group whose generators <A>Sgens</A> act via <A>mats</A> on an affine
##  space. This routine calculates the orbits under this action. If <A>orbs</A>
##  also orbits as sets of vectors are returned.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("COAffineBlocks");

#############################################################################
##
#O  CONextCentralizer( <ocr>, <S>, <H> )  . . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="CONextCentralizer" Arg='ocr, S, H'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CONextCentralizer");

#############################################################################
##
#O  COAffineCohomologyAction( <ocr>, <fgens>, <acts>,<B> )
##
##  <ManSection>
##  <Oper Name="COAffineCohomologyAction" Arg='ocr, fgens, acts,B'/>
##
##  <Description>
##  calculates matrices for the affine action of a factor centralizer on the
##  complements, represented by elements of the cohomology group. <A>B</A> is the
##  result of <C>BaseSteinitzVectors</C> used to represent the cohomology group.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("COAffineCohomologyAction");

#############################################################################
##
#O  CONextCocycles( <cor>, <ocr>, <S> ) . . . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="CONextCocycles" Arg='cor, ocr, S'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CONextCocycles");

#############################################################################
##
#O  CONextCentral( <cor>, <ocr>, <S> ) . . . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="CONextCentral" Arg='cor, ocr, S'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CONextCentral");

#############################################################################
##
#O  CONextComplements( <cor>, <S>, <K>, <M> ) . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="CONextComplements" Arg='cor, S, K, M'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CONextComplements");

#############################################################################
##
#O  COComplements( <cor>, <G>, <N>, <all> ) . . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="COComplements" Arg='cor, G, N, all'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("COComplements");

#############################################################################
##
#O  COComplementsMain( <G>, <N>, <all>, <fun> )  . . . . . . . . . . . . . local
##
##  <ManSection>
##  <Oper Name="COComplementsMain" Arg='G, N, all, fun'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("COComplementsMain");

#############################################################################
##
#O  ComplementClassesRepresentativesSolvableNC( <G>, <N> )
##
##  <ManSection>
##  <Oper Name="ComplementClassesRepresentativesSolvableNC" Arg='G, N'/>
##
##  <Description>
##  computes a set of representatives of the complement classes of <A>N</A> in
##  <A>G</A> by cohomological methods. <A>N</A> must be a solvable normal subgroup
##  of <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation("ComplementClassesRepresentativesSolvableNC",
  [IsGroup,IsGroup]);


# Basic routine for complements with solvable factor group.
DeclareGlobalFunction("COSolvableFactor");

#############################################################################
##
#O  ComplementClassesRepresentatives( <G>, <N> ) . . . . . . . . . . . . find all complement
##
##  <#GAPDoc Label="ComplementClassesRepresentatives">
##  <ManSection>
##  <Oper Name="ComplementClassesRepresentatives" Arg='G, N'/>
##
##  <Description>
##  Let <A>N</A> be a normal subgroup of <A>G</A>.
##  This command returns a set of representatives for the conjugacy classes
##  of complements of <A>N</A> in <A>G</A>.
##  Complements are subgroups of <A>G</A> which intersect trivially with
##  <A>N</A> and together with <A>N</A> generate <A>G</A>.
##  <P/>
##  At the moment methods are available only for the case that <A>N</A> or
##  <A>G</A><C>/</C><A>N</A> is solvable.
##  <Example><![CDATA[
##  gap> ComplementClassesRepresentatives(g,Group((1,2)(3,4),(1,3)(2,4)));
##  [ Group([ (3,4), (2,4,3) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("ComplementClassesRepresentatives",[IsGroup,IsGroup]);
