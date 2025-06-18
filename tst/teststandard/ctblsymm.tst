#@local c3, n, wr, irr, betas, i, G, reps, t, G1, t1, charparam1, classparam1
#@local pi, G2, t2, tr
gap> START_TEST( "ctblsymm.tst" );

#
gap> c3:= CharacterTable( CyclicGroup( 3 ) );;
gap> n:= 3;;
gap> wr:= CharacterTableWreathSymmetric( c3, n );;
gap> irr:= Irr( wr );;
gap> betas:=fail;;
gap> for i in [ 1 .. Length( irr ) ] do
>      betas:= List( CharacterParameters( wr )[i], BetaSet );
>      if List( ClassParameters( wr ), 
>               c -> CharacterValueWreathSymmetric( c3, n, betas, c ) ) 
>         <> irr[i] then
>        Error( "wrong result!" );
>      fi;
>    od;
gap> Length(Irr(CharacterTable("symmetric",12)));
77

#
gap> G:= SymmetricGroup( 5 );;
gap> reps:= [(),(1,2),(1,2)(3,4),(1,2,3),(1,2,3)(4,5),(1,2,3,4),(1,2,3,4,5)];;
gap> SetConjugacyClasses( G,
>        List( Permuted( reps, (4,5)(6,7) ), x -> ConjugacyClass( G, x ) ) );
gap> t:= CharacterTable( G );;  Irr( t );;
gap> Irr(t)[7] = TrivialCharacter( t );
true
gap> CharacterParameters( t )[7] = [ 1, [ 5 ] ];
true

# use the generic character table for natural alternating groups
gap> G1:= AlternatingGroup(7);;
gap> t1:= CharacterTable( G1 );;  Irr( t1 );;
gap> charparam1:= CharacterParameters( t1 );;
gap> classparam1:= ClassParameters( t1 );;
gap> reps:= List( ConjugacyClasses( t1 ), Representative );;
gap> pi:= (5,6,7);;
gap> G2:= AlternatingGroup(7);;
gap> SetConjugacyClasses( G2,
>        List( Permuted( reps, pi ), x -> ConjugacyClass( G1, x ) ) );
gap> t2:= CharacterTable( G2 );;  Irr( t2 );;
gap> CharacterParameters( t2 ) = charparam1;
true
gap> ClassParameters( t2 ) = Permuted( classparam1, pi );
true
gap> tr:= TransformingPermutationsCharacterTables( t1, t2 );;
gap> tr.columns = pi;
true
gap> tr.rows = ();
true

#
gap> STOP_TEST( "ctblsymm.tst" );
