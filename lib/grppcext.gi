#############################################################################
##
#W  grppcext.gi                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.grppcext_gi :=
    "@(#)$Id$";

#############################################################################
##
#F FpGroupPcGroupSQ( G ). . . . . . . . .relators according to sq-algorithmus
##
InstallGlobalFunction( FpGroupPcGroupSQ, function( G )
    local F, f, g, n, rels, i, j, w, v, t, p, k;

    F := FreeGroup( Length(Pcgs(G)) );
    f := GeneratorsOfGroup( F );
    g := Pcgs( G );
    n := Length( g );
    rels := List( [1..n], x -> List( [1..x], y -> false ) );
    for i in [1..n] do
        for j in [1..i-1] do
            w := f[j]^-1 * f[i] * f[j];
            v := ExponentsOfPcElement( g, g[j]^-1 * g[i] * g[j] );
            for k in Reversed( [1..n] ) do
                w := w * f[k]^(-v[k]);
            od;
            rels[i][j] := w;
        od; 
        p := RelativeOrderOfPcElement( g, g[i] );
        w := f[i]^p;
        v := ExponentsOfPcElement( g, g[i]^p );
        for k in Reversed( [1..n] ) do
            w := w * f[k]^(-v[k]);
        od;
        rels[i][i] := w;
    od;
    return rec( group := F, relators := Concatenation( rels ) );
end );

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
InstallGlobalFunction( ExtensionSQ, function( C, G, M, c )
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
    return H;
end );

#############################################################################
##
#M  Extension( G, M, c )
##
InstallMethod( Extension,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsObject, IsVector ],
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
    [ CanEasilyComputePcgs, IsObject],
    0,
function( G, M )
    local C, ext, co, cc, c, i;

    C := CollectorSQ( G, M, false );
    ext := [ ExtensionSQ( C, G, M, 0 ) ];

    # compute the two cocycles
    co := TwoCohomologySQ( C, G, M );
    if Length( co ) = 0 then return
        [SplitExtension(G,M)];
    fi;

    cc := VectorSpace( M.field, co );
    for i in [2..Size(cc)] do
        c := AsList( cc )[i];
        Add( ext, ExtensionSQ( C, G, M, c ) );
    od;
    return ext;
end );

############################################################################
##
#F RelVectorToCocycle( vec, cohom )
##
RelVectorToCocycle := function( vec, cohom )
    local H, z, pcgsH, pcgsG, coc;
    H := ExtensionSQ( cohom.collector, cohom.group, cohom.module, vec );
    z := One( cohom.module.field );
    pcgsH := Pcgs( H );
    pcgsG := cohom.pcgs;
    coc := function( g, h )
        local gg, hh, gh;
        gg := MappedPcElement( g, pcgsG, pcgsH );
        hh := MappedPcElement( h, pcgsG, pcgsH );
        gh := gg * hh;
        return ExponentsOfPcElement( pcgsH, gh, 
               [Length( pcgsG )+1..Length( pcgsH )] ) * z;
    end;
    return coc;
end;

############################################################################
##
#F OnRelVector( vec, tup, cohom )
##
OnRelVector := function( vec, tup, cohom )
    local base, z, H, pcgsH, pcgsG, imgs, k, i, j, rel, tail, w, tails, 
          vecs, mapd, ords, m;

    base  := Concatenation( cohom.cohomology, cohom.coboundaries );
    z := One( cohom.module.field );

    # compute extensions
    H := ExtensionSQ( cohom.collector, cohom.group, cohom.module, vec );   
    pcgsH := Pcgs( H );
    pcgsG := cohom.pcgs;
    ords  := RelativeOrders( pcgsG );

    # map pcgs of G to H
    imgs := List( pcgsG, x -> x^Inverse( tup[1] ) );
    imgs := List( imgs, x -> MappedPcElement( x, pcgsG, pcgsH ) );

    # compute tails of relators in H
    k := 0;
    tails := [];
    for i in [1..Length(pcgsG)] do
        for j in [1..i] do

            # compute tail of relator
            k := k + 1;
            rel := cohom.fprelators[k];
            tail := MappedWord( rel, cohom.fpgens, imgs );

            # conjugating element
            if i = j then
                w := pcgsG[i]^ords[i];
            else
                w := pcgsG[i]^pcgsG[j];
            fi;
            m := MappedPcElement( w, pcgsG, imgs );
            Add( tails, tail^m );
        od;
    od;

    # compute corresponding vectors
    vecs := List( tails, x -> ExponentsOfPcElement( pcgsH, x, 
                   [Length(pcgsG)+1..Length(pcgsH)] ) * z );

    # apply matrix
    mapd := List( vecs, x -> x * tup[2] );

    return Concatenation( mapd );
end;

############################################################################
##
#F CocycleToRelVector( coc, cohom )
##
CocycleToRelVector := function( coc, cohom )
    local vec, gens, invs, pcgsG, rel, s, sub, i, w, t, n, m, r, ords, j,k,l;

    vec := [];
    gens := cohom.fpgens;
    invs := List( gens, x -> x^-1 );
    pcgsG := cohom.pcgs;
    ords  := RelativeOrders( pcgsG );
    
    k := 0;
    for i in [1..Length(pcgsG)] do
        for j in [1..i] do

            # compute tail
            k   := k + 1;
            rel := cohom.fprelators[k];
            s := Length( rel );
            sub := List( [1..cohom.module.dimension], 
                          x -> Zero( cohom.module.field));
            for l in [1..s] do

                # compute left side
                w := Subword( rel, l, l );
                r := MappedWord( w, gens, pcgsG );
   
                # compute right side
                if l = 1 then
                    t := Identity( cohom.group );
                else
                    t := Subword( rel, 1, l-1 );
                    t := MappedWord( t, gens, pcgsG );
                fi;
    
                # add to vector
                m := MappedPcElement( r, pcgsG, cohom.module.generators );
                sub := sub * m;
                sub := sub + coc( t, r );
                if w in invs then
                    sub := sub - coc( r, r^-1 );
                fi;
            od;

            # conjugating element
            if i = j then
                w := pcgsG[i]^ords[i];
            else
                w := pcgsG[i]^pcgsG[j];
            fi;
            m := MappedPcElement( w, pcgsG, cohom.module.generators);
            
            Append( vec, sub*m );
        od;
    od;
    return vec;
end;

############################################################################
##
#F OnCocycle( coc, tup, cohom )
##
OnCocycle := function( coc, tup, cohom )
    local inv, new;
    inv := Inverse( tup[1] );
    new := function( g, h )
        return coc( Image( inv, g ), Image( inv, h ) )*tup[2];
    end;
    return new;
end;

############################################################################
##
#F IsCocycle( coc, cohom )
##
IsCocycle := function( coc, cohom )
    local G, e, a, b, c, m, r, l;
    G := cohom.group;
    e := Enumerator( G );
    for c in e do
        m := MappedPcElement( c, cohom.pcgs, cohom.module.generators);
        for b in e do
            r := coc( b, c );
            for a in e do
                l := coc( a*b, c ) + coc( a, b )*m - coc( a, b*c);
                if not r = l then 
                    return false;
                fi;
            od;
        od;
        Print("next round \n");
    od;
    return true;
end;

############################################################################
##
#F CompatiblePairs( G, M )
#F CompatiblePairs( G, M, D )  ... D <= Aut(G) x GL
#F CompatiblePairs( G, M, D, flag ) ... D <= Aut(G) x GL normalises K
##
InstallGlobalFunction( CompatiblePairs, function( arg )
    local G, M, Mgrp, oper, A, B, D, K, f, tmp, i, tup;

    # catch arguments
    G := arg[1];
    M := arg[2];
    Mgrp := Group( M.generators );
    oper := GroupHomomorphismByImagesNC( G, Mgrp, Pcgs(G), M.generators );

    # automorphism groups of G and M
    if Length( arg ) = 2 then
        Info( InfoCompPairs, 1, "    CompP: compute aut group");
        A := AutomorphismGroup( G );
        B := GL( M.dimension, Characteristic( M.field ) );
        D := DirectProduct( A, B );
    else
        D := arg[3];
    fi;

    # if M is the trivial module
    if M.dimension = 1 and Size( Mgrp ) = 1 then
        return D;
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
        Info( InfoCompPairs, 1, "    CompP: found orbit of length ",
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
    Info( InfoCompPairs, 1, "    CompP: found orbit of length ",
          Length( tmp.orbit ));
    return D;
end );

#############################################################################
##
#F IsCompatiblePair( G, M, tup )
##
IsCompatiblePair := function( G, M, tup )
    local pcgs, imgs, hom, i, g, h, new;
    pcgs := Pcgs( G );
    imgs := M.generators;
    hom  := GroupHomomorphismByImagesNC( G, Group(imgs, imgs[1]^0),
                pcgs, imgs);
    if not IsGroupHomomorphism( hom ) then return false; fi;
    for i in [1..Length(pcgs)] do
        g := Image( hom, Image( tup[1], pcgs[i] ) );
        h := imgs[i]^tup[2];
        if g <> h then return false; fi;
    od;
    new := GroupHomomorphismByImagesNC( G, G, pcgs, 
           List( pcgs,x -> Image( tup[1], x ) ) );
    if not IsGroupHomomorphism( new ) and IsBijective( new ) then 
        return false;
    fi;
    return true;
end;

#############################################################################
##
#F MatrixOperationOfCP( cohom, tup )
##
MatrixOperationOfCP := function( cohom, tup )
    local l, mat, c, im, sol, base, coc, new;

    base := Concatenation( cohom.cohomology, cohom.coboundaries );
    l   := Length( cohom.cohomology );
    mat := [];
    for c in cohom.cohomology do
        im := OnRelVector( c, tup, cohom );
        Add( mat, im );
    od;
    sol := List( mat, x -> SolutionMat( base, x ) );

#    # if something has gone wrong
#    if ForAny( sol, x -> IsBool( x ) ) then 
#        mat := [];
#        for c in cohom.cohomology do
#            coc := RelVectorToCocycle( c, cohom );
#            new := OnCocycle( coc, tup, cohom );
#            im  := CocycleToRelVector( new, cohom );
#            Add( mat, im );
#        od;
#        sol := List( mat, x -> SolutionMat( base, x ) );
#    fi;

    if ForAny( sol, x -> IsBool( x ) ) then
        Error("no solution for matrix"); 
    fi;

    return sol{[1..l]}{[1..l]};
end;

#############################################################################
##
#M ExtensionRepresentatives( G, M, C )
##
InstallMethod( ExtensionRepresentatives,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsRecord, IsList ],
    0,
function( G, M, C )
    local cohom, ext, mats, Mgrp, orbs, V;

    cohom := TwoCohomology( G, M );

    # catch the trivial case
    if Length(cohom.cohomology) = 0 then
        return [ExtensionSQ( cohom.collector, G, M, 0 )];
    fi;

    mats := List( GeneratorsOfGroup( C ), 
                  x -> MatrixOperationOfCP( cohom, x ) );

    # compute orbit of mats on H^2( G, M )
    Mgrp := Group( mats );
    V    := FullRowSpace( M.field, Length(cohom.cohomology) );
    orbs := Orbits( Mgrp, V, OnRight );
    ext  := List( orbs, 
            x -> ExtensionSQ( cohom.collector, G, M, x[1]*cohom.cohomology ) );
    return ext;
end);

#############################################################################
##
#F MyIntCoefficients( p, d, w )
##
MyIntCoefficients := function( p, d, w )
    local v, int, i;
    v   := IntVecFFE( w );
    int := 0;
    for i in [1..d] do
        int := int * p + v[i];
    od;
    return int;
end;

#############################################################################
##
#F MatOrbsApprox( mats, dim, field ) . . . . . . . . . . . . underfull orbits 
##
MatOrbsApprox := function( mats, dim, field )
    local p, q, r, l, n, seen, reps, rest, i, v, orb, j, w, im, h, mat, rep,
          red;

    # set up 
    p := Characteristic( field );
    q := p^dim;
    r := p^dim - 1;
    l := List( [1..dim], x -> p );
    n := Length( mats );
   
    # set up large boolean list
    seen := [];
    seen[q] := false;
    for i in [1..q-1] do
        seen[i] := false;
    od;
    IsBlist( seen );

    reps := [];
    rest := r;
    red  := true;
    for i in [1..r] do
        if not seen[i] then

            seen[i] := true;
            v    := CoefficientsMultiadic( l, i );
            orb  := [v];
            rest := rest - 1;
            j    := 1;
            rep  := v;
            while j <= Length( orb ) do
                w := orb[j];
                for mat in mats do
                    im := w * mat;
                    h  := MyIntCoefficients( p, dim, im );
                    if not seen[h] then
                        seen[h] := true;
                        rest    := rest - 1;
                        Add( orb, im );
                    elif h < i then
                        rep := false;
                    fi;
                od;
                if rest = 0 then
                    j := Length( orb );
                elif Length(orb) > 60000 or IsBool( rep ) then
                    j := Length( orb );
                    red := false;
                fi;
                j := j + 1;
            od;
            if not IsBool( rep ) then
                Add( reps, rep );
            fi;
        fi;
    od;
    return rec( reps := reps * One( field ), red := red );
end;

#############################################################################
##
#F NonSplitExtensions( G, M [, reduce] ) 
##
NonSplitExtensions := function( arg )
    local G, M, C, co, cb, cc, cohom, mats, V, Mgrp, orbs, CP, all, i, red;

    # catch arguments
    G := arg[1];
    M := arg[2];

    # compute H^2(G, M)
    cohom := TwoCohomology( G, M );
    cc := cohom.cohomology;
    C  := cohom.collector;

    Info( InfoFrattExt, 5, "   dim(M) = ",M.dimension,
                                " char(M) = ", Characteristic(M.field),
                                " dim(H2) = ", Length(cc));

    # catch the trivial cases
    if Length(cc) = 0 then
        all := [];
        red := true;

    elif Length(cc) = 1 then
        all := [ExtensionSQ( C, G, M, cc[1] )];
        red := true;

    # if reduction is suppressed
    elif IsBound( arg[3] ) and not arg[3] then
        all := NormedVectors( VectorSpace( M.field, cc ) );
        all := List( all, x -> ExtensionSQ( cohom.collector, G, M, x ) );
        red := false;

    # sometimes we do not want to reduce
    elif not IsBound( arg[3] ) 
        and Characteristic( M.field )^Length(cc) < 10
        and not (HasIsFrattiniFree( G ) and IsFrattiniFree( G ))
        and not HasAutomorphismGroup( G )
    then
        all := NormedVectors( VectorSpace( M.field, cc ) );
        all := List( all, x -> ExtensionSQ( cohom.collector, G, M, x ) );
        red := false;

    # then we want to reduce
    else

        Info( InfoExtReps, 1, "   Ext: compute compatible pairs");
        CP := CompatiblePairs( G, M );

        Info( InfoExtReps, 1, "   Ext: compute linear action");
        mats := List( GeneratorsOfGroup( CP ),
                      x -> MatrixOperationOfCP( cohom, x ) );

        Info( InfoExtReps, 1, "   Ext: compute orbits ");
        orbs := MatOrbsApprox( mats, Length(mats[1]) , M.field );
        all  := orbs.reps;
        red  := orbs.red;
        Info( InfoExtReps, 1, "   Ext: found ",Length(all)," orbits ");

        # create extensions and add info
        all := List( all, x -> ExtensionSQ(cohom.collector, G, M, x*cc) );
    fi;

    if red then
        Info( InfoFrattExt, 5, "    found ",Length(all),
                               " extensions - reduced");
    else
        Info( InfoFrattExt, 5, "    found ",Length(all)," extensions ");
    fi;

    return rec( groups := all, reduced := red );
end;

#############################################################################
##
#F  SplitExtension( G, M )
#F  SplitExtension( G, aut, N )
##
InstallMethod( SplitExtension,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsObject ],
    0,
function( G, M )
    return Extension( G, M, 0 );
end );

InstallOtherMethod( SplitExtension,
    "generic method for pc groups",
    true, 
    [ CanEasilyComputePcgs, IsObject, CanEasilyComputePcgs ],
    0,
function( G, aut, N )
    local pcgsG, fpg, n, gensG, pcgsN, fpn, d, gensN, F, gensF, relators,
          rel, new, g, e, t, l, i, j, k, H, m, gensH,hom1,hom2, relsN, relsG;
    
    pcgsG := Pcgs( G );
    fpg   := Range( IsomorphismFpGroup( G ) );
    n     := Length( pcgsG );
    gensG := GeneratorsOfGroup( FreeGroupOfFpGroup( fpg ) );
    relsG := RelatorsOfFpGroup( fpg );

    pcgsN := Pcgs( N );
    fpn   := Range( IsomorphismFpGroup( N ) );
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
#F ConjugatingElement( G, inn )
##
ConjugatingElement := function( G, inn )
    local elm, C, g, h, n, gens, imgs, i;

    elm := Identity( G );
    C   := G;
    gens := GeneratorsOfGroup( G );
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
    [ CanEasilyComputePcgs, IsObject, IsInt ],
    0,
function( G, aut, p )
    local pcgs, n, R, gensR, F, gens, relators, pow, pre, powers, i, g,
          h, e, t, j, rel, new, H, grps;

    pcgs := Pcgs( G );
    n    := Length( pcgs );
    R    := Range( IsomorphismFpGroup( G ) );
    gensR := GeneratorsOfGroup( FreeGroupOfFpGroup( R ) );
    
    F := FreeGroup( n + 1 );
    gens := GeneratorsOfGroup( F );
    relators := [];
 
    # compute all possible powers of g
    pow := aut^p;
    pre := ConjugatingElement( G, pow );
    powers := List( AsList( Centre(G) ), x -> pre * x );
    powers := Filtered( powers, x -> Image( aut, x ) = x );
    grps   := List( powers, x -> false );

    # compute operation 
    for i in [1..n] do
        t := pcgs[i]^-1 * Image( aut, pcgs[i] );
        t := MappedPcElement( t, pcgs, gens{[2..n+1]} );
        Add( relators, Comm( gens[1], gens[i+1] ) * t );
    od;

    # add relators 
    Append( relators, List( RelatorsOfFpGroup( R ),
                      x -> MappedWord( x, gensR, gens{[2..n+1]} ) ) ); 

    # set up groups
    for i in [1..Length(powers)] do
        t := MappedPcElement( powers[i], pcgs, gens{[2..n+1]} );
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
    [ CanEasilyComputePcgs, IsInt ],
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
        cl := RationalClasses( F );
        cl := List( cl, Representative );
        cl := Filtered( cl, x -> x^p = One( F ) );

        # transfer back - 1. part
        cl := List( cl, x -> PreImagesRepresentative( nat, x ) );
    
        # transfer back - 2. part
        hom := GroupHomomorphismByImagesNC( P, A, GeneratorsOfGroup( P ),
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
