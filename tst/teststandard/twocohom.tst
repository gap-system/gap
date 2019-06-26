gap> START_TEST("twocohom.tst");
gap> g:=PerfectGroup(IsPermGroup,1344,1);;
gap> mo:=IrreducibleModules(g,GF(2),1);;List(mo[2],x->x.dimension);
[ 1 ]
gap> mo:=IrreducibleModules(g,GF(2),0);;List(mo[2],x->x.dimension);
[ 1, 3, 3, 8 ]
gap> coh:=TwoCohomologyGeneric(g,mo[2][2]:
> model:=PerfectGroup(IsPermGroup,10752,1));;
gap> Length(coh.cohomology);
2
gap> comp:=CompatiblePairs(g,mo[2][2]);
<group of size 2688 with 5 generators>
gap> reps:=CompatiblePairOrbitRepsGeneric(comp,coh);;Length(reps);
3
gap> h:=FpGroupCocycle(coh,reps[1],true);;
gap> h:=Image(IsomorphismPermGroup(h));;
gap> Collected(List(MaximalSubgroupClassReps(h),Size));
[ [ 1344, 7 ], [ 1536, 2 ] ]
gap> a:=FpGroupCocycle(coh,reps[2],true);;
gap> a:=Image(IsomorphismPermGroup(a));;
gap> Collected(List(MaximalSubgroupClassReps(a),Size));
[ [ 1344, 3 ], [ 1536, 2 ] ]
gap> IsomorphismGroups(a,h);
fail
gap> IsomorphismGroups(h,PerfectGroup(IsPermGroup,10752,1))<>fail;
true

# that's all, folks
gap> STOP_TEST( "twocohom.tst", 1);
