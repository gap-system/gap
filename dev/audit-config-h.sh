#!/bin/sh
#
# This script scans all kernel sources which do not #include config.h for uses
# of symbols potentially #defined in `config.h`, with a couple of exceptions
# described below. It then reports all matches. The exit code is non-zero
# (indicating an error) if there are any such matches.
#
# This is used in `dev/ci.sh` to verify that we don't use any of those symbols
# in any of our headers. It can also be used to check which C/C++ source files
# use any of these headers, and thus ought to
# #include config.h.
set -e

# ensure that no .h file #includes config.h
if git grep -n -w config.h :src/*.h > /dev/null ; then
  echo "Error, a kernel header file includes config.h"
  exit 1
fi

# First scan config.h to obtain a list of all symbols it might define. From
# this is subtracts a list of "known OK" symbols. The symbols and there reason
# for being on this list are:
# - `HAVE_FUNC_ATTRIBUTE_`*: these are only used for optimizations; also, our
#    headers try hard to define them on the fly (at least in GCC and clang)
# - `HAVE___BUILTIN_MUL_OVERFLOW`: same as above
# - `SIZEOF_VOID_P`: provided for backwards compatibility in a few packages,
#    and actually (re-)defined in `common.h`
# - `SPARC`: only appears in a comment
PATTERN=$(egrep '(#define|#undef)' build/config.h | sed -E -e 's;(#define|/\* #undef) ([^ ]+) .*$;\2;' | egrep -v 'HAVE_FUNC_ATTRIBUTE_|HAVE___BUILTIN_MUL_OVERFLOW|SIZEOF_VOID_P|SPARC' | tr '\n' '|')
PATTERN=${PATTERN%?} # remove trailing "|"

# only consider files that do not #include config.h
FILES=$(git grep --files-without-match -P '^#include "config\.h"$' src)

# Next use `git grep` to search all kernel header files for occurrences of any
# of the symbols in the pattern we just created. We negate the exit code: grep
# exits with exit code 0 if there were hits, and with exit code 1 if there
# were no hits. For our purposes, we want the reverse: no hits is "good".
if git grep -n -P ${PATTERN} $FILES ; then
  echo "Error, a kernel source file not including config.h uses symbols from config.h"
  exit 1
fi
