#############################################################################
##
#W  listcoef.gd                 GAP Library                      Frank Celler
##
Revision.listcoef_gd :=
    "@(#)$Id$";


#############################################################################
##

#O  AddRowVector( <dst>, <src>, <mul>, <from>, <to> )
##
AddRowVector := NewOperation(
    "AddRowVector",
    [ IsList, IsList, IsMultiplicativeElement, IsInt and IsPosRat,
      IsInt and IsPosRat ] );


#############################################################################
##
#O  LeftShiftRowVector( <list>, <shift> )
##
LeftShiftRowVector := NewOperation(
    "LeftShiftRowVector",
    [ IsList, IsInt and IsPosRat ] );


#############################################################################
##
#O  MultRowVector( <list1>, <poss1>, <list2>, <poss2>, <mul> )
##
MultRowVector := NewOperation(
    "MultRowVector",
    [ IsList, IsList, IsList, IsList, IsMultiplicativeElement ] );


#############################################################################
##
#O  RightShiftRowVector( <list>, <shift>, <fill> )
##
RightShiftRowVector := NewOperation(
    "RightShiftRowVector",
    [ IsList, IsInt and IsPosRat, IsObject ] );


#############################################################################
##
#O  ShrinkRowVector( <list> )
##
ShrinkRowVector := NewOperation(
    "ShrinkRowVector",
    [ IsList ] );


#############################################################################
##

#O  AddCoeffs( <list1>, <poss1>, <list2>, <poss2>, <mul> )
##
AddCoeffs := NewOperation(
    "AddCoeffs",
    [ IsList, IsList, IsList, IsList, IsMultiplicativeElement ] );


#############################################################################
##
#O  CoeffsMod( <list1>, <len1>, <mod> )
##
CoeffsMod := NewOperation(
    "CoeffsMod",
    [ IsList, IsInt, IsInt ] );


#############################################################################
##
#O  MultCoeffs( <list1>, <list2>, <len2>, <list3>, <len3> )
##
MultCoeffs := NewOperation(
    "MultCoeffs",
    [ IsList, IsList, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  PowerModCoeffs( <list1>, <len1>, <exp>, <list2>, <len2> )
##
PowerModCoeffs := NewOperation(
    "PowerModCoeffs",
    [ IsList, IsInt, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ProductCoeffs( <list1>, <len1>, <list2>, <len2> )
##
ProductCoeffs := NewOperation(
    "ProductCoeffs",
    [ IsList, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ReduceCoeffs( <list1>, <len1>, <list2>, <len2> )
##
ReduceCoeffs := NewOperation(
    "ReduceCoeffs",
    [ IsList, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ReduceCoeffsMod( <list1>, <len1>, <list2>, <len2>, <mod> )
##
ReduceCoeffsMod := NewOperation(
    "ReduceCoeffsMod",
    [ IsList, IsInt, IsList, IsInt, IsInt ] );


#############################################################################
##
#O  RemoveOuterCoeffs( <list>, <coef> )
##
RemoveOuterCoeffs := NewOperation(
    "RemoveOuterCoeffs",
    [ IsList, IsObject ] );


#############################################################################
##
#O  ShiftedCoeffs( <list>, <shift> )
##
ShiftedCoeffs := NewOperation(
    "ShiftedCoeffs",
    [ IsList, IsInt ] );


#############################################################################
##
#O  ShrinkCoeffs( <list> )
##
ShrinkCoeffs := NewOperation(
    "ShrinkCoeffs",
    [ IsList ] );


#############################################################################
##

#E  listcoef.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
