#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##


#############################################################################
##
##  <#GAPDoc Label="[1]{listcoef}">
##  The following operations all perform arithmetic on row vectors,
##  given as homogeneous lists of the same length, containing
##  elements of a commutative ring.
##  <P/>
##  There are two reasons for using <Ref Oper="AddRowVector"/>
##  in preference to arithmetic operators.
##  Firstly, the three argument form has no single-step equivalent.
##  Secondly <Ref Oper="AddRowVector"/> changes its first argument in-place,
##  rather than allocating a new vector to hold the result,
##  and may thus produce less garbage.
##  <#/GAPDoc>
##

#############################################################################
##
#O  AddVector( <dst>, <src>[, <mul>[, <from>, <to>]] )
##
##  <#GAPDoc Label="AddRowVector">
##  <ManSection>
##  <Oper Name="AddVector" Arg='dst, src[, mul[, from, to]]'/>
##  <Oper Name="AddRowVector" Arg='dst, src[, mul[, from, to]]'/>
##
##  <Description>
##  Adds the product of <A>src</A> and <A>mul</A> to <A>dst</A>,
##  changing <A>dst</A>.
##  If <A>from</A> and <A>to</A> are given then only the index range
##  <C>[ <A>from</A> .. <A>to</A> ]</C> is guaranteed to be affected.
##  Other indices <E>may</E> be affected, if it is more convenient to do so.
##  Even when <A>from</A> and <A>to</A> are given,
##  <A>dst</A> and <A>src</A> must be row vectors of the <E>same</E> length.
##  <P/>
##  If <A>mul</A> is not given either then this operation simply adds
##  <A>src</A> to <A>dst</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "AddVector",
    [ IsMutable and IsList, IsList, IsMultiplicativeElement, IsPosInt,
      IsPosInt ] );

DeclareSynonym( "AddRowVector", AddVector );


#############################################################################
##
#O  AddCoeffs( <list1>, <poss1>, <list2>, <poss2>, <mul> )
#O  AddCoeffs( <list1>, <list2>, <mul> )
#O  AddCoeffs( <list1>, <list2> )
##
##  <#GAPDoc Label="AddCoeffs">
##  <ManSection>
##  <Oper Name="AddCoeffs" Arg='list1[, poss1], list2[, poss2[, mul]]'/>
##
##  <Description>
##  <Ref Oper="AddCoeffs"/> adds the entries of
##  <A>list2</A><C>{</C><A>poss2</A><C>}</C>, multiplied by the scalar
##  <A>mul</A>, to <A>list1</A><C>{</C><A>poss1</A><C>}</C>.
##  Unbound entries in <A>list1</A> are assumed to be zero.
##  The position of the right-most non-zero element is returned.
##  <P/>
##  If the ranges <A>poss1</A> and <A>poss2</A> are not given,
##  they are assumed to span the whole vectors.
##  If the scalar <A>mul</A> is omitted, one is used as a default.
##  <P/>
##  Note that it is the responsibility of the caller to ensure that
##  <A>list2</A> has elements at position <A>poss2</A> and that the result
##  (in <A>list1</A>) will be a dense list.
##  <P/>
##  The function is free to remove trailing (right-most) zeros.
##  <Example><![CDATA[
##  gap> l:=[1,2,3,4];;m:=[5,6,7];;AddCoeffs(l,m);
##  4
##  gap> l;
##  [ 6, 8, 10, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "AddCoeffs",
        [ IsMutable and IsList,
          IsList, IsList, IsList, IsMultiplicativeElement ] );


#############################################################################
##
#O  MultVectorLeft( <list>, <mul> )
##
##  <#GAPDoc Label="MultVector">
##  <ManSection>
##  <Oper Name="MultVector" Arg='list1, mul'/>
##  <Oper Name="MultVectorLeft" Arg='list1, mul'/>
##  <Returns>nothing</Returns>
##
##  <Description>
##  This operation calculates <A>mul</A>*<A>list1</A> in-place.
##  <P/>
##  Note that <C>MultVector</C> is just a synonym for
##  <C>MultVectorLeft</C>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "MultVectorLeft",
        [ IsMutable and IsList,
          IsObject ] );
# For VectorObj objects there also exists a MultVectorRight operation
DeclareSynonym( "MultVector", MultVectorLeft );

#############################################################################
##
#O  CoeffsMod( <list1>, [<len1>, ]<modulus> )
##
##  <#GAPDoc Label="CoeffsMod">
##  <ManSection>
##  <Oper Name="CoeffsMod" Arg='list1, [len1, ]modulus'/>
##
##  <Description>
##  returns the coefficient list obtained by reducing the entries in
##  <A>list1</A> modulo <A>modulus</A>.
##  After reducing it shrinks the list to remove trailing zeroes.
##  If the optional argument <A>len1</A> is used, it reduces
##  only first <A>len1</A> elements of the list.
##  <Example><![CDATA[
##  gap> l:=[1,2,3,4];;CoeffsMod(l,2);
##  [ 1, 0, 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "CoeffsMod",
    [ IsList, IsInt, IsInt ] );


#############################################################################
##
##  <#GAPDoc Label="[2]{listcoef}">
##  The following operations all perform arithmetic on univariate
##  polynomials given by their coefficient lists. These lists can have
##  different lengths but must be dense homogeneous lists containing
##  elements of a commutative ring.
##  Not all input lists may be empty.
##  <P/>
##  In the following descriptions we will always assume that <A>list1</A> is
##  the coefficient list of the polynomial <A>pol1</A> and so forth.
##  If length parameter <A>leni</A> is not given, it is set to the length of
##  <A>listi</A> by default.
##  <#/GAPDoc>
##


#############################################################################
##
#O  MultCoeffs( <list1>, <list2>[, <len2>], <list3>[, <len3>] )
##
##  <ManSection>
##  <Oper Name="MultCoeffs" Arg='list1, list2[, len2], list3[, len3]'/>
##
##  <Description>
##  <E> Only used internally</E>
##  Let <A>pol2</A> (and <A>pol3</A>) be polynomials given by the first
##  <A>len2</A> (<A>len3</A>) entries of the coefficient list <A>list2</A>
##  (<A>list3</A>).
##  If <A>len2</A> and <A>len3</A> are omitted, they default to the lengths
##  of <A>list2</A> and <A>list3</A>.
##  This operation changes <A>list1</A> to the coefficient list of the product
##  of <A>pol2</A> with <A>pol3</A>.
##  This operation changes <A>list1</A> which therefore must be a mutable list.
##  The operation returns the position of the last non-zero entry of the
##  result but is not guaranteed to remove trailing zeroes.
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "MultCoeffs",
    [ IsMutable and IsList, IsList, IsInt, IsList, IsInt ] );

#############################################################################
##
#O  PowerModCoeffs( <list1>[, <len1>], <exp>, <list2>[, <len2>] )
##
##  <#GAPDoc Label="PowerModCoeffs">
##  <ManSection>
##  <Oper Name="PowerModCoeffs" Arg='list1[, len1], exp, list2[, len2]'/>
##
##  <Description>
##  Let <M>p1</M> and <M>p2</M> be polynomials whose coefficients are given
##  by the first <A>len1</A> resp. <A>len2</A> entries of the lists
##  <A>list1</A> and <A>list2</A>, respectively.
##  If <A>len1</A> and <A>len2</A> are omitted, they default to the lengths
##  of <A>list1</A> and <A>list2</A>.
##  Let <A>exp</A> be a positive integer.
##  <Ref Oper="PowerModCoeffs"/> returns the coefficient list of the
##  remainder when dividing the <A>exp</A>-th power of <M>p1</M> by
##  <M>p2</M>.
##  The coefficients are reduced already while powers are computed,
##  therefore avoiding an explosion in list length.
##  <Example><![CDATA[
##  gap> l:=[1,2,3,4];;m:=[5,6,7];;PowerModCoeffs(l,5,m);
##  [ -839462813696/678223072849, -7807439437824/678223072849 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "PowerModCoeffs",
    [ IsList, IsInt, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ProductCoeffs( <list1>[, <len1>], <list2>[, <len2>] )
##
##  <#GAPDoc Label="ProductCoeffs">
##  <ManSection>
##  <Oper Name="ProductCoeffs" Arg='list1[, len1], list2[, len2]'/>
##
##  <Description>
##  Let <M>p1</M> (and <M>p2</M>) be polynomials given by the first
##  <A>len1</A> (<A>len2</A>) entries of the coefficient list <A>list2</A>
##  (<A>list2</A>).
##  If <A>len1</A> and <A>len2</A> are omitted,
##  they default to the lengths of <A>list1</A> and <A>list2</A>.
##  This operation returns the coefficient list of the product of <M>p1</M>
##  and <M>p2</M>.
##  <Example><![CDATA[
##  gap> l:=[1,2,3,4];;m:=[5,6,7];;ProductCoeffs(l,m);
##  [ 5, 16, 34, 52, 45, 28 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "ProductCoeffs",
    [ IsList, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ReduceCoeffs( <list1>[, <len1>], <list2>[, <len2>] )
##
##  <#GAPDoc Label="ReduceCoeffs">
##  <ManSection>
##  <Oper Name="ReduceCoeffs" Arg='list1[, len1], list2[, len2]'/>
##
##  <Description>
##  Let <M>p1</M> (and <M>p2</M>) be polynomials given by the first
##  <A>len1</A> (<A>len2</A>) entries of the coefficient list <A>list1</A>
##  (<A>list2</A>).
##  If <A>len1</A> and <A>len2</A> are omitted,
##  they default to the lengths of <A>list1</A> and <A>list2</A>.
##  <Ref Oper="ReduceCoeffs"/> changes <A>list1</A> to the coefficient list
##  of the remainder when dividing <A>p1</A> by <A>p2</A>.
##  This operation changes <A>list1</A> which therefore must be a mutable
##  list.
##  The operation returns the position of the last non-zero entry of the
##  result but is not guaranteed to remove trailing zeroes.
##  <Example><![CDATA[
##  gap> l:=[1,2,3,4];;m:=[5,6,7];;ReduceCoeffs(l,m);
##  2
##  gap> l;
##  [ 64/49, -24/49, 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "ReduceCoeffs",
    [ IsMutable and IsList, IsInt, IsList, IsInt ] );


#############################################################################
##
#O  ReduceCoeffsMod( <list1>[, <len1>], <list2>[, <len2>], <modulus> )
##
##  <#GAPDoc Label="ReduceCoeffsMod">
##  <ManSection>
##  <Oper Name="ReduceCoeffsMod"
##   Arg='list1[, len1], list2[, len2], modulus'/>
##
##  <Description>
##  Let <M>p1</M> (and <M>p2</M>) be polynomials given by the first
##  <A>len1</A> (<A>len2</A>) entries of the coefficient list <A>list1</A>
##  (<A>list2</A>).
##  If <A>len1</A> and <A>len2</A> are omitted,
##  they default to the lengths of <A>list1</A> and <A>list2</A>.
##  <Ref Oper="ReduceCoeffsMod"/> changes <A>list1</A> to the
##  coefficient list of the remainder when dividing
##  <A>p1</A> by <A>p2</A> modulo <A>modulus</A>,
##  which must be a positive integer.
##  This operation changes <A>list1</A> which therefore must be a mutable
##  list.
##  The operation returns the position of the last non-zero entry of the
##  result but is not guaranteed to remove trailing zeroes.
##  <Example><![CDATA[
##  gap> l:=[1,2,3,4];;m:=[5,6,7];;ReduceCoeffsMod(l,m,3);
##  1
##  gap> l;
##  [ 1, 0, 0, 0 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "ReduceCoeffsMod",
    [ IsMutable and IsList, IsInt, IsList, IsInt, IsInt ] );

#############################################################################
##
#O  QuotRemCoeffs( <list1>[, <len1>], <list2>[, <len2>])
##
##  <ManSection>
##  <Oper Name="QuotRemCoeffs" Arg='list1[, len1], list2[, len2]'/>
##
##  <Description>
##  returns a length 2 list containing the quotient and remainder from the
##  division of the polynomial represented by
##  (the first <A>len1</A> entries of) <A>list1</A> by that represented by
##  (the first <A>len2</A> entries of) <A>list2</A>
##  </Description>
##  </ManSection>
##
DeclareOperation( "QuotRemCoeffs", [IsList, IsInt, IsList, IsInt]);


#############################################################################
##
#F  ValuePol( <coeff>, <x> ) . . . .  evaluate a polynomial at a point
##
##  <#GAPDoc Label="ValuePol">
##  <ManSection>
##  <Oper Name="ValuePol" Arg='coeff, x'/>
##
##  <Description>
##  Let <A>coeff</A> be the coefficients list of a univariate polynomial
##  <M>f</M>, and <A>x</A> a ring element.
##  Then <Ref Oper="ValuePol"/> returns the value <M>f(<A>x</A>)</M>.
##  <P/>
##  The coefficient of <M><A>x</A>^i</M> is assumed to be stored
##  at position <M>i+1</M> in the coefficients list.
##  <Example><![CDATA[
##  gap> ValuePol([1,2,3],4);
##  57
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ValuePol",[IsList,IsRingElement] );


#############################################################################
##
##  <#GAPDoc Label="[3]{listcoef}">
##  The following functions change coefficient lists by shifting or
##  trimming.
##  <#/GAPDoc>
##


#############################################################################
##
#O  RemoveOuterCoeffs( <list>, <coef> )
##
##  <#GAPDoc Label="RemoveOuterCoeffs">
##  <ManSection>
##  <Oper Name="RemoveOuterCoeffs" Arg='list, coef'/>
##
##  <Description>
##  removes <A>coef</A> at the beginning and at the end of <A>list</A>
##  and returns the number of elements removed at the beginning.
##  <Example><![CDATA[
##  gap> l:=[1,1,2,1,2,1,1,2,1];; RemoveOuterCoeffs(l,1);
##  2
##  gap> l;
##  [ 2, 1, 2, 1, 1, 2 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "RemoveOuterCoeffs",
    [ IsMutable and IsList, IsObject ] );


#############################################################################
##
#O  ShiftedCoeffs( <list>, <shift> )
##
##  <#GAPDoc Label="ShiftedCoeffs">
##  <ManSection>
##  <Oper Name="ShiftedCoeffs" Arg='list, shift'/>
##
##  <Description>
##  produces a new coefficient list <C>new</C> obtained by the rule
##  <C>new[i+<A>shift</A>]:= <A>list</A>[i]</C>
##  and filling initial holes by the appropriate zero.
##  <Example><![CDATA[
##  gap> l:=[1,2,3];;ShiftedCoeffs(l,2);ShiftedCoeffs(l,-2);
##  [ 0, 0, 1, 2, 3 ]
##  [ 3 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "ShiftedCoeffs",
    [ IsList, IsInt ] );


#############################################################################
##
#O  LeftShiftRowVector( <list>, <shift> )
##
##  <#GAPDoc Label="LeftShiftRowVector">
##  <ManSection>
##  <Oper Name="LeftShiftRowVector" Arg='list, shift'/>
##
##  <Description>
##  changes <A>list</A> by assigning
##  <A>list</A><M>[i]</M><C>:= </C><A>list</A><M>[i+<A>shift</A>]</M>
##  and removing the last <A>shift</A> entries of the result.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "LeftShiftRowVector",
    [ IsMutable and IsList, IsPosInt ] );


#############################################################################
##
#O  RightShiftRowVector( <list>, <shift>, <fill> )
##
##  <#GAPDoc Label="RightShiftRowVector">
##  <ManSection>
##  <Oper Name="RightShiftRowVector" Arg='list, shift, fill'/>
##
##  <Description>
##  changes <A>list</A> by assigning
##  <A>list</A><M>[i+<A>shift</A>]</M><C>:= </C><A>list</A><M>[i]</M>
##  and filling each of the <A>shift</A> first entries with <A>fill</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "RightShiftRowVector",
    [ IsMutable and IsList, IsPosInt, IsObject ] );


#############################################################################
##
#O  ShrinkRowVector( <list> )
##
##  <#GAPDoc Label="ShrinkRowVector">
##  <ManSection>
##  <Oper Name="ShrinkRowVector" Arg='list'/>
##
##  <Description>
##  removes trailing zeroes from the list <A>list</A>.
##  <Example><![CDATA[
##  gap> l:=[1,0,0];;ShrinkRowVector(l);l;
##  [ 1 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "ShrinkRowVector",
    [ IsMutable and IsList ] );


#############################################################################
##
#O  PadCoeffs( <list>, <len>[, <value>] )
##
##  <ManSection>
##  <Oper Name="PadCoeffs" Arg='list, len[, value]'/>
##
##  <Description>
##  extends <A>list</A> until its length is at least <A>len</A> by adding
##  identical  entries <A>value</A> at the end.
##  <P/>
##  If <A>value</A> is omitted, <C>Zero(<A>list</A>[1])</C> is used.
##  In this case <A>list</A>  must not be empty.
##  </Description>
##  </ManSection>
##
DeclareOperation("PadCoeffs",[IsList and IsMutable, IsPosInt, IsObject]);
DeclareOperation( "PadCoeffs",
    [ IsList and IsMutable and IsAdditiveElementWithZeroCollection,
      IsPosInt ] );


#############################################################################
##
##  <#GAPDoc Label="[4]{listcoef}">
##  The following functions perform operations on finite fields vectors
##  considered as code words in a linear code.
##  <#/GAPDoc>
##


#############################################################################
##
#O  WeightVecFFE( <vec> )
##
##  <#GAPDoc Label="WeightVecFFE">
##  <ManSection>
##  <Oper Name="WeightVecFFE" Arg='vec'/>
##
##  <Description>
##  returns the weight of the finite field vector <A>vec</A>, i.e. the number of
##  nonzero entries.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("WeightVecFFE",[IsList]);

#############################################################################
##
#O  DistanceVecFFE( <vec1>,<vec2> )
##
##  <#GAPDoc Label="DistanceVecFFE">
##  <ManSection>
##  <Oper Name="DistanceVecFFE" Arg='vec1,vec2'/>
##
##  <Description>
##  returns the distance between the two vectors <A>vec1</A> and <A>vec2</A>,
##  which must have the same length and whose elements must lie in a common
##  field.
##  The distance is the number of places where <A>vec1</A> and <A>vec2</A>
##  differ.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("DistanceVecFFE",[IsList,IsList]);


#############################################################################
##
#O  DistancesDistributionVecFFEsVecFFE( <vecs>, <vec> )
##
##  <#GAPDoc Label="DistancesDistributionVecFFEsVecFFE">
##  <ManSection>
##  <Oper Name="DistancesDistributionVecFFEsVecFFE" Arg='vecs, vec'/>
##
##  <Description>
##  returns the distances distribution of the vector <A>vec</A> to the
##  vectors in the list <A>vecs</A>.
##  All vectors must have the same length,
##  and all elements must lie in a common field.
##  The distances distribution is a list <M>d</M> of
##  length <C>Length(<A>vec</A>)+1</C>, such that the value <M>d[i]</M> is
##  the number of vectors in <A>vecs</A> that have distance <M>i+1</M> to
##  <A>vec</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("DistancesDistributionVecFFEsVecFFE",[IsList,IsList]);


#############################################################################
##
#O  DistancesDistributionMatFFEVecFFE( <mat>, <F>, <vec> )
##
##  <#GAPDoc Label="DistancesDistributionMatFFEVecFFE">
##  <ManSection>
##  <Oper Name="DistancesDistributionMatFFEVecFFE" Arg='mat, F, vec'/>
##
##  <Description>
##  returns the distances distribution of the vector <A>vec</A> to the
##  vectors in the vector space generated by the rows of the matrix
##  <A>mat</A> over the finite field <A>F</A>.
##  The length of the rows of <A>mat</A> and the length of <A>vec</A> must be
##  equal, and all entries must lie in <A>F</A>.
##  The rows of <A>mat</A> must be linearly independent.
##  The distances distribution is a list <M>d</M> of length
##  <C>Length(<A>vec</A>)+1</C>, such that the value <M>d[i]</M> is the
##  number of vectors in the vector space generated by the rows of <A>mat</A>
##  that have distance <M>i+1</M> to <A>vec</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("DistancesDistributionMatFFEVecFFE",
  [IsMatrix,IsFFECollection, IsList]);


#############################################################################
##
#O  AClosestVectorCombinationsMatFFEVecFFE(<mat>,<f>,<vec>,<cnt>,<stop>)
#O  AClosestVectorCombinationsMatFFEVecFFECoords(<mat>,<f>,<vec>,<cnt>,<stop>)
##
##  <#GAPDoc Label="AClosestVectorCombinationsMatFFEVecFFE">
##  <ManSection>
##  <Oper Name="AClosestVectorCombinationsMatFFEVecFFE"
##   Arg='mat, f, vec, cnt, stop'/>
##  <Oper Name="AClosestVectorCombinationsMatFFEVecFFECoords"
##   Arg='mat, f, vec, cnt, stop'/>
##
##  <Description>
##  These functions run through the <A>f</A>-linear combinations of the
##  vectors in the rows of the matrix <A>mat</A> that can be written as
##  linear combinations of exactly <A>cnt</A> rows (that is without using
##  zero as a coefficient). The length of the rows of <A>mat</A> and the
##  length of <A>vec</A> must be equal, and all elements must lie in the
##  field <A>f</A>.
##  The rows of <A>mat</A> must be linearly independent.
##  <Ref Oper="AClosestVectorCombinationsMatFFEVecFFE"/> returns a vector
##  from these that is closest to the vector <A>vec</A>.
##  If it finds a vector of distance at most <A>stop</A>,
##  which must be a nonnegative integer, then it stops immediately
##  and returns this vector.
##  <P/>
##  <Ref Oper="AClosestVectorCombinationsMatFFEVecFFECoords"/> returns a
##  length 2 list containing the same closest vector and also a vector
##  <A>v</A> with exactly <A>cnt</A> non-zero entries,
##  such that <A>v</A> times <A>mat</A> is the closest vector.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("AClosestVectorCombinationsMatFFEVecFFE",
  [IsMatrix,IsFFECollection, IsList, IsInt,IsInt]);

DeclareOperation("AClosestVectorCombinationsMatFFEVecFFECoords",
  [IsMatrix,IsFFECollection, IsList, IsInt,IsInt]);


#############################################################################
##
#O  CosetLeadersMatFFE( <mat>, <f> )
##
##  <#GAPDoc Label="CosetLeadersMatFFE">
##  <ManSection>
##  <Oper Name="CosetLeadersMatFFE" Arg='mat, f'/>
##
##  <Description>
##  returns a list of representatives of minimal weight for the cosets of a
##  code.
##  <A>mat</A> must be a <E>check matrix</E> for the code,
##  the code is defined over the finite field <A>f</A>.
##  All rows of <A>mat</A> must have the same length, and all elements must
##  lie in the field <A>f</A>.
##  The rows of <A>mat</A> must be linearly independent.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("CosetLeadersMatFFE",[IsMatrix,IsFFECollection]);


#############################################################################
##
#O  AddToListEntries( <list>, <poss>, <x> )
##
##  <ManSection>
##  <Oper Name="AddToListEntries" Arg='list, poss, x'/>
##
##  <Description>
##  modifies <A>list</A> in place by adding <A>x</A> to each of the entries
##  indexed by <A>poss</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation("AddToListEntries", [ IsList and
        IsExtAElementCollection and IsMutable, IsList
        and IsCyclotomicCollection, IsExtAElement ] );
