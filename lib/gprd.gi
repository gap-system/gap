#############################################################################
##
#W  gprd.gi                     GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
Revision.gprd_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  DirectProduct( <arg> )
##
DirectProduct := function( arg )
    local   grps;
    
    if IsList( arg[1] )  then  grps := arg[1];
                         else  grps := arg;    fi;
    if   ForAll( grps, IsPermGroup )  then
        return DirectProductOfPermGroups( grps );
    elif ForAll( grps, IsPcGroup )    then
        return DirectProductOfPcGroups( grps );
    else
        return DirectProductOfGroups( grps );
    fi;
end;

#############################################################################
##
#M  DirectProductOfGroups( list )
##
DirectProductOfGroups := function( list )
    local ids, tup, first, i, G, gens, g, new, D;

    ids := List( list, x -> One( x ) );
    tup := [];
    first := [1];
    for i in [1..Length( list )] do
        G    := list[i];
        gens := GeneratorsOfGroup( G );
        for g in gens do
            new := ShallowCopy( ids );
            new[i] := g;
            new := Tuple( new );
            Add( tup, new );
        od;
        Add( first, Length( tup )+1 );
    od;
    D := Group( tup );
    SetDirectProductInfo( D, rec( groups := list,
                                  first  := first,
                                  embeddings := [],
                                  projections := [] ) );
    return D;
end;        

#############################################################################
##
#M \in( <tuple>, <G> )
##
InstallMethod( \in, true, [IsTuple, IsGroup and HasDirectProductInfo], 0,
function( g, G )
    local n, info;
    n := Length( g );
    info := DirectProductInfo( G );
    return ForAll( [1..n], x -> g[x] in info.groups[x] );
end );
    
#############################################################################
##
#A Embedding
##
InstallMethod( Embedding,
        "of group and integer",
         true, 
         [ IsGroup and HasDirectProductInfo, IsInt and IsPosRat ], 
         0,
    function( D, i )
    local info, G, imgs, hom, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.embeddings[i] ) then 
        return info.embeddings[i];
    fi;

    # compute embedding
    G := info.groups[i];
    gens := GeneratorsOfGroup( G );
    imgs := GeneratorsOfGroup( D ){[info.first[i] .. info.first[i+1]-1]};
    hom  := GroupHomomorphismByImages( G, D, gens, imgs );
    SetIsInjective( hom, true );

    # store information
    info.embeddings[i] := hom;
    return hom;
end );

#############################################################################
##
#A Projection
##
InstallMethod( Projection,
        "of group and integer",
         true, 
         [ IsGroup and HasDirectProductInfo, IsInt and IsPosRat ], 
         0,
    function( D, i )
    local info, G, imgs, hom, N, list, gens;

    # check
    info := DirectProductInfo( D );
    if IsBound( info.projections[i] ) then 
        return info.projections[i];
    fi;

    # compute projection
    G    := info.groups[i];
    gens := GeneratorsOfGroup( D );
    imgs := Concatenation( 
               List( [1..info.first[i]-1], x -> One( G ) ),
               GeneratorsOfGroup( G ),
               List( [info.first[i+1]..Length(gens)], x -> One(G)));
    hom := GroupHomomorphismByImages( D, G, gens, imgs );
    N := Subgroup( D, gens{Concatenation( [1..info.first[i]-1], 
                           [info.first[i+1]..Length(gens)])});
    SetIsSurjective( hom, true );
    SetKernelOfMultiplicativeGeneralMapping( hom, N );

    # store information
    info.projections[i] := hom;
    return hom;
end );

#############################################################################
##
#M  Size( <D> )
##
InstallMethod( Size, true, [IsGroup and HasDirectProductInfo], 0,
function( D )
    return Product( List( DirectProductInfo( D ).groups, x -> Size(x) ) );
end );

#############################################################################
##
#M  IsSolvableGroup( <D> )
##
InstallMethod( IsSolvableGroup, "for direct products", true, 
               [IsGroup and HasDirectProductInfo], 0,
function( D )
    return ForAll( DirectProductInfo( D ).groups, IsSolvableGroup );
end );

#############################################################################
##
#M  IsPcgsComputable( <D> )
##
InstallMethod( IsPcgsComputable, "for direct products", true, 
               [IsGroup and HasDirectProductInfo], 
               SUM_FLAGS,
function( D )
    return ForAll( DirectProductInfo( D ).groups, IsPcgsComputable );
end );

#############################################################################
##
#M  Pcgs( <D> )
##
InstallMethod( Pcgs, "for direct products", true, 
               [IsGroup and IsPcgsComputable and HasDirectProductInfo], 
               SUM_FLAGS,
function( D )
    local info, pcs, i, pcgs, emb, rels, one, new, g;
    if IsPcGroup( D ) then TryNextMethod(); fi;
    info := DirectProductInfo( D );
    pcs := [];
    rels := [];
    one := List( info.groups, x -> One(x) );
    for i in [1..Length(info.groups)] do
        pcgs := Pcgs( info.groups[i] );
        for g in pcgs do
            new := ShallowCopy( one );
            new[i] := g;
            Add( pcs, Tuple( new ) );
        od;
        Append( rels, RelativeOrders( pcgs ) );
    od;
    pcs := PcgsByPcSequenceNC( ElementsFamily(FamilyObj( D ) ), pcs );
    SetRelativeOrders( pcs, rels );
    SetOneOfPcgs( pcs, One(D) );
    SetIsGenericPcgs( pcs, true );
    return pcs;
end );

#############################################################################
##
#F InnerSubdirectProducts2( D, U, V ) . . . . . . . . . .up to conjugacy in D
##
InnerSubdirectProducts2 := function( D, U, V )
    local normsU, normsV, div, fac, Syl, NormU, orb, NormV, pairs, i, j,
          homU, homV, iso, subdir, gensU, gensV, N, UN, M, VM, Aut, gamma,
          P, NormUN, autU, n, alpha, NormVM, autV, reps, rep, gens, r, g, h,
          S, pair, imgs;
    
    # compute necessary normal subgroups in U and V
    if IsAbelian( U ) and IsAbelian( V ) then
        normsU := List( ConjugacyClassesSubgroups( U ), Representative );
        normsV := List( ConjugacyClassesSubgroups( V ), Representative );
    elif IsAbelian( U ) then
        normsU := List( ConjugacyClassesSubgroups( U ), Representative );
        normsV := NormalSubgroupsAbove( V, DerivedSubgroup(V),[]);
    elif IsAbelian( V ) then
        normsU := NormalSubgroupsAbove( U, DerivedSubgroup(U),[]);
        normsV := List( ConjugacyClassesSubgroups( V ), Representative );
    else
        div  := Set( FactorsInt( Gcd( Size( U ), Size( V ) ) ) );

        # in U
        fac  := Set( FactorsInt( Size( U ) ) );
        fac  := Filtered( fac, x -> not x in div );
        Syl  := List( fac, x -> GeneratorsOfGroup( SylowSubgroup( U, x ) ) );
        Syl  := Concatenation( Syl );
        Syl  := NormalClosure( U, Subgroup( U, Syl ) );
        normsU := NormalSubgroupsAbove( U, Syl, [] );
            
        # in V
        fac  := Set( FactorsInt( Size( V ) ) );
        fac  := Filtered( fac, x -> not x in div );
        Syl  := List( fac, x -> GeneratorsOfGroup( SylowSubgroup( V, x ) ) );
        Syl  := Concatenation( Syl );
        Syl  := NormalClosure( V, Subgroup( V, Syl ) );
        normsV := NormalSubgroupsAbove( V, Syl, [] );
    fi;

    # compute orbits on normal subgroups in U
    NormU  := Normalizer( D, U );
    orb    := Orbits( NormU, normsU, OnPoints );
    normsU := List( orb, x -> x[1] );

    # compute orbits on normal subgroups in V
    NormV  := Normalizer( D, V );
    orb    := Orbits( NormV, normsV, OnPoints );
    normsV := List( orb, x -> x[1] );

    # find isomorphic pairs of factors
    pairs := [];
    for i in [1..Length(normsU)] do
        for j in [1..Length(normsV)] do
            if Index( U, normsU[i] ) = Index( V, normsV[j] ) then
                homU := NaturalHomomorphismByNormalSubgroup( U, normsU[i] );
                homV := NaturalHomomorphismByNormalSubgroup( V, normsV[j] );
                iso := IsomorphismGroups( Image( homU ), Image( homV ) );
                if not IsBool( iso ) then
                    Add( pairs, [ homU, homV, iso] );
                fi;
            fi;
        od;
    od;

    # loop over pairs
    subdir := [];
    gensU  := GeneratorsOfGroup( U );
    gensV  := GeneratorsOfGroup( V );
    for pair in pairs do

        N := KernelOfMultiplicativeGeneralMapping( pair[1] ); 
        UN := Image( pair[1] );
        M := KernelOfMultiplicativeGeneralMapping( pair[2] ); 
        VM := Image( pair[2] );
        iso := pair[3];

        # calculate Aut( U / N )
        Aut := AutomorphismGroup( UN );
        gamma := IsomorphismPermGroup( Aut );
        P := Image( gamma );

        # calculate induced autos in G
        NormUN := Normalizer( NormU, N );
        autU   := [];
        for n in GeneratorsOfGroup( NormUN ) do
            gens := List( gensU, x -> Image( pair[1], x ) );
            imgs := List( gensU, x -> Image( pair[1], x^n ) );
            if gens <> imgs then
                alpha := GroupHomomorphismByImages( UN, UN, gens, imgs );
                SetFilterObj( alpha, IsMultiplicativeElementWithInverse );
                Add( autU, Image( gamma, alpha ) );
            fi;
        od;
        autU := Subgroup( P, autU );

        # calculate induced autos in H
        NormVM := Normalizer( NormV, M );
        autV   := [];
        for n in GeneratorsOfGroup( NormVM ) do
            gens := List( gensV, x -> Image( pair[2], x ) );
            imgs := List( gensV, x -> Image( pair[2], x^n ) );
            if gens <> imgs then
                alpha := GroupHomomorphismByImages( VM, VM, gens, imgs );
                alpha := iso * alpha * InverseGeneralMapping( iso );
                SetFilterObj( alpha, IsMultiplicativeElementWithInverse );
                Add( autV, Image( gamma, alpha ) );
            fi;
        od;
        autV := Subgroup( P, autV );

        # and obtain double coset reps
        reps := List( DoubleCosets( P, autU, autV ), Representative );
        reps := List( reps, x -> PreImagesRepresentative( gamma, x ) );

        # loop over automorphisms
        for rep in reps do

            # compute corresponding group
            gens := Concatenation( GeneratorsOfGroup( N ), 
                                   GeneratorsOfGroup( M ) );
            for r in GeneratorsOfGroup( UN ) do
                g := Image( rep, r );
                h := Image( iso, r );
                g := PreImagesRepresentative( pair[1], g );
                h := PreImagesRepresentative( pair[2], h );
                Add( gens, g * h );
            od;
            S := Subgroup( D, gens );
            SetSize( S, Size( N ) * Size( M ) * Size( UN ) );
            Add( subdir, S );
        od;
    od;

    # return
    return subdir;
end;

#############################################################################
##
#F InnerSubdirectProducts( D, list ) . . . . . . .iterated subdirect products
##
InnerSubdirectProducts := function( P, list )
    local subdir, i, U, tmp, S, new;
    subdir := [list[1]];
    for i in [2..Length(list)] do
        U := list[i];
        tmp := [];
        for S in subdir do
            new := InnerSubdirectProducts2( P, S, U );
            Append( tmp, new );
        od;
        subdir := tmp;
    od;
    return subdir;
end;

#############################################################################
##
#F SubdirectProducts( S, T ) . . . . . . . . . . . up to conjugacy in parents
##
SubdirectProducts := function( S, T )
    local G, H, D, emb1, emb2, U, V, subdir, info, i, tmp;

    # go over to direct product
    G := Parent( S );
    H := Parent( T );
    D := DirectProduct( G, H );

    # create embeddings
    emb1  := Embedding( D, 1 );
    emb2  := Embedding( D, 2 );

    # compute subdirect products
    U := Image( emb1, S );
    V := Image( emb2, T );

    subdir := InnerSubdirectProducts2( D, U, V );

    # create info
    info := rec( groups := [S, T],
                 projections := [Projection( D, 1 ), Projection( D, 2 )] );
        
    for i in [1..Length( subdir )] do
        SetSubdirectProductInfo( subdir[i], info );
    od;
         
    return subdir;
end;
#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:
#############################################################################
