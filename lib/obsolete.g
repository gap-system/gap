#############################################################################
##
#W  obsolete.g                  GAP library                     Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains a number of functions, or extensions of
##  functions to certain numbers or combinations of arguments, which
##  are now considered "deprecated" or "obsolescent", but which are presently
##  included in the system to maintain backwards compatibility.
##
##  Procedures for dealing with this functionality are not yet completely
##  agreed, but it will probably be removed from the system over
##  several releases. 
##
##  These functions should NOT be used in the library.

Revision.obsolete_g :=
    "@(#)$Id$";
##
## Some relics of the old primitive groups library.
##

DeclareGlobalFunction( "AffinePermGroupByMatrixGroup");

InstallGlobalFunction( AffinePermGroupByMatrixGroup, 
        function(arg)
    return AffineActionByMatrixGroup(arg[1]);
end);

DeclareSynonym( "PrimitiveAffinePermGroupByMatrixGroup", AffineActionByMatrixGroup);



#############################################################################
##
##  relics of vector space basis stuff (from times when only unary methods
##  could be installed for attributes and thus additional non-attributes had
##  been introduced)
##

#############################################################################
##
#A  BasisOfDomain( <V> )
#O  BasisByGenerators( <V>, <vectors> )
#O  BasisByGeneratorsNC( <V>, <vectors> )
#A  SemiEchelonBasisOfDomain( <V> )
#O  SemiEchelonBasisByGenerators( <V>, <vectors> )
#O  SemiEchelonBasisByGeneratorsNC( <V>, <vectors> )
##
DeclareSynonymAttr( "BasisOfDomain", Basis );
DeclareSynonym( "BasisByGenerators", Basis );
DeclareSynonym( "BasisByGeneratorsNC", BasisNC );
DeclareSynonymAttr( "SemiEchelonBasisOfDomain", SemiEchelonBasis );
DeclareSynonym( "SemiEchelonBasisByGenerators", SemiEchelonBasis );
DeclareSynonym( "SemiEchelonBasisByGeneratorsNC", SemiEchelonBasisNC );


#############################################################################
##
#O  NewBasis( <V>[, <gens>] )
##
##  This operation is obsolete.
##  The idea to introduce it was that its methods were allowed to call
##  `Objectify', whereas `Basis' methods were thought to call `NewBasis'.
##
DeclareOperation( "NewBasis", [ IsFreeLeftModule, IsCollection ] );


#############################################################################
##
#O  MutableBasisByGenerators( <F>, <gens>[, <zero>] )
##
DeclareSynonym( "MutableBasisByGenerators", MutableBasis );


#############################################################################
##
#E

