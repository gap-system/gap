#############################################################################
##
#W  random.g                    GAP library                  Martin Schönert
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the random number generator
##

#############################################################################
##
#F  RANDOM_LIST( <list> ) . . . . . . . . return a random element from a list
##
R_N := 1;
R_X := [];

# 268435456 is 2^28. This way
# we avoid recomputing it every time we need it.
R_228 := 2^28;
RANDOM_LIST := function ( list )
    R_N := R_N mod 55 + 1;
    R_X[R_N] := (R_X[R_N] + R_X[(R_N+30) mod 55+1]) mod R_228;
    return list[ QUO_INT( R_X[R_N] * LEN_LIST(list), R_228 ) + 1 ];
end;

RANDOM_SEED := function ( n )
    local  i;
    R_N := 1;  R_X := [ n mod R_228 ];
    for i  in [2..55]  do
        R_X[i] := (1664525 * R_X[i-1] + 1) mod R_228;
    od;
    for i  in [1..99]  do
        R_N := R_N mod 55 + 1;
        R_X[R_N] := (R_X[R_N] + R_X[(R_N+30) mod 55+1]) mod R_228;
    od;
end;

if R_X = []  then RANDOM_SEED( 1 );  fi;

#############################################################################
##
#E  random.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

