#############################################################################
##
#W  object.gi                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains some methods applicable to objects in general.
##
Revision.object_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  '<obj1> = <obj2>' . . . . . . . . . . . for objects in different families
##
InstallMethod( \=,
    "for two objects in different families",
    IsNotIdenticalObj,
    [ IsObject,
      IsObject ],
    0,
    false );


#############################################################################
##
#M  \=( <fam1>, <fam2> )  . . . . . . . . . . . . . . . . .  for two families
##
InstallMethod( \=,
     "for two families: delegate to `IsIdenticalObj'",
     true,
     [ IsFamily, IsFamily], 0,
     IS_IDENTICAL_OBJ );


#############################################################################
##
#M  \<( <obj1>, <obj2> )  . . . . . . . for two objects in different families
##
#1
##  Only for the following kinds of objects, an ordering via `\<' of objects
##  in *different* families (see~"Families") is supported.
##  Rationals (see~"IsRat") are smallest,
##  next are cyclotomics (see~"IsCyclotomic"),
##  followed by finite field elements (see~"IsFFE");
##  finite field elements in different characteristics are compared
##  via their characteristics,
##  next are permutations (see~"IsPerm"),
##  followed by the boolean values `true', `false', and `fail'
##  (see~"IsBool"),
##  characters (such as `{'}a{'}', see~"IsChar"),
##  and lists (see~"IsList") are largest;
##  note that two lists can be compared with `\<' if and only if their
##  elements are again objects that can be compared with `\<'.
##
##  For other objects, {\GAP} does *not* provide an ordering via `\<'.
##  The reason for this is that a total ordering of all {\GAP} objects
##  would be hard to maintain when new kinds of objects are introduced,
##  and such a total ordering is hardly used in its full generality.
##
##  However, for objects in the filters listed above, the ordering via `\<'
##  has turned out to be useful.
##  For example, one can form *sorted lists* containing integers and nested
##  lists of integers, and then search in them using `PositionSorted'
##  (see~"Finding Positions in Lists").
##
##  Of course it would in principle be possible to define an ordering
##  via `\<' also for certain other objects,
##  by installing appropriate methods for the operation `\\\<'.
##  But this may lead to problems at least as soon as one loads {\GAP} code
##  in which the same is done, under the assumption that one is completely
##  free to define an ordering via `\<' for other objects than the ones
##  for which the ``official'' {\GAP} provides already an ordering via `\<'.
##
TO_COMPARE := [
    [ IsCyclotomic, "cyclotomic" ],
    [ IsFFE,        "finite field element" ],
    [ IsPerm,       "permutation" ],
    [ IsBool,       "boolean" ],
    [ IsChar,       "character" ],
    [ IsList,       "list" ],
                                              ];
MAKE_COMP := function()
    local i, j, func, infostr;

    for i in [ 1 .. Length( TO_COMPARE ) ] do
      for j in [ 1 .. Length( TO_COMPARE ) ] do
        if i <> j then
          if i < j then func:= ReturnTrue; else func:= ReturnFalse; fi;
          infostr:= "for a ";
          APPEND_LIST_INTR( infostr, TO_COMPARE[i][2] );
          APPEND_LIST_INTR( infostr, ", and a " );
          APPEND_LIST_INTR( infostr, TO_COMPARE[j][2] );
          InstallMethod( \<, infostr, true,
              [ TO_COMPARE[i][1], TO_COMPARE[j][1] ], 0, func );
        fi;
      od;
    od;
end;
MAKE_COMP();

InstallMethod( \<,
    "for two finite field elements in different characteristic",
    IsNotIdenticalObj,
    [ IsFFE, IsFFE ], 0,
    function( z1, z2 )
    return Characteristic( z1 ) < Characteristic( z2 );
    end );

InstallMethod( \<,
    "for two small lists, possibly in different families",
    true,
    [ IsList and IsSmallList, IsList and IsSmallList ], 0,
    LT_LIST_LIST_DEFAULT );

LT_LIST_LIST_FINITE := function( list1, list2 )
    
    local len, i;
    
    # We ask for being small in order to catch the default methods
    # directly in the next call if possible.
    if IsSmallList( list1 ) and IsSmallList( list2 ) then
      return LT_LIST_LIST_DEFAULT( list1, list2 );
    else
        
      len:= Minimum( Length( list1 ), Length( list2 ) );
      i:= 1;                      
      while i <= len do
        if list1[i] < list2[i] then
          return true;
        elif list2[i] < list1[i] then
          return false;
        fi;
        i:= i+1;
      od;
      return len < Length( list2 );

    fi;
end;

InstallMethod( \<,
    "for two finite lists, possibly in different families",
    true,
    [ IsList, IsList ], 0,
    LT_LIST_LIST_FINITE );


#############################################################################
##
#M  FormattedString( <obj>, <width> )  . . . . . convert object into a string
##
InstallMethod( FormattedString,
    "for an object, and a positive integer",
    true,
    [ IsObject,
      IsPosInt ],
    0,

function( str, n )

    local   blanks, fill;

    str:= String( str );

    # If <width> is too small, return.
    if Length( str ) >= n then
        return ShallowCopy(str);
    fi;

    # If <width> is positive, blanks are filled in from the left.
    blanks := "                                                 ";
    fill := n - Length( str );
    while fill > 0  do
        if fill >= Length( blanks )  then
            str := Concatenation( blanks, str );
        else
            str := Concatenation( blanks{ [ 1 .. fill ] }, str );
        fi;
        fill := n - Length( str );
    od;
    return str;
end );


InstallMethod( FormattedString,
    "for an object, and a negative integer",
    true,
    [ IsObject,
      IsNegRat and IsInt ],
    0,

function( str, n )

    local   blanks, fill;

    str:= String( str );

    # If <width> is too small, return.
    if Length( str ) >= -n then
        return ShallowCopy(str);
    fi;

    # If <width> is negative, blanks are filled in from the right.
    blanks := "                                                 ";
    fill :=  - n - Length( str );
    while fill > 0  do
        if fill >= Length( blanks )  then
            str := Concatenation( str, blanks );
        else
            str := Concatenation( str, blanks{ [ 1 .. fill ] } );
        fi;
        fill :=  - n - Length( str );
    od;
    return str;
end );


InstallMethod( FormattedString,
    "for an object, and zero",
    true,
    [ IsObject,
      IsZeroCyc ],
    0,

function( str, zero ) 
    return ShallowCopy(String( str )); 
end );


#############################################################################
##
#M  PrintObj( <obj> )
##
InstallMethod( PrintObj,
    "for an object with name",
    true,
    [ HasName ],
    SUM_FLAGS, # override anything specific
    function ( obj )  Print( Name( obj ) ); end );


InstallMethod( PrintObj,
    "default for an object",
    true,
    [ IsObject ],
    0,
    function( obj ) Print( "<object>" ); end );


#############################################################################
##
#M  ViewObj( <obj> )  . . . . . . . . . . . . . . . . for an object with name
##
InstallMethod( ViewObj,
    "for an object with name",
    true,
    [ HasName ],
    SUM_FLAGS, # override anything specific
    function ( obj )  Print( Name( obj ) ); end );


#############################################################################
##
#M  ShallowCopy( <obj> )  . . . . . . . . . . . . . . . shallow copy of <obj>
##
InstallMethod( ShallowCopy,
    "for a (not copyable) object",
    true,
    [ IsObject ],
    0,

function( obj )
    if IsCopyable(obj)  then
        TryNextMethod();
    else
        return obj;
    fi;
end );


#############################################################################
##
#M  IsInternallyConsistent( <obj> ) . . . . . . . default method 'ReturnTrue'
##
InstallMethod( IsInternallyConsistent,
    "default method 'ReturnTrue'",
    true,
    [ IsObject ], 0,
    ReturnTrue );


#############################################################################
##
#M  KnownAttributesOfObject( <object> ) . . . . . list of names of attributes
##
InstallMethod( KnownAttributesOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_ATTS );

    # convert it into names
    return List( NamesFilter(trues), x -> x{[8..Length(x)-1]} );
end );


#############################################################################
##
#M  KnownPropertiesOfObject( <object> ) . . . . . list of names of properties
##
InstallMethod( KnownPropertiesOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_TPRS );

    # convert it into names
    return List( NamesFilter(trues), x -> x{[8..Length(x)-1]} );
end );


#############################################################################
##
#M  KnownPropertiesOfObject( <object> ) . . . . . list of names of properties
#M  KnownTruePropertiesOfObject( <object> )  list of names of true properties
##
InstallMethod( KnownTruePropertiesOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_PROS );

    # convert it into names
    return NamesFilter(trues);
end );


#############################################################################
##
#M  CategoriesOfObject( <object> )  . . . . . . . list of names of categories
##
InstallMethod( CategoriesOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_CATS );

    # convert it into names
    return NamesFilter(trues);
end );


#############################################################################
##
#M  RepresentationsOfObject( <object> ) . .  list of names of representations
##
InstallMethod( RepresentationsOfObject,
    "for an object",
    true,
    [ IsObject ],
    0,

function( obj )
    local   type,  trues;

    # get the flags list
    type  := TypeObj(obj);
    trues := TRUES_FLAGS(type![2]);

    # filter the representations
    trues := Filtered( trues, x -> INFO_FILTERS[x] in FNUM_REPS );

    # convert it into names
    return NamesFilter(trues);
end );


#############################################################################
##
#M  Display( <obj> )  . . . . . . . . . . . . . . . . . . . display an object
##
##  We do not call `PrintObj' because strings shall be displayed without
##  enclosing doublequotes.
##
InstallMethod( Display,
    "generic: use Print",
    true,
    [ IsObject ], 0,
    Print );


#############################################################################
##

#E

