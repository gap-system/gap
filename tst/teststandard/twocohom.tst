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
gap> comp:=CompatiblePairs(g,mo[2][2]);;Size(comp);
2688
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
gap> g:=SmallGroup(24,12);
<pc group of size 24 with 4 generators>
gap> mo:=IrreducibleModules(g,GF(2));;
gap> coh:=TwoCohomologyGeneric(g,First(mo[2],x->x.dimension=1));;
gap> Length(coh.cohomology);
2
gap> g:=Image(IsomorphismPermGroup(GL(2,8)));;
gap> mo:=IrreducibleModules(g,GF(2));;
gap> mo:=Filtered(mo[2],x->x.dimension=6);;
gap> coh:=List(mo,x->TwoCohomologyGeneric(g,x));;
gap> pos:=First([1..Length(coh)],x->Length(coh[x].cohomology)>0);;
gap> coh:=coh[pos];;
gap> mo:=mo[pos];;
gap> comp:=CompatiblePairs(g,mo);;Size(comp);
63504
gap> reps:=CompatiblePairOrbitRepsGeneric(comp,coh);;Length(reps);
2
gap> gp:=FpGroupCocycle(coh,coh.cohomology[1],true);;
gap> p:=Image(IsomorphismPermGroup(gp));;
gap> ConfluentMonoidPresentationForGroup(p);;
gap> Length(ConjugacyClasses(p));
119

# Extensions nonsolvable
gap> g:=Group((1,2,3,4,5),(3,4,5));;
gap> mats:=[[[0,1,0,0],[0,0,1,0],[0,0,0,1],[2,2,2,2]],
> [[1,0,0,0],[0,1,1,0],[0,0,0,1],[0,0,2,2]]];;
gap> mo:=GModuleByMats(mats*Z(3)^0,GF(3));;
gap> Length(Extensions(g,mo));
3
gap> cp:=CompatiblePairs(g,mo);
<group of size 240 with 4 generators>
gap> Length(ExtensionRepresentatives(g,mo,cp));
2

# New code for Pc groups
gap> g:=AbelianGroup([2,2]);;
gap> mo:=TrivialModule(2,GF(2));;
gap> coh:=TwoCohomologyGeneric(g,mo);;
gap> List(Elements(VectorSpace(GF(2),coh.cohomology)),
> x->FpGroupCocycle(coh,x,true:normalform));;
gap> g:=CyclicGroup(3);;
gap> mo:=GModuleByMats([[[0,1],[1,1]]]*Z(2),GF(2));;
gap> TwoCohomologyGeneric(g,mo).cohomology;
[  ]

# routines used for rewriting
gap> WeylGroupFp("A",3);
<fp group on the generators [ s1, s2, s3 ]>
gap> WeylGroupFp("B",3);
<fp group on the generators [ s1, s2, s3 ]>
gap> WeylGroupFp("D",5);
<fp group on the generators [ s1, s2, s3, s4, s5 ]>
gap> WeylGroupFp("E",6);
<fp group on the generators [ s1, s2, s3, s4, s5, s6 ]>
gap> WeylGroupFp("F",4);
<fp group on the generators [ s1, s2, s3, s4 ]>
gap> ConfluentMonoidPresentationForGroup(SmallGroup(24,12));;

# that's all, folks
gap> STOP_TEST( "twocohom.tst", 1);
