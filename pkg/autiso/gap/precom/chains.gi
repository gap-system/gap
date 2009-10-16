BasisBySubspaces := function( bases, F, d )
    local V, C, B, new, i, c, basis, weigh;

    # initialize
    V := IdentityMat(d,F);
    C := [ V, [] ];

    # create a chain
    for B in bases do
        new := [];
        for i in [2..Length(C)] do
            if Length( C[i-1] ) > Length( C[i] ) + 1 then
                c := SumIntersectionMat( B, C[i-1] )[2];
                c := SumIntersectionMat( c, C[i] )[1];
                if Length( c ) < Length( C[i-1] ) and
                   Length( c ) > Length( C[i] ) then
                    Add( new, c );
                fi;
            fi;
        od;
        Append( C, new );
        Sort( C, function( x, y ) return Length(x)>Length(y); end );
    od;

    # determine a basis
    basis := [];
    weigh := [];
    for i in [1..Length(C)-1] do
        new := BaseSteinitzVectors(C[i], C[i+1]).factorspace;
        Append( basis, new );
        Append( weigh, List( new, x -> i ) );
    od;

    # that' it
    return rec( basis := basis, weights := weigh );
end;

ChainStabilizer := function( wgt, F )
    local d, l, p, mats, size, i, j, n, mat, G;

    # set up
    d := Length( wgt );
    l := 0;
    p := Size(F);

    # init gens and size
    mats := [];
    size  := 1;

    # loop over weights
    for i in [1..wgt[d]] do
        n := Length(Filtered(wgt, x -> x=i)); 

        # adjust size
        for j in [1..n] do
            size := size * (p^(d-l) - p^(d-l-j));
        od;

        # construct gens on diag
        if p = 2 then
            if n >= 2 then
                mat := MutableIdentityMat(d, F);
                mat[l+1][l+n] := One( F );
                mat[l+1][l+1] := Zero( F );
                for j in [ 2 .. n ] do
                    mat[l+j][l+j-1] := One( F );
                    mat[l+j][l+j]   := Zero( F );
                od;
                Add( mats, mat );

                mat := MutableIdentityMat(d, F);
                mat[l+1][l+2] := One( F );
                Add( mats, mat );
            fi;
        else
            mat := MutableIdentityMat(d, F);
            mat[l+1][l+1] := PrimitiveRoot( F );
            Add( mats, mat );

            if n >= 2 then
                mat := MutableIdentityMat(d, F);
                mat[l+1][l+1] := -One( F );
                mat[l+1][l+n] := One( F );
                for j in [ 2 .. n ] do
                    mat[l+j][l+j-1] := -One( F );
                    mat[l+j][l+j]   := Zero( F );
                od;
                Add( mats, mat );
            fi;
        fi;

        # adjust parameter
        l := l + n;

        # add gens off diag
        if l < d then
            mat := MutableIdentityMat(d, F);
            mat[l][l+1] := One( F );
            Add( mats, mat );
        fi;
    od;

    # return group
    G := Group( mats, IdentityMat(d,F) );
    SetSize(G, size );
    return G;
end;

