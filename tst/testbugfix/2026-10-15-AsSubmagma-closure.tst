# AsSubmagma, AsSubsemigroup and AsSubmonoid must return fail if the
# elements are not closed under multiplication
gap> G:= SymmetricGroup( 3 );;
gap> AsSubmagma( G, [ (1,2), (1,2,3) ] );
fail
gap> AsSubsemigroup( G, [ (1,2), (1,2,3) ] );
fail
gap> AsSubmonoid( G, [ (), (1,2), (1,2,3) ] );
fail
gap> Size( AsSubmagma( G, [ (), (1,2,3), (1,3,2) ] ) );
3
gap> Size( AsSubsemigroup( G, [ (), (1,2,3), (1,3,2) ] ) );
3
gap> Size( AsSubmonoid( G, [ (), (1,2,3), (1,3,2) ] ) );
3

# a submonoid must contain the identity of the parent
gap> M:= FullTransformationMonoid( 2 );;
gap> e:= Transformation( [ 1, 1 ] );;
gap> AsSubmonoid( M, [ e ] );
fail
gap> Size( AsSubsemigroup( M, [ e ] ) );
1
