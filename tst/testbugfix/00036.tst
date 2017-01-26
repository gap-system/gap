##  bug 8 for fix 1
gap> q:= QuaternionAlgebra( Rationals );;
gap> t:= TrivialSubspace( q );;
gap> tt:= Subspace( q, [] );;
gap> Intersection2( t, tt );;
gap> g:=SmallGroup(6,2);;
gap> f:=FreeGroup(3);;
gap> f:=f/[f.2*f.3];;
gap> q:=GQuotients(f,g);;
gap> k:=List(q,Kernel);;
gap> k:=Intersection(k);;
gap> hom:=IsomorphismFpGroup(TrivialSubgroup(g));;
gap> IsFpGroup(Range(hom));
true
