#@local G, cl, x
gap> START_TEST("ConjugacyClassesNaturalGroup.tst");

#
# after 'FlushCaches', 'GF(4)' returns a new object (the call of 'GF(8)'
# evicts the one-entry cache); the class representatives must be defined
# over the base domain of the elements of G
#
gap> G:= GL( 2, GF(4) : ConstructingFilter:= IsPlistMatrixRep );;
gap> FlushCaches();; GF(8);;
gap> x:= Representative( ConjugacyClasses( G )[2] );;
gap> IsIdenticalObj( BaseDomain( x ), BaseDomain( One( G ) ) );
true
gap> x * G.1 in G;
true
gap> Size( Centralizer( G, x ) ) * Size( ConjugacyClasses( G )[2] );
180

#
# class representatives of natural GL and SL in the group's representation
#
gap> G:= GL( 2, GF(4) : ConstructingFilter:= IsPlistMatrixRep );;
gap> cl:= ConjugacyClasses( G );;
gap> Length( cl );  Sum( cl, Size );
15
180
gap> IsOne( Representative( cl[1] ) );
true
gap> ForAll( cl, c -> IsPlistMatrixRep( Representative( c ) )
>                     and Representative( c ) in G );
true
gap> G:= SL( 2, GF(5) : ConstructingFilter:= IsPlistMatrixRep );;
gap> cl:= ConjugacyClasses( G );;
gap> Length( cl );  Sum( cl, Size );
9
120
gap> ForAll( cl, c -> IsPlistMatrixRep( Representative( c ) )
>                     and Representative( c ) in G );
true

#
gap> STOP_TEST("ConjugacyClassesNaturalGroup.tst");
