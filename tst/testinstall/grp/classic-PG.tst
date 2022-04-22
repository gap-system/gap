#
# Tests for the "projective general" group constructors:
# PGL, PGO, POmega, PGU, PGammaL
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
gap> G:= PGO( 3, 5 );;  Size( G );
120
gap> G = PGO( 0, 3, 5 );
true
gap> G = PGO( IsPermGroup, 3, 5 );
true
gap> G = PGO( IsPermGroup, 0, 3, 5 );
true
gap> G:= PGO( 1, 4, 5 );;  Size( G );
14400
gap> G = PGO( IsPermGroup, 1, 4, 5 );
true
gap> G:= PGO( -1, 4, 5 );;  Size( G );
15600
gap> G = PGO( IsPermGroup, -1, 4, 5 );
true

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
gap> for d in [ 1, 3, 5, 7 ] do
>      for q in [ 2, 3, 4, 5 ] do
>        for cons in [ PGO, PSO, POmega ] do
>          G:= cons( d, q );
>          if Size( G ) <> Size( GroupByGenerators( GeneratorsOfGroup( G ),
>                                                   One( G ) ) ) then
>            Error( "problem with group order for ", [ d, q ], "\n" );
>          fi;
>        od;
>      od;
>    od;
gap> for d in [ 2, 4, 6 ] do
>      for q in [ 2, 3, 4, 5 ] do
>        for cons in [ PGO, PSO, POmega ] do
>          G:= cons( 1, d, q );
>          if Size( G ) <> Size( GroupByGenerators( GeneratorsOfGroup( G ),
>                                                   One( G ) ) ) then
>            Error( [ d, q ] );
>          fi;
>          G:= cons( -1, d, q );
>          if Size( G ) <> Size( GroupByGenerators( GeneratorsOfGroup( G ),
>                                                   One( G ) ) ) then
>            Error( [ d, q ] );
>          fi;
>        od;
>      od;
>    od;

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
gap> PGammaL( 2, 5 ) = PGL( 2, 5 );
true
gap> Size( PGammaL( 2, 25 ) );
31200
gap> SetX( [1..3], [2, 3, 5], [1..3], {n, p, d} -> Size( PGammaL( n, p^d ) ) = Size( PGL( n, p^d ) ) * d );
[ true ]
gap> PGammaL( IsPermGroup, 3, 9) = PGammaL( 3, 9 );
true
gap> PGammaL( 3, GF(9) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ProjectiveGeneralSemilinearGroupCons' o\
n 3 arguments
gap> PGammaL( 3 );
Error, usage: ProjectiveGeneralSemilinearGroup( [<filter>, ]<d>, <q> )
gap> PGammaL( 3, 6 );
Error, usage: GeneralLinearGroup( [<filter>, ]<d>, <R> )

#
gap> STOP_TEST("classic-PG.tst", 1);
