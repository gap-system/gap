############################################################################
##
#W  chngpcp.gi                  Polycyc                         Bettina Eick
##
##  Algorithms to compute a new pcp groups whose defining pcp runs through
##  a given series or is a prime-infinite pcp.
##  

#############################################################################
##
#F RefinedIgs( <G> ) 
##
## returns a polycyclic generating sequence of G G with prime or infinite
## relative orders only. NOTE: this might be not induced!
##
RefinedIgs := function( G )
    local pcs, rel, ref, ord, map, i, f, g, j;

    # get old pcp
    pcs := Igs(G);
    rel := List( pcs, RelativeOrderPcp );

    # create new pcp
    ref := [];
    ord := [];
    map := [];
    for i in [1..Length(pcs)] do
        if rel[i] = 0 or IsPrime( rel[i] ) then
            Add( ref, pcs[i] );
            Add( ord, rel[i] );
        else
            f := Factors( rel[i] );
            g := pcs[i];
            for j in [1..Length(f)] do
                Add( ref, g );
                Add( ord, f[j] );
                g := g^f[j];
            od;
            map[i] := f;
        fi;
    od;
    return rec( pcs := ref, rel := ord, map := map );
end;

#############################################################################
##
#F RefinedPcpGroup( <G> ) . . . . . . . . refine to infinite or prime factors
##
## this function returns a new pcp group H isomorphic to G such that the 
## defining pcp of H is refined. H!.bijection contains the bijection between
## H and G.
##
# FIXME: This function is documented and should be turned into a GlobalFunction
RefinedPcpGroup := function( G )
    local refExponents, pcs, rel, new, ord, map, i, f, g, j, n, c, t, H, h;

    # refined exponents
    refExponents := function( pcs, g, map )
        local exp, new, i, c;
        exp := ExponentsByIgs( pcs, g );
        new := [];
        for i in [1..Length(exp)] do
            if IsBound( map[i] ) then
                c := CoefficientsMultiadic( Reversed(map[i]), exp[i] );
                Append( new, Reversed( c ) );
            else
                Add( new, exp[i] );
            fi;
        od;
        return new;
    end;

    # refined pcp
    pcs := Igs( G );
    new := RefinedIgs( G );
    ord := new.rel; 
    map := new.map; 
    new := new.pcs;

    # rewrite relations
    n := Length( new );
    c := FromTheLeftCollector( n );
    for i in [1..n] do

        # power
        if ord[i] > 0 then
            SetRelativeOrder( c, i, ord[i] );
            t := refExponents( pcs, new[i]^ord[i], map );
            SetPower( c, i, ObjByExponents(c, t) );
        fi;

        # conjugates
        for j in [1..i-1] do
            t := refExponents( pcs, new[i]^new[j], map );
            SetConjugate( c, i, j, ObjByExponents(c, t) );
            if ord[i] = 0 then
                t := refExponents( pcs, new[i]^(new[j]^-1), map );
                SetConjugate( c, i, -j, ObjByExponents(c, t) );
            fi;
        od;
    od;

    # create group and add a bijection
    H := PcpGroupByCollector( c );
    h := GroupHomomorphismByImagesNC( G, H, new, Igs(H) );
    H!.bijection := h;
    UseIsomorphismRelation( G, H );
    return H;
end;

#############################################################################
##
#F ExponentsByPcpList( pcps, g, k )
##
ExponentsByPcpList := function( pcps, g, k )
    local exp, pcp, e, f, h;
    h := g;
    exp := Concatenation( List(pcps{[1..k-1]}, x -> List(x, y -> 0) ) );
    for pcp in pcps{[k..Length(pcps)]} do
        e := ExponentsByPcp( pcp, h );
        if e <> 0*e then
            f := MappedVector( e, pcp );
            h := f^-1 * h;
        fi;
        Append( exp, e );
    od;
    if not h = h^0 then Error("wrong exponents"); fi;
    return exp;
end;

#############################################################################
##
#F PcpGroupByPcps( <pcps> ). . . . . . . . . . . . .  pcps is a list of pcp's
##
## This function returns a new pcp group G. Its defining igs corresponds to 
## the given series. G!.bijection contains a bijection from the old group
## to the new one.
##
PcpGroupByPcps := function( pcps )
    local gens, rels, n, coll, i, j, h, e, w, G, H;

    if Length( pcps ) = 0 then return fail; fi;

    gens := Concatenation( List( pcps, x -> GeneratorsOfPcp( x ) ) );
    rels := Concatenation( List( pcps, x -> RelativeOrdersOfPcp( x ) ) );
    n    := Length( gens );

    coll := FromTheLeftCollector( n );
    for i in [1..n] do
        if rels[i] > 0 then
            SetRelativeOrder( coll, i, rels[i] );
            h := gens[i] ^ rels[i];
            e := ExponentsByPcpList( pcps, h, 1 );
            w := ObjByExponents( coll, e );
            if Length( w ) > 0 then SetPower( coll, i, w ); fi;
        fi;
        for j in [1..i-1] do
            h := gens[i]^gens[j];
            e := ExponentsByPcpList( pcps, h, 1 );
            w := ObjByExponents( coll, e );
            if Length( w ) > 0 then SetConjugate( coll, i, j, w ); fi;
            if rels[j] = 0 then
                h := gens[i]^(gens[j]^-1);
                e := ExponentsByPcpList( pcps, h, 1 );
                w := ObjByExponents( coll, e );
                if Length( w ) > 0 then SetConjugate( coll, i, -j, w ); fi;
            fi;
        od;
    od;

    # return result
    H := GroupOfPcp( pcps[1] );
    G := PcpGroupByCollector( coll );
    G!.bijection := GroupHomomorphismByImagesNC( G, H, Igs(G), gens );
    SetKernelOfMultiplicativeGeneralMapping(G!.bijection, TrivialSubgroup(G));
    UseIsomorphismRelation( H, G );
    return G;
end;

#############################################################################
##
#F PcpGroupByEfaPcps( <pcps> ) . . . . . . . . . . .  pcps is a list of pcp's
##
## This function returns a new pcp group G. Its defining igs corresponds to 
## the given series. G!.bijection contains a bijection from the old group
## to the new one.
##
PcpGroupByEfaPcps := function( pcps )
    local gens, rels, indx, n, coll, i, j, h, e, w, G, H, l;

    l := Length(pcps);
    if l = 0 then return fail; fi;

    gens := Concatenation( List( pcps, x -> GeneratorsOfPcp( x ) ) );
    indx := Concatenation( List( [1..l], x -> List(pcps[x], y -> x) ));
    rels := Concatenation( List( pcps, x -> RelativeOrdersOfPcp( x ) ) );
    n    := Length( gens );

    coll := FromTheLeftCollector( n );
    for i in [1..n] do
        if rels[i] > 0 then
            SetRelativeOrder( coll, i, rels[i] );
            h := gens[i] ^ rels[i];
            e := ExponentsByPcpList( pcps, h, indx[i]+1 );
            w := ObjByExponents( coll, e );
            if Length( w ) > 0 then SetPower( coll, i, w ); fi;
        fi;
        for j in [1..i-1] do
            #Print(i," by ",j,"\n");
            h := gens[i]^gens[j];
            e := ExponentsByPcpList( pcps, h, indx[i] );
            w := ObjByExponents( coll, e );
            if Length( w ) > 0 then SetConjugate( coll, i, j, w ); fi;
            if rels[j] = 0 then
                h := gens[i]^(gens[j]^-1);
                e := ExponentsByPcpList( pcps, h, indx[i] );
                w := ObjByExponents( coll, e );
                if Length( w ) > 0 then SetConjugate( coll, i, -j, w ); fi;
            fi;
        od;
    od;

    # return result
    H := GroupOfPcp( pcps[1] );
    G := PcpGroupByCollector( coll );
    G!.bijection := GroupHomomorphismByImagesNC( G, H, Igs(G), gens );
    SetKernelOfMultiplicativeGeneralMapping(G!.bijection, TrivialSubgroup(G));
    UseIsomorphismRelation( H, G );
    return G;
end;

#############################################################################
##
#F PcpGroupBySeries( <ser>[, <flag>] ) 
##
## Computes a new pcp presentation through series. If two arguments are
## given, then the factors will be reduced to SNF.
##
# FIXME: This function is documented and should be turned into a GlobalFunction
PcpGroupBySeries := function( arg )
    local   ser,  r,  G,  pcps;

    # get arguments
    ser  := arg[1];
    r    := Length( ser ) - 1;

    # the trivial case
    if r = 0 then 
        G := ser[1];
        G!.bijection := IdentityMapping( G );
        return G;
    fi;

    # otherwise pass arguments on
    if Length( arg ) = 2 then 
        pcps := List( [1..r], i -> Pcp( ser[i], ser[i+1], "snf" ) );
    else
        pcps := List( [1..r], i -> Pcp( ser[i], ser[i+1] ) );
    fi;
    G := PcpGroupByPcps( pcps );
    UseIsomorphismRelation( ser[1], G );
    return G;
end;

#############################################################################
##
#F PcpGroupByEfaSeries(G)
##
InstallMethod( PcpGroupByEfaSeries, true, [IsPcpGroup], 0,
function(G)
    local efa, GG, iso, new;
    efa := EfaSeries(G);
    GG  := PcpGroupBySeries(efa);
    iso := GG!.bijection;
    new := List( efa, x -> PreImage(iso,x) );
    SetEfaSeries(GG, new);
    return GG;
end );

#############################################################################
##
#F ExponentsByPcpFactors( pcps, g )
##
ExponentsByPcpFactors := function( pcps, g )
    local red, exp, pcp, e;
    red := g;
    exp := [];
    for pcp  in pcps do
        e := ExponentsByPcp( pcp, red );
        if e <> 0 * e  then
            red := MappedVector(e,pcp)^-1 * red;
        fi;
        Append( exp, e );
    od;
    return exp;
end;

#############################################################################
##
#F PcpFactorByPcps( H, pcps )
##
PcpFactorByPcps := function(H, pcps)
    local  gens, rels, n, coll, i, j, h, e, w, G;

    # catch args
    gens := Concatenation(List(pcps, x -> GeneratorsOfPcp(x)));
    rels := Concatenation(List(pcps, x -> RelativeOrdersOfPcp(x)));
    n := Length( gens );

    # create new collector
    coll := FromTheLeftCollector( n );
    for i  in [ 1 .. n ]  do
        if rels[i] > 0  then
            SetRelativeOrder( coll, i, rels[i] );
            h := gens[i] ^ rels[i];
            e := ExponentsByPcpFactors( pcps, h );
            w := ObjByExponents( coll, e );
            if Length(w) > 0  then SetPower( coll, i, w ); fi;
        fi;
        for j  in [ 1 .. i - 1 ]  do
            h := gens[i] ^ gens[j];
            e := ExponentsByPcpFactors( pcps, h );
            w := ObjByExponents( coll, e );
            if Length(w) > 0  then SetConjugate( coll, i, j, w ); fi;
            if rels[j] = 0  then
                h := gens[i] ^ (gens[j] ^ -1);
                e := ExponentsByPcpFactors( pcps, h );
                w := ObjByExponents( coll, e );
                if Length(w) > 0  then SetConjugate( coll, i, - j, w ); fi;
            fi;
        od;
    od;

    # create new group
    return PcpGroupByCollector( coll );
end;

