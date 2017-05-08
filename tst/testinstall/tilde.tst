gap> START_TEST("tilde.tst");
gap> aqq~ := 1;
Error, Variable: 'aqq' must have a value
Syntax error: ; expected in stream:1
aqq~ := 1;
   ^
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
Syntax error: identifier expected in stream:1
f := function(~) local a; end;
              ^
gap> f := function(a,~) local a; end;
Syntax error: Expect identifier in stream:1
f := function(a,~) local a; end;
                ^
gap> f := function(a,b) local ~; end;
Syntax error: identifier expected in stream:1
f := function(a,b) local ~; end;
                         ^
gap> f := function(a,b) local x,~; end;
Syntax error: identifier expected in stream:1
f := function(a,b) local x,~; end;
                           ^
gap> {~} -> ~;
Syntax error: identifier expected in stream:1
{~} -> ~;
 ^
gap> {~,~} -> 2;
Syntax error: identifier expected in stream:1
{~,~} -> 2;
 ^
gap> list1 := [1,~];
[ 1, ~ ]
gap> list2 := [1,[1,[1,[1,0]]]];
[ 1, [ 1, [ 1, [ 1, 0 ] ] ] ]
gap> f := function(a) local y; y := [1,~,a]; return y; end;;
gap> f(2);
[ 1, ~, 2 ]
gap> f(2)[2];
[ 1, ~, 2 ]
gap> f := function(a) local y; y := rec( x := 1 ,y := ~, z := a); return y; end;;
gap> f(2);
rec( x := 1, y := ~, z := 2 )
gap> f(2).y;
rec( x := 1, y := ~, z := 2 )

# Check that the RecursionDepth counter in the kernel is incremented and
# decremented correctly. If it isn't decremented correctly, then it will
# eventually exceed the `RecursionTrapInterval` (which normally is
# 5000), and the test will fail due to an unexpected error message.
gap> ForAny([1..10000], x -> (list1 = list2));
false
gap> ForAny([1..10000], x -> (list1 < list2));
false
gap> ForAny([1..10000], x -> (list1 <= list2));
false
gap> ForAll([1..10000], x -> (list1 <> list2));
true
gap> rec1 := rec( x := ~ );
rec( x := ~ )
gap> rec2 := rec( x := rec( x := rec( x := rec( x := rec( x := rec() ) ) ) ) );
rec( x := rec( x := rec( x := rec( x := rec( x := rec(  ) ) ) ) ) )
gap> ForAny([1..10000], q -> (rec1 = rec2));
false
gap> ForAll([1..10000], q -> (rec1 <> rec2));
true

# This can be different every time GAP starts
gap> bool := (rec1 < rec2);;
gap> ForAll([1..10000], q -> ( (rec1 < rec2) = bool) );
true
gap> STOP_TEST( "tilde.tst", 1);
