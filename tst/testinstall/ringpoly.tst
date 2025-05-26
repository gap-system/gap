#@local R,P,F,fam,f
gap> START_TEST("ringpoly.tst");

# Commutativity and associativity
gap> R := PolynomialRing(Integers, 2);;
gap> HasIsIntegralRing(R) and IsIntegralRing(R);
true
gap> HasIsCommutative(R) and IsCommutative(R);
true
gap> HasIsAssociative(R) and IsAssociative(R);
true

# Integral ring
gap> R := PolynomialRing(Integers, 2);;
gap> HasIsIntegralRing(R) and IsIntegralRing(R);
true

# Membership
gap> P := PolynomialRing(Rationals, 2);;
gap> F := FunctionField(Rationals, 2);;
gap> fam := FamilyObj(P.1);;
gap> f := RationalFunctionByExtRep(fam, [ [], 1 ], [ [ 2, 1 ], 1/2 ]);;
gap> f in F;
true
gap> P := PolynomialRing(Integers, 2);;
gap> F := FunctionField(Integers, 2);;
gap> fam := FamilyObj(P.1);;
gap> f := RationalFunctionByExtRep(fam, [ [], 1 ], [ [ 2, 1 ], 1/2 ]);;
gap> f in F;
true

#
gap> STOP_TEST("ringpoly.tst");
