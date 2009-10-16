
#############################################################################
##
#F ActionOnInduced( elm, BL, bF, M, bT, sT, char )
## 
ActionOnInduced := function( elm, BL, bF, M, bT, sT, char )
    local e, mat, i;

    # set up
    e := Length(bT);

    # init block matrix
    mat := List( [1..e], x -> false );

    # fill in blocks into mat
    for i in [1..e] do
        mat[i] := CollectMod( elm, bT[i], BL, M, sT, bT, char );
    od;
   
    # convert block matrix to matrix and return
    return MatrixByBlocks( mat, M.field );
end;

#############################################################################
##
#F InducedLieModule( L, U, M, char )
## 
InducedLieModule := function( L, U, M, char )
    local BL, bL, cL, BU, bU, cU, bF, d, ad, p, c, m, W, bT;

    # get good basis
    BL := Basis(L);
    bL := BasisVectors(BL);
    cL := List( bL, x -> Coefficients( BL, x ) );

    BU := M.basis;
    bU := BasisVectors(BU);
    cU := List( bU, x -> Coefficients( BL, x ) );

    bF := BaseSteinitzVectors(cL, cU).factorspace;
    bF := List( bF, x -> LinearCombination( bL, x ) );

    bL := Concatenation( bF, bU );
    BL := Basis(L, bL);

    # add info to M
    M.zero := NullMat( M.dim, M.dim, M.field );
    M.one := IdentityMat( M.dim, M.field );
    
    # the inner derivations of L
    ad := List( bL, x -> AdjointMatrix(BL, x) );

    # strip elements
    p := Characteristic(M.field);
    c := List( bF, x -> StripElement(BL, ad, x, p));
    m := List( c, x -> x.power );
    d := Length(bL);

    # set up induced module W
    W := rec( basis := BL, field := M.field, dim := p^Sum(m) * M.dim );

    # get basis of W
    bT := PolynomialBasis( m, p );

    # fill in matrices
    W.mats := List( [1..d], x -> ActionOnInduced(x, BL, bF, M, bT, c, char));

    # that's it
    return W;
end;

#############################################################################
##
#F IrreducibleLieModulesMultiStep( L, F, ser, dim, [char] )  . . .  induction
##
IrreducibleLieModulesMultiStep := function( arg )
    local F, L, p, ser, lim, eval, char, i, dim, mds, U, V, d, e, c, cc, M, N;

    # set up
    L := arg[1];
    F := arg[2];
    p := Characteristic(F);
    ser := arg[3];
    lim := arg[4];
    if IsBound( arg[5] ) then 
        eval := arg[5]; 
    else
        eval := false;
    fi;

    # check arguments
    if Length(ser) = 0 then Error("need series of subalgebras"); fi;
    if ser[Length(ser)] <> L then Error("need series of subalgebras"); fi;

    # catch a trivial case
    if Dimension(L) = 0 then
        return rec( dim := 1, field := F, basis := Basis(L), mats := [] );
    fi;

    # initialize induction
    dim := Dimension(ser[1]);
    Info(InfoLieMod, 1, "1st step of dimension ", dim);
    mds := IrreducibleLieModulesSingleStep( ser[1], F );
    if not IsBool(lim) then mds := Filtered(mds, x -> x.dim <= lim ); fi;

    # loop
    for i in [2..Length(ser)] do
        U := ser[i-1];
        V := ser[i];
        d := Dimension(V) - Dimension(U);
        e := Dimension(U);
        c := [];
        Info(InfoLieMod, 1, "\n");
        Info(InfoLieMod, 1, i, "th step of dimension ", d, " with ",
                                Length(mds)," modules");

        # choose variables or character
        if IsBool(eval) then 
            char := List( [1..d], x -> Indeterminate(F, x) );
        else
            char := eval{[e+1..e+d]} * One(F);
        fi;
        for M in mds do 

            Info(InfoLieMod, 2, "  inducing module of dim ", M.dim);
            N := InducedLieModule( V, U, M, char );

            Info(InfoLieMod, 2, "  evaluate ",p^Length(char), 
                                " characters and chop");
            cc := EvalAndChopLieModules( N, char );
            Append( c, cc );

        od;
        if not IsBool(lim) then c := Filtered(c, x -> x.dim <= lim ); fi;

        Info(InfoLieMod, 1, "reduce to isomorphism types");
        mds := ReduceLieModules(c);
    od;
    return mds;
end;

#############################################################################
##
#F SubalgebraSeriesRandom(L)
##
SubalgebraSeriesRandom := function(L)
    local U, ser, dim, try, i, V, done, j, l, W, d;

    # start up
    U := Subalgebra(L, [Random(L)]);
    ser := [U, L];
    dim := [Dimension(L)-1];
    try := 0;
    
    # loop
    while ForAny(dim, x -> x > 1) and try <= 10 do
        
        # choose a random step
        i := Random( Filtered( [1..Length(dim)], x -> dim[x] > 1 ) );
        U := ser[i+1];
        V := ser[i];

        # try to refine it
        done := false;
        j := 0;
        while j <= 10 and not done do
            j := j+1;
            l := Random(U);
            W := Subalgebra(L, Concatenation(GeneratorsOfAlgebra(V),[l]));
            d := Dimension(W);
            if d > Dimension(V) and d < Dimension(U) then
                ser := Concatenation(ser{[1..i]},
                                     [W],
                                     ser{[i+1..Length(ser)]});
                dim := Concatenation(dim{[1..i-1]},
                                     [d-Dimension(V), Dimension(U)-d],
                                     dim{[i+1..Length(dim)]});
                done := true;
            fi;
        od;
 
        # record trials
        if not done then try := try+1; fi;
    od;
    return ser;
end;

#############################################################################
##
#F IrreducibleLieModules( L, F, [dim, char] ) 
##
IrreducibleLieModules := function( arg )
    local L, F, ser, dim, i, mds;

    # catch arguments
    L := arg[1];
    F := arg[2];
    ser := SubalgebraSeriesRandom(L);
    
    if IsBound( arg[3] ) and IsInt(arg[3]) then 
        dim := arg[3];
    else
        dim := false;
    fi;
    
    if IsBound(arg[3]) and IsList(arg[3]) or IsBound(arg[4]) then 
        mds := IrreducibleLieModulesMultiStep( L, F, ser, dim, arg[3] );
    else
        mds := IrreducibleLieModulesMultiStep( L, F, ser, dim  );
    fi;

    # set up result
    for i in [1..Length(mds)] do
        IsAbsIrrLieModule(mds[i]);
    od;
    return mds;
end;


