# Bug in IsFinite
# Example reported on issue #1659 on github.com/gap-system/gap
gap> F := FreeSemigroup(1);;
gap> R := ReesZeroMatrixSemigroup(F, [[F.1]]);;
gap> S := Semigroup(MultiplicativeZero(R));;
gap> IsFinite(S);
true
gap> A := ReesMatrixSemigroup(R, [[MultiplicativeZero(R)]]);;
gap> B := Semigroup(RMSElement(A, 1, MultiplicativeZero(R), 1));;
gap> IsFinite(B);
true

# Bug in IsReesZeroMatrixSemigroup
gap> R := ReesZeroMatrixSemigroup(Group(()), [[()]]);;
gap> T := Semigroup(MultiplicativeZero(R), MultiplicativeZero(R));;
gap> IsReesZeroMatrixSemigroup(T);
false

# Bug in Enumerator for a RMS
gap> R := ReesMatrixSemigroup(Group(()), [[()]]);;
gap> S := ReesMatrixSemigroup(SymmetricGroup(2), [[()]]);;
gap> x := RMSElement(S, 1, (), 1);;
gap> x in R;
false
gap> Position(Enumerator(R), x);
fail

# Bug in Enumerator for a RZMS
gap> R := ReesZeroMatrixSemigroup(Group(()), [[()]]);;
gap> S := ReesZeroMatrixSemigroup(SymmetricGroup(2), [[()]]);;
gap> x := RMSElement(S, 1, (), 1);;
gap> x in R;
false
gap> Position(Enumerator(R), x);
fail
