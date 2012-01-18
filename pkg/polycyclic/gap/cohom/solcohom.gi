#############################################################################
##
#W  solcohom.gi                  Polycyc                         Bettina Eick
##

#############################################################################
##
#F CRSystem( d, l, c )
##
CRSystem := function( d, l, c )
    local null, zero;
    null := List( [1..d*l], x -> 0 );
    if c <> 0 then null := null * One(GF(c)); fi;
    zero := List( [1..d], x -> 0 );
    if c <> 0 then zero := zero * One(GF(c)); fi;
    return rec( null := null, zero := zero, dim := d, len := l, base := [] );
end;

#############################################################################
##
#F AddToCRSystem( sys, mat )
##
AddToCRSystem := function( sys, mat )
    local v;
    for v in mat do
        if IsBound( sys.full ) and sys.full then 
            Add( sys.base, v );
        elif not v = sys.null and not v in sys.base then
            Add( sys.base, v );
        fi;
    od;
end;

#############################################################################
##
#F SubtractTailVectors( t1, t2 )
##
SubtractTailVectors := function( t1, t2 )
    local i;
    for i  in [ 1 .. Length(t2) ]  do
        if IsBound(t2[i])  then
            if IsBound(t1[i])  then
                t1[i] := t1[i] - t2[i];
            else
                t1[i] := - t2[i];
            fi;
        fi;
    od;
end;

#############################################################################
##
#F IsZeroTail( t )
##
IsZeroTail := function( t )
    local i;
    for i  in [ 1 .. Length(t) ]  do
        if IsBound(t[i]) and t[i] <> 0 * t[i] then
            return false;
        fi;
    od;
    return true;
end;

#############################################################################
##
#F AddEquationsCR( sys, t1, t2, flag )
##
AddEquationsCRNorm := function( sys, t, flag  )
    local i, j, v, mat;

    # create a matrix
    mat := [];
    for j in [1..sys.dim] do
        v := [];
        for i in [1..sys.len] do
            if IsBound( t[i] ) then
                Append( v, t[i]{[1..sys.dim]}[j] );
            else
                Append( v, sys.zero );
            fi;
        od;
        Add( mat, v );
    od;

    # finally add it
    if flag then
        AddToCRSystem( sys, mat );
    else
        Append( sys.base, mat );
    fi;
end;

AddEquationsCREndo := function( sys, t )
    local i, l;
    for i in [1..Length(sys)] do
        l := List(t, x -> x[i]);
        AddEquationsCRNorm( sys[i], l, true );
    od;
end;
    
AddEquationsCR := function( sys, t1, t2, flag  )
    local t;

    # the trivial case
    if t1 = t2 and flag then return; fi;

    # subtract t1 - t2 into t
    t := ShallowCopy(t1);
    SubtractTailVectors( t, t2 );

    # check case
    if IsList(sys) then 
        AddEquationsCREndo( sys, t );
    else 
        AddEquationsCRNorm( sys, t, flag );
    fi;
end;
     
#############################################################################
##
## Some small helpers
##
MatPerm := function( d, e )
    local k, t, l, i, f, n, r;
    if d = 1 then return (); fi;
    k := Length(e);
    t := Set(SeriesSteps(e)); Add(t, k);
    l := [];
    for i in [1..Length(t)-1] do
        f := t[i]+1;
        n := t[i+1];
        r := List([1..d], x -> (x-1)*k+[f..n]);
        Append(l, Concatenation(r));
    od;
    return PermListList([1..d*k], l)^-1;
end;

PermuteMat := function( M, rho, sig )
    local N, i, j;
    N := MutableCopyMat(M);
    for i in [1..Length(M)] do
        for j in [1..Length(M[1])] do
            N[i][j] := M[i^sig][j^rho];
        od;
    od;
    return N;
end;

PermuteVec := function( v, rho )
    return List([1..Length(v)], i -> v[i^rho]); 
end;

#############################################################################
##
## ImageCR( A, sys )
##
## returns a basis of the image of sys. Additionally, it returns the 
## transformation from the given generating set and the nullspace of the
## given generating set.
##
ImageCRNorm := function( A, sys )
    local mat, new, tmp;

    mat := sys.base;

    # if mat is empty
    if mat = 0 * mat then
        tmp := rec( basis := [],
                    transformation := [],
                    relations := A.one );

    # if mat is integer
    elif A.char = 0 then
        tmp := LLLReducedBasis( mat, "linearcomb" );

    # if mat is ffe
    elif A.char > 0 then
       new := SemiEchelonMatTransformation( mat );
       tmp := rec( basis := new.vectors,
                   transformation := new.coeffs,
                   relations := ShallowCopy(new.relations) );
       TriangulizeMat(tmp.relations);
    fi;

    # return 
    return rec( basis := tmp.basis, 
                transf := tmp.transformation, 
                fixpts := tmp.relations );
end;

ImageCREndo := function( A, sys )
    local i, mat, K, e, p, n, m, rho, sig;
    K := [];
    for i in [1..Length(sys)] do
        mat := sys[i].base;
        p := A.endosys[i][1];
        e := A.mats[1][i]!.exp;
        n := Length(mat)/Length(e);
        m := Length(mat[1])/Length(e);
        rho := MatPerm(m, e)^-1; 
        sig := MatPerm(n, e)^-1;
        mat := PermuteMat( mat, rho, sig );
        K[i] := KernelSystemGauss( mat, e, p );
        K[i] := ImageSystemGauss( mat, K[i], e, p );
        K[i] := List(K[i], x -> PermuteVec( x, rho^-1));
    od;
    return K;
end;

ImageCR := function( A, sys )
    if IsList(sys) then 
        return ImageCREndo( A, sys );
    else
        return ImageCRNorm( A, sys );
    fi;
end;

#############################################################################
##
## KernelCR( A, sys )
##
## returns the kernel of the system
##
KernelCRNorm := function( A, sys )
    local mat, null;

    if sys.len = 0 then return []; fi;

    # we want the kernel of the transposed
    mat := TransposedMat( sys.base );

    # the nullspace
    if Length( mat ) = 0 then
        null := IdentityMat( sys.dim * sys.len ); 
        if A.char > 0 then null := null * One( A.field ); fi;
    elif A.char > 0 then 
        null := TriangulizedNullspaceMat( mat );
    else
        null := PcpNullspaceIntMat( mat );
        null := TriangulizedIntegerMat( null );
    fi;

    return null;
end;


KernelCREndo := function( A, sys )
    local i, mat, K, e, p, n, m, rho, sig;
    K := [];
    for i in [1..Length(sys)] do
        mat := TransposedMat( sys[i].base );
        p := A.endosys[i][1];
        e := A.mats[1][i]!.exp;
        n := Length(mat)/Length(e);
        m := Length(mat[1])/Length(e);
        rho := MatPerm(m, e); 
        sig := MatPerm(n, e);
        mat := PermuteMat( mat, rho, sig );
        K[i] := KernelSystemGauss( mat, e, p );
        K[i] := List(K[i], x -> PermuteVec( x, rho^-1));
    od;
    return K;
end;

KernelCR := function( A, sys )
    if IsList(sys) then 
        return KernelCREndo( A, sys );
    else
        return KernelCRNorm( A, sys );
    fi;
end;

#############################################################################
##
## SpecialSolutionCR( A, sys )
##
## returns a special solution of the system corresponding to A.extension
##
SpecialSolutionCR := function( A, sys )
    local mat, sol, vec;

    if sys.len = 0 then return []; fi;

    if Length( sys.base ) = 0 or not IsBound( A.extension ) then
        sol := List( [1..sys.dim * sys.len], x -> 0 );
        if A.char > 0 then sol := sol * One( A.field ); fi;
    else
		mat := TransposedMat( sys.base );
        vec := Concatenation( A.extension );
        if A.char > 0 then
            sol := SolutionMat( mat, vec );
        else
            sol := PcpSolutionIntMat( mat, vec );
        fi;
    fi;

    # return with special solution
    return sol;
end;


