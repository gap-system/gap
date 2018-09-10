gap> START_TEST("domain.tst");

# equality for a list and an infinite domain
gap> CF(4)=[E(4)];
false
gap> [E(4)]=CF(4);
false

# equality of a finite and an infinite domain
gap> M := Magma(0,1,2);;
gap> SetIsFinite(M, false);
gap> I := MagmaIdealByGenerators(M,[0]);;
gap> IsFinite(I);
true
gap> J := MagmaIdealByGenerators(M,[2]);;
gap> SetIsFinite(J, false);
gap> M = I;
false
gap> I = J;
false

# TODO: Reinstate a version that is compatible with the Semigroups package
#gap> M = J;
#Error, no method found for comparing two infinite domains

#
gap> STOP_TEST("domain.tst");
