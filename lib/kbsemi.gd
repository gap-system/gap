#############################################################################
##
#W  kbsemi.gd           GAP library        Andrew Solomon and Isabel Araújo
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for Knuth-Bendix Rewriting Systems
##



############################################################################
##
#I  InfoKnuthBendix
## 
##
DeclareInfoClass("InfoKnuthBendix");


############################################################################
##
#C  IsKnuthBendixRewritingSystem(<obj>)
##
##  <ManSection>
##  <Filt Name="IsKnuthBendixRewritingSystem" Arg='obj' Type='Category'/>
##
##  <Description>
##  This is the category of Knuth-Bendix rewriting systems. 
##  </Description>
##  </ManSection>
##
DeclareCategory("IsKnuthBendixRewritingSystem", IsRewritingSystem);

#############################################################################
##
#A  KnuthBendixRewritingSystem(<fam>,<wordord>)
##
##  <ManSection>
##  <Attr Name="KnuthBendixRewritingSystem" Arg='fam,wordord'/>
##
##  <Description>
##  returns the Knuth-Bendix rewriting system of the family <A>fam</A>
##  with respect to the reduction ordering on words given by <A>wordord</A>. 
##  </Description>
##  </ManSection>
##
DeclareOperation("KnuthBendixRewritingSystem",[IsFamily,IsOrdering]);


############################################################################
##
#F  CreateKnuthBendixRewritingSystem(<S>,<lt>)
##
##  <ManSection>
##  <Func Name="CreateKnuthBendixRewritingSystem" Arg='S,lt'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("CreateKnuthBendixRewritingSystem");


############################################################################
##
#F  MakeKnuthBendixRewritingSystemConfluent(<RWS>)
##
##  <ManSection>
##  <Func Name="MakeKnuthBendixRewritingSystemConfluent" Arg='RWS'/>
##
##  <Description>
##  makes a RWS confluent by running a KB. It will call
##  <C>KB_REW.MakeKnuthBendixRewritingSystemConfluent</C>.
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("MakeKnuthBendixRewritingSystemConfluent");

#############################################################################
##
#V  KB_REW
#V  GAPKB_REW
##
##  <#GAPDoc Label="KB_REW">
##  <ManSection>
##  <Var Name="KB_REW"/>
##  <Var Name="GAPKB_REW"/>
##
##  <Description>
##  <C>KB_REW</C> is a global record variable whose components contain functions
##  used for Knuth-Bendix. By default <C>KB_REW</C> is assigned to
##  <C>GAPKB_REW</C>, which contains the KB functions provided by
##  the GAP library.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BindGlobal("GAPKB_REW",rec(name:="GAP library Knuth-Bendix"));
KB_REW:=GAPKB_REW;


############################################################################
##
#F  ReduceWordUsingRewritingSystem(<RWS>,<w>)
##
##  <ManSection>
##  <Func Name="ReduceWordUsingRewritingSystem" Arg='RWS,w'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalFunction("ReduceWordUsingRewritingSystem");

#############################################################################
##
#A  TzRules( <kbrws> )
##
##  <ManSection>
##  <Attr Name="TzRules" Arg='kbrws'/>
##
##  <Description>
##  For a Knuth-Bendix rewriting system for a monoid, this attribute
##  contains rewriting rules in compact form as <Q>Tietze words</Q>. The
##  numbers used correspond to the generators of the monoid.
##  </Description>
##  </ManSection>
##
DeclareAttribute( "TzRules", IsKnuthBendixRewritingSystem );

#############################################################################
##
#E

