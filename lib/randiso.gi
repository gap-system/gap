#############################################################################
##
#W  randiso.gi                GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.randiso_gi :=
    "@(#)$Id$";

#############################################################################
##
#F OmegaAndLowerPCentralSeries( G )
##
InstallMethod( OmegaAndLowerPCentralSeries, 
               "omega and lower central", 
               true, 
               [IsPcGroup], 
               0,
function( G )
    local spec, first, i, ser1, ser2, ser3, pcgs, new, U, V, L, 
          pcgsU, pcgsL, pcgsUL, pcgsV, gensV, gens, N, sizes, j, I;

    # first get LG series
    spec  := InducedPcgsWrtSpecialPcgs( G );
    first := LGFirst( spec );
    ser1  := [G];
    for i in [2..Length(first)] do
        pcgs := InducedPcgsByPcSequenceNC( spec, 
                spec{[first[i]..Length(spec)]} );
        Add( ser1, SubgroupByPcgs( G, pcgs ) );
    od;

    # refine by Omega Series
    ser2 := OmegaSeries( G );
    new  := [G];
    sizes:= [Size(G)];
    for i in [1..Length(ser1)-1] do
        U := ser1[i]; 
        L := ser1[i+1];
        pcgsU := Pcgs(U);
        pcgsL := Pcgs(L);
        pcgsUL:= pcgsU mod pcgsL;
        if Length( pcgsUL ) > 1 then
            for j in [2..Length(ser2)-1] do
                gens := GeneratorsOfGroup( Intersection( U, ser2[j] ) );
                pcgs := InducedPcgsByPcSequenceAndGenerators( 
                        spec, pcgsL, gens );
                pcgs := CanonicalPcgs( pcgs );
                N    := SubgroupByPcgs( G, pcgs );
                if not Size(N) in sizes then
                    Add( new, N );
                    Add( sizes, Size(N) );
                fi;
            od;
            if not Size(L) in sizes then
                Add( new, L );
                Add( sizes, Size(L) );
            fi;
        else
            Add( new, L );
            Add( sizes, Size(L) );
        fi;
    od;

    # refine by p-central series
    ser1 := ShallowCopy( new );
    ser2 := PCentralSeries( G, RelativeOrders(Pcgs(G))[1] );
    new  := [G];
    sizes:= [Size(G)];
    for i in [1..Length(ser1)-1] do
        U := ser1[i];
        L := ser1[i+1];
        pcgsU := Pcgs(U);
        pcgsL := Pcgs(L);
        pcgsUL:= pcgsU mod pcgsL;
        if Length( pcgsUL ) > 1 then
            for j in [2..Length(ser2)-1] do
                gens := GeneratorsOfGroup( Intersection( U, ser2[j] ) );
                pcgs := InducedPcgsByPcSequenceAndGenerators( 
                        spec, pcgsL, gens );
                pcgs := CanonicalPcgs( pcgs );
                N    := SubgroupByPcgs( G, pcgs );
                if not Size(N) in sizes then
                    Add( new, N );
                    Add( sizes, Size(N) );
                fi;
            od;
            if not Size(L) in sizes then
                Add( new, L );
                Add( sizes, Size(L) );
            fi;
        else
            Add( new, L );
            Add( sizes, Size(L) );
        fi;
    od;
    return new;
end );


#############################################################################
##
#F RelatorsCode( <code>, <size>, <gens> )
##
RelatorsCode := function( code, size, gens )
    local F, n1, f, l, mi, n, t1, indices, rels, g, i, uc, ll, rr,
          t, j, z, z2;

    # get indices
    f    := FactorsInt( size );
    l    := Length( f );
    mi   := Maximum( f ) - 1;
    n    := ShallowCopy( code );
    if Length( Set( f ) ) > 1 then
        indices := CoefficientsMultiadic( List([1..l], x -> mi),
                       n mod (mi^l) ) + 2;
        n := QuoInt( n, mi^l );
    else
        indices := f;
    fi;
 
    # initialize relators
    rels := [];
    rr   := [];

    for i in [1..l] do
        rels[i]:=gens[i]^indices[i];
    od;

    ll:=l*(l+1)/2-1;
    if ll < 28 then
        uc := Reversed( CoefficientsMultiadic( List([1..ll], x -> 2 ),
                           n mod (2^ll) ) );
    else
        uc := [];
        n1 := n mod (2^ll);
           for i in [1..ll] do
               uc[i] := n1 mod 2;
                n1 := QuoInt( n1, 2 );
        od;
    fi;
    n := QuoInt( n,2^ll );

    for i in [1..Sum(uc)] do
        t := CoefficientsMultiadic( indices, n mod size );
        g := gens[1]^0;
        for j in [1..l] do
            if t[j] > 0 then 
                g := g * gens[j]^t[j];
            fi;
        od;
        Add( rr, g );
        n := QuoInt( n, size );
    od;
    z:=1;
    for i in [1..l-1] do
        if uc[i] = 1 then
            rels[i] := rels[i]/rr[z];
            z := z+1;
        fi;
    od;
    z2 := l-1;
    for i in [1..l] do
        for j in [i+1..l] do
            z2 := z2+1;
            if uc[z2] = 1 then
                Add( rels, Comm( gens[ j ], gens[ i ] ) / rr[ z ] );
                z := z+1;
            fi;
        od;
    od;

    return rels;
end;

#############################################################################
##
#F PcGroupCode( <code>, <size> )
##
PcGroupCode := function( code, size )
    local F, gens; 

    # catch trivial case
    if size = 1 then
        return Image( IsomorphismPcGroup( Group(()) ) );
    fi;

    # create free group
    F := FreeGroup( Length( FactorsInt( size ) ) );
    gens := GeneratorsOfGroup( F );

    # usual case
    return PcGroupFpGroup( F / RelatorsCode( code, size, gens ) );
end;

#############################################################################
##
#F PcGroup768Code( <code>, <nilp-type>, <auto>, <rank> )
##
PcGroup768Code := function( code, nilp, aut, rank )
    local F, gens, rels, i, j, tar, rel; 

    # create free group
    F := FreeGroup( 9 );
    gens := GeneratorsOfGroup( F );

    # usual case
    if nilp = -1 then
        return PcGroupFpGroup( F / RelatorsCode( code, 768, gens ) );
    fi;

    # nilpotent groups of size 768
    if nilp = 0 then
        rels := RelatorsCode( code, 256, gens{[ 1 .. 8 ]} );
        Add( rels, gens[ 9 ]^3 );
        return PcGroupFpGroup( F / rels );
    fi;

    if nilp = 2 then
        rels := RelatorsCode( code, 256, gens{[ 1 .. 8 ]} );
        Add( rels, gens[ 9 ]^3 );
        aut := CoefficientsMultiadic( List( [ 1 .. rank ], x -> 2 ), aut );
        for i in [ 1 .. rank ] do
            if aut[ i ] = 1 then
                Add( rels, Comm( gens[ 9 ], gens[ i ] ) / gens[ 9 ] );
            fi;
        od;
        return PcGroupFpGroup( F / rels );
    fi;

    # 3-nilpotent groups of size 768
    rels := RelatorsCode( code, 256, gens{[ 2 .. 9 ]} );
    Add( rels, gens[ 1 ]^3 );
    aut := CoefficientsMultiadic( [ 257,257,257,257,257,257,257,257 ], aut )
             - 1;
    for i in [ 1 .. 8 ] do
        tar := CoefficientsMultiadic( [ 2,2,2,2,2,2,2,2 ], aut[ i ] );
        rel := gens[ 1 ] ^ -1 * gens[ i + 1 ] ^ -1 * gens [ 1 ];
        for j in [ 1 .. 8 ] do
            if tar[ j ] = 1 then 
                rel := rel * gens[ j + 1 ];
            fi;
        od;
        Add( rels, rel );
    od;
    return PcGroupFpGroup( F / rels );

end;

#############################################################################
##
#F CodePcgs( <pcgs> ) 
##
CodePcgs := function( pcgs )
    local code, indices, l, mi, i, base, nt, r, j, e, size;

    # basic structures
    l := Length( pcgs );
    indices := RelativeOrders( pcgs );
    mi := Maximum( indices ) - 1;
    code := 0;
    base := 1;

    # code indices of ag-series for non-p-groups
    if Length( Set( indices ) ) > 1 then
        for i in Reversed( [ 1 .. l ] ) do
            code := code + base * ( indices[ i ] - 2 );
            base := base * mi;
        od;
    fi;

    #  code which powers are not trivial and collect values into nt
    nt := [];
    for i in [ 1 .. l - 1 ] do
        r := pcgs[ i ] ^ indices[ i ];
        if r <> OneOfPcgs( pcgs )  then
            Add( nt, r );
            code := code + base;
        fi;
        base := base * 2;
    od;

    # ... and commutators
    for i in [ 1 .. l - 1 ] do
        for j in [ i + 1 .. l ] do
            r := Comm( pcgs[ j ], pcgs[ i ] );
            if r <> OneOfPcgs( pcgs ) then
                Add( nt, r );
                code := code + base;
            fi;
            base := base * 2;
        od;
    od;

    # code now non-trivial words
    e := Enumerator( GroupOfPcgs( pcgs ) );
    size := Size( GroupOfPcgs( pcgs ) );
    for i in nt do
        code := code + base * (Position( e, i ) - 1 );
        base := base * size;
    od;
    return code;
end;

#############################################################################
##
#F CodePcGroup( <G> ) 
##
CodePcGroup := function( G )
    return CodePcgs( Pcgs( G ) );
end;

#############################################################################
##
#F PcGroupCodeRec( coderec )
##
PcGroupCodeRec := function( r )
    local H, pcgs, n;
    H := PcGroupCode( r.code, r.order );

    # add some information
    SetIsFrattiniFree( H, r.isFrattiniFree );

    pcgs := Pcgs(H);
    n    := Length( pcgs );
    SetFittingSubgroup( H, Subgroup( H, pcgs{[r.first[2]..n]} ) );
    SetFrattiniSubgroup( H, Subgroup( H, pcgs{[r.first[3]..n]} ) );

    if r.isFrattiniFree then
        SetSocle( H, Subgroup( H, pcgs{[r.first[2]..n]} ) );
        SetSocleComplement( H, Subgroup( H, pcgs{[1..r.first[2]-1]} ) );
    fi;

    SetIsNilpotentGroup( H, r.first[2]=1 );
    if not IsBool( r.socledim ) then
        SetIsSupersolvableGroup( H, ForAll( r.socledim, x -> x=1 ) );
    fi;
    return H;
end;

#############################################################################
##
#F RandomByPcs( pcs, p )
##
RandomByPcs := function( pcs, p )
    local elm;
    elm := List( [1..Length(pcs)], i -> pcs[i]^Random( 0, p-1 ) );
    return Product( elm );
end;

#############################################################################
##
#F IsLinearlyIndependent( g, p, pcgs, base )
##
IsLinearlyIndependent := function( g, p, pcgs, base )
    local vec, sol;
    vec := ExponentsOfPcElement( pcgs, g ) * One(GF(p));
    if Length( base ) = 0 then
        Add( base, vec );
        return true;
    fi;
    sol := SolutionMat( base, vec );
    if IsBool( sol ) then
        Add( base, vec );
        return true;
    else
        return false;
    fi;
end;

FindLayer := function( g, pcgss )
    local l;
    l := 1;
    while Sum( ExponentsOfPcElement( pcgss[l], g ) ) = 0 do
        l := l + 1;
    od;
    return l;
end;

#############################################################################
##
#F RandomPcgsSylowSubgroup( S, p )
##
RandomPcgsSylowSubgroup := function( S, p )
    local refin, n, subl, bases, pcgss, i, pcgsV, pcgsF, m, top, h, t, g, 
          l, list;

    # use omega series and lower p-central series
    refin := OmegaAndLowerPCentralSeries( S );
    n     := Length( refin );
 
    # set up 
    subl  := List( [1..n-1], x -> [] );
    bases := List( [1..n-1], x -> [] );
    pcgss := List( [1..n-1], x -> Pcgs( refin[x] ) mod Pcgs( refin[x+1] ) );
    
    # start to fill up sub
    for i in [1..n-1] do

        pcgsV := Pcgs( refin[i+1] );
        pcgsF := pcgss[i];
        m     := Length( pcgsF );
        top   := Length( subl[i] );

        while  top <> m do

            # get a non-trivial random element in F
            h := RandomByPcs( pcgsF, p );
            while h = Identity( S ) do
                h := RandomByPcs( pcgsF, p );
            od;

            # get a random element in V
            if Length( pcgsV ) > 0 then
                t := RandomByPcs( pcgsV, p );
            else
                t := Identity( S );
            fi;

            # the product is a random element in U \ V
            g := h * t;

            # check in and adjust top
            if IsLinearlyIndependent( h, p, pcgsF, bases[i] ) then
                Add( subl[i], g );
                top := top + 1;
            fi;
            
            # check in powers and commutators
            list := [g^p];
            Append( list, List( subl[i], x -> Comm(x,g) ) );

            for g in list do
                if g <> Identity(S) then
                    l := FindLayer( g, pcgss );
                    if IsLinearlyIndependent( g, p, pcgss[l], bases[l] ) then
                        Add( subl[l], g );
                    fi;
                fi;
            od;
        od;
    od;
    return Concatenation( subl );
end;

#############################################################################
##
#F RandomSpecialPcgsCoded( G )
##
RandomSpecialPcgsCoded := function( G )
    local pcgs, l, weights, first, primes, sylow, npcs, i, s, n, p, S,
          layer, sub, seq, pcgssys, ppcs, npcgs, pfirst, j, d, k;

    # compute the special pcgs
    pcgs := SpecialPcgs( G );
    l := Length( pcgs );

    # catch the trivial cases
    if l = 0 or l = 1 then return CodePcgs( pcgs ); fi;

    # information about special pcgs
    weights := LGWeights( pcgs );
    first   := LGFirst( pcgs );
    primes  := Set( List( weights, x -> x[3] ) );

    # compute public sylow system
    sylow := SylowSystem( G );

    # loop over sylow subgroups
    ppcs := List( primes, x -> true );
    for i in [1..Length(primes)] do
        p := primes[i];
        S := sylow[i];
        ppcs[i] := RandomPcgsSylowSubgroup( S, p );
    od;

    # loop over LG-series
    npcs := List( [1..Length(first)-1], x -> true );
    pfirst := List( primes, x -> [1] );
    for i in [1..Length(first)-1] do

        # relative to G
        s := first[i];
        n := first[i+1];
        p := weights[s][3];
        j := Position( primes, p );
        d := n - s;

        # relative to Sylow subgroup
        k := Length( pfirst[j] );
        Add( pfirst[j], pfirst[j][k] + d );
        s := pfirst[j][k];
        n := pfirst[j][k+1];
        
        # sift in
        npcs[i] := ppcs[j]{[s..n-1]};
    od;
    npcs := Concatenation( npcs );
        
    # compute corresponding special pcgs
    seq := PcgsByPcSequenceNC( FamilyObj( One( G ) ), npcs );
    pcgssys := rec( pcgs := seq,
                    weights := weights,
                    first := first,
                    layers := LGLayers( pcgs ) );
    pcgssys := PcgsSystemWithComplementSystem( pcgssys );
    seq := pcgssys.pcgs;
    SetRelativeOrders( seq, List( weights, x -> x[3] ) );

    # return code only
    return CodePcgs( seq );
end;

