#############################################################################
##
#W  frelements.g                  FR Package                Laurent Bartholdi
##
#H  @(#)$Id: frelements.g,v 1.5 2008/10/28 15:49:18 gap Exp $
##
#Y  Copyright (C) 2006,  Laurent Bartholdi
##
#############################################################################
##
##  This file reads the implementations, and in principle could be reloaded
##  during a GAP session.
#############################################################################

# We input the elements of each one of the 9 examples of machines found in "frmachines.g".
# More precisely, <frel> is a list containing 9 elements corresponding to the 9 machines.
# Each element of <frel> is a list containing 4 lists: one for FRElementNC, and three for FRElement.
# Finally, each one of these lists contains all the elements of the given machine.

frel := [];

# m1 : Grigorchuk group

Add(frel, []);
f := FreeGroup(5);
Add(frel[1], List(GeneratorsOfGroup(f), g -> FRElementNC(FREFamily([1,2]), f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]], [[1,2], [2,1], [1,2], [1,2], [1,2]], g)));
Add(frel[1], List([1..5], i -> FRElement(["e","a","b","c","d"], [[[1],[1]], [[1],[1]], [[2],[4]], [[2],[5]], [[1],[3]]], [[1,2], [2,1], (), (), ()], [i])));
Add(frel[1], List(GeneratorsOfGroup(f), g -> FRElement(f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]], [(), (1,2), (), (), ()], g)));
m := FRMachine(f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]], [(), (1,2), (), (), ()]);
Add(frel[1], List([1..5], i -> FRElement(m, [i])));

# m2 : Grigorchuk group (on a 8-ary tree)

Add(frel, []);
f := FreeGroup(3);
e := ListWithIdenticalEntries(8, One(f));
Add(frel[2], List(GeneratorsOfGroup(f), g -> FRElementNC(FREFamily([1..8]), f, [e, Concatenation(e{[1..7]}, [f.2]), Concatenation(e{[1..6]}, [f.1,f.3])], [[5,6,7,8,1,2,3,4], [3,4,1,2,6,5,7,8], [3,4,1,2,5,6,7,8]], g)));
e := ListWithIdenticalEntries(8, []);
Add(frel[2], List([1..3], i -> FRElement([e, Concatenation(e{[1..7]}, [[2]]), Concatenation(e{[1..6]}, [[1],[3]])], [(1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(5,6), (1,3)(2,4)], [i])));
Add(frel[2], List(GeneratorsOfGroup(f), g -> FRElement(f, [e, Concatenation(e{[1..7]}, [f.2]), Concatenation(e{[1..6]}, [f.1,f.3])], [(1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(5,6), (1,3)(2,4)], g)));
m := FRMachine(f, [e, Concatenation(e{[1..7]}, [f.2]), Concatenation(e{[1..6]}, [f.1,f.3])], [(1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(5,6), (1,3)(2,4)]);
Add(frel[2], List([1..3], i -> FRElement(m, i)));

# m3 : a spinal group

Add(frel, []);
f := FreeGroup(3);
Add(frel[3], List(GeneratorsOfGroup(f), g -> FRElementNC(FREFamily([1..2]), f, [[One(f), One(f)], [f.1, f.3], [One(f), f.2]], [[2,1], [1,2], [1,2]], g)));
Add(frel[3], List([1..3], i -> FRElement(["a","b1","b2"], [[[], []], [[1], [3]], [[], [2]]], [(1,2), (), ()], [i])));
Add(frel[3], List(GeneratorsOfGroup(f), g -> FRElement(f, [[One(f), One(f)], [f.1, f.3], [One(f), f.2]], [(1,2), (), ()], g)));
m := FRMachine([[[], []], [[1], [3]], [[], [2]]], [(1,2), (), ()]);
Add(frel[3], List([1..3], i -> FRElement(m, i)));

# m4 : the 5-adic adding machine

Add(frel, []);

f := FreeGroup(1);
Add(frel[4], List(GeneratorsOfGroup(f), g -> FRElementNC(FREFamily([1..5]), f, [[One(f), One(f), One(f), One(f), f.1]], [[2,3,4,5,1]], g)));
Add(frel[4], List([1], i -> FRElement([[[], [], [], [], [1]]], [(1,2,3,4,5)], [i])));
Add(frel[4], [FRElement(["t"], [[[], [], [], [], [1]]], [(1,2,3,4,5)], [1])]);
m := FRMachine(["t"], [[[], [], [], [], [1]]], [(1,2,3,4,5)]);
Add(frel[4], [FRElement(m, 1)]);

# m5 : a miscellaneous machine on a 7-ary tree

Add(frel, []);
f := FreeGroup("x","y","z");

Add(frel[5], List(GeneratorsOfGroup(f), g -> FRElementNC(FREFamily([1..7]), f, [[f.1, f.2, f.3, f.1, f.2, f.3, One(f)], [f.1, f.2, f.3, One(f), f.3, f.2, f.1], [One(f), f.2, f.2, f.1, f.3, One(f), One(f)]], [[2,3,4,5,1,6,7], [4,3,2,1,5,6,7], [6,5,1,4,2,3,7]], g)));
Add(frel[5], List([1..3], i -> FRElement(["5","*","7&#4"],[[[1], [2], [3], [1], [2], [3], []], [[1], [2], [3], [], [3], [2], [1]], [[], [2], [2], [1], [3], [], []]], [(1,2,3,4,5), (1,4)(2,3), (1,6,3)(2,5)], [i])));
Add(frel[5], List(GeneratorsOfGroup(f), g -> FRElement(f, [[f.1, f.2, f.3, f.1, f.2, f.3, One(f)], [f.1, f.2, f.3, One(f), f.3, f.2, f.1], [One(f), f.2, f.2, f.1, f.3, One(f), One(f)]], [(1,2,3,4,5), (1,4)(2,3), (1,6,3)(2,5)], g)));
m := FRMachine(f, [[f.1, f.2, f.3, f.1, f.2, f.3, One(f)], [f.1, f.2, f.3, One(f), f.3, f.2, f.1], [One(f), f.2, f.2, f.1, f.3, One(f), One(f)]], [(1,2,3,4,5), (1,4)(2,3), (1,6,3)(2,5)]);
Add(frel[5], List(GeneratorsOfFRMachine(m), g -> FRElement(m, g)));

# m6 : a non-Mealy GroupFRMachine

Add(frel, []);
f := FreeGroup(2);

Add(frel[6], List(GeneratorsOfGroup(f), g -> FRElementNC(FREFamily([1..3]), f, [[f.1*f.2, One(f), f.1^2], [f.2^-5, Comm(f.1,f.2), f.2/f.1]], [[2,3,1], [2,1,3]], g)));
Add(frel[6], List([1,2], i -> FRElement(["a","b"], [[[1,2], [], [1,1]], [[-2,-2,-2,-2,-2], [-1,-2,1,2], [2,-1]]], [(1,2,3), (1,2)], [i])));
Add(frel[6], List(GeneratorsOfGroup(f), g -> FRElement(f, [[f.1*f.2, One(f), f.1^2], [f.2^-5, Comm(f.1,f.2), f.2/f.1]], [(1,2,3), (1,2)], g)));
m := FRMachine(["a","b"], [[[1,2], [], [1,1]], [[-2,-2,-2,-2,-2], [-1,-2,1,2], [2,-1]]], [(1,2,3), (1,2)]);
Add(frel[6], List([1,2], i -> FRElement(m, i)));

# m7 : a miscellaneous MonoidFRMachine on the binary tree

Add(frel, []);
f := FreeMonoid(3);

Add(frel[7], List(GeneratorsOfMonoid(f), g -> FRElementNC(FREFamily([1..2]), f, [[f.1, f.3], [f.2, One(f)], [f.2, f.1]], [[1,1], [2,1], [2,2]], g)));
Add(frel[7], List([1..3], i -> FRElement(["z","y","x"], [[[1], [3]], [[2], []], [[2], [1]]], [Trans([1,1]), (1,2), Trans([2,2])], [i])));
Add(frel[7], List(GeneratorsOfMonoid(f), g -> FRElement(f, [[f.1, f.3], [f.2, One(f)], [f.2, f.1]], [Trans([1,1]), (1,2), Trans([2,2])], g)));
m := FRMachine(["z","y","x"], [[[1], [3]], [[2], []], [[2], [1]]], [Trans([1,1]), (1,2), Trans([2,2])]);
Add(frel[7], List([1..3], i -> FRElement(m, i)));

# m8 : a miscellaneous SemigroupFRMachine on a 7-ary tree

Add(frel, []);
f := FreeMonoid(2);

Add(frel[8], List(GeneratorsOfMonoid(f), g -> FRElementNC(FREFamily([1..7]), f, [[f.1,f.2,f.1,f.2,f.1,f.2,f.1],[f.2,f.2,f.1,f.2,f.1,f.1,f.2]], [[2,5,4,7,7,4,3],[3,1,6,7,4,7,1]], g)));
Add(frel[8], List([1,2], i -> FRElement(["a","b"],[[[1],[2],[1],[2],[1],[2],[1]],[[2],[2],[1],[2],[1],[1],[2]]], [Trans([2,5,4,7,7,4,3]),Trans([3,1,6,7,4,7,1])], [i])));
Add(frel[8], List(GeneratorsOfMonoid(f), g -> FRElement(f, [[f.1,f.2,f.1,f.2,f.1,f.2,f.1],[f.2,f.2,f.1,f.2,f.1,f.1,f.2]], [Trans([2,5,4,7,7,4,3]),Trans([3,1,6,7,4,7,1])], g)));
m := FRMachine(["a","b"],[[[1],[2],[1],[2],[1],[2],[1]],[[2],[2],[1],[2],[1],[1],[2]]], [Trans([2,5,4,7,7,4,3]),Trans([3,1,6,7,4,7,1])]);
Add(frel[8], List(GeneratorsOfFRMachine(m), g -> FRElement(m, g)));

# m9 : a non-Mealy SemigroupFRMachine

Add(frel, []);
f := FreeSemigroup(2);

Add(frel[9], List(GeneratorsOfSemigroup(f), g -> FRElementNC(FREFamily([1..3]), f, [[f.1^2,f.2^3*f.1,f.2],[f.1,f.1^7,f.1^2*f.2^2*f.1]], [[3,2,2],[2,1,3]], g)));
Add(frel[9], List([1..2], i -> FRElement(["a1","a2"],[[[1,1],[2,2,2,1],[2]],[[1],[1,1,1,1,1,1,1],[1,1,2,2,1]]],[Trans([3,2,2]),(1,2)],[i])));
Add(frel[9], List(GeneratorsOfSemigroup(f), g -> FRElement(f, [[f.1^2,f.2^3*f.1,f.2],[f.1,f.1^7,f.1^2*f.2^2*f.1]],[Trans([3,2,2]),(1,2)],g)));
m := FRMachine(["a1","a2"],[[[1,1],[2,2,2,1],[2]],[[1],[1,1,1,1,1,1,1],[1,1,2,2,1]]],[Trans([3,2,2]),(1,2)]);
Add(frel[9], List([1,2], i -> FRElement(m, [i])));

#E frelements.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here