##  bug 10 for fix 5
gap> k:=AbelianGroup([5,5,5]);
<pc group of size 125 with 3 generators>
gap> h:=SylowSubgroup(AutomorphismGroup(k),2);
<group>
gap> g:=SemidirectProduct(h,k);
<pc group with 10 generators>
gap> Centre(g);
Group([  ])
