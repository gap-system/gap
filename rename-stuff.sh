#!/usr/bin/env bash

set -e

moveto_subdir() {
    dir=$1 ; shift

    echo "creating src/$dir"
    mkdir -p src/$dir
    touch src/$dir/README.md
    git add src/$dir/README.md

    for old_base in "$@"
    do
        new_base=$old_base
        # parse OLD:NEW if necessary
        if [[ $old_base == *:* ]]
        then
            new_base=${old_base#*:}
            old_base=${old_base%:*}
        fi

        old="src/$old_base.c"
        new="src/$dir/$new_base.c"
        if [[ -e $old ]]
        then
            echo "  rename $old to $new"
            git mv $old $new
            perl -pi -e "s;$old;$new;" Makefile.rules
        fi

        old="src/$old_base.cc"
        new="src/$dir/$new_base.cc"
        if [[ -e $old ]]
        then
            echo "  rename $old to $new"
            git mv $old $new
            perl -pi -e "s;$old;$new;" Makefile.rules
        fi

        old="src/$old_base.h"
        new="src/$dir/$new_base.h"
        if [[ -e $old ]]
        then
            echo "  rename $old to $new"
            git mv $old $new
            perl -pi -e "s;\"$old_base.h\";\"$dir/$new_base.h\";" src/*.* src/*/*.*
        fi
    done
    git commit -m "Add src/$dir/" src Makefile.rules
}

moveto_subdir tnums \
    blister:blist \
    bool \
    cyclotom \
    ffdata \
    finfield \
    integer \
    intobj \
    macfloat \
    objset \
    permutat \
    plist \
    pperm \
    precord \
    range \
    rational \
    stringobj:string \
    trans \
    weakptr

moveto_subdir interpreter \
    code \
    exprs:expressions \
    funcs \
    hookintrprtr \
    intrprtr:interpreter \
    read \
    scanner \
    stats:statements \
    vars

moveto_subdir core \
    ariths \
    calls \
    gvars \
    lists \
    objects \
    opers \
    records \
    saveload \
    set

moveto_subdir general \
    intfuncs \
    iostream \
    streams

moveto_subdir math \
    costab:coset_table \
    dt \
    dteval \
    listoper \
    objccoll:collector \
    objcftl:collector_ftl \
    objfgelm:freegroup_elms \
    objpcgel:pcgroup-elms \
    sctable \
    tietze \
    vec8bit \
    vecffe \
    vecgf2 \
    vector

moveto_subdir util \
    backtrace \
    debug \
    fibhash \
    gaputils

moveto_subdir applications \
    listfunc \
    sortbase

# force sorting all #include statements
perl -pi -e "s;#include;#include ;" src/*.* src/*/*.*
git add src
git clang-format
git add src
git commit -m "Sort #includes"
