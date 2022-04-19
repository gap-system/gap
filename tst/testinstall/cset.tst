#############################################################################
##
##  test of group intersection and RightCoset
##
gap> START_TEST("cset.tst");

# test intersecting symmetric and alternating groups (has special code)
gap> Intersection(SymmetricGroup([1..5]),SymmetricGroup([3..8]));
Sym( [ 3 .. 5 ] )
gap> Intersection(SymmetricGroup([1..5]),AlternatingGroup([3..8]));
Alt( [ 3 .. 5 ] )
gap> Intersection(AlternatingGroup([1..5]),AlternatingGroup([3..8]));
Alt( [ 3 .. 5 ] )
gap> Intersection(AlternatingGroup([1..5]),SymmetricGroup([3..8]));
Alt( [ 3 .. 5 ] )

# test intersecting permutation groups
gap> Intersection(Group( (1,2,3), (4,5,6), (11,12,13), (11,12,14) ),
>                 Group( (1,7,8), (4,9,11), (10,12), (13,14) ));
Group(())
gap> Intersection(Group((1,2), (3,4)), Group((3,4),(5,6)));
Group([ (3,4) ])

# basic coset tests
gap> RightCoset(Group([(1,2,3),(2,3,4)]), (1,2)) = RightCoset(Group([(1,2,3),(2,3,4)]), (2,3));
true
gap> () in RightCoset(Group([(1,2,3,4)]), (1,2));
false
gap> (1,2) in RightCoset(SymmetricGroup(12), (5,6));
true
gap> Length(RightCosets(SymmetricGroup(5), AlternatingGroup(4)));
10
gap> RightCoset(AlternatingGroup(4), ()) * (1,2,3) = RightCoset(AlternatingGroup(4), ());
true
gap> IsBiCoset(RightCoset(AlternatingGroup(6), (1,2)));
true
gap> IsBiCoset(RightCoset(AlternatingGroup(6), (1,7)));
false
gap> IsRightCoset(RightCoset(MathieuGroup(12), (1,2,3)));
true

# test intersecting cosets
gap> Intersection(RightCoset(Group([ (1,2,3,4,5,6,7), (5,6,7) ]),(3,6)(4,7)),
>                 RightCoset(Group([ (1,2,3,4,5,6,8), (1,3,2,6,4,5), (1,6)(2,3)(4,5)(7,8) ]),(1,7,6,8,3,5)));
RightCoset(Group([ (2,6,7)(3,5,4), (1,2,4)(3,6,5) ]),(1,3,7,5)(4,6))
gap> Intersection(RightCoset(Group([ (1,4)(2,5), (1,3,5)(2,4,6), (1,5)(2,4)(3,6) ]),(1,7,6,5)(3,4,8)),
>                 RightCoset(Group([ (3,4), (5,6,7,8), (5,6) ]),(1,8,6,2)(3,7)));
RightCoset(Group(()),(1,8,3,4,7,6,5,2))
gap> Intersection(RightCoset(Group([ [ [ -1, 0 ], [ 0, 1 ] ], [ [ 0, 1 ], [ 1, 0 ] ] ]), IdentityMat(2)),
>                 RightCoset(Group([ [ [ -1, 0 ], [ 0, -1 ] ] ]),[[0,1],[1,0]]));
RightCoset(<group of size 2 with 1 generators>,
<matrix object of dimensions 2x2 over Integers>)

#
gap> STOP_TEST("cset.tst", 1);
