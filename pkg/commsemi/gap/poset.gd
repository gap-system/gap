#############################################################################
##
#W  poset.gd           COMMSEMI library               Isabel Araujo
##
#H  @(#)$Id: poset.gd,v 1.1 2000/09/13 09:26:11 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.poset_gd:=
    "@(#)$Id: poset.gd,v 1.1 2000/09/13 09:26:11 gap Exp $";

#############################################################################
##
#O  LevelsOfMaximalElementsOfPoset( list, ord )
##
##  for a list and an ordering on the family of the elements of the list
##
DeclareOperation("LevelsOfMaximalElementsOfPoset",[IsList,IsOrdering]);

#############################################################################
##
#O  PosetArrangement( list, ord )
##
##  for a list and an ordering on the family of the elements of the list
##  
DeclareOperation("PosetArrangement",[IsList,IsOrdering]);

#############################################################################
##
#A  PosetOfGreensHClassesOfCommutativeSemigroup( s )
##
##  for a commutative semigroup <S>
##  
DeclareOperation("PosetOfGreensHClassesOfCommutativeSemigroup",
											[IsSemigroup and IsCommutative]);






