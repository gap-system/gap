#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains implementations of functions that report information from the
##  GASMAN garbage collector
##
#############################################################################
##
#F  GasmanStatistics( )
##

InstallGlobalFunction(GasmanStatistics,
        function()
    local raw,cooked,convertrow;
    raw := GASMAN_STATS();
    cooked := rec();
    convertrow := row ->
                  rec( livebags := row[1],
                       livekb := row[2],
                       deadbags := row[3],
                       deadkb := row[4],
                       freekb := row[5],
                       totalkb := row[6],
                       time := row[7],
                       cumulative := row[8]);                       
    if raw[1][1] <> 0 then
        cooked.partial := convertrow(raw[1]);
    fi;
    if raw[2][1] <> 0 then
        cooked.full := convertrow(raw[2]);
    fi;
    cooked.npartial := raw[1][9];
    cooked.nfull := raw[2][9];    
    return cooked;
end );

#############################################################################
##
#F  GasmanMessageStatus()
##
InstallGlobalFunction(GasmanMessageStatus,
        function()
    local stat;
    stat := GASMAN_MESSAGE_STATUS();
    if stat = 0 then
        return "none";
    elif stat = 1 then
        return "full";
    else 
        return "all";
    fi;
end );


#############################################################################
##
#F  SetGasmanMessageStatus( <status> )
##

InstallGlobalFunction(SetGasmanMessageStatus,
        function(stat)
    local oldstat,newstat,i;
    oldstat := GASMAN_MESSAGE_STATUS();
    newstat := Position(["none", "full", "all"], stat);
    if newstat = fail then
        Error("GASMAN message status must be none, full or all");
    fi;
    newstat := newstat -1;
    for i in [1..(newstat + 3 - oldstat) mod 3] do
        GASMAN("message");
    od;
    return;
end);

#############################################################################
##
#F  GasmanLimits( )
##

InstallGlobalFunction(GasmanLimits, 
        function()
    local raw;
    raw := GASMAN_LIMITS();
    return rec(min := raw[1],
               max := raw[2],
               kill := raw[3]);
end);
