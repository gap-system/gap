# See https://github.com/gap-system/gap/issues/6573
gap> START_TEST( "2026-09-17-IrrBaumClausen.tst");

# The assertions in `BaumClausenInfo' would dominate the runtime here.
gap> SetAssertionLevel( 0 );

# `AutomorphismGroup( SmallGroup( 192, 1025 ) )' as a pc group.
# A composition factor of order 5 is acted on by an automorphism of
# order 4, and the fusion of linear representations went wrong.
gap> G:= PcGroupCode( 99041954042254845480650493027768682897535588988716149606025237169102921586241034108468374708180999543256813867834717432171333528874147732707725285319441304153584036442132128555017864412605029312598566912492266040500066198661031980797248326353686835062684680084133271949490452523627715737765384666387978323579808299778343162428234222350979229325353399114706562971914484861568526805106688, 61440 );;
gap> Collected( List( IrrBaumClausen( G ), chi -> chi[1] ) );
[ [ 1, 4 ], [ 2, 2 ], [ 4, 3 ], [ 5, 4 ], [ 10, 8 ], [ 15, 8 ], [ 30, 2 ], 
  [ 60, 3 ] ]

# A split extension of `SmallGroup( 7^5, 37 )' by a group of order 3.
# Here also the fusion of nonlinear representations went wrong;
# the characters came out right but not the representations.
gap> G:= PcGroupCode( 2043655405810684061083121958358464047373336278207, 50421 );;
gap> ForAll( IrreducibleRepresentations( G ), function( rep )
>      local mgi;
>      mgi:= MappingGeneratorsImages( rep );
>      return IsGroupHomomorphism( GroupGeneralMappingByImagesNC( G,
>                 Range( rep ), mgi[1], mgi[2] ) );
>    end );
true

#
gap> STOP_TEST( "2026-09-17-IrrBaumClausen.tst");
