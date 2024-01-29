#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains function that should be in the kernel of GAP.
##  Actually it now just contains some utilities needed very early in
##  the bootstrap.
##


#############################################################################
##
#F  ADD_LIST_DEFAULT( <list>, <obj> ) . . . . . .  add an element to the list
##
##  <ManSection>
##  <Func Name="ADD_LIST_DEFAULT" Arg='list, obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
ADD_LIST_DEFAULT := function ( list, obj )
    list[ LEN_LIST(list)+1 ] := obj;
end;



#############################################################################
##
#F  AS_LIST_SORTED_LIST( <list> ) . . . . . . . . . . . . . . setify the list
##
##  <ManSection>
##  <Func Name="AS_LIST_SORTED_LIST" Arg='list'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <#GAPDoc Label="Ordinal">
##  <ManSection>
##  <Func Name="Ordinal" Arg='n'/>
##
##  <Description>
##  returns the ordinal of the integer <A>n</A> as a string.
##  <Example><![CDATA[
##  gap> Ordinal(2);  Ordinal(21);  Ordinal(33);  Ordinal(-33);
##  "2nd"
##  "21st"
##  "33rd"
##  "-33rd"
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
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
##  <ManSection>
##  <Func Name="IS_SUBSTRING" Arg='str, sub'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
IS_SUBSTRING := function( str, sub )
  return LEN_LIST(sub) = 0 or POSITION_SUBSTRING(str, sub, 0) <> fail;
end;


#############################################################################
##
#F  STRING_LOWER( <str> ) . . . . . . . . . convert to lower, remove specials
##
##  <ManSection>
##  <Func Name="STRING_LOWER" Arg='str'/>
##
##  <Description>
##  <!-- seems obsolete now? (FL) -->
##  </Description>
##  </ManSection>
##
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
##  <ManSection>
##  <Func Name="POSITION_NOT" Arg='list, val [,from-minus-one]'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
        if LENGTH( arg[1] ) <= arg[3] then
          return arg[3] + 1;
        else
          return LENGTH(arg[1]) + 1;
        fi;
    else
      Error( "usage: PositionNot( <list>, <val>[, <from>] )" );
    fi;

end;

#############################################################################
##
#F  Runtimes() . . . . . . . . self-explaining version of result of RUNTIMES()
##
##  <ManSection>
##  <Func Name="Runtimes" Arg=''/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
