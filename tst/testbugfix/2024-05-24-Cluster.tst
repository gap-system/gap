# Fix #5717
gap> g := Group([ (2,4,6,8,12),
>                 (2,4)(6,8)(10,12),
>                 (1,12)(2,3)(4,5)(6,7)(8,9)(10,11) ]);;
gap> # g = TransitiveGroup(12,288);;
gap> ConjugacyClassesSubgroups(g);;
