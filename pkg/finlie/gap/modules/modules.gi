
#############################################################################
##
#F IsLieModule( M )
##
IsLieModule := function( M )
    local b, d, i, j, c, l, r, t;

    b := BasisVectors( M.basis );
    d := Length(b);

    # simple checks
    if Length(M.mats) <> Length(b) then return false; fi;
    if ForAny(M.mats, x -> Length(x) <> M.dim ) then return false; fi;

    # check relations
    for i in [1..d] do
        for j in [i+1..d] do
            c := Coefficients( M.basis, b[i]*b[j] );
            l := M.mats[i]*M.mats[j] - M.mats[j]*M.mats[i];
            r := LinearCombination( c, M.mats );
            t := l-r;
            if t <> 0 * t then return false; fi;
        od;
    od;

    # that's it
    return true;
end;

#############################################################################
##
#F ChopLieModule( M )
##
ChopLieModule := function( M )
    local MM, cc, i, new;
    MM := GModuleByMats( M.mats*One(M.field), M.field );
    cc := SMTX.CompositionFactors(MM);
    for i in [1..Length(cc)] do
        new  := rec( basis := M.basis, 
                     field := M.field, 
                     dim := cc[i].dimension, 
                     mats := cc[i].generators );
        if IsBound(cc[i].IsAbsolutelyIrreducible) then 
            new.absirr := cc[i].IsAbsolutelyIrreducible;
        fi;
        cc[i] := new;
    od;
    return cc;
end;

#############################################################################
##
#F IsomorphicLieModules( M, N )
##
IsomorphicLieModules := function( M, N )
    local MM, NN;
    if M.dim <> N.dim then return false; fi;
    if M.field <> N.field then return false; fi;
    if M.basis <> N.basis then return false; fi;
    if List(M.mats, RankMat) <> List(N.mats, RankMat) then return false; fi;
    MM := GModuleByMats( M.mats*One(M.field), M.field );
    NN := GModuleByMats( N.mats*One(N.field), N.field );
    SMTX.IsIrreducible(MM);
    return not IsBool(SMTX.Isomorphism( MM, NN ));
end;

#############################################################################
##
#F ReduceLieModules( Mlist )
##
ReduceLieModules := function(c)
    local r, k, found, h;
    r := [];
    for k in c do
        found := false;
        for h in [1..Length(r)] do
            if IsomorphicLieModules( k, r[h] ) then
                found := true;
            fi;
        od;
        if found = false then Add( r, k ); fi;
    od;
    return r;
end;

#############################################################################
##
#F IsAbsIrrLieModule(M)
##
IsAbsIrrLieModule := function(M)
    local MM;
    if not IsBound( M.absirr ) then 
        MM := GModuleByMats( M.mats*One(M.field), M.field );
        M.absirr := SMTX.IsAbsolutelyIrreducible(MM);
    fi;
    return M.absirr;
end;

#############################################################################
##
#F EvaluateLieModule := function(M, char, vals)
##
EvaluateLieModule := function(M, char, vals)
    local V, i, j, k, m;
    V := rec( basis := M.basis, dim := M.dim, field := M.field );
    V.mats := List( M.mats, x -> MutableCopyMat( 0 * x ) );
    for i in [1..Length(M.mats)] do
        m := M.mats[i];
        for j in [1..M.dim] do
            for k in [1..M.dim] do
                if IsFFE( m[j][k] ) then 
                    V.mats[i][j][k] := m[j][k]; 
                else
                    V.mats[i][j][k] := Value( m[j][k], char, vals ); 
                fi;
            od;
        od;
    od;
    return V;
end;

#############################################################################
##
#F EvalAndChopLieModules( M, vars )
##
EvalAndChopLieModules := function( M, vars )
    local p, l, c, i, ev, Mi, ci, si, j;
    p := Characteristic( M.field );
    l := List( vars, x -> p );
    c := [];
    for i in [0..p^Length(vars)-1] do
        Info(InfoLieMod, 2, "  starting ",i,"th characters");
        ev := CoefficientsMultiadic( l, i ) * One(M.field);
        Mi := EvaluateLieModule( M, vars, ev );
        ci := ChopLieModule( Mi );
        Append( c, ci );
    od;
    return c;
end;

#############################################################################
##
#F Display
##
DisplayLieModule := function(M)
    local m;
    Print("\n");
    Print("basis of Lie algebra: ",BasisVectors(M.basis), "\n");
    if IsBound(M.absirr) then 
        Print("absolute irreducible: ", M.absirr, "\n");
    fi;
    for m in M.mats do Print("\n"); Display(m); od;
end;
  
