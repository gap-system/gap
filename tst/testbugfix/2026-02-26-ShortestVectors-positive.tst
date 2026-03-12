# Fix: ShortestVectors(..., "positive") should also accept vectors
# that are nonpositive by replacing them with their negation.

gap> E8 :=
> [ [ 2, -1, 0, 0, 0, 0, 0, 0 ], [ -1, 2, -1, 0, 0, 0, 0, 0 ],
>   [ 0, -1, 2, -1, 0, 0, 0, 0 ], [ 0, 0, -1, 2, -1, 0, 0, 0 ],
>   [ 0, 0, 0, -1, 2, -1, 0, -1 ], [ 0, 0, 0, 0, -1, 2, -1, 0 ],
>   [ 0, 0, 0, 0, 0, -1, 2, 0 ], [ 0, 0, 0, 0, -1, 0, 0, 2 ] ];;
gap> Length( ShortestVectors( E8, 2 ).vectors );
120
gap> sv := ShortestVectors( E8, 2, "positive" );;
gap> Length( sv.vectors );
120
gap> ForAll( sv.vectors, x -> ForAll( x, y -> y >= 0 ) );
true
