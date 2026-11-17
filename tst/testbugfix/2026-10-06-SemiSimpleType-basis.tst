# See https://github.com/gap-system/gap/pull/6630
gap> START_TEST( "2026-10-06-SemiSimpleType-basis.tst" );

# `SemiSimpleType' took the root vectors from `Basis' of each simple ideal,
# which semi-echelonizes the vectors that `DirectSumDecomposition' handed
# over. This failed when the basis of <L> does not consist of root vectors.
gap> L:= SimpleLieAlgebra( "B", 3, Rationals );;
gap> n:= Dimension( L );;
gap> b:= BasisVectors( Basis( L ) );;
gap> B:= Basis( L, List( [ 1 .. n ], function( i )
>          if i < n then return b[i] + b[i+1]; fi; return b[n]; end ) );;
gap> K:= LieAlgebraByStructureConstants( Rationals,
>                                        StructureConstantsTable( B ) );;
gap> SemiSimpleType( K );
"B3"

#
gap> STOP_TEST( "2026-10-06-SemiSimpleType-basis.tst" );
