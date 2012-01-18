############################################################################
##
#W  normcon.gi                  Polycyc                         Bettina Eick
##
##  Computing normalizers of subgroups.
##  Solving the conjugacy problem for subgroups.
##
if not IsBound( CHECK_NORM ) then CHECK_NORM := false; fi;

#############################################################################
##
#F AffineActionOnH1( CR, cc )
##
AffineActionOnH1 := function( CR, cc )
    local aff, l, i, lin, trl, j;
    aff := OperationOnH1( CR, cc );
    l   := Length( cc.factor.rels );
    for i in [1..Length(aff)] do
        if aff[i] = 1 then 
            aff[i] := IdentityMat( l+1 );
        else
            lin := List( aff[i].lin, x -> cc.CocToFactor( cc, x ) );
            trl := cc.CocToFactor( cc, aff[i].trl );
            for j in [1..l] do Add( lin[j], 0 ); od;
            Add( trl, 1 );
            aff[i] := Concatenation( lin, [trl] );
        fi;
    od;
    if not IsBool(cc.fld) then aff := aff * One(cc.fld); fi;
    return aff;
end;

#############################################################################
##
#F VectorByComplement( CR, igs )
##
##  bad hack ... igs and fac have to fit together.
##
VectorByComplement := function( CR, U )
    local fac, vec, igs;
    fac := CR.factor;
    igs := Cgs(U);
    vec := List( [1..Length(fac)], i -> 
           ExponentsByPcp( CR.normal, fac[i]^-1 * igs[i] ) );
    return Flat(vec);
end;

#############################################################################
##
#F LiftBlockToPointNormalizer( CR, cc, C, H, HN )
##
LiftBlockToPointNormalizer := function( CR, cc, C, H, HN )
    local b, r, t, i, c, igs;

    # set up b and t 
    b := AddIgsToIgs( Igs(H), DenominatorOfPcp( CR.normal ) );
    r := List( cc.rls, x -> MappedVector( x, CR.normal ) );
    b := AddIgsToIgs( r, b );
    t := ShallowCopy( AsList( Pcp( C, HN ) ) );

    # catch a special case
    if Length(cc.gcb) = 0 then return SubgroupByIgsAndIgs( C, t, b ); fi;

    # add normalizer to centralizer and complement
    for i in [1..Length(t)] do
        c := VectorByComplement( CR, H^t[i] );
        if not IsBool( cc.fld ) then c := c * One( cc.fld ); fi;
        c := cc.CocToCBElement( cc, c ) * cc.trf;
        t[i] := t[i] * MappedVector( c, CR.normal );
    od;
    return SubgroupByIgsAndIgs( C, t, b );
end;

#############################################################################
##
#F NormalizerOfIntersection( C, N, I )
##
NormalizerOfIntersection := function( C, N, I )
    local pcp, int, fac, act, p, d, F, stb, ind;

    # catch trivial cases
    if Size(I) = 1 or IndexNC(N,I) = 1 then return C; fi;

    # set up
    pcp := Pcp(N, "snf");
    int := List( Igs(I), x -> ExponentsByPcp( pcp, x ) );
    fac := Pcp( C, N );
    act := LinearActionOnPcp( fac, pcp );
    p := RelativeOrdersOfPcp( pcp )[1];
    d := Length( pcp );
    Info( InfoPcpGrp, 2,"  normalize intersection in layer of type ",p,"^",d);

    # the finite case
    if p > 0 then
        F := GF(p);
        act := InducedByField( act, F );
        int := VectorspaceBasis( int*One(F) );
        stb := PcpOrbitStabilizer( int, fac, act, OnVectorspaceBases );
        stb := AddIgsToIgs( stb.stab, AsList(pcp) );
        return SubgroupByIgs( C, stb );

    # the infinite case
    else
        ind := NaturalHomomorphismByPcp( fac );
        int := LatticeBasis( int );
        C := Image( ind );
        C := NormalizerIntegralAction( C, act, int );
        return PreImage( ind, C );
    fi;
end;

#############################################################################
##
#F StabilizerOfCocycle( CR, cc, C, elm )
##
StabilizerOfCocycle := function( CR, cc, C, elm )
    local aff, s, l, D, nat, act, e, oper, stb;

    # determine operation and catch trivial case
    aff := AffineActionOnH1( CR, cc );
    if ForAll( aff, x -> x = x^0 ) then return C; fi;

    # determine stabilizer of free abelian part
    s := Position( cc.factor.rels, 0 );
    l := Length( cc.factor.rels );
    D := C;
    if not IsBool(s) then
        nat := NaturalHomomorphismByPcp( CR.super );
        act := List( aff, x -> x{[s..l+1]}{[s..l+1]} );
        e := elm{[s..l]}; Add( e, 1 );
        D := Image( nat, D );
        D := StabilizerIntegralAction( D, act, e );
        D := PreImage( nat, D );
    fi;
    if Size(D) = 1 or s = 1 then return D; fi;

    # now it remains to do an affine finite os calculation
    Add( elm, 1 );

    # set up action for D
    if IndexNC(C,D) > 1 then
        act := Pcp( D, CR.group );
        aff := InducedByPcp( CR.super, act, aff );
    else
        act := CR.super;
    fi;

    # set up operation
    if IsBool(cc.fld) then
        oper := function( pt, aff )
            local im, i;
            im := pt * aff;
            for i in [1..l] do
                if cc.factor.rels[i] > 0 then
                    im[i] := im[i] mod cc.factor.rels[i];
                fi;
            od;
            return im;
        end;
    else
        elm := elm * One(cc.fld);
        oper := OnRight;
    fi;

    # compute stabilizer
    stb := PcpOrbitStabilizer( elm, act, aff, oper );
    return SubgroupByIgsAndIgs( C, stb.stab, Igs(CR.group) );
end;

#############################################################################
##
#F PcpsOfAbelianFactor( N, I )
##
PcpsOfAbelianFactor := function( N, I )
    local ser, sub, pcp, rel, tor, gen, M, p, T;

    # set up
    ser := [];
    sub := Igs(I);
    pcp := Pcp(N, I, "snf");
    rel := RelativeOrdersOfPcp( pcp );
    tor := pcp{Filtered([1..Length(rel)], x -> rel[x] > 0 )};

    # the factor mod torsion
    T := SubgroupByIgsAndIgs( N, tor, sub );
    if IndexNC(N,T) > 1 then 
        Add( ser, Pcp(N,T,"snf") ); 
        pcp := Pcp(T, I);
        rel := RelativeOrdersOfPcp( pcp );
    fi;

    # now the torsion parts
    while Length(pcp) > 0 do
        p := Factors(rel[1])[1];
        gen := List( pcp, x -> x^p );
        gen := Filtered( gen, x -> x <> One(N) );
        M := SubgroupByIgsAndIgs( N, gen, sub );
        Add( ser, Pcp(T,M,"snf") ); 
        T := M;
        pcp := Pcp(T, I);
        rel := RelativeOrdersOfPcp( pcp );
    od;

    return ser;
end;

#############################################################################
##
#F NormalizerOfComplement( C, H, N, I )
##
NormalizerOfComplement := function( C, H, N, I )
    local pcps, pcp, M, L, CR, cc, c;

    # catch the trivial case
    if IndexNC(H,I) = 1 or IndexNC(N,I) = 1 then return C; fi;
    Info( InfoPcpGrp, 2, "  normalize complement");

    # compute efa series through N / I
    pcps := PcpsOfAbelianFactor( N, I );

    # loop over series
    for pcp in pcps do

        M := SubgroupByIgs( C, NumeratorOfPcp( pcp ) );
        L := SubgroupByIgsAndIgs( C, Igs(H), Igs(M) );

        # set up H^1
        CR := rec( group  := L, 
                   super  := Pcp( C, L ),
                   factor := Pcp( L, M ),
                   normal := pcp );
        AddFieldCR( CR );
        AddRelatorsCR( CR );
        AddOperationCR( CR );
        AddInversesCR( CR );

        # determine 1-cohomology 
        cc := OneCohomologyEX( CR );
        if IsBool( cc ) then Error("no complement \n"); fi;

        # stabilize vector
        if Length( cc.factor.rels ) > 0 then
            Info( InfoPcpGrp, 2, "  H1 is of type ",cc.factor.rels);
            c := VectorByComplement( CR, H );
            if not IsBool( cc.fld ) then c := c * One( cc.fld ); fi;
            c := cc.CocToFactor( cc, c );
            C := StabilizerOfCocycle( CR, cc, C, c );
        fi;

        # lift to point normalizer
        C := LiftBlockToPointNormalizer( CR, cc, C, H, L );
    od;
    return C;
end;

#############################################################################
##
#F NormalizerBySeries( G, U, efa )
##
NormalizerBySeries := function( G, U, efa )
    local C, i, N, M, hom, H, I, nat, k; 

    # do a simple check
    if Size(U) = 1 or G = U then return G; fi;

    # loop over series
    C := G;
    for i in [2..Length(efa)-1] do
        Info( InfoPcpGrp, 1, "start layer ",i);

        # get layer
        N := efa[i];
        M := efa[i+1];

        # determine factor C/M
        hom := NaturalHomomorphism( G, M );
        if Size(M) > 1 then
            N := Image( hom, N );
            C := Image( hom, C );
        fi;
        H := Image( hom, U );

        # first normalize the intersection I = N cap H
        I := NormalIntersection( N, H );
        C := NormalizerOfIntersection( C, N, I );

        # now normalize complement
        C := NormalizerOfComplement( C, H, N, I );

        # add checking if required
        if CHECK_NORM then
            Info( InfoPcpGrp, 1, "  check result ");
            H := Image( hom, U );
            if ForAny( Igs(C), x -> H^x <> H ) then
               Error("normalizer is not normalizing");
            fi;
        fi;

        if Size(M) > 1 then C := PreImage( hom, C ); fi;
    od;
    return C;
end;

#############################################################################
##
#F Normalizer
##
NormalizerPcpGroup := function( G, U )
    local GG, UU, NN;

    # translate
    GG  := PcpGroupByEfaSeries(G);
    UU  := PreImage(GG!.bijection,U);

    # compute
    NN := NormalizerBySeries( GG, UU, EfaSeries(GG) );

    # translate back
    return Image(GG!.bijection, NN );
end;

InstallMethod( NormalizerOp, "for a pcp group", true,
        [IsPcpGroup, IsPcpGroup], 0,
function( G, U ) 
    local H;

    # check
    if not IsSubgroup( Parent(G), U ) then
        Error("arguments must have a common parent group");
    fi;

    # catch a special case
    if not IsSubgroup( G, U ) then 
        H := SubgroupByIgs( Parent(G), Igs(G), Igs(U) );
        return Intersection( G, NormalizerPcpGroup( H, U ) );
    fi;

    # treat the general case
    return NormalizerPcpGroup( G, U ); 
end );

#############################################################################
##
#F ConjugacySubgroupsBySeries( G, U, V, pcps )
##
ConjugacySubgroupsBySeries := function( G, U, V, pcps )
    Error("not yet installed");
end;

#############################################################################
##
#F IsConjugate( G, U, V )
#F ConjugacySubgroupsPcpGroup( G, U, V )
##
ConjugacySubgroupsPcpGroup := function( G, U, V )

    # check
    if not IsSubgroup(Parent(G),U) or not IsSubgroup( Parent(G), V ) then
        Error("arguments must have a common parent group");
    fi;

    # compute
    return ConjugacySubgroupsBySeries( G, U, V, PcpsOfEfaSeries(G) );
end;

InstallMethod( IsConjugate, "for a pcp group", true,
        [IsPcpGroup, IsPcpGroup, IsPcpGroup], 0,
function( G, U, V ) return ConjugacySubgroupsPcpGroup( G, U, V ); end );

