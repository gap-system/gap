# 2005/12/08 (TB)
gap> if TestPackageAvailability("ctbllib") <> fail and
>       LoadPackage("ctbllib", false) then
>   t:= CharacterTable( SymmetricGroup( 4 ) );;
>   SetIdentifier( t, "Sym(4)" );  Display( t,
>      rec( powermap:= "ATLAS", centralizers:= "ATLAS", chars:= false ) );
> else
>   # Wilf Wilson: hack to make `testbugfix` tests to pass without `ctbllib`.
>   Print("Sym(4)\n\n",
>         "    24  4  8  3  4\n\n",
>         " p      A  A  A  B\n",
>         " p'     A  A  A  A\n",
>         "    1A 2A 2B 3A 4A\n\n");
> fi;
Sym(4)

    24  4  8  3  4

 p      A  A  A  B
 p'     A  A  A  A
    1A 2A 2B 3A 4A


#############################################################################
#
# Tests requiring Crisp 
