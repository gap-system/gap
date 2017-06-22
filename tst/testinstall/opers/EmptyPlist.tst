gap> EmptyPlist(-1);
Error, <len> must be a non-negative small integer
gap> EmptyPlist(-(2^100));
Error, <len> must be a non-negative small integer
gap> EmptyPlist( () );
Error, <len> must be a non-negative small integer
gap> EmptyPlist();
Error, Function: number of arguments must be 1 (not 0)
gap> EmptyPlist(2^100);
Error, <len> must be a non-negative small integer
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
