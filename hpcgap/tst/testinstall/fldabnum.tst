#############################################################################
##
#W  fldabnum.tst                GAP library                     Thomas Breuer
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##
gap> START_TEST("fldabnum.tst");
gap> CF( 1 ); CF( 6 ); CF( 4 ); CF( 5 ); CF( 36 );
Rationals
CF(3)
GaussianRationals
CF(5)
CF(36)
gap> CF( [ E(3), E(5) ] );
CF(15)
gap> CF( CF(3), 12 );
AsField( CF(3), CF(12) )
gap> CF( CF(3), [ E(3), E(4) ] );
AsField( CF(3), CF(12) )
gap> NF( 7, [ 1 ] ); NF( 7, [ 2 ] ); NF( 7, [ 1, 2, 4 ] );
CF(7)
NF(7,[ 1, 2, 4 ])
NF(7,[ 1, 2, 4 ])
gap> NF( 8, [ 5 ] );
GaussianRationals
gap> CF(5) = CF(7);
false
gap> CF(5) = NF( 15, [ 1 ] );
false
gap> CF(5) = NF( 15, [ 11 ] );
true
gap> NF( 15, [ 4 ] ) = CF(3);
false
gap> NF( 15, [ 7 ] ) = CF(3);
true
gap> CF(8) < CF(9);
true
gap> CF(9) < CF(8);
false
gap> CF(5) < NF( 5, [ 4 ] );
true
gap> NF( 5, [ 4 ] ) < CF(5);
false
gap> NF( 8, [ 3 ] ) < NF( 8, [ 5 ] );
false
gap> NF( 8, [ 5 ] ) < NF( 8, [ 7 ] );
true
gap> NF( 8, [ 7 ] ) < NF( 8, [ 3 ] );
false
gap> E(5) in CF(7);
false
gap> E(5) in CF(10);
true
gap> Z(5) in CF(5);
false
gap> E(5) in NF( 7, [ 2 ] );
false
gap> E(5) in NF( 5, [ 4 ] );
false
gap> Z(5) in NF( 3, [ 2 ] );
false
gap> EY(5) in NF( 5, [ 4 ] );
true
gap> Intersection( CF(12), CF(15) );
CF(3)
gap> Intersection( CF(12), NF( 15, [ 14 ] ) );
Rationals
gap> Intersection( NF( 12, [ 5 ] ), CF(15) );
Rationals
gap> Intersection( NF( 12, [ 5 ] ), NF( 15, [ 14 ] ) );
Rationals
gap> Intersection( NF( 12, [ 7 ] ), NF( 15, [ 7 ] ) );
CF(3)
gap> Intersection( NF( 35, [ 34 ] ), NF( 15, [ 11 ] ) );
NF(5,[ 1, 4 ])
gap> GeneratorsOfField( CF(37) );
[ E(37) ]
gap> GeneratorsOfField( NF( 15, [ 2 ] ) );
[ E(15)+E(15)^2+E(15)^4+E(15)^8 ]
gap> Conductor( CF(7) );
7
gap> Conductor( NF( 17, [ 3 ] ) );
1
gap> Conductor( NF( 15, [ 3 ] ) );
15
gap> Subfields( CF(15) );
[ Rationals, CF(3), CF(5), NF(5,[ 1, 4 ]), CF(15), NF(15,[ 1, 2, 4, 8 ]), 
  NF(15,[ 1, 4 ]), NF(15,[ 1, 14 ]) ]
gap> Subfields( NF( 15, [ 14 ] ) );
[ Rationals, NF(5,[ 1, 4 ]), NF(15,[ 1, 14 ]) ]
gap> x:= Indeterminate( Rationals );; pol:= x^2 + x + 1;;
gap> FieldExtension( Rationals, pol );
CF(3)
gap> FieldExtension( CF(5), pol );    
AsField( CF(5), CF(15) )
gap> x:= Indeterminate( Rationals );; pol:= x^2 - x - 1;;
gap> FieldExtension( Rationals, pol );
NF(5,[ 1, 4 ])
gap> Conjugates( CF( CF(3), 15 ), E(15) );
[ E(15), E(15)^4, E(15)^7, E(15)^13 ]
gap> Conjugates( CF(15), E(15) );
[ E(15), E(15)^2, E(15)^4, E(15)^7, E(15)^8, E(15)^11, E(15)^13, E(15)^14 ]
gap> Conjugates( AsField( CF(3), NF( 15, [ 4 ] ) ), E(15) );
[ E(15), E(15)^7 ]
gap> Conjugates( CF(15), E(15) );
[ E(15), E(15)^2, E(15)^4, E(15)^7, E(15)^8, E(15)^11, E(15)^13, E(15)^14 ]
gap> Norm( CF( CF(3), 15 ), E(15) );
E(3)^2
gap> Norm( CF(15), E(15) );
1
gap> Norm( AsField( CF(3), NF( 15, [ 4 ] ) ), E(15) );
E(15)^8
gap> Norm( CF(15), E(15) );
1
gap> Trace( CF( CF(3), 15 ), E(15) );
-E(3)^2
gap> Trace( CF(15), E(15) );
1
gap> Trace( AsField( CF(3), NF( 15, [ 4 ] ) ), E(15) );
E(15)+E(15)^7
gap> Trace( CF(15), E(15) );
1
gap> ZumbroichBase( 12, 1 );
[ 4, 7, 8, 11 ]
gap> ZumbroichBase( 12, 3 );
[ 0, 3 ]
gap> ZumbroichBase( 12, 4 );
[ 4, 8 ]
gap> Print(ZumbroichBase( 45, 1 ),"\n");
[ 1, 2, 3, 6, 7, 8, 11, 12, 16, 17, 19, 21, 24, 26, 28, 29, 33, 34, 37, 38, 
  39, 42, 43, 44 ]
gap> ZumbroichBase( 10, 1 );
[ 2, 4, 6, 8 ]
gap> ZumbroichBase(  5, 1 );
[ 1, 2, 3, 4 ]
gap> ZumbroichBase( 16, 1 );
[ 0, 1, 2, 3, 4, 5, 6, 7 ]
gap> LenstraBase( 12, [ 1, 5 ], [ 1 ], 1 );
[ [ 4, 8 ], [ 7, 11 ] ]
gap> LenstraBase( 12, [ 1, 5 ], [ 1 ], 3 );
[ [ 0, 0 ], [ 3, 3 ] ]
gap> LenstraBase(  8, [ 1, 3 ], [ 1 ], 1 );
[ [ 0 ], [ 1, 3 ] ]
gap> LenstraBase( 15, [ 1, 4 ], [ 2 ], 1 );
[ [ 1, 4 ], [ 2, 8 ], [ 7, 13 ], [ 11, 14 ] ]
gap> c:= Basis( CF(12) );
CanonicalBasis( CF(12) )
gap> BasisVectors( c );
[ E(3), E(12)^7, E(3)^2, E(12)^11 ]
gap> Coefficients( c, E(12) );
[ 0, -1, 0, 0 ]
gap> Coefficients( c, E( 4) );
[ 0, -1, 0, -1 ]
gap> Coefficients( c, E( 3) );
[ 1, 0, 0, 0 ]
gap> Coefficients( c, E( 6) );
[ 0, 0, -1, 0 ]
gap> Coefficients( c, E( 8) );
fail
gap> c:= Basis( NF( 12, [ 11 ] ) );
CanonicalBasis( NF(12,[ 1, 11 ]) )
gap> BasisVectors( c );
[ -1, E(12)^7-E(12)^11 ]
gap> Coefficients( c,  E(12) );
fail
gap> Coefficients( c, EY(12) );
[ 0, -1 ]
gap> c:= Basis( AsField( CF(3), CF(12) ) );
CanonicalBasis( AsField( CF(3), CF(12) ) )
gap> BasisVectors( c );
[ 1, E(4) ]
gap> Coefficients( c, E(12) );
[ 0, -E(3) ]
gap> Coefficients( c, E( 4) );
[ 0, 1 ]
gap> Coefficients( c, E( 3) );
[ E(3), 0 ]
gap> Coefficients( c, E( 6) );
[ -E(3)^2, 0 ]
gap> Coefficients( c, E( 8) );
fail
gap> c:= Basis( AsField( GaussianRationals, NF( 12, [ 5 ] ) ) );
CanonicalBasis( AsField( GaussianRationals, CF(4) ) )
gap> BasisVectors( c );
[ 1 ]
gap> Coefficients( c, E(12) );
fail
gap> Coefficients( c, E(12)+E(12)^5 );
[ E(4) ]
gap> c:= Basis( AsField( NF( 5, [ 4 ] ), CF(15) ) );
CanonicalBasis( AsField( NF(5,[ 1, 4 ]), CF(15) ) )
gap> Print(BasisVectors( c ),"\n");
[ -1/15*E(15)+2/15*E(15)^2+2/5*E(15)^4-2/15*E(15)^7+8/15*E(15)^8+1/15*E(15)^11
     +7/15*E(15)^13+3/5*E(15)^14, 
  2/5*E(15)+8/15*E(15)^2-1/15*E(15)^4+7/15*E(15)^7+2/15*E(15)^8+3/5*E(15)^11
     -2/15*E(15)^13+1/15*E(15)^14, 
  1/15*E(15)-2/15*E(15)^2+3/5*E(15)^4+2/15*E(15)^7+7/15*E(15)^8-1/15*E(15)^11
     +8/15*E(15)^13+2/5*E(15)^14, 
  3/5*E(15)+7/15*E(15)^2+1/15*E(15)^4+8/15*E(15)^7-2/15*E(15)^8+2/5*E(15)^11
     +2/15*E(15)^13-1/15*E(15)^14 ]
gap> Print(Coefficients( c, E(15) ),"\n");
[ 3*E(5)+E(5)^2+E(5)^3+3*E(5)^4, -3*E(5)-3*E(5)^4, 
  -3*E(5)-2*E(5)^2-2*E(5)^3-3*E(5)^4, 3*E(5)+3*E(5)^4 ]
gap> Coefficients( c, E( 5) );
[ -1, -E(5)^2-E(5)^3, -1, -E(5)^2-E(5)^3 ]
gap> Coefficients( c, E( 3) );
[ -2, -2, 1, 1 ]
gap> Coefficients( c, E( 6) );
[ -1, -1, 2, 2 ]
gap> Coefficients( c, E( 8) );
fail
gap> FieldByGenerators( [ 2, 3, 4, E(2), E(3), EY(5) ] );
NF(15,[ 1, 4 ])
gap> FieldByGenerators( Rationals, [ 2, 3, 4, E(2), E(3), EY(5) ] );
NF(15,[ 1, 4 ])
gap> FieldByGenerators( CF(3), [ 2, 3, 4, E(2), E(3), EY(5) ] );
AsField( CF(3), NF(15,[ 1, 4 ]) )
gap> DefaultFieldByGenerators( [ 2, 3, 4, E(2), E(3), EY(5) ] );
CF(15)
gap> f:= CF(45);
CF(45)
gap> aut:= ANFAutomorphism( f, 2 );
ANFAutomorphism( CF(45), 2 )
gap> id:= IdentityMapping( f );
IdentityMapping( CF(45) )
gap> aut = id;
false
gap> aut^0 = id;
true
gap> aut = ANFAutomorphism( f, 47 );
true
gap> id = aut^0;
true
gap> auts:= List( PrimeResidues( 45 ), i -> ANFAutomorphism( f, i ) );;
gap> IsSSortedList( auts );
true
gap> Position( auts, aut );
2
gap> aut^0 < id;
false
gap> id < aut^0;
false
gap> Order( aut );
12
gap> ImageElm( aut, E(45) );
E(45)^2
gap> Print(ImagesSet( aut, Conjugates( f, E(45) ) ),"\n");
[ -E(45)-E(45)^16, -E(45)^2-E(45)^17, -E(45)^7-E(45)^37, -E(45)^8-E(45)^38, 
  -E(45)^11-E(45)^26, -E(45)^19-E(45)^34, -E(45)^28-E(45)^43, 
  -E(45)^29-E(45)^44, E(45)^44, E(45)^43, E(45)^38, E(45)^37, E(45)^34, 
  E(45)^29, E(45)^28, E(45)^26, E(45)^19, E(45)^17, E(45)^16, E(45)^11, 
  E(45)^8, E(45)^7, E(45)^2, E(45) ]
gap> ImagesRepresentative( aut, E(45) );
E(45)^2
gap> PreImageElm( aut, E(45) );
-E(45)^8-E(45)^38
gap> Print(PreImagesSet( aut, Conjugates( f, E(45) ) ),"\n");
[ -E(45)-E(45)^16, -E(45)^2-E(45)^17, -E(45)^7-E(45)^37, -E(45)^8-E(45)^38, 
  -E(45)^11-E(45)^26, -E(45)^19-E(45)^34, -E(45)^28-E(45)^43, 
  -E(45)^29-E(45)^44, E(45)^44, E(45)^43, E(45)^38, E(45)^37, E(45)^34, 
  E(45)^29, E(45)^28, E(45)^26, E(45)^19, E(45)^17, E(45)^16, E(45)^11, 
  E(45)^8, E(45)^7, E(45)^2, E(45) ]
gap> PreImagesRepresentative( aut, E(45) );
-E(45)^8-E(45)^38
gap> aut * id;
ANFAutomorphism( CF(45), 2 )
gap> id * aut;
ANFAutomorphism( CF(45), 2 )
gap> aut * aut;
ANFAutomorphism( CF(45), 4 )
gap> CompositionMapping( aut, aut );
ANFAutomorphism( CF(45), 4 )
gap> Inverse( aut );
ANFAutomorphism( CF(45), 23 )
gap> One( aut );
IdentityMapping( CF(45) )
gap> aut^3;
ANFAutomorphism( CF(45), 8 )
gap> g:= GaloisGroup( f );
<group with 2 generators>
gap> Size( g );
24
gap> IsAbelian( g );
true
gap> STOP_TEST( "fldabnum.tst", 1);

#############################################################################
##
#E
