#
# Tests for functions defined in src/listfunc.c
#
gap> START_TEST("kernel/listfunc.tst");

#
gap> l:=Immutable([1,2,3]);
[ 1, 2, 3 ]
gap> Add(l, 0, 1);
Error, List Assignment: <list> must be a mutable list
gap> Remove([]);
Error, Remove: <list> must not be empty

# The following test does not work (instead produces a "method not found" error).
# The difference to 'Add' is that for 'Add', we install a custom handler func
# for both 2 and 3 arguments, which we don't do for 'Remove'; so the regular
# operation handler runs, which validates the arguments and produces the "method not
# found" error before in RemPlist for immutable lists is reached.
# gap> Remove(l, 1);
# Error, List Assignment: <list> must be a mutable list

#
gap> APPEND_LIST_INTR(fail, fail);
Error, Append: <list1> must be a mutable list (not the value 'fail')
gap> APPEND_LIST_INTR(rec(), fail);
Error, AppendList: <list1> must be a small list (not a record (plain))

#
gap> POSITION_SORTED_LIST(fail, fail);
Error, POSITION_SORTED_LIST: <list> must be a small list (not the value 'fail'\
)

#
gap> POSITION_SORTED_LIST_COMP(fail, fail, fail);
Error, POSITION_SORTED_LIST_COMP: <list> must be a small list (not the value '\
fail')
gap> POSITION_SORTED_LIST_COMP([], 1, fail);
Error, POSITION_SORTED_LIST_COMP: <func> must be a function (not the value 'fa\
il')
gap> POSITION_SORTED_LIST_COMP([1,2,3], 3, \<);
3
gap> POSITION_SORTED_LIST_COMP([1..3], 3, \<);
3
gap> POSITION_SORTED_LIST_COMP([1..3], fail, \<);
4
gap> POSITION_SORTED_LIST_COMP([1..3], 0, \<);
1

#
gap> SORT_LIST(fail);
Error, SORT_LIST: <list> must be a small list (not the value 'fail')

#
gap> STABLE_SORT_LIST(fail);
Error, STABLE_SORT_LIST: <list> must be a small list (not the value 'fail')

#
gap> SORT_LIST_COMP(fail, fail);
Error, SORT_LIST_COMP: <list> must be a small list (not the value 'fail')
gap> SORT_LIST_COMP([], fail);
Error, SORT_LIST_COMP: <func> must be a function (not the value 'fail')

#
gap> STABLE_SORT_LIST_COMP(fail, fail);
Error, STABLE_SORT_LIST_COMP: <list> must be a small list (not the value 'fail\
')
gap> STABLE_SORT_LIST_COMP([], fail);
Error, STABLE_SORT_LIST_COMP: <func> must be a function (not the value 'fail')

#
gap> SORT_PARA_LIST(fail, fail);
Error, SORT_PARA_LIST: <list> must be a small list (not the value 'fail')
gap> SORT_PARA_LIST([], fail);
Error, SORT_PARA_LIST: <shadow> must be a small list (not the value 'fail')
gap> SORT_PARA_LIST([], [1]);
Error, SORT_PARA_LIST: <list> must have the same length as <shadow> (lengths a\
re 0 and 1)

#
gap> STABLE_SORT_PARA_LIST(fail, fail);
Error, STABLE_SORT_PARA_LIST: <list> must be a small list (not the value 'fail\
')
gap> STABLE_SORT_PARA_LIST([], fail);
Error, STABLE_SORT_PARA_LIST: <shadow> must be a small list (not the value 'fa\
il')
gap> STABLE_SORT_PARA_LIST([], [1]);
Error, STABLE_SORT_PARA_LIST: <list> must have the same length as <shadow> (le\
ngths are 0 and 1)

#
gap> OnPairs(fail,fail);
Error, OnPairs: <pair> must be a list of length 2 (not a boolean or fail)

#
gap> OnTuples(fail,fail);
Error, OnTuples: <tuple> must be a small list (not the value 'fail')

#
gap> OnSets(fail,fail);
Error, OnSets: <set> must be a set (not the value 'fail')
gap> empty:=[];;
gap> IsIdenticalObj(empty, OnSets(empty, ()));
false
gap> empty:=Immutable([]);;
gap> IsIdenticalObj(empty, OnSets(empty, ()));
true

#
gap> STRONGLY_CONNECTED_COMPONENTS_DIGRAPH(fail);
Error, Length: <list> must be a list (not the value 'fail')
gap> STRONGLY_CONNECTED_COMPONENTS_DIGRAPH([]);
[  ]

#
gap> STOP_TEST("kernel/listfunc.tst", 1);
