#
# Tests for functions defined in src/range.c
#
gap> START_TEST("kernel/range.tst");

#
# ElmsRange
#

# catch edge case: empty subrange is turned into a plist, and
# that should have the right TNUM
gap> TNAM_OBJ([1..10]{[]});
"empty plain list"

#
# UnbRange
#

# UnbRange on T_RANGE_SSORT with increment 1
gap> a := [1..5];
[ 1 .. 5 ]
gap> Unbind(a[6]); a;
[ 1 .. 5 ]
gap> Unbind(a[5]); a;
[ 1 .. 4 ]
gap> Unbind(a[1]); a;
[ , 2, 3, 4 ]

# UnbRange on T_RANGE_SSORT with increment 2
gap> a := [1,3..7];
[ 1, 3 .. 7 ]
gap> Unbind(a[6]); a;
[ 1, 3 .. 7 ]
gap> Unbind(a[5]); a;
[ 1, 3 .. 7 ]
gap> Unbind(a[1]); a;
[ , 3, 5, 7 ]

# UnbRange on T_RANGE_NSORT with increment 1
gap> a := [5,4..1];
[ 5, 4 .. 1 ]
gap> Unbind(a[6]); a;
[ 5, 4 .. 1 ]
gap> Unbind(a[5]); a;
[ 5, 4 .. 2 ]
gap> Unbind(a[1]); a;
[ , 4, 3, 2 ]

# UnbRange on T_RANGE_NSORT with increment 2
gap> a := [7,5..1];
[ 7, 5 .. 1 ]
gap> Unbind(a[6]); a;
[ 7, 5 .. 1 ]
gap> Unbind(a[5]); a;
[ 7, 5 .. 1 ]
gap> Unbind(a[1]); a;
[ , 5, 3, 1 ]

#
# INTER_RANGE
#
gap> a := [-10..10];; INTER_RANGE(a,[-10..10]); a;
[ -10 .. 10 ]
gap> a := [-10..10];; INTER_RANGE(a,[-11..10]); a;
[ -10 .. 10 ]
gap> a := [-10..10];; INTER_RANGE(a,[-10..11]); a;
[ -10 .. 10 ]
gap> a := [-10..10];; INTER_RANGE(a,[-11..9]); a;
[ -10 .. 9 ]
gap> a := [-10..10];; INTER_RANGE(a,[-9..11]); a;
[ -9 .. 10 ]
gap> a := [-10..10];; INTER_RANGE(a,[-21,-18..21]); a;
[ -9, -6 .. 9 ]
gap> a := [-10..10];; INTER_RANGE(a,[-6,-3..21]); a;
[ -6, -3 .. 9 ]
gap> a := [-10..10];; INTER_RANGE(a,[-21,-18..6]); a;
[ -9, -6 .. 6 ]
gap> a := [-10,-7..20];; INTER_RANGE(a,[-21,-18..6]); a;
[  ]
gap> a := [-9,-6..21];; INTER_RANGE(a,[-21,-18..6]); a;
[ -9, -6 .. 6 ]
gap> a := [-12,-10..20];; INTER_RANGE(a,[-21,-18..6]); a;
[ -12, -6 .. 6 ]
gap> a := [-15,-12..3];; INTER_RANGE(a,[-21,-18..6]); a;
[ -15, -12 .. 3 ]
gap> a := [-12,-9..3];; INTER_RANGE(a,[-21,-18..6]); a;
[ -12, -9 .. 3 ]
gap> a := [-9,-6..3];; INTER_RANGE(a,[-21,-18..6]); a;
[ -9, -6 .. 3 ]
gap> a := [-9,-3..3];; INTER_RANGE(a,[-21,-18..6]); a;
[ -9, -3 .. 3 ]
gap> a := [-9,-5..3];; INTER_RANGE(a,[-21,-18..6]); a;
[ -9, 3 ]

#
gap> INTER_RANGE(fail, fail);
Error, INTER_RANGE: <range1> must be a mutable range (not the value 'fail')
gap> INTER_RANGE([0..9], fail);
Error, INTER_RANGE: <range2> must be a range (not the value 'fail')
gap> r := MakeImmutable([0..9]);
[ 0 .. 9 ]
gap> INTER_RANGE(r, [-1..1]);
Error, INTER_RANGE: <range1> must be a mutable range (not a list (range,ssort,\
imm))
gap> r;
[ 0 .. 9 ]

#
gap> STOP_TEST("kernel/range.tst", 1);
