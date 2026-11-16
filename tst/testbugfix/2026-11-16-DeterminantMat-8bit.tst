# The kernel determinant for plain lists of 8-bit vectors over GF(q) took q
# as the row length. It refused square matrices of any other size, returned
# a determinant for non-square ones with rows of length q, and never checked
# the length of the first row, so a longer first row made it write past the
# end of the others.
gap> vecs := function( q, rows )
>   rows := rows * Z(q)^0;
>   List( rows, r -> ConvertToVectorRep( r, q ) );
>   return rows;
> end;;

# square, row length <> q
gap> DETERMINANT_LIST_VEC8BITS( vecs( 5, [ [0,1,0], [1,0,0], [0,0,2] ] ) );
Z(5)^3
gap> DETERMINANT_LIST_VEC8BITS( vecs( 4, [ [1,1], [0,1] ] ) );
Z(2)^0

# non-square, row length = q
gap> DeterminantMat( vecs( 4, [ [1,0,0,0], [0,1,0,0], [0,0,1,1] ] ) );
Error, DeterminantMat: <mat> must be a nonempty square matrix
gap> DeterminantMat( vecs( 4, IdentityMat( 5 ){ [ 1 .. 5 ] }{ [ 1 .. 4 ] } ) );
Error, DeterminantMat: <mat> must be a nonempty square matrix

# ragged, first row longer than the others; crashed
gap> DeterminantMat( vecs( 4,
>        Concatenation( [ List( [ 1 .. 2000 ], i -> 1 ) ],
>                       List( [ 1 .. 3 ], i -> [ 1, 0, 0, 0 ] ) ) ) );
Error, DeterminantMat: <mat> must be a nonempty square matrix
