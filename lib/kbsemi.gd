#############################################################################
##
#W  kbsemi.gd           GAP library        Andrew Solomon and Isabel Araujo
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for Knuth Bendix Rewriting Systems
##

Revision.kbsemi_gd :=
    "@(#)$Id$";


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
##  This is the category of Knuth Bendix rewriting systems. 
##
DeclareCategory("IsKnuthBendixRewritingSystem", IsRewritingSystem);

#############################################################################
##
#A  KnuthBendixRewritingSystem(<fam>,<wordord>)
##
##  returns the Knuth Bendix rewriting system of the family <fam>
##  with respect to the reduction ordering on words given by <wordord>. 
##
DeclareOperation("KnuthBendixRewritingSystem",[IsFamily,IsOrdering]);


############################################################################
##
#F  CreateKnuthBendixRewritingSystem(<S>,<lt>)
##
##
DeclareGlobalFunction("CreateKnuthBendixRewritingSystem");


############################################################################
##
#F  MakeKnuthBendixRewritingSystemConfluent(<RWS>)
##  
##  makes a RWS confluent by running a KB. It will call
##  `KB_REW.MakeKnuthBendixRewritingSystemConfluent'.
DeclareGlobalFunction("MakeKnuthBendixRewritingSystemConfluent");

#############################################################################
##
#V  KB_REW
#V  GAPKB_REW
##
##  KB_REW is a global record variable whose components contain functions
##  used for Knuth-Bendix. By default `KB_REW' is assigned to
##  `GAPKB_REW', which contains the KB functions provided by
##  the GAP library.
BindGlobal("GAPKB_REW",rec(name:="GAP library Knuth-Bendix"));
KB_REW:=GAPKB_REW;


############################################################################
##
#F  ReduceWordUsingRewritingSystem(<RWS>,<w>)
##  
##
DeclareGlobalFunction("ReduceWordUsingRewritingSystem");

#############################################################################
##
#A  TzRules( <kbrws> )
##
##  For a Knuth-Bendix rewriting system for a monoid, this attribute
##  contains rewriting rules in compact form as ``tietze words''. The
##  numbers used correspond to the generators of the monoid.
##
DeclareAttribute( "TzRules", IsKnuthBendixRewritingSystem );

#############################################################################
##
#E

