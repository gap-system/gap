gap> START_TEST("algrep.tst");

#
gap> L:=FullMatrixLieAlgebra(GF(5),2);
<Lie algebra over GF(5), with 3 generators>
gap> V:=AdjointModule(L);
<left-module over <Lie algebra over GF(5), with 3 generators>>
gap> s:=List([0..3],r->SymmetricPowerOfAlgebraModule(V,r));;
gap> V:=DirectSumOfAlgebraModules(s);
<35-dimensional left-module over <Lie algebra over GF(5), with 3 generators>>
gap> BV:=Basis(V);;
gap> lst:=[BV[5]];;
gap> W:=SubAlgebraModule(V,lst,"basis");
<1-dimensional left-module over <Lie algebra over GF(5), with 3 generators>>
gap> V/W;
<34-dimensional left-module over <Lie algebra over GF(5), with 3 generators>>

#
gap> A:=FullSparseRowSpace(GF(5), 35);
<vector space of dimension 35 over GF(5)>
gap> AV:=Basis(A);;
gap> CanonicalBasis(A);  # not currently supported for sparse row spaces
fail
gap> IsCanonicalBasis(AV);
false
gap> v:=AV[12];
(Z(5)^0)*e.12
gap> ForAll(AV, v -> v in A);
true
gap> ForAll([1..10], i -> Random(A) in A);
true

#
gap> STOP_TEST( "algrep.tst", 1);
