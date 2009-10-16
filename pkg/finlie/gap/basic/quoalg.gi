#############################################################################
##
## quoalg.gi                                                     Bettina Eick
##

#############################################################################
##
#F Coefficients( B, v )
##
InstallOtherMethod( Coefficients, true, [IsList, IsObject], 0,
function( B, v )
    return SolutionMat( List( B, x -> x![1] ), v![1] );
end );

#############################################################################
##
#F CoefficientsByCBS( B, v )
##
CoefficientsByCBS := function( B, v )
    return SolveTriangularMat( List(B, x -> x![1] ), v![1] );
end;

#############################################################################
##
#F CoefficientsInFactor( e, fbase, ibase )
##
CoefficientsInFactor := function( e, fbase, ibase )
    local df, di, c, d, j, k, a, b;

    # set up
    df := List( fbase, DepthLVector );
    di := List( ibase, DepthLVector );
    c := List( fbase, x -> 0 );

    # loop
    repeat
        d := PositionNonZero(e);
        if d > Length(e) then return c; fi;

        j := Position(df,d);
        k := Position(di,d);
        if not IsBool(j) then 
            a := fbase[j]![1][d];
            b := e[d];
            c[j] := b/a;
            e := e - c[j]*fbase[j]![1];
        elif not IsBool(k) then
            a := ibase[k]![1][d];
            b := e[d];
            e := e - (b/a)*ibase[k]![1];
        fi;
    until false;
end;

#############################################################################
##
#F LieHomomorphism( <L>, <M>, <l>, <m> )
##
LieHomomorphism := function( L, M, bl, bm )
    return rec( source := L, range := M, gens := bl, imgs := bm );
end;

LieImage := function( arg )
    local hom, c;
    hom := arg[1];
    if Length(arg) = 2 then
        c := CoefficientsByCBS( hom.gens, arg[2] );
        return c * hom.imgs;
    elif IsBound( hom.image ) then
        return hom.image;
    else
        hom.imgs := Subalgebra( hom.range, hom.imgs );
        return hom.image;
    fi;
end;

LieKernel := function( hom )
    local vecs, solv, kern;
    if IsBound( hom.kernel ) then return hom.kernel; fi;
    vecs := List( hom.imgs, x -> x![1] );
    solv := NullspaceMat( vecs );
    kern := List( solv, x -> x * hom.gens );
    hom.kernel := Subalgebra( hom.source, kern );
    return hom.kernel;
end;

LiePreimage := function( hom, l )
    local c, bl, pl, ul;
    if IsLieAlgebra(l) then
        bl := CBS(l);
        pl := List( bl, x -> Coefficients( hom.imgs, x )*hom.gens );
        ul := CBS(LieKernel(hom));
        return Subalgebra( hom.source, Concatenation(pl,ul) );
    else
        c := Coefficients( hom.imgs, l );
        return c * hom.gens;
    fi;
end;

#############################################################################
##
#F LieQuotientHomomorphism( <L>, <I> )
##
LieQuotientHomomorphism := function( L, I )
    local p, l, b, d, f, T, i, j, a, F, pre, img, nat;

    # the full space
    p := Characteristic(LeftActingDomain(L));
    l := CBS(L);
    if Length(l) < Length(l[1]![1]) then Error("L must be parent"); fi;

    # the ideal
    b := CBS(I);
    d := List( b, DepthLVector );

    # the factor
    f := Filtered( l, x -> not DepthLVector(x) in d );
    T := TrivialTable( Length(f), p );

    # fill up table
    for i in [1..Length(f)] do
        for j in [i+1..Length(f)] do
            a := f[i]*f[j];
            a := CoefficientsInFactor( a![1], f, b );
            T[i][j] := a * One(GF(p));
            T[j][i] := - T[i][j];
        od;
    od;
    F := LieAlgebraByTable(T);

    # the homomorphism
    pre := Concatenation(f,b);
    img := Concatenation(CBS(F), List(b, z -> Zero(F)));
    return rec( source := L, range := F, 
                image := F,  kernel := I, 
                gens := pre, imgs := img );
end;

#############################################################################
##
#F LieAlgebraMod( <L>, <j> )
##
LieAlgebraMod := function( L, j )
    local T, S;
    T := TableByBasis( L, CBS(L) );
    S := T{[1..j]}{[1..j]}{[1..j]};
    return LieAlgebraByTable(S);
end;

#############################################################################
##
#F InducedActionLieHomomorphism( nat, B )
##
InducedActionLieHomomorphism := function(nat, B)
    local d, v, c, m, n, C;
    d := Dimension(nat.image);
    v := List( nat.gens, x -> x![1] );
    c := [];
    for m in GeneratorsOfGroup(B) do
        n := List( v{[1..d]}, x -> SolutionMat( v, x * m ){[1..d]} );
        Add( c, n );
    od;
    C := Group(c, IdentityMat(d, FieldOfMatrixGroup(B)));
    return GroupHomomorphismByImagesNC( B, C, GeneratorsOfGroup(B), c );
end;

