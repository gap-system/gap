#############################################################################
##
#W  Whitehd.gi               FGA package                    Christian Sievers
##
##  Computations with Whitehead automorphisms
##
#H  @(#)$Id: Whitehd.gi,v 1.1 2005/02/22 15:23:33 gap Exp $
##
#Y  2004 - 2005
##
Revision.("fga/lib/Whitehd_gi") :=
    "@(#)$Id: Whitehd.gi,v 1.1 2005/02/22 15:23:33 gap Exp $";

InstallMethod( FGA_WhiteheadAutomorphisms,
    "for finitely generated free groups",
    [ CanComputeWithInverseAutomaton ],
    function( G )
    local ngens, ngen, combs, auts, L, R;
    ngens := [ 1 .. RankOfFreeGroup( G ) ];
    auts := [];
    for ngen in ngens do
        combs := Combinations( Difference( ngens, [ngen] ));
        for L in combs do
            for R in combs do
                if  L <> []  or  R <> []  then
                    Add( auts, FGA_WhiteheadAutomorphism( G, ngen, L, R ));
                fi;
            od;
        od;
    od;
    return auts;
    end );


InstallMethod( FGA_NielsenAutomorphisms,
    "for finitely generated free groups",
    [ CanComputeWithInverseAutomaton ],
    G -> Filtered( f -> FGA_WhiteheadParams(f).isnielsen )  );


InstallGlobalFunction( FGA_WhiteheadAutomorphism,
    function( G, ngen, L, R )
    local gens, gen, ng, g, img, imginv, imgs, imgsinv, aut, autinv;
    imgs := [];
    imgsinv := [];
    gens := GeneratorsOfGroup( G );
    gen  := gens[ngen];
    for ng in [ 1 .. RankOfFreeGroup( G ) ] do
        img := gens[ng];
        imginv := img;
        if ng in L then
            img := LeftQuotient( gen, img );
            imginv := gen * imginv;
        fi;
        if ng in R then
            img := img * gen;
            imginv := imginv / gen;
        fi;
        Add( imgs, img );
        Add( imgsinv, imginv);
    od;
    aut    := GroupHomomorphismByImages( G, G, GeneratorsOfGroup(G), imgs );
    autinv := GroupHomomorphismByImages( G, G, GeneratorsOfGroup(G), imgsinv );
    SetInverse( aut, autinv );
    SetInverse( autinv, aut );
    SetFGA_WhiteheadParams( aut , rec( gen := ngen, L := L, R := R,
                                       isnielsen := Length(L)+Length(R)=1 ) );
    SetFGA_WhiteheadParams( autinv, true );
    return aut;
    end );


InstallGlobalFunction( FGA_WhiteheadAnalyse,
    function( whs, elm, act      , len      , val, comb     , combrest )
#            [w] * e  * (e*w->e) * (e->Int) * v  * (v*w->v) * (v*e->r)   -> r
    local l, newl, wh, bestwh , newelm, bestnewelm;
#         Int    , w , Maybe w, e
    l := len( elm );
    while true do
        bestwh := fail;
        for wh in whs do
            newelm := act( elm, wh );
            newl := len( newelm );
            if newl < l then
                l := newl;
                bestwh := wh;
                bestnewelm := newelm;
            fi;
        od;
        if bestwh=fail then
            return combrest( val, elm );
        fi;
        val := comb( val, bestwh );
        elm := bestnewelm;
    od;
    # not reached
    end );


########################################################################
# Equation numbers and pages refer to
#   Jakob Nielsen:  Die Isomorphismengruppe der freien Gruppen
# see ../doc/manual.bib
########################################################################

InstallGlobalFunction( FGA_WhiteheadToPQOU,
    function ( w , p , q , o , u )
    #          w * g * g * g * g   -> g

    local n ,g, whp, word, sign, nik;

    n := RankOfFreeGroup( Source ( w ) );
    if FGA_WhiteheadParams(w) = true then
        w := Inverse(w);
        sign := -1;
    else
        sign := 1;
    fi;
    whp:= FGA_WhiteheadParams(w);   
    word := One(p);
    for g in [ 1 .. n ] do
        if g in whp.L or g in whp.R then
            # using and possibly combining eq. (12) and (11)
            # for V_{g,gen}^-1 and U_{g,gen}
            nik := FGA_NikToPQ( g, whp.gen, p, q );
            word := word * nik^-1;
            if g in whp.L then
                word := word * o * u^sign * o;
                # eq. (7)
            fi;
            if g in whp.R then
                word := word * u^sign;
            fi;
            word := word * nik;
        fi;
    od;
    return word;
    end );

InstallGlobalFunction( FGA_NikToPQ,
    function( i   , k , p , q )
    #         Int * g * g * g   -> g
    # eq. (8)

    local l;
    l := k-i;
    if i<k then
        l := l-1;
    fi;
    return (q*p)^l * q^(i-1);
    end );

InstallGlobalFunction( FGA_TiToPQ,
    function( i   , p , q )
    #         Int * g * g   -> g
    # follows from eq. at the middle of page 171

    return q^(2-i)*p*(q*p)^(i-2);
    end );

InstallGlobalFunction( FGA_ExtSymListRepToPQO,
    function( target, p , q , o )
#             [Int] * g * g * g   -> g
    local rank, word1, word2, lastshift, i, t,
          f2, P, Q, Pperm, Qperm, homperm, homrep, perm;

    f2 := FreeGroup("P","Q");
    P := f2.1;  Q := f2.2;

    word1 := One(p);
    word2 := word1;
    rank := Length( target );
    Pperm := (1,2);
    Qperm := PermList(Concatenation([2..rank],[1]));
    homperm := GroupHomomorphismByImages( f2,
                                          SymmetricGroup( rank ), 
                                          GeneratorsOfGroup(f2),
                                          [ Pperm, Qperm ] );
    homrep  := GroupHomomorphismByImages( f2,
                                          Group( p, q ),
                                          GeneratorsOfGroup( f2 ),
                                          [ p, q ] );

    # first get rid of extendedness, using o and q
    lastshift := 1;
    for i in [ 1 .. rank ] do
        if not IsPosInt( target[i] ) then
            word1 := word1 * q^(lastshift-i) * o;
            lastshift := i;
            target[i] := AbsInt(target[i]);
        fi;
    od;
    word1 := word1 * q^(lastshift-1);

    # now target is a permutation, represent it as such
    target := SortingPerm(target);

    # decompose it as product of powers of T_i, compare p. 171
    while  not IsOne( target )  do
        i := LargestMovedPoint( target );
        t := i^target;
        perm := FGA_TiToPQ( i, P, Q );
        word2 := (perm^homrep)^(t-i) * word2;
        target := target * (perm^homperm)^(i-t);
    od;
    return word1*word2;
    end );

InstallGlobalFunction( FGA_CurryAutToPQOU,
    function( p, q, o, u)
        return 
            function( aut )
            local fg, words, wh;
            fg := Source( aut );
            words := List( GeneratorsOfGroup( fg ), gen -> gen ^ aut );
            wh := FGA_WhiteheadAutomorphisms( fg );
            # use Nielsen generators only
            wh := Filtered( wh, f -> FGA_WhiteheadParams(f).isnielsen );
            wh := Concatenation( wh, List( wh, Inverse ));
            return FGA_WhiteheadAnalyse( wh, words, OnTuples,
                l -> Sum( l, Length ),
                One( p ),
                function( v, w ) 
                    return FGA_WhiteheadToPQOU( Inverse(w), p, q, o, u ) * v;
                end,
                function( v, e )
                    e := List( e, g -> LetterRepAssocWord(g)[1] );
                    return FGA_ExtSymListRepToPQO( e, p, q, o ) * v;
                end );
            end;
    end );
