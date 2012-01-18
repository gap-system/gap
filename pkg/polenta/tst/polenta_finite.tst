# A test case involving a maximal unipotent subgroup of SU(6,5).
# This group is given here by matrices over GF(25), not GF(5).
# This triggered a bug in polenta versions up to and including 1.2.7.
gap> START_TEST("Test of POLENTA package with finite field matrices");
gap> z:=Z(5^2);;
gap> mats := [ [ [ 1, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0 ], [ 0, 0, 1, 0, 0, 0 ], [ 0, 0, z^3, 1, 0, 0 ], [ 0, 0, 0, 0, 1, 0 ], [ 0, 0, 0, 0, 0, 1 ] ], [ [ 1, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0 ], [ 0, z^12, 1, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0 ], [ 0, 0, 0, 1, 1, 0 ], [ 0, 0, 0, 0, 0, 1 ] ], [ [ 1, 0, 0, 0, 0, 0 ], [ 0, 1, 0, 0, 0, 0 ], [ 0, z^17, 1, 0, 0, 0 ], [ 0, 0, 0, 1, 0, 0 ], [ 0, 0, 0, z, 1, 0 ], [ 0, 0, 0, 0, 0, 1 ] ] ] * One(z);;
gap> G := Group( mats );;
gap> nat := IsomorphismPcpGroup( G );;
gap> H := Image( nat );
Pcp-group with orders [ 5, 5, 5, 5, 5, 5 ]
gap> h := GeneratorsOfGroup( H );;
gap> mats2 := List( h, x -> PreImage( nat, x ) );;
gap> exp := [ 1, 1, 1, 1, 1, 1 ];;
gap> g := MappedVector( exp, mats2 );;
gap> i := ImageElm( nat, g );;
gap> Exponents( i );
[ 1, 1, 1, 1, 1, 1 ]
gap> PreImagesRepresentative( nat, i );;
gap> last = g;
true
gap> IsPolycyclicMatGroup( G );
true
gap> IsSolvable( G );
true
gap> Size( H );
15625
gap> STOP_TEST( "POLENTA.tst", 100000);

