#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#F FingerprintFF( G )
##
BindGlobal( "FingerprintFF", function( G )
    local orb, ord, res, po, i, typ;

    res := [ ];
    for orb in OrbitsDomain( G, AsList( G ) ) do
        ord := Order( orb[ 1 ] );
        typ := [ ord, Length( orb ) ];
        po := PrimeDivisors( ord );
        i := 1;
        repeat
            if not Primes[ i ] in po then
                Add( typ, orb[ 1 ] ^ Primes[ i ]  in orb );
            fi;
            i := i + 1;
        until Primes[ i ] > ord or i > 10;
        Add( res, typ );
    od;
    res := Collected( res );
    if Size( G ) mod 64 = 0 and Size( G ) mod 512 <> 0 then
        Add( res, IdGroup( SylowSubgroup( G, 2 ) )[ 2 ] );
    fi;
    if Size( G ) mod 81 = 0 and Size( G ) mod 2187 <> 0 then
        Add( res, IdGroup( SylowSubgroup( G, 3 ) )[ 2 ] );
    fi;
    return Flat( res );
end );

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
    local spec, first, i, ser1, ser2, pcgs, new, U, L,
          pcgsU, pcgsL, pcgsUL, gens, N, sizes, j;

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

InstallMethod( OmegaAndLowerPCentralSeries,
  "general case: warn that no method available",true,[IsGroup],0,
function(G)
  Error("sorry, group identification is currently only",
        " available for pc groups.");
end);


#############################################################################
##
#F RelatorsCode( <code>, <size>, <gens> )
##
BindGlobal( "RelatorsCode", function( code, size, gens )
    local n1, f, l, mi, n, indices, rels, g, i, uc, ll, rr,
          t, j, z, z2;

    # get indices
    f    := Factors(Integers, size );
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
end );

#############################################################################
##
#F PcGroupCode( <code>, <size> )
##
InstallGlobalFunction( PcGroupCode, function( code, size )
    local F, gens;

    # catch trivial case
    if size = 1 then
        return Image( IsomorphismPcGroup( GroupByGenerators( [], () ) ) );
    fi;

    # create free group
    F := FreeGroup(IsSyllableWordsFamily, Length( Factors(Integers, size ) ) );
    gens := GeneratorsOfGroup( F );

    # usual case
    return PcGroupFpGroup( F / RelatorsCode( code, size, gens ) );
end );

#############################################################################
##
#F CodePcgs( <pcgs> )
##
InstallGlobalFunction( CodePcgs, function( pcgs )
    local code, indices, l, mi, i, base, nt, r, j, size;

    # basic structures
    l := Length( pcgs );
    if l = 0 then
      return 0;
    fi;
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
    indices := List( [ 1 .. l ], x-> Product( indices{[ x + 1 .. l ]} ) );
    size := Size( GroupOfPcgs( pcgs ) );
    for i in nt do
        code := code + base * ( indices * ExponentsOfPcElement( pcgs, i ) );
        base := base * size;
    od;
    return code;
end );

#############################################################################
##
#F CodePcGroup( <G> )
##
InstallGlobalFunction( CodePcGroup, function( G )
    return CodePcgs( Pcgs( G ) );
end );

#############################################################################
##
#F PcGroupCodeRec( coderec )
##
InstallGlobalFunction( PcGroupCodeRec, function( r )
    local H, pcgs, n;
    H := PcGroupCode( r.code, r.order );

    # add some information
    if IsBound( r.isFrattiniFree ) then
        SetIsFrattiniFree( H, r.isFrattiniFree );
    fi;

    if IsBound( r.first ) then
        pcgs := Pcgs(H);
        n    := Length( pcgs );
        SetFittingSubgroup( H, Subgroup( H, pcgs{[r.first[2]..n]} ) );
        SetFrattiniSubgroup( H, Subgroup( H, pcgs{[r.first[3]..n]} ) );

        if r.isFrattiniFree then
            SetSocle( H, Subgroup( H, pcgs{[r.first[2]..n]} ) );
            SetSocleComplement( H, Subgroup( H, pcgs{[1..r.first[2]-1]} ) );
        fi;

        SetIsNilpotentGroup( H, r.first[2]=1 );
        if not IsBool( r.socledim ) and
           not HasIsSupersolvableGroup( H ) then
            SetIsSupersolvableGroup( H, ForAll( r.socledim, x -> x=1 ) );
        fi;
    fi;
    return H;
end );

#############################################################################
##
#F RandomByPcs( pcs, p )
##
BindGlobal( "RandomByPcs", function( pcs, p )
    local elm;
    elm := List( [1..Length(pcs)], i -> pcs[i]^Random( 0, p-1 ) );
    return Product( elm );
end );

#############################################################################
##
#F IsLinearlyIndependent( g, p, pcgs, base )
##
BindGlobal( "IsLinearlyIndependent", function( g, p, pcgs, base )
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
end );

BindGlobal( "FindLayer", function( g, pcgss )
    local l;
    l := 1;
    while Sum( ExponentsOfPcElement( pcgss[l], g ) ) = 0 do
        l := l + 1;
    od;
    return l;
end );

#############################################################################
##
#F RandomPcgsSylowSubgroup( S, p )
##
BindGlobal( "RandomPcgsSylowSubgroup", function( S, p )
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
end );

#############################################################################
##
#F RandomSpecialPcgsCoded( G )
##
## Returns a random code defining a special pcgs of <G>.
InstallGlobalFunction( RandomSpecialPcgsCoded, function( G )
    local pcgs, l, weights, first, primes, sylow, npcs, i, s, n, p, S,
          seq, pcgssys, ppcs, pfirst, j, d, k;

    # compute the special pcgs
    pcgs := SpecialPcgs( G );
    l := Length( pcgs );

    # catch the trivial cases
    if l = 0 or l = 1 then return CodePcgs( pcgs ); fi;

    # information about special pcgs
    weights := LGWeights( pcgs );
    first   := LGFirst( pcgs );
    primes  := Set( weights, x -> x[3] );

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
end );

#############################################################################
##
#F RandomIsomorphismTest( list, n )
##
InstallGlobalFunction( RandomIsomorphismTest, function( list, n )
    local codes, conds, code, found, i, j, k, l, rem, c;

    # catch trivial case
    if Length( list ) = 1 or Length( list ) = 0 then return list; fi;

    # unpack
    for i in [1..Length(list)] do
        list[i].group := PcGroupCode( list[i].code, list[i].order );
    od;

    # set up
    codes := List( list, x -> [x.code] );
    conds := List( list, x -> 0 );
    rem   := Length( list );
    c := 0;

    while Minimum( conds ) <= n and rem > 1 do
        for i in [1..Length(list)] do
            if Length( codes[i] ) > 0 then
                code := RandomSpecialPcgsCoded( list[i].group );
                if code in codes[i] then
                    conds[i] := conds[i]+1;
                fi;

                found := false;
                j     := 1;
                while not found and j <= Length( list ) do
                    if j <> i then
                        if code in codes[j] then
                            found := true;
                        else
                            j := j + 1;
                        fi;
                    else
                        j := j + 1;
                    fi;
                od;

                if found then
                    k := Minimum( i, j );
                    l := Maximum( i, j );
                    codes[k] := Union( codes[k], codes[l] );
                    codes[l] := [];
                    conds[k] := 0;
                    conds[l] := n+1;
                    rem := rem - 1;
                else
                    AddSet( codes[i], code );
                fi;
            fi;
        od;

        # just for information
        c := c+1;
        if c mod 10 = 0 then
            Info( InfoRandIso, 3, "     ", c, " loops, ",
                  rem, " groups ",
                  conds{ Filtered( [ 1 .. Length( list ) ],
                  x -> Length( codes[ x ] ) > 0 ) }," doubles ",
                  List( codes{ Filtered( [ 1 .. Length( list ) ],
                  x -> Length( codes[ x ] ) > 0 ) }, Length ),
                  " presentations");
        fi;
    od;

    # cut out information
    for i in [1..Length(list)] do
        Unbind( list[i].group );
    od;

    # and return
    return list{ Filtered( [1..Length(codes)], x -> Length(codes[x])>0 ) };
end );

#############################################################################
##
#F ReducedByIsomorphisms( list )
##
InstallGlobalFunction( ReducedByIsomorphisms, function( list )
    local subl, fins, i, fin, j, done,H;

    # the trivial cases
    if Length( list ) = 0 then return list; fi;

    if Length( list ) = 1 then
        list[1].isUnique := true;
        return list;
    fi;

    Info( InfoRandIso, 1, "  reduce ", Length(list), " groups " );

    # first split the list
    Info( InfoRandIso, 2, "   Iso: split list by invariants ");
    done  := [];
    subl  := [];
    fins  := [];
    for i in [1..Length(list)] do
        if list[i].isUnique then
            Add( done, list[i] );
        else
            H   := PcGroupCode( list[i].code, list[i].order );
            fin := FingerprintFF( H );
            fin := Concatenation( list[i].extdim, fin );
            j   := Position( fins, fin );
            if IsBool( j ) then
                Add( subl, [list[i]] );
                Add( fins, fin );
            else
                Add( subl[j], list[i] );
            fi;
        fi;
    od;

    # now remove isomorphic copies
    for i in [1..Length(subl)] do
        Info( InfoRandIso, 2, "   Iso: reduce list of length ",
                               Length(subl[i]));
        subl[i] := RandomIsomorphismTest( subl[i], 10 );
        if Length( subl[i] ) = 1 then
            subl[i][1].isUnique := true;
            Add( done, subl[i][1] );
            Unbind( subl[i] );
        fi;
    od;

    subl := Compacted( subl );
    SortBy( subl, Length );

    # return
    return Concatenation( done, subl );
end );

