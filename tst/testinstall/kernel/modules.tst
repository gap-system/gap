#
# Tests for functions defined in src/modules.c
#
gap> START_TEST("kernel/modules.tst");

#
gap> IS_LOADABLE_DYN(fail);
Error, IS_LOADABLE_DYN: <filename> must be a string (not the value 'fail')

#
gap> LOAD_DYN(fail);
Error, LOAD_DYN: <filename> must be a string (not the value 'fail')

#
gap> LOAD_STAT(fail);
Error, LOAD_STAT: <filename> must be a string (not the value 'fail')
gap> LOAD_STAT("foobar");
false

#
gap> LoadedModules();;

#
gap> STOP_TEST("kernel/modules.tst", 1);
