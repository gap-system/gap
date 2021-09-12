# test for MaximalSubgroupClassReps with options (reported through
# observation by S.Alavi with IntermediateGroup
# More complicated to construct w/o AtlasSubgroup to ensure the 325 points
# action, as it is too slow otherwise.
# Also construct the smaller subgroup
# s1 directly.  Finally do not slow down with assertions that don't need
# testing here

gap> START_TEST("2018-05-24-IntermediateSubgroups.tst");
gap> SetAssertionLevel(0);;
gap> g:=SU(IsPermGroup,4,4);;
gap> sy:=SylowSubgroup(g,2);;
gap> hom:=NaturalHomomorphismByNormalSubgroup(sy, DerivedSubgroup(sy));;
gap> n:=First(NormalSubgroups(Image(hom)), x->Size(x)=4 and IsAbelian(PreImage(hom,x)));;
gap> sub:=Normalizer(g, PreImage(hom,n));;
gap> g:=Action(g,RightTransversal(g,sub),OnRight);;
gap> NrMovedPoints(g);Size(g);
325
1018368000
gap> s:=Stabilizer(g,1);;
gap> s1:=Complementclasses(s,SolvableRadical(s));;
gap> s1:=s1[1];;Size(s1);
4080
gap> n1:= Normalizer( g, s1 );;  Size( n1 );
24480
gap> int:=IntermediateGroup(g,s1);;
gap> IsGroup(int);
true
gap> STOP_TEST("2018-05-24-IntermediateSubgroups.tst");
