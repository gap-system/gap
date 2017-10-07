# Issue related to PrimePGroup for a direct product of trivial groups
#
gap> G := DirectProduct(TrivialGroup(IsPcGroup), TrivialGroup(IsPcGroup));
<pc group of size 1 with 0 generators>
gap> PrimePGroup(G);
fail
gap> A := Group(Transformation([1, 2, 3]));;
gap> B := DirectProduct(A, A);;
gap> IsPGroup(B);
true
gap> HasDirectProductInfo(B);
true
gap> PrimePGroup(B);
fail
