#@local L,T,U,g
gap> START_TEST("alglie.tst");

# universal enveloping algebra
gap> L:= SimpleLieAlgebra( "A", 1, Rationals );;
gap> U:= UniversalEnvelopingAlgebra( L );;
gap> g:= GeneratorsOfAlgebraWithOne( U );
[ [(1)*x.1], [(1)*x.2], [(1)*x.3] ]
gap> g[3]*g[2]*g[1];
[(1)*x.1*x.2*x.3+(-1)*x.3^2]
gap> g[3]^2*g[2]^2*g[1]^2;
[(-4)*x.1*x.2*x.3^3+(1)*x.1^2*x.2^2*x.3^2+(2)*x.3^3+(2)*x.3^4]

# normal form: equal monomials are merged, zero coefficients dropped
gap> T:= StructureConstantsTable( Basis( L ) );;
gap> DescriptionOfNormalizedUEAElement( T, [ [ 2, 1, 1, 1 ], 1, [ 1, 1, 2, 1 ], -1 ] );
[ [ 3, 1 ], -1 ]
gap> DescriptionOfNormalizedUEAElement( T, [ [ 3, 1, 2, 1 ], 1, [ 2, 1, 3, 1 ], -1 ] );
[ [ 2, 1 ], -2 ]
gap> DescriptionOfNormalizedUEAElement( T, [ [ 1, 1, 2, 1 ], 1, [ 1, 1, 2, 1 ], -1 ] );
[  ]

#
gap> STOP_TEST("alglie.tst");
