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
#M  ShallowCopy( <obj> )  . . . . . . . . . . . . . . . shallow copy of <obj>
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

#E  object.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


