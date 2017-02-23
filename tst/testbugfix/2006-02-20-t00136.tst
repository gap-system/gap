# 2006/2/20 (AH)
gap> group1 := Group([ (1,3)(2,5)(4,7)(6,8), (1,4)(2,6)(3,7)(5,8),
> (1,5)(2,3)(4,8)(6,7), (2,3,4,5,7,8,6), (3,4,7)(5,6,8) ]);;
gap> group2 := Group([ (1,3,4,7,2,6,8), (1,8,7,5,3,6,2) ]);;
gap> group3 := SymmetricGroup([1..8]);;
gap> RepresentativeAction(group3,group1,group2);
fail
