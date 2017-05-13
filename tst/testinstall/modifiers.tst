#############################################################################
##
#W  modifiers.tst                GAP Library
##
##
gap> START_TEST("modifiers.tst");
gap> x := rec();
rec(  )
gap> x.2 := 3;
3
gap> x;
rec( 2 := 3 )
gap> x.2 := rec();
rec(  )
gap> x.2.3 := 5;
5
gap> x;
rec( 2 := rec( 3 := 5 ) )
gap> x.f := {} -> rec();
function(  ) ... end
gap> x;
rec( 2 := rec( 3 := 5 ), f := function(  ) ... end )
gap> x.f().q := 6;
6
gap> y := [];
[  ]
gap> x := rec( a := 3 );
rec( a := 3 )
gap> 1 + x.a;
4
gap> x.f := {} -> [4];
function(  ) ... end
gap> 4 + x.f()[1];
8
gap> x.f()[1];
4
gap> l := [[1,2,3],[4,5,6],[7,8,9]];;
gap> Print(l{[2..3]}{[2..3]},"\n");
[ [ 5, 6 ], [ 8, 9 ] ]
gap> STOP_TEST( "modifiers.tst", 1);
