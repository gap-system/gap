#!/bin/sh -ex
#
# {{PackageName}}: {{Subtitle}}
#
# This file is part of the build system of a GAP kernel extension.
# Requires GNU autoconf, GNU automake and GNU libtool.
#
autoreconf -vif `dirname "$0"`
