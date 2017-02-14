# 2005/02/21 (TB)
gap> v:= VectorSpace( Rationals, [ [ 1 ] ] );;
gap> x:= LeftModuleHomomorphismByImages( v, v, Basis( v ), Basis( v ) );;
gap> x + 0*x;;
