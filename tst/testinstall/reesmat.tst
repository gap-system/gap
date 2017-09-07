#############################################################################
##
#W  reesmat.tst                GAP library                Wilf A. Wilson
##
##
#Y  Copyright (C)  2017, The GAP Group
##
gap> START_TEST("reesmat.tst");

# IsFinite: ImmediateMethod, for IsReesZeroMatrixSubsemigroup, 1
gap> F := FreeSemigroup(2);
<free semigroup on the generators [ s1, s2 ]>
gap> S := F / [[F.1 ^ 2, F.1], [F.2, F.1]];
<fp semigroup on the generators [ s1, s2 ]>
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, 0]]);
<Rees 0-matrix semigroup 2x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> HasIsFinite(R);
false
gap> U := Semigroup(RMSElement(R, 1, S.1, 1));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 1 generator>
gap> HasIsFinite(U);
false
gap> IsFinite(S);
true
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, 0]]);
<Rees 0-matrix semigroup 2x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> HasIsFinite(R) and IsFinite(R);
true
gap> U := Semigroup(RMSElement(R, 1, S.1, 1));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 1 generator>
gap> HasIsFinite(U) and IsFinite(U);
true

# IsFinite: ImmediateMethod, for IsReesZeroMatrixSubsemigroup, 2
gap> R := ReesZeroMatrixSemigroup(SymmetricGroup(3), [[(), 0]]);
<Rees 0-matrix semigroup 2x1 over Sym( [ 1 .. 3 ] )>
gap> HasIsFinite(R) and IsFinite(R);
true
gap> U := Semigroup(RMSElement(R, 1, (), 1));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 1 generator>
gap> HasIsFinite(U) and IsFinite(U);
true

# IsFinite: ImmediateMethod, for IsReesZeroMatrixSubsemigroup, 3
gap> F := FreeSemigroup(1);;
gap> R := ReesZeroMatrixSemigroup(F, [[F.1]]);;
gap> HasIsFinite(R);
true
gap> IsFinite(R);
false
gap> U := Semigroup(MultiplicativeZero(R));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 1 generator>
gap> HasIsFinite(U);
false

# IsFinite: ImmediateMethod, for IsReesMatrixSubsemigroup, 1
gap> F := FreeSemigroup(2);
<free semigroup on the generators [ s1, s2 ]>
gap> S := F / [[F.1 ^ 2, F.1], [F.2, F.1]];
<fp semigroup on the generators [ s1, s2 ]>
gap> R := ReesMatrixSemigroup(S, [[S.1, S.2]]);
<Rees matrix semigroup 2x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> HasIsFinite(R);
false
gap> U := Semigroup(RMSElement(R, 1, S.1, 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> HasIsFinite(U);
false
gap> IsFinite(S);
true
gap> R := ReesMatrixSemigroup(S, [[S.1, S.2]]);
<Rees matrix semigroup 2x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> HasIsFinite(R) and IsFinite(R);
true
gap> U := Semigroup(RMSElement(R, 1, S.1, 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> HasIsFinite(U) and IsFinite(U);
true

# IsFinite: ImmediateMethod, for IsZeroMatrixSubsemigroup, 2
gap> R := ReesMatrixSemigroup(SymmetricGroup(3), [[(), (1,2,3)]]);
<Rees matrix semigroup 2x1 over Sym( [ 1 .. 3 ] )>
gap> HasIsFinite(R) and IsFinite(R);
true
gap> U := Semigroup(RMSElement(R, 1, (), 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> HasIsFinite(U) and IsFinite(U);
true

# IsFinite: ImmediateMethod, for IsZeroMatrixSubsemigroup, 3
gap> F := FreeMonoid(1);;
gap> R := ReesMatrixSemigroup(F, [[F.1]]);;
gap> HasIsFinite(R);
true
gap> IsFinite(R);
false
gap> U := Semigroup(RMSElement(R, 1, One(F), 1));
<subsemigroup of 1x1 Rees matrix semigroup with 1 generator>
gap> HasIsFinite(U);
false

# IsFinite: for a Rees 0-matrix subsemigroup, 1
gap> F := FreeSemigroup(1);;
gap> R := ReesZeroMatrixSemigroup(F, [[F.1]]);
<Rees 0-matrix semigroup 1x1 over <free semigroup on the generators [ s1 ]>>
gap> S := Semigroup(MultiplicativeZero(R));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 1 generator>
gap> HasIsFinite(S);
false
gap> IsFinite(S);
true

# IsFinite: for a Rees 0-matrix subsemigroup, 2
gap> F := FreeSemigroup(2);
<free semigroup on the generators [ s1, s2 ]>
gap> S := F / [[F.1 ^ 2, F.1], [F.2, F.1]];
<fp semigroup on the generators [ s1, s2 ]>
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, 0]]);
<Rees 0-matrix semigroup 2x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> U := Semigroup(RMSElement(R, 1, S.1, 1));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 1 generator>
gap> HasIsFinite(U);
false
gap> IsFinite(R);
true
gap> IsFinite(U);
true

# IsFinite: for a Rees 0-matrix subsemigroup, 3
gap> F := FreeSemigroup(2);
<free semigroup on the generators [ s1, s2 ]>
gap> S := F / [[F.1 ^ 2, F.1], [F.2, F.1]];
<fp semigroup on the generators [ s1, s2 ]>
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, 0]]);
<Rees 0-matrix semigroup 2x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> U := Semigroup(RMSElement(R, 1, S.1, 1));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 1 generator>
gap> HasIsFinite(U);
false
gap> IsFinite(U);
true

# IsFinite: for a Rees matrix subsemigroup, 1
gap> F := FreeMonoid(1);
<free monoid on the generators [ m1 ]>
gap> R := ReesMatrixSemigroup(F, [[One(F)]]);
<Rees matrix semigroup 1x1 over <free monoid on the generators [ m1 ]>>
gap> S := Semigroup(RMSElement(R, 1, One(F), 1));
<subsemigroup of 1x1 Rees matrix semigroup with 1 generator>
gap> HasIsFinite(S);
false
gap> IsFinite(S);
true

# IsFinite: for a Rees matrix subsemigroup, 2
gap> F := FreeSemigroup(2);
<free semigroup on the generators [ s1, s2 ]>
gap> S := F / [[F.1 ^ 2, F.1], [F.2, F.1]];
<fp semigroup on the generators [ s1, s2 ]>
gap> R := ReesMatrixSemigroup(S, [[S.1, S.2]]);
<Rees matrix semigroup 2x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> U := Semigroup(RMSElement(R, 1, S.1, 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> HasIsFinite(U);
false
gap> IsFinite(R);
true
gap> IsFinite(U);
true

# IsFinite: for a Rees matrix subsemigroup, 3
gap> F := FreeSemigroup(2);
<free semigroup on the generators [ s1, s2 ]>
gap> S := F / [[F.1 ^ 2, F.1], [F.2, F.1]];
<fp semigroup on the generators [ s1, s2 ]>
gap> R := ReesMatrixSemigroup(S, [[S.1, S.2]]);
<Rees matrix semigroup 2x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> U := Semigroup(RMSElement(R, 1, S.1, 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> HasIsFinite(U);
false
gap> IsFinite(U);
true

# IsIdempotent: for a Rees 0-matrix semigroup element, 1
gap> R := ReesZeroMatrixSemigroup(SymmetricGroup(3), [[(1,2,3), 0]]);
<Rees 0-matrix semigroup 2x1 over Sym( [ 1 .. 3 ] )>
gap> IsIdempotent(MultiplicativeZero(R));
true
gap> Number(R, IsIdempotent);
2
gap> Set(Filtered(R, IsIdempotent));
[ 0, (1,(1,3,2),1) ]

# IsIdempotent: for a Rees 0-matrix semigroup element, 1
gap> S := FullTransformationSemigroup(2);
<full transformation monoid of degree 2>
gap> R := ReesZeroMatrixSemigroup(S, [[IdentityTransformation, 0]]);
<Rees 0-matrix semigroup 2x1 over <full transformation monoid of degree 2>>
gap> x := Filtered(R, IsIdempotent);;
gap> x = Filtered(R, s -> s * s = s);
true

# IsRegularSemigroup: for a Rees matrix semigroup, 1
gap> R := ReesMatrixSemigroup(SymmetricGroup(3), [[(1, 3)], [()]]);
<Rees matrix semigroup 1x2 over Sym( [ 1 .. 3 ] )>
gap> IsRegularSemigroup(R);
true

# IsRegularSemigroup: for a Rees 0-matrix semigroup, 1
gap> S := InverseMonoid(PartialPerm([1]));
<trivial partial perm group of rank 1 with 1 generator>
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, S.1], [0, 0]]);;
gap> IsRegularSemigroup(R);
false
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, 0], [S.1, 0]]);;
gap> IsRegularSemigroup(R);
false
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, 0], [0, S.1]]);;
gap> IsRegularSemigroup(R);
true
gap> S := FullTransformationMonoid(2);
<full transformation monoid of degree 2>
gap> R := ReesZeroMatrixSemigroup(S, [[One(S)]]);
<Rees 0-matrix semigroup 1x1 over <full transformation monoid of degree 2>>
gap> IsRegularSemigroup(R);
true

# IsSimpleSemigroup: for a Rees matrix subsemigroup with an underlying semigroup
gap> S := FullTransformationMonoid(2);
<full transformation monoid of degree 2>
gap> R := ReesMatrixSemigroup(S, [[One(S)]]);
<Rees matrix semigroup 1x1 over <full transformation monoid of degree 2>>
gap> IsSimpleSemigroup(R);
false
gap> S := Semigroup([Transformation([1, 1]), Transformation([2, 2])]);
<transformation semigroup of degree 2 with 2 generators>
gap> R := ReesMatrixSemigroup(S, [[S.1, S.2]]);
<Rees matrix semigroup 2x1 over <transformation semigroup of degree 2 with 2 
  generators>>
gap> IsSimpleSemigroup(R);
true
gap> T := Semigroup(RMSElement(R, 2, S.1, 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> IsSimpleSemigroup(T);
true

# IsZeroSimpleSemigroup: for a Rees 0-matrix semigroup
gap> S := Semigroup([Transformation([1, 1]), Transformation([2, 2])]);
<transformation semigroup of degree 2 with 2 generators>
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, 0, 0], [0, S.1, 0]]);;
gap> IsZeroSimpleSemigroup(R);
false
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, S.1, S.1], [0, 0, 0]]);;
gap> IsZeroSimpleSemigroup(R);
false
gap> R := ReesZeroMatrixSemigroup(S, [[S.1, 0, S.2], [0, S.1, 0]]);;
gap> IsZeroSimpleSemigroup(R);
true
gap> R := ReesZeroMatrixSemigroup(FullTransformationMonoid(2),
>                                 [[IdentityTransformation]]);;
gap> IsZeroSimpleSemigroup(R);
false

# IsReesMatrixSemigroup: for a semigroup
gap> IsReesMatrixSemigroup(FullTransformationMonoid(2));
false

# IsReesMatrixSemigroup: for a Rees matrix subsemigroup with generators, 1
gap> R := ReesMatrixSemigroup(SymmetricGroup(2), [[(1,2)]]);
<Rees matrix semigroup 1x1 over Sym( [ 1 .. 2 ] )>
gap> IsReesMatrixSemigroup(R);
true
gap> S := Semigroup(Elements(R));
<subsemigroup of 1x1 Rees matrix semigroup with 2 generators>
gap> IsReesMatrixSemigroup(S);
true

# IsReesMatrixSemigroup: for a Rees matrix subsemigroup with generators, 2
gap> S := SymmetricInverseMonoid(2);
<symmetric inverse monoid of degree 2>
gap> z := PartialPerm([0]);
<empty partial perm>
gap> R := ReesMatrixSemigroup(S, [[One(S), One(S)], [One(S), z]]);
<Rees matrix semigroup 2x2 over <symmetric inverse monoid of degree 2>>
gap> T := Semigroup(RMSElement(R, 1, One(S), 1), RMSElement(R, 2, One(S), 2));
<subsemigroup of 2x2 Rees matrix semigroup with 2 generators>
gap> IsReesMatrixSemigroup(T);
true
gap> R := ReesMatrixSemigroup(S, [[One(S), z], [z, z]]);
<Rees matrix semigroup 2x2 over <symmetric inverse monoid of degree 2>>
gap> T := Semigroup(RMSElement(R, 1, One(S), 1), RMSElement(R, 2, One(S), 2));
<subsemigroup of 2x2 Rees matrix semigroup with 2 generators>
gap> IsReesMatrixSemigroup(T);
false

# IsReesZeroMatrixSemigroup: for a semigroup
gap> IsReesZeroMatrixSemigroup(FullTransformationMonoid(2));
false

# IsReesZeroMatrixSemigroup: for a Rees matrix subsemigroup with generators, 1
gap> R := ReesZeroMatrixSemigroup(SymmetricGroup(2), [[(1,2)]]);
<Rees 0-matrix semigroup 1x1 over Sym( [ 1 .. 2 ] )>
gap> IsReesZeroMatrixSemigroup(R);
true
gap> S := Semigroup(Elements(R));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 3 generators>
gap> IsReesZeroMatrixSemigroup(S);
true
gap> S := Semigroup(RMSElement(R, 1, (1,2), 1));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 1 generator>
gap> IsReesZeroMatrixSemigroup(S);
false
gap> S := Semigroup(MultiplicativeZero(R), MultiplicativeZero(R));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 2 generators>
gap> IsReesZeroMatrixSemigroup(S);
false

# IsReesZeroMatrixSemigroup: for a Rees matrix subsemigroup with generators, 1
gap> R := ReesZeroMatrixSemigroup(SymmetricGroup(2), [[(1,2)]]);
<Rees 0-matrix semigroup 1x1 over Sym( [ 1 .. 2 ] )>
gap> S := Semigroup(RMSElement(R, 1, (1,2), 1), MultiplicativeZero(R));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 2 generators>
gap> IsReesZeroMatrixSemigroup(S);
false
gap> R := ReesZeroMatrixSemigroup(SymmetricGroup(2), [[()]]);
<Rees 0-matrix semigroup 1x1 over Sym( [ 1 .. 2 ] )>
gap> S := Semigroup(RMSElement(R, 1, (), 1), MultiplicativeZero(R));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 2 generators>
gap> IsReesZeroMatrixSemigroup(S);
true

# ReesMatrixSemigroup: for a semigroup and a rectangular table, 1
gap> ReesMatrixSemigroup(SymmetricGroup(2), [[PartialPerm([0])]]);
Error, the entries of the second argument (a rectangular table) must belong to\
 the first argument (a semigroup)

# ReesZeroMatrixSemigroup: for a semigroup and a dense list
gap> ReesZeroMatrixSemigroup(Group(()), []);
Error, the second argument must be a non-empty list, whose entries are non-emp\
ty lists of equal length
gap> ReesZeroMatrixSemigroup(Group(()), [[]]);
Error, the second argument must be a non-empty list, whose entries are non-emp\
ty lists of equal length
gap> ReesZeroMatrixSemigroup(Group(()), [[1, 2], []]);
Error, the second argument must be a non-empty list, whose entries are non-emp\
ty lists of equal length
gap> ReesZeroMatrixSemigroup(Group(()), [[1, 2, 3], [1, 2, 3], [1,, 3]]);
Error, the second argument must be a non-empty list, whose entries are non-emp\
ty lists of equal length
gap> ReesZeroMatrixSemigroup(Group(()), [[1]]);
Error, the entries of the second argument must be 0 or belong to the first arg\
ument (a semigroup)

# PrintObj: for a Rees matrix semigroup
gap> R := ReesMatrixSemigroup(Group(()), [[()]]);
<Rees matrix semigroup 1x1 over Group(())>
gap> PrintObj(R); Print("\n");
ReesMatrixSemigroup( Group( [ () ] ), [ [ () ] ] )

# PrintObj: for a Rees 0-matrix semigroup
gap> R := ReesZeroMatrixSemigroup(Group(()), [[()]]);
<Rees 0-matrix semigroup 1x1 over Group(())>
gap> PrintObj(R); Print("\n");
ReesZeroMatrixSemigroup( Group( [ () ] ), [ [ () ] ] )

# Size: for a Rees matrix semigroup
gap> Size(ReesMatrixSemigroup(SymmetricGroup(3), [[()], [()]]));
12
gap> F := FreeSemigroup(1);;
gap> Size(ReesMatrixSemigroup(F, [[F.1]]));
infinity
gap> F := FreeSemigroup(2);;
gap> S := F / [[F.1, F.1], [F.1, F.1]];
<fp semigroup on the generators [ s1, s2 ]>
gap> R := ReesMatrixSemigroup(S, [[S.1]]);
<Rees matrix semigroup 1x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> HasIsFinite(S);
false
gap> SetIsFinite(S, false);
gap> Size(R);
infinity

# Size: for a Rees 0-matrix semigroup
gap> Size(ReesZeroMatrixSemigroup(SymmetricGroup(3), [[()], [()]]));
13
gap> F := FreeSemigroup(1);;
gap> Size(ReesZeroMatrixSemigroup(F, [[F.1]]));
infinity
gap> F := FreeSemigroup(2);;
gap> S := F / [[F.1, F.1], [F.1, F.1]];
<fp semigroup on the generators [ s1, s2 ]>
gap> R := ReesZeroMatrixSemigroup(S, [[S.1]]);
<Rees 0-matrix semigroup 1x1 over <fp semigroup on the generators [ s1, s2 ]>>
gap> HasIsFinite(S);
false
gap> SetIsFinite(S, false);
gap> Size(R);
infinity

# Enumerator: for a Rees matrix semigroup
gap> R := ReesMatrixSemigroup(SymmetricGroup(2), [[()]]);
<Rees matrix semigroup 1x1 over Sym( [ 1 .. 2 ] )>
gap> enum := Enumerator(R);
<enumerator of Rees matrix semigroup>
gap> enum[1];
(1,(),1)
gap> Position(enum, enum[1]);
1
gap> enum[2];
(1,(1,2),1)
gap> Position(enum, enum[2]);
2
gap> S := ReesZeroMatrixSemigroup(Group(()), [[(), ()]]);;
gap> Position(enum, RMSElement(S, 2, (), 1));
fail
gap> S := ReesMatrixSemigroup(SymmetricGroup(2), [[()]]);;
gap> Position(enum, RMSElement(S, 1, (), 1));
fail

# Enumerator: for a Rees 0-matrix semigroup
gap> R := ReesZeroMatrixSemigroup(SymmetricGroup(2), [[()]]);
<Rees 0-matrix semigroup 1x1 over Sym( [ 1 .. 2 ] )>
gap> enum := Enumerator(R);;
gap> enum[Position(enum, enum[1])] = enum[1];
true
gap> enum[Position(enum, enum[2])] = enum[2];
true
gap> enum[Position(enum, enum[3])] = enum[3];
true
gap> S := ReesZeroMatrixSemigroup(Group(()), [[(), ()]]);;
gap> Position(enum, RMSElement(S, 2, (), 1));
fail
gap> S := ReesZeroMatrixSemigroup(SymmetricGroup(2), [[()]]);;
gap> Position(enum, RMSElement(S, 1, (), 1));
fail
gap> R := ReesZeroMatrixSemigroup(SymmetricGroup(2), [[(), 0]]);;
gap> T := ReesZeroMatrixSubsemigroup(R, [1, 2], Group(()), [1]);;
gap> SetIsReesZeroMatrixSemigroup(T, true);
gap> SetUnderlyingSemigroup(T, Group(()));
gap> enum := Enumerator(T);;
gap> Position(enum, RMSElement(R, 1, (1,2), 1));
fail

# Matrix, Rows, Columns, UnderlyingSemigroup:
# for a Rees 0-matrix subsemigroup with generators
gap> R := ReesMatrixSemigroup(Group((1,2)), [[(1,2), ()]]);;
gap> T := Semigroup(RMSElement(R, 2, (), 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> Matrix(T);
[ [ (1,2), () ] ]
gap> Rows(T);
[ 2 ]
gap> Columns(T);
[ 1 ]
gap> UnderlyingSemigroup(T);
Group(())
gap> T := Semigroup(RMSElement(R, 2, (), 1), RMSElement(R, 2, (1,2), 1));
<subsemigroup of 2x1 Rees matrix semigroup with 2 generators>
gap> UnderlyingSemigroup(T);
Group([ (1,2) ])
gap> S := Semigroup(RMSElement(R, 1, (1,2), 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> Matrix(S);
fail
gap> Rows(S);
fail
gap> Columns(S);
fail
gap> UnderlyingSemigroup(S);
fail
gap> R := ReesMatrixSemigroup(FullTransformationMonoid(2),
>                             [[IdentityTransformation]]);;
gap> T := Semigroup(RMSElement(R, 1, Transformation([2, 2]), 1),
>                   RMSElement(R, 1, Transformation([1, 1]), 1));
<subsemigroup of 1x1 Rees matrix semigroup with 2 generators>
gap> UnderlyingSemigroup(T);
<simple transformation semigroup of degree 2 with 2 generators>

# Matrix, Rows, Columns, UnderlyingSemigroup:
# for a Rees matrix subsemigroup with generators
gap> R := ReesZeroMatrixSemigroup(Group((1,2)), [[(1,2), 0]]);;
gap> T := Semigroup(RMSElement(R, 2, (), 1), MultiplicativeZero(R));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 2 generators>
gap> Matrix(T);
[ [ (1,2), 0 ] ]
gap> Rows(T);
[ 2 ]
gap> Columns(T);
[ 1 ]
gap> UnderlyingSemigroup(T);
Group(())
gap> T := Semigroup(RMSElement(R, 2, (), 1), RMSElement(R, 2, (1,2), 1));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 2 generators>
gap> UnderlyingSemigroup(T);
Group([ (1,2) ])
gap> S := Semigroup(RMSElement(R, 1, (1,2), 1), MultiplicativeZero(R));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 2 generators>
gap> Matrix(S);
fail
gap> Rows(S);
fail
gap> Columns(S);
fail
gap> UnderlyingSemigroup(S);
fail
gap> R := ReesZeroMatrixSemigroup(FullTransformationMonoid(2),
>                                 [[IdentityTransformation]]);;
gap> T := Semigroup(RMSElement(R, 1, Transformation([2, 2]), 1),
>                   RMSElement(R, 1, Transformation([1, 1]), 1),
>                   MultiplicativeZero(R));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 3 generators>
gap> UnderlyingSemigroup(T);
<transformation semigroup of degree 2 with 2 generators>

# TypeReesMatrixSemigroupElements: for a Rees (0-)matrix semigroup
gap> R := ReesZeroMatrixSemigroup(Group(()), [[()]]);;
gap> TypeReesMatrixSemigroupElements(Semigroup(Representative(R)));
<Type: (ReesZeroMatrixSemigroupElementsFamily, [ IsExtLElement, IsExtRElement,\
 IsMultiplicativeElement, ... ]), data: fail,>
gap> R := ReesMatrixSemigroup(Group(()), [[()]]);;
gap> TypeReesMatrixSemigroupElements(Semigroup(Representative(R)));
<Type: (ReesMatrixSemigroupElementsFamily, [ IsExtLElement, IsExtRElement, IsM\
ultiplicativeElement, ... ]), data: fail,>

# RMSElement global function
gap> R := ReesZeroMatrixSemigroup(SymmetricGroup(2), [[(1,2), 0], [0, ()]]);;
gap> T := Semigroup(RMSElement(R, 2, (1,2), 1),
>                   RMSElement(R, 2, (), 1));
<subsemigroup of 2x2 Rees 0-matrix semigroup with 2 generators>
gap> RMSElement(SymmetricGroup(2), fail, fail, fail);
Error, the first argument must be a Rees matrix semigroup or Rees 0-matrix sem\
igroup
gap> RMSElement(T, 2, (), 2);
Error, the arguments do not describe an element of the first argument (a Rees \
(0-)matrix semigroup)
gap> RMSElement(T, 2, (), 1);
(2,(),1)
gap> IsReesZeroMatrixSemigroup(T);
true
gap> RMSElement(T, 1, (), 1);
Error, the second argument (a positive integer) does not belong to the rows of\
 the first argument (a Rees (0-)matrix semigroup)
gap> RMSElement(T, 2, (), 2);
Error, the fourth argument (a positive integer) does not belong to the columns\
 of the first argument (a Rees (0-)matrix semigroup)
gap> RMSElement(T, 2, (1,2,3), 1);
Error, the second argument does not belong to theunderlying semigroup of the f\
irst argument (a Rees (0-)matrix semgiroup)
gap> RMSElement(T, 2, (1,2), 1);
(2,(1,2),1)

# (Row/Column/UnderlyingElement)OfReesMatrixSemigroupElement
gap> R := ReesMatrixSemigroup(Group(()), [[()]]);;
gap> x := Elements(R)[1];
(1,(),1)
gap> RowOfReesMatrixSemigroupElement(x);
1
gap> ColumnOfReesMatrixSemigroupElement(x);
1
gap> UnderlyingElementOfReesMatrixSemigroupElement(x);
()

# (Row/Column/UnderlyingElement)OfReesZeroMatrixSemigroupElement
gap> R := ReesZeroMatrixSemigroup(Group(()), [[()]]);;
gap> x := RMSElement(R, 1, (), 1);
(1,(),1)
gap> RowOfReesZeroMatrixSemigroupElement(x);
1
gap> ColumnOfReesZeroMatrixSemigroupElement(x);
1
gap> UnderlyingElementOfReesZeroMatrixSemigroupElement(x);
()
gap> x := MultiplicativeZero(R);
0
gap> RowOfReesZeroMatrixSemigroupElement(x);
fail
gap> ColumnOfReesZeroMatrixSemigroupElement(x);
fail
gap> UnderlyingElementOfReesZeroMatrixSemigroupElement(x);
fail

# PrintObj: for Rees (0-)matrix semigroup elements
gap> R := ReesZeroMatrixSemigroup(Group(()), [[0]]);;
gap> x := RMSElement(R, 1, (), 1);;
gap> PrintObj(x); Print("\n");
RMSElement(ReesZeroMatrixSemigroup( Group( [ () ] ), [ [ 0 ] ] ), 1, (), 1)
gap> PrintObj(MultiplicativeZero(R)); Print("\n");
MultiplicativeZero(ReesZeroMatrixSemigroup( Group( [ () ] ), [ [ 0 ] ] ))
gap> R := ReesMatrixSemigroup(Group(()), [[()]]);;
gap> x := RMSElement(R, 1, (), 1);;
gap> PrintObj(x); Print("\n");
RMSElement(ReesMatrixSemigroup( Group( [ () ] ), [ [ () ] ] ), 1, (), 1)

# ELM_LIST: for a Rees (0-)matrix semigroup element
gap> R := ReesZeroMatrixSemigroup(Group(()), [[0]]);;
gap> x := RMSElement(R, 1, (), 1);
(1,(),1)
gap> x[1];
1
gap> x[2];
()
gap> x[3];
1
gap> x[4];
Error, the second argument must be 1, 2, or 3
gap> x := MultiplicativeZero(R);
0
gap> x[1];
Error, the first argument (an element of a Rees 0-matrix semigroup) must be no\
n-zero
gap> x[2];
Error, the first argument (an element of a Rees 0-matrix semigroup) must be no\
n-zero
gap> x[3];
Error, the first argument (an element of a Rees 0-matrix semigroup) must be no\
n-zero
gap> x[4];
Error, the first argument (an element of a Rees 0-matrix semigroup) must be no\
n-zero
gap> R := ReesMatrixSemigroup(Group(()), [[()]]);;
gap> x := RMSElement(R, 1, (), 1);
(1,(),1)
gap> x[1];
1
gap> x[2];
()
gap> x[3];
1
gap> x[4];
Error, the second argument must be 1, 2, or 3

# GeneratorsOfReesMatrixSemigroupNC global function
gap> R := ReesMatrixSemigroup(SymmetricGroup(5), [[(1,2), (), (3,4,5)],
>                                                 [(), (), ()]]);
<Rees matrix semigroup 3x2 over Sym( [ 1 .. 5 ] )>
gap> GeneratorsOfReesMatrixSemigroupNC(R, [1, 2], Group((1,2)(3,4)), [1]);
[ (1,(3,4),1), (2,(),1) ]
gap> Size(Semigroup(last));
4
gap> GeneratorsOfReesMatrixSemigroupNC(R, [2], Group(()), [1]);
[ (2,(),1) ]
gap> Size(Semigroup(last));
1
gap> GeneratorsOfReesMatrixSemigroupNC(R, [1, 2, 3], Group([(1,2), (3,4,5)]),
>                                      [1, 2]);
[ (1,(),1), (1,(1,2)(3,4,5),1), (2,(),2), (3,(),1) ]
gap> Size(Semigroup(last));
36
gap> R := ReesMatrixSemigroup(SymmetricGroup(5), TransposedMat(Matrix(R)));
<Rees matrix semigroup 2x3 over Sym( [ 1 .. 5 ] )>
gap> GeneratorsOfReesMatrixSemigroupNC(R, [1, 2], Group([(1,2), (3,4,5)]),
>                                      [1, 2, 3]);
[ (1,(),1), (1,(1,2)(3,4,5),1), (2,(),2), (1,(),3) ]
gap> Size(Semigroup(last));
36
gap> ReesMatrixSubsemigroupNC(R, [2], Group(()), [2]);
<subsemigroup of 2x3 Rees matrix semigroup with 1 generator>

# GeneratorsOfReesZeroMatrixSemigroupNC global function
gap> R := ReesZeroMatrixSemigroup(Group(()), [[(), 0], [0, ()]]);;
gap> ReesZeroMatrixSubsemigroupNC(R, [1], Group(()), [1, 2]);
<Rees 0-matrix semigroup 1x2 over Group(())>
gap> Size(Semigroup(last));
3

# (GeneratorsOf)ReesMatrixS(ubs)emigroup and GeneratorsOfSemigroup
gap> R := ReesMatrixSemigroup(Group((1,2)), [[(1,2)]]);
<Rees matrix semigroup 1x1 over Group([ (1,2) ])>
gap> T := Semigroup(RMSElement(R, 1, (1,2), 1));
<subsemigroup of 1x1 Rees matrix semigroup with 1 generator>
gap> ReesMatrixSubsemigroup(T, [1], Group(()), [1]);
Error, the first argument must be a Rees matrix semigroup
gap> GeneratorsOfReesMatrixSemigroup(T, [1], Group(()), [1]);
Error, the first argument must be a Rees matrix semigroup
gap> ReesMatrixSubsemigroup(R, [], Group(()), [1]);
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees matrix semigroup)
gap> GeneratorsOfReesMatrixSemigroup(R, [], Group(()), [1]);
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees matrix semigroup)
gap> ReesMatrixSubsemigroup(R, [2], Group(()), [1]);
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees matrix semigroup)
gap> GeneratorsOfReesMatrixSemigroup(R, [2], Group(()), [1]);
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees matrix semigroup)
gap> ReesMatrixSubsemigroup(R, [1], Group(()), []);
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees matrix semigroup)
gap> GeneratorsOfReesMatrixSemigroup(R, [1], Group(()), []);
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees matrix semigroup)
gap> ReesMatrixSubsemigroup(R, [1], Group(()), [2]);
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees matrix semigroup)
gap> GeneratorsOfReesMatrixSemigroup(R, [1], Group(()), [2]);
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees matrix semigroup)
gap> ReesMatrixSubsemigroup(R, [1], Group((1,3)), [1]);
Error, the third argument must be a subsemigroup of the underlying semigroup o\
f the first argument (a Rees matrix semigroup)
gap> GeneratorsOfReesMatrixSemigroup(R, [1], Group((1,3)), [1]);
Error, the third argument must be a subsemigroup of the underlying semigroup o\
f the first argument (a Rees matrix semigroup)
gap> ReesMatrixSubsemigroup(R, [1], Group((1,2)), [1]);
<Rees matrix semigroup 1x1 over Group([ (1,2) ])>
gap> GeneratorsOfReesMatrixSemigroup(R, [1], Group((1,2)), [1]);
[ (1,(),1) ]
gap> Semigroup(last) = last2;
true
gap> GeneratorsOfSemigroup(R);
[ (1,(),1) ]

# (GeneratorsOf)ReesZeroMatrixS(ubs)emigroup and GeneratorsOfSemigroup
gap> R := ReesZeroMatrixSemigroup(Group((1,2)), [[(1,2)]]);
<Rees 0-matrix semigroup 1x1 over Group([ (1,2) ])>
gap> T := Semigroup(RMSElement(R, 1, (1,2), 1));
<subsemigroup of 1x1 Rees 0-matrix semigroup with 1 generator>
gap> ReesZeroMatrixSubsemigroup(T, [1], Group(()), [1]);
Error, the first argument must be a Rees 0-matrix semigroup
gap> GeneratorsOfReesZeroMatrixSemigroup(T, [1], Group(()), [1]);
Error, the first argument must be a Rees 0-matrix semigroup
gap> ReesZeroMatrixSubsemigroup(R, [], Group(()), [1]);
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees 0-matrix semigroup)
gap> GeneratorsOfReesZeroMatrixSemigroup(R, [], Group(()), [1]);
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees 0-matrix semigroup)
gap> ReesZeroMatrixSubsemigroup(R, [2], Group(()), [1]);
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees 0-matrix semigroup)
gap> GeneratorsOfReesZeroMatrixSemigroup(R, [2], Group(()), [1]);
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees 0-matrix semigroup)
gap> ReesZeroMatrixSubsemigroup(R, [1], Group(()), []);
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees 0-matrix semigroup)
gap> GeneratorsOfReesZeroMatrixSemigroup(R, [1], Group(()), []);
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees 0-matrix semigroup)
gap> ReesZeroMatrixSubsemigroup(R, [1], Group(()), [2]);
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees 0-matrix semigroup)
gap> GeneratorsOfReesZeroMatrixSemigroup(R, [1], Group(()), [2]);
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees 0-matrix semigroup)
gap> ReesZeroMatrixSubsemigroup(R, [1], Group((1,3)), [1]);
Error, the third argument must be a subsemigroup of the underlying semigroup o\
f the first argument (a Rees 0-matrix semigroup)
gap> GeneratorsOfReesZeroMatrixSemigroup(R, [1], Group((1,3)), [1]);
Error, the third argument must be a subsemigroup of the underlying semigroup o\
f the first argument (a Rees 0-matrix semigroup)
gap> ReesZeroMatrixSubsemigroup(R, [1], Group((1,2)), [1]);
<subsemigroup of 1x1 Rees 0-matrix semigroup with 1 generator>
gap> GeneratorsOfReesZeroMatrixSemigroup(R, [1], Group((1,2)), [1]);
[ (1,(),1) ]
gap> Semigroup(last) = last2;
true
gap> GeneratorsOfSemigroup(R);
[ (1,(),1), 0 ]

# IsomorphismReesMatrixSemigroup: for a D-class
gap> S := FullTransformationMonoid(3);
<full transformation monoid of degree 3>
gap> D := GreensDClassOfElement(S, Transformation([1, 2, 2]));
<Green's D-class: Transformation( [ 1, 2, 2 ] )>

#gap> IsomorphismReesMatrixSemigroup(D);
#Error, the argument (a Green's D-class) is not a subsemigroup
gap> D := GreensDClassOfElement(S, Transformation([1, 1, 1]));
<Green's D-class: Transformation( [ 1, 1, 1 ] )>
gap> iso := IsomorphismReesMatrixSemigroup(D);
MappingByFunction( <Green's D-class: Transformation( [ 1, 1, 1 ] )>, 
<Rees matrix semigroup 1x3 over Group(())>
 , function( x ) ... end, function( x ) ... end )
gap> inv := InverseGeneralMapping(iso);
MappingByFunction( <Rees matrix semigroup 1x3 over Group(())>, 
<Green's D-class: Transformation( [ 1, 1, 1 ] )>
 , function( x ) ... end, function( x ) ... end )
gap> R := Range(iso);
<Rees matrix semigroup 1x3 over Group(())>
gap> ForAll(D, d -> (d ^ iso) ^ inv = d);
true
gap> IdentityTransformation ^ iso;
fail
gap> S := Semigroup([
>  Transformation([1, 2, 1, 4, 4]),
>  Transformation([1, 2, 2, 5, 5])]);
<transformation semigroup of degree 5 with 2 generators>
gap> D := GreensDClassOfElement(S, S.1);
<Green's D-class: Transformation( [ 1, 2, 1, 4, 4 ] )>
gap> iso := IsomorphismReesMatrixSemigroup(D);
MappingByFunction( <Green's D-class: Transformation( [ 1, 2, 1, 4, 4 ] )>, 
<Rees matrix semigroup 2x2 over Group(())>
 , function( x ) ... end, function( x ) ... end )

# IsomorphismReesMatrixSemigroup: for a finite simple semigroup
#gap> IsomorphismReesMatrixSemigroup(FullTransformationMonoid(2));
#Error, the argument must be a finite simple semigroup
gap> S := Semigroup([
>  Transformation([1, 2, 1, 4, 4]),
>  Transformation([1, 2, 2, 5, 5])]);
<transformation semigroup of degree 5 with 2 generators>
gap> iso := IsomorphismReesMatrixSemigroup(S);;
gap> inv := InverseGeneralMapping(iso);;
gap> ForAll(S, s -> (s ^ iso) ^ inv = s);
true

# IsomorphismReesZeroMatrixSemigroup: for a finite 0-simple semigroup
#gap> IsomorphismReesZeroMatrixSemigroup(FullTransformationMonoid(2));
#Error, the argument must be a finite 0-simple semigroup
gap> S := Semigroup(Transformation([1, 2, 2]), Transformation([1, 1, 1]));
<transformation semigroup of degree 3 with 2 generators>
gap> iso := IsomorphismReesZeroMatrixSemigroup(S);;
gap> inv := InverseGeneralMapping(iso);;
gap> ForAll(S, s -> (s ^ iso) ^ inv = s);
true
gap> MultiplicativeZero(Range(iso)) ^ inv;
Transformation( [ 1, 1, 1 ] )
gap> S := Semigroup([
>  Transformation([1, 2, 1, 4, 1, 2]),
>  Transformation([1, 3, 1, 5, 1, 3]),
>  Transformation([1, 1, 2, 1, 4, 4])]);
<transformation semigroup of degree 6 with 3 generators>
gap> iso := IsomorphismReesZeroMatrixSemigroup(S);;
gap> inv := InverseGeneralMapping(iso);;
gap> ForAll(S, s -> (s ^ iso) ^ inv = s);
true
gap> D := GreensDClassOfElement(S, S.1);;
gap> iso := _InjectionPrincipalFactor(D, ReesZeroMatrixSemigroup);;
gap> inv := InverseGeneralMapping(iso);;
gap> MultiplicativeZero(Range(iso)) ^ inv;
fail

# AssociatedReesMatrixSemigroupOfDClass: for a D-class of a finite semigroup
gap> S := Semigroup([
> Transformation([1, 1, 1, 1]),
> Transformation([2, 2, 2, 2]),
> Transformation([1, 2, 2, 3])]);
<transformation semigroup of degree 4 with 3 generators>
gap> D := GreensDClassOfElement(S, S.1);;
gap> R := AssociatedReesMatrixSemigroupOfDClass(D);
<Rees matrix semigroup 1x2 over Group(())>
gap> D := GreensDClassOfElement(S, S.2);;
gap> R := AssociatedReesMatrixSemigroupOfDClass(D);
<Rees matrix semigroup 1x2 over Group(())>
gap> D := GreensDClassOfElement(S, S.3);;
gap> R := AssociatedReesMatrixSemigroupOfDClass(D);
Error, the argument should be a regular D-class
gap> S := Semigroup([
>  Transformation([1, 2, 1, 4, 1, 2]),
>  Transformation([1, 3, 1, 5, 1, 3]),
>  Transformation([1, 1, 2, 1, 4, 4])]);
<transformation semigroup of degree 6 with 3 generators>
gap> AssociatedReesMatrixSemigroupOfDClass(GreensDClassOfElement(S, S.1));
<Rees 0-matrix semigroup 2x2 over Group(())>

# MonoidByAdjoiningIdentity: for a Rees matrix subsemigroup
gap> R := ReesMatrixSemigroup(Group(()), [[()]]);;
gap> S := MonoidByAdjoiningIdentity(R);
<commutative monoid with 1 generator>
gap> IsZeroSimpleSemigroup(S);
true
gap> Size(S);
2
gap> R = UnderlyingSemigroupOfMonoidByAdjoiningIdentity(S);
true

# IsomorphismReesZeroMatrixSemigroup: for a Rees 0-matrix subsemigroup
gap> R := ReesZeroMatrixSemigroup(Group((1,2)), [[(1,2), ()]]);
<Rees 0-matrix semigroup 2x1 over Group([ (1,2) ])>
gap> U := Semigroup(RMSElement(R, 1, (), 1));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 1 generator>

#gap> IsomorphismReesZeroMatrixSemigroup(U);
#Error, the argument must be a finite 0-simple semigroup
gap> U := Semigroup(Elements(R));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 5 generators>
gap> HasIsWholeFamily(U);
false
gap> iso := IsomorphismReesZeroMatrixSemigroup(U);;
gap> inv := InverseGeneralMapping(iso);;
gap> ForAll(U, u -> (u ^ iso) ^ inv = u);
true
gap> U := Semigroup(RMSElement(R, 1, (), 1), MultiplicativeZero(R));
<subsemigroup of 2x1 Rees 0-matrix semigroup with 2 generators>
gap> iso := IsomorphismReesZeroMatrixSemigroup(U);;
gap> inv := InverseGeneralMapping(iso);;
gap> ForAll(U, u -> (u ^ iso) ^ inv = u);
true

# IsomorphismReesMatrixSemigroup: for a Rees matrix subsemigroup
gap> R := ReesMatrixSemigroup(Group((1,2)), [[(1,2), ()]]);
<Rees matrix semigroup 2x1 over Group([ (1,2) ])>
gap> U := Semigroup(RMSElement(R, 1, (1,2), 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> iso := IsomorphismReesMatrixSemigroup(U);;
gap> U := Semigroup(Elements(R));
<subsemigroup of 2x1 Rees matrix semigroup with 4 generators>
gap> HasIsWholeFamily(U);
false
gap> iso := IsomorphismReesMatrixSemigroup(U);;
gap> inv := InverseGeneralMapping(iso);;
gap> ForAll(U, u -> (u ^ iso) ^ inv = u);
true
gap> U := Semigroup(RMSElement(R, 2, (), 1));
<subsemigroup of 2x1 Rees matrix semigroup with 1 generator>
gap> iso := IsomorphismReesMatrixSemigroup(U);;
gap> inv := InverseGeneralMapping(iso);;
gap> ForAll(U, u -> (u ^ iso) ^ inv = u);
true

#
gap> STOP_TEST("reesmat.tst");
