#############################################################################
##
#W  basicprm.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains the methods  for  the construction  of the basic perm
##  group types.
##
Revision.basicprm_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  AbelianGroupCons( <IsPermGroup>, <ints> )
##
InstallMethod( AbelianGroupCons,
    "perm group",
    true,
    [ IsPermGroup and IsFinite,
      IsList ],
    0,

function( filter, ints )
    local   grp;

    if not ForAll( ints, IsInt )  then
        Error( "<ints> must be a list of integers" );
    fi;
    if not ForAll( ints, x -> 0 < x )  then
        TryNextMethod();
    fi;

    ints := Filtered( ints, x -> 1 < x );
    ints := List( ints, x -> CyclicGroupCons( IsPermGroup, x ) );
    grp  := CallFuncList( DirectProduct, ints );
    SetSize( grp, Product(ints) );
    SetIsAbelian( grp, true );
    return grp;
end );


#############################################################################
##
#M  AlternatingGroupCons( <IsPermGroup>, <deg> )
##
InstallMethod( AlternatingGroupCons,
    "perm group with degree",
    true,
    [ IsPermGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, deg )
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
    if Length(dom) < 3  then
        alt := Group( () );
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
        SetSize( alt, Factorial(Length(dom))/2 );
        SetMovedPoints( alt, dom );
        SetNrMovedPoints( alt, Length(dom) );
        if 4 < Length(dom)  then
            SetIsSimpleGroup(  alt, true );
            SetIsPerfectGroup( alt, true );
        elif 2 < Length(dom)  then
            SetIsSimpleGroup(  alt, false );
            SetIsPerfectGroup( alt, false );
        fi;
        Setter( IsPrimitiveAffineProp )( alt, Length( dom ) < 5 );
    fi;
    SetIsAlternatingGroup( alt, true );
    SetIsNaturalAlternatingGroup( alt, true );
    IsRange( dom );
    SetName( alt, Concatenation( "Alt", String( dom ) ) );
    return alt;
end );

#############################################################################
##
#M  AlternatingGroupCons( <IsPermGroup and IsRegularProp>, <deg> )
##
InstallMethod( AlternatingGroupCons,
    "regular perm group with degree",
    true,
    [ IsPermGroup and IsRegularProp and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, deg )
    return AlternatingGroupCons( IsPermGroup and IsRegularProp,
                                 [ 1 .. deg ] );
end );


#############################################################################
##
#M  AlternatingGroupCons( <IsPermGroup and IsRegularProp>, <dom> )
##
InstallOtherMethod( AlternatingGroupCons,
    "regular perm group with domain",
    true,
    [ IsPermGroup and IsRegularProp and IsFinite,
      IsDenseList ],
    0,

function( filter, dom )
    local   alt;

    alt := AlternatingGroupCons( IsPermGroup, dom );
    alt := Operation( alt, AsList(alt), OnRight );
    SetIsAlternatingGroup( alt, true );
    return alt;
end );


#############################################################################
##
#M  CyclicGroupCons( <IsPermGroup and IsRegularProp>, <n> )
##
InstallMethod( CyclicGroupCons,
    "regular perm group",
    true,
    [ IsPermGroup and IsRegularProp and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   c;

    c := Group( PermList( Concatenation( [2..n], [1] ) ) );
    SetSize( c, n );
    SetIsCyclic( c, true );
    return c;
end );


#############################################################################
##
#M  SymmetricGroupCons( <IsPermGroup>, <deg> )
##
InstallMethod( SymmetricGroupCons,
    "perm group with degree",
    true,
    [ IsPermGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, deg )
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
    if Length(dom) < 2  then
        sym := Group( () );
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
        SetMovedPoints(   sym, dom );
        SetNrMovedPoints( sym, Length(dom) );
    fi;
    Setter( IsPrimitiveAffineProp )( sym, Length( dom ) < 5 );
    SetIsSymmetricGroup( sym, true );
    SetIsNaturalSymmetricGroup( sym, true );
    IsRange( dom );
    SetName( sym, Concatenation( "Sym", String( dom ) ) );
    return sym;
end );


#############################################################################
##
#M  SymmetricGroupCons( <IsPermGroup and IsRegularProp>, <deg> )
##
InstallMethod( SymmetricGroupCons,
    "regular perm group with degree",
    true,
    [ IsPermGroup and IsRegularProp and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, deg )
    return SymmetricGroupCons( IsPermGroup and IsRegularProp,
                               [ 1 .. deg ] );
end );


#############################################################################
##
#M  SymmetricGroupCons( <IsPermGroup and IsRegularProp>, <dom> )
##
InstallOtherMethod( SymmetricGroupCons,
    "regular perm group with domain",
    true,
    [ IsPermGroup and IsRegularProp and IsFinite,
      IsDenseList ],
    0,

function( filter, dom )
    local   alt;

    alt := SymmetricGroupCons( IsPermGroup, dom );
    alt := Operation( alt, AsList(alt), OnRight );
    SetIsSymmetricGroup( alt, true );
    return alt;
end );


#############################################################################
##

#M  IsNaturalAlternatingGroup( <sym> )
##
InstallMethod( IsNaturalAlternatingGroup,
    "size comparison",
    true,
    [ IsPermGroup ],
    0,

function( alt )
    if 0 = NrMovedPoints(alt)  then
        return IsTrivial(alt);
    else
        return Size(alt) * 2 = Factorial( NrMovedPoints(alt) );
    fi;
end );


#############################################################################
##
#M  IsNaturalSymmetricGroup( <sym> )
##
InstallMethod( IsNaturalSymmetricGroup,
    "size comparison",
    true,
    [ IsPermGroup ],
    0,

function( sym )
    return Size(sym) = Factorial( NrMovedPoints(sym) );
end );


#############################################################################
##
#M  <perm> in <nat-sym-grp>
##
InstallMethod( \in,
    true,
    [ IsPerm,
      IsNaturalSymmetricGroup ],
    0,

function( g, S )
    local   m,  l;

    m := MovedPoints(S);
    l := NrMovedPoints(S);
    
    if g = One( g )  then
        return true;
    elif l = 0  then
        return false;
    elif IsRange(m) and ( l = 1 or m[2] - m[1] = 1 )  then
        return SmallestMovedPointPerm(g) >= m[1]
           and LargestMovedPointPerm(g)  <= m[l];
    else
        return IsSubset( m, MovedPointsPerms([g]) );
    fi;
end );


#############################################################################
##
#M  Size( <nat-sym-grp> )
##
InstallMethod( Size,
    true,
    [ IsNaturalSymmetricGroup ],
    0,
    sym -> Factorial( NrMovedPoints(sym) ) );


#############################################################################
##
#M  StabilizerOp( <nat-sym-grp>, <int>, OnPoints )
##
InstallOtherMethod( StabilizerOp,
    true,
    [ IsNaturalSymmetricGroup, IsPosRat and IsInt, IsFunction ],
    0,

function( sym, p, opr )
    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    return AsSubgroup( sym,
           SymmetricGroup( Difference( MovedPoints( sym ), [ p ] ) ) );
end );

#############################################################################
##
#M  PrintObj( <nat-sym-grp> )
##
InstallMethod( PrintObj,
    true,
    [ IsNaturalSymmetricGroup ],
    0,

function(sym)
    Print( "Sym( ", MovedPoints(sym), " )" );
end );


#############################################################################
##

#E  basicperm.gd  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
