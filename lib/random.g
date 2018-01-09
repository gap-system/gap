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
if IsHPCGAP then
    MakeThreadLocal("R_N");
    MakeThreadLocal("R_X");
else
    R_N := 1;
    R_X := [];
fi;

# We need to compute modulo 2^28 repeatedly. If we just write 2^28 into the
# code, though, GAP needs to evaluate it to 268435456 each time it executes
# the function. To avoid this, we put it into a constant. As an additional
# trick, we actually store -2^28, which gives identical results, but has the
# benefit of being an immediate integer even on 32 bit systems.
BIND_CONSTANT("R_228", -2^28);
RANDOM_LIST := function ( list )
    R_N := R_N mod 55 + 1;
    R_X[R_N] := (R_X[R_N] + R_X[(R_N+30) mod 55+1]) mod R_228;
    return list[ QUO_INT( R_X[R_N] * LEN_LIST(list), -R_228 ) + 1 ];
end;

RANDOM_SEED := function ( n )
    local  i;
    R_N := 1;
    R_X := [ n mod R_228 ];
    for i  in [2..55]  do
        R_X[i] := (1664525 * R_X[i-1] + 1) mod R_228;
    od;
    for i  in [1..99]  do
        R_N := R_N mod 55 + 1;
        R_X[R_N] := (R_X[R_N] + R_X[(R_N+30) mod 55+1]) mod R_228;
    od;
end;

if IsHPCGAP then

    BIND_GLOBAL("RANDOM_SEED_COUNTER", FixedAtomicList(1, 0));

    BIND_GLOBAL("GET_RANDOM_SEED_COUNTER", function()
      local r;
      r := ATOMIC_ADDITION(RANDOM_SEED_COUNTER, 1, 1);
      return r;
    end);

    BIND_GLOBAL("RANDOM_SEED_CONSTRUCTOR", function()
        RANDOM_SEED( GET_RANDOM_SEED_COUNTER() );
    end);

    BindThreadLocalConstructor("R_N", RANDOM_SEED_CONSTRUCTOR);
    BindThreadLocalConstructor("R_X", RANDOM_SEED_CONSTRUCTOR);

else

if R_X = []  then RANDOM_SEED( 1 );  fi;

fi;

#############################################################################
##
#E  random.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

