#############################################################################
##
#W  frattext.gi                 GAP library                      Bettina Eick
##
Revision.frattext_gi :=
    "@(#)$Id$";

#############################################################################
##
#F IntCoefficients( primes, vec )
##
IntCoefficients := function( primes, vec )
    local int, i;
    int := 0;
    for i in [1..Length(primes)] do
        int := int * primes[i] + vec[i];
    od;
    return int;
end;

#############################################################################
##
#F CoefficientsInt( primes, int )
##
CoefficientsInt := function( primes, int )
    local vec, i;
    vec := List( primes, x -> 0 );
    for i in Reversed( [1..Length(primes)] ) do
        vec[i] := RemInt( int, primes[i] );
        int := QuoInt( int, primes[i] );
    od;
    return vec;
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
#F PcGroupCode( <code>, <size> )
##
PcGroupCode := function( code, size )
    local F, n1, f, l, mi, n, t1, indices, gens, rels, g, i, uc, ll, rr,
          t, j, z, z2, result;

    # catch trivial case
    if size = 1 then
        return Image( IsomorphismPcGroup( Group(()) ) );
    fi;

    # get indices
    f    := FactorsInt( size );
    l    := Length( f );
    mi   := Maximum( f ) - 1;
    n    := ShallowCopy( code );
    if Length( Set( f ) ) > 1 then
        indices := CoefficientsInt( List([1..l], x -> mi), n mod (mi^l) ) + 2;
        n := QuoInt( n, mi^l );
    else
        indices := f;
    fi;
 
    # create free group
    F := FreeGroup( l );
    gens := GeneratorsOfGroup( F );
    rels := [];
    rr   := [];

    for i in [1..l] do
        rels[i]:=gens[i]^indices[i];
    od;

    ll:=l*(l+1)/2-1;
    if ll < 28 then
        uc := Reversed( CoefficientsInt( List([1..ll], x -> 2), n mod (2^ll)));
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
        t := CoefficientsInt( indices, n mod size );
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
                Add( rels, Comm(gens[j],gens[i])/rr[z] );
                z := z+1;
            fi;
        od;
    od;

    result := PcGroupFpGroup( F / rels );
    return result;
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
#F CheckInPcElement( pcgs, h, p, sub, lin, dims, layers )
##
CheckInPcElement := function( pcgs, h, p, sub, lin, dims, layers )
    local d, l, k, g, ll, lr;

    d := DepthOfPcElement( pcgs, h );
    if d <= Length( pcgs ) then
        l := layers[d];
        if Length( sub[l] ) < dims[l] and IsBool( lin[d] ) then
            Add( sub[l], h );
            lin[d] := h;
        elif Length( sub[l] ) < dims[l] then
            k := h;
            while d <= Length( pcgs ) and not IsBool( lin[d] ) do
                g  := lin[d];
                ll := LeadingExponentOfPcElement( pcgs, h );
                lr := LeadingExponentOfPcElement( pcgs, g );
                k  := LeftQuotient( g^(ll/lr mod p), k );
                d  := DepthOfPcElement( pcgs, k );
            od;
            if d <= Length( pcgs ) and l = layers[d] then
                Add( sub[l], h );
                lin[d] := k;
            fi;
        fi;
    fi;
    return sub;
end;

#############################################################################
##
#F RandomPcgsSylowSubgroup( S, p )
##
RandomPcgsSylowSubgroup := function( S, p )
    local pcgs, l, first, layers, dims, sub, lin, omega, U, top, pcgsU,
          m, pcs, h, d, hit, i, g;

    pcgs := InducedPcgsWrtSpecialPcgs( S );
    l := Length( pcgs );
    first := LGFirst( pcgs );
    layers := LGLayers( pcgs );
    dims := List( [1..Length(first)-1], x -> first[x+1] - first[x] );
 
    # set up 
    sub := List( dims, x -> [] );
    lin := List( [1..l], x -> true );

    # use omega series
    omega := OmegaSeries( S );
    
    # start to fill up sub
    for i in [2..Length(omega)] do
        U := omega[i];
        pcgsU := Pcgs( U );
        m := Length( pcgsU );
 
        hit := List( pcgsU, x -> false );
        for g in Pcgs( omega[i-1] ) do
            hit[DepthOfPcElement( pcgsU, g )] := true;
        od;
        top := First( [1..Length(hit)], x -> not hit[x] );

        while top <= m do

            # compute a random element
            pcs := pcgsU{[top..m]};
            h   := RandomByPcs( pcs, p );
            sub := CheckInPcElement( pcgs, h, p, sub, lin, dims, layers );

            # reset hit and top
            hit[DepthOfPcElement(pcgsU, h)] := true;
            while top <= Length( hit ) and hit[top] do
                top := top + 1;
            od;
        od;
    od;
    return Concatenation( sub );
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
    # sylow := PublicSylowSystem( pcgs );
    sylow := SylowSystem( G );

    # loop over sylow subgroups
    ppcs := List( primes, x -> true );
    for i in [1..Length(primes)] do
        p := primes[i];
        S := sylow[i];
        ppcs[i] := RandomPcgsSylowSubgroup( S, p );
    od;

    # rewrite first for Sylow subgroups
    for i in [1..Length(first)-1] do
        s := first[i];
        p := weights[s][3];
        j := Position( primes, p );
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

#############################################################################
##
#F RandomIsomorphismTest( list, n )
##
RandomIsomorphismTest := function( list, n )
    local codes, conds, code, found, i, j, rem;

    # catch trivial case
    if Length( list ) = 1 then return list; fi;

    # set up
    codes := List( list, x -> [CodePcGroup( x )] );
    conds := List( list, x -> 0 );
    rem   := Length( list );

    while Minimum( conds ) <= n and rem > 1 do
        for i in [1..Length(list)] do
            if Length( codes[i] ) > 0 then
                code := RandomSpecialPcgsCoded( list[i] );
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
                    Append( codes[i], codes[j] );
                    conds[i] := conds[i] + conds[j];
                    codes[j] := [];
                    conds[j] := n+1;
                    rem := rem - 1;
                else
                    Add( codes[i], code );
                fi;
            fi;
        od;
    od;
    return list{ Filtered( [1..Length(codes)], x -> Length(codes[x])>0 ) };
end;

#############################################################################
##
#F FingerprintFF( G ) - hier fehlt noch ExtensionInfo
##
FingerprintFF := function( G ) 
    return Flat( Collected( List( Orbits( G , List( G ) ), 
       y -> [ Order ( y[ 1 ] ), Length( y ) , y[ 1 ] ^ 3 in y , 
       y[ 1 ] ^ 5 in y , y[ 1 ] ^ 7 in y ] ) ) );
end;

#############################################################################
##
#F ReducedByIsomorphisms( list ) 
##
ReducedByIsomorphisms := function( list )
    local subl, fins, i, fin, j;

    # first split the list
    subl  := [];
    fins  := [];
    for i in [1..Length(list)] do
        fin := FingerprintFF( list[i] );
        j   := Position( fins, fin );
        if IsBool( j ) then
            Add( subl, [list[i]] );
            Add( fins, fin );
        else
            Add( subl[j], list[i] );
        fi;
    od;

    # now remove isomorphic copies
    for i in [1..Length(subl)] do
        subl[i] := RandomIsomorphismTest( subl[i], 10 );
    od;
   
    # return 
    return Flat( subl );
end;
        
#############################################################################
##
#F EnlargedModule( M, F, H )
##
EnlargedModule := function( M, F, H )
    local N, l, mats;
    N := ShallowCopy( M );
    l := Length( Pcgs( H ) ) - Length( Pcgs( F ) );
    mats := List( [1..l], x -> IdentityMat( M.dimension, M.field ) );
    N.generators := Concatenation( N.generators, mats );
    return N;
end;

#############################################################################
##
#F FrattiniExtensionsPcGroup( F, o )
##
FrattiniExtensionsPcGroup := function( F, o )
    local sizePhi, primes, prim, modus, grps, exts, min, sub, H, rest, tup,
          j, modu, M, size, new;

    # the trivial cases
    sizePhi := o / Size( F );
    if Size( F ) = o then return [F]; fi;
    if not IsInt( sizePhi ) then return []; fi;
    if not IsSubset( Set( FactorsInt( Size(F) ) ), Set( FactorsInt( o ) ) )
    then return []; fi;

    # construct irreducible modules for F
    primes := Collected( FactorsInt( sizePhi ) );
    prim   := List( primes, x -> x[1] );
    modus  := List( primes, x -> IrreducibleModules( F, GF(x[1]), x[2] ) );

    # set up
    grps := [];
    exts := [F]; 

    # start loop
    while Length( exts ) > 0 do

        Info( InfoFrattExt, 1,"  start new round with ",Length(exts),
                              " groups");
        min := Minimum( List( exts, Size ) );
        sub := Filtered( exts, x -> Size( x ) = min );
        Info( InfoFrattExt, 1,"  start to extend ",Length(sub),
                              " groups of size ",min," - with random isom");
        sub := ReducedByIsomorphisms( sub );
        exts := Filtered( exts, x -> Size( x ) > min );
        Info( InfoFrattExt, 1,"  reduced to ",Length(sub)," groups");
        
        # loop over elements in sub
        for H in sub do
            rest := o / Size( H );
            tup  := Collected( FactorsInt( rest ) )[1];
            j    := Position( prim, tup[1] );
            modu := Filtered( modus[j], x -> x.dimension <= tup[2] );
            modu := List( modu, x -> EnlargedModule( x, F, H ) );

            # loop over modules
            for M in modu do
                size := Size( H ) * tup[1]^M.dimension; 
                new := NonSplitExtensionReps( H, M );
                if size = o then
                    Append( grps, new );
                else
                    Append( exts, new );
                fi;
            od;
        od;
    od;
    Info( InfoFrattExt, 1,"  reduce result ");
    return ReducedByIsomorphisms( grps );
end;

#############################################################################
##
#F FrattiniExtensionsPermGroup( F, o )
##

#############################################################################
##
#F FrattiniExtensions( F, o )
##
FrattiniExtensions := function( F, o )
    if IsPcGroup( F ) then 
        return FrattiniExtensionsPcGroup( F, o );
    else
        Print("sorry - not yet installed \n");
    fi;
end;

#############################################################################
##
#F FrattiniExtensionMethod( o )
##
FrattiniExtensionMethod := function( arg )
    local o, flags, frattfree, groups, F, new, primes;

    o := arg[1];
    if Length( arg ) = 1 then
        flags := rec();
    else
        flags := arg[2];
    fi;

    Info( InfoFEMeth, 1, "compute groups of order", FactorsInt(o) );
    Info( InfoFEMeth, 1, "compute frattini free groups");
    primes    := Set( FactorsInt( o ) );
    frattfree := FrattiniFreeSolvableGroupsBySize( o, flags );
    Info( InfoFEMeth, 1, "found ",Length( frattfree ),
                         " frattini free groups");
    groups := [];
    for F in frattfree do
        Info( InfoFEMeth, 1, "start to extend group of order ",Size(F));
        new := FrattiniExtensions( F, o );
        Info( InfoFEMeth, 1, "extended group of order ",Size(F),
                             " and found ",Length(new)," groups ");
        Append( groups, new );
    od;
    return groups;
end;
