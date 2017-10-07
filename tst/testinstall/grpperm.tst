gap> START_TEST("grpperm.tst");
gap> G := Group((1,2),(1,2,3,4));;
gap> HasAbelianFactorGroup(G,G);
true
gap> HasElementaryAbelianFactorGroup(G,G);
true
gap> HasSolvableFactorGroup(G,G);
true
gap> N := Group((1,2)(3,4),(1,3)(2,4));;
gap> HasAbelianFactorGroup(G,N);
false
gap> HasElementaryAbelianFactorGroup(G,N);
false
gap> HasSolvableFactorGroup(G,N);
true
gap> IsAbelian(N);
true
gap> HasAbelianFactorGroup(N, Group((1,2)));
true
gap> IsElementaryAbelian(N);
true
gap> HasElementaryAbelianFactorGroup(N, Group((1,2)));
true
gap> N := Group((1,2)(3,4),(1,2,3));;
gap> HasAbelianFactorGroup(G,N);
true
gap> HasElementaryAbelianFactorGroup(G,N);
true
gap> HasSolvableFactorGroup(G,N);
true
gap> IsSolvable(G);
true
gap> HasSolvableFactorGroup(G,N);
true
gap> F := FreeGroup("x","y");; x := F.1;; y:=F.2;;
gap> G := F/[x^18,y];;
gap> HasElementaryAbelianFactorGroup(G, Group(G.1^2));
true
gap> HasElementaryAbelianFactorGroup(G, Group(G.1^3));
true
gap> HasElementaryAbelianFactorGroup(G, Group(G.1^6));
false
gap> HasElementaryAbelianFactorGroup(G, Group(G.1^9));
false
gap> HasSolvableFactorGroup(SymmetricGroup(5), Group(()));
false
gap> HasSolvableFactorGroup(SymmetricGroup(5), SymmetricGroup(5));
true
gap> HasSolvableFactorGroup(SymmetricGroup(5), AlternatingGroup(5));
true
gap> HasSolvableFactorGroup(AlternatingGroup(5), AlternatingGroup(5));
true
gap> cube := Group(( 1, 3, 8, 6)( 2, 5, 7, 4)( 9,33,25,17)(10,34,26,18)(11,35,27,19),( 9,11,16,14)(10,13,15,12)( 1,17,41,40)( 4,20,44,37)( 6,22,46,35),(17,19,24,22)(18,21,23,20)( 6,25,43,16)( 7,28,42,13)( 8,30,41,11),(25,27,32,30)(26,29,31,28)( 3,38,43,19)( 5,36,45,21)( 8,33,48,24),(33,35,40,38)(34,37,39,36)( 3, 9,46,32)( 2,12,47,29)( 1,14,48,27),(41,43,48,46)(42,45,47,44)(14,22,30,38)(15,23,31,39)(16,24,32,40) );;
gap> HasSolvableFactorGroup(cube, Center(cube));
false
gap> HasSolvableFactorGroup(cube, DerivedSeriesOfGroup(cube)[2]);
true
gap> G := SylowSubgroup(SymmetricGroup(2^7),2);;
gap> N := Center(G);;
gap> HasSolvableFactorGroup(G,N);
true
gap> s:=SymmetricGroup([ 1, 5, 6, 7, 8, 9, 10 ]);;
gap> RepresentativeAction(s,(9,10),(1,5)) in s;
true
gap> if IsPackageMarkedForLoading("tomlib","") then
> if Length(MaximalSubgroupClassReps(SimpleGroup("M24"))) <> 9 then
> Print( "Error in calculation MaximalSubgroupClassReps of M24\n" );
> fi; fi;
gap> g:=SimpleGroup("L4(3)");;
gap> Length(MaximalSubgroupClassReps(g));
8
gap> g:=PSL(8,2);;
gap> Length(MaximalSubgroupClassReps(g));
10
gap> G := SymmetricGroup(6);;
gap> IsSolvable(G);
false
gap> Length(MinimalGeneratingSet(G));
2
gap> STOP_TEST( "grpperm.tst", 1);
