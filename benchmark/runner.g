#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Shared code for benchmark suites, see README. A suite is a file
##  <suite>/<suite>.g that adds records to the list BENCH_CASES with
##    name, category   strings
##    needs            list of package names, optional
##    setup            function() returning the untimed ingredients
##    run              function(ingredients) returning the result
##  The result is recorded, so it should change if the answer were wrong.
##

BENCH_CASES := [];

BENCH_Field := function( obj )
    local   s;

    s := String( obj );
    if Length( s ) > 5000  then
        s := s{ [ 1 .. 5000 ] };
    fi;
    return ReplacedString( ReplacedString( s, "\n", " " ), "\t", " " );
end;

BENCH_Reseed := function( seed )
    Reset( GlobalMersenneTwister, seed );
    Reset( GlobalRandomSource, seed );
end;

BENCH_LoadSuite := function( dir, suite )
    Read( Concatenation( dir, "/", suite, "/", suite, ".g" ) );
end;

#############################################################################
##
#F  BENCH_RunCase( <case>, <seeds> )
##
##  Runs <case> once for each seed in <seeds>, each from a fresh setup with
##  the random sources reset to the seed, and returns a record with
##  `status' ("ok", "skipped" or "error"), the list `ms' of timings, and
##  the `result' as a string or the `error' message. The backtrack makes
##  random choices, so one case can be fast at one seed and slow at the
##  next; the results must agree.
##
BENCH_RunCase := function( case, seeds )
    local   pkg,  ms,  res,  seed,  args,  t,  ok;

    if IsBound( case.needs )  then
        for pkg  in case.needs  do
            if LoadPackage( pkg, false ) <> true  then
                return rec( status := "skipped", ms := [  ],
                            error := Concatenation( "needs package ", pkg ) );
            fi;
        od;
    fi;

    ms := [  ];
    res := fail;
    for seed  in seeds  do
        BENCH_Reseed( seed );
        args := case.setup( );
        BENCH_Reseed( seed );
        t := Runtime( );
        ok := CALL_WITH_CATCH( case.run, [ args ] );
        t := Runtime( ) - t;
        if not ok[ 1 ]  then
            return rec( status := "error", ms := ms,
                        error := BENCH_Field( ok[ 2 ] ) );
        fi;
        if res <> fail  and  res <> ok[ 2 ]  then
            return rec( status := "error", ms := ms,
                        error := Concatenation( "results differ between seeds: ",
                                     res, " and ", BENCH_Field( ok[ 2 ] ) ) );
        fi;
        res := ok[ 2 ];
        Add( ms, t );
    od;
    return rec( status := "ok", ms := ms, result := BENCH_Field( res ) );
end;
