#
# Tests invariant forms of classic groups
#
gap> START_TEST("classic-forms.tst");

# verify that the generators are invertible / have determinant 1
gap> CheckGeneratorsInvertible := function(G)
>   return ForAll(GeneratorsOfGroup(G),
>               g -> not IsZero(Determinant(g)));
> end;;
gap> CheckGeneratorsSpecial := function(G)
>   return ForAll(GeneratorsOfGroup(G),
>               g -> IsOne(Determinant(g)));
> end;;

# verify that forms are given and preserved
gap> CheckBilinearForm := function(G)
>   local M;
>   M := InvariantBilinearForm(G).matrix;
>   return ForAll(GeneratorsOfGroup(G),
>               g -> g*M*TransposedMat(g) = M);
> end;;
gap> CheckQuadraticForm := function(G)
>   local M, Q;
>   M := InvariantBilinearForm(G).matrix;
>   Q := InvariantQuadraticForm(G).matrix;
>   return Q+TransposedMat(Q) = M;
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

# verify group size if the underlying module is small
gap> CheckSize := function(g)
>    if Size(FieldOfMatrixGroup(g))^DimensionOfMatrixGroup(g) < 1000 then
>        return Size(g) = Size(Group(GeneratorsOfGroup(g)));
>    fi;
>    return true;
> end;;

# odd-dimensional general orthogonal groups
gap> grps:=[];;
gap> for d in [3,5,7] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, GO(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true

# even-dimensional general orthogonal groups
gap> grps:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, GO(+1,d,q));
>     Add(grps, GO(-1,d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true

# odd-dimensional special orthogonal groups
gap> grps:=[];;
gap> for d in [3,5,7] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, SO(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true

# even-dimensional special orthogonal groups
gap> grps:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, SO(+1,d,q));
>     Add(grps, SO(-1,d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true

#
# Omega subgroups of special orthogonal groups
#

# odd-dimensional
gap> grps:=[];;
gap> for d in [3,5,7] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, Omega(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true

# even-dimensional
gap> grps:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, Omega(+1,d,q));
>     if d <> 2 then Add(grps, Omega(-1,d,q)); fi;
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true

#
# unitary groups
#

# general unitary groups
gap> grps:=[];;
gap> for d in [1..6] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, GU(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckSesquilinearForm);
true
gap> ForAll(grps, CheckSize);
true

# special unitary groups
gap> grps:=[];;
gap> for d in [1..6] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, SU(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckSesquilinearForm);
true
gap> ForAll(grps, CheckSize);
true

#
# symplectic groups
#
gap> grps:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, Sp(d,q));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckSize);
true

#
gap> STOP_TEST("classic-forms.tst", 1);
