# Algebra and AlgebraWithOne must reject generators that are not
# additive elements
gap> Algebra( GF(2), [ (1,2) ] );
Error, FLMLOR: <gens> must be a list of additive elements
gap> Algebra( GF(2), [ (1,2) ], "basis" );
Error, FLMLOR: <gens> must be a list of additive elements
gap> AlgebraWithOne( GF(2), [ (1,2) ] );
Error, FLMLORWithOne: <gens> must be a list of additive elements
gap> AlgebraWithOne( GF(2), [ ], () );
Error, FLMLORWithOne: <zero> must be an additive element
gap> Dimension( Algebra( GF(2), [ [ [ Z(2) ] ] ] ) );
1
gap> Dimension( AlgebraWithOne( Rationals, [ ], [ [ 0 ] ] ) );
1
