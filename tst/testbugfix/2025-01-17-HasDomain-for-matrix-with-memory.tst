gap> G := GroupWithMemory([One(GL(3,4))]);;
gap> mat := G.1;;
gap> HasBaseDomain(mat);
true
gap> BaseDomain(mat);
GF(2^2)
gap> DefaultScalarDomainOfMatrixList([mat]);
GF(2^2)
