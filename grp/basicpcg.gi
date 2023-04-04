#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for the construction of the basic pc group
##  types.
##


#############################################################################
##
#M  TrivialGroupCons( <IsPcGroup> )
##
InstallMethod( TrivialGroupCons,
    "pc group",
    [ IsPcGroup and IsTrivial ],
    function( filter )
    filter:= CyclicGroup( IsPcGroup, 1 );
    SetIsTrivial( filter, true );
    return filter;
    end );


#############################################################################
##
#M  AbelianGroupCons( <IsPcGroup and IsFinite>, <ints> )
##
InstallMethod( AbelianGroupCons, "pc group", true,
    [ IsPcGroup and IsAbelian, IsList ], 0,
function( filter, ints )
local   pis,  f,  g,  r,  k,  pi,  i,  geni,  j,  name,  ps;

    if not ForAll( ints, IsInt )  then
        Error( "<ints> must be a list of integers" );
    fi;
    if not ForAll( ints, x -> 0 < x )  then
      TryNextMethod();
    fi;
    if ForAll(ints,i->i=1) then
      # the stupid trivial group case
      g:= CyclicGroup( IsPcGroup, 1 );
      if Length( ints ) > 0 then
        g:= GroupWithGenerators(
                ListWithIdenticalEntries( Length( ints ), One( g ) ) );
      fi;
      return g;
    fi;

    pis := List( ints, Factors );
    f   := FreeGroup( IsSyllableWordsFamily,
             Sum( List(pis{Filtered([1..Length(pis)],i->ints[i]>1)},
                  Length ) ) );
    g   := GeneratorsOfGroup(f);
    r   := [];
    k   := 1;
    geni:=[];
    for pi  in pis  do
      if pi[1]=1 then
        Add(geni,0);
      else
        Add(geni,k);
        for i  in [ 1 .. Length(pi)-1 ]  do
            Add( r, g[k]^pi[i] / g[k+1] );
            k := k + 1;
        od;
        Add( r, g[k]^pi[Length(pi)] );
        k := k + 1;
      fi;
    od;
    f := PolycyclicFactorGroupNC( f, r:noconfluencetest );
    SetSize( f, Product(ints) );
    SetIsAbelian( f, true );

    k:=[];
    g:=GeneratorsOfGroup(f);
    for i in geni do
      if i=0 then
        Add(k,One(f));
      else
        Add(k,g[i]);
      fi;
    od;
    k:=GroupWithGenerators(k,One(f));
    SetSize(k,Size(f));
    SetIsAbelian( k, true );

    if Size(Set(Filtered(Flat(pis),p->p<>1))) = 1 then
        SetIsPGroup( k, true );
        SetPrimePGroup( k, First(Flat(pis),p -> p<>1) );
    fi;

    pis := [ ];
    ps := [ ];
    for i in ints do
      pi := PrimePowersInt( i );
      for j in [ 1, 3 .. Length( pi ) - 1 ] do
        if pi[ j ] in ps then
          SetIsCyclic( k, false );
        fi;
        AddSet( ps, pi[ j ] );
        Add( pis, pi[ j ] ^ pi[ j + 1 ] );
      od;
    od;
    if not HasIsCyclic( k ) then
      SetIsCyclic( k, true );
      return k;
    fi;
    Sort( pis );
    SetAbelianInvariants( k, pis );
    return k;
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
    [ IsPcGroup and IsCyclic,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   pi,  f,  g,  r,  i;

    # Catch the case n = 1.
    if n = 1 then
        f := GroupByRws( SingleCollector( FreeGroup( 0 ), [] ) );
        SetMinimalGeneratingSet (f, []);

    else
        pi := Factors( n );
        f  := FreeGroup( IsSyllableWordsFamily, Length(pi) );
        g  := GeneratorsOfGroup(f);
        r  := [];
        for i  in [ 1 .. Length(g)-1 ]  do
            Add( r, g[i]^pi[i] / g[i+1] );
        od;
        Add( r, g[Length(g)] ^ pi[Length(g)] );
        f := PolycyclicFactorGroupNC( f, r );
        if Size(Set(pi)) = 1 then
            SetIsPGroup( f, true );
            SetPrimePGroup( f, pi[1] );
        fi;
        SetMinimalGeneratingSet (f, [f.1]);
    fi;

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
    elif n = 2 then return
        CyclicGroup( IsPcGroup, 2 );
    fi;
    pi := Factors(n/2);
    f  := FreeGroup( IsSyllableWordsFamily, Length(pi)+1 );
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
    f := PolycyclicFactorGroupNC( f, r );
    SetSize( f, n );
    if n = 2^LogInt(n,2) then
        SetIsPGroup( f, true );
        SetPrimePGroup( f, 2 );
    fi;
    return f;
end );


#############################################################################
##
#M  DicyclicGroupCons( <IsPcGroup and IsFinite>, <n> )
##
InstallMethod( DicyclicGroupCons,
    "pc group",
    true,
    [ IsPcGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
  local k, d, relords, powers, gens, f, rels, pow;
  if 0 <> n mod 4 then TryNextMethod(); fi;
  # Hard to get a confluent RWS for a cyclic group on 2 independent generators
  if n = 4 then return CyclicGroup( filter, n ); fi;
  k := n/4;
  d := Factors( k );
  relords := [2];
  Append(relords, d);
  Add( relords, 2 );
  powers := [0];
  Append( powers, List( [0..Size(d)], i -> Product( d{[1..i]} ) ) );
  gens := Concatenation( [ "x", "y" ], List( powers{[3..Size(powers)]}, d -> Concatenation( "y", String(d) ) ) );
  f := FreeGroup( IsSyllableWordsFamily, gens );
  pow := function( i )
    local e, j;
    i := i mod (n/2);
    e := [0];
    for j in [2..Size(relords)] do
      e[j] := i mod relords[j];
      i := Int( i / relords[j] );
    od;
    return Product([1..Size(e)],i->f.(i)^e[i]);
  end;
  rels := [ [ f.1^2, f.(Size(gens)) ], [ f.(Size(gens))^2, One(f) ] ];
  Append( rels, List( [2..Size(gens)-1], i -> [ f.(i)^relords[i], f.(i+1) ] ) );
  Append( rels, List( [2..Size(gens)-1], i -> [ f.(i)^f.1, pow(-powers[i]) ] ) );
  Append( rels, List( Combinations( [2..Size(gens)], 2 ), ij -> [ f.(ij[2])^f.(ij[1]), f.(ij[2]) ] ) );
  return PcGroupFpGroupNC( f / List( rels, rel -> rel[1]/rel[2] ) );
end );


#############################################################################
##
#M  ElementaryAbelianGroupCons( <IsPcGroup and IsFinite>, <n> )
##
InstallMethod( ElementaryAbelianGroupCons,
    "pc group",
    true,
    [ IsPcGroup and IsElementaryAbelian,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    if n = 1  then
        return CyclicGroupCons( IsPcGroup, 1 );
    elif not IsPrimePowerInt(n)  then
        Error( "<n> must be a prime power" );
    fi;
    n:= AbelianGroupCons( IsPcGroup, Factors(n) );
    SetIsElementaryAbelian( n, true );
    return n;
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

    f := FreeGroup( IsSyllableWordsFamily, 2*n+1);
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

    # return the pc group
    f := PolycyclicFactorGroupNC( f, r );
    SetIsPGroup( f, true );
    SetPrimePGroup( f, p );
    return f;

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
