#############################################################################
##
#W  basicpcg.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for the construction of the basic pc group
##  types.
##
Revision.basicpcg_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  AbelianGroupCons( <IsPcGroup and IsFinite>, <ints> )
##
InstallMethod( AbelianGroupCons,
    "pc group",
    true,
    [ IsPcGroup and IsFinite,
      IsList ],
    0,

function( filter, ints )
    local   pis,  f,  g,  r,  k,  pi,  i;

    if not ForAll( ints, IsInt )  then
        Error( "<ints> must be a list of integers" );
    fi;
    if not ForAll( ints, x -> 0 < x )  then
        TryNextMethod();
    fi;

    pis := List( Filtered( ints, x -> 1 < x ), Factors );
    f   := FreeGroup( Sum( List( pis, Length ) ) );
    g   := GeneratorsOfGroup(f);
    r   := [];
    k   := 1;
    for pi  in pis  do
        for i  in [ 1 .. Length(pi)-1 ]  do
            Add( r, g[k]^pi[i] / g[k+1] );
            k := k + 1;
        od;
        Add( r, g[k]^pi[Length(pi)] );
        k := k + 1;
    od;
    f := PolycyclicFactorGroup( f, r );
    SetSize( f, Product(ints) );
    SetIsAbelian( f, true );
    return f;
end );


#############################################################################
##
#M  AlternatingGroupCons( <IsPcGroup and IsFinite>, <deg> )
##
InstallMethod( AlternatingGroupCons,
    "pc group with degree",
    true,
    [ IsPcGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, deg )
    local   alt;

    if 4 < deg  then
        Error( "<deg> must be at most 4" );
    fi;
    alt := GroupByPcgs(Pcgs(AlternatingGroupCons(IsPermGroup,[1..deg])));
    SetIsAlternatingGroup( alt, true );
    return alt;
end );


#############################################################################
##
#M  CyclicGroupCons( <IsPcGroup and IsFinite>, <n> )
##
InstallMethod( CyclicGroupCons,
    "pc group",
    true,
    [ IsPcGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   pi,  f,  g,  r,  i;

    pi := Factors( n );
    f  := FreeGroup( Length(pi) );
    g  := GeneratorsOfGroup(f);
    r  := [];
    for i  in [ 1 .. Length(g)-1 ]  do
        Add( r, g[i]^pi[i] / g[i+1] );
    od;
    Add( r, g[Length(g)] ^ pi[Length(g)] );
    f := PolycyclicFactorGroup( f, r );
    SetSize( f, n );
    SetIsCyclic( f, true );
    return f;
end );


#############################################################################
##
#M  CyclicGroupCons( <IsPcGroup and IsFinite and IsOneGeneratorGroup>, <n> )
##
InstallMethod( CyclicGroupCons,
    "pc group",
    true,
    [ IsPcGroup and IsFinite and IsOneGeneratorGroup,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   f,  g,  r;

    f := FreeGroup(1);
    g := GeneratorsOfGroup(f);
    r := [ g[1]^n ];
    f := PolycyclicFactorGroup( f, r );
    SetSize( f, n );
    SetIsCyclic( f, true );
    return f;
end );


#############################################################################
##
#M  DihedralGroupCons( <IsPcGroup and IsFinite>, <n> )
##
InstallMethod( DihedralGroupCons,
    "pc group",
    true,
    [ IsPcGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   pi,  f,  g,  r,  i;

    if n mod 2 = 1  then
        TryNextMethod();
    fi;
    pi := Factors(n/2);
    f  := FreeGroup( Length(pi)+1 );
    g  := GeneratorsOfGroup(f);
    r  := [];
    for i  in [ 2 .. Length(g)-1 ]  do
        Add( r, g[i]^pi[i-1] / g[i+1] );
    od;
    Add( r, g[Length(g)] ^ pi[Length(g)-1] );
    Add( r, g[1]^2 );
    for i  in [ 2 .. Length(g) ]  do
        Add( r, g[i]^g[1] * g[i] );
    od;
    f := PolycyclicFactorGroup( f, r );
    SetSize( f, n );
    return f;
end );


#############################################################################
##
#M  ElementaryAbelianGroupCons( <IsPcGroup and IsFinite>, <n> )
##
InstallMethod( ElementaryAbelianGroupCons,
    "pc group",
    true,
    [ IsPcGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    if n = 1  then
        return CyclicGroupCons( IsPcGroup, 1 );
    fi;
    if not IsPrimePowerInt(n)  then
        Error( "<n> must be a prime power" );
    fi;
    return AbelianGroupCons( IsPcGroup, Factors(n) );
end );


#############################################################################
##
#M  ExtraspecialGroupCons( <IsPcGroup and IsFinite>, <order>, <exponent> )
##
InstallMethod( ExtraspecialGroupCons,
    "pc group",
    true,
    [ IsPcGroup and IsFinite,
      IsInt,
      IsObject ],
    0,

function( filters, order, exp )

    local i,        # loop variable
          p,        # divisor of group order
          n,        # the group has order 'p'^(2*'n'+1)
          eps1,     # constant to distinguish odd and even 'p'
          eps2,     # constant to distinguish odd and even 'p'
          name,     # name of generators (default is "e")
          z,        # central element
          f,        # free group
          r,        # relators
          e;        # the group generators

    p := Factors(order);

    if    Length(p) = 1
       or Length(p) mod 2 <> 1
       or Length(Set(p)) <> 1
    then
        Error( "order of an extraspecial group is",
               " a nonprime odd power of a prime" );
    fi;

    n := ( Length(p) - 1 ) / 2;
    p := p[1];

    # determine the required type of the group    
    if p = 2 then
        if n = 1 then
            eps1 := 1;
        else
            eps1 := 0;
        fi;

        # central product of 'n' dihedral groups of order 8
        if exp = '+' or exp = "+" then
            eps2 := 0;

        # central product of 'n'-1 dihedral groups and a quaternionic group
        elif exp = '-' or exp = "-" then
            eps2 := 1;

        # zap
        else
            Error( "<exp> must be '+', '-', \"+\", or \"-\"" );
        fi;
    else
        if exp = p   or exp = '+' or exp = "+" then
            eps1 := 0;
        elif exp = p^2 or exp = '-' or exp = "-" then
            eps1 := 1;
        else
            Error( "<exp> must be <p>, <p>^2, '+', '-', \"+\", or \"-\"" );
        fi;
        eps2 := 0;
    fi;

    f := FreeGroup(2*n+1);
    e := GeneratorsOfGroup(f);
    z := e[ 2*n+1 ];
    r := [];

    # power relators
    Add( r, e[1]^p / z^eps1 );
    for i  in [ 2 .. 2*n-2 ]  do
        Add( r, e[i]^p );
    od;
    if 1 < n  then
        Add( r, e[2*n-1]^p / z^eps2 );
    fi;
    Add( r, e[2*n]^p / z^eps2 );
    Add( r, z^p );

    # nontrivial commutator relators
    for i  in [ 1 .. n ]  do
        Add( r, Comm( e[2*i], e[2*i-1] ) * z );
    od;

    # return the Ag group
    return PolycyclicFactorGroup( f, r );

end );


#############################################################################
##
#M  SymmetricGroupCons( <IsPcGroup and IsFinite>, <deg> )
##
InstallMethod( SymmetricGroupCons,
    "pc group with degree",
    true,
    [ IsPcGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, deg )
    if 4 < deg  then
        Error( "<deg> must be at most 4" );
    fi;
    return GroupByPcgs(Pcgs(SymmetricGroupCons(IsPermGroup,[1..deg])));
end );


#############################################################################
##

#E  basicpc.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
