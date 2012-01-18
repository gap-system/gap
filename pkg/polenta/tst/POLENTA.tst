gap> START_TEST("Test of POLENTA package");  
gap> mats := [ [ [ 1, 0, 0, 3/2, 0 ], [ 0, 1, 0, 0, 1 ], [ 0, 0, 1, 0, 0 ],[ 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 1 ] ], [ [ 1, 0, 0, 1, 0 ], [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 1 ], [ 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 1 ] ],  [ [ 1, -3/2, -1, 0, 0 ], [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ],  [ 0, 0, 0, 1, 1 ], [ 0, 0, 0, 0, 1 ] ],  [ [ 1, 0, 0, 0, 1 ], [ 0, 1, 0, 0, 0 ], [ 0, 0, 1, 0, 0 ], [ 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 1 ] ], [ [ 1, 1, -1, -2, 2 ], [ 0, -1, 0, 0, 0 ], [ 0, 0, -1, 0, 0 ],[ 0, 0, 0, -1, 0 ], [ 0, 0, 0, 0, 1 ] ] ];;
gap> G := Group( mats );;
gap> nat := IsomorphismPcpGroup( G );;
gap> H := Image( nat );;
gap> h := GeneratorsOfGroup( H );;
gap> mats2 := List( h, x -> PreImage( nat, x ) );;
gap> exp :=  [ 1, 1, 1, 1, 1 ];;
gap> g := MappedVector( exp, mats2 );;
gap> i := ImageElm( nat, g );;
gap> Exponents( i );
[ 1, 1, 1, 1, 1 ]
gap> PreImagesRepresentative( nat, i );;
gap> last = g;
true
gap> IsPolycyclicMatGroup( G );
true
gap> IsTriangularizableMatGroup( G );
true
gap> IsSolvable( G );
true
gap> mats_f := mats* One( GF(3 ) );;
gap> G_f := Group( mats_f );;
gap> IsSolvable( G_f );
true
gap> IsPolycyclicMatGroup( G_f );
true
gap> Size( G_f );
162
gap> STOP_TEST( "POLENTA.tst", 100000);   

