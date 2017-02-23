#2015/05/12 (WdG, reported by Istvan Szollosi)
gap> L:= SimpleLieAlgebra("A",1,Rationals);
<Lie algebra of dimension 3 over Rationals>
gap> V:= HighestWeightModule(L,[2]);
<3-dimensional left-module over <Lie algebra of dimension 3 over Rationals>>
gap> v:= Basis(V)[1];
1*v0
gap> z:= Zero(V);
0*v0
gap> IsZero(z);
true
gap> w:= z+v;
1*v0
gap> -w+w;
0*v0
