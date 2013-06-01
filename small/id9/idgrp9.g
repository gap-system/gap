#############################################################################
##
#W  idgrp9.g                 GAP group library             Hans Ulrich Besche
##                                                                Mike Newman
##
##  This file contains the identification routines for groups of order
##  p^4 >= 11 ^ 4.
##

#############################################################################
##
## tell GAP about the component
##
DeclareComponent("id9","1.0");

#############################################################################
##
#F ID_AVAILABLE_FUNCS[ 9 ]
##
ID_AVAILABLE_FUNCS[ 9 ] := function( size )
    local p;

    p := FactorsInt( size );

    if Length( p ) = 4 and Length( Set( p ) ) = 1 and p[ 1 ] >= 11 then
        return rec( func := 19,
                    number := 15,
                    p := p[ 1 ] );
    fi;

    return fail;
end;

#############################################################################
##
#F ID_GROUP_FUNCS[ 19 ]( G, inforec )
##
## order p ^ 4 >= 11 ^ 4
##
ID_GROUP_FUNCS[ 19 ] := function( G, inforec )
    local p, d, c, g, x, y;

    p := inforec.p;

    d := DerivedSeries( G );
    c := List( d, AbelianInvariants );
    c := List( c{[ 1 .. Length( c ) - 1 ]},
        x -> List( x, y -> Length( FactorsInt( y ) ) ) );

    if c = [ [ 4 ] ] then
        return 1;
    elif c = [ [ 2, 2 ] ] then
        return 2;
    elif c = [ [ 1, 1, 1 ], [ 1 ] ] then
        if IsCyclic( Centre( G ) ) then
            return 14;
        else
            # it is sufficient to test the elements of a pcgs to check if the
            # exponent of this group is p (ask Eamonn for details).
            g := List( Pcgs( G ), Order );
            if Set( g ) = [ p ] then
                return 12;
            else
                return 13;
            fi;
        fi;
    elif c = [ [ 1, 2 ], [ 1 ] ] then
        if IsCyclic( Centre( G ) ) then
            return 6;
        elif Size( Group( List( GeneratorsOfGroup( G ), x->x^p ) ) ) = p then
            return 3;
        else
            return 4;
        fi;
    elif c = [ [ 1, 3 ] ] then
        return 5;
    elif c = [ [ 1, 1 ], [ 1, 1 ] ] then
        c := Centralizer( G, d[ 2 ] );
        repeat
            x := Random( c );
        until not x in d[ 2 ];
        repeat
            y := Random( G );
        until not y in c;
        if Order( x ) = p then
            if Order( y ) = p then
                return 7;
            else
                return 8;
            fi;
        else
            if p > 60 then
                Info( InfoWarning, 1,
                   "IdGroup is distinguishing between ", [ p^4, 9 ], " and " );
                Info( InfoWarning, 1,
                   [ p^4, 10 ], ". This might be slow." );
            fi;
            if Comm( Comm( x, y ), y ) in 
               List( [ 1 .. (p-1)/2 ], i -> x ^ ( p * (i^2 mod p) ) ) then
                return 9;
            else
                return 10;
            fi;
        fi;
    elif c = [ [ 1, 1, 2 ] ] then
        return 11;
    elif c = [ [ 1, 1, 1, 1 ] ] then
        return 15;
    fi;
end; 
