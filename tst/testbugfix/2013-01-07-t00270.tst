# 2013/01/07 (MH)
gap> m:=IdentityMat(8,GF(3));;
gap> m2:=m + List([1..8],i->List([1..8], j->Zero(GF(3))));;
gap> DefaultScalarDomainOfMatrixList([m,m2]);
GF(3)
gap> DefaultScalarDomainOfMatrixList([m2,m]);
GF(3)
