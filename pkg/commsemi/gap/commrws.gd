#############################################################################
##
#W  commrws.gd           COMMSEMI library               Isabel Araujo
##
#H  @(#)$Id: commrws.gd,v 1.2 2000/06/01 15:43:59 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##
##
Revision.commrws_gd :=
    "@(#)$Id: commrws.gd,v 1.2 2000/06/01 15:43:59 gap Exp $";

############################################################################
##
#C  IsCommutativeSemigroupRws(<obj>)
##
##  This is the category of commutative semigroup rewriting systems.
##
DeclareCategory("IsCommutativeSemigroupRws", IsRewritingSystem);

#############################################################################
##
#A  CommutativeSemigroupRws(<S>,<vlteq>)
##
##  returns the commutative rewriting system of the commutative FpSemigroup <S>
##  with respect to the <vlteq> ordering on vectors.
##
DeclareOperation("CommutativeSemigroupRws",
                  [IsSemigroup and IsCommutative,IsFunction]);

DeclareAttribute("CommutativeReducedConfluentSemigroupRws",
                  IsSemigroup and IsCommutative);

#############################################################################
##
#A  VectorRulesOfCommutativeSemigroupRws( <comm rws> )
##
##  the rules of the commutative rws written as vector rules
##
DeclareAttribute("VectorRulesOfCommutativeSemigroupRws", 
IsCommutativeSemigroupRws);


############################################################################
##
#C  IsReducedConfluentCommutativeSemigroupRws(<obj>)
##
##  This is the category of reduced confluent commutative semigroup 
##  rewriting systems.
##
DeclareCategory("IsReducedConfluentCommutativeSemigroupRws", IsRewritingSystem);


############################################################################
##
#A  ReducedConfluentCommutativeSemigroupRws( <S>)
##
##  returns a reduced confluent commutative rewriting system for
##  the commutative semigroup <S>.
##
DeclareAttribute("ReducedConfluentCommutativeSemigroupRws",
                  IsSemigroup and IsCommutative);

