#@local CheckGeneratorsInvertible, CheckGeneratorsSpecial, CheckField
#@local CheckBilinearForm, CheckQuadraticForm, frob, CheckSesquilinearForm
#@local CheckSize, CheckClasses, CheckMembershipFromForm
#@local CheckMembershipBilinear, CheckMembershipBilinear2
#@local CheckMembershipSesquilinear
#@local CheckMembershipQuadratic, CheckMembershipQuadratic2
#@local grps1, grps2, grps, d, q, G, m
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

# verify `FieldOfMatrixGroup`
gap> CheckField := function(G)
>   return FieldOfMatrixGroup( G )
>          = FieldOfMatrixGroup( Group( GeneratorsOfGroup( G ), One( G ) ) );
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
>   return (Q+TransposedMat(Q) = M) and
>          ForAll(GeneratorsOfGroup(G),
>            g -> RespectsQuadraticForm(Q, g));
> end;;
gap> frob := function(g,aut)
>   return List(g,row->List(row,x->x^aut));
> end;;
gap> CheckSesquilinearForm := function(G)
>   local M, F, aut;
>   M := InvariantSesquilinearForm(G).matrix;
>   F := InvariantSesquilinearForm(G).baseDomain;
>   aut := FrobeniusAutomorphism(F);
>   aut := aut^(DegreeOverPrimeField(F)/2);
>   return ForAll(GeneratorsOfGroup(G),
>               g -> g*M*TransposedMat(frob(g,aut)) = M);
> end;;

# verify group size if the underlying module is small
gap> CheckSize := function(g)
>    if Size(FieldOfMatrixGroup(g))^DimensionOfMatrixGroup(g) < 1000 then
>        return Size(g) = Size(Group(GeneratorsOfGroup(g), One(g)));
>    fi;
>    return true;
> end;;

# verify class numbers if the group is small
gap> CheckClasses:= function( G )
>    if Size(FieldOfMatrixGroup(G))^DimensionOfMatrixGroup(G) < 1000 then
>        return NrConjugacyClasses(G)
>               = NrConjugacyClasses(Group(GeneratorsOfGroup(G), One(G)));
>    fi;
>    return true;
> end;;

# run some membership tests (there are special methods based on forms)
gap> CheckMembershipFromForm:= function( G, form )
>    local full;
>    full:= GL( DimensionOfMatrixGroup( G ), form.baseDomain );
>    return ForAll( [ 1 .. 10 ], i -> PseudoRandom( G ) in G ) and
>           ( ForAny( GeneratorsOfGroup( full ), g -> not ( g in G ) ) or
>             Size( G ) = Size( full ) );
> end;;
gap> CheckMembershipBilinear:= function( G )
>    return HasIsFullSubgroupGLorSLRespectingBilinearForm( G )
>           and IsFullSubgroupGLorSLRespectingBilinearForm( G )
>           and CheckMembershipFromForm( G, InvariantBilinearForm( G ) );
> end;;
gap> CheckMembershipBilinear2:= function( G )
>    if HasIsFullSubgroupGLorSLRespectingBilinearForm( G )
>       and IsFullSubgroupGLorSLRespectingBilinearForm( G ) then
>      return CheckMembershipFromForm( G, InvariantBilinearForm( G ) );
>    fi;
>    return true;
> end;;
gap> CheckMembershipSesquilinear:= function( G )
>    return HasIsFullSubgroupGLorSLRespectingSesquilinearForm( G )
>           and IsFullSubgroupGLorSLRespectingSesquilinearForm( G )
>           and CheckMembershipFromForm( G, InvariantSesquilinearForm( G ) );
> end;;
gap> CheckMembershipQuadratic:= function( G )
>    return HasIsFullSubgroupGLorSLRespectingQuadraticForm( G )
>           and IsFullSubgroupGLorSLRespectingQuadraticForm( G )
>           and CheckMembershipFromForm( G, InvariantQuadraticForm( G ) );
> end;;
gap> CheckMembershipQuadratic2:= function( G )
>    if HasIsFullSubgroupGLorSLRespectingQuadraticForm( G )
>       and IsFullSubgroupGLorSLRespectingQuadraticForm( G ) then
>      return CheckMembershipFromForm( G, InvariantQuadraticForm( G ) );
>    fi;
>    return true;
> end;;

# odd-dimensional general orthogonal groups
gap> grps1:=[];;
gap> grps2:=[];;
gap> for d in [1,3,5,7] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps1, GO(d,q));
>     Add(grps2, GO(d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps2, GO(d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>   od;
> od;
gap> grps:= Concatenation( grps1, grps2 );;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckField);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true
gap> ForAll(grps1, CheckMembershipQuadratic);
true
gap> ForAll(grps2, CheckMembershipQuadratic2);
true

# even-dimensional general orthogonal groups
gap> grps1:=[];;
gap> grps2:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps1, GO(+1,d,q));
>     Add(grps1, GO(-1,d,q));
>     Add(grps2, GO(+1,d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps2, GO(-1,d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps2, GO(+1,d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>     Add(grps2, GO(-1,d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>   od;
> od;
gap> grps:= Concatenation( grps1, grps2 );;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckField);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true
gap> ForAll(grps1, CheckMembershipQuadratic);
true
gap> ForAll(grps2, CheckMembershipQuadratic2);
true

# odd-dimensional special orthogonal groups
gap> grps1:=[];;
gap> grps2:=[];;
gap> for d in [1,3,5,7] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps1, SO(d,q));
>     Add(grps2, SO(d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps2, SO(d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>   od;
> od;
gap> grps:= Concatenation( grps1, grps2 );;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckField);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true
gap> ForAll(grps1, CheckMembershipQuadratic);
true
gap> ForAll(grps2, CheckMembershipQuadratic2);
true

# even-dimensional special orthogonal groups
gap> grps1:=[];;
gap> grps2:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps1, SO(+1,d,q));
>     Add(grps1, SO(-1,d,q));
>     Add(grps2, SO(+1,d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps2, SO(-1,d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps2, SO(+1,d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>     Add(grps2, SO(-1,d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>   od;
> od;
gap> grps:= Concatenation( grps1, grps2 );;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckField);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckQuadraticForm);
true
gap> ForAll(grps, CheckSize);
true
gap> ForAll(grps1, CheckMembershipQuadratic);
true
gap> ForAll(grps2, CheckMembershipQuadratic2);
true

#
# Omega subgroups of special orthogonal groups
#

# odd-dimensional
gap> grps:=[];;
gap> for d in [1,3,5,7] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps, Omega(d,q));
>     Add(grps, Omega(d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps, Omega(d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckField);
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
>     Add(grps, Omega(-1,d,q));
>     Add(grps, Omega(+1,d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps, Omega(-1,d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps, Omega(+1,d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>     Add(grps, Omega(-1,d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>   od;
> od;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckField);
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
gap> grps1:=[];;
gap> grps2:=[];;
gap> for d in [1..6] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps1, GU(d,q));
>     Add(grps1, GU(d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>     Add(grps2, GU(d,q) ^ RandomInvertibleMat(d,GF(q^4)));
>   od;
> od;
gap> grps:= Concatenation( grps1, grps2 );;
gap> ForAll(grps, CheckGeneratorsInvertible);
true
gap> ForAll(grps, CheckField);
true
gap> ForAll(grps1, CheckSesquilinearForm);
true
gap> ForAll(grps, CheckSize);
true
gap> ForAll(grps1, CheckClasses);
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
gap> ForAll(grps, CheckField);
true
gap> ForAll(grps, CheckSesquilinearForm);
true
gap> ForAll(grps, CheckSize);
true
gap> ForAll(grps, CheckClasses);
true
gap> ForAll(grps, CheckMembershipSesquilinear);
true

#
# symplectic groups
#
gap> grps1:=[];;
gap> grps2:=[];;
gap> for d in [2,4,6,8] do
>   for q in [2,3,4,5,7,8,9,16,17,25,27] do
>     Add(grps1, Sp(d,q));
>     Add(grps2, Sp(d,q) ^ RandomInvertibleMat(d,GF(q)));
>     Add(grps2, Sp(d,q) ^ RandomInvertibleMat(d,GF(q^2)));
>   od;
> od;
gap> grps:= Concatenation( grps1, grps2 );;
gap> ForAll(grps, CheckGeneratorsSpecial);
true
gap> ForAll(grps, CheckField);
true
gap> ForAll(grps, CheckBilinearForm);
true
gap> ForAll(grps, CheckSize);
true
gap> ForAll(grps1, CheckMembershipBilinear);
true
gap> ForAll(grps2, CheckMembershipBilinear2);
true

# an undocumented helper function
gap> G:= GeneralOrthogonalGroup( 3, GF(5) );;
gap> m:= [ [ 0, 1, 0 ], [ 0, 0, 0 ], [ 0, 0, 1 ] ] * Z(5)^0;;
gap> SetInvariantQuadraticFormFromMatrix( G, m );
Error, only the three argument variant of SetInvariantQuadraticFormFromMatrix \
is supported, the form record needs a 'baseDomain' component

#
gap> STOP_TEST("classic-forms.tst");
