# 2005/10/29 (TB)
gap> if TestPackageAvailability("ctbllib") <> fail and
>       LoadPackage("ctbllib", false) <> fail then
>      t:= CharacterTable( "S12(2)" );  p:= PrevPrimeInt( Exponent( t ) );
>      if not IsSmallIntRep( p ) then
>        PowerMap( t, p );
>      fi;
>    fi;
