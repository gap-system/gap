gap> START_TEST("ring-dsum.tst");
gap> # direct sums of small rings
gap> R7 := SmallRing( 7, 2 );; SetName( R7, "R7" );
gap> R8 := SmallRing( 8, 52 );; SetName( R8, "R8" );
gap> R9 := SmallRing( 9, 11 );; SetName( R9, "R9" );
gap> R78 := DirectSum( R7, R8 );
<ring with 4 generators>
gap> info78 := DirectSumInfo( R78 );
rec( embeddings := [  ], first := [ 0, 1, 4 ], projections := [  ], 
  rings := [ R7, R8 ] )
gap> R789 := DirectSum( [ R7, R8, R9 ] );
<ring with 6 generators>
gap> info789 := DirectSumInfo( R789 );
rec( embeddings := [  ], first := [ 0, 1, 4, 6 ], projections := [  ], 
  rings := [ R7, R8, R9 ] )
gap> #
gap> # embeddings and projections of small rings
gap> Embedding( R78, 2 );
[ a, b, c ] -> [ Ba, Bb, Bc ]
gap> e3 := Embedding( R789, 3 );
[ a, b ] -> [ Ca, Cb ]
gap> Projection( R78, 1 );
[ Aa, Ba, Bb, Bc ] -> [ a, 0*a, 0*a, 0*a ]
gap> p3 := Projection( R789, 3 );
[ Aa, Ba, Bb, Bc, Ca, Cb ] -> [ 0*a, 0*a, 0*a, 0*a, a, b ]
gap> genR9 := GeneratorsOfRing( R9 );;
gap> a := genR9[1];; b := genR9[2];;
gap> [ a*b^2, ImageElm( e3, a*b^2 ) ];
[ -a, -Ca ]
gap> ForAll( genR9, g -> ( g ^ e3 ) ^ p3 = g );
true
gap> genR789 := GeneratorsOfRing( R789 );;
gap> x := genR789[3];; y := genR789[6];;
gap> [ x^2, ImageElm( p3, x^2 ) ];
[ Ba+Bc, 0*a ]
gap> [ y^2, ImageElm( p3, y^2 ) ];
[ -Ca, -a ]
gap> #
gap> # other direct sums of rings
gap> R4 := ZmodnZ( 4 );;
gap> R5 := ZmodnZ( 5 );;
gap> R6 := ZmodnZ( 6 );;
gap> R45 := DirectSum( R4, R5 );
<ring with 3 generators>
gap> info45 := DirectSumInfo( R45 );
rec( embeddings := [  ], first := [ 0, 2, 3 ], projections := [  ], 
  rings := [ (Integers mod 4), GF(5) ] )
gap> R456 := DirectSum( [ R4, R5, R6 ] );
<ring with 5 generators>
gap> info456 := DirectSumInfo( R456 );
rec( embeddings := [  ], first := [ 0, 2, 3, 5 ], projections := [  ], 
  rings := [ (Integers mod 4), GF(5), (Integers mod 6) ] )
gap> #
gap> # embeddings and projections of these rings: methods for these
gap> # operations are only installed for rings of type IsSubringSCRing
gap> Embedding( R45, 1 );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Embedding' on 2 arguments
gap> Projection( R456, 2 );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Projection' on 2 arguments
gap> #
gap> # combine these all together:
gap> D := DirectSum( [R4,R5,R6,R7,R8,R9] );
<ring with 11 generators>
gap> DirectSumInfo( D );
rec( embeddings := [  ], first := [ 0, 2, 3, 5, 6, 9, 11 ], 
  projections := [  ], 
  rings := [ (Integers mod 4), GF(5), (Integers mod 6), R7, R8, R9 ] )
gap> STOP_TEST("ring-dsum.tst");
