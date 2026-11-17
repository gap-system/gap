# InducedClassFunction( chi, hom ) induced to Image( hom ), not Range( hom )
gap> S3:= SymmetricGroup( 3 );; S4:= SymmetricGroup( 4 );;
gap> hom:= GroupHomomorphismByImages( S3, S4,
>             [ (1,2,3), (1,2) ], [ (2,3,4), (2,3) ] );;
gap> irr:= Irr( S3 );;
gap> ind:= InducedClassFunction( TrivialCharacter( S3 ), hom );
Character( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 4, 2, 0, 1, 0 ] )
gap> ind = InducedClassFunction( TrivialCharacter( Image( hom ) ), S4 );
true
gap> res:= psi -> ClassFunction( CharacterTable( S3 ),
>        List( ConjugacyClasses( S3 ), c -> ( Representative( c )^hom ) ^ psi ) );;
gap> ForAll( irr, chi -> ForAll( Irr( S4 ),
>        psi -> ScalarProduct( InducedClassFunction( chi, hom ), psi )
>               = ScalarProduct( chi, res( psi ) ) ) );
true
gap> InducedClassFunctions( irr, hom )
>    = List( irr, chi -> InducedClassFunction( chi, hom ) );
true
gap> tbl:= CharacterTable( S3 );;
gap> InducedClassFunction( tbl, [ 1, 1, 1 ], hom );
ClassFunction( CharacterTable( Sym( [ 1 .. 4 ] ) ), [ 4, 2, 0, 1, 0 ] )
gap> InducedClassFunctions( tbl, List( irr, ValuesOfClassFunction ), hom )
>    = List( irr, chi -> InducedClassFunction( chi, hom ) );
true
