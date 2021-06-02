gap> START_TEST("IsFinitelyGenerated.tst");

#
gap> R:=RingWithOne([1,1/2]);
<ring-with-one, with 2 generators>
gap> IsMonoid(R);
true
gap> HasIsFinitelyGeneratedMonoid(R);
false
gap> SetIsFinitelyGeneratedMagma(R,false);
gap> HasIsFinitelyGeneratedMagma(R);
true
gap> HasIsFinitelyGeneratedMonoid(R);
true

#
gap> G:=FreeGroup(infinity);
<free group with infinity generators>
gap> HasIsFinitelyGeneratedGroup(G);
true
gap> IsFinitelyGeneratedGroup(G);
false
gap> IsFinitelyGeneratedMagma(G);
false

#
gap> STOP_TEST("IsFinitelyGenerated.tst");
