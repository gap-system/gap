#@local right_representation, q, F, d, filt, groups, G, basis, xset, vectors
#@local orbs, len, D1, v, D2, D3, D4, actions, D, hom, i, g, img, pre
gap> START_TEST( "acthom.tst" );

#
gap> right_representation:= function( filt, g )
>      return ( filt = IsPlistRep and IsList( g ) ) or
>             ( filt <> IsPlistRep and filt( g ) );
>    end;;
gap> for q in [ 2, 3, 4 ] do
>      F:= GF(q);
>      for d in [ 2 .. 4 ] do
>        for filt in [ IsPlistRep, IsPlistMatrixRep ] do
>          PushOptions( rec( ConstructingFilter:= filt ) );
>          # Test groups with special methods and a general group.
>          groups:= [ GL( d, F ), SL( d, F ) ];
>       #  Add( groups, SylowSubgroup( groups[1], 2 ) );
>       #  Add( groups, Subgroup( groups[1],
>       #                   [ GeneratorsOfGroup( groups[1] )[1] ] ) );
>          for G in groups do
>            # Consider the G-action
>            # - given by the nice monomorphism
>            # - on an orbit (linear & projective)
>            # - on the whole natural G-set (linear & projective)
>            basis:= RowsOfMatrix( One( G ) );
>            xset:= ExternalSet( G );
>            vectors:= HomeEnumerator( xset );
>            orbs:= Orbits( G, vectors );
>            len:= Maximum( List( orbs, Length ) );
>            D1:= [ First( orbs, x -> Length( x ) = len ), OnRight ];
>            v:= OnLines( D1[1][1], One( G ) );
>            D2:= [ Orbit( G, v, OnLines ), OnLines ];
>            D3:= [ vectors, OnRight ];
>            D4:= [ NormedRowVectors_internal( F, basis ), OnLines ];
> 
>            actions:= [ NiceMonomorphism( G ) ];
>            for D in [ D1, D2, D3, D4 ] do
>              if not CompatibleVectorFilter( One( G ) )( D[1][1] ) then
>                Error( "wrong repres. of vector for ", [ q, d, filt ] );
>              fi;
>              hom:= ActionHomomorphism( G, D[1], D[2] );
>              if D[2] <> OnLines and
>                 not IsLinearActionHomomorphism( hom ) then
>                Error( "unexpected type of action hom. for ",
>                       [ q, d, filt ] );
>              fi;
>              Add( actions, hom );
>            od;
> 
>            for hom in actions do
>              for i in [ 1 .. 5 ] do
>                g:= Random( G );
>                if not right_representation( filt, g ) then
>                  Error( "wrong repres. of random matrix for ",
>                         [ q, d, filt ] );
>                fi;
>                img:= g^hom;
>                pre:= PreImagesRepresentative( hom, img );
>                if not right_representation( filt, pre ) then
>                  Error( "wrong repres. of preimage matrix for ",
>                         [ q, d, filt ] );
>                fi;
>                if FunctionAction( UnderlyingExternalSet( hom ) ) = OnLines then
>                  if not ( pre / g in Centre( G ) ) then
>                    Error( "problem with projective action for ",
>                           [ q, d, filt ] );
>                  fi;
>                elif pre <> g then
>                  Error( "problem with linear action for ",
>                         [ q, d, filt ] );
>                fi;
>              od;
>            od;
>          od;
>        od;
>      od;
>    od;

#
gap> STOP_TEST( "acthom.tst" );
