#############################################################################
##
#W  frmachines.g                  FR Package                Laurent Bartholdi
##
#H  @(#)$Id: frmachines.g,v 1.5 2008/10/28 15:49:18 gap Exp $
##
#Y  Copyright (C) 2006,  Laurent Bartholdi
##
#############################################################################
##
##  This file reads the implementations, and in principle could be reloaded
##  during a GAP session.
#############################################################################

# We input 9 examples of machines. The first 6 are GroupFRMachines.
# They are stored in the variables mg, mm, ms, mmi, msiu, msu (for groups, monoids, semigroups, monoids with inverses, semigroups with inverses and unit, semigroups with unit).
# For each one of these categories, we define the associated <f>ree group/monoid/semigroup, the <transitions> and the <outputs>.

mg := [];
mm := [];
ms := [];
mmi := [];
msiu := [];
msu := [];
transitions := [];
outputs := [];

# m1 : Grigorchuk group

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);
f := FreeGroup(5);
Add(transitions, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]]);
Add(outputs, [[1,2], [2,1], [1,2], [1,2], [1,2]]);
m := FRMachineNC(FRMFamily([1,2]), f, transitions[1], outputs[1]);
Add(mg[1], m);
m := FRMachine([[[1],[1]], [[1],[1]], [[2],[4]], [[2],[5]], [[1],[3]]], [(), (1,2), (), (), ()]);
Add(mg[1], m);
m := FRMachine(["e","a","b","c","d"], [[[1],[1]], [[1],[1]], [[2],[4]], [[2],[5]], [[1],[3]]], [[1,2], [2,1], Trans([1,2]), Trans([]), ()]);
Add(mg[1], m);
m := FRMachine(f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]], [(), (1,2), (), (), ()]);
Add(mg[1], m);

f := FreeMonoid(5);
id := Trans([]);
m := FRMachineNC(FRMFamily([1,2]), f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]], [[1,2], [2,1], [1,2], [1,2], [1,2]]);
Add(mm[1], m);
m := FRMachine(f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]], [[1,2], [2,1], id, id, id]);
Add(mm[1], m);

f := FreeSemigroup(5);
m := FRMachineNC(FRMFamily([1,2]), f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]], [[1,2], [2,1], [1,2], [1,2], [1,2]]);
Add(ms[1], m);
m := FRMachine(f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.2, f.5], [f.1, f.3]], [[1,2], [2,1], id, id, id]);
Add(ms[1], m);

f := FreeMonoid(9);
m := FRMachineNC(FRMFamily([1,2]), f, [[f.1, f.1], [f.1, f.1], [f.1, f.1], [f.2, f.6], [f.3, f.7], [f.2, f.8], [f.3, f.9], [f.1, f.4], [f.1, f.5]], [[1,2], [2,1], [2,1], [1,2], [1,2], [1,2], [1,2], [1,2], [1,2]]);
Add(mmi[1], m);
m := FRMachine(f, [[f.1, f.1], [f.1, f.1], [f.1, f.1], [f.2, f.6], [f.3, f.7], [f.2, f.8], [f.3, f.9], [f.1, f.4], [f.1, f.5]], [id, Trans([2,1]), Trans([2,1]), id, id, id, id, id, id]);
Add(mmi[1], m);

f := FreeSemigroup(9);
m := FRMachineNC(FRMFamily([1,2]), f, [[f.1, f.1], [f.1, f.1], [f.1, f.1], [f.2, f.6], [f.3, f.7], [f.2, f.8], [f.3, f.9], [f.1, f.4], [f.1, f.5]], [[1,2], [2,1], [2,1], [1,2], [1,2], [1,2], [1,2], [1,2], [1,2]]);
Add(msiu[1], m);
m := FRMachine(f, [[f.1, f.1], [f.1, f.1], [f.1, f.1], [f.2, f.6], [f.3, f.7], [f.2, f.8], [f.3, f.9], [f.1, f.4], [f.1, f.5]], [id, Trans([2,1]), Trans([2,1]), id, id, id, id, id, id]);
Add(msiu[1], m);

# m2 : Grigorchuk group (on a 8-ary tree)

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);

f := FreeGroup(3);
e := ListWithIdenticalEntries(8, One(f));
Add(transitions, [e, Concatenation(e{[1..7]}, [f.2]), Concatenation(e{[1..6]}, [f.1,f.3])]);
Add(outputs, [[5,6,7,8,1,2,3,4], [3,4,1,2,6,5,7,8], [3,4,1,2,5,6,7,8]]);
m := FRMachineNC(FRMFamily([1..8]), f, transitions[2], outputs[2]);
Add(mg[2], m);
e := ListWithIdenticalEntries(8, []);
m := FRMachine([e, Concatenation(e{[1..7]}, [[2]]), Concatenation(e{[1..6]}, [[1],[3]])], [(1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(5,6), (1,3)(2,4)]);
Add(mg[2], m);
m := FRMachine(["a","b","c"], [e, Concatenation(e{[1..7]}, [[2]]), Concatenation(e{[1..6]}, [[1],[3]])], [(1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(5,6), (1,3)(2,4)]);
Add(mg[2], m);
m := FRMachine(f, [e, Concatenation(e{[1..7]}, [f.2]), Concatenation(e{[1..6]}, [f.1,f.3])], [(1,5)(2,6)(3,7)(4,8), (1,3)(2,4)(5,6), (1,3)(2,4)]);
Add(mg[2], m);

f := FreeMonoid(6);
e := ListWithIdenticalEntries(8, One(f));
m := FRMachineNC(FRMFamily([1..8]), f, [e, Concatenation(e{[1..7]}, [f.2]), Concatenation(e{[1..6]}, [f.1,f.3]), e, Concatenation(e{[1..7]}, [f.5]), Concatenation(e{[1..6]}, [f.4,f.6])], [[5,6,7,8,1,2,3,4], [3,4,1,2,6,5,7,8], [3,4,1,2,5,6,7,8], [5,6,7,8,1,2,3,4], [3,4,1,2,6,5,7,8], [3,4,1,2,5,6,7,8]]);
Add(mmi[2], m);
m := FRMachine(f, [e, Concatenation(e{[1..7]}, [f.2]), Concatenation(e{[1..6]}, [f.1,f.3]), e, Concatenation(e{[1..7]}, [f.5]), Concatenation(e{[1..6]}, [f.4,f.6])], [Trans([5,6,7,8,1,2,3,4]), Trans([3,4,1,2,6,5,7,8]), Trans([3,4,1,2,5,6,7,8]), Trans([5,6,7,8,1,2,3,4]), Trans([3,4,1,2,6,5,7,8]), Trans([3,4,1,2,5,6,7,8])]);
Add(mmi[2], m);

f := FreeSemigroup(7);
e := ListWithIdenticalEntries(8, f.1);
m := FRMachineNC(FRMFamily([1..8]), f, [e, e, Concatenation(e{[1..7]}, [f.3]), Concatenation(e{[1..6]}, [f.2,f.4]), e, Concatenation(e{[1..7]}, [f.6]), Concatenation(e{[1..6]}, [f.5,f.7])], [[1,2,3,4,5,6,7,8], [5,6,7,8,1,2,3,4], [3,4,1,2,6,5,7,8], [3,4,1,2,5,6,7,8], [5,6,7,8,1,2,3,4], [3,4,1,2,6,5,7,8], [3,4,1,2,5,6,7,8]]);
Add(msiu[2], m);
m := FRMachine(f, [e, e, Concatenation(e{[1..7]}, [f.3]), Concatenation(e{[1..6]}, [f.2,f.4]), e, Concatenation(e{[1..7]}, [f.6]), Concatenation(e{[1..6]}, [f.5,f.7])], [Trans([]), Trans([5,6,7,8,1,2,3,4]), Trans([3,4,1,2,6,5,7,8]), Trans([3,4,1,2,5,6,7,8]), Trans([5,6,7,8,1,2,3,4]), Trans([3,4,1,2,6,5,7,8]), Trans([3,4,1,2,5,6,7,8])]);
Add(msiu[2], m);

# m3 : a spinal group

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);

f := FreeGroup(3);
Add(transitions, [[One(f), One(f)], [f.1, f.3], [One(f), f.2]]);
Add(outputs, [[2,1], [1,2], [1,2]]);
m := FRMachineNC(FRMFamily([1..2]), f, transitions[3], outputs[3]);
Add(mg[3], m);
m := FRMachine([[[], []], [[1], [3]], [[], [2]]], [(1,2), (), ()]);
Add(mg[3], m);
m := FRMachine(["a","b1","b2"], [[[], []], [[1], [3]], [[], [2]]], [(1,2), (), ()]);
Add(mg[3], m);
m := FRMachine(f, [[One(f), One(f)], [f.1, f.3], [One(f), f.2]], [(1,2), (), ()]);
Add(mg[3], m);

f := FreeMonoid(6);
m := FRMachineNC(FRMFamily([1..2]), f, [[One(f), One(f)], [f.1, f.3], [One(f), f.2], [One(f), One(f)], [f.4, f.6], [One(f), f.5]], [[2,1], [1,2], [1,2], [2,1], [1,2], [1,2]]);
Add(mmi[3], m);
m := FRMachine(f, [[One(f), One(f)], [f.1, f.3], [One(f), f.2], [One(f), One(f)], [f.4, f.6], [One(f), f.5]], [(1,2), (), (), (1,2), (), ()]);
Add(mmi[3], m);

f := FreeSemigroup(7);
m := FRMachineNC(FRMFamily([1..2]), f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.1, f.3], [f.1, f.1], [f.5, f.7], [f.1, f.6]], [[1,2], [2,1], [1,2], [1,2], [2,1], [1,2], [1,2]]);
Add(msiu[3], m);
m := FRMachine(f, [[f.1, f.1], [f.1, f.1], [f.2, f.4], [f.1, f.3], [f.1, f.1], [f.5, f.7], [f.1, f.6]], [(), (1,2), (), (), (1,2), (), ()]);
Add(msiu[3], m);

# m4 : the 5-adic adding machine

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);

f := FreeGroup(1);
Add(transitions, [[One(f), One(f), One(f), One(f), f.1]]);
Add(outputs, [[2,3,4,5,1]]);
m := FRMachineNC(FRMFamily([1..5]), f, transitions[4], outputs[4]);
Add(mg[4], m);
m := FRMachine([[[], [], [], [], [1]]], [(1,2,3,4,5)]);
Add(mg[4], m);
m := FRMachine(["t"], [[[], [], [], [], [1]]], [(1,2,3,4,5)]);
Add(mg[4], m);
m := FRMachine(f, [[One(f), One(f), One(f), One(f), f.1]], [(1,2,3,4,5)]);
Add(mg[4], m);

f := FreeMonoid(1);
m := FRMachineNC(FRMFamily([1..5]), f, [[One(f), One(f), One(f), One(f), f.1]], [[2,3,4,5,1]]);
Add(mm[4], m);
m := FRMachine(f, [[One(f), One(f), One(f), One(f), f.1]], [(1,2,3,4,5)]);
Add(mm[4], m);

f := FreeMonoid(2);
m := FRMachineNC(FRMFamily([1..5]), f, [[One(f), One(f), One(f), One(f), f.1], [f.2, One(f), One(f), One(f), One(f)]], [[2,3,4,5,1], [5,1,2,3,4]]);
Add(mmi[4], m);
m := FRMachine(f, [[One(f), One(f), One(f), One(f), f.1], [f.2, One(f), One(f), One(f), One(f)]], [(1,2,3,4,5), (1,5,4,3,2)]);
Add(mmi[4], m);

f := FreeSemigroup(3);
m := FRMachineNC(FRMFamily([1..5]), f, [[f.1, f.1, f.1, f.1, f.1], [f.1, f.1, f.1, f.1, f.2], [f.3, f.1, f.1, f.1, f.1]], [[1,2,3,4,5], [2,3,4,5,1], [5,1,2,3,4]]);
Add(msiu[4], m);
m := FRMachine(f, [[f.1, f.1, f.1, f.1, f.1], [f.1, f.1, f.1, f.1, f.2], [f.3, f.1, f.1, f.1, f.1]], [(), (1,2,3,4,5), (1,5,4,3,2)]);
Add(msiu[4], m);

# m5 : a miscellaneous machine on a 7-ary tree

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);

f := FreeGroup("x","y","z");
Add(transitions, [[f.1, f.2, f.3, f.1, f.2, f.3, One(f)], [f.1, f.2, f.3, One(f), f.3, f.2, f.1], [One(f), f.2, f.2, f.1, f.3, One(f), One(f)]]);
Add(outputs, [[2,3,4,5,1,6,7], [4,3,2,1,5,6,7], [6,5,1,4,2,3,7]]);
m := FRMachineNC(FRMFamily([1..7]), f, transitions[5], outputs[5]);
Add(mg[5], m);
m := FRMachine([[[1], [2], [3], [1], [2], [3], []], [[1], [2], [3], [], [3], [2], [1]], [[], [2], [2], [1], [3], [], []]], [(1,2,3,4,5), (1,4)(2,3), (1,6,3)(2,5)]);
Add(mg[5], m);
m := FRMachine(["5","*","7&#4"],[[[1], [2], [3], [1], [2], [3], []], [[1], [2], [3], [], [3], [2], [1]], [[], [2], [2], [1], [3], [], []]], [(1,2,3,4,5), (1,4)(2,3), (1,6,3)(2,5)]);
Add(mg[5], m);
m := FRMachine(f, [[f.1, f.2, f.3, f.1, f.2, f.3, One(f)], [f.1, f.2, f.3, One(f), f.3, f.2, f.1], [One(f), f.2, f.2, f.1, f.3, One(f), One(f)]], [(1,2,3,4,5), (1,4)(2,3), (1,6,3)(2,5)]);
Add(mg[5], m);

f := FreeMonoid("x","y","z");
m := FRMachineNC(FRMFamily([1..7]), f, [[f.1, f.2, f.3, f.1, f.2, f.3, One(f)], [f.1, f.2, f.3, One(f), f.3, f.2, f.1], [One(f), f.2, f.2, f.1, f.3, One(f), One(f)]], [[2,3,4,5,1,6,7], [4,3,2,1,5,6,7], [6,5,1,4,2,3,7]]);
Add(mm[5], m);
m := FRMachine(f, [[f.1, f.2, f.3, f.1, f.2, f.3, One(f)], [f.1, f.2, f.3, One(f), f.3, f.2, f.1], [One(f), f.2, f.2, f.1, f.3, One(f), One(f)]], [(1,2,3,4,5), (1,4)(2,3), (1,6,3)(2,5)]);
Add(mm[5], m);

f := FreeMonoid("x","x'","y","y'","z","z'");
m := FRMachineNC(FRMFamily([1..7]), f, [[f.1, f.3, f.5, f.1, f.3, f.5, One(f)], [f.4, f.2, f.4, f.6, f.2, f.6, One(f)], [f.1, f.3, f.5, One(f), f.5, f.3, f.1], [One(f), f.6, f.4, f.2, f.6, f.4, f.2], [One(f), f.3, f.3, f.1, f.5, One(f), One(f)], [f.4, f.6, One(f), f.2, f.4, One(f), One(f)]], [[2,3,4,5,1,6,7], [5,1,2,3,4,6,7], [4,3,2,1,5,6,7], [4,3,2,1,5,6,7], [6,5,1,4,2,3,7], [3,5,6,4,2,1,7]]);
Add(mmi[5], m);
m := FRMachine(f, [[f.1, f.3, f.5, f.1, f.3, f.5, One(f)], [f.4, f.2, f.4, f.6, f.2, f.6, One(f)], [f.1, f.3, f.5, One(f), f.5, f.3, f.1], [One(f), f.6, f.4, f.2, f.6, f.4, f.2], [One(f), f.3, f.3, f.1, f.5, One(f), One(f)], [f.4, f.6, One(f), f.2, f.4, One(f), One(f)]], [(1,2,3,4,5), (5,4,3,2,1), (1,4)(2,3), (1,4)(2,3), (1,6,3)(2,5), (3,6,1)(2,5)]);
Add(mmi[5], m);

f := FreeSemigroup("x","x'","y","y'","z","z'","1");
m := FRMachineNC(FRMFamily([1..7]), f, [[f.1, f.3, f.5, f.1, f.3, f.5, f.7], [f.4, f.2, f.4, f.6, f.2, f.6, f.7], [f.1, f.3, f.5, f.7, f.5, f.3, f.1], [f.7, f.6, f.4, f.2, f.6, f.4, f.2], [f.7, f.3, f.3, f.1, f.5, f.7, f.7], [f.4, f.6, f.7, f.2, f.4, f.7, f.7], ListWithIdenticalEntries(7, f.7)], [[2,3,4,5,1,6,7], [5,1,2,3,4,6,7], [4,3,2,1,5,6,7], [4,3,2,1,5,6,7], [6,5,1,4,2,3,7], [3,5,6,4,2,1,7], [1,2,3,4,5,6,7]]);
Add(msiu[5], m);
m := FRMachine(f, [[f.1, f.3, f.5, f.1, f.3, f.5, f.7], [f.4, f.2, f.4, f.6, f.2, f.6, f.7], [f.1, f.3, f.5, f.7, f.5, f.3, f.1], [f.7, f.6, f.4, f.2, f.6, f.4, f.2], [f.7, f.3, f.3, f.1, f.5, f.7, f.7], [f.4, f.6, f.7, f.2, f.4, f.7, f.7], ListWithIdenticalEntries(7, f.7)], [(1,2,3,4,5), (5,4,3,2,1), (1,4)(2,3), (1,4)(2,3), (1,6,3)(2,5), (3,6,1)(2,5), ()]);
Add(msiu[5], m);

# m6 : a non-Mealy GroupFRMachine

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);

f := FreeGroup(2);
Add(transitions, [[f.1*f.2, One(f), f.1^2], [f.2^-5, Comm(f.1,f.2), f.2/f.1]]);
Add(outputs, [[2,3,1], [2,1,3]]);
m := FRMachineNC(FRMFamily([1..3]), f, transitions[6], outputs[6]);
Add(mg[6], m);
m := FRMachine([[[1,2], [], [1,1]], [[-2,-2,-2,-2,-2], [-1,-2,1,2], [2,-1]]], [(1,2,3), (1,2)]);
Add(mg[6], m);
m := FRMachine(["a","b"], [[[1,2], [], [1,1]], [[-2,-2,-2,-2,-2], [-1,-2,1,2], [2,-1]]], [(1,2,3), (1,2)]);
Add(mg[6], m);
m := FRMachine(f, [[f.1*f.2, One(f), f.1^2], [f.2^-5, Comm(f.1,f.2), f.2/f.1]], [(1,2,3), (1,2)]);
Add(mg[6], m);

f := FreeMonoid(4);
m := FRMachineNC(FRMFamily([1..3]), f, [[f.1*f.2, One(f), f.1^2], [f.4^5, f.3*f.4*f.1*f.2, f.2*f.3], [f.3^2, f.4*f.3, One(f)], [f.4*f.3*f.2*f.1, f.2^5, f.1*f.4]], [[2,3,1], [2,1,3], [3,1,2], [2,1,3]]);
Add(mmi[6], m);
m := FRMachine(f, [[f.1*f.2, One(f), f.1^2], [f.4^5, f.3*f.4*f.1*f.2, f.2*f.3], [f.3^2, f.4*f.3, One(f)], [f.4*f.3*f.2*f.1, f.2^5, f.1*f.4]], [(1,2,3), (1,2), (3,2,1), (1,2)]);
Add(mmi[6], m);

f := FreeSemigroup(5);
m := FRMachineNC(FRMFamily([1..3]), f, [[f.1*f.2, f.5, f.1^2], [f.4^5, f.3*f.4*f.1*f.2, f.2*f.3], [f.3^2, f.4*f.3, f.5], [f.4*f.3*f.2*f.1, f.2^5, f.1*f.4], ListWithIdenticalEntries(3, f.5)], [[2,3,1], [2,1,3], [3,1,2], [2,1,3], [1,2,3]]);
Add(msiu[6], m);
m := FRMachine(f, [[f.1*f.2, f.5, f.1^2], [f.4^5, f.3*f.4*f.1*f.2, f.2*f.3], [f.3^2, f.4*f.3, f.5], [f.4*f.3*f.2*f.1, f.2^5, f.1*f.4], ListWithIdenticalEntries(3, f.5)], [(1,2,3), (1,2), (3,2,1), (1,2), ()]);
Add(msiu[6], m);

# m7 : a miscellaneous MonoidFRMachine on the binary tree

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);

f := FreeMonoid(3);
Add(transitions, [[f.1, f.3], [f.2, One(f)], [f.2, f.1]]);
Add(outputs, [[1,1], [2,1], [2,2]]);
m := FRMachineNC(FRMFamily([1..2]), f, transitions[7], outputs[7]);
Add(mm[7], m);
m := FRMachine([[[1], [3]], [[2], []], [[2], [1]]], [Trans([1,1]), (1,2), Trans([2,2])]);
Add(mm[7], m);
m := FRMachine(["z","y","x"], [[[1], [3]], [[2], []], [[2], [1]]], [Trans([1,1]), (1,2), Trans([2,2])]);
Add(mm[7], m);
m := FRMachine(f, [[f.1, f.3], [f.2, One(f)], [f.2, f.1]], [[1,1], (1,2), [2,2]]);
Add(mm[7], m);

f := FreeSemigroup(4);
m := FRMachineNC(FRMFamily([1..2]), f, [[f.1, f.1], [f.2, f.4], [f.3, f.1], [f.3, f.2]], [[1,2], [1,1], [2,1], [2,2]]);
Add(msu[7], m);
m := FRMachine([[[1], [1]], [[2], [4]], [[3], [1]], [[3], [2]]], [(), Trans([1,1]), (1,2), Trans([2,2])]);
Add(msu[7], m);
m := FRMachine(["z","y","x","1"], [[[1], [1]], [[2], [4]], [[3], [1]], [[3], [2]]], [(), Trans([1,1]), (1,2), Trans([2,2])]);
Add(msu[7], m);
m := FRMachine(f, [[f.1, f.1], [f.2, f.4], [f.3, f.1], [f.3, f.2]], [(), Trans([1,1]), (1,2), Trans([2,2])]);
Add(msu[7], m);

# m8 : a miscellaneous SemigroupFRMachine on a 7-ary tree

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);

f := FreeMonoid(2);
Add(transitions, [[f.1,f.2,f.1,f.2,f.1,f.2,f.1],[f.2,f.2,f.1,f.2,f.1,f.1,f.2]]);
Add(outputs, [[2,5,4,7,7,4,3],[3,1,6,7,4,7,1]]);
m := FRMachineNC(FRMFamily([1..7]), f, transitions[8], outputs[8]);
Add(mm[8], m);
m := FRMachine([[[1],[2],[1],[2],[1],[2],[1]],[[2],[2],[1],[2],[1],[1],[2]]], [Trans([2,5,4,7,7,4,3]),Trans([3,1,6,7,4,7,1])]);
Add(mm[8], m);
m := FRMachine(["a","b"],[[[1],[2],[1],[2],[1],[2],[1]],[[2],[2],[1],[2],[1],[1],[2]]], [Trans([2,5,4,7,7,4,3]),Trans([3,1,6,7,4,7,1])]);
Add(mm[8], m);
m := FRMachine(f, [[f.1,f.2,f.1,f.2,f.1,f.2,f.1],[f.2,f.2,f.1,f.2,f.1,f.1,f.2]], [[2,5,4,7,7,4,3],[3,1,6,7,4,7,1]]);
Add(mm[8], m);

f := FreeSemigroup(2);
m := FRMachineNC(FRMFamily([1..7]), f, [[f.1,f.2,f.1,f.2,f.1,f.2,f.1],[f.2,f.2,f.1,f.2,f.1,f.1,f.2]], [[2,5,4,7,7,4,3],[3,1,6,7,4,7,1]]);
Add(ms[8], m);
m := FRMachine(f, [[f.1,f.2,f.1,f.2,f.1,f.2,f.1],[f.2,f.2,f.1,f.2,f.1,f.1,f.2]], [[2,5,4,7,7,4,3],[3,1,6,7,4,7,1]]);
Add(ms[8], m);

f := FreeSemigroup(3);
m := FRMachineNC(FRMFamily([1..7]), f, [[f.1,f.2,f.1,f.2,f.1,f.2,f.1],[f.2,f.2,f.1,f.2,f.1,f.1,f.2],ListWithIdenticalEntries(7,f.3)], [[2,5,4,7,7,4,3],[3,1,6,7,4,7,1],[1,2,3,4,5,6,7]]);
Add(msu[8], m);
m := FRMachine(f, [[f.1,f.2,f.1,f.2,f.1,f.2,f.1],[f.2,f.2,f.1,f.2,f.1,f.1,f.2],ListWithIdenticalEntries(7,f.3)], [Trans([2,5,4,7,7,4,3]),Trans([3,1,6,7,4,7,1]),()]);
Add(msu[8], m);

# m9 : a non-Mealy SemigroupFRMachine

Add(mg, []);
Add(mm, []);
Add(ms, []);
Add(mmi, []);
Add(msiu, []);
Add(msu, []);

f := FreeMonoid(2);
Add(transitions, [[f.1^2,f.2^3*f.1,f.2],[f.1,f.1^7,f.1^2*f.2^2*f.1]]);
Add(outputs, [[3,2,2],[2,1,3]]);
m := FRMachineNC(FRMFamily([1..3]), f, transitions[9], outputs[9]);
Add(mm[9], m);
m := FRMachine([[[1,1],[2,2,2,1],[2]],[[1],[1,1,1,1,1,1,1],[1,1,2,2,1]]],[Trans([3,2,2]),(1,2)]);
Add(mm[9], m);
m := FRMachine(["a1","a2"],[[[1,1],[2,2,2,1],[2]],[[1],[1,1,1,1,1,1,1],[1,1,2,2,1]]],[[3,2,2],(1,2)]);
Add(mm[9], m);
m := FRMachine(f, [[f.1^2,f.2^3*f.1,f.2],[f.1,f.1^7,f.1^2*f.2^2*f.1]],[[3,2,2],(1,2)]);
Add(mm[9], m);

f := FreeSemigroup(2);
m := FRMachineNC(FRMFamily([1..3]), f, [[f.1^2,f.2^3*f.1,f.2],[f.1,f.1^7,f.1^2*f.2^2*f.1]],[[3,2,2],[2,1,3]]);
Add(ms[9], m);
m := FRMachine(f, [[f.1^2,f.2^3*f.1,f.2],[f.1,f.1^7,f.1^2*f.2^2*f.1]],[Trans([3,2,2]),(1,2)]);
Add(ms[9], m);

f := FreeSemigroup(3);
m := FRMachineNC(FRMFamily([1..3]), f, [[f.1^2,f.2^3*f.1,f.2],[f.1,f.1^7,f.1^2*f.2^2*f.1],[f.3,f.3,f.3]], [[3,2,2],[2,1,3],[1,2,3]]);
Add(msu[9], m);
m := FRMachine(f, [[f.1^2,f.2^3*f.1,f.2],[f.1,f.1^7,f.1^2*f.2^2*f.1],[f.3,f.3,f.3]],[[3,2,2],(1,2),()]);
Add(msu[9], m);

#E frmachines.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here