# 2008/11/16 (TB)
gap> att:= NewAttribute( "att", IsObject );
<Attribute "att">
gap> prop1:= NewProperty( "prop1", IsObject );
<Property "prop1">
gap> prop2:= NewProperty( "prop2", IsObject );
<Property "prop2">
gap> InstallTrueMethod( prop2, prop1 );
gap> InstallImmediateMethod( att, Tester( prop2 ), 0, G -> 1 );
gap> # The intended behaviour is that `prop1' implies `prop2',
gap> # and that a known value of `prop2' triggers a method call
gap> # that yields the value for the attribute `att'.
gap> g:= Group( (1,2,3,4), (1,2) );;
gap> Tester( att )( g ); Tester( prop1 )( g ); Tester( prop2 )( g );
false
false
false
gap> Setter( prop1 )( g, true );
gap> # Now `prop1' is `true',
gap> # the logical implication sets also `prop2' to `true',
gap> # thus the condition for the immediate method is satisfied.
gap> Tester( prop1 )( g ); Tester( prop2 )( g );
true
true
gap> Tester( att )( g );  # Here we got `false' before the fix.
true
