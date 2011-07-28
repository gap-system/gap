#############################################################################
##
#W  factint.tst              GAP4 Package `FactInt'               Stefan Kohl
##
##  For purposes of limiting the execution time, the testing numbers given
##  here are all 'easy' to factor. This does not mean that the factorization
##  routines provided by this package are not capable of factoring much
##  'harder' numbers.
##
#############################################################################

gap> START_TEST( "factint.tst" );
gap> oldwarninglevel := InfoLevel(InfoPrimeInt);;
gap> SetInfoLevel(InfoPrimeInt,0);
gap> IntegerFactorization(Factorial(39)+1:ECMDeterministic);
[ 79, 57554485363, 146102648914939, 30705821478100704367 ]
gap> FactInt(Factorial(43)-1:ECMDeterministic);
[ [ 97, 607, 857, 883, 12829, 1298793158431, 81378920130420431538741649 ], 
  [  ] ]
gap> Factors(1459^24-1);
[ 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 5, 7, 13, 73, 97, 193, 283, 337, 1009, 
  303889, 669433, 1064341, 6722971513, 4531280671081, 313380751265929 ]
gap> FactorsPminus1(NrPartitions(1503));
[ [ 2, 2, 2, 7, 7, 53, 34261, 1432250823109, 1437327898056671629 ], [  ] ]
gap> FactorsPplus1(Factorial(55)-1);
[ [ 73, 39619, 277914269, 148257413069 ], 
  [ 106543529120049954955085076634537262459718863957 ] ]
gap> FactorsECM(Factorial(36)-1:ECMDeterministic);
[ [ 155166770881, 2397377509874128534536693708479 ], [  ] ]
gap> FactorsCFRAC(Factorial(24)-1);
[ 625793187653, 991459181683 ]
gap> FactorsMPQS(NrPartitions(808));
[ 5963320232189, 1366982853893003 ]
gap> SetInfoLevel(InfoPrimeInt,oldwarninglevel);
gap> STOP_TEST( "factint.tst", 10000000000 );

#############################################################################
##
#E  factint.tst  . . . . . . . . . . . . . . . . . . . . . . . . .  ends here