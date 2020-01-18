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
gap> STOP_TEST( "ctblsymm.tst" );
