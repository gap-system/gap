#############################################################################
##
#W  modules.gi                   Polycyc                         Bettina Eick
##

#############################################################################
##
#F RadicalSeriesOfFiniteModule( mats, d, f )
##
RadicalSeriesOfFiniteModule := function( mats, d, f )
    local base, sers, modu, radb;
    if d = 0 then return []; fi;
    base := IdentityMat( d, f );
    sers := [base];
    modu := GModuleByMats( mats, d, f );
    repeat 
        radb := SMTX.BasisRadical( modu );
        if Length( radb ) > 0 then 
            base := radb * base;
        else 
            base := [];
        fi;
        Add( sers, base );
        if Length( base ) > 0 then 
            modu := SMTX.InducedActionSubmodule( modu, radb );
        fi;
    until Length( base ) = 0;
    return sers;
end;

#############################################################################
##
#F RadicalOfCongruenceModule( mats, d ) . . . . . . .for congruence subgroups
##
RadicalOfCongruenceModule := function( mats, d )
    local coms, i, j, new, base, full, nath, indm, l, algb, newv, tmpb, subb, 
          f, g, h, mat;

    # get commutators 
    coms := [];
    for i in [1..Length( mats )] do
        for j in [i+1..Length( mats )] do
            new := mats[i] * mats[j] - mats[j] * mats[i];
            Append(coms, new );
        od;
    od;
    base := SpinnUpEchelonBase( [], coms, mats, OnRight );
    full := IdentityMat( d );
    nath := NaturalHomomorphismBySemiEchelonBases( full, base );
    indm := List( mats, x -> InducedActionFactorByNHSEB( x, nath ) );
    #Print("found derived submodule of dimension ",Length(base),"\n");

    # start spinning up basis and look for nilpotent elements
    i := 1;
    algb := [];
    while i <= Length( indm ) do

        # add next element to algebra basis
        l := Length( algb );
        newv := Flat( indm[i] );
        tmpb := SpinnUpEchelonBase( algb, [newv], indm{[1..i]}, OnMatVector ); 

        # check whether we have added a non-semi-simple element
        subb := [];
        for j in [l+1..Length(tmpb)] do
            mat := MatByVector( tmpb[j], Length(indm[i]) );
            f := MinimalPolynomial( Rationals, mat );
            g := Collected( Factors( f ) );
            if ForAny( g, x -> x[2] > 1 ) then
                h := Product( List( g, x -> Value( x[1], mat ) ) );
                Append( subb, List( h, x -> ShallowCopy(x) ) );
            fi;
        od;
        #Print("found nilpotent submodule of dimension ", Length(subb),"\n");

        # spinn up new subspace of radical
        subb := SpinnUpEchelonBase( [], subb, indm, OnRight );
        if Length( subb ) > 0 then 
            base := PreimageByNHSEB( subb, nath );
            nath := NaturalHomomorphismBySemiEchelonBases( full, base );
            indm := List( mats, x -> InducedActionFactorByNHSEB( x, nath ) );
            algb := [];
            i := 1;
        else
            i := i + 1;
        fi;
    od;
    return rec( radical := base, nathom := nath, algebra := algb );
end;

#############################################################################
##
#F TraceMatProd( m1, m2, d )
##
TraceMatProd := function( m1, m2, d )
    local t, i, j;
    t := 0;
    for i in [1..d] do
        for j in [1..d] do
            t := t + m1[i][j] * m2[j][i];
        od;
    od;
    return t;
end;

#############################################################################
##
#F AlgebraBase( mats )
##
InstallGlobalFunction( AlgebraBase, function( mats )
    local base, flat;
    if Length( mats ) = 0 then return []; fi;
    flat := List( mats, Flat );
    base := SpinnUpEchelonBase( [], flat, mats, OnMatVector);
    return List( base, x -> MatByVector( x, Length(mats[1]) ) );
end );

#############################################################################
##
#F RadicalOfRationalModule( mats, d ) . . . . . . . . . . . .general approach
##
RadicalOfRationalModule := function( mats, d )
    local base, trac, null, j;

    # get base
    base := AlgebraBase( mats );
    if Length(base) = 0 then return rec( radical := [] ); fi;
    
    # set up system of linear equations ( Tr( ai * aj ) )
    trac := List( base, b -> List( base, c -> TraceMatProd( b, c, d ) ) );

    # compute nullspace
    null := NullspaceMat( trac );
    if Length(null) = 0 then return rec( radical := [] ); fi;

    # translate
    null := List( null, x -> LinearCombination( x, base ) );
    null := Concatenation( null );
    TriangulizeMat( null );
    j := Position( null, 0 * null[1] );
    return rec( radical := null{[1..j-1]} );
end;

#############################################################################
##
#F RadicalSeriesOfRationalModule( mats, d ) . . . . . .compute radical series
##
RadicalSeriesOfRationalModule := function( mats, d )
    local acts, full, base, sers, radb, nath;
    if d = 0 then return []; fi;
    full := IdentityMat( d );
    sers := [full];
    base := full;
    acts := mats;
    repeat 
        radb := RadicalOfRationalModule( acts, d ).radical;
        if Length(radb) > 0 then
            base := radb * base;
            nath := NaturalHomomorphismBySemiEchelonBases( full, base );
            acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ) );
        else
            base := [];
        fi;
        d := Length( base );
        Add( sers, base );
    until d = 0;
    return sers;
end;

#############################################################################
##
#F PrimitiveAlgebraElement( mats, base )
##
InstallGlobalFunction( PrimitiveAlgebraElement, function( mats, base )
    local d, mat, f, c, b, l;

    # set up
    d := Length( base );

    # first try one of mats
    for mat in mats do
        f := MinimalPolynomial( Rationals, mat );
        if Degree( f ) = d then return rec( elem := mat, poly := f ); fi;
    od;

    # otherwise try random elements
    l := Sqrt( Length( base[1] ) );
    repeat
        c := List( [1..d], x -> Random( Integers ) );
        b := MatByVector( c * base, l );
        f := MinimalPolynomial( Rationals, b );
        if Degree( f ) = d then return rec( elem := b, poly := f ); fi;
    until false;
end );

#############################################################################
##
#F SplitSemisimple( base )
##
SplitSemisimple := function( base )
    local d, b, f, s, i;

    d := Length( base );
    b := PrimitiveAlgebraElement( [], base );
    f := Factors( b.poly );

    # the trivial case
    if Length( f ) = 1 then 
        return [rec( basis := IdentityMat(Length(base[1])), poly := f )];
    fi;

    # the non-trivial case
    s := List( f, x -> NullspaceRatMat( Value( x, b.elem ) ) );
    s := List( [1..Length(f)], x -> rec( basis := s[x], poly := f[x] ) );
    return s;
end;

#############################################################################
##
#F HomogeneousSeriesOfCongruenceModule( mats, d ). . for congruence subgroups
##
HomogeneousSeriesOfCongruenceModule := function( mats, d )
    local radb, splt, nath, l, sers, i, sub, full, acts, rads;

    # catch the trivial case and set up
    if d = 0 then return []; fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then return [full, []]; fi;
    sers := [full];

    # get the radical 
    radb := RadicalOfCongruenceModule( mats, d );
    splt := SplitSemisimple( radb.algebra );
    nath := radb.nathom;

    # refine radical factor and initialize series
    l := Length( splt );
    for i in [2..l] do
        sub := Concatenation( List( [i..l], x -> splt[x].basis ) );
        TriangulizeMat( sub ); 
        Add( sers, PreimageByNHSEB( sub, nath ) );
    od;
    Add( sers, radb.radical );
        
    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical );
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ) );

    # use recursive call to refine radical
    rads := HomogeneousSeriesOfCongruenceModule( acts, Length(radb.radical) );
    for i in [2..Length(rads)] do
        if Length(rads[i]) > 0 then rads[i] := rads[i] * radb.radical; fi;
    od;
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F HomogeneousSeriesOfRationalModule( mats, cong, d ). . . . . use full space
##
HomogeneousSeriesOfRationalModule := function( mats, cong, d )
    local full, sers, radb, nath, fact, base, splt, l, i, sub, acts, subs,
          rads; 

    # catch the trivial case and set up
    if d = 0 then return []; fi;
    full := IdentityMat( d );
    sers := [full];

    # other trivial case
    if Length( cong ) = 0 then return [full, []]; fi;

    # get the radical and split its factor
    radb := RadicalOfRationalModule( mats, d );
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical );
    fact := List( cong, x -> InducedActionFactorByNHSEB( x, nath ) );
    base := AlgebraBase( fact );
    splt := SplitSemisimple( List( base, Flat ) );

    # refine radical factor and initialize series
    l := Length( splt );
    for i in [2..l] do
        sub := Concatenation( List( [i..l], x -> splt[x].basis ) );
        TriangulizeMat( sub );
        Add( sers, PreimageByNHSEB( sub, nath ) );
    od;
    Add( sers, radb.radical );

    # use recursive call to refine radical
    l := Length( radb.radical );
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ) );
    subs := List( cong, x -> InducedActionSubspaceByNHSEB( x, nath ) );
    rads := HomogeneousSeriesOfRationalModule( acts, subs, l );
    for i in [2..Length(rads)] do
        if Length(rads[i]) > 0 then rads[i] := rads[i] * radb.radical; fi;
    od;
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F RefineSplitting( mats, subs ) . . . . . . . . . . for congruence subgroups
##
RefineSplitting := function( mats, subs )
    local i, full, news, dims, j, d, e, tmp;

    # refine each of the subspaces subs in turn by spinning
    for i in [1..Length(subs)] do
        full := subs[i];
        news := [];
        dims := 0;
        j := 1;
        d := Length( subs[i] );
        while dims < d do
            e := full[j];
            if ForAll( news, x -> MemberBySemiEchelonBase(e, x) = false ) then
                tmp := SpinnUpEchelonBase( [], [e], mats, OnRight );
                Add( news, tmp );
                dims := dims + Length( tmp );
            fi;
            j := j + 1;
        od;
        subs[i] := news;
    od;
    return Concatenation( subs );
end;

