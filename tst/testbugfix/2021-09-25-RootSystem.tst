# Fix GitHub issue #4661, reported by Lars Göttgens
gap> mats:=[ [[0,1,0],[-1,0,0],[0,0,0]], [[0,0,1],[0,0,0],[-1,0,0]], [[0,0,0],[0,0,1],[0,-1,0]] ];;
gap> F:=Field( E( 4 ) );;
gap> L:=LieAlgebra( F, mats );;
gap> R:=RootSystem( L );
<root system of rank 1>
gap> CartanMatrix( R );
[ [ 2 ] ]
