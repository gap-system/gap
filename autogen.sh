#!/bin/sh
#
# Regenerate configure from configure.ac. Requires GNU autoconf.
# We do not use autoreconf because it is only part of GNU automake,
# and also because it had various other issues in the past.
set -ex
autoconf -Wall -f
autoheader -Wall -f
