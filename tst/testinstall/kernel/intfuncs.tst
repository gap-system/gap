#
# Tests for functions defined in src/intfuncs.c
#
gap> START_TEST("kernel/intfuncs.tst");

#
gap> InitRandomMT(fail);
Error, InitRandomMT: <initstr> must be a string (not the value 'fail')

#
gap> HASHKEY_BAG(0, 0, 0, 0);
0
gap> HASHKEY_BAG(Z(2), 0, 0, 0);
Error, HASHKEY_BAG: <obj> must not be an FFE
gap> HASHKEY_BAG("x", fail, 0, 0);
Error, HASHKEY_BAG: <seed> must be a small integer (not the value 'fail')
gap> HASHKEY_BAG("x", 0, fail, 0);
Error, HASHKEY_BAG: <offset> must be a small integer (not the value 'fail')
gap> HASHKEY_BAG("x", 0, 1000, 0);
Error, HashKeyBag: <offset> must be non-negative and less than the bag size
gap> HASHKEY_BAG("x", 0, 0, fail);
Error, HASHKEY_BAG: <maxlen> must be a small integer (not the value 'fail')

#
gap> STOP_TEST("kernel/intfuncs.tst", 1);
