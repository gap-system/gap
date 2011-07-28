#############################################################################
##
#W  factint.gd              GAP4 Package `FactInt'                Stefan Kohl
##
##  This file contains the declarations of the routines for 
##  integer factorization implemented in pminus1.gi, pplus1.gi, ecm.gi,
##  cfrac.gi, mpqs.gi and general.gi.
##
#############################################################################

#############################################################################
##
#V  IntegerFactorizationInfo . . . . . . .  Info class of the FactInt package
#V  InfoFactInt
##
##  If InfoLevel(IntegerFactorizationInfo) = 1, then basic information about
##  the factoring techniques used is displayed. If this InfoLevel has 
##  value 2, then additionally all ``relevant'' steps in the factoring 
##  algorithms are mentioned, and if it is set to 3, then large amounts 
##  of details of the progress of the factoring process are shown. A high
##  InfoLevel is in particular useful when factoring large integers with ECM
##  or the MPQS.
##
DeclareInfoClass( "IntegerFactorizationInfo" );
DeclareSynonym( "InfoFactInt", IntegerFactorizationInfo );

#############################################################################
##
#F  FactInfo( <level> ) . . . . .  shorthand for setting FactInt's Info level
##
##  Sets the InfoLevel of `IntegerFactorizationInfo' to the positive
##  integer <level>. In other words, `FactInfo( <level> )' is equivalent to
##  `SetInfoLevel( IntegerFactorizationInfo, <level> )'.
##
DeclareGlobalFunction( "FactIntInfo" );
DeclareSynonym( "FactInfo", FactIntInfo );

#############################################################################
##
#F  FetchBrentFactors( ) . . get Brent's tables of factors of numbers b^k - 1
##
##  A utility for fetching the current version of
##
##  http://wwwmaths.anu.edu.au/~brent/ftp/factors/factors.gz
##
##  from the network and unpacking the information into 'BRENTFACTORS'.
##  This information is then stored in the directory pkg/factint/tables.
##
DeclareGlobalFunction( "FetchBrentFactors" );

#############################################################################
##
#F  FactorsTD( <n> [, <Divisors> ] )
##
##  Prime factorization of the integer <n>, using Trial Division with
##  divisors list <Divisors>. If absent, this list defaults to the list
##  `Primes' of the 168 primes p < 1000.
##
##  The result is returned as a list of two lists. The first list
##  contains the prime factors found, and the second list contains
##  remaining unfactored parts of <n>, if there are any.
##
DeclareGlobalFunction( "FactorsTD" );

#############################################################################
##
#F  FactorsPminus1( <n> [ [, <a> ], <Limit1> [, <Limit2> ] ] )
##
##  Prime factorization of the integer <n>, using Pollard's p-1 with
##  first stage limit <Limit1>, second stage limit <Limit2> and 
##  exponentiation base <a>. (Without much loss of generality, one can
##  use <a> = 2 -- this is also the default).
##
##  The result is returned as a list of two lists. The first list
##  contains the prime factors found, and the second list contains
##  remaining unfactored parts of <n>, if there are any.
##
DeclareGlobalFunction( "FactorsPminus1" );

#############################################################################
##
#F  FactorsPplus1( <n> [ [, <Residues> ], <Limit1> [, <Limit2> ] ] )
##
##  Prime factorization of the integer <n>, using a variant of Williams' p+1
##  with first stage limit <Limit1> and second stage limit <Limit2> for
##  <Residues> different residues.
##
##  The result is returned as a list of two lists. The first list
##  contains the prime factors found, and the second list contains
##  remaining unfactored parts of <n>, if there are any.
##
DeclareGlobalFunction( "FactorsPplus1" );

#############################################################################
##
#F  FactorsECM( <n> [, <Curves> [, <Limit1> [, <Limit2> [, <Delta> ] ] ] ] )
##
##  Prime factorization of the integer <n>, using the Elliptic Curves Method
##  (ECM) for <Curves> different elliptic curve groups with first stage
##  limit <Limit1>, second stage limit <Limit2> and first stage limit
##  increment <Delta>.
##
##  The option <ECMDeterministic> demands, if set, that the choice 
##  of the curves to be tried should be deterministic, i.e. that
##  repeated calls of `FactorsECM' yield the same curves, and hence for the
##  same <n> the result after the same number of trials. This is useful
##  mainly for testing purposes.
##
##  The result is returned as a list of two lists. The first list
##  contains the prime factors found, and the second list contains
##  remaining unfactored parts of <n>, if there are any.
## 
DeclareGlobalFunction( "FactorsECM" );
DeclareSynonym( "ECM", FactorsECM );

#############################################################################
##
#F  FactorsCFRAC( <n> )
##
##  Prime factorization of the integer <n>, using the Continued Fraction
##  Algorithm (CFRAC).
##
##  The result is returned as a list of the prime factors of <n>.
##
DeclareGlobalFunction( "FactorsCFRAC" );
DeclareSynonym( "CFRAC", FactorsCFRAC );

#############################################################################
##
#F  FactorsMPQS( <n> )
##
##  Prime factorization of the integer <n>, using the Single Large Prime
##  Variation of the Multiple Polynomial Quadratic Sieve (MPQS).
##
##  The result is returned as a list of the prime factors of <n>.
##
DeclareGlobalFunction( "FactorsMPQS" );
DeclareSynonym( "MPQS", FactorsMPQS );

#############################################################################
##
#F  FactInt( <n> ) . . . . . . . . . . prime factorization of the integer <n>
#F                                                      (partial or complete)
##
##  Recognized options are:
##
##  <cheap>            if true, the partial factorization obtained by
##                     applying the cheap factoring methods is returned
##  <FactIntPartial>   if true, the partial factorization obtained by
##                     applying the factoring methods whose time complexity 
##                     depends mainly on the size of the factors to be found
##                     and less on the size of <n> (see manual) is returned
##                     and the factor base methods (MPQS and CFRAC) are not
##                     used to complete the factorization for numbers that
##                     exceed the bound given by <CFRACLimit> resp.
##                     <MPQSLimit>; default: false
##  <TDHints>          a list of additional trial divisors
##  <RhoSteps>         number of steps for Pollard's Rho
##  <RhoCluster>       interval for Gcd computation in Pollard's Rho
##  <Pminus1Limit1>    first stage limit for Pollard's p-1
##  <Pminus1Limit2>    second stage limit for Pollard's p-1
##  <Pplus1Residues>   number of residues to be tried in William's p+1
##  <Pplus1Limit1>     first stage limit for William's p+1
##  <Pplus1Limit2>     second stage limit for William's p+1
##  <ECMCurves>        number of elliptic curves to be tried by 
##                     the Elliptic Curves Method (ECM),
##                     also admissible: a function that takes the number to
##                     be factored and returns the desired number of curves 
##  <ECMLimit1>        initial first stage limit for ECM
##  <ECMLimit2>        initial second stage limit for ECM
##  <ECMDelta>         increment for first stage limit in ECM
##                     (the second stage limit is also incremented 
##                     appropriately)
##  <ECMDeterministic> if true, the choice of curves in ECM is deterministic,
##                     i.e. repeatable 
##  <FBMethod>         specifies which of the factor base methods should be
##                     used to do the ``hard work''; currently implemented:
##                     `"CFRAC"' and `"MPQS"'
##  <CFRACLimit>       specifies the maximal number of decimal digits of an
##                     integer to which the Continued Fraction Algorithm
##                     (CFRAC) should be applied (only used when 
##                     <FactIntPartial> is true)
##  <MPQSLimit>        as above, for the Multiple Polynomial Quadratic
##                     Sieve (MPQS)
##
##  The result is returned as a list of two lists. The first list
##  contains the prime factors found, and the second list contains
##  remaining unfactored parts of <n>, if there are any.
##
DeclareGlobalFunction( "FactInt" );

#############################################################################
##
#F  IntegerFactorization( <n> ) . . . . . .  prime factors of the integer <n>
## 
##  Returns the list of prime factors of the integer <n>.
##
DeclareGlobalFunction( "IntegerFactorization" );

if not IsBound( PartialFactorization ) then
  DeclareOperation( "PartialFactorization",
                    [ IsMultiplicativeElement, IsInt ] );
fi;

#############################################################################
##
#E  factint.gd . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here