# 2005/10/28 (TB)
gap> rg:= GroupRing( GF(2), SymmetricGroup( 3 ) );;
gap> i:= Ideal( rg, [ Sum( GeneratorsOfAlgebra( rg ){ [ 1, 2 ] } ) ] );;
gap> Dimension( rg / i );;
