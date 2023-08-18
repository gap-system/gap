#@local s, t, maps
gap> START_TEST( "ctblmaps.tst" );

# `ConsiderStructureConstants` can unexpectedly exclude all candidates.
# (Benjamin Sambale found examples for that.)
gap> if TestPackageAvailability("ctbllib") <> fail and
>       LoadPackage("ctbllib", false) <> fail then
>      s:= CharacterTable( "2.A6" );;
>      t:= CharacterTable( "Co3" );;
>      maps:= [ [ 1, 2, 8, 4, 11, 4, 13, 18, 18, 9, 22, 9, 22 ],
>               [ 1, 2, 8, 4, 11, 4, 13, 17, 17, 9, 22, 9, 22 ] ];;
>      if Length( ConsiderStructureConstants( s, t, maps, true ) ) <> 0 then
>        Error( "test of ConsiderStructureConstants failed" );
>      fi;
>    fi;

#
gap> STOP_TEST( "ctblmaps.tst" );
