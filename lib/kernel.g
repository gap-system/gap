#############################################################################
##
#W  kernel.g                    GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains function that should be in the kernel of GAP.
##  Actually it now just contains some utilities needed very early in
##  the bootstrap
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
##  This function is used as a fall-back by the kernel for integers so 
##  large that the kernel buffer normally used is not big enough. Most
##  integers are printed by the faster kernel code.
##
# XXX This function should be obsolete because of the method installed in
# XXX cyclotom.g (FL)
STRING_INT_DEFAULT := function ( n )
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
##  returns the ordinal of the integer <n> as a string.
Ordinal := function ( n )
    local   str;

    str := SHALLOW_COPY_OBJ(STRING_INT(n));
    if n < 0 then n := -n; fi;
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
# XXX F  REPLACE_SUBSTRING( <string>, <old>, <new> ) . . .  replace <old> by <new>
# XXX    (should be thrown away) FL
##  REPLACE_SUBSTRING := function( string, old, new )
##      local   i;
##      
##      for i  in [ 0 .. LEN_LIST( string ) - LEN_LIST( old ) ]  do
##          if string{ i + [ 1 .. LEN_LIST( old ) ] } = old  then
##              string{ i + [ 1 .. LEN_LIST( old ) ] } := new;
##          fi;
##      od;
##  end;

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
#F  POSITION_NOT( <list>, <val> [,<from-minus-one>] ) . . . .  find not <val>
##
POSITION_NOT := function( arg )
    local i;

    if LENGTH(arg) = 2  then
        for i  in [ 1 .. LENGTH(arg[1]) ]  do
            if arg[1][i] <> arg[2] then
                return i;
            fi;
        od;
        return LENGTH(arg[1]) + 1;

    elif LENGTH(arg) = 3 then
        for i  in [ arg[3]+1 .. LENGTH(arg[1]) ]  do
            if arg[1][i] <> arg[2] then
                return i;
            fi;
        od;
        return LENGTH(arg[1]) + 1;

    else
      Error( "usage: PositionNot( <list>, <val>[, <from>] )" );
    fi;

end;


#############################################################################
##
#V  POST_RESTORE_FUNCS
##
POST_RESTORE_FUNCS := [];


#############################################################################
##
#E

