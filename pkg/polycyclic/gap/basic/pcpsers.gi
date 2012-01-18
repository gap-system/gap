#############################################################################
##
#W  pcpseries.gi                   Polycyc                       Bettina Eick
##

#############################################################################
##
#M  LowerCentralSeriesOfGroup( G )
##
##  As usual, this function calls CommutatorSubgroup repeatedly. However,
##  is sets U!.isNormal before to avoid unnecessary normal closures in
##  CommutatorSubgroup.
##
InstallMethod( LowerCentralSeriesOfGroup, true, [IsPcpGroup], 0, 
function( G )
    local ser, U;
    ser := [G];
    U   := ShallowCopy( G );
    G!.isNormal := true;
    while Length(Igs(U)) > 0 do
        U := CommutatorSubgroup( U, G );
        Add( ser, U );
    od;
    Unbind( G!.isNormal );
    return ser;
end );

InstallMethod( PCentralSeriesOp, true, [IsPcpGroup, IsPosInt], 0,
function( G, p )
    local ser, U, C, pcp, new;
    ser := [G];
    U := G;
    G!.isNormal := true;
    while Size(U) > 1 do
        C := CommutatorSubgroup( U, G );
        pcp := Pcp( U, C );
        new := List( pcp, x -> x^p );
        U := SubgroupByIgs( G, Igs(C), new );
        Add( ser, U );
    od;
    Unbind( G!.isNormal );
    return ser;
end );

#############################################################################
##
#F  PcpSeries( G )
##
##  Compute a polycyclic series of G - we use the series defined by Igs(G).
##
InstallGlobalFunction( PcpSeries, function( G )
    local pcs, ser;
    pcs := Igs( G );
    ser := List( [1..Length(pcs)], 
           i ->  SubgroupByIgs( G, pcs{[i..Length(pcs)]} ) );
    Add( ser, TrivialSubgroup(G) );
    return ser;
end );   

#############################################################################
##
#F  CompositionSeries(G)
##
InstallMethod( CompositionSeries, true, [IsPcpGroup], 0,
function(G)
    local g, r, n, s, i, f, m, j, e, U;
 
    if not IsFinite(G) then Error("composition series is infinite"); fi;

    # set up
    g := Pcp(G);
    r := RelativeOrdersOfPcp(g);
    n := Length(g);

    # construct series
    s := [G];
    for i in [1..n] do
        if r[i] > 1 then 
            f := Factors(r[i]);
            m := Length(f);
            for j in [1..m-1] do
                e := Product(f{[1..j]});
                U := SubgroupByIgs(G, Concatenation([g[i]^e], g{[i+1..n]}));
                Add(s, U);
            od;
            Add(s, SubgroupByIgs(G, g{[i+1..n]}));
        fi;
    od;
    return s;
end );

#############################################################################
##
#M  EfaSeries( G )
##
##  Computes a normal series of G whose factors are elementary or free
##  abelian (efa). The normal series will also be normal under action
##  of the parent of G
##
InstallGlobalFunction( IsEfaFactorPcp, function( pcp )
    local gens, denm, i, j, c, cycl, rels, p;

    gens := GeneratorsOfPcp( pcp );
    rels := RelativeOrdersOfPcp( pcp );

    # if there are no generators, then the factor is trivial
    if Length( gens ) = 0 then return true; fi;

    # if the factor is finite, then it must be elementary
    if ForAll( rels, x -> x <> 0 ) then
        p := rels[1];
        if not IsPrime( p ) or ForAny( rels, x-> x <> p ) then
            return false;
        fi;
    fi;

    # if the factor is infinite, then no finite bits may occur at its end
    if ForAny( rels, x -> x = 0 ) and rels[Length(rels)] > 0 then
        return false;
    fi;

    # check if factor is abelian
    denm := DenominatorOfPcp( pcp );
    for i in [1..Length( gens )] do
        for j in [1..i-1] do
            c := Comm( gens[i], gens[j] );
            c := ReducedByIgs( denm, c );
            if c <> c^0 then return false; fi;
        od;
    od;

    # check if factor is elementary or free
    cycl := CyclicDecomposition( pcp );
    rels := cycl.rels;
    p    := rels[1];
    if not (p = 0 or IsPrime(p)) then return false; fi;
    if ForAny( rels, x -> x <> p ) then return false; fi;

    # otherwise it is efa
    pcp!.cyc := cycl;
    return true;
end );

InstallGlobalFunction( EfaSeriesParent, function( G )
    local ser, new, i, U, V, pcp,  nat, ref;

    # take the normal subgroups in the defining pc series
    ser := Filtered( PcpSeries(G), x -> IsNormal(G,x) );

    # check the factors
    new := [G];
    for i in [1..Length(ser)-1] do
        U := ser[i];
        V := ser[i+1];

        # if the factor is free or elementary abelian, then 
        # everything is fine
        pcp  := Pcp( U, V );
        if IsEfaFactorPcp( pcp ) then
            U!.efapcp := pcp;
            Add( new, V );

        # otherwise we need to refine this factor
        else
            nat := NaturalHomomorphismByPcp( pcp );
            ref := RefinedDerivedSeries( Image( nat ) );
            ref := ref{[2..Length(ref)]};
            ref := List( ref, x -> PreImage( nat, x ) );
            Append( new, ref );
        fi;
    od;
    return new;
end );

InstallMethod( EfaSeries, true, [IsPcpGroup], 0, 
function( G )
    local efa, new, L, A, B;

    # use the series of the parent which has a defining pcs
    if G = Parent( G ) then return EfaSeriesParent(G); fi;
    efa := EfaSeries( Parent( G ) );

    # intersect each subgroup into G
    new := [G];
    for L in efa do

        # compute new factor
        A := new[Length(new)];
        B := NormalIntersection( L, G );

        # check if it is a proper factor and if so, then add it
        if IndexNC( A, B ) <> 1 then
            Unbind( A!.efapcp );
            Add( new, B );
        fi;

        # check if the series arrived at the trivial subgroup
        if Length( Igs( B ) ) = 0 then return new; fi;
    od;
end );

#############################################################################
##
#F RefinedDerivedSeries( <G> )
##
## Compute an efa series of G which refines the derived series by
## finite - by - (torsion-free) factors.
##
InstallGlobalFunction( RefinedDerivedSeries, function( G )
    local ser, ref, i, A, B, pcp, gens, rels, n, free, fini, U, s, t, f;

    ser := DerivedSeriesOfGroup( G );
    ref := [G];
    for i in [1..Length( ser ) - 1] do

        # refine abelian factor A/B
        A := ser[i];
        B := ser[i+1];
        pcp := Pcp( A, B, "snf" );
        gens := GeneratorsOfPcp( pcp );
        rels := RelativeOrdersOfPcp( pcp );
        n    := Length( gens );

        # take the free part for the top factor
        free := Filtered( [1..n], x -> rels[x] = 0 );
        fini := Filtered( [1..n], x -> rels[x] > 0 );
        if Length( free ) > 0 then 
            f := AddToIgs( Igs(B), gens{fini} );
            U := SubgroupByIgs( G, f );
            Add( ref, U ); 
        else
            U := A;
        fi;

        # the torsion subgroup
        if Length( fini ) > 0 then
            s := Factors( Lcm( rels{fini} ) );
            f := gens{fini};
            for t in s do
                f := List( f, x -> x ^ t );
                f := AddToIgs( Igs(B), f );
                U := SubgroupByIgs( G, f );
                Add( ref, U );
            od;
        fi;
    od;
    return ref;
end );

#############################################################################
##
#F RefinedDerivedSeriesDown( <G> )
##
## Compute an efa series of G which refines the derived series by
## (torsion-free) - by - finite factors.
##
InstallGlobalFunction( RefinedDerivedSeriesDown, function( G )
    local ser, ref, i, A, B, pcp, gens, rels, n, free, fini, U, s, f, t;

    ser := DerivedSeriesOfGroup( G );
    ref := [G];
    for i in [1..Length( ser ) - 1] do

        # refine abelian factor A/B
        A := ser[i];
        B := ser[i+1];
        pcp := Pcp( A, B, "snf" );
        gens := GeneratorsOfPcp( pcp );
        rels := RelativeOrdersOfPcp( pcp );
        n    := Length( gens );

        # get info
        free := Filtered( [1..n], x -> rels[x] = 0 );
        fini := Filtered( [1..n], x -> rels[x] > 0 );
        U := A;

        # first the torsion part
        if Length( fini ) > 0 then
            s := Factors( Lcm( rels{fini} ) );
            f := ShallowCopy( gens );
            for t in s do
                f := List( f, x -> x ^ t );
                f := AddToIgs( Igs(B), f );
                U := SubgroupByIgs( G, f );
                Add( ref, U );
            od;
        fi;

        # now it remains to add the free part
        if Length( free ) > 0 then Add( ref, B ); fi;
    od;
    return ref;
end );

#############################################################################
##
#F TorsionByPolyEFSeries( G )
##
## Compute an efa-series of G which has only torsion-free factors at the
## top and only finite factors at the bottom. It might happen that such a
## series does not exists. In this case the function returns fail.
##
InstallGlobalFunction( TorsionByPolyEFSeries, function( G )
    local ref, U, D, pcp, gens, rels, n, fini, tmp;

    ref := [];
    U   := ShallowCopy( G );
    while Size(U) = infinity  do

        # factorise abelian factor group
        D    := DerivedSubgroup( U );
        pcp  := Pcp( U, D, "snf" );
        gens := GeneratorsOfPcp( pcp );
        rels := RelativeOrdersOfPcp( pcp );
        n    := Length( gens );

        # check that there is a free part
        if Length( Filtered( [1..n], x -> rels[x] = 0 ) ) = 0 then
            return fail;
        fi;

        # take the free part into the series
        fini := Filtered( [1..n], x -> rels[x] > 0 );
        U    := SubgroupByIgs( G, Igs(D), gens{fini} );
        Add( ref, U );
    od;

    # now U is a finite group and we refine it as we like
    tmp := RefinedDerivedSeries( U );
    Append( ref, tmp{[2..Length(tmp)]} );
    return ref;
end );

#############################################################################
##
#F PStepCentralSeries(G, p)
##
PStepCentralSeries := function(G, p)
    local ser, new, i, N, M, pcp, j, U;
    ser := PCentralSeries(G, p);
    new := [G];
    for i in [1..Length(ser)-1] do
        N := ser[i];
        M := ser[i+1];
        pcp := Pcp(N,M);
        for j in [1..Length(pcp)] do
            U := SubgroupByIgs( G, pcp{[j+1..Length(pcp)]}, Igs(M) );
            Add( new, U );
        od;
    od;
    return new;
end;

#############################################################################
##
#M  PcpsBySeries( ser [,"snf"] )
##
##  Usually it's better to work with pcp's instead of series. Here are
##  the functions to get them.
##
InstallGlobalFunction( PcpsBySeries, function( arg )
    local ser;
    ser := arg[1];
    if Length( arg ) = 1 then
        return List( [1..Length(ser)-1], x -> Pcp( ser[x], ser[x+1] ) );
    else
        return List( [1..Length(ser)-1], x -> Pcp( ser[x], ser[x+1], "snf" ));
    fi;
end );

#############################################################################
##
#M  PcpsOfEfaSeries( G )
##
##  Some of the factors in this series know already its pcp. The other must
##  be computed.
##
InstallMethod( PcpsOfEfaSeries, true, [IsPcpGroup], 0, 
function( G )
    local ser, i, new, pcp;
    ser := EfaSeries( G );
    pcp := [];
    for i in [1..Length(ser)-1] do
        if IsBound( ser[i]!.efapcp ) then
            Add( pcp, ser[i]!.efapcp );
            Unbind( ser[i]!.efapcp );
        else
            new := Pcp( ser[i], ser[i+1], "snf" );
            Add( pcp, new );
        fi;
    od;
    return pcp;
end );

#############################################################################
##
#M  ModuloSeries( ser, N )
##
##  N is assumed to normalize each subgroup in ser. This function returns an
##  induced series of ser[1] mod N. The last subgroup in the returned series
##  is N.
##
InstallGlobalFunction( ModuloSeries, function( ser, N )
    local gens, new, L, A, B;
    gens := GeneratorsOfGroup( N );
    new  := [];
    for L in ser do
        B := SubgroupByIgs( Parent( ser[1] ), Igs(L), gens );
        if Length( new ) = 0 then
            Add( new, B );
        else
            A := new[Length(new)];
            if IndexNC( A, B ) <> 1 then
                Add( new, B );
            fi;
        fi;
        if IsGroup(N) and IsSubgroup( N, L ) then return new; fi;
    od;
    return new;
end );

#############################################################################
##
#M  ModuloSeriesPcps( pcps, N [,"snf] )
##
##  Same as above, but input and output are pcp's. Note that this function
##  has more flexible argumentlists.
##
InstallGlobalFunction( ModuloSeriesPcps, function( arg )
    local pcps, gens, new, A, B, pcp, G;

    pcps := arg[1];
    if Length( pcps ) = 0 then return fail; fi;
    if IsList( arg[2] ) then
        gens := arg[2];
    else
        gens := GeneratorsOfGroup( arg[2] );
    fi;

    G   := GroupOfPcp( pcps[1] );
    A   := SubgroupByIgs( G, AddIgsToIgs(gens, NumeratorOfPcp( pcps[1] )));
    new := [];
    for pcp in pcps do
        B := SubgroupByIgs( G, AddIgsToIgs(gens,DenominatorOfPcp(pcp)));
        if IndexNC( A, B ) <> 1 and Length( arg ) = 2 then
            Add( new, Pcp( A, B ) );
            A := ShallowCopy( B );
        elif IndexNC( A, B ) <> 1 then
            Add( new, Pcp( A, B, "snf" ) );
            A := ShallowCopy( B );
        fi;
        if IsGroup(arg[2]) and IsSubgroup( arg[2], B ) then return new; fi;
    od;
    return new;
end );

#############################################################################
##
#M  ExtendedSeriesPcps( pcps, N [,"snf"]). . . . . . . . extend series with N
##
InstallGlobalFunction( ExtendedSeriesPcps, function( arg )
    local N, L, new;
    N := arg[2];
    L := GroupOfPcp( arg[1][1] );
    if IndexNC( N, L )  <> 1 then
        if Length( arg ) = 2 then
            new := Pcp( N, L );
        else
            new := Pcp( N, L, "snf" );
        fi;
        return Concatenation( [new], arg[1] );
    else
        return arg[1];
    fi;
end );

#############################################################################
##
#M  ReducedEfaSeriesPcps( pcps ). . . . . . . . . . . . try to shorten series
##
InstallGlobalFunction( ReducedEfaSeriesPcps, function( pcps )
    local new, old, i, V, U, pcp;
    new := [];
    old := pcps[Length(pcps)];
    for i in Reversed( [1..Length(pcps)-1] ) do
        U := GroupOfPcp( pcps[i] );
        V := SubgroupByIgs( U, DenominatorOfPcp( old ) );
        pcp := Pcp( U, V );
        if not IsEfaFactorPcp( pcp ) then
            Add( new, old );
            old := pcps[i];
        else
            old := pcp;
        fi;
    od;
    Add( new, old );
    return Reversed( new );
end );

#############################################################################
##
#M  PcpsOfPowerSeries( pcp, n )
##
PcpsOfPowerSeries := function( pcp, n )
    local facs, gens, sers, B, f, A, p, new;
    facs := Factors(n);
    gens := GeneratorsOfPcp( pcp );
    sers := [];
    B    := GroupOfPcp( pcp );
    p    := 1;
    for f in facs do
        p := p * f;
        A := ShallowCopy( B );
        B := AddIgsToIgs(List( gens, x -> x^p ), DenominatorOfPcp(pcp));
        B := SubgroupByIgs( A, B );
        new := Pcp(A, B);
        new!.power := p;
        Add( sers, new );
    od;
    return sers;
end;

#############################################################################
##
#F LinearActionOnPcp( gens, pcp )
##
InstallGlobalFunction( LinearActionOnPcp, function( gens, pcp )
    return List( gens, x -> List( pcp, y -> ExponentsByPcp( pcp, y ^ x ) ) );
end );

