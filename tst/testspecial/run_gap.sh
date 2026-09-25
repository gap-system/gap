#!/usr/bin/env bash

set -e

# This script should be run as ./run_gap.sh gap gapfile.g [gapfile.g.out]
gap="$1"
gfile="$2"
outfile="${3:-$gfile.out}"

# It provides the following features:
# 1) Stop GAP from attaching to the terminal (which it will
#    use in the break loop)
# 2) Combine stderr and stdout
# 3) Rewrite the root of gap with the string GAPROOT,
#    so the output is usable on other machines
# 4) Set lower and upper memory limits, for consistency
# 5) Pass any extra GAP command line options the test asks for.  A test whose
#    first line reads '#GAPOPTS <options>' is run with those added; it is a
#    GAP comment, so it stays part of the test and says on the face of it
#    what the test needs.  The window-cmd-*.g tests use it to ask for -p,
#    which puts GAP into package mode.
gapopts=()
gapoptline=$(sed -n '1s/^#GAPOPTS[[:space:]]*//p' "$gfile")
if [ -n "${gapoptline}" ]; then
    read -ra gapopts <<< "${gapoptline}"
fi

# 6) Stop a wedged GAP from hanging the whole suite; window-cmd-truncated.g
#    covers a bug whose old behaviour was an infinite loop.  Skipped where
#    there is no timeout command, which is the usual case on macOS.
limit=300
guard=()
if command -v timeout >/dev/null 2>&1 ; then
    guard=(timeout "${limit}")
elif command -v gtimeout >/dev/null 2>&1 ; then
    guard=(gtimeout "${limit}")
fi

GAPROOT=$("$gap" --print-gaproot)
# Start from no log at all, so that output left by an earlier run can never be
# mistaken for output of this one
rm -f "${outfile}.tmp"
status=0
( echo "LogTo(\"${outfile}.tmp\");" ; cat "$gfile" ; echo "QUIT;" ) |
    "${guard[@]}" "$gap" -r -A -b -m 256m -o 512m -x 800 "${gapopts[@]}" \
           -c 'SetUserPreference("UseColorsInTerminal",false);' \
           -c 'SetUserPreference("WhereDepth", 5);' \
           2>/dev/null >/dev/null || status=$?
# A timeout is reported and then left to the comparison of the output, so that
# the remaining tests still run.  Any other failure aborts, as it always has.
case ${status} in
    0)       ;;
    124|137) echo "${gfile}: killed after ${limit}s" >&2 ;;
    *)       exit ${status} ;;
esac
# GAP killed before it opened the log leaves nothing to compare against
[ -f "${outfile}.tmp" ] || : > "${outfile}.tmp"
sed -E -e "s:${GAPROOT//:/\\:}:GAPROOT/:g" -e "s;(GAPROOT(/[^/]+)+):[0-9]+;\1:LINE;g" < "${outfile}.tmp" > "${outfile}"
rm "${outfile}.tmp"
