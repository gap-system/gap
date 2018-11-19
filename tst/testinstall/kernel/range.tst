#
# Tests for functions defined in src/set.c
#
gap> START_TEST("kernel/set.tst");

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
gap> STOP_TEST("kernel/set.tst", 1);
