#@local aqq,bool,f,l,r,l2,r2,l3,r3,list1,list2,rec1,rec2,rem,i
gap> START_TEST("tilde.tst");

#
gap> aqq~ := 1;
Error, Variable: 'aqq' must have an assigned value
Syntax error: ; expected in stream:1
aqq~ := 1;
   ^

#
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

#
gap> [ ~ ];
[ ~ ]
gap> [ 1, 2, [0 .. Length(~)] ];
[ 1, 2, [ 0 .. 2 ] ]
gap> [0, 1 + ~, 2 ];
[ 0, [ 1 ], 2 ]

#
# Test viewing of nested self-referential lists and records
# (involves kernel vars PrintObjDepth, PrintObjIndex, ...)
#
gap> l := [ ~ ];
[ ~ ]
gap> r := rec(a:=~);
rec( a := ~ )
gap> l2 := [l, r];
[ [ ~[1] ], rec( a := ~[2] ) ]
gap> r2 := rec(l:=l, r:=r);
rec( l := [ ~.l ], r := rec( a := ~.r ) )
gap> l3 := [ l2, r2 ];
[ [ [ ~[1][1] ], rec( a := ~[1][2] ) ], 
  rec( l := [ ~[2].l ], r := rec( a := ~[2].r ) ) ]
gap> r3:= rec( a:= l2, b := r2 );
rec( a := [ [ ~.a[1] ], rec( a := ~.a[2] ) ], 
  b := rec( l := [ ~.b.l ], r := rec( a := ~.b.r ) ) )

# now also test printing
gap> Print(l, "\n");
[ ~ ]
gap> Print(l2, "\n");
[ [ ~[1] ], rec(
      a := ~[2] ) ]
gap> Print(l3, "\n");
[ [ [ ~[1][1] ], rec(
          a := ~[1][2] ) ], rec(
      l := [ ~[2].l ],
      r := rec(
          a := ~[2].r ) ) ]
gap> Print(r, "\n");
rec(
  a := ~ )
gap> Print(r2, "\n");
rec(
  l := [ ~.l ],
  r := rec(
      a := ~.r ) )
gap> Print(r3, "\n");
rec(
  a := [ [ ~.a[1] ], rec(
          a := ~.a[2] ) ],
  b := rec(
      l := [ ~.b.l ],
      r := rec(
          a := ~.b.r ) ) )

#
gap> [ (x->~)(1) ];
[ ~ ]
gap> l := [ x->~ ];  # this function escapes with an invalid tilde reference
[ function( x ) ... end ]
gap> f := l[1];;
gap> f(1);
Error, '~' does not have a value here
gap> [ f(1) ];
[ ~ ]

#
gap> ~;
Syntax error: '~' not allowed here in stream:1
~;
^
gap> (1,~);
Syntax error: '~' not allowed here in stream:1
(1,~);
   ^
gap> x->~;
Syntax error: '~' not allowed here in stream:1
x->~;
   ^
gap> x -> (1,~);
Syntax error: '~' not allowed here in stream:1
x -> (1,~);
        ^

#
gap> [1..~];
Syntax error: Sorry, '~' not allowed in range in stream:1
[1..~];
     ^
gap> [~..1];
Syntax error: Sorry, '~' not allowed in range in stream:1
[~..1];
     ^
gap> [1,~..5];
Syntax error: Sorry, '~' not allowed in range in stream:1
[1,~..5];
       ^
gap> x->[1..~];
Syntax error: Sorry, '~' not allowed in range in stream:1
x->[1..~];
        ^
gap> x->[~..1];
Syntax error: Sorry, '~' not allowed in range in stream:1
x->[~..1];
        ^
gap> x->[1,~..5];
Syntax error: Sorry, '~' not allowed in range in stream:1
x->[1,~..5];
          ^

#
gap> f := function(~) local a; end;
Syntax error: identifier expected in stream:1
f := function(~) local a; end;
              ^
gap> f := function(a,~) local a; end;
Syntax error: identifier expected in stream:1
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

#
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
gap> i := InputTextString( "local a; a := 10; return rec(a := a*10, b := ~);" );;
gap> r := rec(a := ~, b := ReadAsFunction(i)(), c := ~.b.a);
rec( a := ~, b := rec( a := 100, b := ~.b ), c := 100 )
gap> [Length(~),Length(~),Length(~)];
[ 0, 1, 2 ]
gap> (function() return [Length(~),Length(~),Length(~)]; end)();
[ 0, 1, 2 ]
gap> rem := function(l) Remove(l); return 1; end;;
gap> [2,rem(~),rem(~),rem(~)];
[ ,,, 1 ]
gap> [2,rem(~),3,4,rem(~),5,6,rem(~)];
[ , 1, 3,, 1, 5,, 1 ]
gap> (function() return  [2,rem(~),3,4,rem(~),5,6,rem(~)]; end)();
[ , 1, 3,, 1, 5,, 1 ]

#
gap> STOP_TEST( "tilde.tst", 1);
