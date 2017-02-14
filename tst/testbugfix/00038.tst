## bug 5 for fix 2
gap> t:= CharacterTable( SymmetricGroup( 4 ) );;
gap> PowerMap( t, -1 );;  PowerMap( t, -1, 2 );;
gap> m:= t mod 2;;
gap> PowerMap( m, -1 );;  PowerMap( m, -1, 2 );;
