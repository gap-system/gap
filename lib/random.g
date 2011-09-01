#############################################################################
##
#W  random.g                    GAP library                  Martin Schönert
##
#H  @(#)$Id: random.g,v 4.5 2010/02/23 15:13:25 gap Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the random number generator
##
Revision.random_g :=
    "@(#)$Id: random.g,v 4.5 2010/02/23 15:13:25 gap Exp $";

#############################################################################
##
#F  RANDOM_LIST( <list> ) . . . . . . . . return a random element from a list
##
MakeThreadLocal("R_N");
MakeThreadLocal("R_X");
BindThreadLocal("R_N", 1);
BindThreadLocal("R_X", [ ]);

BIND_GLOBAL("RANDOM_SEED_COUNTER", FixedAtomicList(1, 0));
BIND_GLOBAL("GET_RANDOM_SEED_COUNTER", function()
  local r;
  r := ATOMIC_ADDITION(RANDOM_SEED_COUNTER, 1, 1);
  return r;
end);

# 268435456 is 2^28. This way
# we avoid recomputing it every time we need it.
R_228 := 2^28;
RANDOM_LIST := function ( list )
    local r_n, r_x;
    r_n := ThreadVar.R_N;
    r_x := ThreadVar.R_X;
    R_N := r_n mod 55 + 1;
    r_x[r_n] := (r_x[r_n] + r_x[(r_n+30) mod 55+1]) mod R_228;
    return list[ QUO_INT( r_x[r_n] * LEN_LIST(list), R_228 ) + 1 ];
end;

RANDOM_SEED := function ( n )
    local  i, r_n, r_x;
    ThreadVar.R_N := 1;  ThreadVar.R_X := [ n mod R_228 ];
    r_n := ThreadVar.R_N; r_x := ThreadVar.R_X;
    for i  in [2..55]  do
        r_x[i] := (1664525 * r_x[i-1] + 1) mod R_228;
    od;
    for i  in [1..99]  do
        R_N := r_n mod 55 + 1;
        r_x[r_n] := (r_x[r_n] + r_x[(r_n+30) mod 55+1]) mod R_228;
    od;
end;

if ThreadVar.R_X = []  then RANDOM_SEED( GET_RANDOM_SEED_COUNTER() );  fi;

#############################################################################
##
#E  random.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

