#############################################################################
##
#W  grppccom.gd                  GAP Library                     Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id: grppccom.gd,v 4.16 2010/02/23 15:13:06 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the operations for the computation of complements in
##  pc groups
##
Revision.grppccom_gd :=
    "@(#)$Id: grppccom.gd,v 4.16 2010/02/23 15:13:06 gap Exp $";

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
#O  ComplementclassesSolvableNC( <G>, <N> )
##
##  <ManSection>
##  <Oper Name="ComplementclassesSolvableNC" Arg='G, N'/>
##
##  <Description>
##  computes a set of representatives of the complement classes of <A>N</A> in
##  <A>G</A> by cohomological methods. <A>N</A> must be a solvable normal subgroup
##  of <A>G</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation("ComplementclassesSolvableNC",
  [IsGroup,IsGroup]);

#############################################################################
##
#O  Complementclasses( <G>, <N> ) . . . . . . . . . . . . find all complement
##
##  <#GAPDoc Label="Complementclasses">
##  <ManSection>
##  <Oper Name="Complementclasses" Arg='G, N'/>
##
##  <Description>
##  Let <A>N</A> be a normal subgroup of <A>G</A>.
##  This command returns a set of representatives for the conjugacy classes
##  of complements of <A>N</A> in <A>G</A>.
##  Complements are subgroups of <A>G</A> which intersect trivially with
##  <A>N</A> and together with <A>N</A> generate <A>G</A>.
##  <P/>
##  At the moment only methods for a solvable <A>N</A> are available.
##  <Example><![CDATA[
##  gap> Complementclasses(g,Group((1,2)(3,4),(1,3)(2,4)));
##  [ Group([ (3,4), (2,4,3) ]) ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("Complementclasses",[IsGroup,IsGroup]);


#############################################################################
##
#E

