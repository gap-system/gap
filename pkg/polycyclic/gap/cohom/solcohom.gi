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
AddEquationsCR := function( sys, t1, t2, flag  )
    local t, i, j, v, mat;

    # the trivial case
    if t1 = t2 and flag then return; fi;

    # subtract t1 - t2 into t
    t := ShallowCopy(t1);
    SubtractTailVectors( t, t2 );

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
    
#############################################################################
##
## ImageCR( A, sys )
##
## returns a basis of the image of sys. Additionally, it returns the 
## transformation from the given generating set and the nullspace of the
## given generating set.
##
ImageCR := function( A, sys )
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

#############################################################################
##
## KernelCR( A, sys )
##
## returns the kernel of the system
##
KernelCR := function( A, sys )
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


