# Tests that specific method for multiplying IsDirectProductElement
# and IsInt is used (the generic method for IsDirectProductElement
# and IsObject has a lower rank than IsAddetiveElement and IsObject).
#@local d
gap> START_TEST("2026-03-04-DirectProductElement-Multiply-Integer-Error.tst");

#
gap> d := DirectProductElement( [ (), () ] );;
gap> ApplicableMethod( \*, [1, d] );
function( int, dpelm ) ... end
gap> ApplicableMethod( \*, [d, 1] );
function( dpelm, int ) ... end

#
gap> STOP_TEST("2026-03-04-DirectProductElement-Multiply-Integer-Error.tst");
