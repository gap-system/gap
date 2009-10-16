#############################################################################
##
#W  checksys.gi                  ipcq package                     Bettina Eick
##

#############################################################################
##
#F CheckZme( Q, M, N ) . . . . . . . . . . check that N is a matrix rep for M
##
## Q is a quotient system and M is a module presentation for Q.
##
CheckZme := function( Q, M, N )
    local i, new, j, t, s, exp, tmp;

    if IsBound( N.istri ) and N.istri then return true; fi;
        
    # check that tails fullfil relations in M
    for i in [1..M.cols] do
        new := N.tails[1] * 0;
        for j in [1..Length(M.tails)] do
            t := M.tails[j][i];
            for s in t do
                exp := Exponents( s[2] );
                tmp := MappedVector( exp, N.opers );
                new := new + s[1] * N.tails[j] * tmp;
            od;
        od; 
        if IsBool( SolutionIntMat( N.order, new ) ) then
            Print("inconsistency at tail ", i, "\n");
            return false;
        fi;
    od;

    # check that mats yield a homomorphism
    return true;
end;

#############################################################################
##
#F SubsZme( Q, M, mats ) 
##
SubsZme := function( Q, M, mats )
    local dim, mat, i, j, t, new, s, exp, tmp, k, l;

    dim := Length(mats[1]);
    mat := MutableNullMat( dim*M.rows, dim*M.cols );
    for i in [1..M.rows] do
        for j in [1..M.cols] do
            t := M.tails[i][j];
            new := MutableNullMat(dim,dim);
            for s in t do
                exp := Exponents( s[2] );
                tmp := MappedVector( exp, mats );
                new := new + s[1] * tmp;
            od;
            for k in [1..dim] do
                for l in [1..dim] do
                    mat[dim*(i-1)+k][dim*(j-1)+l] := new[k][l];
                od;
            od;
        od;
    od;
    return mat;
end;

#############################################################################
##
#F CheckQSystem( Q )
##
CheckQSystem := function( Q )
    local j, r, g, i, U;
    for j in [1..Length(Q.fprels)] do
        r := Q.fprels[j];
        g := Q.pcone;
        for i in [1,3..Length(r)-1] do
            g := g * Q.imgs[r[i]]^r[i+1];
        od;
        if g <> Q.pcone then
            Print("relation ",j," not fullfilled \n");
            return false;
        fi;
    od;
    U := Subgroup( Q.pcgroup, Q.imgs );
    if Index( Q.pcgroup, U ) > 1 then
        Print("mapping is not surjective \n");
        return false;
    fi;
    return true;
end;

