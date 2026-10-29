# Embedding( Fam, LieFamily( Fam ) ) used to fail with a no method error
gap> F := FamilyObj( 1 );; L := LieFamily( F );;
gap> emb := Embedding( F, L );;
gap> 3 ^ emb = LieObject( 3 );
true
gap> PreImagesRepresentative( emb, LieObject( 3 ) );
3
gap> PreImagesElm( emb, LieObject( 3 ) );
[ 3 ]
gap> m := [ [ 1, 2 ], [ 3, 4 ] ];;
gap> F := FamilyObj( m );; emb := Embedding( F, LieFamily( F ) );;
gap> m ^ emb = LieObject( m );
true
gap> PreImagesRepresentative( emb, LieObject( m ) ) = m;
true
