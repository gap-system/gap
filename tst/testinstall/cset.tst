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

# test intersecting permutation cosets
gap> RightCoset(Group([ (), (2,7,6)(3,4,5), (1,2,7,5,6,4,3) ]),(1,3,7,5)(4,6)) =
>    Intersection(RightCoset(Group([ (1,2,3,4,5,6,7), (5,6,7) ]),(3,6)(4,7)),
>                 RightCoset(Group([ (1,2,3,4,5,6,8), (1,3,2,6,4,5), (1,6)(2,3)(4,5)(7,8) ]),(1,7,6,8,3,5)));
true
gap> RightCoset(Group(()),(1,8,3,4,7,6,5,2)) =
>    Intersection(RightCoset(Group([ (1,4)(2,5), (1,3,5)(2,4,6), (1,5)(2,4)(3,6) ]),(1,7,6,5)(3,4,8)),
>                 RightCoset(Group([ (3,4), (5,6,7,8), (5,6) ]),(1,8,6,2)(3,7)));
true
gap> [] = Intersection(RightCoset(SymmetricGroup(4), ()), RightCoset(SymmetricGroup([3..6]), (4,7)));
true
gap> [] = Intersection(RightCoset(Group([(1,2,3,4,5)]),(4,5)), RightCoset(AlternatingGroup(4),()));
true
gap> RightCoset(SymmetricGroup(5), (7,9)) =
>    Intersection(RightCoset(SymmetricGroup(5), (1,2)(7,9)),
>                 RightCoset(SymmetricGroup([3..7]), (7,9)));
true
gap> [] = Intersection(RightCoset(Group([(1,2,3,4,5)]),(1,4)(3,5)), RightCoset(SymmetricGroup(3),()));
true
gap> RightCoset(Group([(5,6)]),(4,5)) =
>    Intersection(RightCoset(SymmetricGroup(6), ()),
>                 RightCoset(SymmetricGroup([5..8]), (4,5)));
true


# test trivial cases
gap> Intersection(RightCoset(Group([],()), ()), RightCoset(Group([],()), (1,2))) = [];
true
gap> Intersection(RightCoset(Group((1,2,3)), ()), RightCoset(Group((1,2,3)), (1,2))) = [];
true
gap> Intersection(RightCoset(AlternatingGroup(6), ()), RightCoset(AlternatingGroup(6),(1,2))) = [];
true
gap> Intersection(RightCoset(AlternatingGroup([1..5]), (1,2)), RightCoset(AlternatingGroup([6..10]), (1,2))) = RightCoset(Group(()), (1,2));
true

# test intersection non-permutation cosets
gap> RightCoset(Group([ [ [ -1, 0 ], [ 0, -1 ] ] ]),[[0,1],[1,0]]) =
>    Intersection(RightCoset(Group([ [ [ -1, 0 ], [ 0, 1 ] ], [ [ 0, 1 ], [ 1, 0 ] ] ]), IdentityMat(2)),
>                 RightCoset(Group([ [ [ -1, 0 ], [ 0, -1 ] ] ]),[[0,1],[1,0]]));
true
gap> RightCoset(Group([-IdentityMat(2)]),[[0,1],[1,0]]) =
>    Intersection(RightCoset(Group([-IdentityMat(2)]),[[0,-1],[-1,0]]) =
>                 RightCoset(Group([-IdentityMat(2)]),[[0,1],[1,0]]));
true
gap> [] = Intersection(RightCoset(Group([-IdentityMat(2)]),[[0,1],[1,0]]) =
>                      RightCoset(Group([-IdentityMat(2)]),[[2,1],[1,2]]));
true
gap> matcyc := CyclicGroup(IsMatrixGroup, GF(3), 2);;
gap> [] = Intersection(RightCoset(matcyc, [[0*Z(3), Z(3)], [Z(3), Z(3)^0]]),
>                      RightCoset(matcyc, [[Z(3), Z(3)], [Z(3), 0*Z(3)]] ) );
true
gap> RightCoset(matcyc, [[0*Z(3), Z(3)], [Z(3), Z(3)^0]]) =
>      Intersection(RightCoset(matcyc, [[0*Z(3), Z(3)], [Z(3), Z(3)^0]]),
>                   RightCoset(matcyc, [[Z(3), Z(3)^0], [0*Z(3), Z(3)]] ) );
true
gap> rc1 := RightCoset(Group( [[0*Z(3), Z(3)], [Z(3), 0*Z(3)]], [[Z(3), Z(3)], [Z(3)^0, 0*Z(3)]],
>   [[Z(3), 0*Z(3)], [0*Z(3), Z(3)]] ), [[Z(3), Z(3)^0], [Z(3)^0, Z(3)^0]]);;
gap> rc2 := RightCoset(Group( [[Z(3), Z(3)], [0*Z(3), Z(3)^0]], [[0*Z(3), Z(3)], [Z(3)^0, 0*Z(3)]],
>   [[Z(3), Z(3)], [Z(3), Z(3)^0]], [[Z(3), 0*Z(3)], [0*Z(3), Z(3)]]), [[0*Z(3), Z(3)], [Z(3)^0, Z(3)]]);;
gap> RightCoset(Group( [[Z(3), Z(3)], [0*Z(3), Z(3)^0]], [[Z(3)^0, Z(3)^0], [0*Z(3), Z(3)]] ),[[0*Z(3), Z(3)^0], [Z(3), Z(3)^0]]) =
>      Intersection(rc1, rc2);
true
gap> [] = Intersection(RightCoset(matcyc, One(matcyc)), rc1);
true
gap> RightCoset(Group( [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ),
> [ [ 0*Z(3), Z(3)^0 ], [ Z(3)^0, 0*Z(3) ] ]) = Intersection(RightCoset(matcyc, One(matcyc)), rc2);
true

#
gap> STOP_TEST("cset.tst", 1);
