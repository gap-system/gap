#
# Tests for the "general" group constructors: GL, GO, GU, GammaL
#
#@local G, H, d, q, S, grps, gens, w, form, g, fld

gap> START_TEST("classic-G.tst");

#
gap> GL(1,5); Size(last);
GL(1,5)
4
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
gap> G:=GL(4,3);; List([2,3,5,11,13], p-> Size(SylowSubgroup(G,p)));
[ 512, 729, 5, 1, 13 ]
gap> G:=GL(4,4);; List([2,3,5,11,13], p-> Size(SylowSubgroup(G,p)));
[ 4096, 243, 25, 1, 1 ]
gap> G:=GL(4,5);; List([2,3,5,11,13], p-> Size(SylowSubgroup(G,p)));
[ 2048, 9, 15625, 1, 13 ]
gap> G:=GL(4,7);; List([2,3,5,11,13], p-> Size(SylowSubgroup(G,p)));
[ 2048, 243, 25, 1, 1 ]
gap> G:=GL(5,3);; List([2,3,5,11,13], p-> Size(SylowSubgroup(G,p)));
[ 1024, 59049, 5, 121, 13 ]
gap> G:=GL(5,4);; List([2,3,5,11,13], p-> Size(SylowSubgroup(G,p)));
[ 1048576, 729, 25, 11, 1 ]

# special case: DefaultFieldOfMatrixGroup <> FieldOfMatrixGroup
gap> G:=GL(2,9);
GL(2,9)
gap> H:=Subgroup(G,[G.1^4,G.2]);;
gap> G := GL(2,3);
GL(2,3)
gap> IsNaturalGL(H) and (G=H);
true
gap> DefaultFieldOfMatrixGroup(H);
GF(3^2)
gap> FieldOfMatrixGroup(H);
GF(3)
gap> ForAll([2,3,5], p -> IsConjugate(G, SylowSubgroup(G,2), SylowSubgroup(H,2)));
true

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
gap> IsTrivial( GO(1,3) );
false
gap> IsTrivial( GO(1,4) );
true

#
gap> GO(3);
Error, usage: GeneralOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q>[, <form>] )
or GeneralOrthogonalGroup( [<filt>, ][<e>, ]<d>, <q>[, <form>] )
or GeneralOrthogonalGroup( [<filt>, ]<form> )
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
gap> last = GO(-1,4,GF(9));
true
gap> GO(IsPermGroup,-1,4,9);
Perm_GO(-1,4,9)

#
gap> GO(1,4,9);
GO(+1,4,9)
gap> last = GO(+1,4,GF(9));
true
gap> GO(IsPermGroup,1,4,9);
Perm_GO(+1,4,9)

#
gap> GO(4,9);
Error, sign <e> = 0 but dimension <d> is even
gap> GO(0,4,9);
Error, sign <e> = 0 but dimension <d> is even

#
gap> GU(3,5);
GU(3,5)
gap> GU(IsPermGroup,3,4);
Perm_GU(3,4)
gap> GU(3);
Error, usage: GeneralUnitaryGroup( [<filt>, ]<d>, <q>[, <form>] )
or GeneralUnitaryGroup( [<filt>, ]<form> )
gap> GU(3,6);
Error, <subfield> must be a prime or a finite field

#
gap> GammaL(1,5);
GL(1,5)
gap> GammaL(2,5);
GL(2,5)
gap> GammaL(3,5);
GL(3,5)
gap> GammaL(1,9); Size(last) = SizeGL(1,9) * 2;
GammaL(1,9)
true
gap> GammaL(2,9); Size(last) = SizeGL(2,9) * 2;
GammaL(2,9)
true
gap> GammaL(3,9); Size(last) = SizeGL(3,9) * 2;
GammaL(3,9)
true
gap> GammaL(IsPermGroup,3,9); Size(last) = SizeGL(3,9) * 2;
Perm_GammaL(3,9)
true
gap> GammaL(3);
Error, usage: GeneralSemilinearGroup( [<filter>, ]<d>, <q> )
gap> GammaL(3,6);
Error, <subfield> must be a prime or a finite field

#
gap> Omega(1,2);
GO(0,1,2)
gap> Omega(1,3);
SO(0,1,3)
gap> Omega(3,2);
GO(0,3,2)
gap> Omega(3,3);
Omega(0,3,3)
gap> Omega(5,2);
GO(0,5,2)
gap> Omega(5,3);
Omega(0,5,3)
gap> Omega( 5, GF(3) );
Omega(0,5,3)

#
gap> Omega(+1,2,2);
Omega(+1,2,2)
gap> Omega(+1,2,3);
Omega(+1,2,3)
gap> Omega(+1,4,2);
Omega(+1,4,2)
gap> Omega(+1,4,3);
Omega(+1,4,3)
gap> Omega( +1, 4, GF(3) );
Omega(+1,4,3)

#
gap> Omega(-1,2,2);
Omega(-1,2,2)
gap> Omega(-1,2,3);
Omega(-1,2,3)
gap> Omega(-1,4,2);
Omega(-1,4,2)
gap> Omega(-1,4,3);
Omega(-1,4,3)

#
gap> Omega( IsPermGroup, 5, GF(3) );
Perm_Omega(0,5,3)
gap> Omega( IsPermGroup, +1, 4, GF(3) );
Perm_Omega(+1,4,3)

#
gap> Omega(0,2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Omega' on 2 arguments
gap> Omega(-1,0,2);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `Omega' on 3 arguments

#
gap> Omega(2,2);
Error, sign <e> = 0 but dimension <d> is even

# Tests for IsSquare
gap> fld := GF(3^2);;
gap> IsSquareFFE(fld,Zero(fld));
true
gap> IsSquareFFE(fld,Z(3^2)^6);
true
gap> IsSquareFFE(fld,Z(3^2)^7);
false
gap> fld := GF(2^2);;
gap> IsSquareFFE(fld,PseudoRandom(fld));
true

# Tests for SpinorNorm
gap> G := Omega(1,4,3);;
gap> gens := GeneratorsOfGroup(G);;
gap> form := G!.InvariantBilinearForm.matrix;;
gap> SpinorNorm(form,GF(3),gens[1]);
Z(3)^0
gap> SpinorNorm(form,GF(3),gens[2]);
Z(3)^0
gap> w := PrimitiveElement(GF(3));;
gap> g := IdentityMat(4,GF(3));;
gap> SpinorNorm(form,GF(3),g);
Z(3)^0
gap> g[1,1] := w^3;;
gap> g[4,4] := w^(-3);;
gap> SpinorNorm(form,GF(3),g);
Z(3)

# Membership tests in GL, SL, GO, SO, GU, SU, Sp can be delegated
# to the tests of the stored respected forms and therefore are cheap.
gap> for d in [ 1 .. 10 ] do
>   for q in Filtered( [ 2 .. 30 ], IsPrimePowerInt ) do
>     G:= GL(d,q);
>     S:= SL(d,q);
>     if Size( G ) <> Size( S ) and
>        ForAll( GeneratorsOfGroup( G ), g -> g in S ) then
>       Error( "wrong membership test" );
>     fi;
>     grps:= [];
>     if Length( Factors( q ) ) mod 2 = 0 then
>       Append( grps, [ GU(d, RootInt( q )), SU(d, RootInt( q )) ] );
>     fi;
>     if d mod 2 = 0 then
>       Append( grps, [ GO(-1,d,q), GO(1,d,q) ] );
>       Add( grps, Sp(d,q) );
>     else
>       Add( grps, GO(d,q) );
>     fi;
>     if ForAny( grps,
>            U -> ( Size( U ) < Size( G ) and
>                   ForAll( GeneratorsOfGroup( G ), g -> g in U ) ) or
>                 ( Size( U ) < Size( S ) and
>                   ForAll( GeneratorsOfGroup( S ), g -> g in U ) ) or
>                 ForAny( [ 1 .. 20 ],
>                         i -> not PseudoRandom( U ) in U ) ) then
>       Error( "wrong membership test" );
>     fi;
>   od;
> od;

#
gap> STOP_TEST("classic-G.tst", 1);
