#############################################################################
##
#W  grppcext.gi                 GAP library                      Bettina Eick
##
Revision.grppcext_gi :=
    "@(#)$Id:";

#############################################################################
##
#F  ExtensionSQ( C, G, M, c )
##
##  If <c> is zero,  construct the split extension of <G> and <M>
##
ExtensionSQ := function( C, G, M, c )
    local field, d, n, rels, i, j, w, p, k, l, v, F, m, relators, H, orders,
          Mgens;

    # construct module generators
    field := M.field;
    Mgens := M.generators;
    if Length(Mgens) = 0 then
        return AbelianGroup( List([1..M.dimension], 
                              x -> Characteristic(M.field)));
    fi;
    d := Length(Mgens[1]);
    n := Length(Pcgs( G ));

    # add tails to presentation
    if c = 0  then
        rels := ShallowCopy( C.relators );
    else
        rels := [];
        for i  in [ 1 .. n ]  do
            rels[i] := [];
            for j  in [ 1 .. i ]  do
                if C.relators[i][j] = 0  then
                    w := [];
                else
                    w := ShallowCopy(C.relators[i][j]);
                fi;
                p := (i^2-i)/2 + j - 1;
                for k  in [ 1 .. d ]  do
                    l := c[p*d+k];
                    if l <> Zero( field ) then
                        Add( w, n+k );
                        Add( w, IntFFE(l) );
                    fi;
                od;
                if 0 = Length(w)  then
                    w := 0;
                fi;
                rels[i][j] := w;
            od;
        od;
    fi;

    # add module
    for j  in [ 1 .. d ]  do
        rels[n+j] := [];
        for i  in [ 1 .. j-1 ]  do
            rels[n+j][n+i] := [ n+j, 1 ];
        od;
        rels[n+j][n+j] := 0;
    od;

    # add operation of <G> on module
    for i  in [ 1 .. n ]  do
        for j  in [ 1 .. d ]  do
            v := Mgens[i][j];
            w := [];
            for k  in [ 1 .. d ]  do
                l := v[k];
                if l <> Zero( field ) then
                    Add( w, n+k );
                    Add( w, IntFFE(l) );
                fi;
            od;
            rels[n+j][i] := w;
        od;
    od;

    orders := Concatenation( C.orders, List( [1..d], 
                                       x -> Characteristic( field ) ) );

    # create extension as fp group
    F := FreeGroup( n+d );
    m := GeneratorsOfGroup( F );

    # and construct new presentation from collector
    relators := [];
    for i  in [ 1 .. d+n ]  do
        for j  in [ i .. d+n ]  do
            if i = j  then
                w := m[i]^orders[i];
            else
                w := m[j]^m[i];
            fi;
            v := rels[j][i];
            if 0 <> v  then
                for k  in [ Length(v)-1, Length(v)-3 .. 1 ]  do
                    w := w * m[v[k]]^(-v[k+1]);
                od;
            fi;
            Add( relators, w );
        od;
    od;

    H := PcGroupFpGroup( F / relators );
    # and return
    return H;
end;

#############################################################################
##
#M  Extension( G, M, c )
##
InstallMethod( Extension,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject, IsVector ],
    0,
function( G, M, c )
    local C;
    C := CollectorSQ( G, M, false );
    return ExtensionSQ( C, G, M, c );
end );

#############################################################################
##
#M  Extensions( G, M )
##
InstallMethod( Extensions,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject],
    0,
function( G, M )
    local C, ext, co, cc, c, i;

    C := CollectorSQ( G, M, false );
    ext := [ ExtensionSQ( C, G, M, 0 ) ];

    # compute the two cocycles
    co := TwoCohomologySQ( C, G, M );
    cc := VectorSpace( M.field, co );

    for i in [2..Size(cc)] do
        c := AsList( cc )[i];
        Add( ext, ExtensionSQ( C, G, M, c ) );
    od;
    return ext;
end );

#############################################################################
##
#F  CompatiblePairs( G, M, [A] )
##
CompatiblePairs := function( arg )
    local G, M, A, d, p, B, pcgs, Mgrp, oper, D, f, n, H, i, K, N;

    # catch the arguments
    G := arg[1];
    M := arg[2];
    d := M.dimension;
    pcgs := Pcgs( G );
    Mgrp := Group( M.generators, IdentityMat( d, M.field ) );
    oper := GroupHomomorphismByImages( G, Mgrp, pcgs, M.generators );

    # automorphism group of G
    if Length( arg ) = 3 then
        A := arg[3];
    else
        A := AutomorphismGroup( G );
    fi;

    # stabiliser
    K := KernelOfMultiplicativeGeneralMapping( oper );
    f := function( pt, a ) return Image( a, pt ); end;
    A := Stabilizer( A, K, f );

    # automorphism group of M
    p := Characteristic( M.field );
    B := GL( d, p );

    # normalizer
    N := Normalizer( B, Mgrp );

    # the direct product
    D := DirectProduct( A, N );

    # the action
    f := function( pt, tup )
        local h;
        h := PreImagesRepresentative( oper, pt );
        h := Image( tup[1], h );
        h := Image( oper, h );
        h := tup[2] * h * tup[2]^-1;
        return h;
    end;

    # compute iterated stabilisers
    n := Length( pcgs );
    H := ShallowCopy( D );
    for i in [1..n] do
        H := Stabilizer( H, M.generators[i], f );
    od;
   
    return H;
end;

#############################################################################
##
#M  ExtensionRepresentatives( G, M, P )
##
InstallMethod( ExtensionRepresentatives,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject, IsObject ],
    0,
function( G, M, P )
    local C, cc, l, ext, gens, mats, id, g, mat, c, sub, pcgsN, imgs, rels,
          new, Mgrp, orbs, o, H, n, pcgs, d, co, cb, base, pcgsH, F, f;

    pcgs := Pcgs(G);
    n := Length(pcgs);
    d := M.dimension;
    F := Image( IsomorphismFpGroup( G ) );
    rels := RelatorsOfFpGroup( F );
    f := GeneratorsOfGroup( FreeGroupOfFpGroup( F ) );

    # compute H^2(G, M)
    C  := CollectorSQ( G, M, false ); 
    co := TwoCocyclesSQ( C, G, M );
    cb := TwoCoboundariesSQ( C, G, M );
    cc := BaseSteinitzVectors( co, cb ).factorspace;
    base := Concatenation( cc, cb );
    l  := Length( cc );

    # set up and trivial cases
    ext := [ExtensionSQ( C, G, M, 0 )];

    # catch the trivial case
    if l = 0 then
        return ext;
    elif l = 1 then
        new := ExtensionSQ( C, G, M, cc[1] );
        Add( ext, new );
        return ext;
    fi;

    # compute linear action on H^2(S, M)
    gens := GeneratorsOfGroup( P );
    mats := [];
    id   := IdentityMat( l, M.field );
    for g in gens do
        mat := [];
        for c in cc do
            H     := ExtensionSQ( C, G, M, c );   
            pcgsH := Pcgs( H );
            sub   := pcgsH{[n+1..n+d]};
            pcgsN := InducedPcgsByPcSequence( pcgsH, sub );
            imgs  := List( pcgs, x -> x^g[1] );
            imgs  := List( imgs, x -> ExponentsOfPcElement( pcgs, x ) );
            imgs  := List( imgs, 
                     x -> PcElementByExponents( pcgsH, pcgsH{[1..n]}, x ) );
            new  := List( rels, x -> MappedWord( x, f, imgs ) );
            new  := List( new, x -> ExponentsOfPcElement(pcgsN, x, M.field));
            new  := List( new, x -> g[2] * x * g[2]^-1 );
            new  := Concatenation( new );
            new  := SolutionMat( base, new ){[1..l]};
            Add( mat, new );
        od;
        if not mat = id then
            AddSet( mats, mat );
        fi;
    od;

    # compute orbit of mats on cc
    Mgrp := Group( mats, id );
    cc   := VectorSpace( M.field, cc );
    orbs := Orbits( Mgrp, cc, OnRight );

    for o in orbs do
        new := ExtensionSQ( C, G, M, o );
        Add( ext, new );
    od;

    return ext;
end);

#############################################################################
##
#F  SplitExtension( G, M )
#F  SplitExtension( G, aut, N )
##
InstallMethod( SplitExtension,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject ],
    0,
function( G, M )
    return Extension( G, M, 0 );
end );

InstallOtherMethod( SplitExtension,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsObject, IsPcGroup ],
    0,
function( G, aut, N )
    local pcgsG, fpg, n, gensG, pcgsN, fpn, d, gensN, F, gensF, relators,
          rel, new, g, e, t, l, i, j, k, H, m, gensH,hom1,hom2, relsN, relsG;
    
    pcgsG := Pcgs( G );
    fpg   := Image( IsomorphismFpGroup( G ) );
    n     := Length( pcgsG );
    gensG := GeneratorsOfGroup( FreeGroupOfFpGroup( fpg ) );
    relsG := RelatorsOfFpGroup( fpg );

    pcgsN := Pcgs( N );
    fpn   := Image( IsomorphismFpGroup( N ) );
    d     := Length( pcgsN );
    gensN := GeneratorsOfGroup( FreeGroupOfFpGroup( fpn ) );
    relsN := RelatorsOfFpGroup( fpn );
   
    F := FreeGroup( n + d );
    gensF := GeneratorsOfGroup( F );
    relators := [];

    # relators of G
    for rel in relsG do
        new := MappedWord( rel, gensG, gensF{[1..n]} );
        Add( relators, new );
    od;

    # operation of G on N
    for i in [1..n] do
        for j in [1..d] do

            # left hand side
            l := Comm( gensF[n+j], gensF[i] );

            # right hand side
            g := Image( aut, pcgsG[i] );
            m := Image( g, pcgsN[j] );
            e := ExponentsOfPcElement( pcgsN, (pcgsN[j]^-1 * m)^-1 );
            t := One( F );
            for k in [1..d] do
                t := t * gensF[n+k]^e[k];
            od;
            
            # add new relator
            Add( relators, l * t );
        od;
    od;
            
    # relators of N
    for rel in relsN do
        new := MappedWord( rel, gensN, gensF{[n+1..n+d]} );
        Add( relators, new );
    od;

    H := PcGroupFpGroup( F / relators );
    return H;
end);

#############################################################################
##
#F  FindConjugatingElement( G, inn )
##
FindConjugatingElement := function( G, inn )
    local elm, C, g, h, n, gens, imgs, i;

    elm := One( G );
    C   := G;
    gens := Pcgs( G );
    imgs := List( gens, x -> Image( inn, x ) );
    for i in [1..Length(gens)] do
        g := gens[i];
        h := imgs[i];
        n := RepresentativeOperation( C, g, h );
        elm := elm * n;
        C := Centralizer( C, g^n );
        gens := List( gens, x -> x ^ n );
    od;
    return elm;
end;

#############################################################################
##
#M  TopExtensionsByAutomorphism( G, aut, p )
##
InstallMethod( TopExtensionsByAutomorphism,
    "generic method for groups",
    true, 
    [ IsPcGroup, IsObject, IsInt ],
    0,
function( G, aut, p )
    local pcgs, n, R, gensR, F, gens, relators, pow, pre, powers, i, g,
          h, e, t, j, rel, new, H, grps;

    pcgs := Pcgs( G );
    n    := Length( pcgs );
    R    := Image( IsomorphismFpGroup( G ) );
    gensR := GeneratorsOfGroup( FreeGroupOfFpGroup( R ) );
    
    F := FreeGroup( n + 1 );
    gens := GeneratorsOfGroup( F );
    relators := [];
 
    # compute all possible powers of g
    pow := aut^p;
    pre := FindConjugatingElement( G, pow );
    powers := List( AsList( Centre(G) ), x -> pre * x );
    powers := Filtered( powers, x -> Image( aut, x ) = x );
    grps   := List( powers, x -> false );

    # compute operation 
    for i in [1..Length(gens)] do
        g := pcgs[i];
        h := gens[i+1]; 
        e := ExponentsOfPcElement( pcgs, Image( aut, g ) );
        t := One(F);
        for j in [1..n] do
            t := t * gens[j+1]^e[j];
        od;
        t := (h^-1 * t)^-1; 
        Add( relators, Comm( h, gens[1] ) * t );
    od;

    # add relators 
    Append( relators, List( RelatorsOfFpGroup( R ),
                      x -> MappedWord( x, gensR, gens{[2..n+1]} ) ) ); 

    # set up groups
    for i in [1..Length(powers)] do
        e := ExponentsOfPcElement( pcgs, powers[i] );
        t := One(F);
        for j in [1..n] do
            t := t * gens[j+1]^e[j];
        od;
        rel := gens[1]^p / t;
        new := Concatenation( [rel], relators );
        grps[i] := PcGroupFpGroup( F / new );
    od;

    # return 
    return grps;
end );
    
#############################################################################
##
#M  CyclicTopExtensions( G, p )
##
InstallMethod( CyclicTopExtensions,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsInt ],
    0,
function( G, p )
    local A, gens, P, gensI, I, F, cl, hom, res, aut, new, nat;

    # compute automorphism group
    A := AutomorphismGroup( G );

    # compute rational classes in Aut(G) / Inn(G)
    gens := GeneratorsOfGroup( G );
    if p in Factors( Size( A ) / Index( G, Centre(G) )) then
        P := Operation( A, AsList( G ) );
        gensI := List( gens, x -> Permutation( x, AsList( G ), OnPoints ) );
        I := Subgroup( P, gensI );
    
        nat := NaturalHomomorphismByNormalSubgroup( P, I );
        F   := Range( nat );

        # compute rational classes
        cl := RationalClassesPElements( F, p );
        cl := List( cl, Representative );
        cl := Filtered( cl, x -> x^p = One( F ) );

        # transfer back - 1. part
        cl := List( cl, x -> PreImagesRepresentative( nat, x ) );
    
        # transfer back - 2. part
        hom := GroupHomomorphismByImages( P, A, GeneratorsOfGroup( P ),
               GeneratorsOfGroup( A ) );
        cl := List( cl, x -> Image( hom, x ) );
    else
        cl := [IdentityMapping( G )];
    fi;

    # compute extensions
    res := [];
    for aut in cl do
        new := TopExtensionsByAutomorphism( G, aut, p );
        Append( res, new );
    od;
    return res;
end );

