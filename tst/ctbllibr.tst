#############################################################################
##
#W  ctbllibr.tst               GAP Library                      Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1999,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");

# Check that all ordinary tables can be loaded without problems
# and are internally consistent.
gap> AllCharacterTableNames( IsInternallyConsistent, false );
[  ]

# Check that all Brauer tables can be loaded without problems
# and are internally consistent.
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
gap> AllCharacterTableNames( OfThose, brauernames,
>                            IsInternallyConsistent, false );
[  ]


gap> STOP_TEST( "ctbllibr.tst", 200000000000 );

#############################################################################
##
#E

