# Bug reported by Martin Rubey in forum, Feb 17, 2026
gap> S := SymmetricGroup(10);;
gap> H := Group([ (3,4), (3,4,5,6,7,8,9,10), (1,2) ]);;
gap> F := Group([ (1,7)(2,8)(5,6), (1,8)(2,7)(3,9)(5,6) ]);;
gap> cc := ContainedConjugates(S, H, F);;
gap> Length(cc);
2
gap> ForAll(Combinations(cc, 2),
>            x -> RepresentativeAction(H, x[1][1], x[2][1]) = fail);
true

# Regression test for confusing candidate indices with cluster numbers.
gap> S := SymmetricGroup(12);;
gap> H := ClosureGroup(
>      Group([ (1,3), (2,6)(5,7), (2,5)(6,7) ]),
>      SymmetricGroup([8..12]));;
gap> F := ClosureGroup(
>      Group([ (1,6)(2,7) ]),
>      SymmetricGroup([8..12]));;
gap> cc := ContainedConjugates(S, H, F);;
gap> Length(cc);
3
gap> ForAll(Combinations(cc, 2),
>            x -> RepresentativeAction(H, x[1][1], x[2][1]) = fail);
true
