##  Bug 18 for fix 4
gap> if LoadPackage("ctbllib", false) <> fail then
>      if Irr( CharacterTable( "WeylD", 4 ) )[1] <>
>           [ 3, -1, 3, -1, 1, -1, 3, -1, -1, 0, 0, -1, 1 ] then
>        Print( "problem with Irr( CharacterTable( \"WeylD\", 4 ) )[1]\n" );
>      fi;
>    fi;
