#############################################################################
##
#W  grppcaut.gi                 GAP library                      Bettina Eick
##
Revision.grppcaut_gi :=
    "@(#)$Id$";

#############################################################################
##
#I InfoAutGrp
##
InfoAutGrp := NewInfoClass( "InfoAutGrp" ); SetInfoLevel( InfoAutGrp, 1 );
InfoMatOrb := NewInfoClass( "InfoMatOrb" ); SetInfoLevel( InfoMatOrb, 1 );
InfoOverGr := NewInfoClass( "InfoOverGr" ); SetInfoLevel( InfoOverGr, 0 );
SetInfoLevel( InfoCompPairs, 1 );
if not IsBound( CHOP ) then CHOP := false; fi;

#############################################################################
##
#F CheckAuto( auto )
##
CheckAuto := function( auto )
    local new;
    new := GroupGeneralMappingByImages( Source(auto), Range(auto),
           auto!.generators, auto!.genimages );
    if not IsGroupHomomorphism( new ) then
        Error("no group hom");
    fi;
    if not IsInjective( new ) or not IsSurjective( new ) then
        Error("no bijection");
    fi;
end;

#############################################################################
##
#F InducedActionFactor( mats, fac, low )
##
InducedActionFactor := function( mats, fac, low )
    local sml, upp, d, i, b, t;
    sml := List( mats, x -> [] );
    upp := Concatenation( fac, low );
    d   := Length( fac );
    for i in [1..Length(mats)] do
        for b in fac do
            t := SolutionMat( upp, b*mats[i] ){[1..d]};
            Add( sml[i], t );
        od;
    od;
    return sml; 
end;

#############################################################################
##
#F CoefficientsOfVector( v, fac, low )
##
CoefficientsOfVector := function( v, fac, low )
    local upp, d;
    upp := Concatenation( fac, low );
    d   := Length( fac );
    return SolutionMat( upp, v ){[1..d]};
end;

#############################################################################
##
#F StabilizerByMatrixOperation( C, v, f, cohom )
##
StabilizerByMatrixOperation := function( C, v, f, cohom )
    local field, modu, bases, l, m, incl, gens, ind, vec, tmp, upp,
          low, fac, i, o, S, oper;

    # the trivial case 
    if Size( C ) = 1 then return C; fi;

    # gens and opers
    if HasPcgs( C ) then 
        gens := Pcgs( C );
    else 
        gens := GeneratorsOfGroup( C ); 
    fi;
    oper  := List( gens, x -> f( x, cohom ) );

    # construct module to use meataxe
    if CHOP then
        modu  := GModuleByMats( oper, cohom.module.field );
        bases := SMTX.BasesCompositionSeries( modu );
        l     := Length( bases );
        Info( InfoMatOrb, 1, "  MO: found comp series of length ",l);
        Info( InfoMatOrb, 1, "  MO: with dimensions ",List(bases, Length));

        # compute m
        m := 1;
        incl := false;
        while not incl do
            m := m + 1;
            incl := IsList( SolutionMat( bases[m], v ) );
        od;
        Info( InfoMatOrb, 1, "  MO: v is included in ",m,"th subspace");
    else
        bases := [[], oper[1]^0];
        m     := 2;
    fi;

    # the first factor includes v
    fac := BaseSteinitzVectors( bases[m], bases[m-1] ).factorspace;
    ind := InducedActionFactor( oper, fac, bases[m-1] );
    vec := CoefficientsOfVector( v, fac, bases[m-1] );
    tmp := OrbitStabilizer( C, vec, gens, ind, OnRight );
    SetSize( tmp.stabilizer, Size( C ) / Length( tmp.orbit ) );
    C   := tmp.stabilizer;
    Info( InfoMatOrb, 1, "  MO: found orbit of length ",Length(tmp.orbit) );

    # loop over the remaining factors
    for i in Reversed( [1..m-2] ) do
        if Length( tmp.orbit ) > 1 then 
            if HasPcgs( C ) then
                gens := Pcgs( C );
            else
                gens := GeneratorsOfGroup( C );
            fi;
            oper := List( gens, x -> f( x, cohom ) );
        fi;
        upp  := Concatenation( [v], bases[i+1] );
        low  := bases[i];
        fac  := BaseSteinitzVectors( upp, low ).factorspace;
        ind  := InducedActionFactor( oper, fac, low );
        vec  := CoefficientsOfVector( v, fac, low );
        tmp  := OrbitStabilizer( C, vec, gens, ind, OnRight );
        SetSize( tmp.stabilizer, Size( C ) / Length( tmp.orbit ) );
        C    := tmp.stabilizer;
        Info( InfoMatOrb, 1, "  MO: found orbit of length ", 
                                Length(tmp.orbit));
    od;
    return C;
end;

#############################################################################
##
#F TransferPcgsInfo( A, pcsA, rels )
##
TransferPcgsInfo := function( A, pcsA, rels )
    local pcgsA;
    pcgsA := PcgsByPcSequenceNC( ElementsFamily( FamilyObj( A ) ), pcsA );
    SetIsGenericPcgs( pcgsA, true );
    SetRelativeOrders( pcgsA, rels );
    SetOneOfPcgs( pcgsA, One(A) );
    SetPcgs( A, pcgsA );
    SetFilterObj( A, IsPcgsComputable );
end;

#############################################################################
##
#F BlockStabilizer( G, bl )
##
BlockStabilizer := function( G, bl )
    local sub, sortbl, f, len, pos, L, new;

    # the trivial blocksys is useless
    if ForAll( bl, x -> Length(x) = 1 ) then return G; fi;
    if Length( bl ) = 1 then return G; fi;
    sub := Filtered( bl, x -> Length(x) > 1 );
    len := Set( List( sub, x -> Length(x) ) );
    pos := List( len, x -> Filtered(sub, y -> Length(y) = x ) );
    L   := ShallowCopy( G );
    Sort( pos, function( x, y ) return Length(x) < Length( y ); end);

    sortbl := function( sys )
        local i;
        for i in [1..Length(sys)] do
            Sort( sys[i] );
        od;
        Sort( sys, function( x, y ) return x[1] < y[1]; end);
    end;
    sortbl( sub );

    f := function( pt, perm )
        local new;
        new := List( pt, x -> List( x, y -> y^perm) );
        sortbl( new );
        return new;
    end;

    # now loop
    for new in pos do
        if Length( new ) = 1 then
            L := Stabilizer( L, new[1], OnSets );
        else
            L := Stabilizer( L, new, f );
        fi;
    od;
        
    return L;
end;

#############################################################################
##
#F InducedActionAutGroup( epi, weights, s, n, A )
##
InducedActionAutGroup := function( epi, weights, s, n, A )
    local M, H, F, pcgsM, indices, pcsN, N, d, gensN, G, free, words,
          comp, aut, imgs, mat, w, m, exp, tup, gensG, field, D, gensA,
          pcgsD; 

    M := KernelOfMultiplicativeGeneralMapping( epi );
    H := Source( epi );
    F := Image( epi );
    pcgsM := Pcgs( M );
    field := GF( weights[s][3] );

    # construct p-subgroup of H 
    indices := Filtered( [1..s-1], x -> weights[x][1] = weights[s][1] 
                                   and  weights[x][3] = weights[s][3] );
    pcsN  := Pcgs( H ){indices};
    N     := Subgroup( H, pcsN );
    d     := Length( indices );
    gensN := pcsN{[1..d]};

    # construct words for pcgsM in gensN
    G     := FreeGroup( d );
    gensG := GeneratorsOfGroup( G );
    free  := GroupHomomorphismByImages( G, N, gensG, gensN );
    words := List( pcgsM, x -> PreImagesRepresentative( free, x ) );

    # compute images of words
    comp := [];
    if IsPcgsComputable( A ) then
        gensA := Pcgs( A );
    else
        gensA := GeneratorsOfGroup( A );
    fi;
    for aut in gensA do
        imgs := List( gensN, x -> Image( aut, Image( epi, x ) ) );
        imgs := List( imgs, x -> PreImagesRepresentative( epi, x ) );
        mat := [];
        for w in words do
            m := MappedWord( w, gensG, imgs );
            exp := ExponentsOfPcElement( pcgsM, m ) * One( field );
            Add( mat, exp );
        od;
        tup := Tuple( [aut, mat] );
        Add( comp, tup );
    od; 
Error("in ind action");

    # add size and check solubility
    D := Group( comp, Tuple( [One(A), IdentityMat(Length(pcgsM), field)]));
    SetSize( D, Size( A ) );
    if IsPcgsComputable( A ) then
        TransferPcgsInfo( D, comp, RelativeOrders( gensA ) );
    fi;
   
    return D;
end;

#############################################################################
##
#F Fingerprint( G, U )
##
if not IsBound( MyFingerprint ) then MyFingerprint := false; fi;

FingerprintSmall := function( G, U )
    return [IdGroup( U ), Size( CommutatorSubgroup(G,U) )];
end;

FingerprintMedium := function( G, U )
    local w, cl, id;

    # some general stuff
    w := LGWeights( SpecialPcgs( U ) );
    id := [w, Size( CommutatorSubgroup( G, U ) )];

    # about conjugacy classes
    cl := ConjugacyClasses( U );
    Add( id, List( cl, x -> [Size(x), Order(Representative(x))] ) );

    return id;
end;

FingerprintLarge := function( G, U )
    return [Size(U), Size( DerivedSubgroup( U ) ),
            Size( CommutatorSubgroup( G, U ) )];
end;

Fingerprint := function ( G, U )
    local id;
    if not IsBool( MyFingerprint ) then
        return MyFingerprint( G, U );
    fi;
    if Size( U ) <= 100 then 
        return FingerprintSmall( G, U );
    elif Size( U ) <= 1000 then
        return FingerprintMedium( G, U );
    else
        return FingerprintLarge( G, U );
    fi;
end;

#############################################################################
##
#F NormalizingReducedGL( spec, s, n, M )
##
NormalizingReducedGL := function( spec, s, n, M )
    local G, p, d, field, B, U, hom, pcgs, pcs,
          S, N, L,
          f, P, norm,
          pcgsN, pcgsM, pcgsF, 
          orb, part,
          j, par, done, i, vec, elm, elms, pcgsH, H, tup, pos, 
          perms, V;

    G      := GroupOfPcgs( spec );
    d      := M.dimension;
    field  := M.field;
    p      := Characteristic( field );
    B      := GL( d, p );
    U      := Subgroup( B, M.generators );

    # the trivial case 
    if d = 1 then 
        hom := IsomorphismPermGroup( B );
        pcgs := Pcgs( Image( hom ) );
        pcs := List( pcgs, x -> PreImagesRepresentative( hom, x ) );
        TransferPcgsInfo( B, pcs, RelativeOrders( pcgs ) );
        return B;
    fi;

    # first find out, whether there are characteristic subspaces
    # -> compute socle series and chain stabilising mat group
    S := B;

    # in case that we cannot compute a perm rep of pgl
    if p^d > 10000 then
        return S;
    fi;

    # otherwise use a perm rep of pgl and find a small admissible subgroup
    norm := NormedVectors( field^d );
    f := function( pt, op ) return NormedRowVector( pt * op ); end;
    hom := OperationHomomorphism( S, norm, f );
    P := Image( hom );
    L := ShallowCopy(P);

    # compute corresponding subgroups to mins
    pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[s..Length(spec)]} );
    pcgsM := InducedPcgsByPcSequenceNC( spec, spec{[n..Length(spec)]} );
    pcgsF := pcgsN mod pcgsM;

    # use fingerprints
    done := [];
    part := [];
    for i in [1..Length(norm)] do
        elm := PcElementByExponents( pcgsF, norm[i] );
        elms := Concatenation( [elm], pcgsM );
        pcgsH := InducedPcgsByPcSequenceNC( spec, elms );
        H := SubgroupByPcgs( G, pcgsH );
        tup := Fingerprint( G, H );
        pos := Position( done, tup );
        if IsBool( pos ) then
            Add( part, [i] );
            Add( done, tup );
        else
            Add( part[pos], i );
        fi;
    od;
    Sort( part, function( x, y ) return Length(x) < Length(y); end );

    # compute partition stablizer
    if Length(part) > 1 then
        for par in part do 
            if Length( part ) = 1 then
                L := Stabilizer( L, par[1], OnPoints );
            else
                L := Stabilizer( L, par, OnSets );
            fi;
        od;
    fi;
    Info( InfoOverGr, 1, "found partition ",part );

    # use operation of G on norm
    orb := Orbits( U, norm, f );
    part := List( orb, x -> List( x, y -> Position( norm, y ) ) );
    L := BlockStabilizer( L, part );
    Info( InfoOverGr, 1, "found blocksystem ",part );

    # compute normalizer of module
    perms := List( M.generators, x -> Image( hom, x ) );
    V := Subgroup( P, perms );
    L := Normalizer( L, V );

    # go back to mat group
    B := List( GeneratorsOfGroup(L), x -> PreImagesRepresentative(hom, x));
    B := SubgroupNC( S, B );
    if IsSolvableGroup( L ) then
        pcgs := List( Pcgs(L), x -> PreImagesRepresentative( hom, x ) );
        TransferPcgsInfo( B, pcgs, RelativeOrders( Pcgs(L) ) );
    fi;
    SetSize( B, Size( L ) );
    return B;
end;

#############################################################################
##
#F CocycleSQ( epi, field )
##
CocycleSQ := function( epi, field )
    local H, F, N, pcsH, pcsN, pcgsH, o, n, d, z, c, i, j, h, exp, p, k;

    # set up
    H     := Source( epi );
    F     := Image( epi );
    N     := KernelOfMultiplicativeGeneralMapping( epi );
    pcsH  := List( Pcgs( F ), x -> PreImagesRepresentative( epi, x ) );
    pcsN  := Pcgs( N );
    pcgsH := PcgsByPcSequence( ElementsFamily( FamilyObj( H ) ), 
                               Concatenation( pcsH, pcsN ) );
    o     := RelativeOrders( pcgsH );
    n     := Length( pcsH );
    d     := Length( pcsN );
    z     := One( field );
    
    # initialize cocycle
    c := List( [1..d*(n^2 + n)/2], x -> Zero( field ) );

    # add relators
    for i in [1..n] do
        for j in [1..i] do
            if i = j then
                h := pcgsH[i]^o[i];
            else
                h := pcgsH[i]^pcgsH[j];
            fi; 
            exp := ExponentsOfPcElement( pcgsH, h ){[n+1..n+d]} * z;
            p   := (i^2 - i)/2 + j - 1;
            for k in [1..d] do
                c[p*d+k] := exp[k];
            od;
        od;
    od;

    # check
    if c = 0 * c then return 0; fi;
    return c;
end;
             
#############################################################################
##
#F InduciblePairs( C, epi, M )
##
InduciblePairs := function( C, epi, M )
    local F, Cl, cc, cb, co, cohom, f, c, m, i, o, stab, base, b;

    if HasSize( C ) and Size( C ) = 1 then return C; fi;

    # get groups
    F := Image( epi );

    # get cohomology
    Cl := CollectorSQ( F, M, false );
    cc := TwoCocyclesSQ( Cl, F, M );
    cb := TwoCoboundariesSQ ( Cl, F, M );
    co := BaseSteinitzVectors( cc, cb ).factorspace;

    Info( InfoAutGrp, 1, " computed cohomology with dim ",Length( co ));

    # get linear operation
    cohom := rec( group := F, 
                  module := M,
                  collector := Cl,
                  cocycles := cc,
                  coboundaries := cb,
                  factor := co );
    f := LinearOperationFunctionOfCompatiblePairs( C, cohom );

    # get cocycle
    c := CocycleSQ( epi, M.field );
    b := SolutionMat( cohom.base, c ){[1..Length( co )]};

    # compute stabilizer of b
    stab := StabilizerByMatrixOperation( C, b, f, cohom );
    return stab;
end;
   
MatricesOfRelator := function( rel, gens, inv, mats, field, d )
    local n, m, L, s, i, mat;

    # compute left hand side
    n := Length( mats );
    m := LengthWord( rel );
    L := List( [1..n], x -> NullMat( d, d, field ) );
    while m > 0 do
        s := Subword( rel, 1, 1 );
        i := Position( gens, s );
        if not IsBool( i ) and m > 1 then
            mat := MappedWord(Subword( rel, 2, m ), gens, mats);
            L[i] := L[i] + mat;
        elif not IsBool( i ) then
            L[i] := L[i] + IdentityMat( d, field );
        else
            i := Position( inv, s );
            mat := MappedWord( rel, gens, mats );
            L[i] := L[i] - mat;
        fi;
        if m > 1 then rel := Subword( rel, 2, m ); fi;
        m   := m - 1;
    od;
    return L;
end;

VectorOfRelator := function( rel, gens, imgsF, pcsH, pcsN, nu, field )
    local w, s, r;

    # compute right hand side
    w := MappedWord( rel, gens, imgsF )^-1;
    s := MappedWord( rel, gens, pcsH );
    r := ExponentsOfPcElement( pcsN, w * Image( nu, s ) ) * One(field);
    return r;
end;

#############################################################################
##
#F LiftInduciblePair( epi, ind, M, weight )
##
LiftInduciblePair := function( epi, ind, M, weight )
    local H, F, N, pcgsF, pcsH, pcsN, pcgsH, n, d, imgsF, imgsN, nu, P, 
          gensP, invP, relsP, l, E, v, k, rel, u, vec, L, r, i,
          elm, auto, imgsH, j, h, opmats, sys;

    # set up
    H := Source( epi );
    F := Image( epi );
    N := KernelOfMultiplicativeGeneralMapping( epi );
    pcgsF := Pcgs( F );
    pcsH  := List( pcgsF, x -> PreImagesRepresentative( epi, x ) );
    pcsN  := Pcgs( N );
    pcgsH := PcgsByPcSequence( ElementsFamily( FamilyObj( H ) ),
                               Concatenation( pcsH, pcsN ) );
    n     := Length( pcsH ); 
    d     := Length( pcsN );

    # use automorphism of F
    imgsF := List( pcgsF, x -> Image( ind[1], x ) );
    opmats := List( imgsF, x -> MappedPcElement( x, pcgsF, M.generators ) );
    imgsF := List( imgsF, x -> PreImagesRepresentative( epi, x ) );

    # use automorphism of N
    imgsN := List( pcsN, x -> ExponentsOfPcElement( pcsN, x ) );
    imgsN := List( imgsN, x -> x * ind[2] );
    imgsN := List( imgsN, x -> PcElementByExponents( pcsN, x ) ); 

    # in the split case this is all to do
    if weight[2] = 1 then
        imgsH := Concatenation( imgsF, imgsN );
        auto  := GroupHomomorphismByImages( H, H, AsList(pcgsH), imgsH );
    
        SetIsInjective( auto, true );
        SetIsSurjective( auto, true );
        SetKernelOfMultiplicativeGeneralMapping( auto, TrivialSubgroup( H ) );

        return auto;
    fi;

    # add correction
    nu := GroupHomomorphismByImages( N, N, AsList( pcsN ), imgsN );
    P := Image( IsomorphismFpGroupByPcgs( pcgsF, "g" ) );
    gensP := GeneratorsOfGroup( FreeGroupOfFpGroup( P ) );
    invP  := List( gensP, x -> x^-1 );
    relsP := RelatorsOfFpGroup( P );
    l := Length( relsP );

    E := List( [1..n*d], x -> List( [1..l*d], y -> true ) );
    v := [];
    for k in [1..l] do
        rel := relsP[k];
        L   := MatricesOfRelator( rel, gensP, invP, opmats, M.field, d );
        r   := VectorOfRelator( rel, gensP, imgsF, pcsH, pcsN, nu, M.field );
  
        # add to big system
        Append( v, r );
        for i in [1..n] do
            for j in [1..d] do
                for h in [1..d] do
                    E[d*(i-1)+j][d*(k-1)+h] := L[i][j][h];
                od;
            od;
        od;
    od;

    # solve system
    u := SolutionMat( E, v );
    if u = fail then Error("no lifting found"); fi;

    # correct images 
    for i in [1..n] do
        vec := u{[d*(i-1)+1..d*i]};
        elm := PcElementByExponents( pcsN, vec );
        imgsF[i] := imgsF[i] * elm;
    od;

    # set up automorphisms
    imgsH := Concatenation( imgsF, imgsN );
    auto  := GroupHomomorphismByImages( H, H, AsList( pcgsH ), imgsH );
    
    SetIsInjective( auto, true );
    SetIsSurjective( auto, true );
    SetKernelOfMultiplicativeGeneralMapping( auto, TrivialSubgroup( H ) );

    return auto;
end;

#############################################################################
##
#F AutomorphismGroupElAbGroup( G, B )
##
AutomorphismGroupElAbGroup := function( G, B )
    local pcgs, p, d, mats, autos, mat, imgs, auto, A;

    # create matrices
    pcgs := Pcgs( G );
    p := RelativeOrders( pcgs )[1];
    d := Length( pcgs );

    if IsPcgsComputable( B ) then
        mats := Pcgs( B );
    else
        mats := GeneratorsOfGroup( B );
    fi;

    autos := [];
    for mat in mats do
        imgs := List( pcgs, x -> PcElementByExponents( pcgs, 
                            ExponentsOfPcElement( pcgs, x ) * mat ) ); 
        auto := GroupHomomorphismByImages( G, G, AsList( pcgs ), imgs );
 
        SetIsInjective( auto, true );
        SetIsSurjective( auto, true );
        SetKernelOfMultiplicativeGeneralMapping( auto, TrivialSubgroup( G ) );
        Add( autos, auto );
    od;

    A := Group( autos, IdentityMapping(G) );
    SetSize( A, Size( B ) );
    if IsPcgs( mats ) then
        TransferPcgsInfo( A, autos, RelativeOrders( mats ) );
    fi;
    
    return A;
end;

#############################################################################
##
#F AutomorphismGroupSolvableGroup( G )
##
AutomorphismGroupSolvableGroup := function( G )
    local spec, weights, first, m, pcgsU, U, F, pcgsF, A, i, s, n, p, H, 
          pcgsH, pcgsN, N, epi, mats, M, autos, ocr, elms, e, list, imgs,
          auto, tmp, hom, gens, P, C, B, D, pcsA, rels;

    # get LG series
    spec    := SpecialPcgs(G);
    weights := LGWeights( spec );
    first   := LGFirst( spec );
    m       := Length( spec );

    # set up with GL
    Info( InfoAutGrp, 1, "set up computation for grp with weights ",
                          weights);
    pcgsU := InducedPcgsByPcSequenceNC( spec, spec{[first[2]..m]} );
    pcgsF := spec mod pcgsU;
    F     := GroupByPcgs( pcgsF );
    M     := rec( field := GF( weights[1][3] ),
                  dimension := first[2]-1,
                  generators := [] );
    B     := NormalizingReducedGL( spec, 1, first[2], M );
    A     := AutomorphismGroupElAbGroup( F, B );

    # run down series
    for i in [2..Length(first)-1] do

        # get factor
        s := first[i];
        n := first[i+1];
        p := weights[s][3];
        Info( InfoAutGrp, 1, "start ",i,"th layer with weight ",weights[s],
                             "^", n-s,
                             " and automorphism group of size ",Size(A));

        # set up
        if n > Length( spec ) then
            pcgsH := spec;
            H     := G;   
        else
            pcgsU := InducedPcgsByPcSequenceNC( spec, spec{[n..m]} );
            pcgsH := spec mod pcgsU;
            H     := GroupByPcgs( pcgsH );
            pcgsH := Pcgs( H );
        fi;
        pcgsN := InducedPcgsByPcSequenceNC( pcgsH, pcgsH{[s..n-1]} );
        N     := SubgroupByPcgs( H, pcgsN ); 
        epi := GroupHomomorphismByImages( H, F, AsList( pcgsH ), 
               Concatenation( Pcgs(F), List( [s..n-1], x -> One(F) ) ) );
        SetKernelOfMultiplicativeGeneralMapping( epi, N );

        # get module
        mats := LinearOperationLayer( H, pcgsH{[1..s-1]}, pcgsN );
        M    := GModuleByMats( mats, GF( p ) );
                  
        # compatible / inducible pairs
        if weights[s][2] = 1 then
            Info( InfoAutGrp, 1," compute reduced gl ");
            B := NormalizingReducedGL( spec, s, n, M );
            D := DirectProduct( A, B ); 
            Info( InfoAutGrp, 1," compute compatible pairs in group of size ",
                                  Size(A), " x ",Size(B));
            C := CompatiblePairs( F, M, D );
        else
            Info( InfoAutGrp, 1," compute reduced gl ");
            B := NormalizingReducedGL( spec, s, n, M );
            D := DirectProduct( A, B ); 
            # Info( InfoAutGrp, 1, " compute induced action ");
            # D := InducedActionAutGroup( epi, weights, s, n, A );
            if weights[s][1] > 1 then
                Info( InfoAutGrp, 1,
                      " compute compatible pairs in group of size ",
                       Size(A), " x ",Size(B));
                D := CompatiblePairs( F, M, D );
            fi;
            Info( InfoAutGrp,1, " compute inducible pairs in a group of size ",
                  Size( D ));
            C := InduciblePairs( D, epi, M );
        fi;


        # lift
        Info( InfoAutGrp, 1, " lift back ");
        if Size( C ) = 1 then
            gens := [];
        elif IsPcgsComputable( C ) then
            gens := Pcgs( C );
        else
            gens  := GeneratorsOfGroup( C );
        fi;
        autos := List( gens, x -> LiftInduciblePair( epi, x, M, weights[s] ) );
        
        # add H^1
        Info( InfoAutGrp, 1, " add derivations ");
        ocr := rec( group := H, modulePcgs := pcgsN );
        elms := BasisVectors( Basis( OCOneCocycles( ocr, false ) ) );
        for e in elms do
            list := ocr.cocycleToList( e );
            imgs := List( [1..s-1], x -> pcgsH[x] * list[x] );
            Append( imgs, pcgsH{[s..n-1]} );
            auto := GroupHomomorphismByImages( H, H, AsList( pcgsH ), imgs );
           
            SetIsInjective( auto, true );
            SetIsSurjective( auto, true );
            SetKernelOfMultiplicativeGeneralMapping(auto, TrivialSubgroup(H));
            
            Add( autos, auto );
        od;

        # set up for iteration
        F := ShallowCopy( H );
        A := Group( autos );
        SetSize( A, Size( C ) * p^Length(elms) );
        if Size(C) = 1 then
            rels := List( [1..Length(elms)], x-> p );
            TransferPcgsInfo( A, autos, rels );
        elif IsPcgsComputable( C ) then
            rels := Concatenation( RelativeOrders(gens), 
                                   List( [1..Length(elms)], x-> p ) );
            TransferPcgsInfo( A, autos, rels );
        fi;

        # if possible reduce the number of generators of A
        if Size( F ) <= 1000 and not HasIsPcgsComputable( A ) then
            Info( InfoAutGrp, 1, " nice the gen set of A ");
            hom  := OperationHomomorphism( A, AsList( F ) );
            P    := Image( hom );
            if IsSolvableGroup( P ) then
                pcsA := List( Pcgs(P), x -> PreImagesRepresentative( hom, x ));
                TransferPcgsInfo( A, pcsA, RelativeOrders( Pcgs(P) ) );
            else
                imgs := SmallGeneratingSet( P );
                gens := List( imgs, x -> PreImagesRepresentative( hom, x ) );
                SetGeneratorsOfGroup( A, gens );
            fi;
        fi;
    od; 

    # return
    if IsPcgsComputable( A ) then SetIsSolvableGroup( A, true ); fi;
    return A;
end;
