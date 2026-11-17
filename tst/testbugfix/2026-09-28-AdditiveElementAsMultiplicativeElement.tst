# Arithmetic on wrapped additive elements took over the type of an operand,
# and with it the properties stored in that type, such as IsOne.
#@local x, e, o
gap> START_TEST( "2026-09-28-AdditiveElementAsMultiplicativeElement.tst" );
gap> x := AdditiveElementAsMultiplicativeElement( 3 );;
gap> e := AdditiveElementAsMultiplicativeElement( 0 );;
gap> [ IsOne( x ), IsOne( e ) ];
[ false, true ]
gap> o := One( x );;
gap> [ UnderlyingElement( o ), IsOne( o ) ];
[ 0, true ]
gap> List( [ x * Inverse( x ), x / x, e * x, e / x ], IsOne );
[ true, true, false, false ]
gap> List( [ Inverse( x ), x ^ e ], UnderlyingElement );
[ -3, 3 ]
gap> STOP_TEST( "2026-09-28-AdditiveElementAsMultiplicativeElement.tst" );
