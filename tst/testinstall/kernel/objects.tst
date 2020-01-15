#
# Tests for functions defined in src/objects.c
#
gap> START_TEST("kernel/objects.tst");

# SET_TYPE_COMOBJ
gap> SET_TYPE_COMOBJ(fail, fail);
Error, You can't make a component object from a boolean or fail
gap> SET_TYPE_COMOBJ([], fail);
Error, You can't make a component object from a empty plain list
gap> SET_TYPE_COMOBJ(MakeImmutable(rec()), fail);
Error, You can't make a component object from a record (plain,imm)

# SET_TYPE_POSOBJ
gap> SET_TYPE_POSOBJ(fail, fail);
Error, You can't make a positional object from a boolean or fail
gap> SET_TYPE_POSOBJ(rec(), fail);
Error, You can't make a positional object from a record (plain)

# TODO: the following should also fail, but for now we allow it
gap> #SET_TYPE_POSOBJ(MakeImmutable([]), fail);

#
gap> STOP_TEST("kernel/objects.tst", 1);
