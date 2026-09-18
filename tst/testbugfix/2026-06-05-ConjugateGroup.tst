# Fix an unexpected error in ConjugateGroup when applied to
# a matrix group not over a field
# See https://github.com/gap-system/gap/issues/6423
gap> G:=SL(2,Integers mod 4);;
gap> H:=ConjugateGroup(G,G.1);;
gap> G = H;
true

# original test case
gap> S := SylowSubgroup(SL(2,Integers mod 4),2);;
gap> M := MaximalSubgroups(S);;
gap> Length(M);
3
