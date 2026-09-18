#
#@local c, dir, gzname, l, name, out, s, state, str, t
gap> START_TEST("sha256.tst");

#
# test input validation for the kernel functions
#
gap> state := GAP_SHA256_INIT();
<SHA256 state>

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

# Inputs whose SHA256 starts with one or more zero hex digits: the result
# must still be 64 hex characters (the digest is always 256 bits).
gap> HexSHA256("39");
"0b918943df0962bc7a1824c0555a389347b4febdc7cf9d1254406d80ce44e3f9"
gap> HexSHA256("286");
"00328ce57bbc14b33bd6695bc8eb32cdf2fb5f3a7d89ec14a42825e15d39df60"
gap> HexSHA256("886");
"000f21ac06aceb9cdd0575e82d0d85fc39bed0a7a1d71970ba1641666a44f530"
gap> ForAll(["", "abcd", "39", "286", "886"], s -> Length(HexSHA256(s)) = 64);
true

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

# HexSHA256File
gap> dir := DirectoryTemporary();;
gap> name := Filename(dir, "test.txt");;
gap> FileString(name, "abcd");;
gap> HexSHA256File(name, false);
"88d4266fd4e6338d13b845fcf289579d209c897823b9217da3e161936f031589"
gap> FileString(Filename(dir, "empty.txt"), "");;
gap> HexSHA256File(Filename(dir, "empty.txt"), false);
"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

# larger than the read buffer, so that more than one chunk gets hashed
gap> str := Concatenation(List([1 .. 5000], i -> "0123456789"));;
gap> FileString(Filename(dir, "big.txt"), str);;
gap> HexSHA256File(Filename(dir, "big.txt"), false) = HexSHA256(str);
true

# a file that is not there
gap> HexSHA256File(Filename(dir, "no-such-file"), false);
fail

# the two answers a '.gz' file has
gap> gzname := Filename(dir, "compressed.txt.gz");;
gap> out := OutputGzipFile(gzname, false);;
gap> WriteAll(out, "abcd");;
gap> CloseStream(out);
gap> HexSHA256File(gzname, false) = HexSHA256("abcd");
false
gap> HexSHA256File(gzname, true) = HexSHA256("abcd");
true

# argument checking
gap> HexSHA256File(name);
Error, Function: number of arguments must be 2 (not 1)
gap> HexSHA256File(42, false);
Error, <filename> must be a string
gap> HexSHA256File(name, "yes");
Error, <decompress> must be 'true' or 'false'

#
# SHA256State: accumulating input that is not in one place
#
gap> s := SHA256State();
<SHA256 state>
gap> IsSHA256State(s);
true
gap> IsSHA256State(fail);
false

# How the input is divided up between calls makes no difference.
gap> UpdateSHA256(s, "ab");
gap> UpdateSHA256(s, "cd");
gap> HexSHA256(s) = HexSHA256("abcd");
true
gap> t := SHA256State();;
gap> for c in "abcd" do UpdateSHA256(t, [c]); od;
gap> HexSHA256(t) = HexSHA256("abcd");
true
gap> HexSHA256(SHA256State()) = HexSHA256("");
true

# Reading the digest does not consume the state.  Finalizing a SHA256 state
# pads it in place and so destroys it; GAP_SHA256_DIGEST does that to a copy,
# which is what makes reading a digest an ordinary operation.
gap> HexSHA256(s) = HexSHA256(s);
true
gap> UpdateSHA256(s, "e");
gap> HexSHA256(s) = HexSHA256("abcde");
true

# The argument is left alone: the kernel converts a list of characters to a
# string in place, which must not happen to the caller's list.
gap> l := List("ab", c -> c);;
gap> UpdateSHA256(SHA256State(), l);
gap> IsStringRep(l);
false

#
# UpdateSHA256File
#
gap> dir := DirectoryTemporary();;
gap> name := Filename(dir, "half.txt");;
gap> FileString(name, "cd");;
gap> s := SHA256State();;
gap> UpdateSHA256(s, "ab");
gap> UpdateSHA256File(s, name, false);
true
gap> HexSHA256(s) = HexSHA256("abcd");
true

# A file that cannot be read leaves the state as it was.
gap> UpdateSHA256File(s, Filename(dir, "no-such-file"), false);
fail
gap> HexSHA256(s) = HexSHA256("abcd");
true

# ... and the two answers a '.gz' file has, as for HexSHA256File.
gap> gzname := Filename(dir, "c.txt.gz");;
gap> out := OutputGzipFile(gzname, false);;
gap> WriteAll(out, "abcd");;
gap> CloseStream(out);
gap> s := SHA256State();; UpdateSHA256File(s, gzname, true);;
gap> HexSHA256(s) = HexSHA256("abcd");
true
gap> s := SHA256State();; UpdateSHA256File(s, gzname, false);;
gap> HexSHA256(s) = HexSHA256File(gzname, false);
true

# What this is for: a git object is a header followed by a body, and neither
# has to be brought together in memory to be hashed.
gap> FileString(name, "hello artifact\n");;
gap> s := SHA256State();;
gap> UpdateSHA256(s, "blob 15\000");
gap> UpdateSHA256File(s, name, false);
true
gap> HexSHA256(s);
"68a5de2c96dafbd696ef65b07482b6acdc0de5b763d5e49006638cab5ae0542f"

# ... which is what 'git hash-object' reports for the same file in a
# repository created with 'git init --object-format=sha256'.

# argument checking
gap> UpdateSHA256(fail, "a");
Error, <state> must be a SHA256 state
gap> UpdateSHA256(SHA256State(), 42);
Error, <string> must be a string
gap> UpdateSHA256File(SHA256State(), name, "yes");
Error, <decompress> must be 'true' or 'false'
gap> HexSHA256(42);
Error, <str> has to be a string, an input stream, or a SHA256 state

#
gap> STOP_TEST("sha256.tst");
