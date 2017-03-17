#
# Tests invariant forms of classic groups
# TODO: also test quadratic forms
#
gap> START_TEST("classic-forms.tst");

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

# odd-dimensional general orthogonal groups
gap> grps:=[];;
gap> for d in [3,5,7] do
>   for q in [2,3,4,5,7,8,9] do
>     Add(grps, GO(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckBilinearForm);
true

# even-dimensional general orthogonal groups
gap> grps:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9] do
>     Add(grps, GO(+1,d,q));
>     Add(grps, GO(-1,d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckBilinearForm);
true

# odd-dimensional special orthogonal groups
gap> grps:=[];;
gap> for d in [3,5,7] do
>   for q in [2,3,4,5,7,8,9] do
>     Add(grps, SO(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckBilinearForm);
true

# even-dimensional special orthogonal groups
gap> grps:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9] do
>     Add(grps, SO(+1,d,q));
>     Add(grps, SO(-1,d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckBilinearForm);
true

#
# unitary groups
#

# general unitary groups
gap> grps:=[];;
gap> for d in [2..6] do
>   for q in [2,3,4,5,7,8,9] do
>     Add(grps, GU(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckSesquilinearForm);
true

# TODO: dimension 1 does not have InvariantSesquilinearForm set
gap> GU(1,2);
GU(1,2)
gap> GU(1,5);
GU(1,5)

# special unitary groups
gap> grps:=[];;
gap> for d in [2..6] do
>   for q in [2,3,4,5,7,8,9] do
>     Add(grps, SU(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckSesquilinearForm);
true

# TODO: dimension 1 does not have InvariantSesquilinearForm set
gap> SU(1,2);
SL(1,2)
gap> SU(1,5);
SL(1,5)

#
gap> STOP_TEST("classic-forms.tst", 1);
