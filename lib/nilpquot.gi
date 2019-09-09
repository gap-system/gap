#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later

# TODO: document this function? it is used in various packages by now
BindGlobal( "LeftNormedComm", function( list )
    local c, i;

    if not IsList(list) or Length(list) = 0 then
        Error("<list> must be a non-empty list");
    fi;
    c := list[1];
    for i in [2..Length(list)] do
        c := Comm(c, list[i]);
    od;
    return c;
end );
