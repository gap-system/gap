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
fail := false;


#############################################################################
##
#F  Gcd( [<R>,] <r1>, <r2>... ) . .  greatest common divisor of ring elements
##
##  Allow calls with arbitrarily many arguments.
##
if not IsBound( OLDGCD ) then
    OLDGCD := Gcd;
fi;

Gcd := function ( arg )
    local   R, ns, i, gcd;

    # get and check the arguments (what a pain)
    if   Length(arg) = 0  then
        Error("usage: Gcd( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := arg{ [2..Length(arg)] };
    else
        R := DefaultRing( arg );
        ns := arg;
    fi;
    if not IsList( ns )  or Length(ns) = 0  then
        Error("usage: Gcd( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    else
        if not ForAll( ns, n -> n in R )  then
            Error("<r> must be an element of <R>");
        fi;
    fi;
    if not IsEuclideanRing( R )  then
        Error("<R> must be a Euclidean ring");
    fi;

    # compute the gcd by iterating
    gcd := ns[1];
    for i  in [2..Length(ns)]  do
        gcd := OLDGCD( R, gcd, ns[i] );
    od;

    # return the gcd
    return gcd;
end;


#############################################################################
##
#F  GcdRepresentation( [<R>,] <r>, <s> )  . . . . . representation of the gcd
##
##  Allow calls with arbitrarily many arguments.
##
if not IsBound( OLDGCDREPRESENTATION ) then
    OLDGCDREPRESENTATION := GcdRepresentation;
fi;

GcdRepresentation := function ( arg )
    local   R, ns, i, gcd, rep, tmp;

    # get and check the arguments (what a pain)
    if   Length(arg) = 0  then
        Error("usage: Gcd( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := arg{ [2..Length(arg)] };
    else
        R := DefaultRing( arg );
        ns := arg;
    fi;
    if not IsList( ns )  or Length(ns) = 0  then
        Error("usage: GcdRepresentation( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    else
        if not ForAll( ns, n -> n in R )  then
            Error("<r> must be an element of <R>");
        fi;
    fi;
    if not IsEuclideanRing( R )  then
        Error("<R> must be a Euclidean ring");
    fi;

    # compute the gcd by iterating
    gcd := ns[1];
    rep := [ R.one ];
    for i  in [2..Length(ns)]  do
        tmp := OLDGCDREPRESENTATION ( R, gcd, ns[i] );
        gcd := tmp[1] * gcd + tmp[2] * ns[i];
        rep := List( rep, x -> x * tmp[1] );
        Add( rep, tmp[2] );
    od;

    # return the gcd representation
    return rep;
end;


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
#F  Lcm( [<R>,] <r1>, <r2>,.. ) .  least common multiple of two ring elements
##
##  Allow calls with arbitrarily many arguments.
##
if not IsBound( OLDLCM ) then
    OLDLCM := Lcm;
fi;

Lcm := function ( arg )
    local   ns,  R,  lcm,  i;

    # get and check the arguments (what a pain)
    if   Length(arg) = 0  then
        Error("usage: Lcm( [<R>,] <r1>, <r2>... )");
    elif Length(arg) = 1  then
        ns := arg[1];
    elif Length(arg) = 2 and IsRing(arg[1])  then
        R := arg[1];
        ns := arg[2];
    elif  IsRing(arg[1])  then
        R := arg[1];
        ns := arg{ [2..Length(arg)] };
    else
        R := DefaultRing( arg );
        ns := arg;
    fi;
    if not IsList( ns )  or Length(ns) = 0  then
        Error("usage: Lcm( [<R>,] <r1>, <r2>... )");
    fi;
    if not IsBound( R )  then
        R := DefaultRing( ns );
    else
        if not ForAll( ns, n -> n in R )  then
            Error("<r> must be an element of <R>");
        fi;
    fi;
    if not IsEuclideanRing( R )  then
        Error("<R> must be a Euclidean ring");
    fi;

    # compute the least common multiple
    lcm := ns[1];
    for i  in [2..Length(ns)]  do
        lcm := OLDLCM( R, lcm, ns[i] );
    od;

    # return the lcm
    return lcm;
end;


#############################################################################
##
#M  Order( <D>, <elm> ) . . . . . . . . . . . . . . two argument order method
##
if not IsBound( OLDORDER ) then
    OLDORDER := Order;
fi;

Order := function( arg )
    return OLDORDER( arg[1] );
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




