#############################################################################
##
#W  frattfree.gi                GAP library                      Bettina Eick
##
Revision.frattfree_gi :=
    "@(#)$Id:";

#############################################################################
##
#F DiagonalMat( matlist, field )
##
DiagonalMat := function( matlist, field )
    local c, n, new, mat, i, j;
    c := 0;
    n := Sum( List( matlist, x -> Length( x ) ) );
    new := IdentityMat( n, field );
    for mat in matlist do
        for i in [1..Length(mat)] do
            for j in [1..Length(mat)] do
                new[c+i][c+j] := mat[i][j];
            od;
        od;
        c := c + Length( mat );
    od;
    return new;
end;

#############################################################################
##
#F RunSubdirectProductInfo( U ) 
##
RunSubdirectProductInfo := function( U )
    local info, proj, new, dims;
 
    info := SubdirectProductInfo( U );
    proj := [];
    if HasProjections( info.groups[1] ) then
        new  := Projections( info.groups[1] );
        Append( proj, List( new, x -> info.projections[1] * x ) );
    fi;
    if HasProjections( info.groups[2] ) then
        new  := Projections( info.groups[2] );
        Append( proj, List( new, x -> info.projections[2] * x ) );
    fi;
    if Length( proj ) > 0 then
        SetProjections( U, proj );
    fi;
    dims := [];
    if HasSocleDimensions( info.groups[1] ) then
        Append( dims, SocleDimensions( info.groups[1] ) );
    fi;
    if HasSocleDimensions( info.groups[2] ) then
        Append( dims, SocleDimensions( info.groups[2] ) );
    fi;
    if Length( dims ) > 0 then 
        SetSocleDimensions( U, dims );
    fi;
end;

#############################################################################
##
#F IsConjugateMatGroup( M, U, L )
##
IsConjugateMatGroup := function( M, U, L )
    local orbU, c, g, gensM, new;

    # the trivial cases
    if U = L then return true; fi;
    if HasSize( U ) and HasSize( L ) then
        if Size( U ) <> Size( L ) then return false; fi;
    fi;

    # the small group case
    # PU := Image( IsomorphismPermGroup( U ) );
    # PL := Image( IsomorphismPermGroup( L ) );
    # if not IdGroup( PU ) = IdGroup( PL ) then return false; fi;

    gensM := GeneratorsOfGroup( M );
    orbU := [U];
    c    := 1;
    while c <= Length( orbU ) do
        for g in gensM do
            new := orbU[c]^g;
            if new = L then return true; fi;
            if not new in orbU then
                Add( orbU, new );
            fi;
        od;
        c := c + 1;
    od;
    return false;
end;

#############################################################################
##
#F IsFaithfulModule( L, gensL, m )
##
IsFaithfulModule := function( L, gensL, m )
    local M, iso;
    if Length(gensL) = 0 then return true; fi;
    M := Group( m.generators );
    iso := GroupHomomorphismByImages( L, M, gensL, m.generators );
    return Size( KernelOfMultiplicativeGeneralMapping( iso ) ) = 1;
end;

#############################################################################
##
#F IrreducibleSubgroupsOfGL( n, p, size, flags )
##
## Uses flags.solvable = true.
##
IrreducibleSubgroupsOfGL := function( n, p, sizeL, flags )
    local max, i, size, P, primes, cl, M, field, root, iso, L, q, tmp,
          affine, sub, s, all, new, modus, m, U,  lat, f, found, j;

    # set up
    M := GL( n, p );
    max := Size( M );

    # get size
    if IsBool( sizeL ) then 
        size := max;
    else
        size := Gcd( max, sizeL );
    fi;

    # the trivial case
    if size = 1 and n = 1 then
        return [TrivialSubgroup( M )];
    elif size = 1 then
        return [];
    fi;        

    # the 1-dimensional case is easy
    if n = 1 then

        # compute permgroups
        P := CyclicGroup( IsPermGroup, p - 1 );
        primes := Set(FactorsInt(Size(P)));
        cl := [TrivialSubgroup(P)];
        for q in primes do
            new := Pcgs( SylowSubgroup(P, q) );
            new := List(cl, x -> List( new, y -> ClosureGroup( x, y )));
            cl  := Concatenation( cl, Flat( new ) );
            cl  := Filtered( cl, x -> IsInt( size / Size(x) ) );
        od;
        
        # compute isomorphism
        field := GF( p );
        root  := PrimitiveRoot( field );
        iso   := GroupHomomorphismByImages( P, M, GeneratorsOfGroup( P ),
                                            [[[root]]] );

        # convert
        for i in [1..Length(cl)]  do
            tmp := Image( iso, cl[i] );
            SetSize( tmp, Size( cl[i] ) );
            cl[i] := tmp;
        od;
        return cl;
    fi;

    # the bounded case is not difficult as well
    if p^n < 256 then

        # get primitive groups
        if not IsBound( PrimitiveGroup ) then
            ReadLib("../prim/primitiv.gi");
        fi;
        if IsBound( flags.solvable ) and flags.solvable then
            affine := [1..NrSolvableAffinePrimitiveGroups(p^n)];
        else
            affine := [1..NrAffinePrimitiveGroups(p^n)];
        fi;
        cl := List( affine, x -> PrimitiveGroup( p^n, x ) );
        cl := Filtered( cl, x -> IsInt( size * p^n / Size( x ) ) );
        cl := List( cl, x -> x!.matrixGroup );
        return cl;
    fi;

    # now we have to construct groups - solvable case first
    if (IsBound( flags.solvable ) and flags.solvable) or size < 60 then
        sub := DivisorsInt( size );
        cl  := [];
        for s in sub do
            all := AllSmallGroups( s );
            all := Filtered( all, x -> Size( PCore( x, p ) ) = 1 );
            for L in all do
                new   := [];
                modus := IrreducibleModules( L, GF(p), n );
                modus := Filtered( modus, x -> x.dimension = n );
                modus := Filtered( modus, x -> IsFaithfulModule(L,Pcgs(L),x));
                for m in modus do
                    U := Subgroup( M, m.generators );
                    SetSize( U, Size( L ) );
                    found := false;
                    j := 1;
                    while not found and j <= Length(new) do
                        found := IsConjugateMatGroup( M, U, new[j] );
                        j := j + 1;
                    od;
                    if not found then Add( new, U ); fi;
                    Append( cl, new );
                od;
            od;
        od;
        return cl;
    fi;

    # now we are in the really bad case

    iso := IsomorphismPermGroup( M );
    P   := Image( iso );
    f   := function( G ) return IsInt( size / Size( G ) ); end;
    lat := LatticeByCyclicExtension( P, f );
    cl  := List( ConjugacyClassesSubgroups(lat), Representative );

    for i in [1..Length(cl)] do
        U := PreImage( iso, cl[i] );
        m := GModuleByMats( GeneratorsOfGroup( U ), GF(p) );
        if not MTX.IsIrreducible(m) then
            cl[i] := false; 
        else
            SetSize( U, Size( cl[i] ) );
            cl[i] := U;
        fi;
    od;
    cl := Filtered( cl, x -> not IsBool( x ) );
    return cl;
end;

#############################################################################
##
#F SemiSimpleGroups( n, p, size, flags )
##
## Uses flags.supersolvable = true and
##      flags.solvable = true.
##
SemiSimpleGroups := function( n, p, sizeK, flags ) 
    local M, iso, P, parts, part, irr, subdir, cand, i, tmp, U, V, all, L,
          list, f, l, grps, idf, idl, gens, new, sub, found, j, field, inv,
          gensP; 

    M := GL(n, p);
    iso := IsomorphismPermGroup( M );
    P := Image( iso );
    field := GF(p);
    if IsBool( sizeK ) then sizeK := Size( M ); fi;
        
    # check supersolvable
    if IsBound( flags.supersolvable ) and flags.supersolvable then
        parts := [List( [1..n], x -> 1 )];
        irr := [IrreducibleSubgroupsOfGL( 1, p, sizeK, flags )];
    else
        parts := Partitions( n );
        irr := List( [1..n], 
               x -> IrreducibleSubgroupsOfGL( x, p, sizeK, flags ) );
    fi;

    subdir := [];
    for part in parts do

        # construct candidates first
        cand := List( irr[part[1]], x -> [x] );
        for i in [2..Length(part)] do
            tmp := [];
            for U in cand do
                for V in irr[part[i]] do
                    Add( tmp, Concatenation( U, [V] ) );
                od;
            od;
            cand := Set( tmp );
        od;

        # compute subdirect products
        all := [];
        for list in cand do
            f := 0;
            l := n;
            grps := [];
            for i in [1..Length(part)] do
                l := l - part[i];
                idf := IdentityMat( f, field );
                idl := IdentityMat( l, field );
                gens := GeneratorsOfGroup( list[i] );
                gens := List( gens, x -> DiagonalMat( [idf, x, idl], field ) ); 
                U := Subgroup( M, gens );
                SetSize( U, Size( list[i] ) );
                L := Image( iso, U );
                SetParent( L, P );
                grps[i] := L;
                f := f + part[i];
            od;
            new := InnerSubdirectProducts( P, grps );            
            Append( all, new );
        od;
  
        # filter conjugates
        sub := [];
        for U in all do
            found := false;
            j := 1;
            while not found and j <= Length( sub ) do
                if RepresentativeOperation( P, U, sub[j] ) <> fail then
                    found := true;
                fi;
                j := j + 1;
            od;
            if not found then
                SetSocleDimensions( U, part );
                Add( sub, U );
            fi;
        od;
        Append( subdir, sub );
    od;

    gensP := GeneratorsOfGroup( P );
    inv := GroupHomomorphismByImages( P, M, gensP,
           List( gensP, x -> PreImagesRepresentative( iso, x ) ) );

    # rewrite projections
    for i in [1..Length(subdir)] do
        SetProjections( subdir[i], [inv] );
    od;
    return subdir; 
end;

#############################################################################
##
#F Uncollected
##
Uncollected := function( coll )
    local list, tup;
    list := [];
    for tup in coll do
        Append( list, List( [1..tup[2]], x -> tup[1] ) );
    od;
    return list;
end;

#############################################################################
##
#F SocleComplementAbelianSocle( A, sizeK, flags )
##
SocleComplementAbelianSocle :=  function( A, sizeK, flags )
    local all, i, new, tmp, U, V, sub;

    if Length( A ) = 0 then return []; fi;

    all := [];
    all := SemiSimpleGroups( A[1][1], A[1][2], sizeK, flags );
    for i in [2..Length( A )] do
        new := SemiSimpleGroups( A[i][1], A[i][2], sizeK, flags );
        tmp := [];
        for U in all do
            for V in new do
                sub := SubdirectProducts( U, V );
                sub := Filtered( sub, x -> IsInt( sizeK / Size(x) ) );
                Append( tmp, sub );
            od;
        od;
        all := tmp;
    od;
    return all;
end;
   
#############################################################################
##
#F NonInnerGroups( e, B, size )
##
NonInnerGroups := function( e, B, size )
    local A, gensB, inn, g, nu, I, iso, P, IP, fac, F, tmp, S, H, G,
          gensH, gensG, hom, sizeF, f, lat, cl, i, kernel; 

    # catch trivial case
    sizeF := size / Size(B)^e;
    if not IsInt( sizeF ) then return []; fi;

    A := AutomorphismGroup( B );

    gensB := GeneratorsOfGroup( B );
    inn   := [];
    for g in gensB do
        nu := GroupHomomorphismByImages( B, B, gensB, List(gensB, y -> y^g));
        SetFilterObj( nu, IsMultiplicativeElementWithInverse );
        Add( inn, nu );
    od;
    I := Subgroup( A, inn );

    # construct perm rep
    iso := IsomorphismPermGroup( A );
    P := Image( iso );

    # construct factor mod inner 
    IP := Image( iso, I );
    fac := NaturalHomomorphismByNormalSubgroup( P, IP );
    F := Image( fac );
    if not IsPermGroup( F ) then
        tmp := IsomorphismPermGroup( F );
        fac := fac * tmp;
        F   := Image( fac );
    fi;
    SetGeneratorsOfGroup( F, 
        List( GeneratorsOfGroup( P ), x -> Image( fac, x ) ) );

    # construct wreath prods
    S := SymmetricGroup( e );
    H := WreathProduct( P, S, IdentityMapping(S), [1..e] );
    G := WreathProduct( F, S, IdentityMapping(S), [1..e] );

    # compute epimorphism
    gensH := GeneratorsOfGroup( H );
    gensG := GeneratorsOfGroup( G );
    hom   := GroupHomomorphismByImages( H, G, gensH, gensG );
    SetIsSurjective( hom, true );
    kernel := KernelOfMultiplicativeGeneralMapping( hom );
    
    # compute subgroups
    sizeF := size / Size(B)^e;
    f  := function( G ) return IsInt( sizeF / Size( G ) ); end;
    lat := LatticeByCyclicExtension( G, f );
    cl := List( ConjugacyClassesSubgroups( lat ), Representative );

    # lift subgroups
    for i in [1..Length(cl)] do
        cl[i] := PreImage( hom, cl[i] );
        SetSocle( cl[i], kernel );
    od;
    return cl;    
end;

#############################################################################
##
#F FittingFreeGroupBySocleAndSize( B, size, flags )
##
FittingFreeGroupsBySocleAndSize := function( B, size, flags )
    local  all, i, new, tmp, U, V, sub;
    
    # trivial case
    if Length( B ) = 0 then return []; fi;

    all := NonInnerGroups( B[1][1], B[1][2], size, flags );
    for i in [2..Length( B )] do
        new := NonInnerGroups( B[i][1], B[i][2], size, flags );
        tmp := [];
        for U in all do
            for V in new do
                sub := SubdirectProducts( U, V );
                sub := Filtered( sub, x -> IsInt( size / Size(x) ) );
                Append( tmp, sub );
            od;
        od;
        all := tmp;
    od;
    return all;
end;

#############################################################################
##
#F MySplitExtensionSolvable( U )
##
MySplitExtensionSolvable := function( U ) 
    local hom, inv, H, proj, pr, imgs, new, fac, pcgs, L; 

    hom := IsomorphismPcGroup( U );
    inv := InverseGeneralMapping( hom );
    H   := Image( hom );
    fac := IdentityMapping( H );
    proj := Projections( U );
    for pr in proj do
        inv  := fac * inv;
        imgs := List( Pcgs(H), x -> Image( inv, x ) );
        imgs := List( imgs, x -> Image( pr, x ) );
        new  := GroupHomomorphismByImages( H, Range( pr ), 
                AsList( Pcgs(H) ), imgs );
        H    := SemidirectProduct( H, new );
        fac  := Projection( H );
    od;

    # set attributes
    SetIsFrattiniFree( H, true );
    pcgs := Pcgs(H){[ Length(Pcgs(Image(hom)))+1..Length(Pcgs(H)) ]};
    L    := Subgroup( H, pcgs );
    SetPcgs( L, InducedPcgsByPcSequence( Pcgs(H), pcgs ) );
    SetSocle( H, L );
    pcgs := Pcgs(H){[ 1..Length(Pcgs(Image(hom))) ]};
    L    := Subgroup( H, pcgs );
    SetPcgs( L, InducedPcgsByPcSequence( Pcgs(H), pcgs ) );
    SetSocleComplement( H, L );
    SetSocleDimensions( H, SocleDimensions( U ) );
    return H;
end;

#############################################################################
##
#F MySplitExtensionNonSolvable( U )
##
MySplitExtensionNonSolvable := function( U )
    return U;
end;

#############################################################################
##
#F FrattiniFreeGroups( soc, flags )
##
FrattiniFreeGroups := function( soc, flags )
    local A, B, sizeA, sizeB, sizeK, max, tup, n, C, 
          uncoll, H, allA, allB, all, i, U, p, V, sub;

    # split socle and get sizes
    A := soc[1];
    B := soc[2];
    sizeA := Product( List( A, x -> x[2]^x[1] ) );
    sizeB := Product( List( B, x -> Size(x[2])^x[1] ) );

    # get maximal size 
    max := 1;
    for tup in A do
        n := tup[1];
        p := tup[2];
        max := max * Product( List( [1..n], x -> p^x - 1 ) );
        max := max * p^(n*(n-1)/2);
    od;
    for tup in B do
        n := tup[1];
        C := AutomorphismGroup( tup[2] );
        p := Size( C );
        max := max * p^n * Factorial( n );
    od;

    # set sizeK
    if IsBound( flags.sizelimit ) then
        sizeK := flags.sizelimit / sizeA;
        sizeK := Gcd( sizeK, max );
    else
        sizeK := max;
    fi;

    # normalSylow = true (reduce sizeK)
    if IsBound( flags.normalSylow ) then
        if IsBound( flags.normalSylow.trueprimes ) then
            sizeK := Product( Filtered( FactorsInt( sizeK ),
                            x -> not x in flags.normalSylow.trueprimes ) );
        fi;
    fi;

    # consistency of flags
    if (IsBound( flags.nilpotent ) and flags.nilpotent) or sizeK = 1 then
        if IsBound( flags.supersolvable ) and not flags.supersolvable then  
            return [];
        fi;
        if IsBound( flags.solvable ) and not flags.solvable then  
            return [];
        fi;
    fi;
    if (IsBound( flags.nilpotent ) and flags.nilpotent) then
        flags.solvable := true;
        flags.supersolvable := true;
    fi;
    if IsBound( flags.supersolvable ) and flags.supersolvable then
        if IsBound( flags.solvable ) and not flags.solvable then  
            return [];
        fi;
        flags.solvable := true;
    fi;

    # consistency sizeB > 1 and solvable = true
    if IsBound( flags.solvable ) and flags.solvable and sizeB > 1 then
        return [];
    fi;

    # consistency sizeA > 1 and solvable = false
    if IsBound( flags.solvable ) and not flags.solvable and sizeA > 1 then
        return [];
    fi;

    # consistency sizeK and normalSylow = false
    if IsBound( flags.normalSylow ) then
        if IsBound( flags.normalSylow.falseprimes ) and
           not ForAll( flags.normalSylow.falseprimes, x -> IsInt(sizeK/x) ) 
        then
            return [];
        fi;  
    fi;

    # consistency sizeK and nilpotent = false
    if IsBound( flags.nilpotent ) and not flags.nilpotent and sizeK = 1 then
        return [];
    fi; 

    # nilpotent = true or sizeK = 1
    if (IsBound( flags.nilpotent ) and flags.nilpotent) or sizeK = 1 then
        uncoll := Uncollected( List( A, x -> [x[2], x[1]] ) );
        H := AbelianGroup( uncoll );
        SetIsFrattiniFree( H, true );
        SetSocle( H, H );
        SetSocleComplement( H, TrivialSubgroup( H ) );
        SetSocleDimensions( H, List( uncoll, x -> 1 ) );
        return [H];
    fi;

    # construct semisimple subgroups of Aut(A)
    Info( InfoFFConst, 2, "  compute subgroups of aut A");
    allA := SocleComplementAbelianSocle( A, sizeK, flags );
    Info( InfoFFConst, 2, "    found ", Length( allA )," groups");
   
    # construct subgroups of Aut(B) containing Inn(B)
    Info( InfoFFConst, 2, "  compute subgroups of aut B");
    allB := FittingFreeGroupsBySocleAndSize( B, sizeK, flags );
    Info( InfoFFConst, 2, "    found ", Length( allB )," groups");

    # construct subdirect products
    Info( InfoFFConst, 2, "  compute subdirect products");
    if Length( allB ) = 0 then all := allA; 
    elif Length( allA ) = 0 then all := allB; 
    else
        all := [];
        for U in allA do
            for V in allB do
                sub := SubdirectProducts( U, V );
                sub := Filtered( sub, x -> IsInt( sizeK / x ) );
                Append( all, sub );
            od;
        od;
    fi;

    # construct semidirect products
    Info( InfoFFConst, 2, "  compute ",Length(all)," split extensions");
    for i in [1..Length( all )] do
        U := all[i];
        if IsSolvableGroup( U ) then
            U := MySplitExtensionSolvable( U );
        else
            U := MySplitExtensionNonSolvable( U );
        fi;
        all[i] := U;
    od;

    # filter with flags
    if IsBound( flags.nilpotent ) and not flags.nilpotent then
        return Filtered( all, x -> Size( SocleComplement( x ) ) > 1 );
    fi;
    if IsBound( flags.supersolvable ) and not flags.supersolvable then
        return Filtered( all, x -> Set( SocleDimensions( x ) ) <> [1] );
    fi;
    if IsBound( flags.normalSylow ) and 
       IsBound( flags.normalSylow.falseprimes ) then
        for p in flags.normalSylow.falseprimes do
            all := Filtered( all, x -> IsInt(Size(SocleComplement(x))/p) );
        od;
    fi;
   
    return all;
end;
   
#############################################################################
##
#F FrattiniFreeSolvableGroupsBySize( size, flags )
##
FrattiniFreeSolvableGroupsBySize := function( size, flags )
    local div, all, i, coll, new, newflags;

    # check and set flags
    if IsBound( flags.solvable ) and not flags.solvable then
        return [];
    fi;
    newflags := ShallowCopy( flags );
    newflags.solvable := true;
    newflags.sizelimit := size;

    # run over possible socles
    div := DivisorsInt( size );
    all := [];
    for i in [2..Length(div)] do
        coll := Collected( FactorsInt( div[i] ) );
        coll := List( coll, x -> [x[2],x[1]] );
        Info( InfoFFConst, 1, "  start sockel ", coll );
        new := FrattiniFreeGroups( [coll, []], newflags );
        Append( all, new );
    od;
    return all;     
end;

