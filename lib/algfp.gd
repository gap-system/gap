#############################################################################
##
#W  algfp.gd                   GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the decalarations for finitely presented algebras
##
Revision.algfp_gd :=
    "@(#)$Id$";

#############################################################################
##
#C  IsElementOfFpAlgebra
##
IsElementOfFpAlgebra := NewCategory( "IsElementOfFpAlgebra",
    IsRingElement );


#############################################################################
##
#C  IsElementOfFpAlgebraCollection
##
IsElementOfFpAlgebraCollection := CategoryCollections(
    "IsElementOfFpAlgebraCollection",
    IsElementOfFpAlgebra );


#############################################################################
##
#M  IsSubalgebraFpAlgebra
##
IsSubalgebraFpAlgebra := NewCategory ("IsSubalgebraFpAlgebra", IsAlgebra);

InstallTrueMethod( IsSubalgebraFpAlgebra,
    IsAlgebra and IsElementOfFpAlgebraCollection );

#############################################################################
##
#C  IsFamilyOfFpAlgebraElements
##
IsFamilyOfFpAlgebraElements := CategoryFamily( "IsFamilyOfFpAlgebraElements",
    IsElementOfFpAlgebra );

ElementOfFpAlgebra := NewOperation("ElementOfFpAlgebra",
    [IsFamilyOfFpAlgebraElements,IsRingElement]);

#############################################################################
##
#M  FactorFreeAlgebraByRelators(<F>,<rels>) . . .  factor of free algebra
##
FactorFreeAlgebraByRelators := NewOperationArgs(
  "FactorFreeAlgebraByRelators");

#############################################################################
##
#E  algfp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
