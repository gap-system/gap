#############################################################################
##
#W  coll.tst
##
##  Test operations defined in coll.gd
##
gap> START_TEST("coll.tst");
gap> if not IsBound(TestConsistencyOfEnumeratorByFunctions) then
>   ReadGapRoot( "tst/testenumerator.g" );
> fi;

#
# some collections that are not lists
#
gap> F:=FreeGroup(2);;
gap> c1:=ConjugacyClass(F, One(F));;
gap> IsList(c1); IsCollection(c1);
false
true
gap> c2:=ConjugacyClass(F, F.1);;
gap> IsList(c2); IsCollection(c2);
false
true

#############################################################################
#
# IsEmpty
# IsTrivial
# IsNonTrivial
# IsFinite
#
gap> props := [IsEmpty, IsTrivial, IsNonTrivial, IsFinite];;

# ... immediate methods for a collection which knows its size,
# applied to empty collection
gap> M0:=Magma(FamilyObj([1]), []);;
gap> ForAll(props, prop -> not Tester(prop)(M0));
true
gap> Size(M0);
0
gap> ForAll(props, prop -> Tester(prop)(M0));
true
gap> List(props, p -> p(M0));
[ true, false, true, true ]

# ... immediate methods for a collection which knows its size,
# applied to trivial (= size 1) collection
gap> M1:=Magma(1);;
gap> ForAll(props, prop -> not Tester(prop)(M1));
true
gap> Size(M1);
1
gap> ForAll(props, prop -> Tester(prop)(M1));
true
gap> List(props, p -> p(M1));
[ false, true, false, true ]

# ... immediate methods for a collection which knows its size,
# applied to collection with size greater than 1
gap> M2:=Magma(0, 1);;
gap> ForAll(props, prop -> not Tester(prop)(M2));
true
gap> Size(M2);
2
gap> ForAll(props, prop -> Tester(prop)(M2));
true
gap> List(props, p -> p(M2));
[ false, false, true, true ]

# ... for a collection which does not know its size
gap> List(props, p -> p(Magma(FamilyObj([1]), [])));
[ true, false, true, true ]
gap> List(props, p -> p(Magma(1)));
[ false, true, false, true ]
gap> List(props, p -> p(Magma(0, 1)));
[ false, false, true, true ]

# for a list
gap> IsEmpty([]);
true
gap> IsFinite([]);
true
gap> List(props, p -> p([1]));
[ false, true, false, true ]
gap> List(props, p -> p([0,1]));
[ false, false, true, true ]

#############################################################################
#
# IsWholeFamily
#
gap> IsWholeFamily([1]);
Error, cannot test whether <C> contains the family of its elements

#############################################################################
#
# Size
#

# immediate method for collections knowing they are infinite
gap> c2:=ConjugacyClass(F, F.1);;
gap> HasSize(c2);
false
gap> SetIsFinite(c2, false);
gap> HasSize(c2);
true
gap> Size(c2);
infinity

# immediate method for collections with HasAsList
gap> M2:=Magma(0, 1);;
gap> HasSize(M2);
false
gap> SetAsList(M2, [0,1]);
gap> HasSize(M2);
true
gap> Size(M2);
2

# method for collections, by computing length of enumerator
gap> M2:=Magma(0, 1);;
gap> Size(M2);
2

#############################################################################
#
# Representative
#
gap> Representative([1]);
1
gap> Representative([]);
Error, <list> must be nonempty to have a representative

#############################################################################
#
# RepresentativeSmallest
#
# ... for an (empty) collection
gap> M0:=Magma(FamilyObj([1]), []);;

# first go through the generic collection method, and trigger the error there
gap> RepresentativeSmallest(M0);
Error, <C> must be nonempty to have a representative

# now AsSSortedList(M0) is set, so calling RepresentativeSmallest again
# goes through another method which tests HasAsSSortedList
gap> RepresentativeSmallest(M0);
Error, <C> must be nonempty to have a representative

# recreate M0 with EnumeratorSorted set but not AsSSortedList
# to trigger a third method
gap> M0:=Magma(FamilyObj([1]), []);;
gap> SetEnumeratorSorted(M0, []);
gap> RepresentativeSmallest(M0);
Error, <C> must be nonempty to have a representative

#############################################################################
#
# Random
# RandomList
# PseudoRandom
#
# TODO

#############################################################################
#
# Enumerator
#
gap> Enumerator(c1);
[ <identity ...> ]
gap> Enumerator(M0);
[  ]
gap> enum := Enumerator(M2);;
gap> TestConsistencyOfEnumeratorByFunctions(enum);
true
gap> Size(enum);
2

#############################################################################
#
# EnumeratorSorted
#
gap> EnumeratorSorted(M0);
[  ]
gap> EnumeratorSorted(M2);
[ 0, 1 ]

#############################################################################
#
# EnumeratorOfSubset
#
gap> EnumeratorOfSubset();
Error, usage: EnumeratorOfSubset( <list>, <blist>[, <ishomog>] )
gap> enum:=EnumeratorOfSubset([1,2,Z(3)], [true,false,true]);
Error, missing third argument <ishomog> for inhomog. <list>

#
gap> enum:=EnumeratorOfSubset([1,2,3], [true,false,true]);
<enumerator>
gap> TestConsistencyOfEnumeratorByFunctions(enum);
true
gap> AsList(enum);
[ 1, 3 ]

# 
gap> enum:=EnumeratorOfSubset([1,Z(2),3], [true,false,true], true);
<enumerator>
gap> TestConsistencyOfEnumeratorByFunctions(enum);
true
gap> AsList(enum);
[ 1, 3 ]

# 
gap> enum:=EnumeratorOfSubset([1,2,Z(3)], [true,false,true], false);
<enumerator>
gap> TestConsistencyOfEnumeratorByFunctions(enum);
true
gap> AsList(enum);
[ 1, Z(3) ]

#############################################################################
#
# EnumeratorByFunctions
#
# Since most other non-list enumerators in GAP are implemented using
# EnumeratorByFunctions, there is no strong need to test it explicitly
# by constructing yet another type of enum. It might still be useful to
# do so at some point, to specifically test some of the more exotic or
# undocumented aspects, but for now we don't do it.
#
gap> EnumeratorByFunctions(1,1);
Error, <record> must be a record with components `ElementNumber'
and `NumberElement'

#
gap> enum:=Enumerator(M1);
<enumerator of <trivial group with 1 generator>>
gap> IsEnumeratorByFunctions(enum);
true
gap> Print(enum, "\n");
<enumerator of Semigroup( [ 1 ] )>

#############################################################################
#
# Iterator
#
gap> iter:=Iterator(M1);
<iterator>
gap> List(iter);
[ 1 ]

#
gap> iter:=Iterator([2,1]);
<iterator>
gap> List(iter);
[ 2, 1 ]

#############################################################################
#
# IteratorSorted
#
gap> iter:=IteratorSorted(M1);
<iterator>
gap> List(iter);
[ 1 ]

#
gap> iter:=IteratorSorted([2,1]);
<iterator>
gap> List(iter);
[ 1, 2 ]

#############################################################################
#
# IteratorByFunctions
#
gap> IteratorByFunctions(1);
Error, <record> must be a record with components `NextIterator',
`IsDoneIterator', and `ShallowCopy'

#############################################################################
#
# ConcatenationIterators
#
gap> iter:=ConcatenationIterators([Iterator(M1), Iterator(M0), Iterator([2,3])]);
<iterator>
gap> List(iter);
[ 1, 2, 3 ]

#############################################################################
#
# TrivialIterator
#
gap> iter:=TrivialIterator(42);
<iterator>
gap> List(iter);
[ 42 ]

#############################################################################
#
# List
# SortedList
# SSortedList = Set
#
# These functions are already being tested extensively via calls from
# elsewhere, so we don't bother to add further explicit tests.

#############################################################################
#
# AsList
# AsSortedList
# AsSSortedList = AsSet
#
gap> res:=List([AsList,AsSortedList,AsSet], f -> f(Magma(FamilyObj([1]), [])));
[ [  ], [  ], [  ] ]
gap> List(res,IsMutable);
[ false, false, false ]
gap> res:=List([AsList,AsSortedList,AsSet], f -> f(Magma(1)));
[ [ 1 ], [ 1 ], [ 1 ] ]
gap> List(res,IsMutable);
[ false, false, false ]

#############################################################################
#
# Sum
#
gap> Sum();
Error, usage: Sum( <C>[, <func>][, <init>] )

# for plain lists
gap> Sum([0,1]);
1
gap> Sum([0,1], x->x+1);
3
gap> Sum([0,1], 4);
5
gap> Sum([0,1], x->x+1, 4);
7

# for other collections
gap> Sum(M0);
0
gap> Sum(M0, x->x+1);
0
gap> Sum(M2);
1
gap> Sum(M2, x->x+1);
3
gap> Sum(M2, 4);
5
gap> Sum(M2, x->x+1, 4);
7

# input validation
gap> Sum();
Error, usage: Sum( <C>[, <func>][, <init>] )
gap> Sum([0,1], 4, x->x+1);
Error, usage: Sum( <C>[, <func>][, <init>] )

#############################################################################
#
# Product
#

# for plain lists
gap> Product([0,1]);
0
gap> Product([0,1], x->x+1);
2
gap> Product([0,1], 4);
0
gap> Product([0,1], x->x+1, 4);
8

# for other collections
gap> Product(M0);
1
gap> Product(M0, x->x+1);
1
gap> Product(M2);
0
gap> Product(M2, x->x+1);
2
gap> Product(M2, 4);
0
gap> Product(M2, x->x+1, 4);
8

# input validation
gap> Product();
Error, usage: Product( <C>[, <func>][, <init>] )
gap> Product([0,1], 4, x->x+1);
Error, usage: Product( <C>[, <func>][, <init>] )

#############################################################################
#
# Filtered
#
gap> Filtered([1,2,3],x->x>1);
[ 2, 3 ]
gap> FilteredOp([1,,3],x->x>1);
[ 3 ]

#
gap> v:=ImmutableVector(GF(5),[Z(5)^0,Z(5)^2]);;
gap> Filtered(v, IsOne);
[ Z(5)^0 ]
gap> Filtered(M0, ReturnTrue);
[  ]
gap> Filtered(M1, ReturnTrue);
[ 1 ]
gap> Filtered(M2, ReturnTrue);
[ 0, 1 ]

#############################################################################
#
# Number
#
gap> Number([1,2,3]);
3
gap> Number([1,2,3],x->x>1);
2
gap> NumberOp([1,,3]);
2
gap> NumberOp([1,,3],x->x>1);
1

#
gap> v:=ImmutableVector(GF(5),[Z(5)^0,Z(5)^2]);;
gap> Number(v);
2
gap> Number(v, IsOne);
1
gap> Number(M0);
0
gap> Number(M1);
1
gap> Number(M2);
2

# input validation
gap> Number();
Error, usage: Number( <C>[, <func>] )

#############################################################################
#
# ForAll
# ForAny
#
gap> ForAll([], ReturnTrue);
true
gap> ForAll([], ReturnFalse);
true
gap> ForAll([1], ReturnTrue);
true
gap> ForAll([1], ReturnFalse);
false

#
gap> ForAny([], ReturnTrue);
false
gap> ForAny([], ReturnFalse);
false
gap> ForAny([1], ReturnTrue);
true
gap> ForAny([1], ReturnFalse);
false

# test non-dense argument of the operation (bypassing the special case
# for all plists in the ForAll and ForAny functions)
gap> ForAllOp([1,,3], ReturnTrue);
true
gap> ForAllOp([1,,3], ReturnFalse);
false
gap> ForAnyOp([1,,3], ReturnTrue);
true
gap> ForAnyOp([1,,3], ReturnFalse);
false

#############################################################################
#
# ListX
# SetX
# SumX
# ProductX
#
gap> ListX([1..3], [1..3], {a,b}->[a,b]);
[ [ 1, 1 ], [ 1, 2 ], [ 1, 3 ], [ 2, 1 ], [ 2, 2 ], [ 2, 3 ], [ 3, 1 ], 
  [ 3, 2 ], [ 3, 3 ] ]
gap> ListX([1..3], n -> [1..n], {a,b}->[a,b]);
[ [ 1, 1 ], [ 2, 1 ], [ 2, 2 ], [ 3, 1 ], [ 3, 2 ], [ 3, 3 ] ]
gap> ListX([1..3], [1..3], \<, {a,b}->[a,b]);
[ [ 1, 2 ], [ 1, 3 ], [ 2, 3 ] ]

#
gap> args:=[ [1..3], [1..3], \+ ];;
gap> CallFuncList(SetX, args) = Set(CallFuncList(ListX, args));
true
gap> CallFuncList(SumX, args) = Sum(CallFuncList(ListX, args));
true
gap> CallFuncList(ProductX, args) = Product(CallFuncList(ListX, args));
true

#
gap> args:=[ [1..3], [1..3], \<, \+ ];;
gap> CallFuncList(SetX, args) = Set(CallFuncList(ListX, args));
true
gap> CallFuncList(SumX, args) = Sum(CallFuncList(ListX, args));
true
gap> CallFuncList(ProductX, args) = Product(CallFuncList(ListX, args));
true

#
gap> args:=[ [1..3], n -> [1..n], \+ ];;
gap> CallFuncList(SetX, args) = Set(CallFuncList(ListX, args));
true
gap> CallFuncList(SumX, args) = Sum(CallFuncList(ListX, args));
true
gap> CallFuncList(ProductX, args) = Product(CallFuncList(ListX, args));
true

#############################################################################
#
# Perform
#
gap> Perform([1,2,3], Display);
1
2
3

#############################################################################
#
# IsSubset
#
# TODO

#############################################################################
#
# Intersection
# Intersection2
#
gap> Intersection([]);
[  ]
gap> Intersection([1]);
Error, Intersection: arguments must be lists or collections

# for two lists (not necessarily in the same family)
gap> Intersection2([0,1], [0,Z(2)]);
[ 0 ]

# for two lists or collections, the second being empty
gap> Intersection2([1], []);
[  ]

# for two lists or collections, the first being empty
gap> Intersection2([], [1]);
[  ]

# for two collections in the same family, both lists
gap> Intersection2([0], [0,1]);
[ 0 ]
gap> Intersection2([0,1], [0]);
[ 0 ]

# for two collections in different families
gap> Intersection2(Rationals, GF(2));
[  ]

# for two collections in the same family, the second being a list
gap> Intersection2(M2, [0,1]);
[ 0, 1 ]
gap> Intersection2(Rationals, [0,1]);
[ 0, 1 ]

# for two collections in the same family, the first being a list
gap> Intersection2([0,1], M2);
[ 0, 1 ]
gap> Intersection2([0,1], Rationals);
[ 0, 1 ]

# for two collections in the same family
gap> Intersection2(M2, M2) = M2;
true
gap> Intersection2(M2, Rationals) = M2;
true
gap> Intersection2(Rationals, M2) = M2;
true

# test some formerly buggy cases
gap> Intersection([ -1 .. 1 ], [ -1 .. 1 ]); # previously was empty
[ -1 .. 1 ]
gap> Intersection([ 2, 4 .. 10 ], [ 3 .. 5 ]); # previously was [ 4, 6 ]
[ 4 ]
gap> Intersection([1..3], [4..5], [6,7]);
[  ]

#############################################################################
#
# Union
# Union2
#
# see union.tst

# for two collections that are lists
gap> Union2([0,1], [0,Z(2)]);
[ 0, 1, Z(2)^0 ]

# for two lists
gap> Union2([0,1], [0]);
[ 0, 1 ]
gap> Union2([0], [0,1]);
[ 0, 1 ]

# for two collections, the second being a list
gap> Union2(M1, [0,1]);
[ 0, 1 ]
gap> Union2(c1, AsList(c1)) = c1;
true

# for two collections, the first being a list
gap> Union2([0,1], M1);
[ 0, 1 ]
gap> Union2(AsList(c1), c1) = c1;
true

# for two collections
gap> Union2(M1, M2);
[ 0, 1 ]

#############################################################################
#
# Difference
#
gap> Difference([], M1);
[  ]
gap> Difference(M1, []) = M1;
true
gap> Difference([1,2],[1,Z(2)]);
[ 2 ]
gap> Difference([1,2],[1,3]);
[ 2 ]

# for two collections in different families
gap> Difference(M1, c2) = M1;
true

# for two collections in the same family
gap> Difference(M2, M1);
[ 0 ]

# FIXME/TODO: the following test is for now disabled, as it fails when
# the ResClasses package is loaded, which installs a buggy method
#gap> Difference(M2, Rationals);
#[  ]
# The following test only terminates if the FGA package is loaded
gap> not IsPackageMarkedForLoading("fga","") or Difference(c1, c2) = c1;
true

# for two collections, the first being a list
gap> Difference([0,1], M1);
[ 0 ]
gap> Difference([0,1], Rationals);
[  ]

# for two collections, the second being a list
gap> Difference(M2, [1]);
[ 0 ]

#
gap> STOP_TEST( "coll.tst", 1);
