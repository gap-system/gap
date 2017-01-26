# 2005/12/08 (TB)
gap> if LoadPackage("ctbllib", false) <> fail then
>      if List( Filtered( Irr( CharacterTable( "Sz(8).3" ) mod 3 ),
>                         x -> x[1] = 14 ), ValuesOfClassFunction )
>         <> [ [ 14, -2, 2*E(4), -2*E(4), -1, 0, 1 ],
>              [ 14, -2, -2*E(4), 2*E(4), -1, 0, 1 ] ] then
>        Print( "ordering problem in table of Sz(8).3 mod 3\n" );
>      fi;
>    fi;
