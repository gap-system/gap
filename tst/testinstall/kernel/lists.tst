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
gap> STOP_TEST("kernel/lists.tst", 1);
