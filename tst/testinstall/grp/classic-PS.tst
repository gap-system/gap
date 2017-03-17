#
# Tests for the "projective special" group constructors: PSL, PSU, PSp
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
gap> STOP_TEST("classic.tst-PS", 1);
