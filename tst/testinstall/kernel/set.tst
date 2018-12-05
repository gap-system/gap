#
# Tests for functions defined in src/set.c
#
gap> START_TEST("kernel/set.tst");

#
gap> IsSet(1);
false
gap> LIST_SORTED_LIST(1);
Error, Set: <list> must be a small list (not the integer 1)

#
gap> IS_EQUAL_SET;
function( list1, list2 ) ... end
gap> IS_EQUAL_SET(1,1);
Error, IsEqualSet: <list1> must be a small list (not the integer 1)
gap> IS_EQUAL_SET([],1);
Error, IsEqualSet: <list2> must be a small list (not the integer 1)
gap> IS_EQUAL_SET([],[]);
true

#
gap> IS_SUBSET_SET;
function( set1, set2 ) ... end
gap> IS_SUBSET_SET(1,1);
Error, IsSubsetSet: <set1> must be a small list (not the integer 1)
gap> IS_SUBSET_SET([],1);
Error, IsSubsetSet: <set2> must be a small list (not the integer 1)
gap> IS_SUBSET_SET([],[]);
true
gap> IS_SUBSET_SET([1,2,3],[1,2]);
true
gap> IS_SUBSET_SET([1,2,3],[2,1]);
true
gap> IS_SUBSET_SET([1,2,3],[,1]);
true
gap> IS_SUBSET_SET([1,2,3],[1,2,4]);
false
gap> IS_SUBSET_SET([1,2,3],[2,1,4]);
false
gap> IS_SUBSET_SET([1,2,3],[,1,4]);
false

#
gap> ADD_SET;
function( set, val ) ... end
gap> ADD_SET(1,1);
Error, AddSet: <set> must be a mutable proper set (not the integer 1)

#
gap> REM_SET;
function( set, val ) ... end
gap> REM_SET(1,1);
Error, RemoveSet: <set> must be a mutable proper set (not the integer 1)

#
gap> UNITE_SET;
function( set1, set2 ) ... end
gap> UNITE_SET(1,1);
Error, UniteSet: <set1> must be a mutable proper set (not the integer 1)
gap> UNITE_SET([],1);
Error, UniteSet: <set2> must be a small list (not the integer 1)
gap> UNITE_SET([],[]);

#
gap> INTER_SET;
function( set1, set2 ) ... end
gap> INTER_SET(1,1);
Error, IntersectSet: <set1> must be a mutable proper set (not the integer 1)
gap> INTER_SET([],1);
Error, IntersectSet: <set2> must be a small list (not the integer 1)
gap> INTER_SET([],[]);

#
gap> SUBTR_SET;
function( set1, set2 ) ... end
gap> SUBTR_SET(1,1);
Error, SubtractSet: <set1> must be a mutable proper set (not the integer 1)
gap> SUBTR_SET([],1);
Error, SubtractSet: <set2> must be a small list (not the integer 1)
gap> SUBTR_SET([],[]);

#
gap> STOP_TEST("kernel/set.tst", 1);
