#############################################################################
##
#W  ffe.tst                     GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");

gap> GaloisField( 13 );
GF(13)
gap> GaloisField( 5^3 );
GF(5^3)
gap> GaloisField( 7, 2 );
GF(7^2)
gap> GaloisField( GF(4), 2 );
AsField( GF(2^2), GF(2^4) )

gap> p:= NextPrimeInt( 3^17 );
129140197
gap> GaloisField( p, 1 );
GF(129140197)
gap> GaloisField( p );
GF(129140197)

gap> AsField( GF(4), GF(16) );
AsField( GF(2^2), GF(2^4) )

#T FieldExtension( ... )
#T need polynomials!

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

gap> Norm( GF(16), Z(4) );
Z(2)^0
gap> Norm( AsField( GF(4), GF(16) ), Z(4) );
Z(2^2)^2

gap> Trace( GF(16), Z(4) );
0*Z(2)
gap> Trace( AsField( GF(4), GF(16) ), Z(4) );
0*Z(2)

gap> List( AsListSorted( GF(8) ), Order );
[ 0, 1, 7, 7, 7, 7, 7, 7 ]

gap> SquareRoots( GF(2), Z(2) );
[ Z(2)^0 ]
gap> SquareRoots( GF(4), Z(4) );
[ Z(2^2)^2 ]
gap> SquareRoots( GF(3), Z(3) );
[  ]
gap> SquareRoots( GF(9), Z(3) );
[ Z(3^2)^2, Z(3^2)^6 ]

gap> List( AsListSorted( GF(7) ), Int );
[ 0, 1, 3, 2, 6, 4, 5 ]
gap> List( AsListSorted( GF(8) ), String );
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

#T missing: polynomials and polynomial rings

gap> STOP_TEST( "ffe.tst", 1070031 );


#############################################################################
##
#E  ffe.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##



