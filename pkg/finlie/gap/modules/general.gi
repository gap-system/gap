
#############################################################################
##
#F PolynomialBasis( n, p )
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
#F Binomials of vectors
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
#F MatrixByBlocks( bmat, fld )
## 
MatrixByBlocks := function( bmat, fld )
    local a, b, M, i, j, k, h, r, s;
    a := Length(bmat);
    b := Length(bmat[1][1]);
    M := NullMat( a*b, a*b, fld );
    for i in [1..a] do
        for j in [1..a] do
            if bmat[i][j] <> false then 
                for k in [1..b] do
                    for h in [1..b] do
                        r := b*(i-1) + k;
                        s := b*(j-1) + h;
                        M[r][s] := bmat[i][j][k][h];
                    od;
                od;
            fi;
        od;
    od;
    return M;
end;

#############################################################################
##
#F IteratedLieBracket( elm, bas, vec )
## 
IteratedLieBracket := function( elm, bas, vec )
    local u, i, j;
    u := elm;
    for i in [1..Length(vec)] do
        for j in [1..vec[i]] do
            u := u * bas[i];
        od;
    od;
    return u; 
end;

#############################################################################
##
#F IsFlagBasis( BL )
##
IsFlagBasis := function( BL )
    local bL, i, j, c, k;
    bL := BasisVectors(BL);
    for i in [1..Length(bL)] do
        for j in [i+1..Length(bL)] do
            c := Coefficients( BL, bL[i]*bL[j] );
            k := PositionNonZero( c );
            if k < i then return false; fi;
        od;
    od;
    return true;
end;

