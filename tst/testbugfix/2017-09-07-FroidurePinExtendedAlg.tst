# Issue related to FroidurePinExtendedAlg
# Examples reported on issue #1674 on github.com/gap-system/gap
#
gap> sort := function(x, y)
> local rx, ry;
> rx := RankOfPartialPerm(Representative(x));
> ry := RankOfPartialPerm(Representative(y));
> return rx < ry;
> end;;
gap> x := PartialPerm([1]);
<identity partial perm on [ 1 ]>
gap> y := PartialPerm([0]);
<empty partial perm>
gap> S := Semigroup(x, y);
<partial perm monoid of rank 1 with 2 generators>
gap> D := ShallowCopy(GreensDClasses(S));;
gap> Sort(D, sort);
gap> D;
[ <Green's D-class: <empty partial perm>>, 
  <Green's D-class: <identity partial perm on [ 1 ]>> ]
gap> Elements(S);
[ <empty partial perm>, <identity partial perm on [ 1 ]> ]
gap> S := Semigroup(x, y);
<partial perm monoid of rank 1 with 2 generators>
gap> Elements(S);
[ <empty partial perm>, <identity partial perm on [ 1 ]> ]
gap> D := ShallowCopy(GreensDClasses(S));;
gap> Sort(D, sort);
gap> D;
[ <Green's D-class: <empty partial perm>>, 
  <Green's D-class: <identity partial perm on [ 1 ]>> ]

#
gap> SymmetricInverseMonoid(2);
<symmetric inverse monoid of degree 2>
gap> D := ShallowCopy(GreensDClasses(last));;
gap> Sort(D, sort);
gap> D;
[ <Green's D-class: <empty partial perm>>, 
  <Green's D-class: <identity partial perm on [ 1 ]>>, 
  <Green's D-class: <identity partial perm on [ 1, 2 ]>> ]

#
gap> S := Semigroup(x, y);
<partial perm monoid of rank 1 with 2 generators>
gap> FroidurePinExtendedAlg(S);
gap> LeftCayleyGraphSemigroup(S);
[ [ 1 ], [ 1 ] ]
