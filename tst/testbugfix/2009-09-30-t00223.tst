# 2009/09/30 (TB)
gap> v:= GF(2)^1;;
gap> Subspace( v, [] ) < Subspace( v, [] );
false
gap> v:= GF(2)^[1,1];;
gap> Subspace( v, [] ) < Subspace( v, [] );
false
