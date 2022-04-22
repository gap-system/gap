#
# Tests for the "projective special" group constructors:
# PSL, PSO, PSU, PSp, PSigmaL
#
gap> START_TEST("classic-PS.tst");

#
gap> PSL(4,5);
<permutation group of size 7254000000 with 2 generators>
gap> last = PSL(IsPermGroup,4,5);
true
gap> PSL(4,GF(5));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ProjectiveSpecialLinearGroupCons' on 3 \
arguments
gap> PSL(3);
Error, usage: ProjectiveSpecialLinearGroup( [<filter>, ]<d>, <q> )
gap> PSL(3,6);
Error, usage: SpecialLinearGroup( [<filter>, ]<d>, <R> )

#
gap> G:= PSO( 3, 5 );;  Size( G );
120
gap> G = PSO( 0, 3, 5 );
true
gap> G = PSO( IsPermGroup, 3, 5 );
true
gap> G = PSO( IsPermGroup, 0, 3, 5 );
true
gap> G:= PSO( 1, 4, 5 );;  Size( G );
7200
gap> G = PSO( IsPermGroup, 1, 4, 5 );
true
gap> G:= PSO( -1, 4, 5 );;  Size( G );
7800
gap> G = PSO( IsPermGroup, -1, 4, 5 );
true

#
gap> PSU(3,5);
<permutation group of size 126000 with 2 generators>
gap> last = PSU(IsPermGroup,3,5);
true
gap> PSU(3,GF(5));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ProjectiveSpecialUnitaryGroupCons' on 3\
 arguments
gap> PSU(3);
Error, usage: ProjectiveSpecialUnitaryGroup( [<filter>, ]<d>, <q> )
gap> PSU(3,6);
Error, <subfield> must be a prime or a finite field

#
gap> PSp(4,5);
<permutation group of size 4680000 with 2 generators>
gap> last = PSp(IsPermGroup,4,5);
true
gap> PSp(3,5);
Error, the dimension <d> must be even
gap> PSp(4,GF(5));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ProjectiveSymplecticGroupCons' on 3 arg\
uments
gap> PSp(4);
Error, usage: ProjectiveSymplecticGroup( [<filter>, ]<d>, <q> )
gap> PSp(4,6);
Error, <subfield> must be a prime or a finite field

#
gap> PSigmaL( 3, 5 ) = PSL(3,5);
true
gap> Size( PSigmaL( 3, 9 ) );
84913920
gap> SetX( [1..3], [2, 3, 5], [1..3], {n, p, d} -> Size( PSigmaL( n, p^d ) ) = Size( PSL( n, p^d ) ) * d );
[ true ]
gap> PSigmaL( IsPermGroup, 3, 9 ) = PSigmaL( 3, 9 );
true
gap> PSigmaL( 3, GF(9) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ProjectiveSpecialSemilinearGroupCons' o\
n 3 arguments
gap> PSigmaL( 3 );
Error, usage: ProjectiveSpecialSemilinearGroup( [<filter>, ]<d>, <q> )
gap> PSigmaL( 3, 6 );
Error, usage: SpecialLinearGroup( [<filter>, ]<d>, <R> )

#
gap> STOP_TEST("classic.tst-PS", 1);
