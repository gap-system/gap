#############################################################################
##
#W  random.g                    GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the random number generator
##
Revision.random_g :=
    "@(#)$Id$";

#############################################################################
##
#F  RANDOM_LIST( <list> ) . . . . . . . . return a random element from a list
##
R_N := 1;
R_X := [];

RANDOM_LIST := function ( list )
    R_N := R_N mod 55 + 1;
    R_X[R_N] := (R_X[R_N] + R_X[(R_N+30) mod 55+1]) mod 2^28;
    return list[ QUO_INT( R_X[R_N] * LEN_LIST(list), 2^28 ) + 1 ];
end;

RANDOM_SEED := function ( n )
    local  i;
    R_N := 1;  R_X := [ n ];
    for i  in [2..55]  do
        R_X[i] := (1664525 * R_X[i-1] + 1) mod 2^28;
    od;
    for i  in [1..99]  do
        R_N := R_N mod 55 + 1;
        R_X[R_N] := (R_X[R_N] + R_X[(R_N+30) mod 55+1]) mod 2^28;
    od;
end;

if R_X = []  then RANDOM_SEED( 1 );  fi;

#############################################################################
##
#E  random.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

