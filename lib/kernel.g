#############################################################################
##
#W  kernel.g                    GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains function that should be in the kernel of GAP.
##
Revision.kernel_g :=
    "@(#)$Id$";


#############################################################################
##

#F  ADD_LIST_DEFAULT( <list>, <obj> ) . . . . . .  add an element to the list
##
ADD_LIST_DEFAULT := function ( list, obj )
    list[ LEN_LIST(list)+1 ] := obj;
end;


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
#F  AS_LIST_SORTED_LIST( <list> ) . . . . . . . . . . . . . . setify the list
##
AS_LIST_SORTED_LIST := function ( list )
    local   new;
    if not IS_MUTABLE_OBJ( list ) and IS_SSORT_LIST( list ) then
        new := list;
    else
        new := IMMUTABLE_COPY_OBJ( LIST_SORTED_LIST( list ) );
    fi;
    return new;
end;


#############################################################################
##
#F  STRING_INT( <int> ) . . . . . . . . . . . . . . . .  string of an integer
##
STRING_INT := function ( n )
    local  str,  num,  digits;

    # construct the string without sign
    num:= n;
    if num < 0 then num := - n; fi;
    digits := [ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' ];
    str := "";
    repeat
        ADD_LIST( str, digits[num mod 10 + 1] );
        num := QUO_INT( num, 10 );
    until num = 0;

    # add the sign and return
    if n < 0  then
        ADD_LIST( str, '-' );
    fi;
    str:= IMMUTABLE_COPY_OBJ( str{[LEN_LIST(str),LEN_LIST(str)-1 .. 1]} );
    CONV_STRING( str );
    return str;
end;


#############################################################################
##
#F  Ordinal( <n> )  . . . . . . . . . . . . . ordinal of an integer as string
##
Ordinal := function ( n )
    local   str;

    str := STRING_INT(n);
    if   n mod 10 = 1  and n mod 100 <> 11  then
        APPEND_LIST_INTR( str, "st" );
    elif n mod 10 = 2  and n mod 100 <> 12  then
        APPEND_LIST_INTR( str, "nd" );
    elif n mod 10 = 3  and n mod 100 <> 13  then
        APPEND_LIST_INTR( str, "rd" );
    else
        APPEND_LIST_INTR( str, "th" );
    fi;
    return str;
end;


############################################################################
##

#F  REPLACE_SUBSTRING( <string>, <old>, <new> ) . . .  replace <old> by <new>
##
REPLACE_SUBSTRING := function( string, old, new )
    local   i;
    
    for i  in [ 0 .. LEN_LIST( string ) - LEN_LIST( old ) ]  do
        if string{ i + [ 1 .. LEN_LIST( old ) ] } = old  then
            string{ i + [ 1 .. LEN_LIST( old ) ] } := new;
        fi;
    od;
end;

#############################################################################
##
#F  IS_SUBSTRING( <str>, <sub> )  . . . . . . . . .  check if <sub> is prefix
##
IS_SUBSTRING := function( str, sub )
    local   l,  i;

    l := LEN_LIST(sub);
    if l = 0  then return true;  fi;
    for i  in [ 1 .. LEN_LIST(str)-l+1 ]  do
        if str{[i..i+l-1]} = sub  then
            return true;
        fi;
    od;
    return false;
end;


#############################################################################
##
#F  STRING_LOWER( <str> ) . . . . . . . . . convert to lower, remove specials
##
STRING_LOWER1 := "";
STRING_LOWER2 := "";
SortParallel := "2b defined";
PositionSorted := "2b defined";

STRING_LOWER := function( str )
    local   new,  s,  p;

    if 0 = LEN_LIST(STRING_LOWER1)  then
        APPEND_LIST_INTR( STRING_LOWER1, "abcdefghijklmnopqrstuvwxyz  " );
        APPEND_LIST_INTR( STRING_LOWER2, "ABCDEFGHIJKLMNOPQRSTUVWXYZ!~" );
        APPEND_LIST_INTR( STRING_LOWER1, "abcdefghijklmnopqrstuvwxyz" );
        APPEND_LIST_INTR( STRING_LOWER2, "abcdefghijklmnopqrstuvwxyz" );
        SortParallel( STRING_LOWER2, STRING_LOWER1 );
    fi;

    new := "";
    for s  in str  do
        if s in STRING_LOWER2  then
            p := PositionSorted( STRING_LOWER2, s );
            ADD_LIST( new, STRING_LOWER1[p] );
        else
            ADD_LIST( new, s );
        fi;
    od;
    CONV_STRING(new);
    return new;
end;


#############################################################################
##

#E  kernel.g  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

