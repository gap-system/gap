#############################################################################
##
#W  triangle.gi                 Polycyclic                      Werner Nickel
##

#############################################################################
##
#F  PreImageSubspaceIntMat( <matrix>, <subspace> )
##
##  Find all v such that v * <matrix> in <subspace>.
##
PreImageSubspaceIntMat := function( M, D )
    local   nsp,  d;

    ##                        [ M ]
    ##  Find the nullspace of [ D ]
    nsp := PcpNullspaceIntMat( Concatenation( M, D ) );

    ##  Cut off the relevant bit.
    return List( nsp, v->v{[1..Length(M)]} );
end;

#############################################################################
##
#F  PreImageSubspaceIntMats( <matlist>, <subspace> )
##
##  Find all v such that v * M in <subspace> for all matrices M in
##  <matlist>.   
##
PreImageSubspaceIntMats := function( mats, D )
    local   E,  M,  N;

    if Length(mats[1]) <> Length(mats[1][1]) then
        Error( "square matrices expected" );
    fi;
    
    E := mats[1]^0;
    for M in mats do
        N := PreImageSubspaceIntMat( E * M, D );
	if N = [] then break; fi;
        E := N * E;
        #if E = [] then break; fi;
    od;

    return E;
end;


#############################################################################
##
#F  DiagonalBlockMat( <mats> )
##
##  Construct a matrix with the matrices in <mats> along the diagonal.
##
DiagonalBlockMat := function( mats )
    local   n,  M,  m,  d;

    n := Sum( mats, m->Length(mats[1]) );
    M := NullMat( n, n );

    n := 0;
    for m in mats do
        d := Length(m);
        M{[1..d] + n}{[1..d] + n} := m;
        n := n + d;
    od;

    return M;
end;

Example := function( k, mats )
    local   l,  d,  perm,  example,  i,  ex,  j,  jj,  T;

    l := Length( mats );
    d := Length( mats[1] );
    perm := [2..l]; perm[l] := 1; perm := PermList( perm );

    example := [];
    for i in [1..k] do
        ex := DiagonalBlockMat( mats );
        mats := Permuted( mats, perm );
        for j in [0,d..(l-1)*d] do
            for jj in [0,d..j-d] do
                ex{ [1..d] + j }{ [1..d] + jj } := RandomMat( d,d,[-1..1] );
            od;
        od;
        Add( example, ex );
    od;

    repeat
        T := RandomUnimodularMat( l*d );
        until Maximum( Flat( T ) ) <= 12;

    return T * example * T^-1;
end;

#############################################################################
##
#F  RowsWithLeadingIndexHNF( <hnf> )
##
##  Given an integer matrix <hnf> in Hermite Normal Form, return a list that
##  indicates which row of the matrix has its leading entry in a given 
##  column.
##
RowsWithLeadingIndexHNF := function( hnf )
    local   indices,  i,  j;

    indices := [1..Length(hnf[1])] * 0;
    i := 1;
    for j in [1..Length(hnf)] do
        while i < Length(hnf[j]) and hnf[j][i] = 0 do 
            i := i+1; 
        od;
        if i > Length( hnf[j]) then 
            break; 
        fi;
        indices[i] := j;
    od;
    return indices;
end;

#############################################################################
##
#F  CoefficientsVectorHNF( <v>, <hnf> )
##
##  Decompose the integer vector <v> into the rows of the integer matrix
##  <hnf> given in Hermite Normal Form and return the respective
##  coefficients. 
##
CoefficientsVectorHNF := function( v, hnf )
    local   reduce,  coeffs,  i,  k,  c;
    
    reduce := RowsWithLeadingIndexHNF( hnf );
    coeffs := [1..Length(hnf)] * 0;
    for i in [1..Length(v)] do
        if v[i] <> 0 then
            k := reduce[i];
            if k = 0 or v[i] mod hnf[k][i] <> 0 then
                return fail;
            fi;
            c := v[i] / hnf[k][i];
            v := v - c * hnf[k];
            coeffs[k] := c;
        fi;
    od;

    return coeffs;
end;

    
#############################################################################
##
#F  CompletionToUnimodularMat( <matrix> )
##
##  Complete the integer matrix <matrix> to a unimodular matrix if possible 
##  and produces an error message otherwise.
##
CompletionToUnimodularMat := function( M )
    local   nf,  D,  i,  d,  n,  P,  compl;

    nf := NormalFormIntMat( M, 13 );

    ##
    ##   Check that there are only 1s on the diagonal.
    ##
    D := nf.normal;
    for i in [1..Length(D)] do
        if D[i][i] <> 1 then
            return Error( "\n\n\tSmith Normal Form contains diagonal",
                          "entries different from 1\n\n" );
        fi;
    od;

    d := Length( M );
    n := Length( M[1] );
    ##
    ##  Extend the left transforming matrix to the identity.
    ##
    P := List( nf.rowtrans, ShallowCopy );
    P{[1..d]}{[d+1..n]} := NullMat( d, n-d );
    P{[d+1..n]}         := IdentityMat( n ){[d+1..n]};

    compl := P^-1 * InverseIntMat( nf.coltrans );
    if compl{[1..d]} <> M then
        return Error( "\n\n\tCompletion to unimodular matrix failed\n\n" );
    fi;

    return compl{[d+1..n]};
end;


#############################################################################
##
#F  TriangularForm( <matrices> )
##
##  Transform the unimodular integer matrices <matrices> to lower
##  block-triangular form.  Each block corresponds to a common eigenvalue
##  (possibly in a suitable extension field) of the matrices.
##
TriangularForm := function( mats )
    local   d,  comms,  i,  j,  subs,  dims,  flag,  newflag,  T,  M,  
            C;

    d := Length( mats[1] );

#    Print( "Computing commutators\n" );
    comms := [];
    for i in [1..Length(mats)] do
        for j in [1..i-1] do
            Add( comms, mats[i]*mats[j] - mats[j]*mats[i] );
        od;
    od;

#    Print( "Computing flag: " );
    subs := [];
    dims := [];
    flag := [];
    while Length( flag ) < d do
        newflag := PreImageSubspaceIntMats( comms, flag );
        newflag := HermiteNormalFormIntegerMat( newflag );
        Add( subs, newflag );
        Add( dims, Length(newflag) - Length(flag) );
        flag := newflag;
    od;
#    Print( dims, "\n" );

#    Print( "Computing transforming matrix\n" );
    T := ShallowCopy( subs[1] );
    for i in [2..Length(subs)] do
        M := List( T, v->CoefficientsVectorHNF( v, subs[i] ) );
        C := CompletionToUnimodularMat( M );
        Append( T, C * subs[i] );
    od;

    return T * mats * T^-1;
end;

#############################################################################
##
#F  LowerUnitriangularForm( <matrices> )
##
##  Transform the unimodular integer matrices <matrices> to lower
##  unitriangular form, i.e. to lower triangular matrices with ones on the
##  diagonal. 
##
LowerUnitriangularForm := function( mats )
    local   d,  nilpmats,  i,  j,  subs,  dims,  flag,  newflag,  T,  M,  
            C,  I;

    d := Length( mats[1] );
    I := IdentityMat( d );

    ##  Subtract the identity, this makes each matrix nilpotent.
    nilpmats := List( mats, M->M - I );

    ##  Compute an ascending chain of subspaces with the property that
    ##  each space is mapped by the nilpotent matrices into the
    ##  previous one.
    subs := [];
    dims := [];
    flag := [];
    while Length( flag ) < d do
        newflag := PreImageSubspaceIntMats( nilpmats, flag );
        newflag := HermiteNormalFormIntegerMat( newflag );
        Add( subs, newflag );
        Add( dims, Length(newflag) - Length(flag) );
        flag := newflag;
    od;

    T := ShallowCopy( subs[1] );
    for i in [2..Length(subs)] do
	##  How does T embed into subs[i]
        C := List( T, v->CoefficientsVectorHNF( v, subs[i] ) );
	##  Now extend to a basis of subs[i], the coefficients are
        ##  with respect to the basis of subs[i]
        C := CompletionToUnimodularMat( C );
        ##  Add the additional basis vectors to T
        Append( T, C * subs[i] );
    od;

    return T * mats * T^-1;
end;

        
#############################################################################
##
#F  IsLowerUnitriangular( <mat> )
##
##  Test if the matrix <mat> is lower unitriangular.
##
IsLowerUnitriangular := function( M )

    return
        ForAll( M, v->Length(v) = Length(M) )      ##  Is M quadratic?
    and ForAll( [1..Length(M)], i->M[i][i] = 1 )   ##  Does M have ones
						   ##  on the diagonal?
    and IsLowerTriangularMat( M );                 ##  Is M lower triangular?
end;
