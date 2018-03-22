gap> START_TEST("IsInfiniteAbelianizationGroup.tst");

#
# Finite groups never have infinite abelianization
#
gap> G:=SymmetricGroup(3);;
gap> HasIsInfiniteAbelianizationGroup(G);
true
gap> IsInfiniteAbelianizationGroup(G);
false

#
# Free groups have infinite abelianization if and only if they are non-trivial
#
gap> G:=FreeGroup(0);;
gap> HasIsInfiniteAbelianizationGroup(G);
true
gap> IsInfiniteAbelianizationGroup(G);
false

#
gap> G:=FreeGroup(2);;
gap> HasIsInfiniteAbelianizationGroup(G);
true
gap> IsInfiniteAbelianizationGroup(G);
true

#
gap> G:=TrivialSubgroup(G);;
gap> HasIsInfiniteAbelianizationGroup(G);
true
gap> IsInfiniteAbelianizationGroup(G);
false

#
# for fp groups, more work is needed
#
gap> F:=FreeGroup(2);;
gap> H:=F/[F.1^2,F.2^2];; IsInfiniteAbelianizationGroup(H);
false
gap> H:=F/[F.1^2];; IsInfiniteAbelianizationGroup(H);
true
gap> H:=F/[F.1^2,F.2^2,Comm(F.1,F.2)];; IsInfiniteAbelianizationGroup(H);
false
gap> K:=Subgroup(H, [H.1, H.2^2]);; IsInfiniteAbelianizationGroup(K);
false

#
gap> STOP_TEST("IsInfiniteAbelianizationGroup.tst", 1);
