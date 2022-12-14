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
#F  CollectGarbage( <full> )
##
##  This function works *not* only if GAP uses GASMAN.
##
InstallGlobalFunction( CollectGarbage, function( full )
    if full then
      GASMAN( "collect" );
    else
      GASMAN( "partial" );
    fi;
end );

#############################################################################
##
#F  GasmanStatistics( )
##
if GAPInfo.KernelInfo.GC = "GASMAN" then
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
fi;


#############################################################################
##
#F  GasmanMessageStatus()
##
if GAPInfo.KernelInfo.GC = "GASMAN" then
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
fi;


#############################################################################
##
#F  SetGasmanMessageStatus( <status> )
##
if GAPInfo.KernelInfo.GC = "GASMAN" then
InstallGlobalFunction(SetGasmanMessageStatus,
        function(stat)
    local oldstat,newstat,i;
    if GAPInfo.KernelInfo.GC <> "GASMAN" and stat <> "none" then
      Info( InfoWarning, 1,
            "SetGasmanMessageStatus makes sense only if GASMAN is running" );
      return;
    fi;
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
fi;


#############################################################################
##
#F  GasmanLimits( )
##
if GAPInfo.KernelInfo.GC = "GASMAN" then
InstallGlobalFunction(GasmanLimits,
        function()
    local raw, r;
    raw := GASMAN_LIMITS();
    r := rec();
    if IsBound(raw[1]) then r.min := raw[1]; fi;
    if IsBound(raw[2]) then r.max := raw[2]; fi;
    if IsBound(raw[3]) then r.kill := raw[3]; fi;
    return r;
end);
fi;
