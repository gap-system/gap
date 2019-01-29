#
# Tests for functions defined in src/objfgelm.c
#
gap> START_TEST("kernel/objfgelm.tst");

#
gap> MULT_WOR_LETTREP(false, false);
Error, MULT_WOR_LETTREP: <a> must be a plain list (not the value 'false')
gap> MULT_WOR_LETTREP([], false);
Error, MULT_WOR_LETTREP: <b> must be a plain list (not the value 'false')
gap> MULT_WOR_LETTREP([], []);
[  ]
gap> MULT_BYT_LETTREP(true, false);
Error, MULT_BYT_LETTREP: <a> must be a string (not the value 'true')
gap> MULT_BYT_LETTREP([], false);
Error, MULT_BYT_LETTREP: <b> must be a string (not the value 'false')
gap> MULT_BYT_LETTREP([], []);
""

#
gap> STOP_TEST("kernel/objfgelm.tst", 1);
