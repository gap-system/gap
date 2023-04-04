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
##  This file  contains the methods  for  the construction  of the basic perm
##  group types.
##


#############################################################################
##
#M  TrivialGroupCons( <IsPermGroup> )
##
InstallMethod( TrivialGroupCons,
    "perm group",
    [ IsPermGroup and IsTrivial ],
    function( filter )
    return GroupByGenerators( [], () );
    end );


#############################################################################
##
#M  AbelianGroupCons( <IsPermGroup>, <ints> )
##
InstallMethod( AbelianGroupCons,
    "perm group",
    true,
    [ IsPermGroup and IsAbelian,
      IsList ],
    0,

function( filter, ints )
    local   grp,  grps;

    if IsEmpty( ints ) then
      # Create a group with empty list of generators
      return GroupWithGenerators( [], () );
    fi;
    if not ForAll( ints, IsInt )  then
        Error( "<ints> must be a list of integers" );
    fi;
    if not ForAll( ints, x -> 0 < x )  then
        TryNextMethod();
    fi;

    grps := List( ints, x -> CyclicGroupCons( IsPermGroup, x ) );
    # the way a direct product is constructed guarantees the right
    # generators (also generators of order 1)
    grp  := CallFuncList( DirectProduct, grps );
    SetSize( grp, Product(ints) );
    SetIsAbelian( grp, true );
    return grp;
end );


#############################################################################
##
#M  ElementaryAbelianGroupCons( <IsPermGroup>, <size> )
##
InstallMethod( ElementaryAbelianGroupCons, "perm group", true,
    [ IsPermGroup and IsElementaryAbelian, IsPosInt ],
    0,function(filter,size)

    local G;

    if size = 1 or IsPrimePowerInt( size )  then
        G := AbelianGroup( filter, Factors(size) );
    else
        Error( "<n> must be a prime power" );
    fi;
    SetIsElementaryAbelian( G, true );
    return G;
end);


#############################################################################
##
#M  AlternatingGroupCons( <IsPermGroup>, <deg> )
##
InstallMethod( AlternatingGroupCons,
    "perm group with degree",
    true,
    [ IsPermGroup and IsFinite,
      IsInt],
    0,

function( filter, deg )
    if deg<0 then TryNextMethod();fi;
    return AlternatingGroupCons( IsPermGroup, [ 1 .. deg ] );
end );


#############################################################################
##
#M  AlternatingGroupCons( <IsPermGroup>, <dom> )
##
InstallOtherMethod( AlternatingGroupCons,
    "perm group with domain",
    true,
    [ IsPermGroup and IsFinite,
      IsDenseList ],
    0,

function( filter, dom )
    local   alt,  dl,  g,  l;

    dom := Set(dom);
    IsRange( dom );
    if Length(dom) < 3  then
        alt := GroupByGenerators( [], () );
        SetSize(           alt, 1 );
        SetMovedPoints(    alt, [] );
        SetNrMovedPoints(  alt, 0 );
        SetIsPerfectGroup( alt, true );
    else
        if Length(dom) mod 2 = 0  then
            dl := dom{[ 1 .. Length(dom)-1 ]};
        else
            dl := dom;
        fi;
        g := [ MappingPermListList( dl, Concatenation( dl{[2..Length(dl)]},
                 [dl[1]] ) ) ];
        if 3 < Length(dom)  then
            l := Length(dom);
            Add( g, (dom[l-2],dom[l-1],dom[l]) );
        fi;
        alt := GroupByGenerators(g);
        if Length(dom)<5000 then
            SetSize( alt, Factorial(Length(dom))/2 );
        fi;
        SetMovedPoints( alt, dom );
        SetNrMovedPoints( alt, Length(dom) );
        if 4 < Length(dom)  then
            SetIsNonabelianSimpleGroup( alt, true );
        elif 2 < Length(dom)  then
            SetIsPerfectGroup( alt, false );
        fi;
        SetIsPrimitiveAffine( alt, Length( dom ) < 5 );
    fi;
    SetIsAlternatingGroup( alt, true );
    SetIsNaturalAlternatingGroup( alt, true );
    return alt;
end );

#############################################################################
##
#M  AlternatingGroupCons( <IsPermGroup and IsRegular>, <deg> )
##
InstallMethod( AlternatingGroupCons,
    "regular perm group with degree",
    true,
    [ IsPermGroup and IsRegular and IsFinite,
      IsInt],
    0,

function( filter, deg )
    if deg<0 then TryNextMethod();fi;
    return AlternatingGroupCons( IsPermGroup and IsRegular,
                                 [ 1 .. deg ] );
end );


#############################################################################
##
#M  AlternatingGroupCons( <IsPermGroup and IsRegular>, <dom> )
##
InstallOtherMethod( AlternatingGroupCons,
    "regular perm group with domain",
    true,
    [ IsPermGroup and IsRegular and IsFinite,
      IsDenseList ],
    0,

function( filter, dom )
    local   alt;

    alt := AlternatingGroupCons( IsPermGroup, dom );
    alt := Action( alt, AsList(alt), OnRight );
    SetIsAlternatingGroup( alt, true );
    return alt;
end );


#############################################################################
##
#M  CyclicGroupCons( <IsPermGroup and IsRegular>, <n> )
##
InstallMethod( CyclicGroupCons,
    "regular perm group",
    true,
    [ IsPermGroup and IsRegular and IsCyclic,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   g, c;

    g := PermList( Concatenation( [2..n], [1] ) );
    c := GroupByGenerators( [g] );
    SetSize( c, n );
    SetIsCyclic( c, true );
    if n > 1 then
        SetMinimalGeneratingSet (c, [g]);
    else
        SetMinimalGeneratingSet (c, []);
    fi;
    return c;
end );


#############################################################################
##
#M  DihedralGroupCons( <IsPermGroup>, <2n> )
##
InstallMethod( DihedralGroupCons,
    "perm. group",
    true,
    [ IsPermGroup, IsPosInt ], 0,
    function( filter, 2n )

    local D, g, h;
    if 2n = 2 then
      D:= GroupByGenerators( [ (1,2) ] );
    elif 2n = 4 then
      D := GroupByGenerators( [ (1,2), (3,4) ] );
    elif 2n mod 2 = 1 then
      TryNextMethod();
    else
      g:= PermList( Concatenation( [ 2 .. 2n/2 ], [ 1 ] ) );
      h:= PermList( Concatenation( [ 1 ], Reversed( [ 2 .. 2n/2 ] ) ) );
      D:= GroupByGenerators( [ g, h ] );
    fi;
    return D;
    end );

#############################################################################
##
#M  DicyclicGroupCons( <IsPermGroup>, <4n> )
##
InstallMethod( DicyclicGroupCons,
    "perm. group",
    true,
    [ IsPermGroup, IsPosInt ], 0,
function( filter, n )
  local y, z, x;
  if 0 <> n mod 4 then TryNextMethod(); fi;
  y := PermList( Concatenation( [2..n/2], [1], [n/2+2..n], [n/2+1] ) );
  x := PermList( Concatenation( Cycle( y^-1, [n/2+1..n], n/2+1 ), Cycle( y^-1, [1..n/2], n/4+1 ) ) );
  return Group(x,y);
end );


#############################################################################
##
#M  MathieuGroupCons( <IsPermGroup>, <degree> )
##
##  The returned permutation groups are compatible only in the following way.
##  $M_{23}$ is the stabilizer of the point $24$ in $M_{24}$.
##  $M_{21}$ is the stabilizer of the point $22$ in $M_{22}$.
##  $M_{11}$ is the stabilizer of the point $12$ in $M_{12}$.
##  $M_{10}$ is the stabilizer of the point $11$ in $M_{11}$.
##  $M_{9}$ is the stabilizer of the point $10$ in $M_{10}$.
##
InstallMethod( MathieuGroupCons,
    "perm group with degree",
    [ IsPermGroup and IsFinite, IsPosInt ],
    function( filter, degree )
    local M;

    # degree 9, base 1 2, indices 9 8
    if degree = 9  then
      M:= Group(
            (1,4,9,8)(2,5,3,6),
            (1,6,5,2)(3,7,9,8) );
      SetSize( M, 72 );

    # degree 10, base 1 2 3, indices 10 9 8
    elif degree = 10  then
      M:= Group(
            (1,9,6,7,5)(2,10,3,8,4),
            (1,10,7,8)(2,9,4,6) );
      SetSize( M, 720 );

    # degree 11, base 1 2 3 4, indices 11 10 9 8
    elif degree = 11  then
      M:= Group(
            (1,2,3,4,5,6,7,8,9,10,11),
            (3,7,11,8)(4,10,5,6) );
      SetSize( M, 7920 );
      SetIsNonabelianSimpleGroup( M, true );

    # degree 12, base 1 2 3 4 5, indices 12 11 10 9 8
    elif degree = 12  then
      M:= Group(
            (1,2,3,4,5,6,7,8,9,10,11),
            (3,7,11,8)(4,10,5,6),
            (1,12)(2,11)(3,6)(4,8)(5,9)(7,10) );
      SetSize( M, 95040 );
      SetIsNonabelianSimpleGroup( M, true );

    # degree 21, base 1 2 3 4, indices 21 20 16 3
    elif degree = 21  then
      M:= Group(
             (1,4,5,9,3)(2,8,10,7,6)(12,15,16,20,14)(13,19,21,18,17),
             (1,21,5,12,20)(2,16,3,4,17)(6,18,7,19,15)(8,13,9,14,11) );
      SetSize( M, 20160 );
      SetIsNonabelianSimpleGroup( M, true );

    # degree 22, base 1 2 3 4 5, indices 22 21 20 16 3
    elif degree = 22  then
      M:= Group(
            (1,2,3,4,5,6,7,8,9,10,11)(12,13,14,15,16,17,18,19,20,21,22),
            (1,4,5,9,3)(2,8,10,7,6)(12,15,16,20,14)(13,19,21,18,17),
            (1,21)(2,10,8,6)(3,13,4,17)(5,19,9,18)(11,22)(12,14,16,20) );
      SetSize( M, 443520 );
      SetIsNonabelianSimpleGroup( M, true );

    # degree 23, base 1 2 3 4 5 6, indices 23 22 21 20 16 3
    elif degree = 23  then
      M:= Group(
            (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23),
            (3,17,10,7,9)(4,13,14,19,5)(8,18,11,12,23)(15,20,22,21,16) );
      SetSize( M, 10200960 );
      SetIsNonabelianSimpleGroup( M, true );

    # degree 24, base 1 2 3 4 5 6 7, indices 24 23 22 21 20 16 3
    elif degree = 24  then
      M:= Group(
            (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23),
            (3,17,10,7,9)(4,13,14,19,5)(8,18,11,12,23)(15,20,22,21,16),
            (1,24)(2,23)(3,12)(4,16)(5,18)(6,10)(7,20)(8,14)(9,21)(11,17)
            (13,22)(19,15) );
      SetSize( M, 244823040 );
      SetIsNonabelianSimpleGroup( M, true );

    # error
    else
        Error("degree <d> must be 9, 10, 11, 12, 21, 22, 23, or 24" );
    fi;

    return M;
    end );


#############################################################################
##
#M  SymmetricGroupCons( <IsPermGroup>, <deg> )
##
InstallMethod( SymmetricGroupCons,
    "perm group with degree",
    true,
    [ IsPermGroup and IsFinite,
      IsInt ],
    0,

function( filter, deg )
    if deg<0 then TryNextMethod();fi;
    return SymmetricGroupCons( IsPermGroup, [ 1 .. deg ] );
end );


#############################################################################
##
#M  SymmetricGroupCons( <IsPermGroup>, <dom> )
##
InstallOtherMethod( SymmetricGroupCons,
    "perm group with domain",
    true,
    [ IsPermGroup and IsFinite,
      IsDenseList ],
    0,

function( filters, dom )
    local   sym,  g;

    dom := Set(dom);
    IsRange( dom );
    if Length(dom) < 2  then
        sym := GroupByGenerators( [], () );
        SetSize(           sym, 1 );
        SetMovedPoints(    sym, [] );
        SetNrMovedPoints(  sym, 0 );
        SetIsPerfectGroup( sym, true );
    else
        g := [ MappingPermListList( dom, Concatenation(
                 dom{[2..Length(dom)]}, [ dom[1] ] ) ) ];
        if 2 < Length(dom)  then
            Add( g, ( dom[1], dom[2] ) );
        fi;
        sym := GroupByGenerators( g );
        if Length(dom)<5000 then
            SetSize( sym, Factorial(Length(dom)) );
        fi;
        SetMovedPoints(    sym, dom );
        SetNrMovedPoints(  sym, Length(dom) );
        SetIsPerfectGroup( sym, false );
    fi;
    SetIsPrimitiveAffine( sym, Length( dom ) < 5 );
    SetIsSymmetricGroup( sym, true );
    SetIsNaturalSymmetricGroup( sym, true );
    return sym;
end );


#############################################################################
##
#M  SymmetricGroupCons( <IsPermGroup and IsRegular>, <deg> )
##
InstallMethod( SymmetricGroupCons,
    "regular perm group with degree",
    true,
    [ IsPermGroup and IsRegular and IsFinite,
      IsInt],
    0,

function( filter, deg )
    if deg<0 then TryNextMethod();fi;
    return SymmetricGroupCons( IsPermGroup and IsRegular,
                               [ 1 .. deg ] );
end );


#############################################################################
##
#M  SymmetricGroupCons( <IsPermGroup and IsRegular>, <dom> )
##
InstallOtherMethod( SymmetricGroupCons,
    "regular perm group with domain",
    true,
    [ IsPermGroup and IsRegular and IsFinite,
      IsDenseList ],
    0,

function( filter, dom )
    local   alt;

    alt := SymmetricGroupCons( IsPermGroup, dom );
    alt := Action( alt, AsList(alt), OnRight );
    SetIsSymmetricGroup( alt, true );
    return alt;
end );
