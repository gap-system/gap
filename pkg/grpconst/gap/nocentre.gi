#############################################################################
##
#W  nocentre.gi                 GrpConst                         Bettina Eick
#W                                                         Hans Ulrich Besche
##
Revision.("grpconst/gap/nocentre_gi") :=
    "@(#)$Id: nocentre.gi,v 1.5 2010/10/21 07:00:17 gap Exp $";

#############################################################################
##
#F PermRepDP( D ) . . . . . . . . . . . . . permutation rep of direct product
##
PermRepDP := function( D )
    local A, B, operA, operB, G, emb1, emb2;

    A := Image( Projection( D, 1 ) );
    B := Image( Projection( D, 2 ) );
    operA := IsomorphismPermGroup( A );
    operB := IsomorphismPermGroup( B );
    G := DirectProduct( Image( operA ), Image( operB ) );
    emb1 := Embedding( G, 1 );
    emb2 := Embedding( G, 2 );
    return [operA * emb1, operB * emb2];

end;

#############################################################################
##
#F PermOper( oper, elms ) . . . . . . . . perm rep of direct product elements
##
PermOper := function( oper, gens )
    local new, g, h1, h2, h;
    new := [];
    for g in gens do
        h1 := Image( oper[1], g[1] );
        h2 := Image( oper[2], g[2] );
        h := h1 * h2;
        Add( new, h );
    od;
    return Group( new, () );
end;


#############################################################################
##
#F CosetReps . . . . . . . . . . . . . double coset reps for induced aut grps
##
CosetReps := function( C, hom, NU, NL )
    local U, H, CU, gens, oper, g, imgs, aut, CL, reps;

    if Size( C ) = 1 then return [Identity(C)]; fi;
    U := Image( hom );
    H := Source( hom );

    # automorphisms of U induced by NU
    CU := [];
    gens := GeneratorsOfGroup( U );
    oper := GeneratorsOfGroup( NU );
    for g in oper do
        imgs := List( gens, x -> x^g );
        if imgs <> gens then
            aut := GroupHomomorphismByImagesNC(U, U, gens, imgs);
            SetIsBijective( aut, true );
            Add( CU, aut );
        fi;
    od;
    CU := SubgroupNC( C, CU );

    # automorphisms of U induced by NL
    CL := [];
    gens := List(GeneratorsOfGroup(H), x -> Image(hom,x));
    oper := GeneratorsOfGroup( NL );
    for g in oper do
        imgs := List( GeneratorsOfGroup( H ), x -> Image( g, x ) );
        imgs := List( imgs, x -> Image( hom, x ) );
        aut := GroupHomomorphismByImagesNC(U, U, gens, imgs);
        SetIsBijective( aut, true );
        Add( CL, aut );
    od;
    CL := SubgroupNC( C, CL );

    # double-coset representatives
    reps := DoubleCosets( C, CU, CL );
    reps := List( reps, Representative );
    return reps;
end;
 
#############################################################################
##
## N is a center-free perfect group and H is soluble.
## classify extensions of N by H up to isomorphism
##
ExtensionsByGroupNoCentre := function( N, H )
    local A, I, hom, O, clU, B, clL, f, D, gensN, oper, pairs, U, L, nat, 
          F, iso, res, NU, NL, C, reps, r, new, gens, G, pair, g, h;

    # the automorphism group of N
    Info( InfoGrpCon, 2, " compute Aut N ");
    A := AutomorphismGroup(N);
    I := InnerAutomorphismsAutomorphismGroup(A);
    hom := NaturalHomomorphismByNormalSubgroup( A, I );
    O := Image(hom);

    # possible projections in O
    Info( InfoGrpCon, 2, " compute subgroups of Out N  ");
    clU := ConjugacyClassesSubgroups( O );
    clU := List( clU, Representative );

    # the automorphism group of H
    Info( InfoGrpCon, 2, " compute Aut H ");
    B := AutomorphismGroup( H );
    IsomorphismPermGroup(B);

    # possible kernels in H
    Info( InfoGrpCon, 2, " compute possible centralizers in H ");
    clL := NormalSubgroups( H );
    clL := Filtered( clL, x -> Index(H, x) <= Size(O) );
    f := function( pt, aut ) return Image( aut, pt ); end;
    clL := Orbits( B, clL, f );
    clL := List( clL, x -> x[1] );

    # compute direct product
    Info( InfoGrpCon, 2, " compute direct product and projections ");
    D := DirectProduct( A, H );
    gensN := List( GeneratorsOfGroup( I ), x -> Tuple( [x, Identity(H)] ) );

    # compute perm reps
    Info( InfoGrpCon, 2, " compute perm rep of D ");
    oper := PermRepDP( D );

    # compute pairs
    Info( InfoGrpCon, 2, " computing pairs ");
    pairs := [];
    for U in clU do
        for L in clL do
            nat := NaturalHomomorphismByNormalSubgroup( H, L );
            F := Image( nat );
            if Size(U) = Size( F ) then
                if IdGroup( U ) = IdGroup( F ) then
                    iso := IsomorphismGroups( F, U );
                    iso := nat * iso;
                    SetIsSurjective( iso, true );
                    SetKernelOfMultiplicativeGeneralMapping( iso, L );
                    Add( pairs, iso );
                fi;
            fi;
        od;
    od;

    # classify subdirect products
    Info( InfoGrpCon, 2, " start to loop over ", Length(pairs), " pairs ");
    res := [];
    for pair in pairs do
        Info( InfoGrpCon, 3, "  start factors of id ", IdGroup(U),"");
        U := Image( pair );
        L := Kernel( pair );

        # operating groups
        Info( InfoGrpCon, 3, "  computing normalizer ");
        NU := Normalizer( O, U );
        Info( InfoGrpCon, 3, "  computing stabilizer ");
        NL := Stabilizer( B, L, f );
        Info( InfoGrpCon, 3, "  computing automorphism group ");
        C := AutomorphismGroup( U );

        # coset reps
        Info( InfoGrpCon, 3, "  computing coset reps ");
        reps := CosetReps( C, pair, NU, NL );

        # for each double coset rep create a group
        Info( InfoGrpCon, 3, "  loop over ", Length(reps), " coset reps ");
        for r in reps do
            new := pair * r;

            Info( InfoGrpCon, 4, 
                  "   compute generators of subdirect product "); 
            gens := [];
            for g in GeneratorsOfGroup( H ) do
                h := Image( new, g );
                h := PreImagesRepresentative( hom, h );
                h := Tuple( [h, g ] );
                Add( gens, h );
            od;
            Append( gens, gensN );

            Info( InfoGrpCon, 4, "   compute perm rep ");
            G := PermOper( oper, gens );
            Add( res, G );
        od;
    od;
    
    return res;
end;

#############################################################################
##
#F UpwardsExtensionsNoCentre( N, stepsize )
##
UpwardsExtensionsNoCentre := function( N, stepsize )
    local all, res, G, tmp;
    if stepsize = 1 then
        return [N];
    fi;
    all := AllGroups( stepsize, IsSolvableGroup, true );
    res := [];
    for G in all do
        IsPGroup( G );
        Info( InfoGrpCon, 1, "start extending by group with id ",IdGroup(G) );
        tmp := ExtensionsByGroupNoCentre( N, G );
        Append( res, tmp );
    od;
    return res;
end;

