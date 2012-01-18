#############################################################################
##
#F ExtensionCR( A, c ) . . . . . . . . . . . . . . . . . . . . .one extension
##
InstallGlobalFunction( ExtensionCR, function( A, c )
    local n, m, coll, i, j, g, e, r, o, x, k, v, G, rels;

    # get dimensions
    n := Length( A.mats );
    m := A.dim;
    rels := RelativeOrdersOfPcp( A.factor );

    # in case c is ffe
    if IsBool( c ) then c := List( [1..m*Length(A.enumrels)], x -> 0 ); fi;
    if Length( c ) > 0 and IsFFE( c[1] ) then c := IntVecFFE(c); fi;

    # the free group
    coll := FromTheLeftCollector( n+m );
    
    # the relators of G
    for i in [1..Length(A.enumrels)] do
        e := A.enumrels[i];
        r := VectorOfWordCR( A.relators[e[1]][e[2]], n );
        v := c{[(i-1)*m+1..i*m]};
        Append(r, v);
        o := ObjByExponents( coll, r );
        
        if e[1] = e[2] then
            SetRelativeOrder( coll, e[1], rels[e[1]] );
            SetPower( coll, e[1], o );
        elif e[1] > e[2] then
            SetConjugate( coll, e[1], e[2], o );
        else
            SetConjugate( coll, e[1], -e[2]+e[1], o );
        fi;
    od;
        
    # power relators of A
    if A.char > 0 then
        for i in [n+1..n+m] do
            SetRelativeOrder( coll, i, A.char );
        od;
    fi;

    # conjugate relators - G acts on A
    for i in [1..n] do
        for j in [n+1..n+m] do
            x := List( [1..n], x -> 0 );
            if A.char = 0 then
                Append( x, A.mats[i][j-n] );
            else
                Append( x, IntVecFFE( A.mats[i][j-n] ) );
            fi;
            SetConjugate( coll, j, i, ObjByExponents( coll, x ) );
        od;
    od;
    
    UpdatePolycyclicCollector( coll );
    G := PcpGroupByCollectorNC( coll );
    G!.module := Subgroup( G, Igs(G){[n+1..n+m]} );
    return G;
 
end );

#############################################################################
##
#F ExtensionsCR( C ) . . . . . . . . . . . . . . . . . . . . . all extensions
##
# FIXME: This function is documented and should be turned into a GlobalFunction
ExtensionsCR := function( C )
    local cc, new, elm, rel;

    # compute cocycles
    cc := TwoCocyclesCR( C );

    # if there are infinitely many extensions
    if C.char = 0 and Length( cc ) > 0 then
        Print("infinitely many extensions \n");
        return fail;
    fi;

    # otherwise compute all elements
    new := [];
    if Length( cc ) = 0 then
        elm := ExtensionCR( C, false );
        Add( new, elm );
    else
        rel := ExponentsByRels( List( cc, x -> C.char ) );
        elm := List( rel, x -> IntVector( x * cc ) );
        elm := List( elm, x -> ExtensionCR( C, x ) );
        Append( new, elm );
    fi;
    return new;
end;

#############################################################################
##
#F ExtensionClassesCR( C ) . . . . . . . . . . . . . .  all up to equivalence
##
# FIXME: This function is documented and should be turned into a GlobalFunction
ExtensionClassesCR := function( C )
    local cc, elms;

    # compute H^2( U, A/B ) and return if there is no complement
    cc := TwoCohomologyCR( C );
    if IsBool( cc ) then return []; fi;

    # check the finiteness of H^1
    if ForAny( cc.factor.rels, x -> x = 0 ) then
        Print("infinitely many extensions \n");
        return fail;
    fi;

    # catch a trivial case
    if Length( cc.factor.rels ) = 0 then 
        return [ ExtensionCR( C, false ) ];
    fi;

    # create elements of cc.factor
    elms := ExponentsByRels( cc.factor.rels );
    if C.char > 0 then elms := elms * One( C.field ); fi;


    # loop over orbit and extract information
    return List( elms, x -> ExtensionCR( C, IntVector( x * cc.factor.prei )));
end;


#############################################################################
##
#F SplitExtensionPcpGroup( G, mats ) . . . . . . . . . . . . . . .G split Z^n
##
# FIXME: This function is documented and should be turned into a GlobalFunction
SplitExtensionPcpGroup := function( G, mats )
    return ExtensionCR( CRRecordByMats( G, mats ), false );
end;

#############################################################################
##
#F SplitExtensionByAutomorphisms( G, H, auts )
##
InstallMethod( SplitExtensionByAutomorphisms,
   "for a PcpGroup, a PcpGroup, and a list of automorphisms", true, 
   [ IsPcpGroup, IsPcpGroup, IsList ], 0, 
   function( G, H, auts )
    local g, h, n, m, rg, rh, zn, zm, coll, o, i, j, k;

    # get dimensions
    g := Pcp(G);
    h := Pcp(H);
    n := Length( g );
    m := Length( h );
    rg := RelativeOrdersOfPcp( g );
    rh := RelativeOrdersOfPcp( h );
    zn := List( [1..n], x -> 0 );
    zm := List( [1..m], x -> 0 );

    # the free group
    coll := FromTheLeftCollector( n+m );

    # the relators of G
    for i in [1..n] do
        if rg[i] > 0 then
            o := ExponentsByPcp( g, g[i]^rg[i] );
            o := ObjByExponents( coll, Concatenation( zm, o ) );
            SetRelativeOrder( coll, m+i, rg[i] );
            SetPower( coll, m+i, o );
        fi;
        for j in [i+1..n] do
            o := ExponentsByPcp( g, g[j]^g[i] );
            o := ObjByExponents( coll, Concatenation( zm, o ) );
            SetConjugate( coll, m+j, m+i, o );
        od;
    od;
   
    # the relators of H
    for i in [1..m] do
        if rh[i] > 0 then 
            o := ExponentsByPcp( h, h[i]^rh[i] );
            o := ObjByExponents( coll, Concatenation( o, zn ) );
            SetRelativeOrder( coll, i, rh[i] );
            SetPower( coll, i, o );
        fi;
        for j in [i+1..m] do
            o := ExponentsByPcp( h, h[j]^h[i] );
            o := ObjByExponents( coll, Concatenation( o, zn ) );
            SetConjugate( coll, j, i, o );
        od;
    od;

    # the action of H on G
    for i in [1..m] do
        k := List( g, x -> Image( auts[i], x ) );
        for j in [1..n] do
            o := ExponentsByPcp( g, k[j] );
            o := ObjByExponents( coll, Concatenation( zm, o ) );
            SetConjugate( coll, m+j, i, o );
        od;
    od;

    UpdatePolycyclicCollector(coll);
    G := PcpGroupByCollectorNC( coll );
    return G;
end);

#############################################################################
##
#M  DirectProductOp( <groups>, <onegroup> ) . . . . . . . . .  for pcp groups
##
InstallMethod( DirectProductOp, "for pcp groups", ReturnTrue, 
               [ IsList, IsPcpGroup ], 0,
function( groups, onegroup )
    local  D, info, f, a, i;

    if IsEmpty(groups) or not ForAll(groups,IsPcpGroup) then 
        TryNextMethod(); 
    fi;

    D := groups[1]; 
    f := [1,Length(Igs(D))+1];
    for i in [2..Length(groups)] do
        a := List(Igs(D), x -> IdentityMapping(groups[i]));
        D := SplitExtensionByAutomorphisms(groups[i],D,a);
        Add(f,Length(Igs(D))+1);
    od;

    info := rec(groups := groups, 
                first  := f,
                embeddings := [ ], 
                projections := [ ]);
    SetDirectProductInfo(D,info);

    if ForAny(groups,grp->HasSize(grp) and not IsFinite(grp)) then 
        SetSize(D,infinity); 
    elif ForAll(groups,HasSize) then 
        SetSize(D,Product(List(groups,Size))); 
    fi;

    return D;
end );

#############################################################################
##
#A Embedding
##
InstallMethod( Embedding, true, 
               [ IsPcpGroup and HasDirectProductInfo, IsPosInt ], 0,
function( D, i )
    local info, G, imgs, hom, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then return info.embeddings[i]; fi;

    # compute embedding
    G := info.groups[i];
    gens := Igs( G );
    imgs := Igs( D ){[info.first[i] .. info.first[i+1]-1]};
    hom  := GroupHomomorphismByImagesNC( G, D, gens, imgs );
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#A Projection
##
InstallMethod( Projection, true,
         [ IsPcpGroup and HasDirectProductInfo, IsPosInt ], 0,
function( D, i )
    local info, G, imgs, hom, N, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.projections[i] ) then return info.projections[i]; fi;

    # compute projection
    G := info.groups[i];
    gens := Igs( D );
    imgs := Concatenation(
               List( [1..info.first[i]-1], x -> One( G ) ),
               Igs( G ),
               List( [info.first[i+1]..Length(gens)], x -> One(G)));
    hom := GroupHomomorphismByImagesNC( D, G, gens, imgs );
    SetIsSurjective( hom, true );

    # add kernel
    N := SubgroupNC( D, gens{Concatenation( [1..info.first[i]-1],
                           [info.first[i+1]..Length(gens)])});
    SetKernelOfMultiplicativeGeneralMapping( hom, N );

    # store information
    info.projections[i] := hom;
    return hom;
end );


