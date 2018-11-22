gap> START_TEST("EmptyPlist.tst");

#
gap> EmptyPlist(-1);
Error, EmptyPlist: <len> must be a non-negative small integer (not the integer\
 -1)
gap> EmptyPlist(-(2^100));
Error, EmptyPlist: <len> must be a non-negative small integer (not a large neg\
ative integer)
gap> EmptyPlist( () );
Error, EmptyPlist: <len> must be a non-negative small integer (not a permutati\
on (small))
gap> EmptyPlist();
Error, Function: number of arguments must be 1 (not 0)
gap> EmptyPlist(2^100);
Error, EmptyPlist: <len> must be a non-negative small integer (not a large pos\
itive integer)
gap> l := EmptyPlist(10);
[  ]
gap> l = EmptyPlist(0);
true
gap> l = [];
true
gap> l[5] := 5;;
gap> l;
[ ,,,, 5 ]
gap> l[12] := 2;;
gap> l;
[ ,,,, 5,,,,,,, 2 ]

#
gap> STOP_TEST("EmptyPlist.tst", 1);
