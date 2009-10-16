
ExpandMat := function( m )
    local z, d, i;
    z := 0 * m[1][1];
    d := Length(m);
    for i in [1..d] do m[i][d+1] := z; od;
    m[d+1] := 0 * m[1];
    return m;
end;

FindJordanNormalForms := function( n )
    local jnf, chr, res, x, i, f, c, g, a, b;

    jnf := JordanNormalForms( n-1, 2 );
    chr := List( jnf, x -> CharacteristicPolynomial(x) );
    res := [];
    x := Indeterminate( GF(2) );

    for i in [1..Length(jnf)] do
        f := chr[i];
        c := CoefficientsOfUnivariatePolynomial(f);
        if c[n-1] = 0 * c[n-1] then 
            g := Collected(Factors(f));
            a := Filtered( g, y -> y[1] = x );
            b := Difference( g, a );
            if Length(a) > 0 then 
                a := a[1][2]+1;
            else
                a := 1;
            fi;
            if not ForAll(b, y -> y[2]=1) then
                Add( res, [ExpandMat(jnf[i]), x*f] ); 
            fi;
        fi;
    od;
    return res;
end;

SpanRestrictedLieAlg := function( mats )
    local vecs, base, i, m, l, v, c, j; 

    vecs := List( mats, Flat );
    base := ShallowCopy( mats );
    i := 1; 
    while i <= Length(mats) do
        m := base[i];
       
        # add power
        l := m^2;
        v := Flat(l);
        c := SolutionMat( vecs, v );
        if IsBool(c) then 
            Add( base, l );
            Add( vecs, v );
        fi;

        # add Lie commutators
        for j in [1..i-1] do
            l := base[j]*m - m*base[j];
            v := Flat(l);
            c := SolutionMat( vecs, v );
            if IsBool(c) then 
                Add( base, l );
                Add( vecs, v );
            fi;
        od;

        i := i+1;
    od;
    return base;
end;

