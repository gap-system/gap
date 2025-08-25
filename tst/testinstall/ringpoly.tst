#@local R,P,F,fam,f,PP,PF,old_ITER_POLY_WARN
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

# Membership for function fields over rationals/integers
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

# Membership for function fields over polynomial rings
gap> old_ITER_POLY_WARN := ITER_POLY_WARN;;
gap> ITER_POLY_WARN := false;;
gap> P := PolynomialRing(Rationals, 2);;
gap> PP := PolynomialRing(P, 2);;
gap> PF := FunctionField(P, 2);;
gap> fam := FamilyObj(PP.1);;
gap> f := RationalFunctionByExtRep(fam, [ [], One(P) ], [ [ 2, 1 ], 1/2*One(P) ]);;
gap> f in PF;
true
gap> P := PolynomialRing(Integers, 2);;
gap> PP := PolynomialRing(P, 2);;
gap> PF := FunctionField(P, 2);;
gap> fam := FamilyObj(PP.1);;
gap> f := RationalFunctionByExtRep(fam, [ [], One(P) ], [ [ 2, 1 ], 1/2*One(P) ]);;
gap> f in PF;
true
gap> ITER_POLY_WARN := old_ITER_POLY_WARN;;

#
gap> STOP_TEST("ringpoly.tst");
