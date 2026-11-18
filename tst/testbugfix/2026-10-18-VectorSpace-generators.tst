# VectorSpace and FreeLeftModule must reject generators that are not
# additive elements
gap> VectorSpace( GF(2), [ (1,2) ] );
Error, FreeLeftModule: <gens> must be a list of additive elements
gap> FreeLeftModule( Integers, [ (1,2) ], "basis" );
Error, FreeLeftModule: <gens> must be a list of additive elements
gap> VectorSpace( GF(2), [ ], () );
Error, FreeLeftModule: <zero> must be an additive element
gap> Dimension( VectorSpace( GF(2), [ [ [ Z(2) ] ] ] ) );
1
gap> Dimension( VectorSpace( GF(2), [ ], [ 0*Z(2) ] ) );
0
