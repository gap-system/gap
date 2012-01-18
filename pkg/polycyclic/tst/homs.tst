gap> START_TEST("Test of homs between various group types");

gap> TestHom := function(A,B,gens_A,gens_B)
>   local map, inv, H;
> #  Display(List(gens_A,g->IndependentGeneratorExponents(A,g)));
> #  Display(List(gens_B,g->IndependentGeneratorExponents(B,g)));
>   
>   map:=GroupGeneralMappingByImages(A,B,gens_A,gens_B);
>   inv:=GroupGeneralMappingByImages(B,A,gens_B,gens_A);
>   
>   Display(HasIsAbelian(ImagesSource(map)));
>   Display(HasIsAbelian(PreImagesRange(map)));
> 
>   Display(inv = InverseGeneralMapping(map));
>   Display(List([IsTotal,IsSingleValued,IsSurjective,IsInjective], f->f(map)));
>   Display(List([IsTotal,IsSingleValued,IsSurjective,IsInjective], f->f(inv)));
>   Display(List([PreImagesRange(map),CoKernel(map),ImagesSource(map),Kernel(map)],Size));
>   Display(List([PreImagesRange(inv),CoKernel(inv),ImagesSource(inv),Kernel(inv)],Size));
> end;;
gap> 
gap> filters:=[IsPermGroup,IsPcGroup,IsPcpGroup];;
gap> for i1 in [1..Length(filters)] do
>   f1:=filters[i1];
>   for i2 in [1..Length(filters)] do
>     f2:=filters[i2];
>     Print("### Starting test (", i1, ",", i2, ") ###\n");
>     A:=AbelianGroup(f1,[35,15]);;
>     B:=AbelianGroup(f2,[35,15]);;
>     iA := IndependentGeneratorsOfAbelianGroup(A);
>     iB := IndependentGeneratorsOfAbelianGroup(B);
>     
>     TestHom(A,B,iA,iB);
>     
>     gens_A:=ShallowCopy(iA);
>     gens_B:=ShallowCopy(iB);
>     gens_A:=gens_A{[1..3]};
>     gens_B:=gens_B{[1..3]};
>     TestHom(A,B,gens_A,gens_B);
>     
>     gens_A[1]:=One(gens_A[1]);;
>     gens_A[2]:=MappedVector([ 0, 1, 0, 6 ], iA);;
>     gens_B[3]:=One(gens_B[3]);;
>     
>     TestHom(A,B,gens_A,gens_B);
>     
>     gens_A[1]:=MappedVector([ 2, 1, 1, 0 ], iA);
>     TestHom(A,B,gens_A,gens_B); 
>   od;
> od;
### Starting test (1,1) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]
### Starting test (1,2) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]
### Starting test (1,3) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]
### Starting test (2,1) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]
### Starting test (2,2) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]
### Starting test (2,3) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]
### Starting test (3,1) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]
### Starting test (3,2) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]
### Starting test (3,3) ###
true
true
true
[ true, true, true, true ]
[ true, true, true, true ]
[ 525, 1, 525, 1 ]
[ 525, 1, 525, 1 ]
true
true
true
[ false, true, false, true ]
[ false, true, false, true ]
[ 75, 1, 75, 1 ]
[ 75, 1, 75, 1 ]
true
true
true
[ false, false, false, false ]
[ false, false, false, false ]
[ 175, 3, 15, 35 ]
[ 15, 35, 175, 3 ]
true
true
true
[ true, false, false, false ]
[ false, false, true, false ]
[ 525, 5, 15, 175 ]
[ 15, 175, 525, 5 ]


gap> G:=AbelianGroup(IsPcpGroup,[2,3,2]);;
gap> map:=GroupGeneralMappingByImages(G,G,[G.1],[G.3]);;
gap> Size(PreImagesSet(map,G));
2
gap> List([IsTotal,IsSingleValued,IsSurjective,IsInjective], f->f(map));
[ false, true, false, true ]
gap> map2:=map*map;;
gap> Size(PreImagesSet(map2,G));
1
gap> Size(ImagesSet(map2,G));
1
gap> Size(ImagesSource(map2));
1
gap> Size(PreImagesRange(map2));
1

gap> STOP_TEST( "homs.tst", 10000000);

