#############################################################################
##
#W  listcoef.gd                 GAP Library                      Frank Celler
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.listcoef_gd :=
    "@(#)$Id$";


#1
##  The following operations all perform arithmetic on row vectors.
##  given as homogeneous lists of the same length, containing
##  elements of a commutative ring.

#############################################################################
##
#O  AddRowVector( <dst>, <src>, <mul> [,<from>, <to>] )
##
##  Adds the product of <src> and <mul> to <dst>, changing <dst>.
##  If <from> and <to> are given only the index range `[<from>..<to>]' is
##  affected.
DeclareOperation(
    "AddRowVector",
    [ IsList, IsList, IsMultiplicativeElement, IsPosInt,
      IsPosInt ] );


#############################################################################
##
#O  LeftShiftRowVector( <list>, <shift> )
##
##  changes <list> by assigning
##  `<list>[i]:=<list>[i+<shift>]' and removing the last <shift> entries of
##  the result.
DeclareOperation(
    "LeftShiftRowVector",
    [ IsList, IsPosInt ] );


#############################################################################
##
#O  MultRowVector( <list1>, <poss1>, <list2>, <poss2>, <mul> )
##
DeclareOperation(
    "MultRowVector",
    [ IsList, IsList, IsList, IsList, IsMultiplicativeElement ] );


#############################################################################
##
#O  RightShiftRowVector( <list>, <shift>, <fill> )
##
##  changes <list> by assigning
##  `<list>[i+<shift>]:=<list>[i]' and filling the <shift> training entries
##  with <fill>.
DeclareOperation(
    "RightShiftRowVector",
    [ IsList, IsPosInt, IsObject ] );


#############################################################################
##
#O  ShrinkRowVector( <list> )
##
DeclareOperation(
    "ShrinkRowVector",
    [ IsList ] );


#2
##  The following operations all perform arithmetic on univariate
##  polynomials given by their coefficient lists. These lists can have
##  different lengths but must be dense homogeneous lists containing
##  elements of a commutative ring.
##  Not all input lists may be empty.
##
##  If length parameter <len> are not given, they are set to the length of
##  the corresponding list by default.
##  In the following descriptions we will always assume that <list1> is the
##  coefficient list of the polynomial <pol1> and so forth.

#############################################################################
##
#O  AddCoeffs( <list1>, <poss1>, <list2>, <poss2>, <mul> )   add coefficients
##
##  `AddCoeffs' adds the entries  of <list2>{<poss2>} multiplied by <mul> to
##  <list1>{<poss1>}.  Non-existing  entries  in  <list1> are assumed  to  be
##  zero.  The position of the right-most non-zero elemented is returned.
##
##  Note  that it is  the responsibility  of the  caller  to ensure  that the
##  <list2> has elements at position <poss2> and that the result (in <list1>)
##  is a dense list.
##
##  The function is free to remove trailing (right-most) zeros.
##
DeclareOperation(
    "AddCoeffs",
    [ IsList, IsList, IsList, IsList, IsMultiplicativeElement ] );


#############################################################################
##
#O  CoeffsMod( <list1>, [<len1>,] <mod> )
##
##  returns the coefficient list obtained by reducing the entries in <list1>
##  modulo <mod>.
DeclareOperation(
    "CoeffsMod",
    [ IsList, IsInt, IsInt ] );


#############################################################################
##
#O  MultCoeffs( <list1>, <list2>, <len2>, <list3>, <len3> )
##
##  This operation changes <list1> to the coefficient list of the product
##  of <pol2> with <pol3>.
##  This operation changes <list1> which therefore must be a mutable list.
##  The operations returns the position of the last non-zero entry of the
##  result but is not guaranteed to remove trailing zeroes.
DeclareOperation(
    "MultCoeffs",
    [ IsList, IsList, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  PowerModCoeffs( <list1>, [<len1>,] <exp>, <list2> [,<len2>] )
##
##  returns the coefficient list of the remainder when dividing
##  `<pol1>^<exp>' by <pol2>. The operation reduces coefficients already
##  while computing powers and therefore avoids an explosion in list length.
DeclareOperation(
    "PowerModCoeffs",
    [ IsList, IsInt, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ProductCoeffs( <list1>, [<len1>,] <list2> [,<len2>] )
##
##  returns the coefficient list of the product of <pol1> and <pol2>.
DeclareOperation(
    "ProductCoeffs",
    [ IsList, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ReduceCoeffs( <list1> [,<len1>], <list2> [,<len2>] )
##
##  changes <list1> to the coefficient list of the remainder when dividing
##  <pol1> by <pol2>.
##  This operation changes <list1> which therefore must be a mutable list.
##  The operations returns the position of the last non-zero entry of the
##  result but is not guaranteed to remove trailing zeroes.
DeclareOperation(
    "ReduceCoeffs",
    [ IsList, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ReduceCoeffsMod( <list1>, [<len1>,] <list2>, [<len2>,] <mod> )
##
##  changes <list1> to the coefficient list of the remainder when dividing
##  <pol1> by <pol2> modulo <mod>. <mod> must be a positive integer.
##  This operation changes <list1> which therefore must be a mutable list.
##  The operations returns the position of the last non-zero entry of the
##  result but is not guaranteed to remove trailing zeroes.
DeclareOperation(
    "ReduceCoeffsMod",
    [ IsList, IsInt, IsList, IsInt, IsInt ] );



#############################################################################
##
#O  RemoveOuterCoeffs( <list>, <coef> )
##
##  removes <coef> at the beginning and at the end of <list> and returns the
##  number of elements removed at the beginning.
DeclareOperation(
    "RemoveOuterCoeffs",
    [ IsList, IsObject ] );


#############################################################################
##
#O  ShiftedCoeffs( <list>, <shift> )
##
##  produces a new coefficient list <new> obtained by the rule
##  `<new>[i+<shift>]:=<list>[i]' and filling initial holes by the
##  appropriate zero.
DeclareOperation(
    "ShiftedCoeffs",
    [ IsList, IsInt ] );


#############################################################################
##
#O  ShrinkCoeffs( <list> )
##
##  removes trailing zeroes from <list>. It returns the position of the last
##  non-zero entry, that is the length of <list> after the operation.
DeclareOperation(
    "ShrinkCoeffs",
    [ IsList ] );


#3
##  The following functions perform operations on FFE vectors considered as
##  code words.

#############################################################################
##
#O  WeightVecFFE( <vec> )
##
##  returns the weight of the finite field vector <vec>, i.e. the number of
##  nonzero entries.
DeclareOperation("WeightVecFFE",[IsList]);

#############################################################################
##
#O  DistanceVecFFE( <vec1>,<vec2> )
##
##  returns the distance between the two vectors <vec1> and <vec2>, which
##  must have the same length and whose elements must lie in a common field.
##  The distance is the number of places where <vec1> and <vec2> differ.
DeclareOperation("DistanceVecFFE",[IsList,IsList]);

#############################################################################
##
#O  DistancesDistributionVecFFEsVecFFE( <vecs>,<vec> )
##
##  returns the distances distribution of the vector <vec> to the vectors in
##  the list <vecs>. All vectors must have the same length, and all elements
##  must lie in a common field. The distances distribution is a list <d> of
##  length `Length(<vec>)+1', such that the value `<d>[<i>]' is the number
##  of vectors in <vecs> that have distance `<i>+1' to <vec>.
DeclareOperation("DistancesDistributionVecFFEsVecFFE",[IsList,IsList]);

#############################################################################
##
#O  DistancesDistributionMatFFEVecFFE( <mat>,<f>,<vec> )
##
##  returns the distances distribution of the vector <vec> to the vectors in
##  the vector space generated by the rows of the matrix <mat> over the
##  finite field <f>. The length of the rows of <mat> and the length of
##  <vec> must be equal, and all elements must lie in <f>. The rows of <mat>
##  must be linearly independent. The distances distribution is a list <d>
##  of length `Length(<vec>)+1', such that the value `<d>[<i>]' is the
##  number of vectors in the vector space generated by the rows of <mat>
##  that have distance `<i>+1' to <vec>.
DeclareOperation("DistancesDistributionMatFFEVecFFE",
  [IsMatrix,IsFFECollection, IsList]);

#############################################################################
##
#O  AClosestVectorCombinationsMatFFEVecFFE( <mat>,<f>,<vec>,<l>,<stop> )
##
##  runs through the <f>-linear combinations of the vectors in the rows of
##  the matrix <mat> that can be written as linear combinations of exactly
##  <l> rows (that is without using zero as a coefficient) and returns a
##  vector from these that is closest to the vector <vec>. The length of the
##  rows of <mat> and the length of <vec> must be equal, and all elements
##  must lie in <f>. The rows of <mat> must be linearly independent. If it
##  finds a vector of distance at most <stop>, which must be a nonnegative
##  integer, then it stops immediately and returns this vector.
DeclareOperation("AClosestVectorCombinationsMatFFEVecFFE",
  [IsMatrix,IsFFECollection, IsList, IsInt,IsInt]);

#############################################################################
##
#O  CosetLeadersMatFFE( <mat>,<f> )
##
##  returns a list of representatives of minimal weight for the cosets of a
##  code. <mat> must be a *check matrix* for the code, the code is defined
##  over the finite field <f>.   All rows of <mat> must have the same
##  length, and all elements must lie in <f>. The rows of <mat> must be
##  linearly independent.
DeclareOperation("CosetLeadersMatFFE",[IsMatrix,IsFFECollection]);

#############################################################################
##
#E  listcoef.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
