#############################################################################
## for the collector
InstallMethod( RelativeOrders, 
               true,
               [ IsFromTheLeftCollectorRep ],
               0,
function( pcp ) 
    return pcp![PC_EXPONENTS];
end );

#############################################################################
## ok
NormalFormByPcp := function( pcp, g )
    local h, k;
    h := ObjByExponents( pcp, g );
    k := List( g, x -> 0 );
    CollectWordOrFail( pcp, k, h );
    return k;
end;

#############################################################################
## ok
PcpElementByExponentsNC := function( coll, list )
    local elm, fam;
    elm := rec( collector := coll,
                exponents := list,
                name := "g" );
    fam := coll![PC_PCP_ELEMENTS_FAMILY];
    return Objectify( NewType( fam, IsPcpElementRep ), elm );
end;

PcpElementByExponents := function( coll, list )
    return PcpElementByExponentsNC( coll, NormalFormByPcp( coll, list ) );
end; 

PcpElementByWordNC := function( coll, list )
    local exp, i, elm, fam;
    exp := List( [1..coll![PC_NUMBER_OF_GENERATORS]], x -> 0 );
    for i in [1,3..Length(list)-1] do
        exp[list[i]] := list[i+1];
    od; 
    elm := rec( collector := coll,
                exponents := exp,
                name := "g" );
    fam := coll![PC_PCP_ELEMENTS_FAMILY];
    return Objectify( NewType( fam, IsPcpElementRep ), elm );
end;

PcgsOfPcp := function( pcp )
    local n, id;
    n := pcp![PC_NUMBER_OF_GENERATORS];
    id := IdentityMat( n );
    return List( [1..n], x -> PcpElementByExponentsNC( pcp, id[x] ) );
end;

OneOfPcp := function( pcp )
    local n;
    n := pcp![PC_NUMBER_OF_GENERATORS];
    return PcpElementByExponentsNC( pcp, List( [1..n], x -> 0 ) );
end;

#############################################################################
## ok
Exponents := function( elm ) return elm!.exponents; end;
Collector := function( elm ) return elm!.collector; end;
NameTag   := function( elm ) return elm!.name; end;

Depth := function( g )
    local i, e;
    e := Exponents( g );
    for i in [1..Length(e)] do
        if e[i] <> 0 then
            return i;
        fi;
    od;
    return Length(e) + 1;
end;

LeadingExponent := function( g )
    local i, e;
    e := Exponents( g );
    for i in [1..Length(e)] do
        if e[i] <> 0 then
            return e[i];
        fi;
    od;
    return fail;
end;

RelativeOrder := function( g )
    local d, r;
    d   := Depth( g );
    r   := RelativeOrders( Collector(g) );
    if IsBound( r[d] ) then 
        return r[d] / Gcd( r[d], LeadingExponent(g) );
    elif d <= Length( PcgsOfPcp( Collector( g ) ) ) then
       return infinity;
    else
       return fail;
    fi;
end;

NormedPcpElement := function( g )
    local c, r, d, l, e, f;

    c := Collector( g );
    r := RelativeOrders( c );
    d := Depth( g );
    l := LeadingExponent( g );
    if not IsBound( r[d] ) then 
        if l < 0 then 
            return g^-1;
        else
            return g; 
        fi;
    fi;

    e := Gcd( r[d], l );
    f := (l/e )^-1 mod (r[d] / e);

    return g^f;
end;

#############################################################################
## ok
InstallMethod( PrintObj, 
               "for pcp elements", 
               true, 
               [IsPcpElement], 
               0,
function( elm )
    local g, l, e, d;
    g := NameTag( elm );
    e := Exponents( elm );
    d := Depth( elm );
    if d > Length( e ) then
        Print("identity");
    elif e[d] = 1 then
        Print(g,d);
    else
        Print(g,d,"^",e[d]);
    fi;
    for l in [d+1..Length(e)] do
        if e[l] = 1 then
            Print("*",g,l);
        elif e[l] <> 0 then
            Print("*",g,l,"^",e[l]);
        fi;
    od;
end );
 
#############################################################################
## ok
InstallMethod( \*,
               "for pcp elements", 
               true, 
               [IsPcpElement, IsPcpElement], 
               0,
function( g1, g2 )
    local e, f;
    e  := ShallowCopy( Exponents( g1 ) );
    f  := ObjByExponents( Collector( g2 ),  Exponents( g2 ) );
    CollectWordOrFail( Collector( g1 ), e, f );
    return PcpElementByExponentsNC( Collector( g1 ), e );
end );
       
#############################################################################
## ok
InstallMethod( Inverse,
               "for pcp elements", 
               true, 
               [IsPcpElement], 
               0,
function( g )
    local k, h;
    h := ObjByExponents( Collector( g ), Exponents( g ) );
    k := FromTheLeftCollector_Inverse( Collector(g), h );
    return PcpElementByWordNC( Collector(g), k );
end );

InstallMethod( INV,
               "for pcp elements", 
               true, 
               [IsPcpElement], 
               0,
function( g )
    local k;
    k := FromTheLeftCollector_Inverse( Collector(g), 
         ObjByExponents( Collector(g), Exponents(g) ));
    return PcpElementByWordNC( Collector(g), k );
end );

#############################################################################
## ok
InstallMethod( \^,
               "for pcp elements", 
               true, 
               [IsPcpElement, IsInt], 
               0,
function( g, d )
    local h, i, k;
    if d = 0 then 
        return OneOfPcp( Collector( g ) );
    elif d = 1 then 
        return g;
    fi;

    if d < 0 then
        k := Inverse(g);
        d := -d;
    else
        k := ShallowCopy(g);
    fi;
    h := k;
    for i in [2..d] do
        h := h * k;
    od;
    return h;
end );

#############################################################################
## ok
InstallMethod( \=,
               "for pcp elements", 
               true, 
               [IsPcpElement, IsPcpElement],
               0,
function( g, h )
    return Exponents( g ) = Exponents( h );
end );

#############################################################################
## ok
InstallMethod( \<,
               "for pcp elements", 
               true, 
               [IsPcpElement, IsPcpElement],
               0,
function( g, h )
    return Exponents( g ) < Exponents( h );
end );

