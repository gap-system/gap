## bug 6 for fix 5
gap> v:= VectorSpace( Rationals, [ [ 1 ] ] );;
gap> x:= LeftModuleHomomorphismByImages( v, v, Basis( v ), Basis( v ) );;
gap> x + 0*x;;
