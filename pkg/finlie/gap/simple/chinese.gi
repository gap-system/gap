
#############################################################################
##
#F Basis of the polynomial algebra 
## 
PolynomialBasis := function( n, p )
    local d, m, r, bas, i, noa, a, k;
    d := p^Sum(n);
    m := Length(n);
    bas := [];
    for i in [0..d-1] do
        noa := i;
        a := [];
        for k in [1..m-1] do
            a[k] := noa mod p^n[k];
            noa := (noa-a[k])/(p^n[k]);
        od;
        a[m] := noa;
        bas[i+1] := a;
    od;
    return bas;
end;

#############################################################################
##
#F Binomials of polynomials
## 
MultiBinomial := function( a, b )
    local c, i;
    c := 1;
    for i in [1..Length(a)] do
        c := c * Binomial( a[i], b[i] );
    od;
    return c;
end;

#############################################################################
##
#F WordByExponents
## 
WordByExponents := function( vec )
    local w, i;
    w := [];
    for i in [1..Length(vec)] do
        if vec[i] <> 0*vec[i] then
            Add( w, vec[i] );
            Add( w, i );
        fi;
    od;
    return w;
end;

#############################################################################
##
#F SimpleLieAlgebraTypeK2 (n, mu, F)
##
## The simple Lie algebra over F with char F = 2 of Kontakt type as 
## described by Lei et al.
##
SimpleLieAlgebraTypeK2 := function( n, mu, F )
    local m, r, d, l, T, bas, eps, i, a, j, b, c, e, u, v, k, h, S, f, L;

    # set up and check arguments
    m := Length(n);
    if not Characteristic(F) = 2 then return fail; fi;
    if not ForAll(n, IsInt) then return fail; fi;
    if IsInt(m/2) then return fail; fi;
    if not 2*Length(mu)+1 = m then return fail; fi;

    r := (m-1)/2;
    d := 2^Sum(n);
    l := Concatenation( mu, List( mu, x -> 1-x ) );
    if IsInt(r/2) then 
        f := d-1;
    else
        f := d;
    fi;

    # set up table of structure constants
    T := EmptySCTable( f, Zero(F), "antisymmetric" );

    # elements of the polynomial algebra
    bas := PolynomialBasis( n, 2 );
    eps := IdentityMat( m, Integers );

    # fill in table
    for i in [1..f] do
        a := bas[i];
        for j in [i+1..f] do
            b := bas[j];
            c := a + b;
            e := List( [1..f], x -> 0 );

            # the coeff of x^(a+b-e_m)
            h := Position( bas, c-eps[m] );
            if not IsBool(h) and h <= f then 
                u := MultiBinomial( c-eps[m], a );
                v := MultiBinomial( c-eps[m], b );
                if b[m] > 0 then
                    e[h] := e[h] + u;
                fi;
                if a[m] > 0 then 
                    e[h] := e[h] + v;
                fi;
                for k in [1..m-1] do
                    if b[m] > 0 and a[k] > 0 then
                        e[h] := e[h] + l[k]*a[k]*u;
                    fi;
                    if a[m] > 0 and b[k] > 0 then
                        e[h] := e[h] + l[k]*b[k]*v;
                    fi;
                od;
            fi;

            # the coeffs of x^(a+b-e_k-e_k')
            for k in [1..r] do
                h := Position( bas, c-eps[k]-eps[k+r] );
                if not IsBool(h) and h <= f then
                    if a[k] > 0 and b[k+r] > 0 then 
                        u := MultiBinomial( c-eps[k]-eps[k+r], a-eps[k] );
                        e[h] := e[h] + u;
                    fi;
                    if a[k+r] > 0 and b[k] > 0 then 
                        v := MultiBinomial( c-eps[k]-eps[k+r], a-eps[k+r] );
                        e[h] := e[h] + v;
                    fi;
                fi;
            od;

            # turn e into a word and add it
            if e <> 0*e then
                SetEntrySCTable( T, j, i, WordByExponents(e) );
            fi;
        od;
    od;

    # check and return
    #if not TestJacobi(T)=true then Error("no Jacobi"); fi;
    L := LieAlgebraByStructureConstants( F, T );
    SetName(L, Concatenation("Q", String(n), String(mu)));
    return L;
end;

#############################################################################
##
#F SimpleLieAlgebraTypeH2 (n, F)
##
## The simple Lie algebra over F with char F = 2 of Hamiltonian type
## described by Lei et al.
##
SimpleLieAlgebraTypeH2 := function( n, F )
    local m, d, T, bas, eps, i, j, k, h, a, b, c, e, u, L;

    # set up and check arguments
    m := Length(n);
    if not Characteristic(F) = 2 then return fail; fi;
    if not ForAll(n, IsInt) then return fail; fi;

    # get dimension
    if ForAll(n, x -> x = 1) then 
        d := 2^Sum(n) - 2;
    else
        d := 2^Sum(n) - 1;
    fi;

    # set up table of structure constants
    T := EmptySCTable( d, Zero(F), "antisymmetric" );

    # elements of the polynomial algebra
    bas := PolynomialBasis( n, 2 );
    bas := bas{[2..Length(bas)]};
    eps := IdentityMat( m, Integers );

    # fill in table
    for i in [1..d] do
        a := bas[i];
        for j in [i+1..d] do
            b := bas[j];

            # set up for [y^(a), y^(b)]
            c := a + b;
            e := List( [1..d], x -> 0 );

            # the coeff of y^(a+b-2e_i)
            for k in [1..m] do
                if a[k] > 0 and b[k] > 0 then 
                    h := Position( bas, c-2*eps[k] );
                    if not IsBool(h) then 
                        u := MultiBinomial( c-2*eps[k], a-eps[k] );
                        e[h] := e[h] + u;
                    fi;
                fi;
            od;

            # turn e into a word and add it
            if e <> 0*e then
                SetEntrySCTable( T, j, i, WordByExponents(e) );
            fi;
        od;
    od;

    # check and return
    #if not TestJacobi(T)=true then Error("no Jacobi"); fi;
    L := LieAlgebraByStructureConstants( F, T );
    SetName(L, Concatenation("P",String(n)));
    return L;
end;

