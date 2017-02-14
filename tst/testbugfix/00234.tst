# 2011/04/29 (TB)
gap> t:= CharacterTable( SmallGroup( 72, 26 ) );;
gap> Set( List( Irr( t ), x -> Size( CentreOfCharacter( x ) ) ) );
[ 6, 12, 18, 72 ]
