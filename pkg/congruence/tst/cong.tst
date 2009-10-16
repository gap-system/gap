gap> G:=PrincipalCongruenceSubgroup(8);
<principal congruence subgroup of level 8 in SL_2(Z)>
gap> IsGroup(G);
true
gap> IsMatrixGroup(G);
true
gap> IsPrincipalCongruenceSubgroup(G);
true
gap> IsFinitelyGeneratedGroup(G);
true
gap> LevelOfCongruenceSubgroup(G);
8
gap> DimensionOfMatrixGroup(G);
2
gap> MultiplicativeNeutralElement(G);
[ [ 1, 0 ], [ 0, 1 ] ]
gap> One(G);
[ [ 1, 0 ], [ 0, 1 ] ]
gap> [[1,2],[3,4]] in G;
false
gap> [[1,8],[8,65]] in G;
true
gap> G:=PrincipalCongruenceSubgroup(3);
<principal congruence subgroup of level 3 in SL_2(Z)>
gap> ForAll( List([1..100], k -> Random(G)), m -> m in G);
true
gap> ForAll( List([1..100], k -> Random(G,10*k)), m -> m in G);
true
gap> G:=CongruenceSubgroupGamma0(3);
<congruence subgroup CongruenceSubgroupGamma_0(3) in SL_2(Z)>
gap> ForAll( List([1..100], k -> Random(G)), m -> m in G);
true
gap> ForAll( List([1..100], k -> Random(G,10*k)), m -> m in G);
true
gap> G:=CongruenceSubgroupGammaUpper0(3);
<congruence subgroup CongruenceSubgroupGamma^0(3) in SL_2(Z)>
gap> ForAll( List([1..100], k -> Random(G)), m -> m in G);
true
gap> ForAll( List([1..100], k -> Random(G,10*k)), m -> m in G);
true
gap> G:=CongruenceSubgroupGamma1(3);
<congruence subgroup CongruenceSubgroupGamma_1(3) in SL_2(Z)>
gap> ForAll( List([1..100], k -> Random(G)), m -> m in G);
true
gap> ForAll( List([1..100], k -> Random(G,10*k)), m -> m in G);
true
gap> G:=CongruenceSubgroupGammaUpper1(3);
<congruence subgroup CongruenceSubgroupGamma^1(3) in SL_2(Z)>
gap> ForAll( List([1..100], k -> Random(G)), m -> m in G);
true
gap> ForAll( List([1..100], k -> Random(G,10*k)), m -> m in G);
true
gap> G2:=PrincipalCongruenceSubgroup(2);
<principal congruence subgroup of level 2 in SL_2(Z)>
gap> G3:=PrincipalCongruenceSubgroup(3);
<principal congruence subgroup of level 3 in SL_2(Z)>
gap> G6:=PrincipalCongruenceSubgroup(6);
<principal congruence subgroup of level 6 in SL_2(Z)>
gap> G:=SL(2,Integers);
SL(2,Integers)
gap> IsSubgroup(G,G2);
true
gap> IsSubgroup(G3,G2);
false
gap> IsSubgroup(G2,G6);
true
gap> Index(G,G3);
24  
gap> IndexInSL2Z(G6);
144
gap> Index(G3,G6);
6
gap> f:=[PrincipalCongruenceSubgroup,
>        CongruenceSubgroupGamma1,
>        CongruenceSubgroupGammaUpper1,
>        CongruenceSubgroupGamma0,
>        CongruenceSubgroupGammaUpper0];;
gap> g1:=List(f, t -> t(2));;
gap> g2:=List(f, t -> t(4));;
gap> for g in g2 do
> Print( List( g1, x -> IsSubgroup(x,g) ), "\n");
> od;
[ true, true, true, true, true ]
[ false, true, false, true, false ]
[ false, false, true, false, true ]
[ false, false, false, true, false ]
[ false, false, false, false, true ]
gap> Intersection(G2,G3);
<principal congruence subgroup of level 6 in SL_2(Z)>
gap> G6=Intersection(G2,G3);
true
gap> g1:=List(f, t -> t(2));;                           
gap> g2:=List(f, t -> t(2));; 
gap> for g in g2 do                                                          
> Print( List( g1, x -> Intersection(x,g) ), "\n");
> od;
[ PrincipalCongruenceSubgroup(2), PrincipalCongruenceSubgroup(2), 
  PrincipalCongruenceSubgroup(2), PrincipalCongruenceSubgroup(2), 
  PrincipalCongruenceSubgroup(2) ]
[ PrincipalCongruenceSubgroup(2), CongruenceSubgroupGamma1(2), 
  PrincipalCongruenceSubgroup(2), CongruenceSubgroupGamma1(2), 
  PrincipalCongruenceSubgroup(2) ]
[ PrincipalCongruenceSubgroup(2), PrincipalCongruenceSubgroup(2), 
  CongruenceSubgroupGammaUpper1(2), PrincipalCongruenceSubgroup(2), 
  CongruenceSubgroupGammaUpper1(2) ]
[ PrincipalCongruenceSubgroup(2), CongruenceSubgroupGamma1(2), 
  PrincipalCongruenceSubgroup(2), CongruenceSubgroupGamma0(2), 
  IntersectionOfCongruenceSubgroups(
      CongruenceSubgroupGamma0(2),
      CongruenceSubgroupGammaUpper0(2) ) ]
[ PrincipalCongruenceSubgroup(2), PrincipalCongruenceSubgroup(2),
  CongruenceSubgroupGammaUpper1(2), IntersectionOfCongruenceSubgroups(
      CongruenceSubgroupGamma0(2),
      CongruenceSubgroupGammaUpper0(2) ), CongruenceSubgroupGammaUpper0(2) ]  
gap> G:=Intersection(CongruenceSubgroupGamma0(4),CongruenceSubgroupGamma1(3));
<intersection of congruence subgroups of resulting level 12 in SL_2(Z)>
gap> DefiningCongruenceSubgroups(G);
[ <congruence subgroup CongruenceSubgroupGamma_0(4) in SL_2(Z)>,
  <congruence subgroup CongruenceSubgroupGamma_1(3) in SL_2(Z)> ]
gap> H:=Intersection(G,CongruenceSubgroupGamma1(4));
<intersection of congruence subgroups of resulting level 12 in SL_2(Z)>
gap> DefiningCongruenceSubgroups(H);
[ <congruence subgroup CongruenceSubgroupGamma_1(3) in SL_2(Z)>,
  <congruence subgroup CongruenceSubgroupGamma_1(4) in SL_2(Z)> ]
gap> K:=Intersection(H,CongruenceSubgroupGamma0(3));
<congruence subgroup CongruenceSubgroupGamma_1(12) in SL_2(Z)>
gap> List([1..6], n -> IndexInSL2Z(PrincipalCongruenceSubgroup(n)));
[ 1, 12, 24, 48, 120, 144 ]
gap> fs:=FareySymbolByData([infinity,0,1,2,infinity],[1,2,2,1]);                         
[ infinity, 0, 1, 2, infinity ]
[ 1, 2, 2, 1 ]
gap> GeneralizedFareySequence(fs);
[ infinity, 0, 1, 2, infinity ]
gap> List([1..5], i -> NumeratorOfGFSElement(GeneralizedFareySequence(fs),i));
[ -1, 0, 1, 2, 1 ]
gap> List([1..5], i -> DenominatorOfGFSElement(GeneralizedFareySequence(fs),i));         
[ 0, 1, 1, 1, 0 ]
gap> LabelsOfFareySymbol(fs);
[ 1, 2, 2, 1 ]
gap> IsValidFareySymbol(fs);
true
gap> fs:=FareySymbolByData([infinity,0,1,infinity],[1,"even",1]);   
[ infinity, 0, 1, infinity ]
[ 1, "even", 1 ]
gap> Print(fs); Print("\n");
FareySymbolByData( [ infinity, 0, 1, infinity ], [ 1, "even", 1 ] ]
gap> SetInfoLevel(InfoCongruence,1);
gap> fs1_1:=FareySymbolByData([infinity,0,infinity],["even","odd"]);; 
gap> GeneratorsByFareySymbol(last);                                  
[ [ [ 0, -1 ], [ 1, 0 ] ], [ [ 0, -1 ], [ 1, -1 ] ] ]
gap> fs2_1:=FareySymbolByData([infinity,0,infinity],["odd","odd"]);;
gap> GeneratorsByFareySymbol(last);
[ [ [ -1, -1 ], [ 1, 0 ] ], [ [ 0, -1 ], [ 1, -1 ] ] ]
gap> fs2_2:=FareySymbolByData([infinity,0,1,2,infinity],[1,2,2,1]);;
gap> GeneratorsByFareySymbol(last);                                                        
[ [ [ 1, 2 ], [ 0, 1 ] ], [ [ 3, -2 ], [ 2, -1 ] ] ]
gap> fs2_3:=FareySymbolByData([infinity,0,1,infinity],[1,"even",1]);;   
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 2, -1 ] ] ]
gap> fs3_1:=FareySymbolByData([infinity,0,1,infinity],["even","even","even"]);;
gap> GeneratorsByFareySymbol(last);                                            
[ [ [ 0, -1 ], [ 1, 0 ] ], [ [ 1, -1 ], [ 2, -1 ] ], [ [ 1, -2 ], [ 1, -1 ] ]
 ]
gap> fs3_2:=FareySymbolByData([infinity,0,1,2,infinity],["even",1,"even",1]);;      
gap> GeneratorsByFareySymbol(last);                                           
[ [ [ 0, -1 ], [ 1, 0 ] ], [ [ 3, -1 ], [ 1, 0 ] ], [ [ 3, -5 ], [ 2, -3 ] ] ]
gap> fs3_3:=FareySymbolByData([infinity,0,1,2,5/2,3,infinity],[1,2,3,3,2,1]);;                 
gap> GeneratorsByFareySymbol(last);                                           
[ [ [ 1, 3 ], [ 0, 1 ] ], [ [ 8, -3 ], [ 3, -1 ] ], [ [ 7, -12 ], [ 3, -5 ] ] 
 ]
gap> fs3_4:=FareySymbolByData([infinity,0,1,infinity],[1,"odd",1]);;          
gap> GeneratorsByFareySymbol(last);                                 
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 3, -2 ] ] ]
gap> fs4_1:=FareySymbolByData([infinity,0,1/2,1,3/2,2,infinity],[1,2,3,3,2,1]);;       
gap> GeneratorsByFareySymbol(last);                                             
[ [ [ 1, 2 ], [ 0, 1 ] ], [ [ 7, -2 ], [ 4, -1 ] ], [ [ 5, -4 ], [ 4, -3 ] ] ]
gap> fs4_2:=FareySymbolByData([infinity,0,1/2,1,3/2,2,5/2,3,7/2,4,infinity],[1,4,5,5,3,3,2,2,4,1]);;
gap> GeneratorsByFareySymbol(last);                                                                 
[ [ [ 1, 4 ], [ 0, 1 ] ], [ [ 15, -4 ], [ 4, -1 ] ], [ [ 5, -4 ], [ 4, -3 ] ], 
  [ [ 9, -16 ], [ 4, -7 ] ], [ [ 13, -36 ], [ 4, -11 ] ] ]
gap> fs4_4:=FareySymbolByData([infinity,0,1/2,1,infinity],[1,2,2,1]);;               
gap> GeneratorsByFareySymbol(last);                                   
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 3, -1 ], [ 4, -1 ] ] ]
gap> fs4_5:=FareySymbolByData([infinity,0,1,2,infinity],[1,"even","even",1]);;     
gap> GeneratorsByFareySymbol(last);                                           
[ [ [ 1, 2 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 2, -1 ] ], [ [ 3, -5 ], [ 2, -3 ] ] ]
gap> fs4_6:=FareySymbolByData([infinity,0,1,2,3,4,infinity],[1,"even",2,"even",2,1]);;
gap> GeneratorsByFareySymbol(last);                                                   
[ [ [ 1, 4 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 2, -1 ] ], [ [ 7, -11 ], [ 2, -3 ] ],
  [ [ 5, -13 ], [ 2, -5 ] ] ]
gap> fs4_7:=FareySymbolByData([infinity,0,1,infinity],["odd","even","even"]);;        
gap> GeneratorsByFareySymbol(last);
[ [ [ -1, -1 ], [ 1, 0 ] ], [ [ 1, -1 ], [ 2, -1 ] ], 
  [ [ 1, -2 ], [ 1, -1 ] ] ]
gap> fs5_1:=FareySymbolByData([infinity,0,1,2,3,infinity],[1,"even","even",1,"odd"]);;      
gap> GeneratorsByFareySymbol(last);
[ [ [ 3, 2 ], [ 1, 1 ] ], [ [ 1, -1 ], [ 2, -1 ] ], [ [ 3, -5 ], [ 2, -3 ] ], 
  [ [ 3, -13 ], [ 1, -4 ] ] ]  
gap> fs5_2:=FareySymbolByData([infinity,0,1/2,1,4/3,3/2,2,3,infinity],[1,2,3,3,"odd",2,1,"odd"]);;        
gap> GeneratorsByFareySymbol(last);
[ [ [ 3, 2 ], [ 1, 1 ] ], [ [ 7, -2 ], [ 4, -1 ] ], [ [ 6, -5 ], [ 5, -4 ] ], 
  [ [ 26, -37 ], [ 19, -27 ] ], [ [ 3, -13 ], [ 1, -4 ] ] ]
gap> fs5_3:=FareySymbolByData([infinity,0,1/2,1,4/3,7/5,3/2,2,7/3,12/5,5/2,3,10/3,17/5,7/2,4,         
>                              13/3,22/5,9/2,23/5,14/3,5,infinity],
>                             [1,2,6,6,10,11,5,5,11,9,4,4,9,8,3,3,8,7,7,10,2,1]);
[ infinity, 0, 1/2, 1, 4/3, 7/5, 3/2, 2, 7/3, 12/5, 5/2, 3, 10/3, 17/5, 7/2, 
  4, 13/3, 22/5, 9/2, 23/5, 14/3, 5, infinity ]
[ 1, 2, 6, 6, 10, 11, 5, 5, 11, 9, 4, 4, 9, 8, 3, 3, 8, 7, 7, 10, 2, 1 ]
gap> GeneratorsByFareySymbol(fs5_3);    
[ [ [ 1, 5 ], [ 0, 1 ] ], [ [ 24, -5 ], [ 5, -1 ] ], [ [ 6, -5 ], [ 5, -4 ] ], 
  [ [ 139, -190 ], [ 30, -41 ] ], [ [ 59, -85 ], [ 25, -36 ] ], 
  [ [ 11, -20 ], [ 5, -9 ] ], [ [ 84, -205 ], [ 25, -61 ] ], 
  [ [ 16, -45 ], [ 5, -14 ] ], [ [ 109, -375 ], [ 25, -86 ] ], 
  [ [ 21, -80 ], [ 5, -19 ] ], [ [ 91, -405 ], [ 20, -89 ] ] ]
gap> fs11_1:=FareySymbolByData([infinity,-1,0,1,2,infinity],["even","odd","odd","even","even"]);     
[ infinity, -1, 0, 1, 2, infinity ]
[ "even", "odd", "odd", "even", "even" ]
gap> GeneratorsByFareySymbol(last); 
[ [ [ -1, -2 ], [ 1, 1 ] ], [ [ -2, -1 ], [ 3, 1 ] ], 
  [ [ 1, -1 ], [ 3, -2 ] ], [ [ 3, -5 ], [ 2, -3 ] ], 
  [ [ 2, -5 ], [ 1, -2 ] ] ]
gap> fs11_2:=FareySymbolByData([infinity,0,1,2,3,infinity],["even","even","odd","odd","even"]);
[ infinity, 0, 1, 2, 3, infinity ]
[ "even", "even", "odd", "odd", "even" ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 0, -1 ], [ 1, 0 ] ], [ [ 1, -1 ], [ 2, -1 ] ], [ [ 4, -7 ], [ 3, -5 ] ], 
  [ [ 7, -19 ], [ 3, -8 ] ], [ [ 3, -10 ], [ 1, -3 ] ] ]
gap> fs12_1:=FareySymbolByData([infinity,0,1/6,1/5,1/4,1/3,1/2,3/5,2/3,1,4/3,7/5,3/2,5/3,7/4,9/5,11/6,2,infinity],                  
>                              [        1,8,  9,  7,  4,  4,  7,  6,  2,2,  6,  5,  3,  3,  5,  9,   8,1]);
[ infinity, 0, 1/6, 1/5, 1/4, 1/3, 1/2, 3/5, 2/3, 1, 4/3, 7/5, 3/2, 5/3, 7/4, 
  9/5, 11/6, 2, infinity ]
[ 1, 8, 9, 7, 4, 4, 7, 6, 2, 2, 6, 5, 3, 3, 5, 9, 8, 1 ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 2 ], [ 0, 1 ] ], [ [ 23, -2 ], [ 12, -1 ] ], 
  [ [ 109, -20 ], [ 60, -11 ] ], [ [ 17, -4 ], [ 30, -7 ] ], 
  [ [ 7, -2 ], [ 18, -5 ] ], [ [ 41, -26 ], [ 30, -19 ] ], 
  [ [ 7, -6 ], [ 6, -5 ] ], [ [ 53, -76 ], [ 30, -43 ] ], 
  [ [ 31, -50 ], [ 18, -29 ] ] ]
gap> fs12_2:=FareySymbolByData([infinity,0,1,2,3,4,infinity],[1,"odd","odd","odd","odd",1]);                         
[ infinity, 0, 1, 2, 3, 4, infinity ]
[ 1, "odd", "odd", "odd", "odd", 1 ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 4 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 3, -2 ] ], [ [ 4, -7 ], [ 3, -5 ] ], 
  [ [ 7, -19 ], [ 3, -8 ] ], [ [ 10, -37 ], [ 3, -11 ] ] ]
gap> fs12_3:=FareySymbolByData([infinity,0,1,5/4,4/3,3/2,5/3,2,7/3,5/2,8/3,11/4,14/5,3,infinity],                                  
>                              [1,"even",5,4,3,3,"even","even",2,2,4,5,"even",1]);
[ infinity, 0, 1, 5/4, 4/3, 3/2, 5/3, 2, 7/3, 5/2, 8/3, 11/4, 14/5, 3, 
  infinity ]
[ 1, "even", 5, 4, 3, 3, "even", "even", 2, 2, 4, 5, "even", 1 ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 3 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 2, -1 ] ], 
  [ [ 67, -81 ], [ 24, -29 ] ], [ [ 65, -84 ], [ 24, -31 ] ], 
  [ [ 19, -27 ], [ 12, -17 ] ], [ [ 17, -29 ], [ 10, -17 ] ], 
  [ [ 23, -53 ], [ 10, -23 ] ], [ [ 31, -75 ], [ 12, -29 ] ], 
  [ [ 73, -205 ], [ 26, -73 ] ] ]
gap> fs12_4:=FareySymbolByData([infinity,0,1/3,1/2,2/3,1,2,3,10/3,7/2,11/3,4,5,6,infinity],              
>                              [1,"even",3,2,"even","even","even","even",2,3,"even","even","even",1]);
[ infinity, 0, 1/3, 1/2, 2/3, 1, 2, 3, 10/3, 7/2, 11/3, 4, 5, 6, infinity ]
[ 1, "even", 3, 2, "even", "even", "even", "even", 2, 3, "even", "even", 
  "even", 1 ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 6 ], [ 0, 1 ] ], [ [ 3, -1 ], [ 10, -3 ] ], 
  [ [ 43, -18 ], [ 12, -5 ] ], [ [ 41, -24 ], [ 12, -7 ] ], 
  [ [ 7, -5 ], [ 10, -7 ] ], [ [ 3, -5 ], [ 2, -3 ] ], 
  [ [ 5, -13 ], [ 2, -5 ] ], [ [ 33, -109 ], [ 10, -33 ] ], 
  [ [ 37, -137 ], [ 10, -37 ] ], [ [ 9, -41 ], [ 2, -9 ] ], 
  [ [ 11, -61 ], [ 2, -11 ] ] ]
gap> fs12_5:=FareySymbolByData([infinity,0,1/3,2/5,1/2,1,4/3,3/2,2,3,infinity],
>                              ["even",1,"even","even","even","even",1,"even","even","even"]);
[ infinity, 0, 1/3, 2/5, 1/2, 1, 4/3, 3/2, 2, 3, infinity ]
[ "even", 1, "even", "even", "even", "even", 1, "even", "even", "even" ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 0, -1 ], [ 1, 0 ] ], [ [ 13, -3 ], [ 9, -2 ] ], 
  [ [ 13, -5 ], [ 34, -13 ] ], [ [ 12, -5 ], [ 29, -12 ] ], 
  [ [ 3, -2 ], [ 5, -3 ] ], [ [ 13, -17 ], [ 10, -13 ] ], 
  [ [ 8, -13 ], [ 5, -8 ] ], [ [ 5, -13 ], [ 2, -5 ] ], 
  [ [ 3, -10 ], [ 1, -3 ] ] ]
gap> fs12_6:=FareySymbolByData([infinity,0,1,4/3,3/2,5/3,2,3,infinity],                     
>                              [1,"even","even",2,2,"even","even",1]);
[ infinity, 0, 1, 4/3, 3/2, 5/3, 2, 3, infinity ]
[ 1, "even", "even", 2, 2, "even", "even", 1 ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 3 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 2, -1 ] ], 
  [ [ 13, -17 ], [ 10, -13 ] ], [ [ 19, -27 ], [ 12, -17 ] ], 
  [ [ 17, -29 ], [ 10, -17 ] ], [ [ 5, -13 ], [ 2, -5 ] ] ]
gap> fs12_7:=FareySymbolByData([infinity,0,1,2,3,4,5,6,infinity],                
>                              [1,"even","even","even","even","even","even",1]);
[ infinity, 0, 1, 2, 3, 4, 5, 6, infinity ]
[ 1, "even", "even", "even", "even", "even", "even", 1 ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 6 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 2, -1 ] ], [ [ 3, -5 ], [ 2, -3 ] ], 
  [ [ 5, -13 ], [ 2, -5 ] ], [ [ 7, -25 ], [ 2, -7 ] ], 
  [ [ 9, -41 ], [ 2, -9 ] ], [ [ 11, -61 ], [ 2, -11 ] ] ]
gap> fs12_8:=FareySymbolByData([infinity,0,1,3/2,2,3,infinity],                    
>                              ["even","even","even","even","even","even"]);
[ infinity, 0, 1, 3/2, 2, 3, infinity ]
[ "even", "even", "even", "even", "even", "even" ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 0, -1 ], [ 1, 0 ] ], [ [ 1, -1 ], [ 2, -1 ] ], 
  [ [ 7, -10 ], [ 5, -7 ] ], [ [ 8, -13 ], [ 5, -8 ] ], 
  [ [ 5, -13 ], [ 2, -5 ] ], [ [ 3, -10 ], [ 1, -3 ] ] ]
gap> fs12_9:=FareySymbolByData([infinity,0,1/4,1/3,1/2,2/3,3/4,4/5,5/6,1,infinity],        
>                              [1,4,3,2,2,3,4,5,5,1]);
[ infinity, 0, 1/4, 1/3, 1/2, 2/3, 3/4, 4/5, 5/6, 1, infinity ]
[ 1, 4, 3, 2, 2, 3, 4, 5, 5, 1 ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 19, -4 ], [ 24, -5 ] ], 
  [ [ 17, -5 ], [ 24, -7 ] ], [ [ 7, -3 ], [ 12, -5 ] ], 
  [ [ 31, -25 ], [ 36, -29 ] ] ]
gap> fs12_10:=FareySymbolByData([infinity,0,1/6,1/5,1/4,2/7,1/3,2/5,1/2,4/7,7/12,3/5,2/3,5/7,3/4,4/5,5/6,1,infinity],
>                               [1,2,3,7,7,8,8,6,6,9,9,4,4,5,5,3,2,1]);
[ infinity, 0, 1/6, 1/5, 1/4, 2/7, 1/3, 2/5, 1/2, 4/7, 7/12, 3/5, 2/3, 5/7, 
  3/4, 4/5, 5/6, 1, infinity ]
[ 1, 2, 3, 7, 7, 8, 8, 6, 6, 9, 9, 4, 4, 5, 5, 3, 2, 1 ]
gap> GeneratorsByFareySymbol(last);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 11, -1 ], [ 12, -1 ] ], 
  [ [ 49, -9 ], [ 60, -11 ] ], [ [ 13, -3 ], [ 48, -11 ] ], 
  [ [ 13, -4 ], [ 36, -11 ] ], [ [ 13, -6 ], [ 24, -11 ] ], 
  [ [ 85, -49 ], [ 144, -83 ] ], [ [ 25, -16 ], [ 36, -23 ] ], 
  [ [ 37, -27 ], [ 48, -35 ] ] ]
gap> G:=CongruenceSubgroupGamma0(20);
<congruence subgroup CongruenceSubgroupGamma_0(20) in SL_2(Z)>
gap> fs:=FareySymbol(G);
[ infinity, 0, 1/5, 1/4, 2/7, 3/10, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 1, 
  infinity ]
[ 1, 3, 4, 6, 7, 7, 5, 2, 2, 3, 6, 4, 5, 1 ]
gap> G:=PrincipalCongruenceSubgroup(2);
<principal congruence subgroup of level 2 in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1, 2, infinity ]
[ 2, 1, 1, 2 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 2 ], [ 0, 1 ] ], [ [ 3, -2 ], [ 2, -1 ] ] ]
gap> G:=CongruenceSubgroupGamma0(2);                               
<congruence subgroup CongruenceSubgroupGamma_0(2) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1, infinity ]
[ 1, "even", 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 2, -1 ] ] ]
gap> G:=CongruenceSubgroupGamma0(3);        
<congruence subgroup CongruenceSubgroupGamma_0(3) in SL_2(Z)>
gap> FareySymbol(G);      
[ infinity, 0, 1, infinity ]
[ 1, "odd", 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 1, -1 ], [ 3, -2 ] ] ]
gap> G:=PrincipalCongruenceSubgroup(4);
<principal congruence subgroup of level 4 in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/2, 1, 3/2, 2, 5/2, 3, 7/2, 4, infinity ]
[ 1, 5, 2, 2, 3, 3, 4, 4, 5, 1 ]
gap> GeneratorsOfGroup(G);             
[ [ [ 1, 4 ], [ 0, 1 ] ], [ [ -15, 4 ], [ -4, 1 ] ], [ [ 5, -4 ], [ 4, -3 ] ], 
  [ [ 9, -16 ], [ 4, -7 ] ], [ [ 13, -36 ], [ 4, -11 ] ] ]
gap> G:=CongruenceSubgroupGamma0(4);                      
<congruence subgroup CongruenceSubgroupGamma_0(4) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/2, 1, infinity ]
[ 1, 2, 2, 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 3, -1 ], [ 4, -1 ] ] ]
gap> G:=CongruenceSubgroupGamma0(5);        
<congruence subgroup CongruenceSubgroupGamma_0(5) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/2, 1, infinity ]
[ 1, "even", "even", 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 2, -1 ], [ 5, -2 ] ], [ [ 3, -2 ], [ 5, -3 ] ] ]
gap> G:=CongruenceSubgroupGamma0(6);        
<congruence subgroup CongruenceSubgroupGamma_0(6) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/3, 1/2, 2/3, 1, infinity ]
[ 1, 3, 2, 2, 3, 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 5, -1 ], [ 6, -1 ] ], [ [ 7, -3 ], [ 12, -5 ] ] 
 ]
gap> G:=CongruenceSubgroupGamma0(7);        
<congruence subgroup CongruenceSubgroupGamma_0(7) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/2, 1, infinity ]
[ 1, "odd", "odd", 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 2, -1 ], [ 7, -3 ] ], [ [ 4, -3 ], [ 7, -5 ] ] ]
gap> G:=CongruenceSubgroupGamma0(9);        
<congruence subgroup CongruenceSubgroupGamma_0(9) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/3, 1/2, 2/3, 1, infinity ]
[ 1, 2, 2, 3, 3, 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 4, -1 ], [ 9, -2 ] ], [ [ 7, -4 ], [ 9, -5 ] ] ]
gap> G:=CongruenceSubgroupGamma0(10);       
<congruence subgroup CongruenceSubgroupGamma_0(10) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/3, 2/5, 1/2, 3/5, 2/3, 1, infinity ]
[ 1, "even", 3, 2, 2, 3, "even", 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 3, -1 ], [ 10, -3 ] ], 
  [ [ 19, -7 ], [ 30, -11 ] ], [ [ 11, -5 ], [ 20, -9 ] ], 
  [ [ 7, -5 ], [ 10, -7 ] ] ]
gap> G:=CongruenceSubgroupGamma0(13);       
<congruence subgroup CongruenceSubgroupGamma_0(13) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/3, 1/2, 2/3, 1, infinity ]
[ 1, "odd", "even", "even", "odd", 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 3, -1 ], [ 13, -4 ] ], 
  [ [ 5, -2 ], [ 13, -5 ] ], [ [ 8, -5 ], [ 13, -8 ] ],
  [ [ 9, -7 ], [ 13, -10 ] ] ]
gap> G:=CongruenceSubgroupGamma0(18);       
<congruence subgroup CongruenceSubgroupGamma_0(18) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/6, 1/5, 2/9, 1/4, 1/3, 1/2, 2/3, 3/4, 7/9, 4/5, 5/6, 1, 
  infinity ]
[ 1, 4, 4, 7, 6, 2, 2, 3, 3, 6, 7, 5, 5, 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 7, -1 ], [ 36, -5 ] ], 
  [ [ 71, -15 ], [ 90, -19 ] ], [ [ 55, -13 ], [ 72, -17 ] ], 
  [ [ 7, -2 ], [ 18, -5 ] ], [ [ 13, -8 ], [ 18, -11 ] ], 
  [ [ 31, -25 ], [ 36, -29 ] ] ]
gap> G:=CongruenceSubgroupGamma0(25);       
<congruence subgroup CongruenceSubgroupGamma_0(25) in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/5, 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 1, infinity ]
[ 1, 2, 2, "even", 3, 3, 4, 4, "even", 5, 5, 1 ]
gap> GeneratorsOfGroup(G);
[ [ [ 1, 1 ], [ 0, 1 ] ], [ [ 6, -1 ], [ 25, -4 ] ], 
  [ [ 7, -2 ], [ 25, -7 ] ], [ [ 11, -4 ], [ 25, -9 ] ], 
  [ [ 16, -9 ], [ 25, -14 ] ], [ [ 18, -13 ], [ 25, -18 ] ], 
  [ [ 21, -16 ], [ 25, -19 ] ] ]
gap> G:=IntersectionOfCongruenceSubgroups(PrincipalCongruenceSubgroup(2),CongruenceSubgroupGamma0(4));      
<intersection of congruence subgroups of resulting level 4 in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/2, 1, 3/2, 2, infinity ]
[ 1, 3, 2, 2, 3, 1 ]
gap> GeneratorsOfGroup(G);
#I  Using the Congruence package for GeneratorsOfGroup ...
[ [ [ 1, 2 ], [ 0, 1 ] ], [ [ 7, -2 ], [ 4, -1 ] ], [ [ 5, -4 ], [ 4, -3 ] ] ]
gap> G:=IntersectionOfCongruenceSubgroups(PrincipalCongruenceSubgroup(2),CongruenceSubgroupGamma0(3));
<intersection of congruence subgroups of resulting level 6 in SL_2(Z)>
gap> FareySymbol(G);
[ infinity, 0, 1/3, 1/2, 2/3, 1, 4/3, 3/2, 5/3, 2, infinity ]
[ 1, 5, 4, 3, 2, 2, 3, 4, 5, 1 ]
gap> GeneratorsOfGroup(G);                                                          
#I  Using the Congruence package for GeneratorsOfGroup ...
[ [ [ 1, 2 ], [ 0, 1 ] ], [ [ 11, -2 ], [ 6, -1 ] ], 
  [ [ 19, -8 ], [ 12, -5 ] ], [ [ 17, -10 ], [ 12, -7 ] ], 
  [ [ 7, -6 ], [ 6, -5 ] ] ]
gap> G16:=CongruenceSubgroupGamma0(16);;
gap> FS16:=FareySymbol(G16);;
gap> gens:=GeneratorsByFareySymbol(FS16);;
gap> glue_list:=gluing_matrices(FS16);    
[ 1, 2, -2, 3, -3, 4, -4, 5, -5, -1 ]
gap> for i in [1..10] do
>      g:=Random(G16);
>      w:=FactorizeMat( G16, g );
>      h:=CheckFactorizeMat(gens,w);       
>      Print(g," : ",h," : ", g=h or g=-h, "\n");
>    od;