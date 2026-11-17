# MakeImmutable left the last row of a GF(2) matrix mutable, so the
# immutable matrix could still be changed
gap> m:= IdentityMat( 3, GF(2) );;
gap> ConvertToMatrixRep( m, 2 );;
gap> MakeImmutable( m );;
gap> List( [ 1 .. 3 ], i -> IsMutable( m[i] ) );
[ false, false, false ]
gap> m[3][1]:= Z(2);
Error, List Assignment: <list> must be a mutable list (not a data object)
gap> IsOne( m );
true
gap> ForAny( Immutable( m )^-1, IsMutable );
false
