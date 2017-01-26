# 2007/02/21 (TB)
gap> v:= GF(2)^2;;  bv:= BasisVectors( Basis( v ) );;
gap> IsInjective( LeftModuleGeneralMappingByImages( v, v, bv, 0 * bv ) );
false
gap> map:= LeftModuleGeneralMappingByImages( v, v, 0 * bv, bv );;
gap> Print( ImagesRepresentative( map, Zero( v ) ), "\n" );
[ 0*Z(2), 0*Z(2) ]
