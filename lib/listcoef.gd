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
##
##  There are two reasons for using  `AddRowVector'
##  in preference to arithmetic operators. Firstly, the three argument 
##  form has no single-step equivalent. Secondly
##  `AddRowVector' changes its first argument in-place, rather than allocating
##  a new vector to hold the result, and may thus produce less garbage.
##

#############################################################################
##
#O  AddRowVector( <dst>, <src>, [ <mul> [,<from>, <to>]] )
##
##  Adds the product of <src> and <mul> to <dst>, changing <dst>.
##  If <from> and <to> are given then only the index range `[<from>..<to>]' is
##  guaranteed to be affected. Other indices MAY be affected, if it is 
##  more convenient to do so. Even when <from> and <to> are given,
##  <dst> and <src> must be row vectors of the *same* length.
##
##  If <mul> is not given either then this Operation simply adds <src> to <dst>.
##
DeclareOperation(
    "AddRowVector",
    [ IsMutable and IsList, IsList, IsMultiplicativeElement, IsPosInt,
      IsPosInt ] );

#############################################################################
##
#O  AddCoeffs( <list1>, <poss1>, <list2>, <poss2>, <mul> )
#O  AddCoeffs( <list1>, <list2>, <mul> )
#O  AddCoeffs( <list1>, <list2> )
##
##  `AddCoeffs' adds the entries  of `<list2>\{<poss2>\}', multiplied by the
##  scalar <mul>, to
##  `<list1>\{<poss1>\}'.  Non-existing  entries  in  <list1> are assumed  to  be
##  zero.  The position of the right-most non-zero element is returned.
##
##  If the ranges <poss1> and <poss2> are not given, they are assumed to
##  span the whole vectors. If the scalar <mul> is omitted, one is used as a
##  default.
##
##  Note  that it is  the responsibility  of the  caller  to ensure  that the
##  <list2> has elements at position <poss2> and that the result (in <list1>)
##  will be a dense list.
##
##  The function is free to remove trailing (right-most) zeros.
##
DeclareOperation(
    "AddCoeffs",
        [ IsMutable and IsList, 
          IsList, IsList, IsList, IsMultiplicativeElement ] );


#############################################################################
##
#O  MultRowVector( <list1>, <poss1>, <list2>, <poss2>, <mul> )
#O  MultRowVector( <list>, <mul> )
##
##  The five-argument version of this Operation replaces
##  `<list1>[<poss1>[<i>]]' by `<mul>*<list2>[<poss2>[<i>]]' for <i>
##  between 1 and `Length(<poss1>)'.
##
##  The two-argument version simply multiplies each element of <list>, 
##  in-place, by <mul>.

DeclareOperation(
    "MultRowVector",
        [ IsMutable and IsList, 
          IsList, IsList, IsList, IsMultiplicativeElement ] );

#############################################################################
##
#O  CoeffsMod( <list1>, [<len1>,] <mod> )
##
##  returns the coefficient list obtained by reducing the entries in <list1>
##  modulo <mod>. After reducing it shrinks the list to remove trailing
##  zeroes.
DeclareOperation(
    "CoeffsMod",
    [ IsList, IsInt, IsInt ] );

#2
##  The following operations all perform arithmetic on univariate
##  polynomials given by their coefficient lists. These lists can have
##  different lengths but must be dense homogeneous lists containing
##  elements of a commutative ring.
##  Not all input lists may be empty.
##
##  In the following descriptions we will always assume that <list1> is the
##  coefficient list of the polynomial <pol1> and so forth.
##  If length parameter <leni> is not given, it is set to the length of
##  <listi> by default.

#############################################################################
##
#O  MultCoeffs( <list1>, <list2>[, <len2>], <list3>[, <len3>] )
##
##  * Only used internally *
##  Let <pol2> (and <pol3>) be polynomials given by the first <len2> (<len3>)
##  entries of the coefficient list <list2> (<list3>).
##  If <len2> and <len3> are omitted, they default to the lengths of <list2>
##  and <list3>.
##  This operation changes <list1> to the coefficient list of the product
##  of <pol2> with <pol3>.
##  This operation changes <list1> which therefore must be a mutable list.
##  The operations returns the position of the last non-zero entry of the
##  result but is not guaranteed to remove trailing zeroes.
DeclareOperation(
    "MultCoeffs",
    [ IsMutable and IsList, IsList, IsInt, IsList, IsInt ] );

#############################################################################
##
#O  PowerModCoeffs( <list1>[, <len1>], <exp>, <list2>[, <len2>] )
##
##  Let $p_1$ and $p_2$ be polynomials whose coefficients are given by the
##  first <len1> resp. <len2> entries of the lists <list1> and <list2>,
##  respectively.
##  If <len1> and <len2> are omitted, they default to the lengths of <list1>
##  and <list2>.
##  Let <exp> be a positive integer.
##  `PowerModCoeffs' returns the coefficient list of the remainder
##  when dividing the <exp>-th power of $p_1$ by $p_2$.
##  The coefficients are reduced already while powers are computed,
##  therefore avoiding an explosion in list length.
##
DeclareOperation(
    "PowerModCoeffs",
    [ IsList, IsInt, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ProductCoeffs( <list1>, [<len1>,] <list2> [,<len2>] )
##
##  Let <pol1> (and <pol2>) be polynomials given by the first <len1> (<len2>)
##  entries of the coefficient list <list2> (<list2>).
##  If <len1> and <len2> are omitted, they default to the lengths of <list1>
##  and <list2>.
##  This operation returns the coefficient list of the product of <pol1> and
##  <pol2>.
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
    [ IsMutable and IsList, IsInt, IsList, IsInt ] );


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
    [ IsMutable and IsList, IsInt, IsList, IsInt, IsInt ] );

#############################################################################
##
#F  ProductPol( <coeffs_f>, <coeffs_g> )  . . . .  product of two polynomials
##
##  *@ OBSOLETE @*
##  Let <coeffs_f> and <coeffs_g> be coefficients lists of two univariate
##  polynomials $f$ and $g$, respectively.
##  `ProductPol' returns the coefficients list of the product $f g$.
##
##  The coefficient of $x^i$ is assumed to be stored at position $i+1$ in
##  the coefficients lists.
##
DeclareGlobalFunction( "ProductPol" );


#############################################################################
##
#F  ValuePol( <coeff>, <x> ) . . . .  evaluate a polynomial at a point
##
##  Let <coeff> be the coefficients list of a univariate polynomial $f$,
##  and <x> a ring element. Then
##  `ValuePol' returns the value $f(<x>)$.
##
##  The coefficient of $x^i$ is assumed to be stored at position $i+1$ in
##  the coefficients list.
##
DeclareOperation( "ValuePol",[IsList,IsRingElement] );


#3
##  The following functions change coefficient lists by shifting or
##  trimming.

#############################################################################
##
#O  RemoveOuterCoeffs( <list>, <coef> )
##
##  removes <coef> at the beginning and at the end of <list> and returns the
##  number of elements removed at the beginning.
DeclareOperation(
    "RemoveOuterCoeffs",
    [ IsMutable and IsList, IsObject ] );


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
#O  LeftShiftRowVector( <list>, <shift> )
##
##  changes <list> by assigning
##  `<list>[i]:=<list>[i+<shift>]' and removing the last <shift> entries of
##  the result.
DeclareOperation(
    "LeftShiftRowVector",
    [ IsMutable and IsList, IsPosInt ] );

#############################################################################
##
#O  RightShiftRowVector( <list>, <shift>, <fill> )
##
##  changes <list> by assigning
##  `<list>[i+<shift>]:=<list>[i]' and filling each of the <shift> first
##  entries with <fill>.
DeclareOperation(
    "RightShiftRowVector",
    [ IsMutable and IsList, IsPosInt, IsObject ] );


#############################################################################
##
#O  ShrinkCoeffs( <list> )
##
##  removes trailing zeroes from <list>. It returns the position of the last
##  non-zero entry, that is the length of <list> after the operation.
DeclareOperation(
    "ShrinkCoeffs",
    [ IsMutable and IsList ] );


#############################################################################
##
#O  ShrinkRowVector( <list> )
##
##  removes trailing zeroes from the list <list>.
##
DeclareOperation(
    "ShrinkRowVector",
    [ IsMutable and IsList ] );


#4
##  The following functions perform operations on Finite fields vectors
##  considered as code words in a linear code.


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
#O  AClosestVectorCombinationsMatFFEVecFFE(<mat>,<f>,<vec>,<l>,<stop>)
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
#O AddToListEntries( <list>, <poss>, <x> )
##
##  modifies <list> in place by adding <x> to each of the entries
##  indexed by <poss>.
##
DeclareOperation("AddToListEntries", [ IsList and
        IsExtAElementCollection and IsMutable, IsList
        and IsCyclotomicCollection, IsExtAElement ] );

#############################################################################
##
#E  listcoef.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
