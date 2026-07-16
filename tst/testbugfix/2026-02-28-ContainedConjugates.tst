# Bug reported by Martin Rubey in forum, Feb 17, 2026
gap> S := SymmetricGroup(10);;
gap> H := Group([ (3,4), (3,4,5,6,7,8,9,10), (1,2) ]);;
gap> F := Group([ (1,7)(2,8)(5,6), (1,8)(2,7)(3,9)(5,6) ]);;
gap> Length(ContainedConjugates(S, H, F));
2
