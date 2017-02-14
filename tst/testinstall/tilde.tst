gap> START_TEST("tilde.tst");
gap> aqq~ := 1;
Error, Variable: 'aqq' must have a value
Syntax error: ; expected in stream:1
aqq~ := 1;
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
gap> f := function(~) local a; end;
Syntax error: ~ is not a valid name for an argument in stream:1
f := function(~) local a; end;
              ^
gap> f := function(a,~) local a; end;
Syntax error: ~ is not a valid name for an argument in stream:1
f := function(a,~) local a; end;
                ^
gap> f := function(a,b) local ~; end;
Syntax error: ~ is not a valid name for a local identifier in stream:1
f := function(a,b) local ~; end;
                         ^
gap> f := function(a,b) local x,~; end;
Syntax error: ~ is not a valid name for a local identifier in stream:1
f := function(a,b) local x,~; end;
                           ^
gap> {~} -> ~;
Syntax error: ~ is not a valid name for an argument in stream:1
{~} -> ~;
 ^
gap> {~,~} -> 2;
Syntax error: ~ is not a valid name for an argument in stream:1
{~,~} -> 2;
 ^
gap> ({} -> ~);
function(  ) ... end
gap> STOP_TEST( "tilde.tst", 1);
