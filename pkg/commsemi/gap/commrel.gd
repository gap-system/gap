#############################################################################
##
#W  commrel.gd        COMMSEMI library       Isabel Araujo and Andrew Solomon
##
#H  @(#)$Id: commrel.gd,v 1.2 2000/06/01 15:43:59 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains code for commutative semigroups
##
Revision.commrel_gd:=
    "@(#)$Id: commrel.gd,v 1.2 2000/06/01 15:43:59 gap Exp $";

#############################################################################
##
#A  EpimorphismToLargestSemilatticeHomomorphicImage(s)
##
##  for a commutative semigroup <s>, returns the epimorphism
##  to the largest semilattice homomorphic image
##
DeclareAttribute("EpimorphismToLargestSemilatticeHomomorphicImage",IsSemigroup);

#############################################################################
##
#O  LargestSemilatticeHomomorphicImage(<S>)
##
##  returns the largest semilattice homomorphic image
##
DeclareOperation("LargestSemilatticeHomomorphicImage",
[IsSemigroup and IsCommutative]);

#############################################################################
##
#O  ArchimedeanRelation(<S>)
##
##  returns the ArchimedeanRelation on the semigroup <S>.
##
DeclareOperation("ArchimedeanRelation",
[IsSemigroup and IsCommutative]);

#############################################################################
##
#A  StabilizerOfGreensClass(<C>)
##
##  returns the subsemigroup of the parent of <C>, which stabilizes <C>
##
DeclareAttribute("StabilizerOfGreensClass",IsGreensClass);

#############################################################################
##
#A  SchutzenbergerGroupOfHClass(<C>)
##
##  returns the Schutzenberger of the H-class <C>.
##  This is still to be implemented.
##
DeclareAttribute("SchutzenbergerGroupOfHClass",IsGreensClass);

#############################################################################
##
#E
##
