#
# Tests for the "general" group constructors: GL, GO, GU, GammaL
#
gap> START_TEST("classic-G.tst");

#
gap> GL(2,5);
GL(2,5)
gap> last = GL(2,GF(5));
true
gap> GL(IsPermGroup,3,4);
Perm_GL(3,4)
gap> last = GL(IsPermGroup,3,GF(4));
true
gap> GL(3);
Error, usage: GeneralLinearGroup( [<filter>, ]<d>, <R> )
gap> GL(3,6);
Error, usage: GeneralLinearGroup( [<filter>, ]<d>, <R> )

#
gap> G := GO(3,5);
GO(0,3,5)
gap> G = GO(0,3,5);
true
gap> G = GO(3,GF(5));
true
gap> G = GO(0,3,GF(5));
true
gap> GO(IsPermGroup,3,5);
Perm_GO(0,3,5)

#
gap> GO(3);
Error, usage: GeneralOrthogonalGroup( [<filter>, ][<e>, ]<d>, <q> )
gap> GO(3,6);
Error, <subfield> must be a prime or a finite field
gap> GO(-1,3,5);
Error, sign <e> <> 0 but dimension <d> is odd
gap> GO(+1,3,5);
Error, sign <e> <> 0 but dimension <d> is odd
gap> GO(2,3,5);
Error, sign <e> must be -1, 0, +1

#
gap> GO(-1,4,9);
GO(-1,4,9)

#gap> last = GO(-1,4,GF(9));
#true
#gap> GO(IsPermGroup,-1,4,9);
#Perm_GO(-1,4,9)

#
gap> GO(1,4,9);
GO(+1,4,9)

#gap> last = GO(+1,4,GF(9));
#true
#gap> GO(IsPermGroup,1,4,9);
#Perm_GO(+1,4,9)

#
gap> GO(4,9);
Error, sign <e> = 0 but dimension <d> is even
gap> GO(0,4,9);
Error, sign <e> = 0 but dimension <d> is even

#
gap> GU(3,5);
GU(3,5)

#gap> GU(IsPermGroup,3,4);
#Perm_GU(3,4)
gap> GU(3);
Error, usage: GeneralUnitaryGroup( [<filter>, ]<d>, <q> )
gap> GU(3,6);
Error, <subfield> must be a prime or a finite field

#
gap> GammaL(3,5);
GL(3,5)
gap> GammaL(3,9);
GammaL(3,9)
gap> GammaL(IsPermGroup,3,9);
Perm_GammaL(3,9)
gap> Size(last) / Size(GL(3,9));
2
gap> GammaL(3);
Error, usage: GeneralSemilinearGroup( [<filter>, ]<d>, <q> )
gap> GammaL(3,6);
Error, <subfield> must be a prime or a finite field

#
gap> STOP_TEST("classic-G.tst", 1);
