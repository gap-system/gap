#############################################################################
##
##  test of group intersection and RightCoset
##
gap> START_TEST("cset.tst");

# helper
gap> TestIntersection := function(A, B)
>      local C;
>      C := Intersection(A,B);
>      Assert(0, Intersection(AsSet(A),AsSet(B)) = AsSet(C));
>      return C;
>    end;;

# test intersecting symmetric and alternating groups (has special code)
gap> TestIntersection(SymmetricGroup([1..5]),SymmetricGroup([3..8]));
Sym( [ 3 .. 5 ] )
gap> TestIntersection(SymmetricGroup([1..5]),AlternatingGroup([3..8]));
Alt( [ 3 .. 5 ] )
gap> TestIntersection(AlternatingGroup([1..5]),AlternatingGroup([3..8]));
Alt( [ 3 .. 5 ] )
gap> TestIntersection(AlternatingGroup([1..5]),SymmetricGroup([3..8]));
Alt( [ 3 .. 5 ] )

# test intersecting permutation groups
gap> TestIntersection(Group( (1,2,3), (4,5,6), (11,12,13), (11,12,14) ),
>                 Group( (1,7,8), (4,9,11), (10,12), (13,14) ));
Group(())
gap> TestIntersection(Group((1,2), (3,4)), Group((3,4),(5,6)));
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
>    TestIntersection(RightCoset(Group([ (1,2,3,4,5,6,7), (5,6,7) ]),(3,6)(4,7)),
>                 RightCoset(Group([ (1,2,3,4,5,6,8), (1,3,2,6,4,5), (1,6)(2,3)(4,5)(7,8) ]),(1,7,6,8,3,5)));
true
gap> RightCoset(Group(()),(1,8,3,4,7,6,5,2)) =
>    TestIntersection(RightCoset(Group([ (1,4)(2,5), (1,3,5)(2,4,6), (1,5)(2,4)(3,6) ]),(1,7,6,5)(3,4,8)),
>                 RightCoset(Group([ (3,4), (5,6,7,8), (5,6) ]),(1,8,6,2)(3,7)));
true
gap> [] = TestIntersection(RightCoset(SymmetricGroup(4), ()), RightCoset(SymmetricGroup([3..6]), (4,7)));
true
gap> [] = TestIntersection(RightCoset(Group([(1,2,3,4,5)]),(4,5)), RightCoset(AlternatingGroup(4),()));
true
gap> RightCoset(SymmetricGroup([3..5]), (7,9)) =
>    TestIntersection(RightCoset(SymmetricGroup(5), (1,2)(7,9)),
>                 RightCoset(SymmetricGroup([3..7]), (7,9)));
true
gap> [] = TestIntersection(RightCoset(Group([(1,2,3,4,5)]),(1,4)(3,5)), RightCoset(SymmetricGroup(3),()));
true
gap> RightCoset(Group([(5,6)]),(4,5)) =
>    TestIntersection(RightCoset(SymmetricGroup(6), ()),
>                 RightCoset(SymmetricGroup([5..8]), (4,5)));
true
gap> RightCoset(SymmetricGroup(5), (1,4,5)) =
>    TestIntersection(RightCoset(SymmetricGroup(5), ()),
>                 RightCoset(SymmetricGroup(5), (1,2)));
true
gap> [] =
>    TestIntersection(RightCoset(Group((1,2,3,4,5)), (1,2)),
>                 RightCoset(Group((1,2,3,5,4)), ()));
true
gap> [] =
>    TestIntersection(RightCoset(Group((1,2,3,4,5)), (1,2,3)),
>                 RightCoset(Group((1,2,3,5,4)), ()));
true
gap> RightCoset(Group([ (1,2,3,5,4) ]),(1,2)) =
>    TestIntersection(RightCoset(SymmetricGroup(7), ()),
>                 RightCoset(Group((1,2,3,5,4)), (1,2)));
true
gap> [] =
>    TestIntersection(RightCoset(SymmetricGroup([3..7]), ()),
>                 RightCoset(Group((1,2,3,5,4)), (1,2)));
true
gap> [] = TestIntersection(
>    RightCoset(Group( [ (1,10)(3,12)(4,7)(6,9), (1,7)(3,9)(4,10)(6,12), (1,5,9)(2,6,10)(3,7,11)(4,8,12) ] ),(1,3,10,7,9,5,6,8,2,12)(4,11)),
>    RightCoset(Group( [ (3,12)(6,9), (3,9)(6,12), (1,7)(2,8)(6,12), (1,6,2)(3,11,4)(5,10,9)(7,12,8), (1,2)(4,11)(5,10)(7,8) ] ), (2,9,7,5,11,8,10)(4,12,6)));
true
gap> [] = TestIntersection(RightCoset(Group( [ (1,4)(2,5), (1,3,5)(2,4,6) ] ),(1,6,3)), RightCoset(Group( [ (1,5,2,3,6) ] ),(1,6,5,3,2)));
true
gap> [] = TestIntersection(
>    RightCoset(Group( [ (1,3,5,7,9)(2,4,6,8,10), (1,2)(3,7)(8,9) ] ),(1,2,12)(3,10,8,11,9,4,5,6)),
>    RightCoset(Group( [ (3,12,11), (5,8)(11,12), (1,11)(2,12)(3,9)(4,5)(6,8)(7,10), (1,6)(2,4)(5,7)(9,10) ] ),(1,12,9,5,10,2,6,4,3,11)(7,8)));
true

# test trivial cases
gap> TestIntersection(RightCoset(Group([],()), ()), RightCoset(Group([],()), (1,2))) = [];
true
gap> TestIntersection(RightCoset(Group((1,2,3)), ()), RightCoset(Group((1,2,3)), (1,2))) = [];
true
gap> TestIntersection(RightCoset(AlternatingGroup(6), ()), RightCoset(AlternatingGroup(6),(1,2))) = [];
true
gap> TestIntersection(RightCoset(AlternatingGroup([1..5]), (1,2)), RightCoset(AlternatingGroup([6..10]), (1,2))) = RightCoset(Group(()), (1,2));
true

# test intersection non-permutation cosets
gap> RightCoset(Group([ [ [ -1, 0 ], [ 0, -1 ] ] ]),[[0,1],[1,0]]) =
>    TestIntersection(RightCoset(Group([ [ [ -1, 0 ], [ 0, 1 ] ], [ [ 0, 1 ], [ 1, 0 ] ] ]), IdentityMat(2)),
>                 RightCoset(Group([ [ [ -1, 0 ], [ 0, -1 ] ] ]),[[0,1],[1,0]]));
true
gap> RightCoset(Group([-IdentityMat(2)]),[[0,1],[1,0]]) =
>    TestIntersection(RightCoset(Group([-IdentityMat(2)]),[[0,-1],[-1,0]]),
>                 RightCoset(Group([-IdentityMat(2)]),[[0,1],[1,0]]));
true
gap> [] = TestIntersection(RightCoset(Group([-IdentityMat(2)]),[[0,1],[1,0]]),
>                      RightCoset(Group([-IdentityMat(2)]),[[2,1],[1,2]]));
true
gap> matcyc := CyclicGroup(IsMatrixGroup, GF(3), 2);;
gap> [] = TestIntersection(RightCoset(matcyc, [[0*Z(3), Z(3)], [Z(3), Z(3)^0]]),
>                      RightCoset(matcyc, [[Z(3), Z(3)], [Z(3), 0*Z(3)]] ) );
true
gap> RightCoset(matcyc, [[0*Z(3), Z(3)], [Z(3), Z(3)^0]]) =
>      TestIntersection(RightCoset(matcyc, [[0*Z(3), Z(3)], [Z(3), Z(3)^0]]),
>                   RightCoset(matcyc, [[Z(3), Z(3)^0], [0*Z(3), Z(3)]] ) );
true
gap> rc1 := RightCoset(Group( [[0*Z(3), Z(3)], [Z(3), 0*Z(3)]], [[Z(3), Z(3)], [Z(3)^0, 0*Z(3)]],
>   [[Z(3), 0*Z(3)], [0*Z(3), Z(3)]] ), [[Z(3), Z(3)^0], [Z(3)^0, Z(3)^0]]);;
gap> rc2 := RightCoset(Group( [[Z(3), Z(3)], [0*Z(3), Z(3)^0]], [[0*Z(3), Z(3)], [Z(3)^0, 0*Z(3)]],
>   [[Z(3), Z(3)], [Z(3), Z(3)^0]], [[Z(3), 0*Z(3)], [0*Z(3), Z(3)]]), [[0*Z(3), Z(3)], [Z(3)^0, Z(3)]]);;
gap> RightCoset(Group( [[Z(3), Z(3)], [0*Z(3), Z(3)^0]], [[Z(3)^0, Z(3)^0], [0*Z(3), Z(3)]] ),[[0*Z(3), Z(3)^0], [Z(3), Z(3)^0]]) =
>      TestIntersection(rc1, rc2);
true
gap> [] = TestIntersection(RightCoset(matcyc, One(matcyc)), rc1);
true
gap> RightCoset(Group( [ [ Z(3)^0, 0*Z(3) ], [ 0*Z(3), Z(3)^0 ] ] ),
> [ [ 0*Z(3), Z(3)^0 ], [ Z(3)^0, 0*Z(3) ] ]) = TestIntersection(RightCoset(matcyc, One(matcyc)), rc2);
true

#
gap> STOP_TEST("cset.tst", 1);
