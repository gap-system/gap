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
gap> M = J;
Error, no method found for comparing two infinite domains

# PrintObj method
gap> Domain([1..5]);
Domain([ 1 .. 5 ])
gap> Domain(FamilyObj(1), []);
Domain([  ])

# AsList and Enumerator for domains which know their GeneratorsOfDomain
gap> r := Immutable([1..3]);;
gap> d := Domain(r);;
gap> IsIdenticalObj(AsList(d), r);
true
gap> IsIdenticalObj(Enumerator(d), r);
true
gap> r := Immutable([1,2,3,1]);;
gap> d := Domain(r);;
gap> IsIdenticalObj(GeneratorsOfDomain(d), r);
true
gap> IsIdenticalObj(AsList(d), r);
false
gap> IsIdenticalObj(Enumerator(d), r);
false

#
gap> STOP_TEST("domain.tst");
