# 2005/08/23 (TB)
gap> g:= SymmetricGroup( 4 );; IsSolvable( g );; Irr( g );;
gap> meth:= ApplicableMethod( CharacterDegrees, [ g, 0 ] );;
gap> meth( g, 0 );
"TRY_NEXT_METHOD"
