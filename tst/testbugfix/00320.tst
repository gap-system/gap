# 2005/08/23 (TB)
gap> tbl:= CharacterTable( ElementaryAbelianGroup( 4 ) );;
gap> IsElementaryAbelian( tbl );
true
gap> ClassPositionsOfMinimalNormalSubgroups( tbl );
[ [ 1, 2 ], [ 1, 3 ], [ 1, 4 ] ]
gap> if LoadPackage("ctbllib", false) <> fail then
>      tbl:= CharacterTableIsoclinic( CharacterTable( "2.A5.2" ) );
>      if tbl mod 3 = fail then
>        Error( CharacterTable( "Isoclinic(2.A5.2)" ), " mod 3" );
>      fi;
>      SourceOfIsoclinicTable( tbl );
>    fi;
gap> tbl:= CharacterTable( Group( () ) );;
gap> ClassPositionsOfElementaryAbelianSeries( tbl );;
