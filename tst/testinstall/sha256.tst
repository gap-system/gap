#
gap> START_TEST("sha256.tst");

#
# test input validation for the kernel functions
#
gap> state := GAP_SHA256_INIT();
<object>

#
gap> GAP_SHA256_UPDATE(fail, fail);
Error, GAP_SHA256_UPDATE: <state> must be a SHA256 state (not the value 'fail'\
)
gap> GAP_SHA256_UPDATE(state, fail);
Error, GAP_SHA256_UPDATE: <bytes> must be a string (not the value 'fail')
gap> GAP_SHA256_HMAC(fail, fail);
Error, GAP_SHA256_HMAC: <key> must be a string (not the value 'fail')
gap> GAP_SHA256_HMAC("", fail);
Error, GAP_SHA256_HMAC: <text> must be a string (not the value 'fail')

#
gap> HexSHA256("abcd");
"88d4266fd4e6338d13b845fcf289579d209c897823b9217da3e161936f031589"
gap> HexSHA256(['a', 'b', 'c', 'd']);
"88d4266fd4e6338d13b845fcf289579d209c897823b9217da3e161936f031589"
gap> HexSHA256("abcd\n");
"fc4b5fd6816f75a7c81fc8eaa9499d6a299bd803397166e8c4cf9280b801d62c"
gap> HexSHA256("abcd\r");
"aea243b0f1748f70fe977b811723cd1e5bf37a9a3aafcb95957c4dbdea78b1d9"
gap> HexSHA256("abcd\r\n");
"9c9a433b67154b248b93bf805dd19241ed07c86ddf15c640f2dcdd927824bb23"
gap> HexSHA256("");
"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

#
gap> HexSHA256(InputTextString("abcd"));
"88d4266fd4e6338d13b845fcf289579d209c897823b9217da3e161936f031589"
gap> HexSHA256(InputTextString(['a', 'b', 'c', 'd']));
"88d4266fd4e6338d13b845fcf289579d209c897823b9217da3e161936f031589"
gap> HexSHA256(InputTextString("abcd\n"));
"fc4b5fd6816f75a7c81fc8eaa9499d6a299bd803397166e8c4cf9280b801d62c"
gap> HexSHA256(InputTextString("abcd\r"));
"aea243b0f1748f70fe977b811723cd1e5bf37a9a3aafcb95957c4dbdea78b1d9"
gap> HexSHA256(InputTextString("abcd\r\n"));
"9c9a433b67154b248b93bf805dd19241ed07c86ddf15c640f2dcdd927824bb23"
gap> HexSHA256(InputTextString(""));
"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

#
gap> STOP_TEST("sha256.tst");
