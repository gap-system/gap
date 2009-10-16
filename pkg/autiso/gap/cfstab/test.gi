
TestVectorCanoForm := function( d, F )
    local p, U, v, V, l, pcgs, r, i, u, w, f;

    # set up
    p := Characteristic(F);
    U := UnitriangularPcpGroup( d, p );

    # take a random vector
    v := Random(F^d);
    Print("got vector ",v, "\n");

    # take a pcgs for a random subgroup of U
    V := Subgroup( U, [] );
    l := Random([1..Length(Pcp(U))]);
    while Length( Pcp(V) ) < l do
        V := Subgroup(U, Concatenation( Igs(V), [Random(U)]));
    od;
    Print("got pcgs of length ",Length(Pcp(V)),"\n");

    # translate to matrices and then to tuples
    pcgs := List( Pcp(V), x -> MappedVector( Exponents(x), U!.mats ) );
    pcgs := List( pcgs, x -> Tuple([1,x]) );

    # compute cano form
    r := VectorCanonicalForm( pcgs, v, F, d, fail );

    # act on random conjugates
    for i in [1..10] do
        Print(i," th check \n");

        # compute new vector and its cano form
        u := MappedVector( Exponents(Random(V)), U!.mats );
        w := v * u;
        f := VectorCanonicalForm( pcgs, w, F, d, fail );

        # check equivalence
        if f.cano <> r.cano then Error("no cano form"); fi;
        if Length(f.stab) <> Length(r.stab) then Error("wrong stab"); fi;
    od;
    return true;
end;
    
TestSubspaceCanoForm := function( d, F )
    local p, U, l, b, V, m, r, i, v, c, f, o;

    # set up
    p := Characteristic(F);
    U := UnitriangularPcpGroup( d, p );

    # take a random subspace
    l := Random([1..d]);
    b := MyBaseMat(RandomMat( l, d, F ));
    Print("got subspace of dim ",Length(b),"\n");

    # take a pcgs for a random subgroup of U
    l := Random([1..Length(Pcp(U))]);
    V := Subgroup(U, List( [1..l], x -> Random(U) ));
    Print("got pcgs of length ",Length(Pcp(V)),"\n");
    if Length(Pcp(V)) = 0 then return fail; fi;

    # translate to matrices
    m := List( Pcp(V), x -> MappedVector( Exponents(x), U!.mats ) );
    m := List( m, x -> Tuple([1,x]) );
    o := [1,m[1]^0];

    # compute cano form
    r := SubspaceCanonicalForm( m, o, b, F );

    # act on random conjugates
    for i in [1..10] do
        Print(i," th check \n");
        v := MappedVector( Exponents(Random(V)), U!.mats );
        c := MyBaseMat( b * v );
        f := SubspaceCanonicalForm( m, c, F );
        if f.cano <> r.cano then Error("no cano form"); fi;
        if Length(f.stab) <> Length(r.stab) then Error("wrong stab"); fi;
    od;
    return true;
end;
        
    
