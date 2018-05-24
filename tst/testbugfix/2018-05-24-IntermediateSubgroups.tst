# test for MaximalSubgroupClassReps with options (reported through
# observation by S.Alavi with IntermediateGroup
# More complicated to construct w/o AtlasSubgroup to ensure the 325 points
# action, as it is too slow otherwise.
# Also construct the smaller subgroup
# s1 directly.  Finally do not slow down with assertions that don't need
# testing here

gap> START_TEST("noassert");
gap> SetAssertionLevel(0);;
gap> g:=SU(IsPermGroup,4,4);;
gap> sy:=SylowSubgroup(g,2);;
gap> n:=Filtered(NormalSubgroups(sy),x->IsAbelian(x) and Size(x)=256);;
gap> sub:=Normalizer(g,n[1]);;
gap> g:=Action(g,RightTransversal(g,sub),OnRight);;
gap> NrMovedPoints(g);Size(g);
325
1018368000
gap> s:=Stabilizer(g,1);;
gap> s1:=Complementclasses(s,RadicalGroup(s));;
gap> s1:=s1[1];;Size(s1);
4080
gap> n1:= Normalizer( g, s1 );;  Size( n1 );
24480
gap> int:=IntermediateGroup(g,s1);;
gap> IsGroup(int);
true
gap> STOP_TEST("noassert");
