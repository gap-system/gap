#!/bin/sh -ex
#
# Regenerate configure from configure.ac. Requires GNU autoconf.

# Workaround problem caused by running this script with an outdated
# version of libtool (i.e. before 2.4.2), which then causes subsequent
# runs with a current version to fail.
rm -rf aclocal.m4 autom4te.cache cnf/ltmain.sh cnf/m4/l*.m4

# We use --no-recursive to prevent autoreconf from running itself in
# extern/gmp.  And we use '-I cnf/m4' as it helps with some older
# autoconf versions.
autoreconf -vif --no-recursive -I cnf/m4 `dirname "$0"`
