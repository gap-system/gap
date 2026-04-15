# Regression test for square matrices and invalid dependent input in
# CosetLeadersMatFFE.
gap> M := IdentityMat(2, GF(2));;
gap> L := CosetLeadersMatFFE(M, GF(2));;
gap> Length(L);
4
gap> CosetLeadersMatFFE(L, GF(2));
Error, CosetLeadersMatFFE: <mat> must have linearly independent rows
