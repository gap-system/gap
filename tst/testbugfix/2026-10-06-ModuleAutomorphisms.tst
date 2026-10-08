# MTX.ModuleAutomorphisms ran into "arg[1] must be mutable" for modules
# given by plain list matrices, i.e. over fields with more than 256 elements
gap> G:= SymmetricGroup( 3 );;
gap> M:= PermutationGModule( G, GF(257) );;
gap> A:= MTX.ModuleAutomorphisms( TensorProductGModule( M, M ) );;

# the module is the sum of 2 trivial, 1 sign and 3 two-dimensional modules
gap> Size( A ) = Size( GL(2,257) ) * Size( GL(1,257) ) * Size( GL(3,257) );
true
