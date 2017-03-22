#!/bin/sh
#
# Regenerate configure from configure.ac. Requires GNU autoconf.
set -ex
autoconf -Wall -f
autoheader -Wall -f
