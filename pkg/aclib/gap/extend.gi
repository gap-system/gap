#############################################################################
##
#W  extend.gi                                                   Karel Dekimpe
#W                                                               Bettina Eick
##

#############################################################################
##
#F FiniteSubgroupsAreCyclic( G )
##
FiniteSubgroupsAreCyclic := function( G )
    local fin, rep, flg;
    fin := FiniteSubgroupClasses( G );
    rep := List( fin, Representative );
    flg := ForAll( rep, IsCyclic );
    return flg;
end;

#############################################################################
##
#F AllActionsHolonomy( G ) 
##
## Computes all actions of G on Z which can lead to a torsion-free
## extension centralizing Fit(G). Thus all finite subgroups of G and Fit(G)
## centralizes Z and the kernel of the action has index at most 2.
##
AllActionsHolonomy := function( G )
    local mats, acts, fins, reps, gens, U, hom, F, low, H, i;

    # first we add the trivial action
    mats := List( Igs(G), x -> IdentityMat(1));
    acts := [mats];

    # determine the subgroup known to centralize Z
    U := FittingSubgroup(G);

    # determine all subgroups of index 2 in G/U
    hom := NaturalHomomorphism( G, U );
    F   := Image( hom );
    low := LowIndexSubgroupClasses( F, 2 );
    low := List( low, Representative );
    low := List( low, x -> PreImage( hom, x ) );

    # for each subgroup we get one action
    for H in low do
        mats := List( Igs(G), x -> IdentityMat(1));
        for i in [1..Length(Igs(G))] do
            if not Igs(G)[i] in H then
                mats[i] := - mats[i];
            fi;
        od;
        Add( acts, mats );
    od;
    return acts;
end;

#############################################################################
##
#F AllActionsForTorsionFreeExtension( G ) 
##
## Computes all actions of G on Z which can lead to a torsion-free
## extension centralizing Fit(G). Thus all finite subgroups of G and Fit(G)
## centralizes Z and the kernel of the action has index at most 2.
##
AllActionsForTorsionFreeExtension := function( G )
    local mats, acts, fins, reps, gens, U, hom, F, low, H, i;

    # first we add the trivial action
    mats := List( Igs(G), x -> IdentityMat(1));
    acts := [mats];

    # determine the subgroup known to centralize Z
    fins := FiniteSubgroupClasses( G );
    reps := List( fins, Representative );
    gens := Flat( List( reps, Igs ) );
    Append( gens, GeneratorsOfGroup( FittingSubgroup(G) ) );
    U := NormalClosure( G, Subgroup( G, gens ) );
    if Index( G, U ) = 1 then return acts; fi;

    # determine all subgroups of index 2 in G/U
    hom := NaturalHomomorphism( G, U );
    F   := Image( hom );
    low := LowIndexSubgroupClasses( F, 2 );
    low := List( low, Representative );
    low := List( low, x -> PreImage( hom, x ) );

    # for each subgroup we get one action
    for H in low do
        mats := List( Igs(G), x -> IdentityMat(1));
        for i in [1..Length(Igs(G))] do
            if not Igs(G)[i] in H then
                mats[i] := - mats[i];
            fi;
        od;
        Add( acts, mats );
    od;
    return acts;
end;

#############################################################################
##
#F ExpandedTail( tail, d )
##
ExpandedTail := function( t, d )
    local r, i;
    r := List( [1..d], x -> 0 );
    for i in [1..Length(t)] do
        if IsBound( t[i] ) then r[i] := t[i][1][1]; fi;
    od;
    return r;
end;

#############################################################################
##
#F HasTorsionFreeExtension( G, CR )
##
## Check if G has a torsion-free extension. We assume that all finite 
## subgroups of G are cyclic (otherwise, no torsion-free extension exists).
## CR ist a record describing the second cohomology group of G by Z.
##
HasTorsionFreeExtension := function( G, CR )
    local fins, reps, repp, cc, d, subs, U, g, e, p, w, v, i, t, r, pr, 
          f, V, spcs, sub;

    # compute the finite subgroups of prime order up to conjugacy
    fins := FiniteSubgroupClasses( G );
    reps := List( fins, Representative );
    repp := Filtered( reps, x -> IsPrime( Size(x) ) );
    if Length( repp ) = 0 then return true; fi;

    # extract second cohomology
    cc := CR.twocohom;

    # for each finite subgroup of prime order compute the corresponding
    # relation on cc.gcc
    subs := [];
    for U in repp do
        g := GeneratorsOfGroup( U )[1];
        e := Exponents( g );
        p := Order( g );
        w := rec( word := e, tail := [] );
        v := ShallowCopy( w );
        for i in [2..p] do
            v := CollectedTwoCR( CR, v, w );
        od;
        r := ExpandedTail( v.tail, Length( CR. enumrels ) );
        sub := NullspaceIntMod( cc.factor.prei, r, p );
        Add( subs, sub );
    od;

    e := Lcm( List( repp, Size ) );
    d := Length( cc.factor.prei );
    return SizeOfUnionMod( subs, e ) < e^d;
end;

#############################################################################
##
#F HasMinimalCentreExtension( G, CR )
##
## Check if there is an extension of G that has minimal centre; that is,
## Z(Fit(E)) = Z. This is only implemented for groups G with abelian 
## Fitting subgroup.
##
HasMinimalCentreExtension := function( G, CR )
    local cc, d, t, F, f, g, l, c, i, j, v, w, a, b;

    # get cohomology and generic elements
    cc := CR.twocohom;
    d  := Length( CR.enumrels );
    t  := List( [1..Length(cc.gcc)], x -> Indeterminate( Integers, x ) );
    t  := t * cc.gcc;

    # get Fitting subgroup generators
    F := FittingSubgroup( G );

    # the abelian case is more effective - consider this first
    if IsAbelian( F ) then 
        f := GeneratorsOfGroup( F );
        l := Length( f );

        # find tails of commutators
        c := NullMat( l, l );
        for i in [1..l] do
            for j in [i+1..l] do
                v := rec( word := Exponents( f[i]^-1 ), tail := [] );
                w := rec( word := Exponents( f[j]^-1 ), tail := [] );
                v := CollectedTwoCR( CR, v, w );
                w := rec( word := Exponents( f[i] ), tail := [] );
                v := CollectedTwoCR( CR, v, w );
                w := rec( word := Exponents( f[j] ), tail := [] );
                v := CollectedTwoCR( CR, v, w );
                b := ExpandedTail( v.tail, d );
                a := b * t;
                c[i][j] := a;
                c[j][i] := -a;
            od;
        od;
        
        # get determinant
        c := GenericDeterminantMat( c );
        return Length( ExtRepPolynomialRatFun(c) ) <> 0;
    fi;

    # the non-abelian case 
    f := MinimalGeneratingSet( F );
    g := GeneratorsOfGroup( Centre( F ) );
    if Length(f) < Length( g ) then return false; fi;

    # find tails of commutators
    c := NullMat( Length(f), Length(g) );
    for i in [1..Length(f)] do
        for j in [1..Length(g)] do
            v := rec( word := Exponents( f[i]^-1 ), tail := [] );
            w := rec( word := Exponents( g[j]^-1 ), tail := [] );
            v := CollectedTwoCR( CR, v, w );
            w := rec( word := Exponents( f[i] ), tail := [] );
            v := CollectedTwoCR( CR, v, w );
            w := rec( word := Exponents( g[j] ), tail := [] );
            v := CollectedTwoCR( CR, v, w );
            b := ExpandedTail( v.tail, d );
            c[i][j] := b * t;
        od;
    od;

    # get determinant of rxr submats
    Error("not yet implemented");
    c := Determinant( c );
    c := ExtRepPolynomialRatFun( c );
    c := Filtered( c, x -> IsInt(x) );
    return ForAny( c, x -> x <> 0 ); 
end;

#############################################################################
##
#F HasExtensionOfType( G, torfree, mincent )
##
## Let G be a pcp group. This function checks if G has a torsion-free
## extension or an extension with Z(Fit(H)) = Z$ with the free abelian
## module Z. 
##
InstallGlobalFunction( HasExtensionOfType, function( G, torfree, mincent )
    local mats, CR, found, i;

    # if both flags are false, then there is nothing to do
    if not torfree and not mincent then return true; fi;

    # first check if G is torsion-free or has non-cyclic finite subgrps
    Print("    check that all finite subgroups are cyclic\n");
    if not FiniteSubgroupsAreCyclic( G ) then return false; fi;

    # if G is torsion-free, then all extensions of G are torsion-free
    if Length( FiniteSubgroupClasses(G) ) = 1 then torfree := false; fi;
    if not torfree and not mincent then return true; fi;

    # now loop over actions - the trivial action first
    Print("    consider trivial action \n");
    mats := List( Igs(G), x -> IdentityMat( 1 ) );
    CR := CRRecordByMats( G, mats );
    CR.twocohom := TwoCohomologyCR( CR );
    if mincent then 
        found := HasMinimalCentreExtension( G, CR );
        #if found <> HasMinimalCentreExtensionByCRRec2( G, CR ) then 
        #    Error("something wrong with min cent");
        #fi;
    fi;
    if (not mincent) or (found and torfree) then 
        found := HasTorsionFreeExtension( G, CR );
    fi;
    if found then return true; fi;

    # now consider the remaining actions
    mats := AllActionsForTorsionFreeExtension( G );
    for i in [2..Length(mats)] do
        Print("    consider non-trivial action number ",i-1,"\n");
        CR := CRRecordByMats( G, mats[i] );
        CR.twocohom := TwoCohomologyCR( CR );
        if mincent then 
            found := HasMinimalCentreExtension( G, CR );
            #if found <> HasMinimalCentreExtensionByCRRec2( G, CR ) then 
            #    Error("something wrong with min cent");
            #fi;
        fi;
        if (not mincent) or (found and torfree) then 
            found := HasTorsionFreeExtension( G, CR );
        fi;
        if found then return true; fi;
    od;

    # we have not found a suitable extension
    return false;
end );
