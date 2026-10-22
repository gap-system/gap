# GroupHomomorphismByImages with a list equal, but not identical to the
# generators of the source made PreImagesRange a new group, so
# RestrictedClassFunction returned class functions of a new table
gap> S3:= SymmetricGroup( 3 );; S4:= SymmetricGroup( 4 );;
gap> hom:= GroupHomomorphismByImages( S3, S4,
>             [ (1,2,3), (1,2) ], [ (2,3,4), (2,3) ] );;
gap> IsIdenticalObj( PreImagesRange( hom ), S3 );
true
gap> psi:= Irr( S4 )[2];;
gap> r:= RestrictedClassFunction( psi, hom );;
gap> IsIdenticalObj( UnderlyingCharacterTable( r ), CharacterTable( S3 ) );
true
gap> r = ClassFunction( CharacterTable( S3 ), List( ConjugacyClasses( S3 ),
>            c -> ( Representative( c )^hom ) ^ psi ) );
true

# a mapping that is not total restricts to its preimage
gap> map:= GroupGeneralMappingByImages( S4, S4, [ (1,2,3) ], [ (1,2,3) ] );;
gap> IsTotal( map );
false
gap> ValuesOfClassFunction( RestrictedClassFunction( Irr( S4 )[4], map ) );
[ 3, 0, 0 ]
