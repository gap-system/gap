#@local L,T,U,g,so3,b2,h3,dec,F,R,Fam,a,b,ma,mb,descr
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

# DirectSumDecomposition: exercise the cases with nondegenerate Killing
# form but non-split Cartan subalgebra (so(3) has eigenvalues +-i),
# and the cases with degenerate Killing form.
gap> T:= EmptySCTable( 3, 0, "antisymmetric" );;
gap> SetEntrySCTable( T, 1, 2, [ 1, 3 ] );
gap> SetEntrySCTable( T, 2, 3, [ 1, 1 ] );
gap> SetEntrySCTable( T, 3, 1, [ 1, 2 ] );
gap> so3:= LieAlgebraByStructureConstants( Rationals, T );;
gap> dec:= DirectSumDecomposition( so3 );;
gap> List( dec, Dimension );
[ 3 ]
gap> List( dec, SemiSimpleType );
[ "A1" ]
gap> L:= DirectSumOfAlgebras( so3, SimpleLieAlgebra( "A", 1, Rationals ) );;
gap> dec:= DirectSumDecomposition( L );;
gap> List( dec, Dimension );
[ 3, 3 ]
gap> ForAll( dec, I -> IsIdeal( L, I ) );
true
gap> List( dec, SemiSimpleType );
[ "A1", "A1" ]

# over a small field, decomposable elements are used instead of a
# splitting element
gap> F:= GF( 3 );;
gap> so3:= LieAlgebraByStructureConstants( F, T );;
gap> L:= DirectSumOfAlgebras( so3, so3 );;
gap> dec:= DirectSumDecomposition( L );;
gap> List( dec, Dimension );
[ 3, 3 ]
gap> ForAll( dec, I -> IsIdeal( L, I ) );
true
gap> L:= DirectSumOfAlgebras( so3, SimpleLieAlgebra( "A", 1, F ) );;
gap> dec:= DirectSumDecomposition( L );;
gap> List( dec, Dimension );
[ 3, 3 ]
gap> ForAll( dec, I -> IsIdeal( L, I ) );
true

# a central component
gap> T:= EmptySCTable( 2, 0, "antisymmetric" );;
gap> SetEntrySCTable( T, 1, 2, [ 1, 2 ] );
gap> b2:= LieAlgebraByStructureConstants( Rationals, T );;
gap> T:= EmptySCTable( 3, 0, "antisymmetric" );;
gap> SetEntrySCTable( T, 1, 2, [ 1, 3 ] );
gap> h3:= LieAlgebraByStructureConstants( Rationals, T );;
gap> List( DirectSumDecomposition( FullMatrixLieAlgebra( Rationals, 3 ) ),
>          Dimension );
[ 1, 8 ]
gap> T:= EmptySCTable( 2, 0, "antisymmetric" );;
gap> L:= DirectSumOfAlgebras( h3, LieAlgebraByStructureConstants( Rationals, T ) );;
gap> List( DirectSumDecomposition( L ), Dimension );
[ 1, 1, 3 ]

# no central component: idempotents in the centralizer of ad L
gap> L:= DirectSumOfAlgebras( b2, b2 );;
gap> dec:= DirectSumDecomposition( L );;
gap> List( dec, Dimension );
[ 2, 2 ]
gap> ForAll( dec, I -> IsIdeal( L, I ) );
true
gap> L:= DirectSumOfAlgebras( h3, b2 );;
gap> dec:= DirectSumDecomposition( L );;
gap> List( dec, Dimension );
[ 2, 3 ]
gap> ForAll( dec, I -> IsIdeal( L, I ) );
true
gap> List( DirectSumDecomposition( h3 ), Dimension );
[ 3 ]
gap> L:= LieAlgebraByStructureConstants( Rationals,
>                                        EmptySCTable( 0, 0, "antisymmetric" ) );;
gap> List( DirectSumDecomposition( L ), Dimension );
[ 0 ]

# NormalizedElementOfMagmaRingModuloRelations for free Lie algebras
# returns a description of the element, not the element
gap> R:= FreeLieAlgebra( Rationals, 2 );;
gap> Fam:= ElementsFamily( FamilyObj( R ) );;
gap> a:= R.1;;  b:= R.2;;
gap> ma:= CoefficientsAndMagmaElements( a )[1];;
gap> mb:= CoefficientsAndMagmaElements( b )[1];;
gap> descr:= [ 0, CoefficientsAndMagmaElements( a + a*b ) ];;
gap> NormalizedElementOfMagmaRingModuloRelations( Fam, descr ) = descr;
true
gap> NormalizedElementOfMagmaRingModuloRelations( Fam, [ 0, [ mb*ma, 1 ] ] )
>    = [ 0, CoefficientsAndMagmaElements( b*a ) ];
true
gap> NormalizedElementOfMagmaRingModuloRelations( Fam, [ 0, [ ma*ma, 1 ] ] );
[ 0, [  ] ]

#
gap> STOP_TEST("alglie.tst");
