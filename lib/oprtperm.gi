#############################################################################
##
#W  oprtperm.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#H  $Log$
#H  Revision 4.26  1997/04/15 10:28:06  htheisse
#H  more detailed checks in `RepresentativeOperation'
#H
#H  Revision 4.25  1997/04/14 08:31:35  htheisse
#H  corrected some requirements
#H
#H  Revision 4.24  1997/03/18 09:10:26  htheisse
#H  corrected `RepresentativeOperation' for perm groups
#H
#H  Revision 4.23  1997/03/17 14:20:53  htheisse
#H  added generic method for `OrbitStabilizer'
#H
#H  Revision 4.22  1997/03/04 16:04:48  htheisse
#H  checked the `oprt*' functions against the descriptions of the 3.4 manual
#H
#H  Revision 4.21  1997/02/26 13:59:28  htheisse
#H  reorganised methods for `MaximalBlocks'
#H
#H  Revision 4.20  1997/02/12 14:58:52  htheisse
#H  renamed `IsomorphismPermGroup' to `IsomorphismPermGroups'
#H
#H  Revision 4.19  1997/02/06 09:53:48  htheisse
#H  moved a `Transitivity' method here
#H
#H  Revision 4.18  1997/01/29 15:54:30  mschoene
#H  fixed a few more doubly defined locals
#H
#H  Revision 4.17  1997/01/27 11:21:08  htheisse
#H  removed some of Juergen Mnich's code
#H
#H  Revision 4.16  1997/01/09 17:56:21  htheisse
#H  workaround till `false in [1,2]' works
#H
#H  Revision 4.15  1997/01/09 16:31:39  ahulpke
#H  Added StabilizerOfBlockNC
#H
#H  Revision 4.14  1996/12/13 12:17:52  htheisse
#H  patched `Transitivity' into working
#H
##
Revision.oprtperm_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  Orbit( <G>, <pnt>, <gens>, <oprs>, <OnPoints> ) . . . . . . . on integers
##
InstallOtherMethod( OrbitOp,
        "G, int, gens, perms, opr", true,
        [ IsPermGroup, IsInt,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, oprs, opr )
    if gens <> oprs  or  opr <> OnPoints  then
        TryNextMethod();
    fi;
    if HasStabChain( G )  and  IsInBasicOrbit( StabChainAttr( G ), pnt )  then
        return StabChainImmAttr( G ).orbit;
    else
        return Immutable( OrbitPerms( oprs, pnt ) );
    fi;
end );

#############################################################################
##
#M  OrbitStabilizer( <G>, <pnt>, <gens>, <oprs>, <OnPoints> ) . . on integers
##
InstallOtherMethod( OrbitStabilizerOp,
        "G, int, gens, perms, opr", true,
        [ IsPermGroup, IsInt,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, oprs, opr )
    local   S;
    
    if gens <> oprs  or  opr <> OnPoints  then
        TryNextMethod();
    fi;
    S := StabChain( G, [ pnt ] );
    if BasePoint( S ) = pnt  then
        return Immutable( rec( orbit := S.orbit,
                          stabilizer := GroupStabChain
                                        ( G, S.stabilizer, true ) ) );
    else
        return Immutable( rec( orbit := [ pnt ],
                          stabilizer := G ) );
    fi;
end );

#############################################################################
##
#M  Orbits( <G>, <D>, <gens>, <oprs>, <OnPoints> )  . . . . . . . on integers
##
InstallMethod( OrbitsOp,
        "G, ints, gens, perms, opr", true,
        [ IsGroup, IsList and IsCyclotomicsCollection,
          IsList,
          IsList and IsPermCollection,
          IsFunction ], 0,
    function( G, D, gens, oprs, opr )
    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    return Immutable( OrbitsPerms( oprs, D ) );
end );

#############################################################################
##
#M  Cycle( <g>, <pnt>, <OnPoints> ) . . . . . . . . . . . . . . . on integers
##
InstallOtherMethod( CycleOp,
        "perm, int, opr", true,
        [ IsPerm, IsInt, IsFunction ], 0,
    function( g, pnt, opr )
    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    return Immutable( CyclePermInt( g, pnt ) );
end );

#############################################################################
##
#M  CycleLength( <g>, <pnt>, <OnPoints> ) . . . . . . . . . . . . on integers
##
InstallOtherMethod( CycleLengthOp,
        "perm, int, opr", true,
        [ IsPerm, IsInt, IsFunction ], 0,
    function( g, pnt, opr )
    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    return CycleLengthPermInt( g, pnt );
end );

#############################################################################
##
#M  Blocks( <G>, <D>, <gens>, <oprs>, <OnPoints> )  . . . . find block system
##
InstallMethod( BlocksOp,
        "G, ints, gens, perms, opr", true,
        [ IsGroup, IsList and IsCyclotomicsCollection, IsList and IsEmpty,
          IsList,
          IsList and IsPermCollection,
          IsFunction ], 0,
    function( G, D, noseed, gens, oprs, opr )
    local   blocks,     # block system of <G>, result
            orbit,      # orbit of 1 under <G>
            trans,      # factored inverse transversal for <orbit>
            eql,        # '<i> = <eql>[<k>]' means $\beta(i)  = \beta(k)$,
            next,       # the points that are equivalent are linked
            last,       # last point on the list linked through 'next'
            leq,        # '<i> = <leq>[<k>]' means $\beta(i) <= \beta(k)$
            gen,        # one generator of <G> or 'Stab(<G>,1)'
            rnd,        # random element of <G>
            pnt,        # one point in an orbit
            img,        # the image of <pnt> under <gen>
            cur,        # the current representative of an orbit
            rep,        # the representative of a block in the block system
            block,      # the block, result
            changed,    # number of random Schreier generators
            nrorbs,     # number of orbits of subgroup $H$ of $G_1$
            i;          # loop variable

    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    
    # handle trivial group
    if Length( oprs ) = 0  then
        Error("<G> must operate transitively on <D>");
    fi;

    # handle trivial domain
    if Length( D ) = 1  or IsPrimeInt( Length( D ) )  then
        return Immutable( [ D ] );
    fi;
 
    # compute the orbit of $G$ and a factored transversal
    orbit := [ D[1] ];
    trans := [];
    trans[ D[1] ] := ();
    for pnt  in orbit  do
        for gen  in oprs  do
            if not IsBound( trans[ pnt / gen ] )  then
                Add( orbit, pnt / gen );
                trans[ pnt / gen ] := gen;
            fi;
        od;
    od;

    # check that the group is transitive
    if Length( orbit ) <> Length( D )  then
        Error("<G> must operate transitively on <D>");
    fi;
    Info( InfoOperation, 1, "BlocksNoSeed transversal computed" );
    nrorbs := Length( orbit );

    # since $i \in k^{G_1}$ implies $\beta(i)=\beta(k)$,  we initialize <eql>
    # so that the connected components are orbits of some subgroup  $H < G_1$
    eql := [];
    leq := [];
    next := [];
    last := [];
    for pnt  in orbit  do
        eql[pnt]  := pnt;
        leq[pnt]  := pnt;
        next[pnt] := 0;
        last[pnt] := pnt;
    od;

    # repeat until we have a block system
    changed := 0;
    cur := orbit[2];
    rnd := ();
    repeat

        # compute such an $H$ by taking random  Schreier generators  of $G_1$
        # and stop if 2 successive generators dont change the orbits any more
        while changed < 2  do

            # compute a random Schreier generator of $G_1$
            i := Length( orbit );
            while 1 <= i  do
                rnd := rnd * Random( oprs );
                i   := QuoInt( i, 2 );
            od;
            gen := rnd;
            while D[1] ^ gen <> D[1]  do
                gen := gen * trans[ D[1] ^ gen ];
            od;
            changed := changed + 1;

            # compute the image of every point under <gen>
            for pnt  in orbit  do
                img := pnt ^ gen;

                # find the representative of the orbit of <pnt>
                while eql[pnt] <> pnt  do
                    pnt := eql[pnt];
                od;

                # find the representative of the orbit of <img>
                while eql[img] <> img  do
                    img := eql[img];
                od;

                # if the don't agree merge their orbits
                if   pnt < img  then
                    eql[img] := pnt;
                    next[ last[pnt] ] := img;
                    last[pnt] := last[img];
                    nrorbs := nrorbs - 1;
                    changed := 0;
                elif img < pnt  then
                    eql[pnt] := img;
                    next[ last[img] ] := pnt;
                    last[img] := last[pnt];
                    nrorbs := nrorbs - 1;
                    changed := 0;
                fi;

            od;

        od;
        Info( InfoOperation, 1, "BlocksNoSeed ",
                       "number of orbits of <H> < <G>_1 is ",nrorbs );

        # take arbitrary point <cur>,  and an element <gen> taking 1 to <cur>
        while eql[cur] <> cur  do
            cur := eql[cur];
        od;
        gen := [];
        img := cur;
        while img <> D[1]  do
            Add( gen, trans[img] );
            img := img ^ trans[img];
        od;
        gen := Reversed( gen );

        # compute an alleged block as orbit of 1 under $< H, gen >$
        pnt := cur;
        while pnt <> 0  do

            # compute the representative of the block containing the image
            img := pnt;
            for i  in gen  do
                img := img / i;
            od;
            while eql[img] <> img  do
                img := eql[img];
            od;

            # if its not our current block but a minimal block
            if   img <> D[1]  and img <> cur  and leq[img] = img  then

                # then try <img> as a new start
                leq[cur] := img;
                cur := img;
                gen := [];
                img := cur;
                while img <> D[1]  do
                    Add( gen, trans[img] );
                    img := img ^ trans[img];
                od;
                gen := Reversed( gen );
                pnt := cur;

            # otherwise if its not our current block but contains it
            # by construction a nonminimal block contains the current block
            elif img <> D[1]  and img <> cur  and leq[img] <> img  then

                # then merge all blocks it contains with <cur>
                while img <> cur  do
                    eql[img] := cur;
                    next[ last[cur] ] := img;
                    last[ cur ] := last[ img ];
                    img := leq[img];
                    while img <> eql[img]  do
                        img := eql[img];
                    od;
                od;
                pnt := next[pnt];

            # go on to the next point in the orbit
            else

                pnt := next[pnt];

            fi;

        od;

        # make the alleged block
        block := [ D[1] ];
        pnt := cur;
        while pnt <> 0  do
            Add( block, pnt );
            pnt := next[pnt];
        od;
        block := Set( block );
        blocks := [ block ];
        Info( InfoOperation, 1, "BlocksNoSeed ",
                       "length of alleged block is ",Length(block) );

        # quick test to see if the group is primitive
        if Length( block ) = Length( orbit )  then
            Info( InfoOperation, 1, "BlocksNoSeed <G> is primitive" );
            return Immutable( [ D ] );
        fi;

        # quick test to see if the orbit can be a block
        if Length( orbit ) mod Length( block ) <> 0  then
            Info( InfoOperation, 1, "BlocksNoSeed ",
                           "alleged block is clearly not a block" );
            changed := -1000;
        fi;

        # '<rep>[<i>]' is the representative of the block containing <i>
        rep := [];
        for pnt  in orbit  do
            rep[pnt] := 0;
        od;
        for pnt  in block  do
            rep[pnt] := 1;
        od;

        # compute the block system with an orbit algorithm
        i := 1;
        while 0 <= changed  and i <= Length( blocks )  do

            # loop over the generators
            for gen  in oprs  do

                # compute the image of the block under the generator
                img := OnSets( blocks[i], gen );

                # if this block is new
                if rep[ img[1] ] = 0  then

                    # add the new block to the list of blocks
                    Add( blocks, img );

                    # check that all points in the image are new
                    for pnt  in img  do
                        if rep[pnt] <> 0  then
                            Info( InfoOperation, 1, "BlocksNoSeed ",
                                           "alleged block is not a block" );
                            changed := -1000;
                        fi;
                        rep[pnt] := img[1];
                    od;

                # if this block is old
                else

                    # check that all points in the image lie in the block
                    for pnt  in img  do
                        if rep[pnt] <> rep[img[1]]  then
                           Info( InfoOperation, 1, "BlocksNoSeed ",
                                           "alleged block is not a block" );
                            changed := -1000;
                        fi;
                    od;

                fi;

            od;

            # on to the next block in the orbit
            i := i + 1;
        od;

    until 0 <= changed;

    # return the block system
    return Immutable( blocks );
end );

#############################################################################
##
#M  Blocks( <G>, <D>, <seed>, <gens>, <oprs>, <OnPoints> )   blocks with seed
##
InstallMethod( BlocksOp,
        "G, ints, seed, gens, perms, opr", true,
        [ IsGroup, IsList and IsCyclotomicsCollection,
          IsList and IsCyclotomicsCollection,
          IsList,
          IsList and IsPermCollection,
          IsFunction ], 0,
    function( G, D, seed, gens, oprs, opr )
    local   blks,       # list of blocks, result
            rep,        # representative of a point
            siz,        # siz[a] of the size of the block with rep <a>
            fst,        # first point still to be merged into another block
            nxt,        # next  point still to be merged into another block
            lst,        # last  point still to be merged into another block
            gen,        # generator of the group <G>
            nrb,        # number of blocks so far
            a, b, c, d; # loop variables for points

    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    
    nrb := Length(D) - Length(seed) + 1;

    # in the beginning each point <d> is in a block by itself
    rep := [];
    siz := [];
    for d  in D  do
        rep[d] := d;
        siz[d] := 1;
    od;

    # except the points in <seed>, which form one block with rep <seed>[1]
    fst := 0;
    nxt := siz;
    lst := 0;
    c   := seed[1];
    for d  in seed  do
        if d <> c  then
            rep[d] := c;
            siz[c] := siz[c] + siz[d];
            if fst = 0  then
                fst      := d;
            else
                nxt[lst] := d;
            fi;
            lst      := d;
            nxt[lst] := 0;
        fi;
    od;

    # while there are points still to be merged into another block
    while fst <> 0  do

        # get this point <a> and its repesentative <b>
        a := fst;
        b := rep[fst];

        # for each generator <gen> merge the blocks of <a>^<gen>, <b>^<gen>
        for gen  in oprs  do
            c := a^gen;
            while rep[c] <> c  do
                c := rep[c];
            od;
            d := b^gen;
            while rep[d] <> d  do
                d := rep[d];
            od;
            if c <> d  then
                if Length(D) < 2*(siz[c] + siz[d])  then
                    return Immutable( [ D ] );
                fi;
                nrb := nrb - 1;
                if siz[d] <= siz[c]  then
                    rep[d]   := c;
                    siz[c]   := siz[c] + siz[d];
                    nxt[lst] := d;
                    lst      := d;
                    nxt[lst] := 0;
                else
                    rep[c]   := d;
                    siz[d]   := siz[d] + siz[c];
                    nxt[lst] := c;
                    lst      := c;
                    nxt[lst] := 0;
                fi;
            fi;
        od;

        # on to the next point still to be merged into another block
        fst := nxt[fst];
    od;

    # turn the list of representatives <rep> into a list of blocks <blks>
    blks := [];
    for d  in D  do
        c := d;
        while rep[c] <> c  do
           c := rep[c];
        od;
        if IsInt( nxt[c] )  then
            nxt[c] := [ d ];
            Add( blks, nxt[c] );
        else
            AddSet( nxt[c], d );
        fi;
    od;

    # return the set of blocks <blks>
    return Immutable( Set( blks ) );
end );

#############################################################################
##

#M  Earns( <G>, <Omega> ) . . . . . . . . . . earns of affine primitive group
##
InstallMethod( EarnsOp,
        "G, ints, gens, perms, opr", true,
        [ IsPermGroup, IsList,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, Omega, gens, oprs, opr )
    local   pcgs,  n,  fac,  p,  d,  alpha,  beta,  G1,  G2,  orb,
            Gamma,  M,  C,  f,  P,  Q,  Q0,  R,  R0,  pre,  gen,  g,
            ord,  pa,  a,  x,  y,  z;

    if gens <> oprs  or  opr <> OnPoints  then
        TryNextMethod();
    fi;
    
    n := Length( Omega );
    if not IsPrimePowerInt( n )  then
        return fail;
    elif not IsPrimitive( G, Omega )  then
        Error( "sorry, cannot compute the earns for imprimitive groups" );
    fi;
    
    # Try a shortcut for solvable groups (or if a solvable normal subgroup is
    # found).
    if DefaultStabChainOptions.tryPcgs  then
        pcgs := TryPcgsPermGroup( G, false, false, true );
        if not IsPcgs( pcgs )  then
            pcgs := pcgs[ 1 ];
        fi;
        if not IsEmpty( pcgs )  then
            return ElementaryAbelianSeries( pcgs )
                   [ Length( ElementaryAbelianSeries( pcgs ) ) - 1 ];
        fi;
    fi;
    
    fac := FactorsInt( n );  p := fac[ 1 ];  d := Length( fac );
    alpha := BasePoint( StabChainAttr( G ) );
    G1 := Stabilizer( G, alpha );
    
    # If <G1> is regular, it must be cyclic of prime order.
    if IsTrivial( G1 )  then
        return G;
    fi;
    
    # If <G1> is not a Frobenius group ...
    for orb  in Orbits( G1, Omega )  do
        beta := orb[ 1 ];
        if beta <> alpha  then
            G2 := Stabilizer( G1, beta );
            if not IsTrivial( G2 )  then
                Gamma := Filtered( Omega, p -> ForAll( GeneratorsOfGroup( G2 ),
                                 g -> p ^ g = p ) );
                if not IsPrimePowerInt( Length( Gamma ) )  then
                    return fail;
                fi;
                C := Centralizer( G, G2 );
                f := OperationHomomorphism( C, Gamma );
                P := PCore( ImagesSource( f ), p );
                if not IsTransitive( P, [ 1 .. Length( Gamma ) ] )  then
                    return fail;
                fi;
                gens := [  ];
                for gen  in GeneratorsOfGroup( Centre( P ) )  do
                    pre := PreImagesRepresentative( f, gen );
                    ord := Order( pre );  pa := 1;
                    while ord mod p = 0  do
                        ord := ord / p;
                        pa := pa * p;
                    od;
                    pre := pre ^ ( ord * Gcdex( pa, ord ).coeff2 );
                    for g  in GeneratorsOfGroup( C )  do
                        z := Comm( g, pre );
                        if z <> One( C )  then
                            M := SolvableNormalClosurePermGroup( G, [ z ] );
                            if M <> fail  and  Size( M ) = n  then
                                return M;
                            else
                                return fail;
                            fi;
                        fi;
                    od;
                    Add( gens, pre );
                od;
                Q := SylowSubgroup( Centre( G2 ), p );
                 
                # This is unnecessary  if   you trust the   classification of
                # finite simple groups.
                if Size( Q ) > p ^ ( d - 1 )  then  
                    return fail;
                fi;
                
                R := ClosureGroup( Q, gens );
                R0 := OmegaPN( R, p, 1 );
                y := First( GeneratorsOfGroup( R0 ),
                            y -> not # y in Q = Centre(G2)
                            (     alpha ^ y = alpha
                              and beta  ^ y = beta
                              and ForAll( GeneratorsOfGroup( G2 ),
                                      gen -> gen ^ y = gen ) ) );
                Q0 := OmegaPN( Q, p, 1 );
                for z  in Q0  do
                    M := SolvableNormalClosurePermGroup( G, [ y * z ] );
                    if M <> fail  and  Size( M ) = n  then
                        return M;
                    fi;
                od;
                return fail;
            fi;
        fi;
    od;
    
    # <G> is a Frobenius group.
    a := GeneratorsOfGroup( Centre( G1 ) )[ 1 ];
    x := First( GeneratorsOfGroup( G ), gen -> alpha ^ gen <> alpha );
    z := Comm( a, a ^ x );
    M := SolvableNormalClosurePermGroup( G, [ z ] );
    return M;

end );
    
#############################################################################
##
#M  TransitivityOp( <G>, <D>, <gens>, <oprs>, <opr> ) . . . . . . on integers
##
InstallMethod( TransitivityOp,
        "G, ints, gens, perms, opr", true,
        [ IsPermGroup, IsList and IsCyclotomicsCollection,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, D, gens, oprs, opr )
    if gens <> oprs  or  opr <> OnPoints  then
        TryNextMethod();
    
    elif not IsTransitiveOp( G, D, gens, oprs, opr )  then
        return 0;
    else
        G := StabilizerOp( G, D[ 1 ], opr );
        gens := GeneratorsOfGroup( G );
        return TransitivityOp( G, D{ [ 2 .. Length( D ) ] },
                       gens, gens, opr ) + 1;
    fi;
end );

#############################################################################
##
#M  IsSemiRegular( <G>, <D>, <gens>, <oprs>, <opr> )  . . . . for perm groups
##
InstallMethod( IsSemiRegularOp,
        "G, ints, gens, perms, opr", true,
        [ IsGroup, IsList and IsCyclotomicsCollection,
          IsList,
          IsList and IsPermCollection,
          IsFunction ], 0,
    function( G, D, gens, oprs, opr )
    local   used,       #
            perm,       #
            orbs,       # orbits of <G> on <D>
            gen,        # one of the generators of <G>
            orb,        # orbit of '<D>[1]'
            pnt,        # one point in the orbit
            new,        # image of <pnt> under <gen>
            img,        # image of '<prm>[<i>][<pnt>]' under <gen>
            p, n,       # loop variables
            i, l;       # loop variables
    
    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    
    # compute the orbits and check that they all have the same length
    orbs := OrbitsOp( G, D, gens, oprs, OnPoints );
    if Length( Set( List( orbs, Length ) ) ) <> 1  then
        return false;
    fi;
    
    # initialize the permutations that act like the generators
    used := [];
    perm := [];
    for i  in [ 1 .. Length( oprs ) ]  do
        used[i] := [];
        perm[i] := [];
        for pnt  in orbs[1]  do
            used[i][pnt] := false;
        od;
        perm[i][ orbs[1][1] ] := orbs[1][1] ^ oprs[i];
        used[i][ orbs[1][1] ^ oprs[i] ] := true;
    od;
    
    # initialize the permutation that permutes the orbits
    l := Length( oprs ) + 1;
    used[l] := [];
    perm[l] := [];
    for orb  in orbs  do
        for pnt  in orb  do
            used[l][pnt] := false;
        od;
    od;
    for i  in [ 1 .. Length(orbs)-1 ]  do
        perm[l][orbs[i][1]] := orbs[i+1][1];
        used[l][orbs[i+1][1]] := true;
    od;
    perm[l][orbs[Length(orbs)][1]] := orbs[1][1];
    used[l][orbs[1][1]] := true;
    
    # compute the orbit of the first representative
    orb := [ orbs[1][1] ];
    for pnt  in orb  do
        for gen  in oprs  do
    
            # if the image is new
            new := pnt ^ gen;
            if not new in orb  then
    
                # add the new element to the orbit
                Add( orb, new );
    
                # extend the permutations that act like the generators
                for i  in [ 1 .. Length( oprs ) ]  do
                    img := perm[i][pnt] ^ gen;
                    if used[i][img]  then
                        return false;
                    else
                        perm[i][new] := img;
                        used[i][img] := true;
                    fi;
                od;
    
                # extend the permutation that permutates the orbits
                p := pnt;
                n := new;
                for i  in [ 1 .. Length( orbs ) ]  do
                    img := perm[l][p] ^ gen;
                    if used[l][img]  then
                        return false;
                    else
                        perm[l][n] := img;
                        used[l][img] := true;
                    fi;
                    p := perm[l][p];
                    n := img;
                od;
    
            fi;
    
        od;
    od;
    
    # check that the permutations commute with the generators
    for i  in [ 1 .. Length( oprs ) ]  do
        for gen  in oprs  do
            for pnt  in orb  do
                if perm[i][pnt] ^ gen <> perm[i][pnt ^ gen]  then
                    return false;
                fi;
            od;
        od;
    od;
    
    # check that the permutation commutes with the generators
    for gen  in oprs  do
        for orb  in orbs  do
            for pnt  in orb  do
                if perm[l][pnt] ^ gen <> perm[l][pnt ^ gen]  then
                    return false;
                fi;
            od;
        od;
    od;
    
    # everything is ok, the representation is semiregular
    return true;
    
end );

#############################################################################
##
#M  RepresentativeOperation( <G>, <d>, <e>, <opr> ) . . . . . for perm groups
##
InstallOtherMethod( RepresentativeOperationOp, true, [ IsPermGroup,
        IsObject, IsObject, IsFunction ], 0,
    function ( G, d, e, opr )
    local   rep,                # representative, result
            r,                  # slice of the representative
            S,                  # stabilizer of <G>
            rep2,               # representative in <S>
            i,  f;              # loop variables

    # standard operation on points, make a basechange and trace the rep
    if opr = OnPoints and IsInt( d ) and IsInt( e )  then
        d := [ d ];  e := [ e ];
        S := true;
    elif     ( opr = OnPairs or opr = OnTuples )
         and IsPositionsList( d ) and IsPositionsList( e )  then
        S := true;
    fi;
    if IsBound( S )  then
        if d = e  then
            rep := One( G );
        else
            S := StabChainOp( G, d );
            rep := S.identity;
            for i  in [ 1 .. Length( d ) ]  do
                if BasePoint( S ) = d[ i ]  then
                    f := e[ i ] / rep;
                    if not IsInBasicOrbit( S, f )  then
                        rep := fail;
                        break;
                    else
                        rep := LeftQuotient( InverseRepresentative( S, f ),
                                       rep );
                    fi;
                    S := S.stabilizer;
                elif e[ i ] <> d[ i ] ^ rep  then
                    rep := fail;
                    break;
                fi;
            od;
        fi;

    # operation on (lists of) permutations, use backtrack
    elif opr = OnPoints and IsPerm( d ) and IsPerm( e )  then
        rep := RepOpElmTuplesPermGroup( true, G, [ d ], [ e ],
                       TrivialSubgroup( G ), TrivialSubgroup( G ) );
    elif     ( opr = OnPairs or opr = OnTuples )
         and IsList( d ) and IsPermCollection( d )
         and IsList( e ) and IsPermCollection( e )  then
        rep := RepOpElmTuplesPermGroup( true, G, d, e,
                       TrivialSubgroup( G ), TrivialSubgroup( G ) );

    # operation on permgroups, use backtrack
    elif opr = OnPoints and IsPermGroup( d ) and IsPermGroup( e )  then
        rep := IsomorphismPermGroups( G, d, e );

    # operation on pairs on tuples of other objects, iterate
    elif opr = OnPairs  or opr = OnTuples  then
        rep := One( G );
        S   := G;
        i   := 1;
        while i <= Length(d)  and rep <> fail  do
            if e[i] = fail  then
                rep := fail;
            else
                rep2 := RepresentativeOperationOp( S, d[i], e[i]^(rep^-1),
                                OnPoints );
                if rep2 <> fail  then
                    rep := rep2 * rep;
                    S   := StabilizerOp( S, d[i], OnPoints );
                else
                    rep := fail;
                fi;
            fi;
            i := i + 1;
        od;

    # operation on sets of points, use backtrack
    elif opr = OnSets and IsPositionsList( d ) and IsPositionsList( e )  then
        rep := RepOpSetsPermGroup( G, d, e );

    # other operation, fall back on default representative
    else
        TryNextMethod();
    fi;

    # return the representative
    return rep;
end );

#############################################################################
##
#M  Stabilizer( <G>, <d>, <opr> ) . . . . . . . . . . . . . . for perm groups
##
InstallOtherMethod( StabilizerOp,
        "P, pnt, opr", true,
        [ IsPermGroup, IsObject, IsFunction ], 0,
    function( G, d, opr )
    local   K,          # stabilizer <K>, result
            S,  base;

    # standard operation on points, make a stabchain beginning with <d>
    if opr = OnPoints and IsInt( d )  then
        base := [ d ];
    elif     ( opr = OnPairs or opr = OnTuples )
         and IsPositionsList( d )  then
        base := d;
    fi;
    if IsBound( base )  then
        K := StabChainOp( G, base );
        S := K;
        while IsBound( S.orbit )  and  S.orbit[ 1 ] in base  do
            S := S.stabilizer;
        od;
        if IsIdentical( S, K )  then  K := G;
                                else  K := GroupStabChain( G, S, true );  fi;
                            
    # standard operation on (lists of) permutations, take the centralizer
    elif opr = OnPoints  and IsPerm( d )  then
        K := Centralizer( G, d );
    elif     ( opr = OnPairs or opr = OnTuples )
         and IsList( d ) and IsPermCollection( d )  then
        K := RepOpElmTuplesPermGroup( false, G, d, d,
                     TrivialSubgroup( G ), TrivialSubgroup( G ) );

    # standard operation on a permutation group, take the normalizer
    elif opr = OnPoints  and IsPermGroup(d)  then
        K := Normalizer( G, d );

    # operation on sets of points, use a backtrack
    elif opr = OnSets  and ForAll( d, IsInt )  then
        K := RepOpSetsPermGroup( G, d );

    # other operation
    else
        TryNextMethod();
    fi;

    # return the stabilizer
    return K;
end );


#############################################################################
##
#F  StabilizerOfBlockNC( <G>, <B> )  . . . . block stabilizer for perm groups
##
StabilizerOfBlockNC := function(G,B)
local S,j;
  S:=StabChainOp(G,rec(base:=[B[1]],reduced:=false));
  S:=DeepCopy(S);

  # Make <S> the stabilizer of the block <B>.
  InsertTrivialStabilizer(S.stabilizer,B[1]);
  j := 1;
  while                                j < Length( B )
	and Length( S.stabilizer.orbit ) < Length( B )  do
      j := j + 1;
      if IsBound( S.translabels[ B[ j ] ] )  then
	  AddGeneratorsExtendSchreierTree( S.stabilizer,
		  [ InverseRepresentative( S, B[ j ] ) ] );
      fi;
  od;
  return GroupStabChain(G,S.stabilizer,true);
end;

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  oprtperm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

