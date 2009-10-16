#############################################################################
##
#W  grpint.gi                  Polycyc                           Bettina Eick
##

#############################################################################
##
#F NormalIntersection( N, U ) . . . . . . . . . . . . . . . . . . . .U \cap N
##
InstallOtherMethod( NormalIntersection, true, [IsPcpGroup, IsPcpGroup], 0,
function( N, U )
    local G, igs, igsN, igsU, n, s, I, id, ls, rs, is, g, d, al, ar, e, tm;

    G    := Parent( N );
    while G <> Parent(G) do G := Parent(G); od;

    igs  := Igs(G);
    igsN := Cgs( N );
    igsU := Cgs( U );
    n    := Length( igs );

    # if N or U is trivial
    if Length( igsN ) = 0 or Length( igsU ) = 0 then
        return SubgroupByIgs(G, [] );
    fi;

    # if N or U are equal to G
    if Length( igsN ) = n and ForAll(igsN, x -> LeadingExponent(x) = 1) then 
        return U;
    elif Length(igsU) = n and ForAll(igsU, x -> LeadingExponent(x) = 1) then 
        return N;
    fi;
  
    # if N is a tail
    s := Depth( igsN[1] );
    if Length( igsN ) = n-s+1 and 
       ForAll( igsN, x -> LeadingExponent(x) = 1 ) then
        I := Filtered( igsU, x -> Depth(x) >= s );
        return SubgroupByIgs( G, I );
    fi;

    # otherwise compute
    id := One(G);
    ls := List( igs, x -> id );
    rs := List( igs, x -> id );
    is := List( igs, x -> id );

    for g in igsU do
        d := Depth( g );
        ls[d] := g;
        rs[d] := g;
    od;

    I := [];
    for g in igsN do
        d := Depth( g );
        if ls[d] = id  then
            ls[d] := g;
        else
            Add( I, g );
        fi;
    od;

    # enter the pairs [ u, 1 ] of <I> into [ <ls>, <rs> ]
    for al  in I  do
        ar := id;
        d  := Depth( al );

        # compute sum and intersection
        while al <> id and ls[d] <> id  do
            e := Gcdex( LeadingExponent(ls[d]), LeadingExponent(al) );
            tm := ls[d]^e.coeff1 * al^e.coeff2;
            al := ls[d]^e.coeff3 * al^e.coeff4;
            ls[d] := tm;
            tm := rs[d]^e.coeff1 * ar^e.coeff2;
            ar := rs[d]^e.coeff3 * ar^e.coeff4;
            rs[d] := tm;
            d := Depth( al );
        od;

        # we have a new sum generator
        if al <> id  then
            ls[d] := al;
            rs[d] := ar;
       
        # we have a new intersection generator
        elif ar <> id then
            d := Depth( ar );
            while ar <> id and is[d] <> id  do
                e  := Gcdex(LeadingExponent( is[d] ), LeadingExponent( ar ));
                tm := is[d]^e.coeff1 * ar^e.coeff2;
                ar := is[d]^e.coeff3 * ar^e.coeff4;
                is[d] := tm;
                d  := Depth( ar );
            od;
            if ar <> id  then
                is[d] := ar;
            fi;
        fi;
    od;

    # sum := Filtered( ls, x -> x <> id );
    I := Filtered( is, x -> x <> id );
    return Subgroup( G, I );
end );

#############################################################################
##
#M Intersection( N, U )
##
InstallMethod( Intersection2, true, [IsPcpGroup, IsPcpGroup], 0,
function( U, V )
    local G;

    # get the parent 
    G := Parent( U );
    while G <> Parent(G) do G := Parent(G); od;

    # catch a trivial case
    if not IsSubgroup( G, V ) then TryNextMethod(); fi;

    # check for trivial cases
    if IsInt(Size(U)) and IsInt(Size(V)) then
        if IsInt(Size(V)/Size(U)) and ForAll(Igs(U), x -> x in V ) then
            return U;
        elif Size(V)<Size(U) and IsInt(Size(U)/Size(V))
             and ForAll( Igs(V), x -> x in U ) then
            return V;
        fi;
    fi;

    # test if one the groups is known to be normal
    if IsNormal( V, U ) then
        return NormalIntersection( U, V );
    elif IsNormal( U, V ) then
        return NormalIntersection( V, U );
    fi;

    Error("sorry: intersection for non-normal groups not yet installed");
end );
