
#############################################################################
##
#F  FindNiceRowOneNorm
#F  FindNiceRowTwoNorm
#F  FindNiceRowInfinityNorm
##
##  Functions that select during an HNF computation a row from a matrix <M>
##  such that the row is minimal with respect to a chosen norm and can
##  function as pivot entry in position i,j.
##
#F  FindNiceRowInfinityNormRowOps
##
##  Does the same as FindNiceRowInfinityNorm() but records the row
##  operations. 
##
FindNiceRowOneNorm := function( M, i, j )
    local   m,  n,  k,  a,  r;

    m := Length( M ); n := Length( M[1] );

    for k in [i+1..m] do
        a := AbsInt( M[k][j] );
        if a <> 0 and 
           (a < AbsInt( M[i][j] )
            or (a = AbsInt( M[i][j] ) 
                and Sum( M[k], AbsInt ) < Sum( M[i], AbsInt ) ) ) then

            r := M[i]; M[i] := M[k]; M[k] := r;
        fi;
    od;
    return;
end;

FindNiceRowTwoNorm := function( M, i, j )
    local   m,  n,  k,  a,  r;

    m := Length( M ); n := Length( M[1] );

    for k in [i+1..m] do
        a := AbsInt( M[k][j] );
        if a <> 0 and 
           (a < AbsInt( M[i][j] )
            or (a = AbsInt( M[i][j] ) 
                and M[k]*M[k] < M[i]*M[i] ) ) then

            r := M[i]; M[i] := M[k]; M[k] := r;
        fi;
    od;
    return;
end;

FindNiceRowInfinityNorm := function( M, i, j )
    local   m,  n,  k,  a,  r;

    m := Length( M ); n := Length( M[1] );

    for k in [i+1..m] do
        a := AbsInt( M[k][j] );
        if a <> 0 and 
           (a < AbsInt( M[i][j] )
            or (a = AbsInt( M[i][j] ) 
                and Number( M[k], x->x<>0 ) < Number( M[i], x->x<>0 ) ) ) then

            r := M[i]; M[i] := M[k]; M[k] := r;
        fi;
    od;
    return;
end;

FindNiceRowInfinityNormRowOps := function( M, Q, i, j )
    local   m,  n,  k,  a,  r;

    m := Length( M ); n := Length( M[1] );

    for k in [i+1..m] do
        a := AbsInt( M[k][j] );
        if a <> 0 and 
           (a < AbsInt( M[i][j] )
            or (a = AbsInt( M[i][j] ) 
                and Number( M[k], x->x<>0 ) < Number( M[i], x->x<>0 ) ) ) then 

            r := M[i]; M[i] := M[k]; M[k] := r;
            r := Q[i]; Q[i] := Q[k]; Q[k] := r;
        fi;
    od;
    return;
end;

#############################################################################
##
#F  HNFIntMat . . . . . . . . . . . . Hermite Normalform of an integer matrix
##
HNFIntMat := function( M )

    local   MM,  m,  n,  i,  j,  k,  r,  Cleared,  a;

    if M = [] then return []; fi;

    MM := M;
    M := List( M, ShallowCopy );
    m := Length( M ); n := Length( M[1] );

    i := 1; j := 1;
    while i <= m and j <= n do

        # find first k with M[k][j] non-zero
        k := i; while k <= m and M[k][j] = 0 do k := k+1; od;

        if k <= m then

            # swap rows 
            r := M[i]; M[i] := M[k]; M[k] := r;

            # find nicest row with M[k][j] non-zero
            FindNiceRowInfinityNorm( M, i, j );

            if M[i][j] < 0 then M[i] := -1 * M[i]; fi;
            
            # reduce all other entries in this columns with the pivot entry
            Cleared := true;
            for k in [i+1..m] do
                a := QuoInt(M[k][j],M[i][j]);
                if a <> 0 then  
                    AddRowVector( M[k], M[i], -a, i, n ); 
                fi;
                if M[k][j] <> 0 then Cleared := false; fi;
            od;

            # if all entries below the pivot are zero, reduce above the
            # pivot and then move on along the diagonal 
            if Cleared then 
                for k in [1..i-1] do
                    a := QuoInt(M[k][j],M[i][j]);

                    if M[k][j] < 0 and M[k][j] mod M[i][j] <> 0 then 
                        a := a-1;
                    fi;

                    if a <> 0 then  
                        AddRowVector( M[k], M[i], -a, 1, n ); 
                    fi;
                od;
                i := i+1; j := j+1; 
            fi;
        else

            # increase column counter if column has only zeroes
            j := j+1;
        fi;

    od;
    return M{[1..i-1]};
end;

#############################################################################
##
#F  HNFIntMat . . . . . . . . . . . . Hermite Normal Form plus row operations
##
HNFIntMatRowOps := function( M )

    local   MM,  m,  n,  Q,  i,  j,  k,  r,  Cleared,  a;

    if M = [] then return []; fi;

    MM := M;
    M := List( M, ShallowCopy );
    m := Length( M ); n := Length( M[1] );

    Q := IdentityMat( Length(M) );

    i := 1; j := 1;
    while i <= m and j <= n do

        # find first k with M[k][j] non-zero
        k := i; while k <= m and M[k][j] = 0 do k := k+1; od;

        if k <= m then

            # swap rows 
            r := M[i]; M[i] := M[k]; M[k] := r;
            r := Q[i]; Q[i] := Q[k]; Q[k] := r;
            

            # find nicest row with M[k][j] non-zero
            FindNiceRowInfinityNormRowOps( M, Q, i, j );

            if M[i][j] < 0 then M[i] := -1 * M[i]; Q[i] := -1 * Q[i]; fi;
            
            # reduce all other entries in this columns with the pivot entry
            Cleared := true;
            for k in [i+1..m] do
                a := QuoInt(M[k][j],M[i][j]);
                if a <> 0 then  
                    AddRowVector( M[k], M[i], -a, i, n ); 
                    AddRowVector( Q[k], Q[i], -a, 1, m ); 

                fi;
                if M[k][j] <> 0 then Cleared := false; fi;
            od;

            # if all entries below the pivot are zero, reduce above the
            # pivot and then move on along the diagonal 
            if Cleared then 
                for k in [1..i-1] do
                    a := QuoInt(M[k][j],M[i][j]);

                    if M[k][j] < 0 and M[k][j] mod M[i][j] <> 0 then 
                        a := a-1;
                    fi;

                    if a <> 0 then  
                        AddRowVector( M[k], M[i], -a, 1, n ); 
                        AddRowVector( Q[k], Q[i], -a, 1, m ); 
                    fi;
                od;
                i := i+1; j := j+1; 
            fi;
        else

            # increase column counter if column has only zeroes
            j := j+1;
        fi;

    od;

    return [ M, Q ];
end;

#############################################################################
##
#F  DiagonalFormIntMat . . . . diagonal form of an integer matrix plus column
#F                             operations 
##
DiagonalFormIntMat := function( M )
    local   Q,  pair;

    M := HNFIntMat( M );
    Q := IdentityMat( Length(M[1]) );

    while not IsDiagonalMat( M ) do
        M := TransposedMat( M );
        pair := HNFIntMatRowOps( M );
        Q := Q * TransposedMat( pair[2] );
        M := TransposedMat( pair[1] );

        if not IsDiagonalMat( M ) then
            M := HNFIntMat( M );
        fi;
    od;    

    return [ M, Q ];
end;


##
##  This function takes a matrix M in HNF and eliminates for each row whose
##  leading entry is 1 the remaining entries of the row.  This corresponds
##  to a sequence of column operations.  Note that all entries above and
##  below the 1 are 0 since the matrix is in HNF.  
##
##  The function returns the transformed matrix M' together with the
##  transforming matrix Q such that 
##                         M * Q = M'
##
ClearOutWithOnes := function( M )
    local   Q,  i,  k,  j,  l;

    M := List( M, ShallowCopy );
    Q := IdentityMat( Length(M[1]) );
    for i in [1..Length(M)] do
        k := First( [1..Length(M[i])], e -> M[i][e] <> 0 );
        if M[i][k] = 1 then
            for j in [k+1..Length(M[i])] do
                if M[i][j] <> 0 then

                    Q[j] := Q[j] - M[i][j] * Q[k];
                    M[i][j] := 0;
                fi;
            od;
        fi;
    od;

    return [M, TransposedMat(Q)];
end;

##
##  After we have cleared out those rows of the HNF whose leading entry is 1,
##  we need to compute a diagonal form of the rest of the matrix.  This
##  routines cuts out the relevant part, computes a diagonal form of it, puts
##  that back into the matrix and returns the performed columns operations.
##
CutOutNonOnes := function( M )
    local   rows,  cols,  nf,  Q,  i;

    # Find all rows whose leading entry is 1
    rows := Filtered( [1..Length(M)], i->First( M[i], e->e <> 0 ) = 1 );

    if rows = [1..Length(M)] then
        return IdentityMat( Length(M[1]) );
    fi;

    # Find those colums where the leading entry is
    cols := List( rows, i->Position( M[i], 1 ) );

    # The complement are those rows whose leading entry is not one and those
    # colums that do not have a 1 in a leading position.
    rows := Difference( [1..Length(M)], rows );
    cols := Difference( [1..Length(M[1])], cols );

    # skip leading zeroes
    i := 1; while M[rows[1]][cols[i]] = 0 do i := i+1; od;
    cols := cols{[i..Length(cols)]};

    nf := DiagonalFormIntMat( M{rows}{cols} );

    Q := IdentityMat( Length(M[1]) );
    for i in cols do Q[i][i] := 0; od;
    Q{cols}{cols} := nf[2];

    M{rows}{cols} := nf[1];

    return Q;
end;


##
##    The HNF of a matrix that comes out of the consistency test for a
##    central extension tends to have a lot of rows whose leading entry is 1.
##    In particular, if we do not have an efficient strategy for computing
##    tails, we have many generators which can be expressed by others.  
##
##    This is a simple consequence of the fact that we add about n^2/2 new
##    generators to the polycyclic presentation if the the group has n
##    generators.  But it is clear that the rank of R/[R,F] is bounded from
##    above by n.  Therefore, about n^2/2 generators will be expressed by
##    others.
##
##    We return a diagonal form of M and the matrix of column operations in
##    the same format as NormalFormIntMat()
##
NormalFormConsistencyRelations := function( M )
    local   nf,  Q,  rows,  cols,  small,  nfim,  QQ;

    M := HNFIntMat( M );

    nf := ClearOutWithOnes( M );

    M := nf[1];
    Q := nf[2];

    Q := Q * CutOutNonOnes( M );

    return rec( normal := M, coltrans := Q );
end;



DisplayMat := function( M )
    local   i,  j;

    for i in [1..Length(M)] do
        for j in [1..Length(M[1])] do
            if M[i][j] = 0 then
                Print( "." );
            else
                Print( " ", M[i][j] );
            fi;
        od;
        Print( "\n" );
    od;
end;

