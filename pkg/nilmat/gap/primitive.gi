#############################################################################
##
#W  primitive.gi                   NilMat                        Alla Detinko
#W                                                               Bettina Eick
#W                                                              Dane Flannery
##

##
## This file contains a method to determine all nilpotent primitive matrix
## groups in GL(n,q) up to conjugacy.
##

#############################################################################
##
#F SingerCycle( n, po, l ) . . . . . . . . . . . . a Singer cycle in GL(n,po)
##
SingerCycle := function(n,po,l)
    local F, F1, a, B;
    F := GF(po^l);
    F1 := GF(F, n);
    a := PrimitiveRoot(F1);
    B := Basis(F1);
    return List(BasisVectors(B), x -> Coefficients(B, x*a));
end;

#############################################################################
##
#F OrdersPAG( n, po, l ) . . . . . . . . . . orders of primitive abelian grps
##
OrdersPAG := function(n, po, l)
    local q, qn, l1, l2, K1, K2, y, d;
    q := po^l;
    qn := q^n - 1;
    l1 := Filtered([1..n], IsPrime);
    l1 := Filtered(l1, x -> IsInt(n/x));
    l2 := List(l1, r -> r*(q^(n/r) - 1));
    K1 := DivisorsInt(qn);
    K2 := [];
    for y in K1 do
        if ForAll(l2, x -> not IsInt(x/y))
            then Add(K2,y);
        fi;
    od;
    return K2;
end;

#############################################################################
##
#F PrimitiveAbelianGens( n, po, l ) . . . . . gens for primitive abelian grps
##
PrimitiveAbelianGens := function (n, po, l)
    local qn, K2, a, Anq;
    qn := po^(l*n) - 1;
    K2 := OrdersPAG(n, po, l);
    a := SingerCycle(n, po, l);
    return List(K2, x -> a^(qn/x));
end;

#############################################################################
##
#F OddPrimitiveAbelianGens( n, po, l ) . . . . gens for odd prim. abel. grps 
##
OddPrimitiveAbelianGens := function (n, po, l)
    local qn, a, K2, K3;
    qn := po^(l*n) - 1;
    K2 := OrdersPAG(n, po, l);
    K3 := Filtered(K2, x -> x mod 2 = 1);
    a := SingerCycle(n, po, l);
    return List(K3, x -> a^(qn/x));
end;

#############################################################################
##
#F SpecialMatrix( po, t )
##
## Construct a matrix g = [[x,y],[y,-x]] with x^2+y^2 = -1.
##
SpecialMatrix := function(po,t)
    local z,i,o,j,x,y,g,n;
 
    z := Z(po,t);
    o := z^0;
    n := po^t-1;
 
    i := 1;
    x := z;
    y := z;
   
    while  x^2 + y^2 <> -o  and  i <= n  do
        i := i+1;
        x := z^i;
        j := 1;
        y := z;
      
        while  x^2 + y^2 <> -o  and j<= n  do
            j := j+1;
            y := z^j;
        od;
    od;
 
    g := [[x,y],[y,-x]];
    return g;
end;

############################################################################
##
#F NilpotentPrimitiveMatGroups( n, po, l )
##
## Returns a complete and irredundant list of conjugacy class representatives
## of the nilpotent primitive subgroups of GL(n,qo^l).
##
NilPrimMatGroups := function(n, po, l)
    local q, m, Pnq, Cnq, t, e, d, s, a, b, i;

    # set up
    q := po^l;
    m := n/2;

    # start with abelian primitive groups
    Pnq := List( PrimitiveAbelianGens(n, po,l), x -> GroupByGenerators([x]));
    if po = 2 or n mod 2 = 1 or IsInt(n/4) or q mod 4 = 1 then return Pnq; fi;

    # consider abelian primitive groups of odd order in deg n/2
    Cnq := OddPrimitiveAbelianGens(m, po, l); 
    if Cnq = [] then return Pnq; fi;
    Cnq := List(Cnq, x -> KroneckerProduct(x, IdentityMat(2, GF(q))));

    # set up for additions
    t := PLength((q^n - 1), 2);
    e := IdentityMat(m, GF(q));
    d := KroneckerProduct(e, DiagonalMat([Z(q)^0,-1*Z(q)^0]));
    s := KroneckerProduct(e, SpecialMatrix(po, l));
    a := KroneckerProduct(e, AbelianSylow(po, l*m));

    # extend list
    b := a^(2^(t-2));
    Append( Pnq, List(Cnq, x -> GroupByGenerators([x, a, d])));
    Append( Pnq, List(Cnq, x -> GroupByGenerators([x, b, s])));

    # this is all in certain cases
    if po mod 8 = 3 then return Pnq; fi;
      
    # extend list further
    for i in [1..(t-3)] do
        b := a^(2^i);
        Append( Pnq, List(Cnq, x -> GroupByGenerators([x, b, d])));
        Append( Pnq, List(Cnq, x -> GroupByGenerators([x, b, s])));
    od;

    return Pnq;
end;

InstallGlobalFunction( SizesOfNilpotentPrimitiveMatGroups, function(n, po, l)
    local q, Anq, Pnq, m, i, Cnq, t, N1nq, N2nq, L1, N3nq;

    q := po^l;
    m := n/2;
    t := PLength((q^n - 1), 2);

    # start with abelian primitive groups
    Pnq := OrdersPAG(n, po, l);
    if po = 2 or n mod 2 = 1 or IsInt(n/4) or q mod 4 = 1 then return Pnq; fi;

    # consider abelian primitive groups of odd order in deg n/2
    Cnq := Filtered(OrdersPAG(m, po, l), x -> x mod 2 = 1);
    Append( Pnq, List( Cnq, x -> 2^(t+1)*x ));
    Append( Pnq, List( Cnq, x -> 8*x));

    # this is all in certain cases
    if po mod 8 = 3 then return Pnq; fi;

    # extend list further
    for i in [1..(t-3)] do
        Append( Pnq, List(Cnq, x -> 2^(t-i+1) * x) );
        Append( Pnq, List(Cnq, x -> 2^(t-i+1) * x) );
    od;

    return Pnq;
end );

InstallGlobalFunction( NilpotentPrimitiveMatGroups, function(n,po,l)
    local Pnq, i, Onq;
    Pnq := NilPrimMatGroups(n,po,l);
    Onq := SizesOfNilpotentPrimitiveMatGroups(n, po, l);
    for i in [1..Length(Pnq)] do
        SetIsNilpotentGroup( Pnq[i], true );
        SetSize( Pnq[i], Onq[i] );
    od;
    return Pnq;
end );
