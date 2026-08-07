# The `window-cmd-*.g` tests

These tests cover the kernel's reading of a window handler's answer in package
mode: `SyWinBeginAnswer` and the entry readers in `src/sysfiles.c`, and
`FuncWindowCmd` in `src/gap.c`.

`tst/testinstall/kernel/gap.tst` covers `WindowCmd`'s argument checks and the
`No Window Handler Present` path.  These tests cover parsing an answer
from a (faked) window handler.

## How they work

`WindowCmd` writes `@w<len>+<cmd>` to stdout, then waits for the
handler's answer back from **stdin**.  A test can therefore put the answer
bytes on the line after the call:

    got := WindowCmd(["TST"]);;
    @a8+I0+S2+ok
    Print(got, "\n");

GAP reads stdin only to the newline, so the answer is still in the stream
when the kernel asks for it.  No handler and no second process are
involved, so there is no timing in these tests at all.  The kernel does not
interpret the three character command name, so `"TST"` is used as a
placeholder.

The tests need `gap -p`, and package mode cannot be entered from within GAP
(`SyWindow` is set at startup only), so `run_gap.sh` takes options from a
first line of the form

    #GAPOPTS -p

As an ordinary GAP comment, this says right in the test the GAP flags
that are needed.

## Reading an answer

An answer is `@a<len>+<payload>`, where `<len>` counts the payload bytes as
written.  The payload is a run of entries:

    I<digits><sign>        an integer, <sign> being + or -
    S<digits>+<bytes>      a string, <digits> its un-escaped length

**Every digit run in this protocol is least significant digit first**, so
`52` is 25 and `0009` is 9000; this is the thing most often misread as a bug.
A string's `<digits>` count its length after un-escaping, so they may be
fewer than the bytes written.  Within a payload `@` is written `@@`, and a
control character as `@A` .. `@Z`.

The first entry is a status code, which `FuncWindowCmd` removes before
returning the rest; hence the leading `I0+` in every answer here.  A status
of `1` means failure, and turns the remaining entries into the arguments of
`Error`.  Note that `I+` and `S+`, with no digits at all, are exactly what
`FuncWindowCmd` itself emits for `0` and `""`.

The newline ending an answer stays in the input, where GAP reads it as an
empty line: the blank `gap>` that follows each answer in the expected output.

## The tests

`window-cmd-long-string.g` -- strings longer than the kernel's refill buffer,
so an answer is read in several pieces: dense escapes over several refills,
two strings in one answer, and a `@@` pair aimed at a refill boundary so that
half an escape is carried across.

`window-cmd-entries.g` -- the shapes an entry can take: `I+`, signed
integers, `S+` and `S0+`, the whole `@A` .. `@Z` escape table, mixed kinds, a
malformed `@<chr>`, an entry after a refill, an unknown entry kind and the
drain that keeps the stream in sync after it, a status of `1`, and a header
that is not `@a<digits>+` at all.  It turns `BreakOnError` off, so that the
cases which raise an error print their message and carry on instead of
opening a break loop.  That keeps the expected output to the messages this
code is responsible for, rather than also pinning GAP's break loop banner and
stack trace, whose wording has changed between releases.

`window-cmd-truncated.g` -- answers that come up short: an entry claiming
more bytes than the payload holds, which is clamped; and a payload the input
never delivers, where the kernel meets EOF part way through and zero fills
the rest.

Not covered: the outgoing direction, since `run_gap.sh` captures GAP's log
rather than its stdout, so the `@w` framing and the escaping of the command
are invisible here; `EAGAIN` and the `@y`/`@s` sync handshake, which need a
pseudo terminal, input side `@` decoding living only in `syGetchTerm`; and
answers that are not merely short but invalid, such as one carrying no status
entry at all, which is a broken handler rather than something the kernel is
expected to survive gracefully.

## Regenerating

    dev/make-window-cmd-tests.sh
    tst/testspecial/regenerate_tests.sh

The generator runs from any directory.  It lives in `dev/` because it is
needed only to change the tests, not to run them, and `dev/` is not shipped
in a release.  The answers are generated rather than edited because each has
three interlocking counts -- the payload length, each string's un-escaped
length, and the escaping -- and a wrong one is not necessarily a visible
failure, as the kernel clamps a string to the bytes that remain.  It takes
the refill buffer size from `SYS_WIN_BUF_SIZE` in `src/sysfiles.c` rather
than keeping a copy, and checks in the bytes it has just produced that the
boundary case really does straddle a refill.  **Regenerate if
`SYS_WIN_BUF_SIZE` changes**, or that case will go on passing while no longer
testing a boundary.

Two things not to tidy up.  `window-cmd-truncated.g.out` ends without a
trailing newline, because GAP is killed by EOF mid-prompt.  And that same
test covers a bug whose old behaviour was an infinite loop, so a regression
in it hangs rather than fails; where the system has a `timeout` command
`run_gap.sh` uses it, reports the test as killed, and lets the output
comparison fail it so the other tests still run.

## A note for maintainers

This file should eventually be folded into `README.md`, along with
descriptions of the other tests here, many of which appear to be
undocumented as of this writing.
