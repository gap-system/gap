#############################################################################
##
#W  ffe.tst                     GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("ffe.tst");
gap> GaloisField( 13 );
GF(13)
gap> GaloisField( 5^3 );
GF(5^3)
gap> GaloisField( 7, 2 );
GF(7^2)
gap> GaloisField( GF(4), 2 );
AsField( GF(2^2), GF(2^4) )
gap> x:= Indeterminate( GF(13) );; pol:= x^2 - x - 1;;
gap> GaloisField( 13, pol );
GF(13^2)
gap> GaloisField( GF(13), pol );
GF(13^2)
gap> p:= NextPrimeInt( 3^17 );
129140197
gap> GaloisField( p, 1 );
GF(129140197)
gap> GaloisField( p );
GF(129140197)
gap> AsField( GF(4), GF(16) );
AsField( GF(2^2), GF(2^4) )
gap> x:= Indeterminate( GF(2) );; pol:= x^2 + x + 1;;
gap> FieldExtension( GF(2), pol );
GF(2^2)
gap> FieldExtension( GF(2^3), pol );
AsField( GF(2^3), GF(2^6) )
gap> f1:= GF( 256 );
GF(2^8)
gap> f2:= GF( 2, Z(2) * [1,1,1,0,0,0,0,1,1] );
GF(2^8)
gap> f3:= GF( 2, Z(2) * [1,0,1,1,1,0,0,0,1] );
GF(2^8)
gap> DefiningPolynomial( f1 );
x_1^8+x_1^4+x_1^3+x_1^2+Z(2)^0
gap> DefiningPolynomial( f2 );
x_1^8+x_1^7+x_1^2+x_1+Z(2)^0
gap> DefiningPolynomial( f3 );
x_1^8+x_1^4+x_1^3+x_1^2+Z(2)^0
gap> RootOfDefiningPolynomial( f1 );
Z(2^8)
gap> RootOfDefiningPolynomial( f2 );
Z(2^8)^53
gap> RootOfDefiningPolynomial( f3 );
Z(2^8)
gap> Z(4) in GF(8);
false
gap> Z(4) in GF(16);
true
gap> Intersection( GF(2^2), GF(2^3) );
GF(2)
gap> Intersection( GF(2^4), GF(2^6) );
GF(2^2)
gap> Conjugates( GF(16), Z(4) );
[ Z(2^2), Z(2^2)^2, Z(2^2), Z(2^2)^2 ]
gap> Conjugates( AsField( GF(4), GF(16) ), Z(4) );
[ Z(2^2), Z(2^2) ]
gap> Conjugates( GF(4), GF(4), Z(4) );
[ Z(2^2) ]
gap> Conjugates( AsField( GF(4), GF(4) ), GF(2), Z(4) );
[ Z(2^2), Z(2^2)^2 ]
gap> Norm( GF(16), Z(4) );
Z(2)^0
gap> Norm( AsField( GF(4), GF(16) ), Z(4) );
Z(2^2)^2
gap> Norm( GF(8), GF(8), Z(8) );
Z(2^3)
gap> Norm( AsField( GF(8), GF(8) ), GF(2), Z(8) );
Z(2)^0
gap> Trace( GF(16), Z(4) );
0*Z(2)
gap> Trace( AsField( GF(4), GF(16) ), Z(4) );
0*Z(2)
gap> Trace( GF(4), GF(4), Z(4) );
Z(2^2)
gap> Trace( AsField( GF(4), GF(4) ), GF(2), Z(4) );
Z(2)^0
gap> List( AsSSortedList( GF(8) ), Order );
[ 0, 1, 7, 7, 7, 7, 7, 7 ]
gap> SquareRoots( GF(2), Z(2) );
[ Z(2)^0 ]
gap> SquareRoots( GF(4), Z(4) );
[ Z(2^2)^2 ]
gap> SquareRoots( GF(3), Z(3) );
[  ]
gap> SquareRoots( GF(9), Z(3) );
[ Z(3^2)^2, Z(3^2)^6 ]
gap> List( AsSSortedList( GF(7) ), Int );
[ 0, 1, 3, 2, 6, 4, 5 ]
gap> Print(List( AsSSortedList( GF(8) ), String ),"\n");
[ "0*Z(2)", "Z(2)^0", "Z(2^3)", "Z(2^3)^2", "Z(2^3)^3", "Z(2^3)^4", 
  "Z(2^3)^5", "Z(2^3)^6" ]
gap> FieldByGenerators( GF(2), [ Z(4), Z(8) ] );
GF(2^6)
gap> FieldByGenerators( GF(4), [ Z(4), Z(8) ] );
AsField( GF(2^2), GF(2^6) )
gap> DefaultFieldByGenerators( GF(2), [ Z(4), Z(8) ] );
GF(2^6)
gap> DefaultFieldByGenerators( GF(4), [ Z(4), Z(8) ] );
AsField( GF(2^2), GF(2^12) )
gap> RingByGenerators( [ Z(4), Z(8) ] );
GF(2^6)
gap> RingByGenerators( [ Z(4), Z(8) ] );
GF(2^6)
gap> DefaultRingByGenerators( [ Z(4), Z(8) ] );
GF(2^6)
gap> DefaultRingByGenerators( [ Z(4), Z(8) ] );
GF(2^6)
gap> Subfields( GF(81) );
[ GF(3), GF(3^2), GF(3^4) ]
gap> Subfields( GF(2^6) );
[ GF(2), GF(2^2), GF(2^3), GF(2^6) ]
gap> STOP_TEST( "ffe.tst", 1);

#############################################################################
##
#E
