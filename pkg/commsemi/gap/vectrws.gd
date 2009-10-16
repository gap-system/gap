#############################################################################
##
#W  commrws.gd           COMMSEMI library         Isabel Araujo
##
#H  @(#)$Id: vectrws.gd,v 1.2 2000/06/01 15:43:59 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##
##
Revision.commrws_gd :=
    "@(#)$Id: vectrws.gd,v 1.2 2000/06/01 15:43:59 gap Exp $";

############################################################################
##
#C  IsVectorRewritingSystem(<obj>)
##
##  This is the category of vector rewriting systems.
##
DeclareCategory("IsVectorRewritingSystem", IsRewritingSystem);

#############################################################################
##
#A  VectorRewritingSystem(<vlist>,<vlteq>)
##
##  for a <vlist> of pairs of vectors all 
##  returns the vector rewriting system with rules in the vlist  
##  with respect to the <vlteq> ordering on vectors.
##
DeclareOperation("VectorRewritingSystem",
                  [IsList,IsFunction]);

############################################################################
##
#F  VectorToAssocWord(f,v)
##
##  for a free semigroup <f> and a vector <v>
##  It returns the word in f which is a product
##
DeclareGlobalFunction("VectorToAssocWord");


