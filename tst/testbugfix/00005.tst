##  Check the fix in OrbitStabilizerAlgorithm (Error 4) for infinite groups.
##
gap> N:=GroupByGenerators(
>   [ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 0, 0 ], [ 0, -1, 0, 0 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 1, 0 ], [ 0, -1, 0, 1 ] ], 
>     [ [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ], [ -1, 0, 0, -1 ], [ 0, -1, 1, 0 ] ], 
>     [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ], 
>     [ [ 0, 1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, 1 ], [ 0, 0, 1, 0 ] ] ] );
<matrix group with 6 generators>
gap> IsFinite(N);
false
gap> G:=GroupByGenerators( [ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ],
>   [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ] ] );
Group([ [ [ 0, -1, 0, 0 ], [ 1, 0, 0, 0 ], [ 0, 0, 0, -1 ], [ 0, 0, 1, 0 ] ] 
 ])
gap> Centralizer(N,G);
<matrix group of size infinity with 6 generators>
