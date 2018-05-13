#
# Tests for functions defined in src/lists.c
#
gap> START_TEST("kernel/lists.tst");

# IsHomogListDefault
# TODO: need to create custom list type to test this

# IsTableListDefault
gap> IsTable([true,false,true]);
false

# IsPossListDefault
# TODO: need to create custom list type to test this

#
gap> SET_FILTER_LIST(fail,fail);
Error, <oper> must be an operation

#
gap> enum:=Enumerator(Integers);
<enumerator of Integers>
gap> IsList(enum);
true
gap> Length(enum);
infinity
gap> IsSmallList(enum);
false

#
gap> ISB_LIST(1,2);
Error, IsBound: <list> must be a list (not a integer)
gap> ISB_LIST([1],1);
true
gap> ISB_LIST([1],2);
false
gap> ISB_LIST([1],[1,2]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `IsBound[]' on 2 arguments
gap> ISB_LIST([[1,2],[3,4]],[1,2]);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `IsBound[]' on 2 arguments

#
gap> UNB_LIST(1,2);
Error, Unbind: <list> must be a list (not a integer)
gap> UNB_LIST([1],1);
gap> UNB_LIST([1],2);

#
gap> ELM0_LIST([1],1);
1
gap> ELM0_LIST([1],2);
fail
gap> ELM0_LIST(1,2);
Error, List Element: <list> must be a list (not a integer)

#
gap> ELM_LIST([1],1);
1
gap> ELM_LIST([1],2);
Error, List Element: <list>[2] must have an assigned value
gap> ELM_LIST(1,2);
Error, List Element: <list> must be a list (not a integer)

#
gap> ELMS_LIST(1,1);
Error, List Elements: <positions> must be a dense list of positive integers
gap> ELMS_LIST([1],1);
Error, List Elements: <positions> must be a dense list of positive integers
gap> ELMS_LIST([1],[2]);
Error, List Elements: <list>[2] must have an assigned value
gap> ELMS_LIST([1,2,3],[1,3]);
[ 1, 3 ]
gap> ELMS_LIST([1],[1,2^100,3]);
Error, List Elements: position is too large for this type of list
gap> ELMS_LIST([1,2,3],[1..4]);
Error, List Elements: <list>[4] must have an assigned value
gap> ELMS_LIST([1,2,3],[4..5]);
Error, List Elements: <list>[4] must have an assigned value
gap> ELMS_LIST([1,2,3],[1..2]);
[ 1, 2 ]

#
gap> ELMS_LIST_DEFAULT(1,1);
Error, Length: <list> must be a list (not a integer)
gap> ELMS_LIST_DEFAULT([1],1);
Error, Length: <list> must be a list (not a integer)
gap> ELMS_LIST_DEFAULT([1],[2]);
Error, List Elements: <list>[2] must have an assigned value
gap> ELMS_LIST_DEFAULT([1,2,3],[1,3]);
[ 1, 3 ]
gap> ELMS_LIST_DEFAULT([1],[1,2^100,3]);
Error, List Elements: position is too large for this type of list
gap> ELMS_LIST_DEFAULT([1,2,3],[1..4]);
Error, List Elements: <list>[4] must have an assigned value
gap> ELMS_LIST_DEFAULT([1,2,3],[4..5]);
Error, List Elements: <list>[4] must have an assigned value
gap> ELMS_LIST_DEFAULT([1,2,3],[1..2]);
[ 1, 2 ]

#
gap> ASS_LIST(1,1,1);
Error, List Assignment: <list> must be a list (not a integer)
gap> l:=[];; ASS_LIST(l,1,1); l;
[ 1 ]

#
gap> ASSS_LIST([1],[1],1);
Error, List Assignment: <rhss> must be a dense list
gap> ASSS_LIST([1],1,[1]);
Error, List Assignment: <positions> must be a dense list of positive integers
gap> ASSS_LIST(1,[1],[1]);
Error, List Assignments: <list> must be a list (not a integer)
gap> l:=[];; ASSS_LIST(l,[1],[1]); l;
[ 1 ]

#
gap> ASSS_LIST_DEFAULT([1],[1],1);
Error, List Assignment: <rhss> must be a dense list
gap> ASSS_LIST_DEFAULT([1],1,[1]);
Error, List Assignment: <positions> must be a dense list of positive integers
gap> ASSS_LIST_DEFAULT(1,[1],[1]);
Error, List Assignment: <list> must be a list (not a integer)
gap> l:=[];; ASSS_LIST_DEFAULT(l,[1],[1]); l;
[ 1 ]

#
gap> STOP_TEST("kernel/lists.tst", 1);
