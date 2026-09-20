#@local G
gap> START_TEST( "matgroup.tst" );

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
