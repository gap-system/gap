#############################################################################
##
#W  grpcom.gi                    Polycyc                         Bettina Eick
##

##
## computing conjugacy classes of complements
##

#############################################################################
##
#F PushVector( mats, invs, one, coc, exp )
##
PushVector := function( mats, invs, one, coc, exp )
    local n, m, i, e, j;

    n := 0 * coc[1];
    m := one;

    # parse coc trough exp under action of matrixes
    for i in Reversed( [1..Length(exp)] ) do
        e := exp[i]; 
        if e > 0 then
            for j in [1..e] do
                n := n + coc[i] * m;
                m := mats[i] * m;
            od;
        elif e < 0 then
            for j in [1..-e] do
                m := invs[i] * m;
                n := n - coc[i] * m;
            od;
        fi;
    od;
    return n;
end;

#############################################################################
##
#F EvaluateCocycle( C, coc, exp )
##
EvaluateCocycle := function( C, coc, exp )
    if IsBound( C.central ) and C.central then return exp * coc; fi;
    return PushVector( C.mats, C.invs, C.one, coc, exp );
end;

#############################################################################
##
#F CocycleConjugateComplement( C, cc, coc, w, h )
##
CocycleConjugateComplement := function( C, cc, coc, w, h )
    local l, g, m, s, c, a, b, v;

    # first catch a special cases
    if Length( w ) = 1 and w[1][2] = 1 and cc.factor.gens <> [] then
        v := cc.action[w[1][1]];
        if v = 1 then
            return 0 * cc.sol;
        else
            return coc * v.lin + v.trl - coc * cc.factor.prei;
        fi;
    fi;

    # now compute
    if Length( coc ) = 0 then 
        coc := cc.sol;
    else
        coc := coc * cc.factor.prei + cc.sol;
    fi;

    l := Length( C.factor );
    g := h^-1;
    m := SubsWord( w, C.smats );
    s := List( C.factor, x -> ExponentsByPcp( C.factor, x^g ) );

    # the linear part
    c := CutVector( coc, l );
    a := Flat( List( s, x -> EvaluateCocycle( C, c, x )*m ) );

    # the translation part
    b := List( [1..l], 
               x -> C.factor[x]^-1 * MappedVector(s[x], C.factor)^h);
    b := List( b, x -> ExponentsByPcp( C.normal, x ) );
    
    return Flat(a) + Flat(b) - coc;
end;

#############################################################################
##
#F OperationOnH1( C, cc ) . . . .affine action of C.super on cohomology group
##
OperationOnH1 := function( C, cc )
    local lin, sub, i, j, g, m, l, coc, img, trl, act, s, h, add;

    # catch some trivial cases
    if Length( C.super ) = 0 then
        return [];
    elif Length( cc.factor.gens ) = 0 then
        return List( C.super, x -> 1 );
    fi;
    l := Length( C.factor );

    # compute action - linear and translation 
    lin := List( C.super, x -> [] );
    trl := List( C.super, x -> 0  );
    for i in [1..Length(C.super)] do
        g := C.super[i]^-1;
        h := C.super[i];
        m := C.smats[i];
        s := List( C.factor, x -> ExponentsByPcp( C.factor, x^g ) );

        # the linear part
        for j in [1..Length( cc.factor.prei )] do
            coc := CutVector( cc.factor.prei[j], l );
            img := List( s, x -> EvaluateCocycle(C, coc, x));
            img := List( img, x -> x * m );
            lin[i][j] := Flat( img );
        od;

        # translation part
        coc := CutVector( cc.sol, l );
        img := List( s, x -> EvaluateCocycle( C, coc, x ) );
        img := List( img, x -> x * m );
        add := List( [1..l], 
               x -> C.factor[x]^-1 * MappedVector(s[x], C.factor)^h);
        add := List( add, x -> ExponentsByPcp( C.normal, x ) );
        trl[i] := Flat( img ) + Flat( add ) - cc.sol;
    od;

    # combine linear and translation action
    act := [];
    for i in [1..Length( C.super )] do
        if lin[i] = cc.gcc and trl[i] = 0*trl[i] then
            act[i] := 1;
        else
            act[i] := rec( lin := lin[i], trl := trl[i] );
        fi;
    od;
    return act;
end;

#############################################################################
##
#F ComplementClassesCR( C )
##
InstallGlobalFunction( ComplementClassesCR, function( C )
    local cc, elms, supr, mats, oper, os, cent, comp, e, d, K, gens, w, g, 
          c, S;

    # first catch a trivial case
    if Length(C.normal) = 0 then 
        return [rec( repr := GroupOfPcp( C.factor ), 
                     norm := GroupOfPcp( C.super ) )];
    fi;

    # compute H^1( U, A/B ) and return if there is no complement
    cc := OneCohomologyEX( C );
    if IsBool( cc ) then return []; fi;

    # check the finiteness of H^1
    if ForAny( cc.factor.rels, x -> x = 0 ) then
        Print("infinitely many complements to lift \n");
        return fail; 
    fi;

    # create elements of H1
    elms := ExponentsByRels( cc.factor.rels );
    if C.char > 0 then elms := elms * One( C.field ); fi;

    # get acting matrices of G on H1
    if not IsBound( C.super ) then
        supr := [];
        mats := [];
    else
        supr := C.super;
        mats := OperationOnH1( C, cc );
    fi;
    cc.action := mats;

    # the operation function of G on H1
    oper := function( pt, act ) 
        local im;
        if act = 1 then return pt; fi;
        im := pt * act.lin + act.trl;
        return cc.CocToFactor( cc, im );
    end;

    # orbits of G on elements of H1
    os  := PcpOrbitsStabilizers( elms, supr, mats, oper );

    # compute centralizer of complements
    cent := List( cc.rls, x -> MappedVector( IntVector( x ), C.normal ) );

    # loop over orbit and extract information
    comp := [];
    for e in os do

        # the complement 
        if Length( e.repr ) > 0 then 
            d := e.repr * cc.factor.prei + cc.sol;
        else
            d := cc.sol;
        fi;
        K := ComplementCR( C, d );

        # add centralizer to complement
        gens := AddIgsToIgs( cent, Igs( K ) );

        # add normalizer to centralizer and complement
        for w in e.word do
            g := SubsWord( w, supr );
            if g <> g^0 and Length( cc.gcb ) > 0 and Length( w ) > 0 then
                c := CocycleConjugateComplement( C, cc, e.repr, w, g );
                c := cc.CocToCBElement(cc, c) * cc.trf;
                g := g * MappedVector( IntVector( c ), C.normal );
                gens := AddIgsToIgs( [g], gens );
            elif g <> g^0 then
                gens := AddIgsToIgs( [g], gens );
            fi;
        od;

        # the normalizer
        S := SubgroupByIgs( C.group, gens );

        #if not CheckComplement( C, S, K ) then 
        #   Error("complement wrong");
        #fi;

        Add( comp, rec( repr := K, norm := S ) );
    od;

    return comp;
end );

#############################################################################
##
#F CheckComplement( C, S, K )
##
CheckComplement := function( C, S, K )
    local G, A, B, L, I, g;

    # check that it is a complement
    G := C.group;
    A := SubgroupByIgs( G, NumeratorOfPcp( C.normal ) );
    B := SubgroupByIgs( G, DenominatorOfPcp( C.normal ) );
    L := SubgroupByIgs( G, Igs(A), Igs(K) );
    I := NormalIntersection( A, K );

    if not L = G then 
        Print("intersection wrong\n");
        return false; 
    elif not I = B then 
        Print("cover wrong\n");
        return false; 
    elif ForAny( Igs(S), x -> x = One(K) ) then 
        Print("igs of normalizer is incorrect\n");
        return false;
    elif not IsSubgroup(S,K) then
        Print("normalizer does not contain complement\n");
        return false;
    elif not IsNormal(S, K)  then 
        Print("normalizer does not normalize \n");
        return false; 
    fi;

    # now its o.k.
    return true;
end;

#############################################################################
##
#F ComplementClassesEfaPcps( G, U, pcps ). . . . . 
##        compute G-classes of complements in U along series. Series must
##        be an efa-series and each subgroup in series must be normal 
##        under G.
##
InstallGlobalFunction( ComplementClassesEfaPcps, function( G, U, pcps )
    local cls, pcp, new, cl, tmp, C;

    cls := [ rec( repr := U, norm := G )];
    for pcp in pcps do
        if Length( pcp ) > 0 then 
            new := [];
            for cl in cls do

                # set up class record
                C := rec( group  := cl.repr,
                          super  := Pcp( cl.norm, cl.repr ),
                          factor := Pcp( cl.repr, GroupOfPcp( pcp ) ),
                          normal := pcp );

                AddFieldCR( C );
                AddRelatorsCR( C );
                AddOperationCR( C );
                AddInversesCR( C );
                tmp :=  ComplementClassesCR( C );
                Append( new, tmp );
            od; 
            cls := ShallowCopy(new);
        fi;
    od;
    return cls;
end );

#############################################################################
##
#F ComplementClasses( [G,] U, N ). . . . . G-classes of complements to N in U
##
## Note that N and U must be normalized by G.
##
InstallGlobalFunction( ComplementClasses, function( arg )
    local G, U, N, pcps;

    # the arguments
    G := arg[1];
    if Length( arg ) = 3 then
        U := arg[2];
        N := arg[3];
    else
        U := arg[1];
        N := arg[2];
    fi;

    # catch a trivial case
    if U = N then 
       return [rec( repr := TrivialSubgroup( N ), norm := G )]; 
    fi;

    # otherwise compute series and all next function
    pcps := PcpsOfEfaSeries( N );
    return ComplementClassesEfaPcps( G, U, pcps );
end );

