#@local checkStandardAssociate, A, x, R
gap> START_TEST("associate.tst");

# test StandardAssociate, StandardAssociateUnit, IsAssociated
gap> checkStandardAssociate :=
> function(R, coll...)
>   local r, u, s;
>   if Length(coll) > 0 then
>     coll := coll[1];
>   elif Size(R) <= 1000 then
>     coll := R;
>   else
>     coll := List([1..1000],i->Random(R));
>   fi;
>   for r in coll do
>     u := StandardAssociateUnit(R,r); Assert(0, u in R);
>     if not IsUnit(R,u) then Error("StandardAssociateUnit not a unit for ", [R,r]); fi;
>     s := StandardAssociate(R,r); Assert(0, s in R);
>     if u * r <> s then Error("StandardAssociate doesn't match its unit for ", [R,r]);  fi;
>     if not IsAssociated(R,r,s) then Error("r, s not associated for ", [R,r]);  fi;
>   od;
>   return true;
> end;;

# rings in characteristic 0
gap> checkStandardAssociate(Integers, [-10..10]);
true
gap> checkStandardAssociate(Rationals);
true
gap> checkStandardAssociate(GaussianIntegers);
true
gap> checkStandardAssociate(GaussianRationals);
true

# finite fields
gap> ForAll(Filtered([2..50], IsPrimePowerInt), q->checkStandardAssociate(GF(q)));
true

# ZmodnZ
gap> ForAll([1..100], m -> checkStandardAssociate(Integers mod m));
true
gap> checkStandardAssociate(Integers mod ((2*3*5)^2));
true
gap> checkStandardAssociate(Integers mod ((2*3*5)^3));
true
gap> checkStandardAssociate(Integers mod ((2*3*5*7)^2));
true
gap> checkStandardAssociate(Integers mod ((2*3*5*7)^3));
true

# polynomial rings
gap> for A in [ GF(5), Integers, Rationals ] do
>      for x in [1,3] do
>        R:=PolynomialRing(A, x);
>        checkStandardAssociate(R, List([1..30],i->PseudoRandom(R)));
>      od;
>    od;

#
gap> STOP_TEST("associate.tst", 1);
