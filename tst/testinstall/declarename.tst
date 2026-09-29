#@local x

#
gap> START_TEST( "declarename.tst" );

#
gap> DeclareGlobalName( "x" );
gap> x;
Error, Variable: 'x' must have an assigned value
gap> {} -> x;;  # no syntax warning
gap> DeclareGlobalName( "x" );  # can be called several times
gap> x:= 0;;
gap> DeclareGlobalName( "x" );  # can be called also after the assignment

#
gap> STOP_TEST( "declarename.tst" );
