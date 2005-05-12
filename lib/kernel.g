#############################################################################
##
#W  kernel.g                    GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains function that should be in the kernel of GAP.
##  Actually it now just contains some utilities needed very early in
##  the bootstrap.
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


#############################################################################
##
#F  IS_SUBSTRING( <str>, <sub> )  . . . . . . . . .  check if <sub> is prefix
##
IS_SUBSTRING := function( str, sub )
  if LEN_LIST(sub) > 0 and POSITION_SUBSTRING(str, sub, 0) = fail then
    return false;
  else
    return true;
  fi;
end;


#############################################################################
##
#F  STRING_LOWER( <str> ) . . . . . . . . . convert to lower, remove specials
##
# seems obsolete now? (FL)
STRING_LOWER_TRANS := 0;

STRING_LOWER := function( str )
  local i, res;
  if STRING_LOWER_TRANS = 0 then
    STRING_LOWER_TRANS := "";
    for i in [0..255] do 
      STRING_LOWER_TRANS[i+1] := CHAR_INT(i);
    od;
    STRING_LOWER_TRANS{1+[65..90]} := STRING_LOWER_TRANS{1+[97..122]};
    STRING_LOWER_TRANS{1+[33,126]} := "  ";
  fi;
  res := SHALLOW_COPY_OBJ(str);
  TranslateString(res, STRING_LOWER_TRANS);
  return res;
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
#F  Runtimes() . . . . . . . . self-explaining version of result of RUNTIMES()
##
Runtimes := function()
  local res, rt, cmp, a, i;
  res := rec();
  rt := RUNTIMES();
  cmp := ["user_time", "system_time", 
          "user_time_children", "system_time_children"]; 
  if IS_INT(rt) then
    for a in cmp do 
      res.(a) := fail;
    od;
    res.(cmp[1]) := rt;
  else
    for i in [1..4] do
      res.(cmp[i]) := rt[i];
    od;
  fi;
  return res;
end;

############################################################################
##
#V  POST_RESTORE_FUNCS
##
POST_RESTORE_FUNCS := [];


#############################################################################
##
#E

