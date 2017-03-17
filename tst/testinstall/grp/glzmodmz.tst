gap> START_TEST("glzmodmz.tst");

#
gap> CheckGeneratorsInvertible := function(G)
>   return ForAll(GeneratorsOfGroup(G),
>               g -> not IsZero(Determinant(g)));
> end;;
gap> CheckGeneratorsSpecial := function(G)
>   return ForAll(GeneratorsOfGroup(G),
>               g -> IsOne(Determinant(g)));
> end;;
gap> CheckBilinearForm := function(G)
>   local M;
>   M := InvariantBilinearForm(G).matrix;
>   return ForAll(GeneratorsOfGroup(G),
>               g -> g*M*TransposedMat(g) = M);
> end;;
gap> frob := function(g,aut)
>   return List(g,row->List(row,x->x^aut));
> end;;
gap> CheckSesquilinearForm := function(G)
>   local M, F, aut;
>   M := InvariantSesquilinearForm(G).matrix;
>   F := FieldOfMatrixGroup(G);
>   aut := FrobeniusAutomorphism(F);
>   aut := aut^(DegreeOverPrimeField(F)/2);
>   return ForAll(GeneratorsOfGroup(G),
>               g -> g*M*TransposedMat(frob(g,aut)) = M);
> end;;

#
gap> SizeOfGLdZmodmZ(2,2);
6
gap> SizeOfGLdZmodmZ(2,4);
96
gap> SizeOfGLdZmodmZ(2,1);
Error, GL(2,Integers mod 1) is not a well-defined group, resp. not supported.


#
gap> G:=GL(4,Integers mod 4);
GL(4,Z/4Z)
gap> CheckGeneratorsInvertible(G);
true
gap> H:=SL(4,Integers mod 4);
SL(4,Z/4Z)
gap> CheckGeneratorsSpecial(H);
true
gap> K:=Sp(4,Integers mod 4);
Sp(4,Z/4Z)
gap> CheckGeneratorsSpecial(K) and CheckBilinearForm(K);
true

#
gap> NrMovedPoints(Image(NiceMonomorphism(G : cheap)));;
gap> NrMovedPoints(Image(NiceMonomorphism(H : cheap)));;
gap> NrMovedPoints(Image(NiceMonomorphism(K : cheap)));;

#
gap> IsSubgroup(G,H); IsSubgroup(H,K); IsSubgroup(G,K);
true
true
true

#
gap> Size(G); Size(H); Size(K);
1321205760
660602880
737280

#
gap> K:=Sp(4,Integers mod 9);
Sp(4,Z/9Z)
gap> CheckGeneratorsSpecial(K) and CheckBilinearForm(K);
true
gap> K:=Sp(6,Integers mod 16);
Sp(6,Z/16Z)
gap> CheckGeneratorsSpecial(K) and CheckBilinearForm(K);
true

#
gap> K:=GO(3,Integers mod 9);
GO(3,Z/9Z)
gap> CheckGeneratorsInvertible(K) and CheckBilinearForm(K);
true
gap> K:=GO(+1,4,Integers mod 9);
GO(1,4,Z/9Z)
gap> CheckGeneratorsInvertible(K) and CheckBilinearForm(K);
true
gap> K:=GO(-1,4,Integers mod 9);
GO(-1,4,Z/9Z)
gap> CheckGeneratorsInvertible(K) and CheckBilinearForm(K);
true

#
gap> K:=SO(3,Integers mod 9);
SO(3,Z/9Z)
gap> CheckGeneratorsSpecial(K) and CheckBilinearForm(K);
true
gap> K:=SO(+1,4,Integers mod 9);
SO(1,4,Z/9Z)
gap> CheckGeneratorsSpecial(K) and CheckBilinearForm(K);
true
gap> K:=SO(-1,4,Integers mod 9);
SO(-1,4,Z/9Z)
gap> CheckGeneratorsSpecial(K) and CheckBilinearForm(K);
true

#
gap> STOP_TEST("glzmodmz.tst", 1);
