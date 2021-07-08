##  bug 2 for fix 4.
gap> 1 * One( Integers mod NextPrimeInt( 2^24 ) );
ZmodpZObj( 1, 16777259 )
gap> f:=FreeGroup("a","b");;g:=f/[Comm(f.1,f.2),f.1^5,f.2^7];;Pcgs(g);;
gap> n:=Subgroup(g,[g.2]);; m:=ModuloPcgs(g,n);;
gap> ExponentsOfPcElement(m,m[1]);
[ 1 ]
