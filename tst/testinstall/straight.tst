#
gap> START_TEST("straight.tst");

##  IntegratedStraightLineProgram:
##  'prg0' returns an empty list,
##  'prg1' is overwriting and returns an element,
##  'prg2' is non-overwriting and returns an element,
##  'prg3' is overwriting and returns a nonempty list of elements.
##  Test all combinations of these programs.
##
gap> f:= FreeGroup( "x", "y" );;
gap> gens:= GeneratorsOfGroup( f );;
gap> prg0:= StraightLineProgram( [ [] ], 2 );;
gap> ResultOfStraightLineProgram( prg0, gens );
[  ]
gap> prg1:= StraightLineProgram( [ [ [ 1, 2 ], 1 ], [ 1, 2, 2, -1 ] ], 2 );;
gap> ResultOfStraightLineProgram( prg1, gens );
x^4*y^-1
gap> prg2:= StraightLineProgram( [ [ [ 2, 2 ], 3 ], [ 1, 3, 3, 2 ] ], 2 );;
gap> ResultOfStraightLineProgram( prg2, gens );
x^3*y^4
gap> prg3:= StraightLineProgram(
>               [ [ [ 2, 2 ], 2 ], [ [ 1, 1 ], [ 2, 1 ] ] ], 2 );;
gap> ResultOfStraightLineProgram( prg3, gens );
[ x, y^2 ]

##
gap> prg:= IntegratedStraightLineProgram( [ prg0, prg0 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[  ]
gap> prg:= IntegratedStraightLineProgram( [ prg0, prg1 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^4*y^-1 ]
gap> prg:= IntegratedStraightLineProgram( [ prg0, prg2 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^3*y^4 ]
gap> prg:= IntegratedStraightLineProgram( [ prg0, prg3 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x, y^2 ]
gap> prg:= IntegratedStraightLineProgram( [ prg1, prg0 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^4*y^-1 ]
gap> prg:= IntegratedStraightLineProgram( [ prg1, prg1 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^4*y^-1, x^4*y^-1 ]
gap> prg:= IntegratedStraightLineProgram( [ prg1, prg2 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^4*y^-1, x^3*y^4 ]
gap> prg:= IntegratedStraightLineProgram( [ prg1, prg3 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^4*y^-1, x, y^2 ]
gap> prg:= IntegratedStraightLineProgram( [ prg2, prg0 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^3*y^4 ]
gap> prg:= IntegratedStraightLineProgram( [ prg2, prg1 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^3*y^4, x^4*y^-1 ]
gap> prg:= IntegratedStraightLineProgram( [ prg2, prg2 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^3*y^4, x^3*y^4 ]
gap> prg:= IntegratedStraightLineProgram( [ prg2, prg3 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^3*y^4, x, y^2 ]
gap> prg:= IntegratedStraightLineProgram( [ prg3, prg0 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x, y^2 ]
gap> prg:= IntegratedStraightLineProgram( [ prg3, prg1 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x, y^2, x^4*y^-1 ]
gap> prg:= IntegratedStraightLineProgram( [ prg3, prg2 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x, y^2, x^3*y^4 ]
gap> prg:= IntegratedStraightLineProgram( [ prg3, prg3 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x, y^2, x, y^2 ]
gap> prg:= IntegratedStraightLineProgram( [ prg0, prg1, prg2, prg3 ] );;
gap> ResultOfStraightLineProgram( prg, gens );
[ x^4*y^-1, x^3*y^4, x, y^2 ]

#
gap> STOP_TEST( "straight.tst" );
