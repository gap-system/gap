
BindGlobal("NPPsi",function(e,q)
    local   psi,  phi,  cs,  c,  a;
    psi := 1;
    phi := q^e-1;
    if e <> 1 then
        cs := Set(Factors(e));
        for c in cs do
            a := Gcd(phi,q^(e/c)-1);
            while a > 1 do
                psi := a*psi;
                phi := phi/a;
                a := Gcd(phi,a);
            od;
        od;
    fi;
    return psi;
end);

InstallGlobalFunction(PPDDegrees, function(g,q)
    local   ppds,  f,  x,  l,  degs,  i,  p,  y,  j;
    ppds := [];
    if not IsRationalFunction(g) then
        g := CharacteristicPolynomial(g);
    fi;
    x := IndeterminateOfLaurentPolynomial(g);
    l := Factors(g);
    degs := List(l,DegreeOfLaurentPolynomial);
    SortParallel(degs,l);
    for i in [1..Length(l)] do
        if IsBound(degs[i]) then
            p := NPPsi(degs[i],q);
            y := PowerMod(x,p,l[i]);
            if not IsOne(y) then
                Add(ppds,degs[i]);
                for j in [i+1..Length(degs)] do
                    if degs[j] mod degs[i] = 0 then
                        Unbind(degs[j]);
                    fi;
                od;
            fi;
        fi;
    od;
    return ppds;
end);
                