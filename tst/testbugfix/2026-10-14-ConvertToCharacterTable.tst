gap> START_TEST( "2026-10-14-ConvertToCharacterTable.tst" );

# ConvertToCharacterTable returned fail for every record with an
# UnderlyingGroup, since it checked for a wrongly named component
gap> G := SymmetricGroup( 3 );;
gap> t := CharacterTable( G );;
gap> mkrec := {} -> rec( UnderlyingCharacteristic := 0,
>        Identifier := "test",
>        SizesCentralizers := SizesCentralizers( t ),
>        ComputedPowerMaps := ComputedPowerMaps( t ),
>        Irr := List( Irr( t ), ValuesOfClassFunction ),
>        UnderlyingGroup := G,
>        ConjugacyClasses := ConjugacyClasses( t ),
>        IdentificationOfConjugacyClasses :=
>            IdentificationOfConjugacyClasses( t ) );;
gap> new := ConvertToCharacterTable( mkrec() );;
gap> IsOrdinaryTable( new );
true
gap> UnderlyingGroup( new ) = G;
true
gap> List( Irr( new ), ValuesOfClassFunction ) =
>    List( Irr( t ), ValuesOfClassFunction );
true

# without the identification, the check fails
gap> r := mkrec();;
gap> Unbind( r.IdentificationOfConjugacyClasses );
gap> ConvertToCharacterTable( r );
fail

#
gap> STOP_TEST( "2026-10-14-ConvertToCharacterTable.tst" );
