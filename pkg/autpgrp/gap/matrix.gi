#############################################################################
##
#W  matrix.gi               AutPGrp package                      Bettina Eick
##
#H  @(#)$Id: matrix.gi,v 1.3 2003/08/18 12:10:28 gap Exp $
##
Revision.("autpgrp/gap/matrix_gi") :=
    "@(#)$Id: matrix.gi,v 1.3 2003/08/18 12:10:28 gap Exp $";

#############################################################################
##
#F ChainByCollection( bases, full )
##
ChainByCollection := function( bases, full )
    local chain, base, tmp, i, V, W, int;

    chain := [ full, [] ];
    for base in bases do
        tmp := [];
        for i in [2..Length(chain)] do
            V := chain[i-1];
            W := chain[i];
            if Length( V ) > Length( W ) + 1 then
                int := SumIntersectionMat( base, V )[2];
                int := SumIntersectionMat( int, W )[1];
                if Length( int ) < Length( V ) and
                   Length( int ) > Length( W ) then
                    AddSet( tmp, int );
                fi;
            fi;
        od;
        Append( chain, tmp );
        Sort( chain, function( x, y ) return Length(x)>Length(y); end );
    od;
    return chain;
end;


#############################################################################
##
#F StabilizingMatrixGroup( list of bases ) . . . . . compute stabilizer in GL
##
StabilizingMatrixGroup := function( bases, d, p  )
    local full, chain, mats, l, size, i, j, n, mat, G, rel, field;

    # general set up
    full  := IdentityMat( d, GF(p) );
    chain := ChainByCollection( bases, full );
    field := GF(p);

    # loop over chain
    mats  := [];
    l     := 0;
    size  := 1;
    for i in [2..Length(chain)] do
        n := Length( chain[i-1] ) - Length( chain[i] );
        for j in [1..n] do
            size := size * (p^(d-l) - p^(d-l-j));
        od;
        
        # Construct the generators.
        if p = 2 then
            if n >= 2 then
                mat := MutableIdentityMat(d, field);
                mat[l+1][l+n] := One( field );
                mat[l+1][l+1] := Zero( field );
                for j in [ 2 .. n ] do 
                    mat[l+j][l+j-1] := One( field );
                    mat[l+j][l+j]   := Zero( field );
                od;
                Add( mats, mat );
 
                mat := MutableIdentityMat(d, field);
                mat[l+1][l+2] := One( field );
                Add( mats, mat );
            fi;
        else
            mat := MutableIdentityMat(d, field);
            mat[l+1][l+1] := PrimitiveRoot( field );
            Add( mats, mat );

            if n >= 2 then
                mat := MutableIdentityMat(d, field);
                mat[l+1][l+1] := -One( field );
                mat[l+1][l+n] := One( field );
                for j in [ 2 .. n ] do 
                    mat[l+j][l+j-1] := -One( field );
                    mat[l+j][l+j]   := Zero( field );
                od;
                Add( mats, mat );
            fi;
        fi;
        l := l + n;
        if l < d then
            mat := MutableIdentityMat(d, field);
            mat[l][l+1] := One( field );
            Add( mats, mat );
        fi;
    od;

    # change basis of mats
    rel  := List( [2..Length(chain)], i -> 
                  BaseSteinitzVectors( chain[i-1], chain[i] ).factorspace );
    rel  := Concatenation( rel );
    mats := List( mats, x -> rel^-1 * x * rel );
    
    G := Group( mats, IdentityMat( d, field ) );
    SetSize( G, size );

    return G;
end;


