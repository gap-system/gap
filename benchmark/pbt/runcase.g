#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Runs one case of cases.g and prints its time and result. run.py calls
##  this in this directory, for each case and seed, as
##
##      gap -q -A --quitonbreak
##          -c 'PBT_CASE := "<name>";; PBT_SEED := <seed>;;' runcase.g
##
##  and reads the line "@RESULT <ms> <result>" it prints, with tabs between
##  the fields. With PBT_CASE := fail, a line "@CASE <name>" is printed for
##  each case instead.
##

# library code that adapts to how long something took would otherwise make
# the same computation differ from run to run
SetUserPreference( "ReproducibleBehaviour", true );

# so that GAP does not break the lines printed below
SizeScreen( [ 4096 ] );

Read( "cases.g" );

PBT_Reseed := function( seed )
    Reset( GlobalMersenneTwister, seed );
    Reset( GlobalRandomSource, seed );
end;

PBT_RunCase := function( name, seed )
    local case, input, ms, result;

    case := PBT_Case( name );
    if case = fail then
        Error( "there is no case named ", name );
    fi;

    # the input is the same for every seed, which only affects the search
    PBT_Reseed( 1 );
    input := case.setup( );

    PBT_Reseed( seed );
    ms := Runtime( );
    result := case.run( input );
    ms := Runtime( ) - ms;

    Print( "@RESULT\t", ms, "\t", result, "\n" );
end;

if PBT_CASE = fail then
    Perform( PBT_CASES, function( case )
        Print( "@CASE\t", case.name, "\n" );
    end );
else
    PBT_RunCase( PBT_CASE, PBT_SEED );
fi;
QuitGap( 0 );
