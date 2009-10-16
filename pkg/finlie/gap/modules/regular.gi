
#############################################################################
##
#F ActionOnTensor( elm, L, BL, bT, sT, char )
## 
ActionOnTensor := function( elm, L, BL, bT, sT, char )
    local e, mat, i;

    # set up
    e := Length(bT);

    # compute matrix
    mat := List( [1..e], x -> [] );
    for i in [1..e] do
        mat[i] := Collect( L, BL, elm, bT[i], sT, bT, char );
    od;
    return mat;
end;

#############################################################################
##
#F RegularLieModule( L, F, char )
## 
RegularLieModule := function( L, F, char )
    local BL, bL, dL, ad, p, c, m, W, bT;

    # get bases
    BL := Basis(L);
    bL := BasisVectors(BL);
    dL := Length(bL);
    
    # the inner derivations of L
    Info(InfoLieMod, 2, "  determining adjoints and strip");
    ad := List( bL, x -> AdjointMatrix(BL, x) );

    # strip elements
    p := Characteristic(F);
    c := List( bL, x -> StripElement(BL, ad, x, p));
    m := List( c, x -> x.power );

    # set up small and big modules
    W := rec( basis := BL, field := F, dim := p^Sum(m) );

    # get basis
    bT := PolynomialBasis( m, p );

    # fill in matrices
    Info(InfoLieMod, 2, "  compute matrices in dimension ",Length(bT));
    W.mats := List([1..dL], x -> ActionOnTensor(x, L, BL, bT, c, char));

    # that's it
    return W;
end;

#############################################################################
##
#F IrreducibleLieModulesSingleStep( L, F, [char] ) . . . using regular module
##
IrreducibleLieModulesSingleStep := function(arg)
    local L, F, p, char, poss, vars, subs, i, M, c;

    # catch arguments
    L := arg[1];
    F := arg[2];
    p := Characteristic(F);
    if Length(arg) = 3 then 
        char := arg[3]; 
    else
        char := List( Basis(L), x -> false );
    fi;

    # catch a trivial case
    if Length(char) = 0 then 
        return [rec( dim := 1, field := F, basis := Basis(L), mats := [] )];
    fi;
   
    # add variables if necessary
    poss := Filtered([1..Length(char)], x -> char[x] = false);
    vars := List(poss, x -> Indeterminate(F, x));
    subs := StructuralCopy(char); 
    for i in [1..Length(poss)] do subs[poss[i]] := vars[i]; od;
    subs := subs * One(F);

    # compute regular module
    Info(InfoLieMod, 1, "computing regular module");
    M := RegularLieModule( L, F, subs );

    # evaluate characters and chop
    Info(InfoLieMod, 1, "evaluate ", p^Length(poss), " characters");
    c := EvalAndChopLieModules( M, vars );

    Info(InfoLieMod, 1, "reduce to isomorphism types");
    return ReduceLieModules(c);
end;

