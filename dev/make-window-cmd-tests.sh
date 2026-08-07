#!/usr/bin/env bash

set -e

# Regenerate the window-cmd-*.g tests in tst/testspecial.  Run this, then
# tst/testspecial/regenerate_tests.sh to update the expected output.
#
# It lives in dev/ because it is a maintenance tool, needed only to change the
# tests and not to run them, and dev/ is not shipped in a release; the tests it
# writes are committed.
#
# A test here is fed to GAP on stdin.  When 'WindowCmd' is evaluated the
# kernel writes '@w<len>+<cmd>' to stdout and then reads the window handler's
# answer back from stdin, so the answer bytes simply follow the newline of the
# line that called 'WindowCmd'.  With stdin redirected GAP reads input one byte
# at a time and never reads ahead past a newline -- 'syBuf[0].bufno' is -1, so
# 'syGetchNonTerm' asks for a single character at a time -- and the answer is
# therefore still in the stream when the kernel asks for it.  No window handler
# is involved, and the kernel never interprets the three character command
# name, so "TST" needs no support anywhere.
#
# The answers are written out by hand, which is fiddly enough (lengths, digit
# order, escape counts) to be worth generating rather than editing in place.

# SRCDIR is the top of the source tree, found from where this script lives.
SRCDIR=$(cd "$(dirname "$0")/.." && pwd)

# GAPDIR points to the directory containing the gap executable
# (so for out-of-tree builds, builddir and not srcdir).  Resolve it while we
# are still in the directory the user invoked us from, as we change directory
# below and a relative GAPDIR would then mean something else entirely.
GAPDIR=$(cd "${GAPDIR:-$SRCDIR}" && pwd)

# The refill buffer size the tests are built around is the kernel's, so take
# it from the kernel rather than keeping a second copy in step by hand.
WCBUFSIZE=$(sed -n 's/^#define SYS_WIN_BUF_SIZE  *\([0-9][0-9]*\).*/\1/p' \
                "$SRCDIR/src/sysfiles.c")
if [ -z "${WCBUFSIZE}" ]; then
    echo "$0: cannot find SYS_WIN_BUF_SIZE in $SRCDIR/src/sysfiles.c" >&2
    exit 1
fi
export WCBUFSIZE

# The tests are written to the working directory, so run GAP from where they
# belong; this also keeps the GAP program below free of any path handling.
cd "$SRCDIR/tst/testspecial"

"$GAPDIR/gap" -A -b -q -r <<'GAPEOF'

# every count in this protocol is written least significant digit first
WCRev := n -> Reversed(String(n));;

# '@' doubles, a control character becomes '@' and the corresponding letter
WCEsc := function(str)
  local  out, c, i;
  out := "";
  for c in str do
    i := INT_CHAR(c);
    if c = '@' then
      Append(out, "@@");
    elif 1 <= i and i <= 26 then
      Add(out, '@');
      Add(out, CHAR_INT(i - 1 + INT_CHAR('A')));
    else
      Add(out, c);
    fi;
  od;
  return out;
end;;

WCInt := function(n)
  local  sign;
  if n < 0 then sign := "-"; else sign := "+"; fi;
  return Concatenation("I", WCRev(AbsInt(n)), sign);
end;;

# the digits give the un-escaped length, so they need not match the bytes
WCStr := s -> Concatenation("S", WCRev(Length(s)), "+", WCEsc(s));;

# an answer is '@a<escaped payload length>+<payload>'
WCAnswer := function(entries)
  local  payload;
  payload := Concatenation(entries);
  return Concatenation("@a", WCRev(Length(payload)), "+", payload);
end;;

# payload offset at which the data of a string entry of length <len> starts,
# given the entries in front of it; used to aim an escape at a refill boundary
WCDataOffset := {before, len} ->
  Length(Concatenation(before)) + 1 + Length(WCRev(len)) + 1;;

WCRep := {block, n} -> Concatenation(ListWithIdenticalEntries(n, block));;

# The kernel serves the payload through a refill buffer of this size, read
# out of src/sysfiles.c by the wrapper so that the two cannot drift apart.
WCBufSize := Int(GAPInfo.SystemEnvironment.WCBUFSIZE);;

# Check that <answer> really does put an escape pair across the first refill
# boundary: the '@' as the last byte the kernel can serve from its first
# bufferful, its partner as the first byte of the next.  Recomputing this from
# the finished bytes is the point -- deriving it from the same arithmetic that
# placed it would assert nothing.
WCCheckStraddle := function(answer)
  local  payload, at, run;

  payload := answer{[Position(answer, '+') + 1 .. Length(answer)]};
  if Length(payload) <= WCBufSize then
    Error("payload of ", Length(payload), " bytes never reaches the ",
          WCBufSize, " byte refill boundary");
  fi;
  # 0 based payload offset WCBufSize-1 is 1 based position WCBufSize
  at := WCBufSize;
  if payload[at] <> '@' or payload[at + 1] <> '@' then
    Error("no '@@' pair at the refill boundary: found ",
          payload{[at .. at + 1]});
  fi;
  # and it must open a pair, not close one, so the run before it must be even
  run := 0;
  while at - run - 1 >= 1 and payload[at - run - 1] = '@' do
    run := run + 1;
  od;
  if run mod 2 <> 0 then
    Error("the '@' at the refill boundary closes an earlier pair");
  fi;
end;;

# The header every generated test opens with, given its one line description.
# The '#GAPOPTS' line has to come first: run_gap.sh reads the options for the
# run out of it, and these tests are useless without '-p'.
#
# The answers are raw protocol and need the format to hand, but spelling it
# out in each test is expensive -- a comment in a test is echoed into its
# expected output as well, so every such line costs twice on disk.  Hence a
# pointer to the README instead.
WCHeader := description -> Concatenation(
  "#GAPOPTS -p\n",
  description,
  "#  Generated by dev/make-window-cmd-tests.sh -- do not edit.\n",
  "#  README-window-cmd.md explains the '@a' answers below, in particular\n",
  "#  that every digit run is least significant digit first.\n");;

MakeCases := function()
  local  cases, status, dense, first, second, len, pad, aimed, answer;

  status := WCInt(0);          # leading status entry, dropped by WindowCmd
  cases  := [];

  # 1. An escape every few bytes, over several refills, so that escaped and
  # plain bytes keep arriving in different pieces of the answer.  The escaped
  # block is 11 bytes, which does not divide the refill size, so the
  # boundaries fall at different offsets within the block; splitting a '@X'
  # pair itself is left to case 3, which aims one there exactly.
  #
  # "Long" here means long against the kernel's refill buffer, which is the
  # only length in this protocol that means anything: answers have no size
  # limit, and the 8000 byte buffer that used to cap them is long gone.
  dense := WCRep("@ab\ncdefg", 100);
  Add(cases, rec(
    name     := "dense escapes",
    expected := "WCRep(\"@ab\\ncdefg\", 100)",
    answer   := WCAnswer([status, WCStr(dense)])));

  # 2. Two strings in one answer, the first spanning a refill, so that entry
  # parsing resumes correctly in the middle of a buffer after a payload that
  # required a refill of its own.
  first  := WCRep("@wx\nyz", 100);
  second := WCRep("mnopqr", 40);
  Add(cases, rec(
    name     := "two long strings",
    expected := "[ WCRep(\"@wx\\nyz\", 100), WCRep(\"mnopqr\", 40) ]",
    answer   := WCAnswer([status, WCStr(first), WCStr(second)])));

  # 3. A '@@' pair aimed at the first refill boundary, the '@' at payload
  # offset WCBufSize-1 and its double at WCBufSize, so that the kernel has to
  # carry a half read escape across a refill.  Offsets are 0 based and count
  # payload bytes only, as the '@a<len>+' header is read separately and does
  # not go through the buffer.
  #
  # This aim holds as long as the first refill returns a whole buffer, which
  # it does here because the entire file is already in the pipe.  A short read
  # would not break the test, but would quietly reduce it to another escape
  # case.
  #
  # There is nothing here for the reader this replaced to fail: it had no
  # refill buffer at all, and read a whole answer in one go.  Escapes as such
  # are covered against it by the escape table in window-cmd-entries.g; this
  # case exists for the streaming reader that took its place.
  len   := 2 * WCBufSize;
  pad   := WCBufSize - 1 - WCDataOffset([status], len);
  aimed := Concatenation(WCRep("x", pad), "@", WCRep("y", len - pad - 1));
  answer := WCAnswer([status, WCStr(aimed)]);
  WCCheckStraddle(answer);
  Add(cases, rec(
    name     := "escape across refill",
    expected := Concatenation("Concatenation(WCRep(\"x\", ", String(pad),
                              "), \"@\", WCRep(\"y\", ",
                              String(len - pad - 1), "))"),
    answer   := answer));

  return cases;
end;;

# 'WriteAll' writes the string as it stands.  'PrintTo' would fold the long
# answer lines to the screen width, which would corrupt them.
WriteLongStringTest := function(name)
  local  out, cases, c;

  cases := MakeCases();
  out   := OutputTextFile(name, false);

  WriteAll(out, Concatenation(
    WCHeader(Concatenation(
      "#  Strings longer than the kernel's answer refill buffer, in package\n",
      "#  mode, so that the answer has to be read in several pieces.\n")),
    "WCRep := {block, n} -> Concatenation(ListWithIdenticalEntries(n, block));;\n",
    "Check := function(name, got, want)\n",
    "  local i, s, e;\n",
    "  Print(name, \": \");\n",
    "  if Length(got) <> Length(want) then\n",
    "    Print(\"FAIL - expected \", Length(want), \" results, got \",",
    " Length(got), \"\\n\");\n",
    "    return;\n",
    "  fi;\n",
    "  for i in [1..Length(want)] do\n",
    "    s := got[i]; e := want[i];\n",
    "    if s <> e then\n",
    "      Print(\"FAIL - entry \", i, \" has length \", Length(s),\n",
    "            \", expected \", Length(e), \", first difference at \",\n",
    "            First([1..Minimum(Length(s), Length(e))],",
    " j -> s[j] <> e[j]), \"\\n\");\n",
    "      return;\n",
    "    fi;\n",
    "  od;\n",
    "  Print(\"ok, lengths \", List(got, Length), \"\\n\");\n",
    "end;;\n"));

  for c in cases do
    WriteAll(out, Concatenation("want := ", c.expected, ";;\n"));
    # 'Check' compares lists, so a case expecting a single string has to have
    # it wrapped; a case whose expectation is already a list starts with '['
    if c.expected[1] <> '[' then
      WriteAll(out, "want := [ want ];;\n");
    fi;
    WriteAll(out, "got := WindowCmd([\"TST\"]);;\n");
    WriteAll(out, c.answer);
    WriteAll(out, "\n");
    WriteAll(out, Concatenation("Check(\"", c.name, "\", got, want);\n"));
  od;

  CloseStream(out);
end;;

##  The entry test: the small shapes an answer entry can take, which
##  'FuncWindowCmd' has to turn into GAP objects.  The cases up to the first
##  error all stay inside their declared payload, so the input stream is still
##  in sync afterwards and they can simply follow one another.  Results are
##  printed as they stand, which is both the check and the documentation.

WriteEntryTest := function(name)
  local  out, cases, ctrl, i, c, payload;

  ctrl := "";
  for i in [1..26] do
    Add(ctrl, CHAR_INT(i));
  od;

  cases := [
    # 'I+' with no digits at all is the documented way of writing zero
    rec(name    := "implicit zero",
        payload := Concatenation(WCInt(0), "I+"),
        show    := "got"),

    # signs, and an integer following another integer
    rec(name    := "signed integers",
        payload := Concatenation(WCInt(0), WCInt(-13), WCInt(7), WCInt(0)),
        show    := "got"),

    # 'S+' and 'S0+' are both an empty string
    rec(name    := "empty strings",
        payload := Concatenation(WCInt(0), "S+", "S0+"),
        show    := "got"),

    # every control character, i.e. the whole '@A' .. '@Z' escape table
    rec(name    := "escape table",
        payload := Concatenation(WCInt(0), WCStr(ctrl)),
        show    := "List(got[1], INT_CHAR)"),

    # a literal '@' round trips as '@@', mixed in with other entry kinds
    rec(name    := "mixed entries",
        payload := Concatenation(WCInt(0), WCStr("a@b"), WCInt(-1),
                                 WCStr(""), WCStr("x\ny")),
        show    := "got"),

    # '@' followed by neither '@' nor a capital is malformed; the kernel
    # drops both bytes and carries on, so this decodes to just "abcd"
    rec(name    := "malformed escape",
        payload := Concatenation(WCInt(0), "S", WCRev(4), "+", "ab@1cd"),
        show    := "got"),

    # an entry after a string long enough to force a refill, to check that
    # entry parsing resumes correctly part way through the buffer
    rec(name    := "entry after refill",
        payload := Concatenation(WCInt(0), WCStr(WCRep("pq", 300)),
                                 WCInt(42)),
        show    := "[ Length(got[1]), got[2] ]")];

  out := OutputTextFile(name, false);

  WriteAll(out, WCHeader("#  The shapes an answer entry can take, in package mode.\n"));

  for c in cases do
    WriteAll(out, "got := WindowCmd([\"TST\"]);;\n");
    WriteAll(out, Concatenation("@a", WCRev(Length(c.payload)), "+",
                                c.payload));
    WriteAll(out, "\n");
    WriteAll(out, Concatenation("Print(\"", c.name, " = \", ", c.show,
                                ", \"\\n\");\n"));
  od;

  # An entry kind that is neither 'I' nor 'S' is an error.  The kernel drains
  # the rest of the answer before reporting it, so the junk after the 'X' is
  # swallowed and the next case still reads its answer correctly -- which is
  # the only coverage the drain path gets.
  #
  # The junk deliberately runs past one bufferful, so that draining it has to
  # read from the input rather than just step over bytes already in hand.  It
  # costs nothing in the expected output, as the kernel consumes these bytes
  # and GAP never sees them.
  payload := Concatenation(WCInt(0), "X", WCRep("junk", WCBufSize / 2));
  WriteAll(out, "got := WindowCmd([\"TST\"]);;\n");
  WriteAll(out, Concatenation("@a", WCRev(Length(payload)), "+", payload));
  WriteAll(out, "\n");
  WriteAll(out, "got := WindowCmd([\"TST\"]);;\n");
  payload := Concatenation(WCInt(0), WCStr("ok"));
  WriteAll(out, Concatenation("@a", WCRev(Length(payload)), "+", payload));
  WriteAll(out, "\n");
  WriteAll(out, "Print(\"in sync after drain = \", got, \"\\n\");\n");

  # A status entry of 1 is how a window handler reports a failure back to GAP,
  # and is the form every real front end uses; the entries after it become the
  # arguments of 'Error'.  This raises an error, so 'quit;' is needed to leave
  # the break loop, as elsewhere in this directory.
  WriteAll(out, "got := WindowCmd([\"TST\"]);;\n");
  payload := Concatenation(WCInt(1), WCStr("bad news"));
  WriteAll(out, Concatenation("@a", WCRev(Length(payload)), "+", payload));
  WriteAll(out, "\n");
  WriteAll(out, "quit;\n");

  # A header that is not '@a<digits>+' at all.  Writing it as a bare '@a'
  # means the newline ending the line is what fails the check, so nothing is
  # left over to be mistaken for input.  This raises an error too, and is put
  # last so that the break loop it opens is simply ended by the harness.
  WriteAll(out, "got := WindowCmd([\"TST\"]);;\n");
  WriteAll(out, "@a\n");

  CloseStream(out);
end;;

##  The truncated answer test: two ways an answer can come up short.  The
##  first stays inside its declared payload and is merely an entry claiming
##  more than the payload holds, which is clamped.  The second is a payload
##  the input never delivers, where the kernel meets EOF part way through --
##  that is the one that used to spin forever, subtracting a read() of 0 from
##  the count of bytes outstanding and so never reducing it.
##
##  The second case runs the stream out entirely, so it has to come last and
##  its checks have to sit on the same input line as the 'WindowCmd' call.
##  GAP reads a whole line before evaluating any of it, so the 'Print' calls
##  are already in hand by the time the answer swallows the rest of the file.

WriteTruncatedTest := function(name)
  local  out, data, payload, tail;

  out := OutputTextFile(name, false);

  WriteAll(out, WCHeader("#  Answers that come up short, in package mode.\n"));

  # 1. The answer is well formed and complete, but the string entry claims
  # 9000 bytes where the payload has only 20 left, so the length is clamped to
  # what is really there.  Nothing is read past the payload and the input
  # stream is still in sync afterwards.
  data    := "0123456789abcdefghij";
  payload := Concatenation(WCInt(0), "S", WCRev(9000), "+", data);
  WriteAll(out, "got := WindowCmd([\"TST\"]);;\n");
  WriteAll(out, Concatenation("@a", WCRev(Length(payload)), "+", payload));
  WriteAll(out, "\n");
  WriteAll(out, Concatenation(
    "Print(\"clamped length = \", Length(got[1]), \"\\n\");\n",
    "Print(\"clamped content = \", got[1] = \"", data, "\", \"\\n\");\n"));

  # 2. The header promises 5000 payload bytes and the input runs out long
  # before that, so the kernel meets EOF in the middle of a string entry and
  # has to zero fill the rest instead of spinning on a read() of 0.
  #
  # The length follows from the header alone: 9 payload bytes go on 'I0+' and
  # the 'S' length prefix, so the string is clamped to the remaining 4991.
  # The leading bytes are the ten written here plus the newline that ends the
  # file.  What comes immediately after that is whatever run_gap.sh appends to
  # the test before GAP reaches EOF, so this says nothing about it -- but well
  # past that everything must be the zero fill, and checking so is what keeps
  # uninitialised memory from reaching a GAP string unnoticed.
  tail := Concatenation(WCInt(0), "S", WCRev(9000), "+", "abcdefghij");
  WriteAll(out, Concatenation(
    "got := WindowCmd([\"TST\"]);;",
    " Print(\"eof entries = \", Length(got), \"\\n\");",
    " Print(\"eof length = \", Length(got[1]), \"\\n\");",
    " Print(\"eof prefix = \", got[1]{[1..11]} = \"abcdefghij\\n\", \"\\n\");",
    " Print(\"eof zero filled = \",",
    " ForAll(got[1]{[100..Length(got[1])]}, c -> c = CHAR_INT(0)),",
    " \"\\n\");\n"));
  WriteAll(out, Concatenation("@a", WCRev(5000), "+", tail));
  WriteAll(out, "\n");

  CloseStream(out);
end;;

WriteLongStringTest("window-cmd-long-string.g");
WriteEntryTest("window-cmd-entries.g");
WriteTruncatedTest("window-cmd-truncated.g");
QUIT;
GAPEOF

echo "wrote window-cmd-long-string.g window-cmd-entries.g window-cmd-truncated.g"
