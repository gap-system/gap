#############################################################################
##
##  Exclude from testinstall.g as it takes considerable time.
##
gap> START_TEST("grpperm.tst");
gap> G1 := TrivialSubgroup (Group ((1,2)));;
gap> G2 := SymmetricGroup ([]);;
gap> G3:=Intersection (G1, G2);;
gap> Size(G3);
1
gap> Pcgs(G3);;
gap> g:=Group((1,2,9)(3,4,5)(6,7,8), (1,4,7)(2,5,8)(3,6,9));;
gap> h:=Group((1,2,9)(3,4,5)(6,7,8));;
gap> (g<h)=(AsSSortedList(g)<AsSSortedList(h));
true
gap> g:=Group( (1,2,3), (2,3)(4,5) );;
gap> IsSolvable(g);
true
gap> RepresentativeAction(g,(2,5,3), (2,3,4));
(2,3)(4,5)
gap> g:=Group( ( 9,11,10), ( 2, 3, 4),  (14,17,15), (13,16)(15,17), 
>              ( 8,12)(10,11), ( 5, 7)(10,11), (15,16,17), (10,11,12) );;
gap> Sum(ConjugacyClasses(g),Size)=Size(g);
true
gap> g:= Group( (4,8,12),(2,10)(4,8),(1,10)(2,5)(3,12)(4,7)(6,9)(8,11),
>               (1,7)(3,9)(5,11)(6,10) );;
gap> e:=ElementaryAbelianSeriesLargeSteps(DerivedSeries(g));;
gap> List(e,Size);
[ 2592, 324, 162, 81, 1 ]
gap> ForAll([1..Length(e)-1],i->HasElementaryAbelianFactorGroup(e[i],e[i+1]));
true
gap> group:=
> Subgroup( Group( (  1,  2)(  3,  5)(  4,  7)(  6, 10)(  8, 12)(  9, 13)
> ( 14, 19)( 15, 20)( 16, 22)( 17, 23)( 18, 25)( 24, 31)( 26, 33)( 27, 34)
> ( 28, 36)( 29, 38)( 30, 39)( 35, 45)( 37, 46)( 41, 48)( 42, 50)( 43, 51)
> ( 44, 53)( 47, 57)( 49, 59)( 52, 62)( 54, 64)( 55, 65)( 56, 67)( 58, 70)
> ( 60, 73)( 61, 74)( 63, 77)( 66, 80)( 68, 82)( 69, 75)( 71, 84)( 72, 85)
> ( 76, 88)( 78, 90)( 79, 91)( 81, 94)( 83, 97)( 86,100)( 87,101)( 89,102)
> ( 92,104)( 93,105)( 95,103)( 96,106)( 99,107)(108,114)(109,115)(110,112)
> (113,117)(118,119), (  1,  3,  6)(  2,  4,  8)(  5,  9, 14)(  7, 11, 16)
> ( 10, 15, 21)( 12, 17, 24)( 13, 18, 26)( 19, 27, 35)( 20, 28, 37)( 22, 29, 36)
> ( 23, 30, 40)( 25, 32, 42)( 31, 41, 49)( 33, 43, 52)( 34, 44, 54)( 38, 39, 47)
> ( 45, 55, 66)( 46, 56, 68)( 48, 58, 71)( 50, 60, 65)( 51, 61, 75)( 53, 63, 78)
> ( 57, 69, 73)( 59, 72, 86)( 62, 76, 89)( 64, 79, 92)( 67, 81, 95)( 70, 83, 98)
> ( 74, 87, 77)( 80, 93, 88)( 82, 96, 97)( 84, 99,108)( 85, 90,103)( 91,101,110)
> ( 94,100,109)(102,111,104)(105,112,116)(106,113,118)(114,115,117) ), 
> [ (  1,  6)(  2, 25)(  4, 27, 70, 98, 35, 42)(  5, 44)(  7, 11)(  8, 32, 19)
>     (  9, 50, 33,111, 24, 34)( 12,113, 40, 65, 14, 54)( 13, 78)( 15, 21)
>     ( 17,104, 52, 60, 23,106)( 18, 41, 88, 93, 49, 63)( 20,109)( 22,107, 29)
>     ( 26, 53, 31)( 28, 86, 76, 62, 59,100)( 30,118)( 37, 94, 72)
>     ( 38,110, 99,114, 90, 95)( 39, 87, 92, 71, 73,101)( 43,102)
>     ( 45, 85,115, 46, 58, 64)( 47, 67, 84, 91, 57, 74)( 48, 56, 66, 79, 77, 69
>      )( 51, 75)( 55, 68,117,108, 81,103)( 96, 97)(112,116), 
>   (  1,  8, 65, 89, 94, 10, 37, 72, 43, 32,  6, 14, 19, 83, 54)
>     (  2,  9, 78, 86, 67, 63, 52, 76, 93, 55, 44, 49, 42, 24, 82,118,  4, 13,
>       17, 92, 88, 62,104, 18, 85,109, 41, 34, 35, 16)(  3, 21, 15)
>     (  5, 45, 95,117, 59, 29, 47, 74,110, 50, 30, 69, 64, 91, 22, 20,103, 99,
>       46, 60, 26, 87, 39, 90, 27, 25, 66, 81, 73, 53)(  7, 36, 84,106, 38, 51,
>      33, 79, 98, 96, 56,100, 68, 31,116,112, 80, 71, 28,114, 97, 70, 48,111,
>       75, 77, 23,115,107, 11)( 12,102, 40,119,113)( 57,108,105,101, 58, 61) 
>  ] );;
gap> perf:=RepresentativesPerfectSubgroups(group);;
gap> List(perf,Size);
[ 1, 60, 960, 30720 ]
gap> g:=Group([
> (2,3,5,4)(6,14,21)(7,12,22,9,13,24,10,11,25,8,15,23)(16,32,27)(17,31,
> 29,18,35,26,20,33,30,19,34,28), (1,26,25,2,28,24)(3,30,23,5,29,21)
> (4,27,22)(6,9)(7,8)(11,18,35,13,16,31,12,17,33,15,19,32)(14,20,34) ]);;
gap> h:=Group([ (31,32,33,34,35), (26,27,28,29,30), (21,22,23,24,25),
> (16,17,18,19,20), (11,12,13,14,15), (6,7,8,9,10), (1,2,3,4,5) ] );;
gap> Size(g/h);
2752512
gap> g:=WreathProduct(MathieuGroup(11),Group((1,2)));
<permutation group of size 125452800 with 5 generators>
gap> Length(ConjugacyClassesSubgroups(g));
2048
gap> g:=SemidirectProduct(GL(3,5),GF(5)^3);
<matrix group of size 186000000 with 3 generators>
gap> g:=Image(IsomorphismPermGroup(g));
<permutation group of size 186000000 with 3 generators>
gap> SortedList(List(MaximalSubgroupClassReps(g),Size));
[ 46500, 48000, 60000, 1488000, 6000000, 6000000, 93000000 ]
gap> g:=Image(IsomorphismPermGroup(GL(2,5)));;
gap> w:=WreathProduct(g,SymmetricGroup(5));;
gap> m:=MaximalSubgroupClassReps(w);;
gap> Collected(List(m,x->Index(w,x)));
[ [ 2, 3 ], [ 5, 1 ], [ 6, 1 ], [ 10, 1 ], [ 16, 1 ], [ 3125, 1 ], 
  [ 7776, 1 ], [ 100000, 1 ] ]
gap> Unbind(m);Unbind(w);Unbind(g);
gap> g := Group(GeneratorsOfGroup(SymmetricGroup(1000)));;
gap> IsNaturalSymmetricGroup(g);
true
gap> Size(g) = Factorial(1000);
true
gap> g := Group(GeneratorsOfGroup(AlternatingGroup(999)));;
gap> IsNaturalSymmetricGroup(g);
false
gap> IsNaturalAlternatingGroup(g);
true
gap> 2*Size(g) = Factorial(999);
true
gap> Intersection(SymmetricGroup([1..5]),SymmetricGroup([3..8]));
Sym( [ 3 .. 5 ] )
gap> Intersection(SymmetricGroup([1..5]),AlternatingGroup([3..8]));
Alt( [ 3 .. 5 ] )
gap> Intersection(AlternatingGroup([1..5]),AlternatingGroup([3..8]));
Alt( [ 3 .. 5 ] )
gap> Intersection(AlternatingGroup([1..5]),SymmetricGroup([3..8]));  
Alt( [ 3 .. 5 ] )
gap> s := SymmetricGroup(100);
Sym( [ 1 .. 100 ] )
gap> Stabilizer(s,3,OnPoints);
Sym( [ 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,\
 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 4\
1, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60,\
 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 8\
0, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,\
 100 ] )
gap> Stabilizer(s,[3,4,101],OnTuples); 
Sym( [ 1, 2, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22\
, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, \
42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61\
, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, \
81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 10\
0 ] )
gap> Stabilizer(s,[3,4,101],OnSets);
<permutation group of size 188537808977664954912523714861144849476193875281579\
033269884775545894141400464475977659523184154582396472117011772169208588252951\
34720000000000000000000000 with 3 generators>
gap> Stabilizer(s,[[2,3],[3,4,5,101]],OnTuplesSets);
<permutation group of size 198335586974189937841914280308378760231636729730253\
559088875210967698444561818299997537895207400149796415018947793150861127974912\
0000000000000000000000 with 3 generators>
gap> Stabilizer(s,[[2,3],[3,4,101]],OnTuplesSets);  
Sym( [ 1, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 2\
3, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42,\
 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 6\
2, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81,\
 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100 ]\
 )
gap> Centralizer(s,(1,2,3,4)(5,6,7,8)(9,10,11)(12,13,14));
<permutation group of size 139548069409954938518969413651821655960040854381993\
238884831283501108134558516513594307316297031600121692765028352000000000000000\
00000 with 91 generators>
gap> GeneratorsOfGroup(last);
[ (1,2,3,4), (1,5)(2,6)(3,7)(4,8), (5,6,7,8), (9,10,11), (9,12)(10,13)(11,14),
  (12,13,14), (15,100), (16,100), (17,100), (18,100), (19,100), (20,100), 
  (21,100), (22,100), (23,100), (24,100), (25,100), (26,100), (27,100), 
  (28,100), (29,100), (30,100), (31,100), (32,100), (33,100), (34,100), 
  (35,100), (36,100), (37,100), (38,100), (39,100), (40,100), (41,100), 
  (42,100), (43,100), (44,100), (45,100), (46,100), (47,100), (48,100), 
  (49,100), (50,100), (51,100), (52,100), (53,100), (54,100), (55,100), 
  (56,100), (57,100), (58,100), (59,100), (60,100), (61,100), (62,100), 
  (63,100), (64,100), (65,100), (66,100), (67,100), (68,100), (69,100), 
  (70,100), (71,100), (72,100), (73,100), (74,100), (75,100), (76,100), 
  (77,100), (78,100), (79,100), (80,100), (81,100), (82,100), (83,100), 
  (84,100), (85,100), (86,100), (87,100), (88,100), (89,100), (90,100), 
  (91,100), (92,100), (93,100), (94,100), (95,100), (96,100), (97,100), 
  (98,100), (99,100) ]
gap> Centralizer(AlternatingGroup(14), (1,2,3,4)(5,6,7,8)(9,10,11)(12,13,14));
<permutation group of size 288 with 7 generators>
gap> GeneratorsOfGroup(last);
[ (1,3)(2,4), (1,5)(2,6)(3,7)(4,8), (5,7)(6,8), (1,2,3,4)(5,8,7,6), 
  (9,10,11), (1,2,3,4)(9,12)(10,13)(11,14), (12,13,14) ]
gap> a8 := AlternatingGroup(8);;
gap> pairs := Tuples( [1..8], 2 );;
gap> orbs := Orbits( a8, pairs, OnPairs );; Length( orbs );
2
gap> u56 := Stabilizer( a8, orbs[2][1], OnPairs );; Index( a8, u56 );
56
gap> g:=TransitiveGroup(12,250);;
gap> hom:=IsomorphismPcGroup(g);;
gap> Length(ConjugacyClassesByHomomorphicImage(g,hom));
65

# test of data library use
gap> SetInfoLevel(InfoPerformance,2);
gap> Size(Normalizer(SymmetricGroup(12),PrimitiveGroup(12,2)));
#I  Using Primitive Groups Library
95040
gap> Size(Normalizer(SymmetricGroup(12),
> PrimitiveGroup(12,2):NoPrecomputedData));
95040
gap> SetInfoLevel(InfoPerformance,0);
gap> s:=SymmetricGroup(56);;
gap> List([1..7],x->Size(Normalizer(s,PrimitiveGroup(56,x))));
[ 80640, 80640, 80640, 80640, 80640, 40320, 40320 ]
gap> g:=SymmetricGroup(17);;s:=SylowSubgroup(g,NrMovedPoints(g));;
gap> ac:=AscendingChain(g,s);;
gap> Maximum(List([2..Length(ac)],x->Index(ac[x],ac[x-1])))<10^11;
true
gap> g:=PSL(4,5);;
gap> l:=LowLayerSubgroups(g,3,x->Index(g,x)<=10000);;
gap> Sum(List(l,x->Index(g,x)));
89655

# test of ONanScottType -- primitive groups and their type
gap> rr:=[[60,1,"3a"],[60,2,"3a"],[60,3,"3b"],[60,4,"3b"],
> [60,5,"3b"],[168,1,"3a"],[168,2,"3a"],[168,3,"3b"],
> [168,4,"3b"],[168,5,"3b"],[360,1,"3a"],[360,2,"3a"],
> [360,3,"3a"],[360,4,"3a"],[360,5,"3b"],[360,6,"3b"],
> [360,7,"3b"],[360,8,"3b"],[360,9,"3a"],[360,10,"3b"],
> [360,11,"3b"],[360,12,"3b"],[360,13,"3b"],[360,14,"3b"],
> [360,15,"3b"],[360,16,"3b"],[504,1,"3a"],[504,2,"3b"],
> [504,3,"3a"],[504,4,"3b"],[660,1,"3a"],[660,2,"3a"],
> [660,3,"3b"],[660,4,"3b"],[660,5,"3b"],[1092,1,"3a"],
> [1092,2,"3a"],[1092,3,"3b"],[1092,4,"3b"],[1092,5,"3b"],
> [2448,1,"3a"],[2448,2,"3b"],[2448,3,"3a"],[2448,4,"3b"],
> [2448,5,"3b"],[2520,1,"3a"],[2520,2,"3b"],[2520,3,"3a"],
> [2520,4,"3b"],[2520,5,"3b"],[3420,1,"3a"],[3420,2,"3b"],
> [3420,3,"3a"],[3420,4,"3b"],[3420,5,"3b"],[3600,6,"4a"],
> [3600,7,"4b"],[3600,8,"4a"],[3600,9,"4a"],[3600,10,"4b"],
> [3600,11,"4b"],[3600,12,"4b"],[3600,13,"4b"],
> [3600,14,"4b"],[3600,15,"4b"],[3600,16,"4a"],
> [3600,17,"4b"],[3600,18,"4b"],[3600,19,"4b"],
> [3600,20,"4b"],[3600,21,"4b"],[3600,22,"4b"],
> [3600,23,"4b"],[3600,24,"4b"],[3600,25,"4b"],
> [3600,26,"4b"],[3600,27,"4b"],[3600,28,"4b"],
> [3600,29,"4b"],[4080,1,"3a"],[4080,2,"3a"],[4080,3,"3b"],
> [4080,4,"3b"],[4080,5,"3b"],[4080,6,"3a"],[4080,7,"3b"],
> [4080,8,"3b"]];;
gap> gpcopy:=function(G)local s,r;s:=Size(G); # new conjugate group
> r:=Random(SymmetricGroup(2+LargestMovedPoint(G)));
> G:=Group(List(GeneratorsOfGroup(G),x->x^r));SetSize(G,s);return G;end;;
gap> First(rr,x->ONanScottType(gpcopy(PrimitiveGroup(x[1],x[2])))<>x[3]);
fail

# test of block homomorphism kernels -- observed by Thomas 12/15/17. The test
# is to ensure that the `SmallerDegree` runs through in plausible memory and
# time use. Takes about 4 minutes on my Laptop. AH
gap> a:=[[0,-1,0,1,0,-1,1,0],[0,0,-1,0,1,-1,0,0],[0,0,0,-1,1,0,0,0],
> [0,0,0,-1,0,0,0,0],[0,0,1,-1,0,0,0,0],[0,-1,1,0,-1,0,0,0],
> [1,-1,0,1,0,-1,0,0],[2,1,0,0,0,1,4,1]];;
gap> b:=[[-1,0,1,0,-1,1,0,0],[0,-1,0,1,-1,0,0,0],[0,0,-1,1,0,0,0,0],
> [0,0,-1,0,0,0,0,0],[0,1,-1,0,0,0,0,0],[-1,1,0,-1,0,0,0,0],
> [-1,0,1,0,-1,0,1,0],[2,0,0,0,0,0,0,1]];;
gap> c:=[[1,0,0,0,0,0,0,0],[0,1,0,0,0,0,0,0],[0,0,1,0,0,0,0,0],
> [0,0,0,1,0,0,0,0],[0,0,0,0,1,0,0,0],[0,0,0,0,0,1,0,0],
> [0,0,0,0,0,0,1,0],[6,0,0,0,0,0,0,1]];;
gap> elm:=a*b;;
gap> one:=elm^0;;
gap> fixed:=NullspaceMat(elm-one);;
gap> fun:=function(v,g)return List(v*g,x->x mod 18);end;;
gap> seed:=fun(fixed[2],one);;
gap> sgens:=[a,b,c];;
gap> orb:=Orbit(Group(sgens),seed,fun);;
gap> permgens:=List(sgens,x->Permutation(x,orb,fun));;
gap> sm:=SmallerDegreePermutationRepresentation(Group(permgens));;
gap> NrMovedPoints(Source(sm));
157464
gap> NrMovedPoints(Range(sm))<200;
true

# construct extensions
gap> g:=PerfectGroup(IsPermGroup,3840,1);;
gap> cf:=List(MTX.CollectedFactors(RegularModule(g,GF(2))[2]),x->x[1]);;
gap> List(cf,x->x.dimension);
[ 1, 4, 4 ]
gap> coh:=TwoCohomologyGeneric(g,cf[2]);;
gap> coh.cohomology;
[ <an immutable GF2 vector of length 336>, <an immutable GF2 vector of length
    336> ]
gap> e:=Elements(VectorSpace(GF(2),coh.cohomology));;
gap> p:=List(e,x->FpGroupCocycle(coh,x,true));
[ <fp group of size 61440 on the generators [ F1, F2, F3, F4, F5, F6, F7, F8,
      m1, m2, m3, m4 ]>, <fp group of size 61440 on the generators
    [ F1, F2, F3, F4, F5, F6, F7, F8, m1, m2, m3, m4 ]>,
  <fp group of size 61440 on the generators [ F1, F2, F3, F4, F5, F6, F7, F8,
      m1, m2, m3, m4 ]>, <fp group of size 61440 on the generators
    [ F1, F2, F3, F4, F5, F6, F7, F8, m1, m2, m3, m4 ]> ]
gap> p:=List(p,x->Image(IsomorphismPermGroup(x)));
[ <permutation group of size 61440 with 12 generators>,
  <permutation group of size 61440 with 12 generators>,
  <permutation group of size 61440 with 12 generators>,
  <permutation group of size 61440 with 12 generators> ]
gap> STOP_TEST( "grpperm.tst", 1);
