gap> START_TEST("Normalizer.tst");
gap> r:=Integers mod 4;;
gap> maz:=[ [ [ 3, 1, 2, 1 ], [ 1, 2, 1, 1 ], [ 2, 1, 1, 3 ], [ 1, 1, 3, 2 ] ],
>   [ [ 1, 1, 3, 2 ], [ 1, 3, 2, 3 ], [ 3, 2, 3, 3 ], [ 2, 3, 3, 1 ] ] ];;
gap> G:=GL(4,r);;
gap> U:=Group(maz*One(r));;
gap> hom:=IsomorphismPermGroup(G);;
gap> g:=Image(hom,G);;u:=Image(hom,U);;
gap> Normalizer(g,u)=NormalizerViaRadical(g,u);
true
gap> STOP_TEST("Normalizer.tst", 1);
