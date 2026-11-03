#@local F, gens, G, iso
gap> START_TEST("IsomorphismPermGroup.tst");

#
# a group of plist matrices that is not a full GL, so that
# IsomorphismPermGroup uses a sparse linear action
#
gap> F:= GF(9);;
gap> gens:= [ Matrix( IsPlistMatrixRep, F,
>               [ [ Z(9), 0*Z(9), 0*Z(9) ], [ 0*Z(9), Z(9)^0, 0*Z(9) ],
>                 [ 0*Z(9), 0*Z(9), Z(9)^0 ] ] ),
>             Matrix( IsPlistMatrixRep, F,
>               [ [ Z(9)^0, Z(9)^0, 0*Z(9) ], [ 0*Z(9), Z(9)^0, Z(9)^0 ],
>                 [ 0*Z(9), 0*Z(9), Z(9)^0 ] ] ) ];;
gap> G:= GL( 3, F : ConstructingFilter:= IsPlistMatrixRep );;
gap> ForAll( [ 1 .. 10 ], function( s )
>      local iso;
>      # the random start vectors must not matter
>      Reset( GlobalMersenneTwister, s );  Reset( GlobalRandomSource, s );
>      iso:= IsomorphismPermGroup( Subgroup( G, gens ) );
>      return Size( Image( iso ) ) = 1944 and
>             ForAll( gens, x -> PreImagesRepresentative( iso, Image( iso, x ) ) = x );
>    end );
true

#
gap> STOP_TEST("IsomorphismPermGroup.tst");
