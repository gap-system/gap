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


#############################################################################
##
#O  ElementOfFpAlgebra( <Fam>, <elm> )
##
ElementOfFpAlgebra := NewOperation("ElementOfFpAlgebra",
    [IsFamilyOfFpAlgebraElements,IsRingElement]);


#############################################################################
##
#F  FactorFreeAlgebraByRelators(<F>,<rels>) . . . . .  factor of free algebra
##
FactorFreeAlgebraByRelators := NewOperationArgs(
  "FactorFreeAlgebraByRelators");


#############################################################################
##
#P  IsNormalForm( <elm> )
##
IsNormalForm := NewProperty( "IsNormalForm", IsObject );
SetIsNormalForm := Setter( IsNormalForm );
HasIsNormalForm := Tester( IsNormalForm );


#############################################################################
##
#A  NiceNormalFormByExtRepFunction( <Fam> )
##
##  Applied to the family <Fam> and the external representation of an element
##  $e$ of the family <Fam>,
##  'NiceNormalFormByExtRepFunction( <Fam> )' returns the element of <Fam>
##  that is equal to $e$ and in normal form.
##
##  If the family <Fam> knows a nice normal form for its elements then the
##  elements can be always constructed as normalized elements by
##  'NormalizedObjByExtRep'.
##
##  (Perhaps a normal form that is expensive to compute will not be regarded
##  as a nice normal form.)
##
NiceNormalFormByExtRepFunction := NewAttribute(
    "NiceNormalFormByExtRepFunction",
    IsFamily );
SetNiceNormalFormByExtRepFunction := Setter(
    NiceNormalFormByExtRepFunction );
HasNiceNormalFormByExtRepFunction := Tester(
    NiceNormalFormByExtRepFunction );


#############################################################################
##
#E  algfp.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
