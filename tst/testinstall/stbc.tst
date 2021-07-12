#@local sc
gap> START_TEST("stbc.tst");

#
gap> StabChainBaseStrongGenerators([1]);
Error, usage: StabChainBaseStrongGenerators(<base>, <sgs>[, <one>])
gap> StabChainBaseStrongGenerators([1], [()], fail, fail);
Error, usage: StabChainBaseStrongGenerators(<base>, <sgs>[, <one>])
gap> StabChainBaseStrongGenerators([1], []);
Error, the identity element must be given as the third argument when the secon\
d argument <sgs> is empty
gap> sc := StabChainBaseStrongGenerators([1], [], ());
<stabilizer chain record, Base [ 1 ], Orbit length 1, Size: 1>
gap> IsTrivial(GroupStabChain(sc));
true
gap> sc := StabChainBaseStrongGenerators([1 .. 4], [(1,2), (2,3), (3,4)]);
<stabilizer chain record, Base [ 1, 2, 3, 4 ], Orbit length 4, Size: 24>
gap> sc = StabChainBaseStrongGenerators([1 .. 4], [(1,2), (2,3), (3,4)], ());
true
gap> GroupStabChain(sc) = SymmetricGroup(4);
true

#
gap> STOP_TEST("stbc.tst", 1);
