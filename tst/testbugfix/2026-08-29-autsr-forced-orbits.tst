# In AutomGrpSR, the hook processing someCharacteristics.orbits appended
# the orbit of the wrong subgroup when an orbit pair spans two orbits,
# causing "Action not well-defined" errors. Found while investigating
# https://github.com/gap-system/gap/issues/6537
gap> START_TEST("2026-08-29-autsr-forced-orbits.tst");

# A5 x 3^4 x C2: Aut(A5 x 3^4) is large enough for AutomGrpSR to use
# the radical automorphism reduction, which processes the orbits hook.
# Fresh group per call, as AutomorphismGroup is a cached attribute.
gap> mk:=function()
> local c3,P,G;
> c3:=CyclicGroup(IsPermGroup,3);
> P:=DirectProduct(c3,c3,c3,c3);
> G:=DirectProduct(AlternatingGroup(5),P,CyclicGroup(IsPermGroup,2));
> return rec(G:=G,emb:=Embedding(G,2),P:=P);
> end;;

# Pair in two orbits: a line and a hyperplane of the 3^4 factor.
# Expected size: |S5| * |GL(3,3)| * |GL(1,3)| = 120*11232*2
gap> t:=mk();;
gap> V:=Image(t.emb,Subgroup(t.P,[t.P.4]));;
gap> W:=Image(t.emb,Subgroup(t.P,[t.P.1,t.P.2,t.P.3]));;
gap> a:=AutomorphismGroup(t.G:
> someCharacteristics:=rec(subgroups:=[],orbits:=[[V,W]]));;
gap> Size(a);
2695680

# Pair in one orbit: two lines.
# Expected size: |S5| * |Stab_GL(4,3)({line1,line2})| = 120*31104
gap> t:=mk();;
gap> V:=Image(t.emb,Subgroup(t.P,[t.P.3]));;
gap> W:=Image(t.emb,Subgroup(t.P,[t.P.4]));;
gap> a:=AutomorphismGroup(t.G:
> someCharacteristics:=rec(subgroups:=[],orbits:=[[V,W]]));;
gap> Size(a);
3732480

#
gap> STOP_TEST("2026-08-29-autsr-forced-orbits.tst");
