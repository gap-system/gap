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
# creating subalgebra
#
gap> L:=FullMatrixLieAlgebra(GF(3), 2);; Dimension(L);;
gap> V:=AdjointModule(L);
<left-module over <Lie algebra of dimension 4 over GF(3)>>
gap> S:=SymmetricPowerOfAlgebraModule(V, 4);
<35-dimensional left-module over <Lie algebra of dimension 4 over GF(3)>>

# span of zero vectors
gap> S0:=SubAlgebraModule(S,[]);
<0-dimensional left-module over <Lie algebra of dimension 4 over GF(3)>>
gap> S0:=SubAlgebraModule(S,[],"basis");
<0-dimensional left-module over <Lie algebra of dimension 4 over GF(3)>>

# span of some vectors
gap> bas:=Basis(S){[ 1, 2, 4, 5, 6, 9, 13, 14, 15, 16, 19, 25, 32, 33, 34, 35 ]};;
gap> S1:=SubAlgebraModule(S,bas);
<left-module over <Lie algebra of dimension 4 over GF(3)>>
gap> Dimension(S1);
16
gap> S1:=SubAlgebraModule(S,bas,"basis");
<16-dimensional left-module over <Lie algebra of dimension 4 over GF(3)>>

#
#
# cocycles etc.
#

# for zero module
gap> CochainSpace(S0,0);
<vector space of dimension 0 over GF(3)>
gap> CochainSpace(S0,1);
<vector space of dimension 0 over GF(3)>
gap> CochainSpace(S0,2);
<vector space of dimension 0 over GF(3)>
gap> Cocycles(S0,0);
<vector space of dimension 0 over GF(3)>
gap> Cocycles(S0,1);
<vector space of dimension 0 over GF(3)>
gap> Cocycles(S0,2);
<vector space of dimension 0 over GF(3)>
gap> Coboundaries(S0,0);
<vector space of dimension 0 over GF(3)>
gap> Coboundaries(S0,1);
<vector space of dimension 0 over GF(3)>
gap> Coboundaries(S0,2);
<vector space of dimension 0 over GF(3)>

# for proper submodule
gap> CochainSpace(S1,0);
<vector space of dimension 16 over GF(3)>
gap> CochainSpace(S1,1);
<vector space of dimension 64 over GF(3)>
gap> CochainSpace(S1,2);
<vector space of dimension 96 over GF(3)>
gap> Cocycles(S1,0);
<vector space of dimension 4 over GF(3)>
gap> Cocycles(S1,1);
<vector space of dimension 16 over GF(3)>
gap> Cocycles(S1,2);
<vector space of dimension 48 over GF(3)>
gap> tmp:=Coboundaries(S1,0);; Dimension(tmp);; tmp;
<vector space of dimension 0 over GF(3)>
gap> tmp:=Coboundaries(S1,1);; Dimension(tmp);; tmp;
<vector space of dimension 12 over GF(3)>
gap> tmp:=Coboundaries(S1,2);; Dimension(tmp);; tmp;
<vector space of dimension 48 over GF(3)>

# for full module
gap> CochainSpace(S,0);
<vector space of dimension 35 over GF(3)>
gap> CochainSpace(S,1);
<vector space of dimension 140 over GF(3)>
gap> CochainSpace(S,2);
<vector space of dimension 210 over GF(3)>
gap> Cocycles(S,0);
<vector space of dimension 6 over GF(3)>
gap> Cocycles(S,1);
<vector space of dimension 45 over GF(3)>
gap> tmp:=Coboundaries(S,0);; Dimension(tmp);; tmp;
<vector space of dimension 0 over GF(3)>
gap> tmp:=Coboundaries(S,1);; Dimension(tmp);; tmp;
<vector space of dimension 29 over GF(3)>

#
gap> STOP_TEST( "algrep.tst", 1);
