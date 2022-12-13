# 2012/12/06 (AK)
gap> x := Indeterminate(Rationals);
x_1
gap> InverseSameMutability(Zero(x));
fail
gap> Inverse(Zero(x));
fail
gap> InverseOp(Zero(x));
fail
