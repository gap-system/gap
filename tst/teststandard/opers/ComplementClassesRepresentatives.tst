gap> START_TEST("ComplementClassesRepresentatives.tst");
gap> n := 0;; for G in AllGroups(60) do for N in NormalSubgroups(G) do if ComplementClassesRepresentatives(G, N)<>fail then n := n+1; fi; od; od; n;
133
gap> G := SymmetricGroup(4);; N := DerivedSubgroup(AlternatingGroup(4));;
gap> Set(ComplementClassesRepresentatives(G, N), H -> H^G)=Set([ Group([ (3,4), (2,4,3) ])^G ]);
true
gap> G := SymmetricGroup(4);; N := DerivedSubgroup(AlternatingGroup(4));;
gap> ConjugacyClassesSubgroups(G);;
gap> IsTrivial(ComplementClassesRepresentatives(G, G));
true
gap> ComplementClassesRepresentatives(G, Group((1,2)));
Error, N must be normal in G
gap> Set(ComplementClassesRepresentatives(G, N), H -> H^G)=Set([ Group([ (3,4), (2,4,3) ])^G ]);
true
gap> G := Group((1,2),(1,2,3,4));;
gap> N := DerivedSubgroup(Group((1,2,3),(2,3,4)));;
gap> Set(ComplementClassesRepresentatives(G, N), H -> H^G)=Set([ Group([ (3,4), (2,4,3) ])^G ]);
true
gap> G := Group([ (6,7,8,9,10), (8,9,10), (1,2)(6,7), (1,2,3,4,5)(6,7,8,9,10) ]);;
gap> N := Group((6,7,8),(6,7,8,9,10));;
gap> ComplementClassesRepresentatives(G, N);
Error, cannot compute complements if both N and G/N are nonsolvable
gap> G := Group([ (6,7,8,9,10), (8,9,10), (1,2)(6,7), (1,2,3,4,5)(6,7,8,9,10) ]);;
gap> N := Group((6,7,8),(6,7,8,9,10));; ConjugacyClassesSubgroups(G);;
gap> Set(ComplementClassesRepresentatives(G, N), H -> H^G)=Set([ Group([ (1,2,5)(3,4)(6,7), (1,4)(2,5,3)(6,7) ])^G, Group([ (2,5)(7,8), (1,3,5,4)(6,10,9,7) ])^G, Group([ (2,3,4)(6,8,10), (1,2)(3,5,4)(6,10,7)(8,9) ])^G ]);
true
gap> G := SymmetricGroup(5);; N := AlternatingGroup(5);;
gap> Set(ComplementClassesRepresentatives(G, N), H -> H^G)=Set([ Group([ (1,2) ])^G ]);
true
gap> G := SymmetricGroup(6);; N := AlternatingGroup(6);;
gap> Set(ComplementClassesRepresentatives(G, N), H -> H^G)=Set([ Group([ (1,2) ])^G, Group([ (1,2)(3,4)(5,6) ])^G ]);
true
gap> STOP_TEST("ComplementClassesRepresentatives.tst", 1);
