# 2008/09/02 (FL)
gap> SmithNormalFormIntegerMatTransforms(
> [ [ 2, 0, 0, 0, 0 ], [ 2, 2, 0, -2, 0 ], [ 0, -2, -2, -2, 0 ],
>   [ 3, 1, -1, 0, -1 ], [ 4, -2, 0, 2, 0 ], [ 3, -1, -1, 2, -1 ],
>   [ 0, 4, -2, 0, 2 ], [ 2, 2, 0, 2, 2 ], [ 0, 0, 0, 0, 0 ],
>   [ 2, 0, -4, -2, 0 ], [ 0, -2, 4, 2, -2 ], [ 2, -2, 0, -2, -1 ],
>   [ 3, -3, -1, 1, 0 ] ]).normal;
[ [ 1, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 2, 0 ], 
  [ 0, 0, 0, 0, 2 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], [ 0, 0, 0, 0, 0 ], 
  [ 0, 0, 0, 0, 0 ] ]

# 2008/09/10 (TB)
gap> g:= AlternatingGroup( 10 );;                                   
gap> gens:= GeneratorsOfGroup( g );;                                 
gap> hom:= GroupHomomorphismByImagesNC( g, g, gens, gens );;         
gap> IsOne( hom ); # This took (almost) forever before the change ...
true
