#############################################################################
##
#W  ctbllib.tst         GAP character table library             Thomas Breuer
##
#H  @(#)$Id: ctbllib.tst,v 1.12 2004/08/31 08:44:03 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id: ctbllib.tst,v 1.12 2004/08/31 08:44:03 gap Exp $");

gap> LoadPackage( "ctbllib" );
true

# Check that all ordinary tables can be loaded without problems,
# are internally consistent, and have power maps and automorphisms stored.
gap> easytest:= function( ordtbl )
>       if not IsInternallyConsistent( ordtbl ) then
>         Print( "#E  not internally consistent: ", ordtbl, "\n" );
>       elif ForAny( Factors( Size( ordtbl ) ),
>                p -> not IsBound( ComputedPowerMaps( ordtbl )[p] ) ) then
>         Print( "#E  some power maps are missing: ", ordtbl, "\n" );
>       elif not HasAutomorphismsOfTable( ordtbl ) then
>         Print( "#E  table automorphisms missing: ", ordtbl, "\n" );
>       fi;
>       return true;
> end;;
gap> AllCharacterTableNames( easytest, false );;

# Check that all Brauer tables can be loaded without problems,
# are internally consistent, and have automorphisms stored.
# (This covers the tables that belong to the library via `MBT' calls
# as well as $p$-modular tables of $p$-solvable ordinary tables
# and tables of groups $G$ for which the Brauer table of $G/O_p(G)$ is
# contained in the library and the corresponding factor fusion is stored
# on the table of $G$.)
gap> brauernames:= function( ordtbl )
>       local primes;
>       primes:= Set( Factors( Size( ordtbl ) ) );
>       return List( primes, p -> Concatenation( Identifier( ordtbl ),
>                                     "mod", String( p ) ) );
> end;;
gap> easytest:= function( modtbl )
>       if not IsInternallyConsistent( modtbl ) then
>         Print( "#E  not internally consistent: ", modtbl, "\n" );
>       elif not HasAutomorphismsOfTable( modtbl ) then
>         Print( "#E  table automorphisms missing: ", modtbl, "\n" );
>       fi;
>       return true;
> end;;
gap> AllCharacterTableNames( OfThose, brauernames, IsCharacterTable, true,
>                            easytest, false );;

gap> STOP_TEST( "ctbllib.tst", 200000000000 );


#############################################################################
##
#E

