#############################################################################
##
#W  object.gi                   GAP library                  Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains some methods applicable objects in general.
##
Revision.object_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  '<obj1> = <obj2>'
##
InstallMethod( \=,
    IsNotIdentical,
    [ IsObject,
      IsObject ],
    0,
    false );


#############################################################################
##
#M  \=( <fam1>, <fam2> )  . . . . . . . . . . . . . . . . .  for two families
##
InstallMethod( \=, true, [ IsFamily, IsFamily], 0, IS_IDENTICAL_OBJ );


#############################################################################
##
#M  FormattedString( <obj>, <width> )  . . . . . convert object into a string
##
InstallMethod( FormattedString,
    true,
    [ IsObject,
      IsPosRat and IsInt ],
    0,

function( str, n )

    local   blanks, fill;

    str:= String( str );

    # If <width> is too small, return.
    if Length( str ) >= n then
        return str;
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
    true,
    [ IsObject,
      IsNegRat and IsInt ],
    0,

function( str, n )

    local   blanks, fill;

    str:= String( str );

    # If <width> is too small, return.
    if Length( str ) >= -n then
        return str;
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


#############################################################################
##
#M  PrintObj( <obj> )
##
InstallMethod( PrintObj,
    true,
    [ HasName ],
    SUM_FLAGS,
    function ( obj )  Print( Name( obj ) ); end );


InstallMethod( PrintObj,
    true,
    [ IsObject ],
    0,
    function( obj ) Print( "<object>" ); end );


#############################################################################
##
#F  ShallowCopy( <obj> )  . . . . . . . . . . . . . . . shallow copy of <obj>
##
InstallMethod( ShallowCopy,
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

#E  object.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


