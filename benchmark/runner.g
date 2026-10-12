#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Shared code for the benchmark suites run by run.py, see README.
##
##  A suite is a file <suite>/<suite>.g that calls BENCH_AddCase once for
##  each of its cases. A case has a name and a category (strings), the
##  packages it needs, a function setup() that builds the input and is not
##  timed, and a function run(input) that computes the result and is timed.
##  The result is recorded and compared between runs, so it should be
##  something that changes if the answer were wrong: the order of a
##  normalizer, or whether a conjugator found really conjugates.
##

BENCH_CASES := [];

BENCH_AddCase := function( name, category, needs, setup, run )
    if ForAny( BENCH_CASES, c -> c.name = name )  then
        Error( "duplicate case name ", name );
    fi;
    Add( BENCH_CASES, rec( name := name, category := category,
                           needs := needs, setup := setup, run := run ) );
end;

BENCH_LoadSuite := function( dir, suite )
    Read( Concatenation( dir, "/", suite, "/", suite, ".g" ) );
end;

BENCH_Reseed := function( seed )
    Reset( GlobalMersenneTwister, seed );
    Reset( GlobalRandomSource, seed );
end;

# a result as one line of at most 5000 characters
BENCH_Field := function( obj )
    local   s;

    s := String( obj );
    if Length( s ) > 5000  then
        s := s{ [ 1 .. 5000 ] };
    fi;
    return ReplacedString( ReplacedString( s, "\n", " " ), "\t", " " );
end;

#############################################################################
##
#F  BENCH_RunCase( <case>, <seeds> )
##
##  Runs <case> once for each seed in <seeds> and returns a record with
##  `status' ("ok", "skipped" or "error"), the list `ms' of timings, and
##  the `result' as a string or the `error' message. The input is built
##  afresh each time, with the random sources reset to 1 so that it is the
##  same for every seed; run() then sees the sources reset to the seed. The
##  backtrack makes random choices, so one case can be fast at one seed and
##  slow at the next; the results must agree.
##
BENCH_RunCase := function( case, seeds )
    local   pkg,  ms,  res,  seed,  input,  t,  ok;

    for pkg  in case.needs  do
        if LoadPackage( pkg, false ) <> true  then
            return rec( status := "skipped", ms := [  ],
                        error := Concatenation( "needs package ", pkg ) );
        fi;
    od;

    ms := [  ];
    res := fail;
    for seed  in seeds  do
        BENCH_Reseed( 1 );
        input := case.setup( );
        BENCH_Reseed( seed );
        t := Runtime( );
        ok := CALL_WITH_CATCH( case.run, [ input ] );
        t := Runtime( ) - t;
        if not ok[ 1 ]  then
            return rec( status := "error", ms := ms,
                        error := BENCH_Field( ok[ 2 ] ) );
        fi;
        if res <> fail  and  res <> ok[ 2 ]  then
            return rec( status := "error", ms := ms,
                        error := Concatenation(
                                     "results differ between seeds: ",
                                     BENCH_Field( res ), " and ",
                                     BENCH_Field( ok[ 2 ] ) ) );
        fi;
        res := ok[ 2 ];
        Add( ms, t );
    od;
    return rec( status := "ok", ms := ms, result := BENCH_Field( res ) );
end;
