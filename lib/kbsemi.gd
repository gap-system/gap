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
#C  IsKnuthBendixRewritingSystem(<obj>)
## 
##  This is the category of Knuth Bendix rewriting systems.	
##
DeclareCategory("IsKnuthBendixRewritingSystem", IsRewritingSystem);

#############################################################################
##
#A  KnuthBendixRewritingSystem(<S>,<lteq>)
##
##	returns the Knuth Bendix rewriting system of the FpSemigroup <S>
##	with respect to the reduction ordering on words given by <lteq>. 
##
DeclareOperation("KnuthBendixRewritingSystem",[IsFpSemigroup,IsFunction]);

############################################################################
##
#F  CreateKnuthBendixRewritingSystemOfFpSemigroup(<S>,<lt>)
##  
##
DeclareGlobalFunction("CreateKnuthBendixRewritingSystemOfFpSemigroup");

############################################################################
##
#F  MakeKnuthBendixRewritingSystemConfluent(<RWS>)
##  
##
DeclareGlobalFunction("MakeKnuthBendixRewritingSystemConfluent");

############################################################################
##
#F  ReduceWordUsingRewritingSystem(<RWS>,<w>)
##  
##
DeclareGlobalFunction("ReduceWordUsingRewritingSystem");

#############################################################################
##
#E

