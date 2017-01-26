# 2008/02/29 (TB)
gap> f:= GF(2);; x:= Indeterminate( f );; p:= x^2+x+1;;
gap> e:= AlgebraicExtension( f, p );;
gap> GeneratorsOfLeftModule( e );;  Basis( e );;  Iterator( e );;
