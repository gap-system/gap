#############################################################################
##
#W  nilpotency.gi                   NilMat                       Alla Detinko
#W                                                               Bettina Eick
#W                                                              Dane Flannery
##

##
## This file contains methods to check whether a given matrix group over 
## GF(q) or Q is nilpotent. The methods for groups over Q need Polenta. The
## group needs to be finitely generated.
##

#############################################################################
##
## Some helpers
##
PLength := function(a,p)
    return Length(Filtered(Factors(a), x -> x = p));
end;

PrimeFactors := function(list)
    local prm;
    prm := Flat(List(list, Factors));
    prm := Set(prm);
    return Filtered(prm, x -> x <> 1);
end;

PAndPrimePart := function( elm, q )
    local o, f, a, b, g;
    o := Order(elm);
    f := Factors(o);
    a := Product(Filtered(f, x -> x in q));
    b := Product(Filtered(f, x -> not x in q));
    g := Gcdex(a,b);
    return [elm^(g.coeff2*b), elm^(g.coeff1*a)];
end; 

IsCentralElement := function(H,a)
    local h;
    for h in GeneratorsOfGroup(H) do
        if h*a <> a*h then return false; fi;
    od;
    return true;
end;

IsCentralSubgroup := function(H,U)
    local h, a;
    for h in GeneratorsOfGroup(H) do
        for a in GeneratorsOfGroup(U) do
            if h*a <> a*h then return false; fi;
        od;
    od;
    return true;
end;

GroupsCommute := function(S,U)
    local s, u, a, b;
    s := GeneratorsOfGroup(S);
    u := GeneratorsOfGroup(U);
    for a in s do
        for b in u do
            if not a*b = b*a then return false; fi;
        od;
    od;
    return true;
end;

OrbitStabGens := function(G, v)
    local g, h, l, orb, trs, stb, c, i, w, j, U, s;

    # set up
    g := GeneratorsOfGroup(G);
    h := List(g, x -> x^-1);
    l := Length(g);

    # set up for orbit-stab computation
    orb := [v];
    trs := [One(G)];
    stb := [];
    c := 0;
    while c < Length(orb) do
        c := c+1;
        for i in [1..l] do
            w := h[i]*orb[c]*g[i];
            j := Position(orb, w);
            if IsBool(j) then
                Add(orb, w);
                Add(trs, trs[c]*g[i]);
            else
                s := trs[c]*g[i]*trs[j]^-1;
                if s <> One(G) then AddSet(stb, s); fi;
            fi;
        od;
    od;

    # that is it
    U := GroupByGenerators(stb);
    U!.index := Length(orb);
    return U;
end;
       
MakeMatGroup := function(F, gens)
    local s;
    s := Set(gens);
    if Length(s) > 1 then s := Filtered(s, x -> x <> x^0); fi;
    s := List(s, x -> ImmutableMatrix(F,x));
    return GroupByGenerators(s);
end;

#############################################################################
##
#F IsCompletelyReducibleNilpotentMatGroup(G)
##
InstallGlobalFunction( IsCompletelyReducibleNilpotentMatGroup, function(G)
    local J, g;
    J := JordanSplitting(G);
    g := GeneratorsOfGroup(J[2]);
    return ForAll( g, x -> x = One(G) );
end );

#############################################################################
##
#F ClassLimit(n,F) . . . . . . . . . an upper bound for the nilpotency class
##
## The function returns an upper bound for the nilpotency class of a
## nilpotent subgroup of GL(n,F). The field F needs to be finite or of
## char Q (otherwise the function returns fail).
##
InstallGlobalFunction( ClassLimit, function(n, F)
    local p, q, t, f, m, s;

    p := Characteristic(F);

    # in char 0 the class limit is easy to obtain
    if F = Rationals then return Int(3*n/2); fi;

    # otherwise the field needs to be finite for our methods
    if not IsFinite(F) then return fail; fi;

    # get relevant primes
    f := [];
    for t in [2..n] do
        if t <> p and IsPrimeInt(t) then
            if ForAny([1..n], x -> IsInt((Size(F)^x - 1)/t)) then
                Add( f, t );
            fi;
        fi;
    od;

    # loop over relevant primes
    m := 1;
    for t in f do
        s := PLength(Size(F)-1,t);
        m := Maximum(m, t*s - s + 1);
    od;

    # that's it
    return n*m;
end );

#############################################################################
##
#F SecondCentralElement(G, H, l) . . . . . . . . .an element in Z_2(H) \ Z(H)
##
## The function returns an element in Z_2(H) which is not in Z(H). The
## function assumes that H is a nilpotent normal subgroup of G (it may return
## fail otherwise). The integer l is an upper bound to the nilpotency class
## of H.
##
SecondCentralElement := function(G, H, l)
    local h, g, a, b, i, c;

    # find initial element and check that H is non-abelian
    h := GeneratorsOfGroup(H);
    g := GeneratorsOfGroup(G);
    a := First(h, x -> not IsCentralElement(H,x));
    if IsBool(a) then return fail; fi;

    # find second central element
    i := 0;
    c := 0;
    while i < Length(g) do
        i := i+1;
        b := Comm(g[i],a);
        if not IsCentralElement(H,b) then
            a := b;
            i := 0;
            c := c+1;
            if c > l then return fail; fi;
        fi;
    od;
    return a;
end;

#############################################################################
##
#F NonCentralAbelian(H, a) . . non-central abelian subgroup of H containing a
##
## The function returns a non-central abelian subgroup of H containing the
## element a. The element a is the result of SecondCentralElement. The
## abelian subgroup is generated by two elements.
##
## Note: This function is not currently used.
##
NonCentralAbelian := function(H,a)
    local h, b, c;
    h := GeneratorsOfGroup(H);
    for b in h do
        c := Comm(b,a);
        if c <> One(H) then
            return Subgroup(H, [a,c]);
        fi;
    od;
    return fail;
end;

#############################################################################
##
#F AbelianNormalSeries(G, l) . . . . . . a normal series with abelian factors
##  
## The function returns a normal series with abelian factors of G. The group
## G has to be non-abelian and nilpotent (otherwise the function may return
## fail). The integer l is a limit to the nilpotency class of G.
##

InstallGlobalFunction( AbelianNormalSeries, function(G, l)
    local n, p, C, s, c, a;

    # set up
    n := DimensionOfMatrixGroup(G);
    p := Characteristic(FieldOfMatrixGroup(G));

    # initialise series
    C := G;
    s := [C];

    # loop
    c := 0;
    while not IsAbelian(C) do

        # increase counter -- check that c <= n-1
        c := c+1;
        if c > n-1 then return fail; fi;

        # get relevant element
        Info(InfoNilMat, 3, "   - ",c,"the second central element ");
        a := SecondCentralElement(G,C,l);
        if IsBool(a) then return fail; fi;

        C := OrbitStabGens(C, a);
        Add(s, C);

        Info(InfoNilMat, 3, "   - centralizer has index ",C!.index);
        if IsInt(C!.index/p) then return fail; fi;
    od;

    return s;
end );

#############################################################################
##
#A IsUnipotentMatGroup(G)
##
InstallMethod( IsUnipotentMatGroup, true, [IsMatrixGroup], 0,
function(G)
    local n, F, g, V, U;

    n := DimensionOfMatrixGroup(G);
    F := FieldOfMatrixGroup(G);
    g := List(GeneratorsOfGroup(G), x -> x - x^0);
    U := IdentityMat(n, F);

    repeat
        V := U;
        U := BaseMat(Concatenation(List(g, x -> V*x)));
    until Length(V) = Length(U) or Length(U) = 0;

    return (Length(U) = 0);
end );

#############################################################################
##
#A JordanSplitting(G) . . . . . . . . . . . . . . . the Jordan decomposition
##
## The function returns the Jordan decomposition of G as a list of two groups
## [S,U]. If G is nilpotent, then G = S x U, the group U is unipotent and S is
## semisimple.
##
InstallMethod( JordanSplitting, true, [IsMatrixGroup], 0,
function(G)
    local g, F, d, S, U;

    # set up
    g := GeneratorsOfGroup(G);
    F := FieldOfMatrixGroup(G);

    # split every generator
    d := List(g, JordanDecomposition);

    # create new groups
    S := MakeMatGroup( F, ShallowCopy(List(d, x -> x[1])) );
    U := MakeMatGroup( F, List(d, x -> (x[2] * x[1]^-1) + One(G)) );

    return [S, U];
end );

#############################################################################
##
#A PiPrimarySplitting(G) . . . . . . . . . . . . . .the pi-primary splitting
##
## Let pi be the set of primes in the range [1..dim(G)].
## This function returns a list [B,C] of subgroups of G with G = BC.
##
## If G is nilpotent, then G = B x C,
## C is the product of all Sylow p-subgroups with p > n, and
## B is the product of all remaining Sylow subgroups.
## Further, if G is nilpotent, then C is central in G.
##
## The group G needs to be a matrix group over a finite field.
##
InstallMethod( PiPrimarySplitting, true, [IsMatrixGroup], 0,
function(G)
    local F, n, q, s, B, C;

    # set up
    F := FieldOfMatrixGroup(G);
    n := DimensionOfMatrixGroup(G);
    q := Filtered([1..n], IsPrimeInt);

    # check
    if not IsFinite(F) then TryNextMethod(); fi;

    # split every generator
    s := List(GeneratorsOfGroup(G), x -> PAndPrimePart(x,q));

    # generate groups
    B := MakeMatGroup(F, List(s, x -> x[1]));
    C := MakeMatGroup(F, List(s, x -> x[2]));

    return [B,C];
end );

#############################################################################
##
#F SylowSubgroupOfNilpotentMatGroupFF(G, g, p)
##
## The function returns a Sylow p-subgroup of G where G is a nilpotent matrix
## group over GF(q). The list g has to be a polycyclic sequence for G.
##
SylowSubgroupOfNilpotentMatGroupFF := function(G, g, p)
    local F, s, U;
    F := FieldOfMatrixGroup(G);
    s := List(g, x -> PAndPrimePart(x,[p])[1]);
    U := MakeMatGroup( F, s );
    SetIsPGroup(U, true);
    SetPrimePGroup(U, p);
    return U;
end;

#############################################################################
##
#F PcGensBySeries(G, s)
##
## The function returns a polycyclic sequence for G using the abelian normal
## series s of G.
##
PcGensBySeries := function(G, s)
    local b, i;
    b := ShallowCopy(GeneratorsOfGroup(s[Length(s)]));
    for i in Reversed([1..Length(s)-1]) do
        Append(b, Filtered(GeneratorsOfGroup(s[i]), x -> not (x in b)));
    od;
    return b;
end;

#############################################################################
##
#F IsNilpotentMatGroupFF(G, l) . . . . . . . . . . . . .check nilpotency of G
##
## The function returns true if G is nilpotent and false otherwise. The
## group G is a subgroup of GL(n,F), where F is a finite field, and the
## integer l is an upper bound to the nilpotency class of G.
##
IsNilpotentMatGroupFF := function(G, l)
    local p, n, J, S, U, P, B, C, s, o, r, b, syl, q, W, V;

    Info( InfoNilMat, 1, "start testing nilpotency ");
    p := Characteristic(FieldOfMatrixGroup(G));
    n := DimensionOfMatrixGroup(G);

    # catch a trivial case
    if Length(GeneratorsOfGroup(G)) = 1 then return true; fi;

    # compute Jordan splitting
    Info( InfoNilMat, 1, "determine Jordan decomposition G <= <S,U>");
    J := JordanSplitting(G);
    S := J[1];
    U := J[2];

    Info( InfoNilMat, 1, "checking Jordan decomposition ");
    Info( InfoNilMat, 2, "  - checking [S,U] = 1 ");
    if not GroupsCommute(S,U) then return false; fi;
    Info( InfoNilMat, 2, "  - checking that U is unipotent ");
    if not IsUnipotentMatGroup(U) then return false; fi;

    # it remains to consider S
    Info( InfoNilMat, 1, "determine pi-primary decomposition S = <B,C>");
    P := PiPrimarySplitting(S);
    B := P[1];
    C := P[2];

    Info( InfoNilMat, 1, "checking pi-primary decomposition ");
    Info( InfoNilMat, 2, "  - check that pi-part C is central ");
    if not IsCentralSubgroup(S, C) then return false; fi;
    Info( InfoNilMat, 2, "  - check wether pi'-part B is abelian ");
    if IsAbelian(B) then return true; fi;

    # compute series through B
    Info( InfoNilMat, 1, "compute abelian normal series of B with limit ",l);
    s := AbelianNormalSeries(B, l);
    if IsBool(s) then return false; fi;
    Info( InfoNilMat, 2, "  - found series of length ",Length(s));

    # check the prime factors of |B|
    o := PrimeFactors(List(s{[2..Length(s)]}, x -> x!.index));
    r := PrimeFactors(List(GeneratorsOfGroup(s[Length(s)]), Order));
    o := Union(o,r);
    Info( InfoNilMat, 1, "B has prime factors ",o);
    if ForAny(r, x -> IsInt(x/p)) then return false; fi;
    if ForAny(o, x -> x > n) then return false; fi;

    # pick up polycyclic generators for B (perhaps more)
    b := PcGensBySeries(B, s);
    Info( InfoNilMat, 1, "B has ",Length(b)," pc gens ");

    # now we leave the Detinko-Flannery paper and do a simple final check
    # if B is nilpotent, then we construct its Sylow subgroups
    #      and note that they commute
    # if B is not nilpotent, then we construct supergroups of the
    #      Sylow subgroups and they will not commute

    syl := [];
    for q in o do
        Info( InfoNilMat, 1, "determine Sylow ",q,"-subgroup of B");
        W := SylowSubgroupOfNilpotentMatGroupFF(B, b, q);
        for V in syl do
            if not GroupsCommute(W,V) then return false; fi;
        od;
        Add( syl, W);
    od;

    SetSylowSystem(B, syl);
    return true;
end;

#############################################################################
##
## IsNilpotentMatGroupRN( G ) . . . . . .nilpotency testing for groups over Q
##
## The function returns true if G is nilpotent and false otherwise. The
## group G is a subgroup of GL(n,Q) and the integer l is an upper bound to
## the nilpotency class of G.
##
IsNilpotentMatGroupRN := function(G, l)
    local n, g, d, S, U, s, p, t, pcgs, kern, K;

    n := DimensionOfMatrixGroup(G);
    g := GeneratorsOfGroup(G);
    if Length(g) = 1 then return true; fi;
   
    # first split by Jordan Decomposition
    d := List(g, JordanDecomposition);
    S := GroupByGenerators(List(d, x -> x[1]));
    U := GroupByGenerators(List(d, x -> x[2]*x[1]^-1 + One(G)));

    # check [S,U] = 1 and IsUnipotent(U)
    if not GroupsCommute(S,U) then return false; fi;
    if not IsUnipotentMatGroup(U) then return false; fi;
    if IsAbelian(S) then return true; fi;

    # consider S using Polenta
    s := GeneratorsOfGroup(S);
    p := DetermineAdmissiblePrime(s);

    # check image of congruence hom
    t := InducedByField(s, GF(p));
    if not IsNilpotentMatGroupFF(GroupByGenerators(t),l) then
        return false;
    fi;

    # get kernel of congruence hom
    pcgs := CPCS_finite_word( t, n+2 );
    kern := POL_NormalSubgroupGeneratorsOfK_p( pcgs, s );
    kern := Filtered(kern, x -> not x = One(G));
    if Length(kern) = 0 then return true; fi;

    # check that the kernel is central
    K := GroupByGenerators(kern);
    if not IsCentralSubgroup(S, K) then return false; fi;
  
    # that's it
    return true;
end;

#############################################################################
##
#F IsNilpotentMatGroup( G ) . . . .  nilpotency testing a la Flannery-Detinko
##
InstallGlobalFunction( IsNilpotentMatGroup, function(G)
    local F, p, l, n;

    F := FieldOfMatrixGroup(G);
    n := DimensionOfMatrixGroup(G);

    # get class limit
    l := ClassLimit(n, F);

    # choose case
    if IsFinite(F) then
        return IsNilpotentMatGroupFF(G, l);
    fi;
    if F = Rationals then
        return IsNilpotentMatGroupRN(G, l);
    fi;

    # otherwise there is no method
    return fail;
end );

##
## need to install this method with high value, as otherwise for the
## finite field case GAP determines a permutation group and tests 
## nilpotency of that.
##
InstallMethod( IsNilpotentGroup, true, [IsMatrixGroup], SUM_FLAGS,
function(G)
    local F;
    F := FieldOfMatrixGroup(G);
    if IsFinite(F) or F = Rationals then return IsNilpotentMatGroup(G); fi;
    TryNextMethod();
end );
