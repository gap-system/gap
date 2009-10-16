
FindIdealDeterministic := function(L)
    local vec, elm, e, U, b, i;

    # try some basics
    U := LieDerivedSubalgebra(L);
    if Dimension(U) < Dimension(L) and Dimension(U) <> 0 then 
        return U;
    fi;
    
    U := LieCentre(L);
    if Dimension(U) < Dimension(L) and Dimension(U) <> 0 then 
        return U;
    fi;

    # now we need the full force
    vec := BasisVectors(Basis(L));
    elm := Elements(L);
    for i in [1..Length(elm)] do
        Print("checking ",i," \n"); 
        b := List(vec, x -> elm[i]*x);
        U := IdealByGenerators( L, b );
        if Dimension(U)<>0 and Dimension(U)<Dimension(L) then 
            return U;
        fi;
    od;
    return fail;
end;

FindIdealRandom := function(L)
    local U, vec, i;

    # try some basics
    U := LieDerivedSubalgebra(L);
    if Dimension(U) < Dimension(L) and Dimension(U) <> 0 then 
        return U;
    fi;
    
    U := LieCentre(L);
    if Dimension(U) < Dimension(L) and Dimension(U) <> 0 then 
        return U;
    fi;

    # try basis
    for i in [1..Dimension(L)] do
        Print("try basis \n");
        vec := BasisVectors(Basis(L))[i];
        U := IdealByGenerators( L, [vec] );
        if Dimension(U)<>0 and Dimension(U)<Dimension(L) then 
            return U;
        fi;
   od;
    # try at random
    for i in [1..Dimension(L)] do
        Print("try random \n");
        vec := Random(L);
        U := IdealByGenerators( L, [vec] );
        if Dimension(U)<>0 and Dimension(U)<Dimension(L) then 
            return U;
        fi;
   od;
 
    return fail;
end;
  
ChiefSeriesLieAlgebra := function(L)
    local B, b, m, M, U, i, F;

    F := LeftActingDomain(L);
    B := Basis(L);
    b := BasisVectors(B);
    m := List( b, x -> TransposedMat(AdjointMatrix( B,x )));
    M := GModuleByMats( m, F );
    if SMTX.IsIrreducible(M) then return [L]; fi;

    U := SMTX.BasesCompositionSeries(M);
    for i in [2..Length(U)] do
        U[i] := IdealByGenerators( L, List(U[i], x -> x*b) );
    od;
    return U{[2..Length(U)]};
end;

IdealsOfLieAlgebra := function(L)
    local B, b, m, M, U, i;

    Print("Warning: produces incorrect results\n");

    B := Basis(L);
    b := BasisVectors(B);
    m := List( b, x -> TransposedMat(AdjointMatrix( B,x )));
    M := GModuleByMats( m, GF(2) );
    if SMTX.IsIrreducible(M) then return [L]; fi;

    U := SMTX.BasesSubmodules(M);
    for i in [2..Length(U)] do
        U[i] := IdealByGenerators( L, List(U[i], x -> x*b) );
    od;
    return U{[2..Length(U)]};
end;

SimpleFactorsLieAlgebra := function(L)
    local B, b, m, M, f, U, i, F;

    # a simple check
    if IsLieSolvable(L) then return []; fi;

    # try to find a submodule
    B := Basis(L);
    b := BasisVectors(B);
    m := List( b, x -> TransposedMat(AdjointMatrix( B,x )));
    M := GModuleByMats( m, GF(2) );
    if SMTX.IsIrreducible(M) then return [L]; fi;
    U := SMTX.BasesCompositionSeries(M);

    # consider each factor
    f := [];
    U[1] := IdealByGenerators(L, [Zero(L)]);
    for i in [2..Length(U)] do
        U[i] := IdealByGenerators( L, List(U[i], x -> x*b) );
        F := U[i]/U[i-1];
        if not IsLieSolvable(F) then Add( f, F ); fi;
    od;
    return f;
end;

ChiefSeriesDimensionsLieAlgebra := function(L)
    local B, b, m, M, U, i;

    B := Basis(L);
    b := BasisVectors(B);
    m := List( b, x -> TransposedMat(AdjointMatrix( B,x )));
    M := GModuleByMats( m, GF(2) );
    if SMTX.IsIrreducible(M) then return [Dimension(L)]; fi;

    U := SMTX.BasesCompositionSeries(M);
    U := List( [2..Length(U)], x -> Length(U[x])-Length(U[x-1]));
    return U;
end;

SimpleSubfactorsAtRandom := function( L )
    local u, U, C, F, f, i;
    i := 0;
    while true do
        i := i+1;
        u := Random(L);
        U := Subalgebra( L, [u] );
        C := Centralizer( L, U );
        F := C/U;
        f := SimpleFactorsLieAlgebra(F);
        if Length(f)>0 then return f; fi;
        Print(i, " centralizer has dimension ",Dimension(F)," \n");
    od;
end;

