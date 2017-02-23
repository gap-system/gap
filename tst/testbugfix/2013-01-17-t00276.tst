# 2013/01/17 (AK)
gap> lo:= LieObject( [ [ 1, 0 ], [ 0, 1 ] ] );
LieObject( [ [ 1, 0 ], [ 0, 1 ] ] )
gap> m:=UnderlyingRingElement(lo);
[ [ 1, 0 ], [ 0, 1 ] ]
gap> lo*lo;
LieObject( [ [ 0, 0 ], [ 0, 0 ] ] )
gap> m*m;
[ [ 1, 0 ], [ 0, 1 ] ]
