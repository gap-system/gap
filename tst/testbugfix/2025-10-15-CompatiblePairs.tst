# CompatiblePairs used to ignore the first optional argument in certain cases.
# In the example below, the last command used to produce the output
#  [ 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96, 96 ]
#
# Reported by Heiko Dietrich, together with a helpful analysis of the problem
# that made a fix quite easy.
gap> G:=AbelianGroup([3,3]);;
gap> M:=GModuleByMats([One(GL(1,3)),One(GL(1,3))],GF(3));;
gap> aut:=List(ConjugacyClassesSubgroups(AutomorphismGroup(G)),Representative);;
gap> SortedList(List(aut,A->Size(CompatiblePairs(A,G,M))));
[ 2, 4, 4, 6, 8, 8, 12, 12, 12, 16, 16, 16, 24, 32, 48, 96 ]
