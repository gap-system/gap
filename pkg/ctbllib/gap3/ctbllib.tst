#############################################################################
##
#A  ctbllib.tst                GAP 3 tests                      Thomas Breuer
##
#A  @(#)$Id: ctbllib.tst,v 1.4 2004/03/30 08:58:51 gap Exp $
##
#Y  Copyright (C)  2003,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

RequirePackage( "ctbllib" );

# Check that all ordinary tables can be loaded without problems,
# are internally consistent, and have power maps and automorphisms stored.
easytest:= function( ordtbl )
      if not TestCharTable( ordtbl ) then
        Print( "#E  not internally consistent: ", ordtbl, "\n" );
      elif ForAny( Factors( Size( ordtbl ) ),
                   p -> not IsBound( ordtbl.powermap[p] ) ) then
        Print( "#E  some power maps are missing: ", ordtbl, "\n" );
      elif not IsBound( ordtbl.automorphisms ) then
        Print( "#E  table automorphisms missing: ", ordtbl, ",\n" );
      fi;
      return true;
end;;
AllCharTableNames( easytest, false );;

# Check that all Brauer tables can be loaded without problems.
brauernames:= function( ordtbl )
      local primes;
      primes:= Set( Factors( Size( CharTable( ordtbl ) ) ) );
      return List( primes, p -> Concatenation( ordtbl,
                                    "mod", String( p ) ) );
end;;
AllCharTableNames( OfThose, brauernames, IsCharTable, true );;


#############################################################################
##
#E

