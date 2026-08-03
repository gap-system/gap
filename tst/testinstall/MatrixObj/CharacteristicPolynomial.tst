#@local F, l, u, M, rep
gap> START_TEST( "CharacteristicPolynomial.tst" );

# Characteristic and minimal polynomials must be computable for every kind of
# matrix object, and must not depend on the representation used. Matrices in
# IsGenericMatrixRep are the interesting case here, as they do not offer
# access to their rows, which the methods spinning up vectors rely on.
gap> F := GF(257);;
gap> l := [[1,2,3,4],[0,1,2,3],[5,0,1,2],[1,0,0,1]] * One(F);;
gap> u := List(l, ShallowCopy);;
gap> for rep in [ IsPlistMatrixRep, IsGenericMatrixRep ] do
>      M := Matrix(rep, F, l);
>      if CharacteristicPolynomial(F, F, M, 1)
>         <> CharacteristicPolynomial(F, F, u, 1) then
>        Print("wrong characteristic polynomial for ", rep, "\n");
>      fi;
>      if MinimalPolynomial(F, M, 1) <> MinimalPolynomial(F, u, 1) then
>        Print("wrong minimal polynomial for ", rep, "\n");
>      fi;
>    od;

# the same over a small field, where the matrices are compressed
gap> F := GF(5);;
gap> l := [[1,2,3,4],[0,1,2,3],[3,0,1,2],[1,0,0,1]] * One(F);;
gap> u := List(l, ShallowCopy);;
gap> for rep in [ IsPlistMatrixRep, IsGenericMatrixRep ] do
>      M := Matrix(rep, F, l);
>      if CharacteristicPolynomial(F, F, M, 1)
>         <> CharacteristicPolynomial(F, F, u, 1) then
>        Print("wrong characteristic polynomial for ", rep, "\n");
>      fi;
>      if MinimalPolynomial(F, M, 1) <> MinimalPolynomial(F, u, 1) then
>        Print("wrong minimal polynomial for ", rep, "\n");
>      fi;
>    od;

#
gap> STOP_TEST( "CharacteristicPolynomial.tst" );
