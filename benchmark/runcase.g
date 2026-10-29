#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Lists the cases of a suite or runs one of them; the driver run.py sets
##  the record BENCH before reading this file:
##    dir           the benchmark directory
##    suite         name of the suite, see runner.g
##    list          if true, list the cases and quit
##    case          name of the case to run
##    seeds         list of seeds for the random sources, one run each
##    reproducible  whether to set the ReproducibleBehaviour preference
##
##  Output lines read by the driver, with fields separated by tabs:
##    @CASE  <name> <category> <needs>
##    @BENCH <name> <status> <ms,...> <result or error>
##

if BENCH.reproducible  then
    SetUserPreference( "ReproducibleBehaviour", true );
fi;
Read( Concatenation( BENCH.dir, "/runner.g" ) );
BENCH_LoadSuite( BENCH.dir, BENCH.suite );

BENCH_Main := function( )
    local   case,  needs,  r;

    if IsBound( BENCH.list )  and  BENCH.list  then
        for case  in BENCH_CASES  do
            if IsBound( case.needs )  then  needs := case.needs;
                                       else  needs := [  ];       fi;
            Print( "@CASE\t", case.name, "\t", case.category, "\t",
                   JoinStringsWithSeparator( needs, "," ), "\n" );
        od;
        return;
    fi;

    case := First( BENCH_CASES, c -> c.name = BENCH.case );
    if case = fail  then
        Print( "@BENCH\t", BENCH.case, "\terror\t\tno such case\n" );
        return;
    fi;
    r := BENCH_RunCase( case, BENCH.seeds );
    if r.status = "ok"  then
        Print( "@BENCH\t", case.name, "\tok\t",
               JoinStringsWithSeparator( List( r.ms, String ), "," ), "\t",
               r.result, "\n" );
    else
        Print( "@BENCH\t", case.name, "\t", r.status, "\t\t", r.error, "\n" );
    fi;
end;

BENCH_Main( );
QuitGap( 0 );
