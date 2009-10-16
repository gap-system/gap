#############################################################################
##
#W  lattices.gi                 Polycyclic                       Bettina Eick
##
##  Methods to compute with integral lattices.
##

#############################################################################
##
#F  InducedByField( mats, f )
##
InducedByField := function( mats, f )
    local i;
    mats := ShallowCopy( mats );
    for i in [1..Length(mats)] do
        mats[i] := Immutable( mats[i] * One(f) );
        ConvertToMatrixRep( mats[i], f );
    od;
    return mats;
end;

#############################################################################
##
#F  PcpNullspaceIntMat( arg )
##
InstallGlobalFunction( PcpNullspaceIntMat, function( arg )
    local A, d, hnfm, rels, j;

    A := arg[1];
    if Length( arg ) = 2 then d := arg[2]; fi;

    # catch a trivial case
    if Length(A) = 0 and Length( arg ) = 2 then return IdentityMat(d); fi;
    if Length(A) = 0 and Length( arg ) = 1 then Error("trivial matrix"); fi;

    # compute hnf
    hnfm := NormalFormIntMat( A, 4 );
    rels := hnfm.rowtrans;
    hnfm := hnfm.normal;

    # get relations
    j := Position( hnfm, 0 * hnfm[1] );
    if IsBool( j ) then return []; fi;
    return NormalFormIntMat( rels{[j..Length(rels)]}, 0 ).normal;
end );

InstallGlobalFunction( NullspaceRatMat, function( arg )
    local A, d, hnfm, rels, j;

    A := arg[1];
    if Length( arg ) = 2 then d := arg[2]; fi;

    # catch a trivial case
    if Length(A) = 0 and Length( arg ) = 2 then return IdentityMat(d); fi;
    if Length(A) = 0 and Length( arg ) = 1 then Error("trivial matrix"); fi;

    # compute nullspace
    return TriangulizedNullspaceMat( A );
end );

#############################################################################
##
#F  NullspaceMatMod( mat, rels )
##
NullspaceMatMod := function( mat, rels )
    local l, idm, i, null;

    # set up
    l := Length( mat );
    
    # append relative orders
    mat := ShallowCopy( mat );
    idm := IdentityMat( Length(rels) );
    for i in [1..Length(rels)] do
        Add( mat, rels[i] * idm[i] );
    od;

    # solve
    null := PcpNullspaceIntMat( mat, l );
    if Length( null ) = 0 then return null; fi;

    # cut out the solutions
    for i in [1..Length(null)] do
        null[i] := null[i]{[1..l]};
        if null[i] = 0 * null[i] then null[i] := false; fi;
    od;
    return Filtered( null, x -> not IsBool(x) );
end;

#############################################################################
##
#F  PcpBaseIntMat( mat )
##
PcpBaseIntMat := function( A )
    local hnfm, zero, j;
    hnfm := NormalFormIntMat( A, 0 ).normal;
    zero := hnfm[1] * 0;
    j := Position( hnfm, zero );
    if not IsBool( j ) then hnfm := hnfm{[1..j-1]}; fi;
    return hnfm;
end;

#############################################################################
##
#F  FreeGensAndKernel( mat )
##
FreeGensAndKernel := function( mat )
    local norm, j;
    norm := NormalFormIntMat( mat, 6 );
    j := Position( norm.normal, 0 * mat[1] );
    if IsBool( j ) then j := Length(norm.normal)+1; fi;
    return rec( free := norm.normal{[1..j-1]},
                trsf := norm.rowtrans{[1..j-1]},
                kern := norm.rowtrans{[j..Length(norm.rowtrans)]} );
end;

#############################################################################
##
#F  PcpSolutionIntMat( A, s )
##
InstallGlobalFunction( PcpSolutionIntMat, function( A, s )
    local B, N, H;
    B := Concatenation( [s], A );
    N := PcpNullspaceIntMat( B );
    if Length(N) = 0 then return fail; fi;
    H := NormalFormIntMat( N, 2 ).normal;
    if H[1][1] = 1 then
        return -H[1]{[2..Length(H[1])]};
    else
        return fail;
    fi;
end );

#############################################################################
##
#F LatticeIntersection( base1, base2 )  
##
InstallGlobalFunction( LatticeIntersection, function( base1, base2 )
    local n, l, m, id, zr, A, i, H, I, h;

    # set up and catch the trivial cases
    if Length( base1 ) = 0 or Length( base2 ) = 0 then return []; fi;
    n  := Length( base1[1] );
    l  := Length( base1 );
    m  := Length( base2 );
    id := IdentityMat( n );
    if base1 = id then return base2; fi;
    if base2 = id then return base1; fi;
    zr := List( [1..n], x -> 0 );

    # determine matrix
    A := List( [1..l+m], x -> [] );
    for i in [1..l] do
        A[i] := Concatenation( base1[i], base1[i] );
    od;
    for i in [1..m] do
        A[l+i] := Concatenation( base2[i], zr );
    od;

    # compute normal form
    H := NormalFormIntMat( A, 0 ).normal;

    # read off intersection
    I := [];
    for h in H do
        if h{[1..n]} = zr then
            Add( I, h{[n+1..2*n]} );
        fi;
    od;
    return I;
end );

#############################################################################
##
#F VectorModLattice( vec, base )
##
VectorModLattice := function( vec, base )
    local i, q;
    vec := ShallowCopy(vec);
    for i in [1..Length(vec)] do
        if vec[i] <> 0 then 
            q := QuotientRemainder( vec[i], base[i][i] );
            if q[2] < 0 then q[1] := q[1] - 1; fi;
            AddRowVector( vec, base[i], -q[1] );
            if vec[i] < 0 or vec[i] >= base[i][i] then 
                Error("bloody quotient");
            fi;
        fi;
    od;
    return vec;
end;

#############################################################################
##
#F  PurifyRationalBase( base ) . . . . . . . . . . . . .this is too expensive
##
PurifyRationalBase := function( base )
    local i, dual;

    if Length(base) = 0 then return base; fi;
    if Length(base) = Length(base[1]) then
        return IdentityMat( Length(base[1]) );
    fi;

    base := ShallowCopy( base );
    for i in [1..Length(base)] do
        base[i] := Lcm( List( base[i], DenominatorRat ) ) * base[i];
        base[i] := base[i] / Gcd( base[i] );
    od;
    for i in [Length(base)+1..Length(base[1])] do Add( base, 0*base[1] ); od;

    base := PcpNullspaceIntMat( TransposedMat( base ) );
    for i in [Length(base)+1..Length(base[1])] do Add( base, 0*base[1] ); od;
    base := PcpNullspaceIntMat( TransposedMat( base ) );
    return NormalFormIntMat(base, 2).normal;
end;
