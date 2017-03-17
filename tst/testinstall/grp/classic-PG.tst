#
# Tests for the "projective general" group constructors: PGL, POmega, PGU
#
gap> START_TEST("classic-PG.tst");

#
gap> PGL(4,5);
<permutation group of size 29016000000 with 2 generators>
gap> last = PGL(IsPermGroup,4,5);
true
gap> PGL(4,GF(5));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ProjectiveGeneralLinearGroupCons' on 3 \
arguments
gap> PGL(3);
Error, usage: ProjectiveGeneralLinearGroup( [<filter>, ]<d>, <q> )
gap> PGL(3,6);
Error, usage: GeneralLinearGroup( [<filter>, ]<d>, <R> )

#
gap> G := POmega(3,7);
<permutation group of size 168 with 2 generators>
gap> G = POmega(0,3,7);
true
gap> G = POmega(IsPermGroup,3,7);
true

#
gap> POmega(3,GF(5));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ProjectiveOmegaCons' on 4 arguments
gap> POmega(3);
Error, usage: ProjectiveOmega( [<filter>, ][<e>, ]<d>, <q> )
gap> POmega(3,6);
Error, <subfield> must be a prime or a finite field
gap> POmega(-1,3,5);
Error, sign <e> <> 0 but dimension <d> is odd
gap> POmega(+1,3,5);
Error, sign <e> <> 0 but dimension <d> is odd
gap> POmega(2,3,5);
Error, sign <e> <> 0 but dimension <d> is odd

#
gap> POmega(-1,4,9);
<permutation group of size 265680 with 2 generators>
gap> last = POmega(IsPermGroup,-1,4,9);
true

#
gap> POmega(1,4,9);
<permutation group of size 129600 with 2 generators>
gap> last = POmega(IsPermGroup,1,4,9);
true

#
gap> POmega(4,9);
Error, sign <e> = 0 but dimension <d> is even
gap> POmega(0,4,9);
Error, sign <e> = 0 but dimension <d> is even

#
gap> PGU(3,5);
<permutation group of size 378000 with 2 generators>
gap> last = PGU(IsPermGroup,3,5);
true
gap> PGU(3,GF(5));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ProjectiveGeneralUnitaryGroupCons' on 3\
 arguments
gap> PGU(3);
Error, usage: ProjectiveGeneralUnitaryGroup( [<filter>, ]<d>, <q> )
gap> PGU(3,6);
Error, <subfield> must be a prime or a finite field

#
gap> STOP_TEST("classic-PG.tst", 1);
