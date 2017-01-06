gap> START_TEST("tilde.tst");
gap> aqq~ := 1;
Error, Variable: 'aqq' must have a value
Syntax error: ; expected in stream:1
aqq~ := 1;
   ^
gap> ~a := 1;
Error, Variable: '~' must have a value
Syntax error: ; expected in stream:1
~a := 1;
 ^
gap> ~ := 1;
Error, '~' cannot be assigned
gap> l := [2, ~];
[ 2, ~ ]
gap> l = l[2];
true
gap> r := rec(x := ~, y := [1,2,~]);
rec( x := ~, y := [ 1, 2, ~ ] )
gap> r.x;
rec( x := ~, y := [ 1, 2, ~ ] )
gap> r.y;
[ 1, 2, rec( x := ~[3], y := ~ ) ]
gap> r.x;
rec( x := ~, y := [ 1, 2, ~ ] )
gap> r.y[3];
rec( x := ~, y := [ 1, 2, ~ ] )
gap> STOP_TEST( "tilde.tst", 1);
