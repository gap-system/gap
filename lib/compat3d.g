#############################################################################
##
#W  compat3d.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the destructive part of the {\GAP} 3 compatibility
##  mode, i.e., those parts whose availability in {\GAP} 4 is possible only
##  at the cost of losing some {\GAP} 4 specific functionality.
##
##  This file is read only if the user explicitly reads it.
##  *Note* that it is not possible to switch off the destructive part of the
##  compatibility mode once it has been loaded.
##
#T I think we should make the compatibility mode available only via a
#T command line option.
#T (This will be unavoidable if it involves changes in the kernel.)
##
Revision.compat3d_g :=
    "@(#)$Id$";


#############################################################################
##
##  Print a warning (preliminary proposal).
##
Print( "#I  Now the destructive part of the GAP 3 compatibility mode\n",
       "#I  is loaded.\n",
       "#I  This makes certain GAP 4 facilities unusable.\n",
       "#I  (If I would be in favour of misusing the literature then\n",
       "#I  I would express the effect of loading this mode as follows.\n",
       "#I  \n",
       "#I  ``Lasciate ogni speranza, voi ch' entrate!'')\n" );


#############################################################################
##
#F  Domain( <list> )
##
##  We must forbid calling `Domain'.
##  In {\GAP}-3, it was used as an oracle in the construction of domains,
##  it returned for example `FiniteFieldMatrices' or `Permutations'.
##
##  In {\GAP}-4, the various aspects of information to create domains are
##  described by the types of objects.
##
Domain := function( arg )
    Error( "this function is not available in GAP 4\n",
           "because the domain construction mechanism has changed" );
end;


#############################################################################
##
#V  fail
##
##  In the compatibility mode, 'fail' and 'false' are identical.
##  This is necessary to handle the different behaviour of e.g. 'Position'.
##
#T This does not work, the kernel returns the proper `FAIL' object in many
#T cases.
#T The destructive part of the compatibility mode can be available only via
#T a command line option.
##
if not IsBound( OLDFAIL ) then
  OLDFAIL:= fail;
  MakeReadWriteGVar( "fail" );
  fail := false;
fi;


#############################################################################
##
#F  IsString( <obj> )
##
##  In {\GAP} 3, `IsString' did silently convert its argument to the string
##  representation.
##
if not IsBound( OLDISSTRING ) then
    OLDISSTRING := IsString;
fi;

IsString := function( obj )
    local result;
    result:= OLDISSTRING( obj );
    if result then
      ConvertToStringRep( obj );
    fi;
    return result;
end;


#############################################################################
##
#M  Order( <D>, <elm> ) . . . . . . . . . . . . . . two argument order method
##
if not IsBound( OLDORDER ) then
    OLDORDER := Order;
fi;

Order := function( arg )
    if Length( arg ) = 2 then
      return OLDORDER( arg[2] );
    else
      Error( "usage: Order( <D>, <d> )" );
    fi;
end;


#############################################################################
##
#M  Position( <list>, <elm> ) . . . . . . .  return `false' instead of `fail'
#M  Position( <list>, <elm>, <from> ) . . .  return `false' instead of `fail'
##
if not IsBound( OLDPOSITION ) then
    OLDPOSITION := Position;
fi;

Position := function( arg )
    local pos;
    if Length( arg ) = 2 then
      pos:= OLDPOSITION( arg[1], arg[2] );
    else
      pos:= OLDPOSITION( arg[1], arg[2], arg[3] );
    fi;
    if pos = OLDFAIL then
      pos:= false;
    fi;
    return pos;
end;


#############################################################################
##
#F  String( <obj> )
#F  String( <obj>, <width> )
##
##  The problem with 'String' is that it is an attribute in {\GAP-4},
##  so we cannot deal with two argument methods.
##
if not IsBound( OLDSTRING ) then
    OLDSTRING := String;
fi;

String := function( arg )
    if Length( arg ) = 1 then
        return OLDSTRING( arg[1] );
    elif Length( arg ) = 2 then
        return FormattedString( arg[1], arg[2] );
    fi;
end;

StringInt    := OLDSTRING;
StringRat    := OLDSTRING;
StringCyc    := OLDSTRING;
StringFFE    := OLDSTRING;
StringPerm   := OLDSTRING;
StringAgWord := OLDSTRING;
StringBool   := OLDSTRING;
StringList   := OLDSTRING;
StringRec    := OLDSTRING;


#############################################################################
##
#E  compat3d.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here




