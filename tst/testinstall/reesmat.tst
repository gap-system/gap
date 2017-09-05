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

#
gap> STOP_TEST("reesmat.tst");
