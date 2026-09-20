#@local F, gens, G, cl, H
gap> START_TEST( "matgroup.tst" );

#
# a GL(2,4) whose elements are matrix objects rather than plain lists
#
gap> F:= GF(4);;
gap> gens:= [ Matrix( IsPlistMatrixRep, F, [ [ Z(4), 0*Z(4) ], [ 0*Z(4), Z(4)^0 ] ] ),
>             Matrix( IsPlistMatrixRep, F, [ [ Z(4)^0, Z(4)^0 ], [ Z(4)^0, 0*Z(4) ] ] ) ];;
gap> ForAll( gens, IsMatrixObj ) and ForAny( gens, IsMatrix ) = false;
true
gap> G:= Group( gens );;
gap> IsMatrixGroup( G );  IsFFEMatrixGroup( G );
true
true

#
gap> DimensionOfMatrixGroup( G );
2
gap> FieldOfMatrixGroup( G );  DefaultFieldOfMatrixGroup( G );
GF(2^2)
GF(2^2)
gap> Size( G );
180
gap> Size( AsSSortedList( G ) );
180
gap> Size( Image( IsomorphismPermGroup( G ) ) );
180
gap> Size( DerivedSubgroup( G ) );  Size( Centre( G ) );
60
3
gap> Size( SylowSubgroup( G, 3 ) );  Exponent( G );
9
30
gap> IsAbelian( G );  IsSolvableGroup( G );
false
false

#
gap> cl:= ConjugacyClasses( G );;
gap> Length( cl );  Sum( cl, Size );
15
180
gap> ForAll( cl, c -> Representative( c ) in G );
true

#
# a proper subgroup, so that the natural-GL shortcuts do not apply
#
gap> H:= Group( gens[1] );;
gap> Size( H );  IsAbelian( H );
3
true
gap> IsSubgroup( G, H );
true

#
# 'FlushCaches' makes 'GF(4)' return a new object; the cached nice
# monomorphism of the full GL must not be reused across that boundary
#
gap> G:= GL( 2, GF(4) : ConstructingFilter:= IsPlistMatrixRep );;
gap> Size( Image( NiceMonomorphism( G ) ) );
180
gap> FlushCaches();
gap> G:= GL( 2, GF(4) : ConstructingFilter:= IsPlistMatrixRep );;
gap> ForAll( GeneratorsOfGroup( G ), g -> PreImagesRepresentative(
>        NiceMonomorphism( G ), ImagesRepresentative( NiceMonomorphism( G ), g ) ) = g );
true

#
gap> STOP_TEST( "matgroup.tst" );
