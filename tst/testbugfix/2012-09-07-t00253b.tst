# Check that \in method works for groups handled by a nice monomorphism
# created with a custom SeedFaithfulAction.
# Fix and test case added by MH on 2012-09-07.
gap> m1:=PermutationMat( (1,2), 5, GF(5) );;
gap> m2:=PermutationMat( (3,4), 5, GF(5) );;
gap> n:=PermutationMat( (1,4,5), 5, GF(5) );;
gap> G:=Group(m1, m2);;
gap> SetSeedFaithfulAction(G,rec(points:=[m1[1],m1[3]], ops:=[OnPoints,OnPoints]));
gap> n in G;
false
