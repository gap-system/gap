#############################################################################
##
#W  grppcext.gi                 GAP library                      Bettina Eick
##
Revision.grppcext_gi :=
    "@(#)$Id:";

#############################################################################
##
#F FpGroupPcGroupSQ( G ). . . . . . . . .relators according to sq-algorithmus
##
FpGroupPcGroupSQ := function( G )
    local F, f, g, n, rels, i, j, w, v, t, p;

    F := FreeGroup( Length(Pcgs(G)) );
    f := GeneratorsOfGroup( F );
    g := Pcgs( G );
    n := Length( g );
    rels := List( [1..n], x -> List( [1..x], y -> false ) );
    for i in [1..n] do
        for j in [1..i-1] do
            w := f[j]^-1 * f[i]^-1 * f[j];
            v := ExponentsOfPcElement( g, g[i]^g[j] );
            t := Product( List( [1..n], x -> f[x]^v[x] ) ); 
            rels[i][j] := w * t;
        od; 
        p := RelativeOrderOfPcElement( g, g[i] );
        w := (f[i]^-1)^p;
        v := ExponentsOfPcElement( g, g[i]^p );
        t := Product( List( [1..n], x -> f[x]^v[x] ) ); 
        rels[i][i] := w * t;
    od;
    return rec( group := F, relators := Concatenation( rels ) );
end;

#############################################################################
##
#F MappedPcElement( elm, pcgs, list )
##
MappedPcElement := function( elm, pcgs, list )
    local vec, new, i;
    if Length( list ) = 0 then return fail; fi;
    vec := ExponentsOfPcElement( pcgs, elm );
    if Length( list ) < Length( vec ) then return fail; fi;
    new := list[1]^0;
    for i in [1..Length(vec)] do
        new := new * list[i]^vec[i];
    od;
    return new;
end;

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

############################################################################
##
#F CompatiblePairs( G, M )
#F CompatiblePairs( G, M, D )  ... D <= Aut(G) x GL
#F CompatiblePairs( G, M, D, flag ) ... D <= Aut(G) x GL normalises K
##
CompatiblePairs := function( arg )
    local G, M, Mgrp, oper, A, B, D, K, f, tmp, i, tup;

    # catch arguments
    G := arg[1];
    M := arg[2];
    Mgrp := Group( M.generators );
    oper := GroupHomomorphismByImages( G, Mgrp, Pcgs(G), M.generators );

    # automorphism groups of G and M
    if Length( arg ) = 2 then
        Info( InfoCompPairs, 1, "    comp pairs: compute aut group \n");
        A := AutomorphismGroup( G );
        B := GL( M.dimension, Characteristic( M.field ) );
        D := DirectProduct( A, B );
    else
        D := arg[3];
    fi;

    # compute stabilizer of K in A 
    if Length( arg ) <= 3 or not arg[4] then

        # get kernel of oper
        K := KernelOfMultiplicativeGeneralMapping( oper );

        # get its stabilizer
        f := function( pt, a ) return Image( a[1], pt ); end;
        tmp := OrbitStabilizer( D, K, f );
        SetSize( tmp.stabilizer, Size(D)/Length(tmp.orbit) ); 
        D := tmp.stabilizer;
        Info( InfoCompPairs, 1, "    comp pairs: found orbit of length ",
              Length( tmp.orbit ));
    fi;

    # compute stabilizer of M.generators in D
    f := function( tup, elm )
        local gens;
        gens := List( tup[1], x -> Image( Inverse(elm[1]), x ) );
        gens := List( gens, x -> MappedPcElement( x, tup[1], tup[2] ) );
        gens := List( gens, x -> x ^ elm[2] );
        return Tuple( [tup[1], gens] );
    end;

    tup := Tuple( [Pcgs(G), M.generators] );
    tmp := OrbitStabilizer( D, tup, f );
    SetSize( tmp.stabilizer, Size(D)/Length(tmp.orbit) ); 
    D := tmp.stabilizer;
    Info( InfoCompPairs, 1, "    comp pairs: found orbit of length ",
          Length( tmp.orbit ));
    return D;
end;

#############################################################################
##
#F LinearOperationFunctionOfCompatiblePairs( C, cohom )
##
LinearOperationFunctionOfCompatiblePairs := function( C, cohom )
    local F, f;
    if not IsBound( cohom.presentation ) then 
        F := FpGroupPcGroupSQ( cohom.group );
        cohom.presentation := rec( relators := F.relators,
                              generators := GeneratorsOfGroup( F.group ) );
    fi;
    if not IsBound( cohom.base ) then
        cohom.base  := Concatenation( cohom.factor, cohom.coboundaries );
    fi;

    # compute linear operation function
    f := function( g, cohom )
        local pcgsG, n, d, z, pres, c, H, pcgsH, pcgsN, imgs, new, mat, l; 
        pcgsG := Pcgs( cohom.group );
        n     := Length( pcgsG );
        d     := cohom.module.dimension;
        l     := Length( cohom.factor );
        z     := One( cohom.module.field );
        pres  := cohom.presentation;
        mat   := [];
        for c in cohom.factor do
            H     := ExtensionSQ( cohom.collector, 
                                  cohom.group, cohom.module, c );   
            pcgsH := Pcgs( H );
            pcgsN := InducedPcgsByPcSequence( pcgsH, pcgsH{[n+1..n+d]} );
            imgs  := List( pcgsG, x -> x^Inverse( g[1] ) );
            imgs  := List( imgs, x -> MappedPcElement( x, pcgsG, pcgsH ) );
            new   := List( pres.relators, 
                           x -> MappedWord( x, pres.generators, imgs ) );
            new  := List( new, 
                    x -> ExponentsOfPcElement(pcgsN, x) 
                         * One(cohom.module.field ) );
            new  := List( new, x -> x^g[2] );
            new  := Concatenation( new );
            new  := SolutionMat( cohom.base, new ){[1..l]};
            Add( mat, new );
        od;
        return mat;
    end;
    return f;
end;

#############################################################################
##
#M ExtensionRepresentatives( G, M, C )
##
InstallMethod( ExtensionRepresentatives,
    "generic method for pc groups",
    true, 
    [ IsPcGroup, IsRecord, IsList ],
    0,
function( G, M, C )
    local Cl, co, cb, cc, ext, new, cohom, mats, Mgrp, orbs, o, V, f;

    # compute H^2(G, M)
    Cl := CollectorSQ( G, M, false ); 
    co := TwoCocyclesSQ( Cl, G, M );
    cb := TwoCoboundariesSQ( Cl, G, M );
    cc := BaseSteinitzVectors( co, cb ).factorspace;

    # catch the trivial case
    if Length(cc) = 0 then
        return [ExtensionSQ( Cl, G, M, 0 )];
    elif Length(cc) = 1 then
        new := ExtensionSQ( Cl, G, M, cc[1] );
        return [ExtensionSQ( Cl, G, M, 0 ), new];
    fi;

    # set up to compute linear operation
    cohom := rec( group        := G,
                  module       := M,
                  collector    := Cl,
                  cocycles     := co,
                  coboundaries := cb,
                  factor       := cc );
    f := LinearOperationFunctionOfCompatiblePairs( C, cohom );
    mats := List( GeneratorsOfGroup( C ), x -> f( x, cohom ) );

    # compute orbit of mats on cc
    Mgrp := Group( mats );
    V    := FullRowSpace( M.field, Length(cc) );
    orbs := Orbits( Mgrp, V, OnRight );
    ext  := List( orbs, x -> ExtensionSQ( Cl, G, M, x[1]*cc ) );
    return ext;
end);

#############################################################################
##
#F NonSplitExtensionReps( G, M ) 
##
NonSplitExtensionReps := function( G, M )
    local C, co, cb, cc, cohom, mats, V, Mgrp, orbs, ext, CP, f;

    # compute H^2(G, M)
    C  := CollectorSQ( G, M, false ); 
    co := TwoCocyclesSQ( C, G, M );
    cb := TwoCoboundariesSQ( C, G, M );
    cc := BaseSteinitzVectors( co, cb ).factorspace;
    Info( InfoExtReps, 1, "    H2 has dimension ",Length(cc));

    # catch the trivial case
    if Length(cc) = 0 then
        return [];
    elif Length(cc) = 1 then
        return [ExtensionSQ( C, G, M, cc[1] )];
    fi;

    # set up to compute linear operation
    cohom := rec( group        := G,
                  module       := M,
                  collector    := C,
                  cocycles     := co,
                  coboundaries := cb,
                  factor       := cc );
    Info( InfoExtReps, 1, "    compute compatible pairs and operation");
    CP := CompatiblePairs( G, M );
    f := LinearOperationFunctionOfCompatiblePairs( CP, cohom );
    mats := List( GeneratorsOfGroup( CP ), x -> f( x, cohom ) );

    # compute orbit of mats on cc
    Info( InfoExtReps, 1, "    compute orbits ");
    Mgrp := Group( mats );
    V    := FullRowSpace( M.field, Length(cc) );
    orbs := Orbits( Mgrp, V, OnRight );
    orbs := orbs{[2..Length(orbs)]};
    Info( InfoExtReps, 1, "    found ",Length(orbs)," orbits ");
    ext  := List( orbs, x -> ExtensionSQ(C, G, M, x[1]*cc) );
    return ext;
end;

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

