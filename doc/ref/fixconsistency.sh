#!/bin/bash
#
# This script uses the report produced by `make check-manuals`
# to fix inconsistencies in GAPDoc cross-references within
# the GAP Reference Manual.
#
# The output of `make check-manuals` produces the output of the form
#
# ./reesmat.xml:379 : Ref to IsReesZeroMatrixSemigroup uses Attr instead of Prop
# ./fixconsistency.sh IsReesZeroMatrixSemigroup Attr Prop ./reesmat.xml 379
#
# where the 2nd line is the instruction for calling this script from
# the `doc/ref` directory.
#
# To use it, do the following (provided you do not have older log files)
#
# rm dev/log/check_manuals_*
# make check-manuals
# grep fixconsistency dev/log/check_manuals_* > doc/ref/fix.sh
# cd doc/ref
# bash fix.sh
#
# Arguments:
# $1 name of the function, operation, attribute, etc.
# $2 old type used in the Ref element
# $3 new type to be used in the Ref element
# $4 filename
# $5 line number
echo '*** Processing ' $1 $2 $3 $4 $5
sedarg="$5s|$2=\\\"$1\\\"|$3=\\\"$1\\\"|g"
echo $sedarg
echo 'Using sed...'
# Note that the -i option for sed used below is not portable. This will
# work on macOS (and presumably on other BSD variants), but not with GNU
# sed, nor with other POSIX sed variants. As Max Horn suggests, it will
# be safer to use `perl -pie`.
sed -i '' $sedarg $4
