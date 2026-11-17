# IrreducibleModules failed for p-groups in characteristic p, also when they
# arise as abelian quotients for dim = 1, see
# <https://github.com/gap-system/gap/issues/5924>
gap> dims:= {G, F, d} -> List( IrreducibleModules( G, F, d )[2], m -> m.dimension );;
gap> dims( SymmetricGroup( 3 ), GF(4), 1 );
[ 1 ]
gap> dims( SymmetricGroup( 4 ), GF(4), 1 );
[ 1 ]
gap> dims( DihedralGroup( IsPermGroup, 8 ), GF(4), 1 );
[ 1 ]
gap> dims( DihedralGroup( 8 ), GF(4), 0 );
[ 1 ]
gap> dims( Group( [ [ Z(2)^0, Z(2)^0 ], [ 0*Z(2), Z(2)^0 ] ] ), GF(2), 0 );
[ 1 ]
gap> dims( AlternatingGroup( 4 ), GF(4), 1 );
[ 1, 1, 1 ]
