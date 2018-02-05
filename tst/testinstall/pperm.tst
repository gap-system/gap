#############################################################################
##
#W  pperm.tst
#Y  James D. Mitchell
##
#############################################################################
##
## takes around 4 seconds to run

#
gap> START_TEST("pperm.tst");
gap> display:=UserPreference("PartialPermDisplayLimit");;
gap> notationpp:=UserPreference("NotationForPartialPerms");;
gap> notationt:=UserPreference("NotationForTransformations");;
gap> SetUserPreference("PartialPermDisplayLimit", 100);;
gap> SetUserPreference("NotationForPartialPerms", "component");;
gap> SetUserPreference("NotationForTransformations", "fr");;

# GAP-level functions
#
gap> f:=PartialPerm( [ 4, 5, 7, 8 ], [ 5, 4, 1, 6 ] );
[7,1][8,6](4,5)
gap> g:=PartialPerm([2]);;
gap> NaturalLeqPartialPerm(g, f);
false
gap> g:=PartialPerm([0,0,0,0,4]);;
gap> NaturalLeqPartialPerm(g, f);
true

#
gap> f:=EmptyPartialPerm();;
gap> ImageSetOfPartialPerm(f);
[  ]
gap> ImageListOfPartialPerm(f);
[  ]
gap> f:=EmptyPartialPerm()^-1;;
gap> ImageSetOfPartialPerm(f);
[  ]
gap> ImageListOfPartialPerm(f);
[  ]

# test input validation
gap> DegreeOfPartialPerm(fail);
Error, usage: the argument should be a partial perm,
gap> CoDegreeOfPartialPerm(fail);
Error, usage: the argument should be a partial perm,
gap> RankOfPartialPerm(fail);
Error, usage: the argument should be a partial perm,
gap> 

# SmallestIdempotentPower, IndexPeriodOfPartialPerm, IsIdempotent
gap> f:=RandomPartialPerm(100000);;
gap> IsIdempotent(f^SmallestIdempotentPower(f));
true
gap> x:=IndexPeriodOfPartialPerm(f);;
gap> f^x[1]=f^(x[1]+x[2]);
true
gap> RankOfPartialPerm(f^(x[1]-1))>RankOfPartialPerm(f^x[1]);
true
gap> f:=RandomPartialPerm(100000);;
gap> IsIdempotent(f^SmallestIdempotentPower(f));
true
gap> x:=IndexPeriodOfPartialPerm(f);;
gap> f^x[1]=f^(x[1]+x[2]);
true
gap> RankOfPartialPerm(f^(x[1]-1))>RankOfPartialPerm(f^x[1]);
true
gap> f:=RandomPartialPerm(1000);;
gap> IsIdempotent(f^SmallestIdempotentPower(f));
true
gap> x:=IndexPeriodOfPartialPerm(f);;
gap> f^x[1]=f^(x[1]+x[2]);
true
gap> RankOfPartialPerm(f^(x[1]-1))>RankOfPartialPerm(f^x[1]);
true
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 6, 7, 8, 10, 12, 14 ], 
> [ 15, 11, 5, 8, 9, 3, 6, 2, 4, 1 ] );;
gap> IndexPeriodOfPartialPerm(f);
[ 5, 1 ]
gap> f^5=f^6;
true
gap> f^5;
<empty partial perm>
gap> f^6;
<empty partial perm>
gap> f^4;                                                    
[12,9]
gap> f := PartialPerm( [ 1, 2, 3 ], [ 70000, 3, 4 ] );
[1,70000][2,3,4]
gap> IsIdempotent(f);
false
gap> f:=PartialPermNC([1..10]);;   
gap> IsIdempotent(f);
true
gap> f:=PartialPermNC([1..10]); 
<identity partial perm on [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]>
gap> IsIdempotent(f);
true
gap> f:=PartialPerm( [ 1, 2 ], [ 3, 1 ] );;
gap> IsIdempotent(f);
false
gap> f:=PartialPermNC([1..100000]); 
<partial perm on 100000 pts with degree 100000, codegree 100000>
gap> IsIdempotent(f);
true
gap> f:=PartialPermNC([1..100000]);;
gap> IsIdempotent(f);
true
gap> f := PartialPerm([], []);
<empty partial perm>
gap> IndexPeriodOfPartialPerm(f);
[ 1, 1 ]
gap> SmallestIdempotentPower(f);
1
gap> f:=PartialPerm([2,3,1,5,6,7,8,4,10]);
[9,10](1,2,3)(4,5,6,7,8)
gap> SmallestIdempotentPower(f);
15
gap> IndexPeriodOfPartialPerm(f);
[ 2, 15 ]
gap> IsIdempotent(f);
false

# ComponentsOfPartialPerm, NrComponentsOfPartialPerm, 
# ComponentRepsOfPartialPerm and ComponentPartialPermInt
gap> f:=RandomPartialPerm(100000);;
gap> NrComponentsOfPartialPerm(f)=Length(ComponentsOfPartialPerm(f));
true
gap> Union(ComponentsOfPartialPerm(f))=Union(DomainOfPartialPerm(f), 
> ImageSetOfPartialPerm(f));
true
gap> List(ComponentRepsOfPartialPerm(f), i-> ComponentPartialPermInt(f, i))
> =ComponentsOfPartialPerm(f);
true
gap> f:=RandomPartialPerm(100);;
gap> NrComponentsOfPartialPerm(f)=Length(ComponentsOfPartialPerm(f));
true
gap> Union(ComponentsOfPartialPerm(f))=Union(DomainOfPartialPerm(f), 
> ImageSetOfPartialPerm(f));
true
gap> List(ComponentRepsOfPartialPerm(f), i-> ComponentPartialPermInt(f, i))
> =ComponentsOfPartialPerm(f);
true
gap> f := PartialPerm([], []);
<empty partial perm>
gap> ComponentsOfPartialPerm(f);
[  ]
gap> ComponentRepsOfPartialPerm(f);
[  ]
gap> NrComponentsOfPartialPerm(f);
0
gap> f:=PartialPerm([2,3,1,5,6,7,8,4,10]);
[9,10](1,2,3)(4,5,6,7,8)
gap> ComponentsOfPartialPerm(f);
[ [ 9, 10 ], [ 1, 2, 3 ], [ 4, 5, 6, 7, 8 ] ]
gap> ComponentRepsOfPartialPerm(f);
[ 9, 1, 4 ]
gap> NrComponentsOfPartialPerm(f);
3

# FixedPointsOfPartialPerm, MovedPoints, 
# NrFixedPoints, NrMovedPoints
gap> f:=RandomPartialPerm(100000);;
gap> FixedPointsOfPartialPerm(f)=
> Filtered([1..DegreeOfPartialPerm(f)], i-> i^f=i);
true
gap> f:=PartialPermNC([1..100000]);
<partial perm on 100000 pts with degree 100000, codegree 100000>
gap> FixedPointsOfPartialPerm(f)=[1..100000];
true
gap> f:=RandomPartialPerm(20);;
gap> FixedPointsOfPartialPerm(f)=
> Filtered([1..DegreeOfPartialPerm(f)], i-> i^f=i);
true
gap> f:=RandomPartialPerm(20);;
gap> DomainOfPartialPerm(f);;
gap> FixedPointsOfPartialPerm(f)=
> Filtered([1..DegreeOfPartialPerm(f)], i-> i^f=i);
true
gap> f:=RandomPartialPerm(100000);;
gap> NrMovedPoints(f)+NrFixedPoints(f)=
> RankOfPartialPerm(f);
true
gap> Union(MovedPoints(f), FixedPointsOfPartialPerm(f))=
> DomainOfPartialPerm(f);
true
gap> Intersection(MovedPoints(f), FixedPointsOfPartialPerm(f));
[  ]
gap> f:=RandomPartialPerm(100);;
gap> NrMovedPoints(f)+NrFixedPoints(f)=
> RankOfPartialPerm(f);
true
gap> Union(MovedPoints(f), FixedPointsOfPartialPerm(f))=
> DomainOfPartialPerm(f);
true
gap> Intersection(MovedPoints(f), FixedPointsOfPartialPerm(f));
[  ]

# LargestMovedPoint, SmallestMovedPoint
gap> f:=RandomPartialPerm(100000);; DomainOfPartialPerm(f);;
gap> i:=LargestMovedPoint(f);;
gap> i^f<>i;
true
gap> f:=RandomPartialPerm(100000);;
gap> i:=LargestMovedPoint(f);;
gap> i^f<>i;
true
gap> f:=RandomPartialPerm(100);;   DomainOfPartialPerm(f);;
gap> i:=LargestMovedPoint(f);;
gap> i^f<>i;
true
gap> f:=RandomPartialPerm(100);;
gap> i:=LargestMovedPoint(f);;
gap> i^f<>i;
true
gap> f:=PartialPermNC([1..100]);;
gap> LargestMovedPoint(f);
0
gap> f:=PartialPermNC([1..100]); 
<partial perm on 100 pts with degree 100, codegree 100>
gap> LargestMovedPoint(f);
0
gap> f:=PartialPermNC([4,2,3]);; DomainOfPartialPerm(f);;
gap> LargestMovedPoint(f);
1
gap> f:=PartialPermNC([4,2,3]);; 
gap> LargestMovedPoint(f);
1
gap> f:=PartialPermNC(Concatenation([100001], [2..100000]));
<partial perm on 100000 pts with degree 100000, codegree 100001>
gap> LargestMovedPoint(f);
1
gap> f:=PartialPermNC(Concatenation([100001], [2..100000]));;
gap> LargestMovedPoint(f);
1
gap> f:=PartialPermNC([1..100000]);                          
<partial perm on 100000 pts with degree 100000, codegree 100000>
gap> LargestMovedPoint(f);
0
gap> f:=RandomPartialPerm(100000);; DomainOfPartialPerm(f);;
gap> i:=SmallestMovedPoint(f);;
gap> i^f<>i;
true
gap> f:=RandomPartialPerm(100000);;
gap> i:=SmallestMovedPoint(f);;
gap> i^f<>i;
true
gap> f:=RandomPartialPerm(100);;   DomainOfPartialPerm(f);;
gap> i:=SmallestMovedPoint(f);;
gap> i^f<>i;
true
gap> f:=RandomPartialPerm(100);;
gap> i:=SmallestMovedPoint(f);;
gap> i^f<>i;
true
gap> f:=PartialPermNC([1..100]);;
gap> SmallestMovedPoint(f);
infinity
gap> f:=PartialPermNC([1..100]); 
<partial perm on 100 pts with degree 100, codegree 100>
gap> SmallestMovedPoint(f);
infinity
gap> f:=PartialPermNC([4,2,3]);; DomainOfPartialPerm(f);;
gap> SmallestMovedPoint(f);
1
gap> f:=PartialPermNC([4,2,3]);; 
gap> SmallestMovedPoint(f);
1
gap> f:=PartialPermNC(Concatenation([100001], [2..100000]));
<partial perm on 100000 pts with degree 100000, codegree 100001>
gap> SmallestMovedPoint(f);
1
gap> f:=PartialPermNC(Concatenation([100001], [2..100000]));;
gap> SmallestMovedPoint(f);
1
gap> f:=PartialPermNC([1..100000]);                          
<partial perm on 100000 pts with degree 100000, codegree 100000>
gap> SmallestMovedPoint(f);
infinity

# TRIM_PPERM
gap> f:=PartialPermNC([65536]); 
[1,65536]
gap> g:=PartialPermNC([2,65536], [70000,1]);           
[2,70000][65536,1]
gap> h:=f*g;
<identity partial perm on [ 1 ]>
gap> IsPPerm4Rep(h);
true
gap> TRIM_PPERM(h); h;
<identity partial perm on [ 1 ]>
gap> IsPPerm2Rep(h);
true
gap> h:=f*g;;
gap> IsPPerm4Rep(h);
true
gap> TRIM_PPERM(h); h;
<identity partial perm on [ 1 ]>
gap> IsPPerm2Rep(h);
true

# LeftOne
gap> f:=RandomPartialPerm(10);; DomainOfPartialPerm(f);;
gap> e:=LeftOne(f);;
gap> IsIdempotent(e);
true
gap> e*f=f;
true
gap> DomainOfPartialPerm(e)=DomainOfPartialPerm(f);
true
gap> ImageListOfPartialPerm(e)=DomainOfPartialPerm(f);
true
gap> f:=RandomPartialPerm(10);;
gap> e:=LeftOne(f);;
gap> IsIdempotent(e);
true
gap> e*f=f;         
true
gap> DomainOfPartialPerm(e)=DomainOfPartialPerm(f);
true
gap> ImageListOfPartialPerm(e)=DomainOfPartialPerm(f);
true
gap> f:=RandomPartialPerm(100000);;
gap> e:=LeftOne(f);;
gap> IsIdempotent(e);
true
gap> e*f=f;         
true
gap> DomainOfPartialPerm(e)=DomainOfPartialPerm(f);
true
gap> ImageListOfPartialPerm(e)=DomainOfPartialPerm(f);
true
gap> f:=RandomPartialPerm(100000);; DomainOfPartialPerm(f);;
gap> e:=LeftOne(f);;
gap> IsIdempotent(e);
true
gap> e*f=f;
true
gap> DomainOfPartialPerm(e)=DomainOfPartialPerm(f);
true
gap> ImageListOfPartialPerm(e)=DomainOfPartialPerm(f);
true
gap> f:=PartialPermNC([65536], [1]);
[65536,1]
gap> e:=LeftOne(f);
<identity partial perm on [ 65536 ]>
gap> e*f=f;
true
gap> f:=PartialPermNC([1], [65536]);
[1,65536]
gap> e:=LeftOne(f);
<identity partial perm on [ 1 ]>
gap> e*f=f;
true

#RightOne
gap> f:=RandomPartialPerm(10);; ImageSetOfPartialPerm(f);;
gap> e:=RightOne(f);;
gap> IsIdempotent(e);
true
gap> f*e=f;
true
gap> ImageListOfPartialPerm(e)=ImageSetOfPartialPerm(f);
true
gap> DomainOfPartialPerm(e)=ImageSetOfPartialPerm(f);
true
gap> f:=RandomPartialPerm(10);; 
gap> e:=RightOne(f);;
gap> IsIdempotent(e);
true
gap> f*e=f;
true
gap> ImageListOfPartialPerm(e)=ImageSetOfPartialPerm(f);
true
gap> DomainOfPartialPerm(e)=ImageSetOfPartialPerm(f);
true
gap> f:=RandomPartialPerm(100000);; ImageSetOfPartialPerm(f);;
gap> e:=RightOne(f);;
gap> IsIdempotent(e);
true
gap> f*e=f;
true
gap> ImageListOfPartialPerm(e)=ImageSetOfPartialPerm(f);
true
gap> DomainOfPartialPerm(e)=ImageSetOfPartialPerm(f);
true
gap> f:=RandomPartialPerm(100000);; 
gap> e:=RightOne(f);;
gap> IsIdempotent(e);
true
gap> f*e=f;
true
gap> ImageListOfPartialPerm(e)=ImageSetOfPartialPerm(f);
true
gap> DomainOfPartialPerm(e)=ImageSetOfPartialPerm(f);
true
gap> f:=PartialPermNC([65536], [1]);
[65536,1]
gap> e:=RightOne(f);
<identity partial perm on [ 1 ]>
gap> f*e=f;
true
gap> f:=PartialPermNC([1], [65536]);
[1,65536]
gap> e:=RightOne(f);
<identity partial perm on [ 65536 ]>
gap> f*e=f;
true

# NaturalLeqPartialPerm
gap> f:=PartialPermNC([1], [65536]);
[1,65536]
gap> NaturalLeqPartialPerm(f,f);
true
gap> g:=PartialPermNC([1,2], [65536,4]);
[1,65536][2,4]
gap> NaturalLeqPartialPerm(f,g);
true
gap> NaturalLeqPartialPerm(g,f);
false
gap> f:=PartialPermNC([1], [10]);                               
[1,10]
gap> g:=PartialPermNC([1,2], [10,4]);   
[1,10][2,4]
gap> NaturalLeqPartialPerm(f,g);
true
gap> g:=PartialPerm( [ 1, 2, 3, 4, 6, 7, 8, 10 ], 
> [ 3, 8, 1, 9, 4, 10, 5, 6 ] );; 
gap> DomainOfPartialPerm(g);;
gap> NaturalLeqPartialPerm(f,g);
false
gap> g:=PartialPermNC([1,2], [10,100000]);
[1,10][2,100000]
gap> NaturalLeqPartialPerm(f,g);
true
gap> g:=       
> PartialPerm( [ 1, 2, 4, 6, 8, 9 ], 
> [ 42760, 64197, 33426, 57309, 17780, 69833 ] );
[1,42760][2,64197][4,33426][6,57309][8,17780][9,69833]
gap> NaturalLeqPartialPerm(f,g);
false
gap> f:=PartialPermNC([1,0,0,0,0,10]);;
gap> NaturalLeqPartialPerm(f,g);
false
gap> g:=PartialPermNC([1,5,6], [1,10,100000]);
[5,10][6,100000](1)
gap> NaturalLeqPartialPerm(f,g);
false
gap> g:=PartialPermNC([1,6,7], [1,10,100000]);
[6,10][7,100000](1)
gap> NaturalLeqPartialPerm(f,g);
true
gap> g:=PartialPermNC([1,6,7], [1,10,1000]);  
[6,10][7,1000](1)
gap> NaturalLeqPartialPerm(f,g);
true
gap> g:= 
> PartialPerm( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
>    19, 20, 21, 22, 23, 25, 26, 27, 29, 30, 32, 33, 34, 35, 37, 40, 42, 47, 
>    48, 49, 50, 51, 52, 53, 56, 57, 59, 62, 63, 66, 67, 69, 70, 75, 76, 78, 
>    80, 84, 87, 88, 89, 93, 96 ], 
> [ 66, 52, 4, 5, 62, 49, 97, 86, 41, 48, 28, 2, 60, 69, 77, 96, 47, 67, 1, 
>    88, 100, 32, 16, 71, 63, 64, 94, 29, 46, 22, 51, 3, 31, 9, 38, 81, 30, 
>    87, 98, 17, 82, 85, 90, 33, 89, 74, 50, 80, 35, 36, 27, 54, 73, 20, 40, 
>    57, 92, 34, 8, 99, 25 ] );;
gap> NaturalLeqPartialPerm(f,g);
false
gap> f:=PartialPermNC([1],[100000]);;  
gap> f:=PartialPermNC([1],[100000]); 
[1,100000]
gap> f:=PartialPermNC([1],[100000])*PartialPermNC([100000], [2]);
[1,2]
gap> IsPPerm4Rep(f);
false
gap> f:=PartialPermNC([1],[100000])*PartialPermNC([1,100000], [100000,2]);
[1,2]
gap> IsPPerm4Rep(f);
true
gap> g:=PartialPermNC([1,2],[2,3]);
[1,2,3]
gap> NaturalLeqPartialPerm(f,g);
true
gap> g:=
> PartialPerm( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 18, 19, 
>     20, 21, 22, 23, 27, 28, 29, 30, 31, 32, 33, 34, 35, 38, 39, 40, 41, 42, 
>     45, 46, 49, 52, 53, 54, 56, 58, 59, 60, 66, 71, 72, 73, 74, 75, 77, 79, 
>     80, 85, 86, 92, 93, 96 ], 
>  [ 26, 38, 18, 89, 41, 54, 85, 59, 24, 95, 35, 64, 25, 32, 21, 23, 94, 28, 
>     79, 31, 46, 22, 75, 27, 42, 20, 73, 3, 7, 37, 14, 65, 78, 1, 76, 15, 57, 
>     66, 49, 16, 19, 74, 52, 71, 72, 2, 86, 80, 40, 44, 4, 62, 47, 81, 58, 50, 
>     9, 61, 43, 10 ] );;
gap> NaturalLeqPartialPerm(f,g);
false
gap> f:=PartialPermNC([1],[100000]);                                      
[1,100000]
gap> g:=PartialPermNC([1,2,3], [100000,4,5]);;;
gap> g;
[1,100000][2,4][3,5]
gap> NaturalLeqPartialPerm(f,g);
true
gap> g:=
> PartialPerm( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 
>     20, 21, 22, 25, 26, 27, 28, 29, 31, 32, 34, 35, 37, 40, 43, 44, 46, 48, 
>     50, 51, 52, 54, 55, 56, 57, 59, 60, 61, 63, 64, 65, 66, 67, 69, 71, 76, 
>     78, 79, 80, 81, 83, 85, 86, 88, 89, 90, 92, 93, 95, 96, 97, 99 ], 
>  [ 12, 67, 52, 69, 96, 43, 38, 58, 72, 99, 87, 33, 22, 7, 35, 89, 15, 42, 77, 
>     3, 70, 39, 34, 25, 81, 83, 88, 30, 97, 64, 36, 17, 14, 26, 51, 55, 11, 
>     10, 1, 59, 75, 71, 93, 44, 74, 4, 5, 63, 31, 32, 85, 53, 66, 94, 46, 27, 
>     68, 100, 86, 8, 90, 65, 47, 48, 45, 29, 57, 82, 92, 24 ] );;
gap> NaturalLeqPartialPerm(f,g);   
false
gap> f:=PartialPermNC([100000]);;   
gap> g:=PartialPermNC([1,2,3], [100000,4,5]);;;
gap> NaturalLeqPartialPerm(f,g);
true
gap> g:=
> PartialPerm( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17, 18, 19, 
>     21, 22, 24, 25, 26, 27, 28, 29, 31, 34, 36, 37, 38, 39, 41, 44, 46, 47, 
>     48, 51, 55, 56, 57, 58, 61, 62, 63, 64, 66, 67, 68, 69, 71, 72, 73, 74, 
>     75, 76, 77, 81, 82, 83, 94, 96, 98 ], 
>  [ 86243, 24019, 92473, 44160, 93892, 22630, 39783, 61399, 99288, 31825, 
>     60250, 46007, 6674, 24575, 47097, 15055, 21177, 64280, 53747, 63362, 
>     9651, 76666, 33684, 42123, 38956, 87858, 92587, 4775, 38450, 95306, 
>     48164, 84693, 59170, 65070, 24314, 31294, 54766, 39401, 76714, 86853, 
>     80503, 6128, 29087, 32355, 40641, 62259, 86547, 68053, 36450, 15562, 
>     44576, 37896, 62646, 55753, 21232, 56275, 32817, 52357, 64985, 82822, 
>     78412, 65577, 68433 ] );;
gap> NaturalLeqPartialPerm(f,g);    
false
gap> f:=PartialPermNC([1],[100000])*PartialPermNC([1,100000], [100000,2]);
[1,2]
gap> IsPPerm4Rep(f);
true
gap> g:=PartialPermNC([1,2],[2,3]);            
[1,2,3]
gap> f:=PartialPermNC([100000])*PartialPermNC([1,100000], [100000,2]);;     
gap> IsPPerm4Rep(f);
true
gap> NaturalLeqPartialPerm(f,g);
true
gap> g:=PartialPerm( [ 1, 3 ], [ 3, 1 ] );;     
gap> NaturalLeqPartialPerm(f,g);
false

# AsPartialPerm
gap> p:=(1,2,7,5)(3,9)(6,10,8);;
gap> f:=AsPartialPerm(p);       
(1,2,7,5)(3,9)(4)(6,10,8)
gap> f:=AsPartialPerm(p,11);
(1,2,7,5)(3,9)(4)(6,10,8)(11)
gap> f:=AsPartialPerm(p,12);
(1,2,7,5)(3,9)(4)(6,10,8)(11)(12)
gap> f:=AsPartialPerm(p,70000);
<partial perm on 70000 pts with degree 70000, codegree 70000>
gap> OnTuples([1..10], f)=OnTuples([1..10], p);
true
gap> f:=AsPartialPerm(p,[1,3,6]);
[1,2][3,9][6,10]
gap> f:=AsPartialPerm(p,[1,3,6,11]);
[1,2][3,9][6,10](11)
gap> f:=AsPartialPerm(p,[1,3,6,70000]);
[1,2][3,9][6,10](70000)
gap> p:=(1,100000);;
gap> f:=AsPartialPerm(p,100001);
<partial perm on 100001 pts with degree 100001, codegree 100001>
gap> OnTuples([1,100000, 100001], f);
[ 100000, 1, 100001 ]
gap> f:=AsPartialPerm(p,10);     
[1,100000](2)(3)(4)(5)(6)(7)(8)(9)(10)
gap> IsPPerm4Rep(f);
true
gap> p:=(1,19)(10,100000);;
gap> AsPartialPerm(p,9); 
[1,19](2)(3)(4)(5)(6)(7)(8)(9)
gap> p:=(1,9)(10,100000);;
gap> AsPartialPerm(p,9);
(1,9)(2)(3)(4)(5)(6)(7)(8)

# JoinOfPartialPerms
gap> f:=PartialPermNC([1],[2]);;
gap> g:=PartialPermNC([1,2,3],[2,4,1]);;
gap> JoinOfPartialPerms(f, g);
[3,1,2,4]
gap> f:=PartialPermNC([1],[2]);
[1,2]
gap> g:=PartialPermNC([2],[3]);    
[2,3]
gap> JoinOfPartialPerms(f, g);
[1,2,3]
gap> g:=PartialPermNC([2],[1]);
[2,1]
gap> JoinOfPartialPerms(f, g);
(1,2)
gap> g:=PartialPermNC([1],[3]);
[1,3]
gap> JoinOfPartialPerms(f, g);
fail
gap> f:=PartialPermNC([2]);;
gap> g:=PartialPermNC([3]);;
gap> JoinOfPartialPerms(f, g);
fail
gap> f:=PartialPermNC([2]);;
gap> g:=PartialPermNC([0,3]);;
gap> JoinOfPartialPerms(f, g);
[1,2,3]
gap> f:=PartialPermNC([2]); 
[1,2]
gap> g:=PartialPermNC([0,3]);;
gap> JoinOfPartialPerms(f, g);
[1,2,3]
gap> f:=PartialPermNC([2]);;
gap> g:=PartialPermNC([0,3]); 
[2,3]
gap> JoinOfPartialPerms(f, g);
[1,2,3]
gap> f:=PartialPermNC([2]);;
gap> f:=PartialPermNC([2]); 
[1,2]
gap> g:=PartialPermNC([0,100000]);
[2,100000]
gap> JoinOfPartialPerms(f,g);
[1,2,100000]
gap> JoinOfPartialPerms(last, PartialPermNC([100000],[1]));
(1,2,100000)
gap> g:=PartialPermNC([0,100000]);;
gap> JoinOfPartialPerms(f,g);                              
[1,2,100000]
gap> f:=PartialPermNC([2]);;
gap> g:=PartialPermNC([0,100000]); 
[2,100000]
gap> JoinOfPartialPerms(f,g);
[1,2,100000]
gap> f:=PartialPermNC([2]);;
gap> g:=PartialPermNC([0,100000]);;
gap> JoinOfPartialPerms(f,g);
[1,2,100000]
gap> last^2;
[1,100000]
gap> f:=PartialPermNC([2]);;
gap> f:=PartialPermNC([0,100000]);;
gap> g:=PartialPermNC([2]);;       
gap> JoinOfPartialPerms(f,g);
[1,2,100000]
gap> f:=PartialPermNC([0,100000]);;
gap> g:=PartialPermNC([0,100000,4]);;
gap> JoinOfPartialPerms(f,g);
[2,100000][3,4]
gap> g:=PartialPermNC([0,0,4]);;     
gap> JoinOfPartialPerms(f,g);
[2,100000][3,4]
gap> g:=PartialPermNC([0,0,4]); 
[3,4]
gap> JoinOfPartialPerms(f,g);
[2,100000][3,4]
gap> f:=PartialPermNC([0,100000]); 
[2,100000]
gap> JoinOfPartialPerms(f,g);
[2,100000][3,4]
gap> g:=PartialPermNC([0,0,4]);;
gap> JoinOfPartialPerms(f,g);
[2,100000][3,4]
gap> f:=PartialPermNC( [ 1, 2, 4, 5, 6, 7 ], [ 5, 100000, 7, 3, 1, 4 ] )*
> PartialPermNC([1..99999]);
[6,1,5,3](4,7)
gap> IsPPerm4Rep(f);
true
gap> g:=PartialPermNC([8,100000],[100000,1]);
[8,100000,1]
gap> JoinOfPartialPerms(f, g);
fail
gap> g:=PartialPermNC([8],[100000]);         
[8,100000]
gap> JoinOfPartialPerms(f, g);
[6,1,5,3][8,100000](4,7)

# MeetOfPartialPerms
gap> f:=PartialPermNC([2]);;
gap> g:=PartialPermNC([3]);;
gap> MeetOfPartialPerms(f,g);
<empty partial perm>
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 8, 10 ], [ 7, 1, 4, 3, 2, 6, 5 ] );;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 5, 8, 10 ], [ 3, 1, 4, 2, 5, 6, 7 ] );;
gap> MeetOfPartialPerms(f,g);
[2,1][3,4][8,6]
gap> f:=RandomPartialPerm(1000);;
gap> g:=JoinOfPartialPerms(f, PartialPermNC([1001..2000], [1001..2000]));;
gap> f=MeetOfPartialPerms(f, g);
true
gap> g:=JoinOfPartialPerms(f, PartialPermNC([1001..100000], [1001..100000]));;
gap> f=MeetOfPartialPerms(f, g);
true
gap> g:=RandomPartialPerm(1000);;
gap> f:=JoinOfPartialPerms(g, PartialPermNC([1001..100000], [1001..100000]));;
gap> g=MeetOfPartialPerms(f, g);
true
gap> f:=PartialPermNC([100000,2,3,4,5]); 
[1,100000](2)(3)(4)(5)
gap> g:=PartialPermNC([100001,2,3,4,5]);                                       
[1,100001](2)(3)(4)(5)
gap> MeetOfPartialPerms(f,g);
<identity partial perm on [ 2, 3, 4, 5 ]>
gap> MeetOfPartialPerms(PartialPerm([1]));
<identity partial perm on [ 1 ]>
gap> MeetOfPartialPerms(PartialPerm([1]), PartialPerm([2]));
<empty partial perm>
gap> MeetOfPartialPerms(PartialPerm([1]), PartialPerm([1, 2]));
<identity partial perm on [ 1 ]>
gap> MeetOfPartialPerms([]);
Error, usage: the argument should be a collection of partial perms, 
gap> MeetOfPartialPerms([PartialPerm([1]), PartialPerm([1, 2])]);
<identity partial perm on [ 1 ]>
gap> MeetOfPartialPerms(SymmetricInverseMonoid(3));
<empty partial perm>

# RestrictedPartialPerm
gap> f:=PartialPermNC([100000,2,3,4,5]);
[1,100000](2)(3)(4)(5)
gap> RestrictedPartialPerm(f, [2..5]);
<identity partial perm on [ 2, 3, 4, 5 ]>
gap> g:=last;
<identity partial perm on [ 2, 3, 4, 5 ]>
gap> DegreeOfPartialPerm(g);
5
gap> g:=RestrictedPartialPerm(f, [100000]);
<empty partial perm>
gap> g:=RestrictedPartialPerm(f, [1]);
[1,100000]
gap> f:=PartialPermNC([10,2,3,4,5]);    
[1,10](2)(3)(4)(5)
gap> RestrictedPartialPerm(f, [2..5]);
<identity partial perm on [ 2, 3, 4, 5 ]>
gap> g:=RestrictedPartialPerm(f, [1]);
[1,10]
gap> g:=RestrictedPartialPerm(f, [100]);
<empty partial perm>
gap> g:=RestrictedPartialPerm(f, [10]); 
<empty partial perm>
gap> g:=RestrictedPartialPerm(f, [5]); 
<identity partial perm on [ 5 ]>

# AsPermutation
gap> f:=PartialPermNC([10,2,3,4,5]);      
[1,10](2)(3)(4)(5)
gap> AsPermutation(f);
fail
gap> f:=RestrictedPartialPerm(f, [2..10]);
<identity partial perm on [ 2, 3, 4, 5 ]>
gap> AsPermutation(f);
()
gap> f:=RandomPartialPerm(1000);;
gap> x:=IndexPeriodOfPartialPerm(f);;
gap> g:=f^x[1];;
gap> OnTuples(DomainOfPartialPerm(g),AsPermutation(g))=
> OnTuples(DomainOfPartialPerm(g), g);
true
gap> f:=RandomPartialPerm(100000);;
gap> x:=IndexPeriodOfPartialPerm(f);;
gap> g:=f^x[1];;
gap> OnTuples(DomainOfPartialPerm(g),AsPermutation(g))=
> OnTuples(DomainOfPartialPerm(g), g);
true
gap> AsPermutation(f);
fail

# PermLeftQuoPartialPerm
gap> f:=RandomPartialPerm(100);;
gap> p:=Random(SymmetricGroup(ImageSetOfPartialPerm(f)));;
gap> g:=f*p;;
gap> PermLeftQuoPartialPerm(f, g)=p;
true
gap> h:=RandomPartialPerm([101..100000]);;
gap> h:=JoinOfPartialPerms(h, PartialPermNC([1..100], [1..100]));;
gap> g=g*h;
true
gap> g:=g*h;;
gap> IsPPerm4Rep(g);
true
gap> p=PermLeftQuoPartialPerm(f, g);
true
gap> f:=
> PartialPerm(
>  [ 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 23, 
>     24, 25, 26, 28, 29, 30, 31, 32, 33, 34, 36, 37, 38, 39, 40, 41, 43, 46, 
>     48, 50, 51, 56, 57, 59, 63, 66, 68, 70, 71, 74, 76, 77, 78, 79, 83, 84, 
>     85, 87, 90, 92, 94, 97, 100 ], 
>  [ 81741, 47535, 89543, 7647, 6928, 97188, 75189, 75720, 16656, 19809, 59830, 
>     16417, 72882, 82179, 79601, 83154, 17509, 84845, 47064, 83836, 71322, 
>     16135, 20341, 76275, 83899, 31052, 74445, 62658, 89822, 77308, 51562, 
>     39893, 31166, 28666, 71421, 60942, 85356, 37758, 73004, 85900, 7741, 
>     60975, 67112, 21368, 84588, 64899, 13092, 33817, 85063, 22848, 98767, 
>     36015, 82759, 4951, 10858, 31285, 49208, 60946, 33562, 4467, 52041, 
>     75960, 83945 ] );;
gap> PermLeftQuoPartialPerm(f, f);
()
gap> IsPerm4Rep(last);
true
gap> PermLeftQuoPartialPerm(f, f);
()
gap> f:=PartialPermNC([1,2], [100000,100001])*
> PartialPermNC([100000, 100001, 100002], [2,1,100002]); 
(1,2)
gap> g:=PartialPermNC([1,2]);     
<identity partial perm on [ 1, 2 ]>
gap> IsPPerm2Rep(g);
true
gap> IsPPerm4Rep(f);
true
gap> PermLeftQuoPartialPerm(f, g);
(1,2)
gap> PermLeftQuoPartialPerm(g, f);
(1,2)

# Kernel level functions
#
# OnePPerm
gap> f:=RandomPartialPerm(100000);;
gap> e:=One(f);;
gap> e*f=f;
true
gap> f*e=f;
true
gap> Union(DomainOfPartialPerm(f), ImageSetOfPartialPerm(f))=
> DomainOfPartialPerm(e);
true
gap> Union(DomainOfPartialPerm(f), ImageSetOfPartialPerm(f))=
> ImageSetOfPartialPerm(e);
true
gap> f:=RandomPartialPerm(10000);;
gap> e:=One(f);;
gap> e*f=f;    
true
gap> f*e=f;
true
gap> Union(DomainOfPartialPerm(f), ImageSetOfPartialPerm(f))=      
> DomainOfPartialPerm(e);
true
gap> Union(DomainOfPartialPerm(f), ImageSetOfPartialPerm(f))=
> ImageSetOfPartialPerm(e);
true
gap> f:=PartialPermNC([1,2], [100000,100001])*                                 
> PartialPermNC([100000, 100001, 100002], [2,1,100002]);
(1,2)
gap> One(f);
<identity partial perm on [ 1, 2 ]>
gap> IsPPerm2Rep(last);
true
gap> IsPPerm4Rep(f);
true

# EqPPerm24 and EqPPerm42
gap> f:=PartialPermNC([1..100], [2..101]);
<partial perm on 100 pts with degree 100, codegree 101>
gap> p:=(1,100000);
(1,100000)
gap> IsPPerm2Rep(f); 
true
gap> IsPPerm4Rep(f*p);
true
gap> f*p=f;
true
gap> f=f*p;
true

# ProdPPerm2Perm2, Case 1 of 6: codeg(f)<=deg(p), domain known
gap> f:=RandomPartialPerm(10);; DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(100));;
gap> g:=f*p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# QuoPPerm2Perm2, Case 1 of 6: codeg(f)<=deg(p), domain known
gap> f:=RandomPartialPerm(10);; DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(100));;
gap> g:=f/p;;
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true

# ProdPPerm2Perm2, Case 2 of 6: codeg(f)<=deg(p), domain not known
gap> f:=RandomPartialPerm(10);;
gap> p:=Random(SymmetricGroup(100));;
gap> g:=f*p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> f:=RandomPartialPerm(10);;
gap> p:=Random(SymmetricGroup(100));;
gap> g:=f*p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# QuoPPerm2Perm2, Case 2 of 6: codeg(f)<=deg(p), domain not known
gap> f:=RandomPartialPerm(10);;
gap> p:=Random(SymmetricGroup(100));;
gap> g:=f/p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> f/p=f*p^-1;
true
gap> f:=RandomPartialPerm(10);;
gap> p:=Random(SymmetricGroup(100));;
gap> g:=f/p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true

# ProdPPerm2Perm2, Case 3 of 6: codeg(f)>deg(p), domain known
gap> f:=RandomPartialPerm(100);; DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(10));;
gap> g:=f*p;;
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f:=RandomPartialPerm(65535);;
gap> p:=Random(SymmetricGroup(10000));;
gap> g:=f*p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# QuoPPerm2Perm2, Case 3 of 6: codeg(f)>deg(p), domain known
gap> f:=RandomPartialPerm(100);; DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(10));;
gap> g:=f/p;;
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true
gap> f:=RandomPartialPerm(65535);;
gap> p:=Random(SymmetricGroup(10000));;
gap> g:=f/p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true

# ProdPPerm2Perm2, Case 4 of 6: codeg(f)>deg(p), domain not known
gap> f:=RandomPartialPerm(100);;
gap> p:=Random(SymmetricGroup(10));;   
gap> g:=f*p;;                       
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f:=RandomPartialPerm(10000);;
gap> p:=Random(SymmetricGroup(1000));; 
gap> g:=f*p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# QuoPPerm2Perm2, Case 4 of 6: codeg(f)>deg(p), domain not known
gap> f:=RandomPartialPerm(100);;
gap> p:=Random(SymmetricGroup(10));;   
gap> g:=f/p;;                       
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true
gap> f:=RandomPartialPerm(10000);;
gap> p:=Random(SymmetricGroup(1000));; 
gap> g:=f/p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true

# ProdPPerm2Perm2, Case 5 of 6: deg(p)=65536, domain not known
gap> p:=(1,65536);;
gap> f:=RandomPartialPerm(10000);;
gap> g:=f*p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# QuoPPerm2Perm2, Case 5 of 6: deg(p)=65536, domain not known
gap> p:=(1,65536,123);;
gap> f:=RandomPartialPerm(10000);;
gap> g:=f/p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true

# ProdPPerm2Perm2, Case 6 of 6: deg(p)=65536, domain known
gap> f:=RandomPartialPerm(10000);; DomainOfPartialPerm(f);;
gap> p:=(1,65536);;
gap> g:=f*p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# QuoPPerm2Perm2, Case 6 of 6: deg(p)=65536, domain known
gap> f:=RandomPartialPerm(10000);; DomainOfPartialPerm(f);;
gap> p:=(1,65536,123);;
gap> g:=f/p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true

# ProdPPerm2Perm4, Case 1 of 2: domain known
gap> f:=RandomPartialPerm(10);; DomainOfPartialPerm(f);;
gap> p:=(1,100000);;
gap> g:=f*p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# QuoPPerm2Perm4, Case 1 of 2: domain known
gap> f:=RandomPartialPerm(10);; DomainOfPartialPerm(f);;
gap> p:=(1,100000,123);;
gap> g:=f/p;;
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> f/p=f*p^-1;
true

# ProdPPerm2Perm4, Case 2 of 2: domain not known
gap> f:=RandomPartialPerm(1000);;
gap> p:=(1,100000);;
gap> g:=f*p;;
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true

# QuoPPerm2Perm4, Case 2 of 2: domain not known
gap> f:=RandomPartialPerm(1000);;
gap> p:=(1,100000,123);;
gap> g:=f/p;;
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> f/p=f*p^-1;
true

# ProdPPerm4Perm4, Case 1 of 4: deg(p)>codeg(f) domain not known
gap> p:=(1,100000);;
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,70000]));;
gap> g:=f*p;                  
[65536,100000][65537,70000]
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true

# QuoPPerm4Perm4, Case 1 of 4: deg(p)>codeg(f) domain not known
gap> p:=(1,100000,123);;
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,70000]));;
gap> g:=f/p;                  
[65536,123][65537,70000]
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> f/p=f*p^-1;
true

# ProdPPerm4Perm4, Case 2 of 4: deg(p)>codeg(f) domain known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,70000]));
[65536,1][65537,70000]
gap> p:=(1,100000);;
gap> g:=f*p;
[65536,100000][65537,70000]
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true

# QuoPPerm4Perm4, Case 2 of 4: deg(p)>codeg(f) domain known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,70000]));
[65536,1][65537,70000]
gap> p:=(1,100000,123);;
gap> g:=f/p;
[65536,123][65537,70000]
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> f/p=f*p^-1;
true

# ProdPPerm4Perm4, Case 3 of 4: deg(p)<=codeg(f) domain not known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001]));;
gap> p:=(1,100000);;
gap> g:=f*p;
[65536,100000][65537,100001]
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true

# QuoPPerm4Perm4, Case 3 of 4: deg(p)<=codeg(f) domain not known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001]));;
gap> p:=(1,100000,123);;
gap> g:=f/p;
[65536,123][65537,100001]
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> f/p=f*p^-1;
true

# ProdPPerm4Perm4, Case 4 of 4: deg(p)<=codeg(f) domain known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001]));
[65536,1][65537,100001]
gap> p:=(1,100000);;
gap> g:=f*p;
[65536,100000][65537,100001]
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);  
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true

# QuoPPerm4Perm4, Case 4 of 4: deg(p)<=codeg(f) domain known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001]));
[65536,1][65537,100001]
gap> p:=(1,100000,123);;
gap> g:=f/p;
[65536,123][65537,100001]
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);  
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> f/p=f*p^-1;
true

# ProdPPerm4Perm2, Case 1 of 2: domain not known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001]));;
gap> p:=(1,2);;
gap> g:=f*p;
[65536,2][65537,100001]
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);  
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true

# QuoPPerm4Perm2, Case 1 of 2: domain not known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001]));;
gap> p:=(1,2,4);;
gap> g:=f/p;
[65536,4][65537,100001]
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);  
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> f/p=f*p^-1;
true

# ProdPPerm4Perm2, Case 2 of 2: domain known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001])); 
[65536,1][65537,100001]
gap> p:=(1,2);;
gap> g:=f*p;
[65536,2][65537,100001]
gap> OnTuples(ImageListOfPartialPerm(f), p)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true

# QuoPPerm4Perm2, Case 2 of 2: domain known
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001])); 
[65536,1][65537,100001]
gap> p:=(1,2,4);;
gap> g:=f/p;
[65536,4][65537,100001]
gap> OnTuples(ImageListOfPartialPerm(f), p^-1)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> DomainOfPartialPerm(g)=DomainOfPartialPerm(f);
true
gap> f/p=f*p^-1;
true

# ProdPerm2PPerm2, Case 1 of 2: deg(p)<=deg(f)
gap> f:=PartialPermNC([ 1, 2, 3, 6, 8, 10 ], [ 2, 6, 7, 9, 1, 5 ]);;
gap> p:=(1,2,5,3);;
gap> g:=p*f;                                                          
[3,2][8,1,6,9][10,5,7]
gap> OnSets(DomainOfPartialPerm(f), p^-1)=DomainOfPartialPerm(g);
true
gap> OnTuples(OnTuples(DomainOfPartialPerm(g), p), f)=
> ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> ImageSetOfPartialPerm(f)=ImageSetOfPartialPerm(g);
true
gap> f:=RandomPartialPerm(10000);;
gap> p:=Random(SymmetricGroup(9000));;
gap> g:=p*f;;
gap> OnSets(DomainOfPartialPerm(f), p^-1)=DomainOfPartialPerm(g);
true
gap> OnTuples(OnTuples(DomainOfPartialPerm(g), p), f)=
> ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> ImageSetOfPartialPerm(f)=ImageSetOfPartialPerm(g);
true
gap> f:=PartialPermNC( [ 1, 2, 3, 6, 100000 ], [ 2, 6, 7, 1, 5 ] );;
gap> p:=(1,3)(2,9,7,8,6,10,5,4);;
gap> p*f;
[3,2][4,6][8,1,7][100000,5]

# ProdPerm2PPerm2, Case 2 of 2: deg(p)>deg(f)
gap> f:=PartialPermNC([ 1, 2, 3, 6, 8, 10 ], [ 2, 6, 7, 9, 1, 5 ]);;
gap> p:=(1,5,12,8)(2,16,10,15,13,7)(3,4,20,14,6,19,9,18,11,17);;
gap> g:=p*f;
[8,2][12,1][14,9][16,5][17,7,6]
gap> OnSets(DomainOfPartialPerm(f), p^-1);
[ 7, 8, 12, 14, 16, 17 ]
gap> OnTuples(OnTuples(last, p), f)=ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> ImageSetOfPartialPerm(f)=ImageSetOfPartialPerm(g);
true
gap> f:=RandomPartialPerm(1000);;
gap> p:=Random(SymmetricGroup(2000));;
gap> g:=p*f;;
gap> OnSets(DomainOfPartialPerm(f), p^-1)=DomainOfPartialPerm(g);
true
gap> OnTuples(OnTuples(DomainOfPartialPerm(g), p), f)=
> ImageListOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true
gap> ImageSetOfPartialPerm(f)=ImageSetOfPartialPerm(g);          
true

# ProdPerm4PPerm4, Case 1 of 2: deg(p)<=deg(f)
gap> f:=PartialPermNC(Concatenation(List([1..65535], x-> 0), [1,100001]));
[65536,1][65537,100001]
gap> p:=(1,65537);; 
gap> g:=p*f;
[65536,1,100001]
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# ProdPerm4PPerm4, Case 2 of 2: deg(p)>deg(f)
gap> f:=PartialPermNC([1,65536], [1,65536]);;
gap> p:=(1,100000);;
gap> g:=p*f;
[100000,1](65536)
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# ProdPerm4PPerm2, Case 1 of 2: deg(p)<=deg(f)
gap> p:=(1,100000);;
gap> f:=PartialPermNC([ 1, 2, 3, 6, 8, 10 ], [ 2, 6, 7, 9, 1, 5 ]);;
gap> g:=p*f;
[3,7][8,1][10,5][100000,2,6,9]
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# ProdPerm4PPerm2, Case 2 of 2: deg(p)>deg(f)
gap> f:=PartialPermNC([65537],[1]);;
gap> IsPPerm2Rep(f);
true
gap> p:=(65537, 65538);;
gap> g:=p*f;
[65538,1]
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# ProdPerm2PPerm4, Case 1 of 2: deg(p)<=deg(f)
gap> p:=(1,10000);;
gap> f:=PartialPermNC([ 10000 ], [ 70000 ] );;
gap> g:=p*f;
[1,70000]
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# ProdPerm2PPerm4, Case 2 of 2: deg(p)>deg(f)
gap> f:=PartialPermNC([ 1 ], [ 70000 ] );;    
gap> p:=(1,10000);;
gap> g:=p*f;
[10000,70000]
gap> CodegreeOfPartialPerm(g)=Maximum(ImageSetOfPartialPerm(g));
true

# InvPPerm2, Case 1 of 4, deg>65535 and domain not known
gap> f:=PartialPerm([100000],[1])*PartialPermNC([1]);;
gap> f^-1;
[1,100000]
gap> f*f^-1=LeftOne(f);
true
gap> f^-1*f=RightOne(f);
true

# InvPPerm2, Case 2 of 4, deg>65535 and domain known
gap> f:=PartialPerm([100000], [1]);
[100000,1]
gap> f^-1;
[1,100000]
gap> f*f^-1=LeftOne(f);
true
gap> f^-1*f=RightOne(f);
true

# InvPPerm2, Case 3 of 4, deg<65536 and domain not known
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 16, 17, 18, 19 ], 
> [ 3, 12, 14, 4, 11, 18, 17, 2, 9, 5, 15, 8, 20, 10, 19 ] );;
gap> f:=f*RightOne(f);;
gap> f^-1;
[9,10,18,6][14,3,1][15,12,2,8,16][20,17,7](4)(5,11)(19)
gap> f*f^-1=LeftOne(f);
true
gap> f^-1*f=RightOne(f);
true

# InvPPerm2, Case 4 of 4, deg<65536 and domain known
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 14, 16, 18, 19, 20 ], 
> [ 13, 1, 8, 5, 4, 14, 11, 12, 9, 20, 2, 18, 7, 3, 19 ] );;
gap> f^-1;
[7,18,16][11,8,3,19,20,12,9,10][13,1,2,14,6](4,5)
gap> f*f^-1=LeftOne(f);
true
gap> f^-1*f=RightOne(f);
true

# InvPPerm4, Case 1 of 4, deg>65535 and domain not known
gap> f:=PartialPerm([100000],[100001]);;
gap> f:=f*RightOne(f);;
gap> f^-1;
[100001,100000]
gap> f*f^-1=LeftOne(f);
true
gap> f^-1*f=RightOne(f);
true

# InvPPerm4, Case 2 of 4, deg>65535 and domain known
gap> f:=PartialPerm([100000],[100001]);
[100000,100001]
gap> f^-1;
[100001,100000]
gap> f*f^-1=LeftOne(f);
true
gap> f^-1*f=RightOne(f);
true

# InvPPerm4, Case 3 of 4, deg<65536 and domain not known
gap> f:=PartialPerm([1],[100001]);;
gap> f:=f*RightOne(f);;
gap> f^-1;
[100001,1]
gap> f*f^-1=LeftOne(f);
true
gap> f^-1*f=RightOne(f);
true

# InvPPerm4, Case 4 of 4, deg<65536 and domain known
gap> f:=PartialPerm([1],[100001]);;
gap> f^-1;
[100001,1]
gap> f*f^-1=LeftOne(f);
true
gap> f^-1*f=RightOne(f);
true

# PowPPerm2Perm2, Case 1 of 4, deg(f)>deg(p) and codeg(f)>deg(p)
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 16, 17, 18, 19 ], 
> [ 3, 12, 14, 4, 11, 18, 17, 2, 9, 5, 15, 8, 20, 10, 19 ] );;
gap> p:=(1,7,10,4,9,8)(3,6,5);;
gap> f^p;
[5,18,4,8][7,6,14][10,17,20][16,1,2,12,15](3,11)(9)(19)
gap> p^-1*f*p;                     
[5,18,4,8][7,6,14][10,17,20][16,1,2,12,15](3,11)(9)(19)
gap> f^p=p^-1*f*p;
true

# PowPPerm2Perm2, Case 2 of 4, deg(f)>deg(p) and codeg(f)<=deg(p)
gap> f:=PartialPermNC( [ 11, 12, 13, 14, 15, 18, 19, 20 ], 
> [ 4, 2, 10, 5, 9, 6, 3, 8 ] );;
gap> CodegreeOfPartialPerm(f);
10
gap> DegreeOfPartialPerm(f);
20
gap> p:=(1,4,8,3,2,7,6,10,9,5);;
gap> f^p;
[11,8][12,7][13,9][14,1][15,5][18,10][19,2][20,3]
gap> p^-1*f*p;
[11,8][12,7][13,9][14,1][15,5][18,10][19,2][20,3]

# PowPPerm2Perm2, Case 3 of 4, deg(f)<=deg(p) and codeg(f)>deg(p)
gap> f:=f^-1;;
gap> DegreeOfPartialPerm(f);
10
gap> CodegreeOfPartialPerm(f);     
20
gap> p:=(1,7,4,8)(2,6,5)(9,10);;
gap> f^p;
[1,20][2,14][3,19][5,18][6,12][8,11][9,13][10,15]
gap> p^-1*f*p;                     
[1,20][2,14][3,19][5,18][6,12][8,11][9,13][10,15]

# PowPPerm2Perm2, Case 4 of 4, deg(f)<=deg(p) and codeg(f)<=deg(p)
gap> f:=PartialPermNC( 
> [ 1, 2, 3, 5, 7, 9, 10, 12, 13, 14, 16, 17, 19, 20, 21, 22, 
>   23, 26, 27, 28, 29, 30, 31, 32, 35, 36, 39, 40, 41, 43, 47, 48, 49 ], 
> [ 5, 4, 45, 24, 43, 28, 21, 31, 13, 49, 20, 46, 11, 17, 29, 22, 7, 27, 32, 
>   30, 42, 6, 44, 39, 15, 16, 34, 37, 1, 12, 40, 47, 8 ] );;
gap> p:=(1,76,65,52,5,59,75,64,37,12,78,41,57,48,94,32,9,3,99,17,89)
> (2,35,33,63,43,28,
> 22,15,100,66,45,4,80,58,51,67,55,24,56,86,49,38,42,93,88,18,77,62,79,19,92,50,
> 83,91,44,95,14,72,60,85,34)(6,16,31,11,97,46,47,73,7,39,27,70,61,71,74,10,
> 96,98,87,53,81)(8,54,20,36,23,26,40,68,25,90,13,30,84,29,21,69,82);;
gap> DegreeOfPartialPerm(f);
49
gap> CodegreeOfPartialPerm(f);
49
gap> f^p;
[3,22,84,16][23,31,36,89,47][26,39,28,78,11,95][33,100][35,80][40,70,9,27,2]
[57,76,59,56][72,38,54][92,97][94,73,68,12][96,69,21,93][99,4](15)(30)
gap> p^-1*f*p;                      
[3,22,84,16][23,31,36,89,47][26,39,28,78,11,95][33,100][35,80][40,70,9,27,2]
[57,76,59,56][72,38,54][92,97][94,73,68,12][96,69,21,93][99,4](15)(30)
gap> f^p=p^-1*f*p;
true

# PowPPerm2Perm4, Case 1 of 2, deg(f)>deg(p) and codeg(f)<=deg(p)
gap> f:=PartialPermNC([100000], [1]);
[100000,1]
gap> IsPPerm2Rep(f);
true
gap> p:=Random(SymmetricGroup(100000));;
gap> f^p=p^-1*f*p;
true

# PowPPerm2Perm4, Case 2 of 2, deg(f)<=deg(p) and codeg(f)<=deg(p)
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 6 ], [ 2, 5, 8, 1, 3, 4 ] );;
gap> p:=Random(SymmetricGroup(100000));;
gap> f^p=p^-1*f*p;               
true

# PowPPerm4Perm2, Case 1 of 4, deg(f)>deg(p) and codeg(f)>deg(p)
gap> f:=PartialPermNC([100000], [100000]);
<identity partial perm on [ 100000 ]>
gap> p:=(1,3,2,10)(5,7)(6,9,8);;
gap> f^p;
<identity partial perm on [ 100000 ]>
gap> f:=RandomPartialPerm(100000);;        
gap> p:=Random(SymmetricGroup(50000));;
gap> f^p=p^-1*f*p;
true

# PowPPerm4Perm2, Case 2 of 4, deg(f)>deg(p) and codeg(f)<=deg(p)
gap> f:=PartialPermNC([100000], [1]);     
[100000,1]
gap> p:=Random(SymmetricGroup(10));;   
gap> p:=(1,10)(3,8)(4,7,5,9);;
gap> f^p;
[100000,10]
gap> p^-1*f*p;
[100000,10]
gap> f:=PartialPermNC( [ 1, 2, 4, 5, 6, 7 ], [ 5, 100000, 7, 3, 1, 4 ] );;
gap> f:=f*PartialPermNC([1..99999]);                                        
[6,1,5,3](4,7)
gap> IsPPerm4Rep(f);
true
gap> f:=JoinOfPartialPerms(f, PartialPermNC([100000],[8]));
[6,1,5,3][100000,8](4,7)
gap> IsPPerm4Rep(f);
true
gap> p:=(1,10,4,5,3,8,2,6,7,9);;
gap> f^p;
[7,10,3,8][100000,2](5,9)
gap> p^-1*f*p;
[7,10,3,8][100000,2](5,9)

# PowPPerm4Perm2, Case 3 of 4, deg(f)<=deg(p) and codeg(f)>deg(p)
gap> p:=(1,6,7,9,4,3,10,2,5,8);;
gap> f:=PartialPermNC( [ 1 ], [100000] );;
gap> IsPPerm4Rep(f);
true
gap> f^p;
[6,100000]
gap> p^-1*f*p;
[6,100000]

# PowPPerm4Perm2, Case 4 of 4, deg(f)<=deg(p) and codeg(f)<=deg(p)
gap> f:=PartialPermNC( [ 1, 2, 4, 5, 6, 7 ], [ 5, 100000, 7, 3, 1, 4 ] );;
gap> f:=f*PartialPermNC([1..99999]);
[6,1,5,3](4,7)
gap> IsPPerm4Rep(f);
true
gap> p:=(1,3,5,4,6)(7,10,8,9);;
gap> f^p;
[1,3,4,5](6,10)
gap> p^-1*f*p;
[1,3,4,5](6,10)

# PowPPerm4Perm4, Case 1 of 4, deg(f)>deg(p) and codeg(f)>deg(p)
gap> f:=RandomPartialPerm(100000);; 
gap> p:=Random(SymmetricGroup(65538));;
gap> IsPPerm4Rep(f); IsPerm4Rep(p);
true
true
gap> f^p=p^-1*f*p;
true

# PowPPerm4Perm4, Case 2 of 4, deg(f)>deg(p) and codeg(f)<=deg(p)
gap> f:=PartialPermNC([100000], [65536]);;
gap> p:=Random(SymmetricGroup(70000));;
gap> f^p=p^-1*f*p;
true

# PowPPerm4Perm4, Case 3 of 4, deg(f)<=deg(p) and codeg(f)>deg(p)
gap> f:=f^-1;
[65536,100000]
gap> f^p=p^-1*f*p;
true

# PowPPerm4Perm4, Case 4 of 4, deg(f)<=deg(p) and codeg(f)<=deg(p)
gap> f:=RandomPartialPerm(66000);; 
gap> p:=Random(SymmetricGroup(70000));;
gap> f^p=p^-1*f*p;
true

# QuoPPerm22, Case 1 of 4, dom(g) known,   dom(f) known
gap> f:=PartialPermNC( [ 1, 2, 4, 5, 6, 9, 10 ], [ 8, 7, 9, 5, 10, 6, 1 ] );;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 9, 10 ], 
> [ 5, 9, 7, 4, 2, 3, 6, 1 ] );
[10,1,5,2,9,6,3,7](4)
gap> f/g;
[4,2,3][5,1](9)(10)
gap> f*g^-1;
[4,2,3][5,1](9)(10)
gap> f*g^-1=f/g;
true
gap> f:=RandomPartialPerm(10000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(10000);; DomainOfPartialPerm(g);;
gap> f/g=f*g^-1;
true
gap> f:=PartialPermNC([100000], [1]);
[100000,1]
gap> f/f;
<identity partial perm on [ 100000 ]>

# QuoPPerm22, Case 2 of 4, dom(g) known,   dom(f) unknown
gap> f:=PartialPermNC([5,9,4,2,0,3,7,6,0,10]);;
gap> g:=PartialPermNC( [ 1, 2, 3, 5, 6, 7, 10 ], [ 1, 8, 10, 4, 3, 7, 2 ] );
[5,4][6,3,10,2,8](1)(7)
gap> f/g;
[4,10,3,5](6)(7)
gap> f*g^-1;
[4,10,3,5](6)(7)
gap> f/g=f*g^-1;
true
gap> f:=RandomPartialPerm(10000);;
gap> g:=RandomPartialPerm(10000);; DomainOfPartialPerm(g);;
gap> f/g=f*g^-1;
true

# QuoPPerm22, Case 3 of 4, dom(g) unknown, dom(f) known
gap> g:=PartialPermNC([5,9,4,2,0,3,7,6,0,10]);;
gap> f:=PartialPermNC( [ 1, 2, 3, 5, 6, 7, 10 ], [ 1, 8, 10, 4, 3, 7, 2 ] );
[5,4][6,3,10,2,8](1)(7)
gap> f/g;
[5,3,10,4](6)(7)
gap> f*g^-1;
[5,3,10,4](6)(7)
gap> f:=RandomPartialPerm(10000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(10000);;
gap> f/g=f*g^-1;
true

# QuoPPerm22, Case 4 of 4, dom(g) unknown, dom(f) unknown
gap> f:=PartialPermNC([ 1, 8, 10, 0, 4, 3, 7, 0, 0, 2 ]);;
gap> g:=PartialPermNC([5,9,4,2,0,3,7,6,0,10]);;
gap> f/g=f*g^-1;
true
gap> f:=RandomPartialPerm(10000);;                          
gap> g:=RandomPartialPerm(10000);;
gap> f/g=f*g^-1;
true

# QuoPPerm24, Case 1 of 4, dom(f) known,   dom(g) known
gap> f:=RandomPartialPerm(20);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(100000);; DomainOfPartialPerm(g);;
gap> f/g=f*g^-1;
true

# QuoPPerm24, Case 2 of 4, dom(f) known,   dom(g) unknown
gap> f:=RandomPartialPerm(20);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(100000);;                         
gap> f/g=f*g^-1;
true

# QuoPPerm24, Case 3 of 4, dom(f) unknown, dom(g) known
gap> f:=RandomPartialPerm(20);;                         
gap> g:=RandomPartialPerm(100000);; DomainOfPartialPerm(g);;
gap> f/g=f*g^-1;
true

# QuoPPerm24, Case 4 of 4, dom(f) unknown, dom(g) unknown
gap> f:=RandomPartialPerm(20);;                             
gap> g:=RandomPartialPerm(100000);;                         
gap> f/g=f*g^-1;
true

# QuoPPerm42, Case 1 of 4, dom(f) known,   dom(g) known
gap> f:=RandomPartialPerm(100000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(20);; DomainOfPartialPerm(g);;
gap> f/g=f*g^-1;
true

# QuoPPerm42, Case 2 of 4, dom(f) known,   dom(g) unknown
gap> f:=RandomPartialPerm(100000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(20);; 
gap> f/g=f*g^-1;
true

# QuoPPerm42, Case 3 of 4, dom(f) unknown, dom(g) known
gap> f:=RandomPartialPerm(100000);;
gap> g:=RandomPartialPerm(20);; DomainOfPartialPerm(g);;                     
gap> f/g=f*g^-1;
true

# QuoPPerm42, Case 4 of 4, dom(f) unknown, dom(g) unknown
gap> f:=RandomPartialPerm(100000);;                         
gap> g:=RandomPartialPerm(20);;                             
gap> f/g=f*g^-1;
true

# QuoPPerm44, Case 1 of 4, dom(f) known,   dom(g) known
gap> f:=RandomPartialPerm(100000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(100000);; DomainOfPartialPerm(g);;
gap> f/g=f*g^-1;
true

# QuoPPerm44, Case 2 of 4, dom(f) known,   dom(g) unknown
gap> f:=RandomPartialPerm(100000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(100000);; 
gap> f/g=f*g^-1;
true

# QuoPPerm44, Case 3 of 4, dom(f) unknown, dom(g) known
gap> f:=RandomPartialPerm(100000);;
gap> g:=RandomPartialPerm(100000);; DomainOfPartialPerm(g);;                     
gap> f/g=f*g^-1;
true

# QuoPPerm44, Case 4 of 4, dom(f) unknown, dom(g) unknown
gap> f:=RandomPartialPerm(100000);;                         
gap> g:=RandomPartialPerm(100000);;                             
gap> f/g=f*g^-1;
true

# LQuoPerm2PPerm2, Case 1 of 4, deg(p)<deg(f),  dom(f) unknown
gap> f:=PartialPermNC(
> [ 11, 12, 9, 13, 20, 0, 2, 14, 18, 0, 7, 3, 19, 0, 0, 0, 0, 0, 5, 16 ]);;
gap> p:=(1,7,10,4,9,8)(3,6,5);;
gap> LQUO(p, f);
[1,14][6,9,13,19,5][8,18][10,2,12,3,20,16](7,11)
gap> p^-1*f;
[1,14][6,9,13,19,5][8,18][10,2,12,3,20,16](7,11)
gap> last=last2;
true

# LQuoPerm2PPerm2, Case 2 of 4, deg(p)<deg(f),  dom(f) known
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 6, 8, 9, 10, 12, 13, 15, 16, 18 ], 
> [ 13, 9, 18, 1, 5, 7, 3, 10, 2, 12, 14, 11, 16 ] );;
gap> p:=(1,5,8,4,6,3)(2,9,10);;
gap> LQUO(p, f);
[4,7][6,1,18,16,11][15,14](2,10,3,5,13,12)(9)
gap> p^-1*f;
[4,7][6,1,18,16,11][15,14](2,10,3,5,13,12)(9)
gap> last=last2;
true

# LQuoPerm2PPerm2, Case 3 of 4, deg(p)>=deg(f), dom(f) unknown
gap> f:=PartialPermNC([ 7, 0, 10, 0, 4, 8, 9, 0, 0, 6 ]);;
gap> p:=(1,16,4,12,6,20,13,9,19,3,7,17,10,14,11,15,2);;
gap> LQUO(p, f);
[5,4][14,6][16,7,10][17,9][20,8]
gap> p^-1*f;
[5,4][14,6][16,7,10][17,9][20,8]
gap> last=last2;
true

# LQuoPerm2PPerm2, Case 4 of 4, deg(p)>=deg(f), dom(f) known
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 7, 10 ], 
> [ 2, 3, 8, 9, 10, 6, 1, 4 ] );;
gap> p:=(1,13,15,3,5,7,17)(2,16,12,11,19,18,14,8,10,9,20)(4,6);;
gap> LQUO(p, f);
[5,8][7,10][13,2][16,3][17,1](4,6,9)
gap> p^-1*f;                       
[5,8][7,10][13,2][16,3][17,1](4,6,9)
gap> last=last2;
true
gap> f:=RandomPartialPerm(65535);;
gap> p:=Random(SymmetricGroup(65536));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm2PPerm4, Case 1 of 4, deg(p)<deg(f),  dom(f) unknown
gap> f:=RandomPartialPerm(65536);;
gap> p:=Random(SymmetricGroup(60000));;
gap> LQUO(p, f)=p^-1*f; 
true

# LQuoPerm2PPerm4, Case 2 of 4, deg(p)<deg(f),  dom(f) known
gap> f:=RandomPartialPerm(65536);; DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(60000));;
gap> LQUO(p, f)=p^-1*f; 
true

# LQuoPerm2PPerm4, Case 3 of 4, deg(p)>=deg(f), dom(f) unknown
gap> f:=RandomPartialPerm(65536);;                         
gap> p:=Random(SymmetricGroup(70000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm2PPerm4, Case 4 of 4, deg(p)>=deg(f), dom(f) known
gap> f:=RandomPartialPerm(65536);; DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(60000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm4PPerm2, Case 1 of 4, deg(p)<deg(f),  dom(f) unknown
gap> f:=PartialPermNC( [ 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 14, 15, 17, 19 ], 
> [ 19, 7, 17, 14, 8, 5, 3, 18, 15, 13, 2, 12, 10, 20 ] );;
gap> f:=JoinOfPartialPerms(f, PartialPermNC([100000], [1]));;
gap> p:=Random(SymmetricGroup(70000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm4PPerm2, Case 2 of 4, deg(p)<deg(f),  dom(f) known
gap> f:=PartialPermNC( [ 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 14, 15, 17, 19 ], 
> [ 19, 7, 17, 14, 8, 5, 3, 18, 15, 13, 2, 12, 10, 20 ] );;
gap> f:=JoinOfPartialPerms(f, PartialPermNC([100000], [1]));;
gap> DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(70000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm4PPerm2, Case 3 of 4, deg(p)>=deg(f), dom(f) unknown
gap> f:=PartialPermNC( [ 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 14, 15, 17, 19 ], 
> [ 19, 7, 17, 14, 8, 5, 3, 18, 15, 13, 2, 12, 10, 20 ] );;
gap> f:=JoinOfPartialPerms(f, PartialPermNC([10000], [1]));;
gap> p:=Random(SymmetricGroup(70000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm4PPerm2, Case 4 of 4, deg(p)>=deg(f), dom(f) known
gap> f:=PartialPermNC( [ 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 14, 15, 17, 19 ], 
> [ 19, 7, 17, 14, 8, 5, 3, 18, 15, 13, 2, 12, 10, 20 ] );;
gap> f:=JoinOfPartialPerms(f, PartialPermNC([10000], [1]));;
gap> DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(70000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm4PPerm4, Case 1 of 4, deg(p)<deg(f),  dom(f) unknown
gap> f:=RandomPartialPerm(70000);;
gap> p:=Random(SymmetricGroup(66000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm4PPerm4, Case 2 of 4, deg(p)<deg(f),  dom(f) known
gap> f:=RandomPartialPerm(70000);;
gap> DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(66000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm4PPerm4, Case 3 of 4, deg(p)>=deg(f), dom(f) unknown
gap> f:=RandomPartialPerm(66000);;
gap> p:=Random(SymmetricGroup(70000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPerm4PPerm4, Case 4 of 4, deg(p)>=deg(f), dom(f) known
gap> f:=RandomPartialPerm(66000);;
gap> DomainOfPartialPerm(f);;
gap> p:=Random(SymmetricGroup(70000));;
gap> LQUO(p, f)=p^-1*f;
true

# LQuoPPerm22, Case 1 of 3, dom(g) unknown
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 16, 17, 18, 19 ], 
> [ 3, 12, 14, 4, 11, 18, 17, 2, 9, 5, 15, 8, 20, 10, 19 ] );;
gap> g:=PartialPermNC(
> [ 13, 1, 8, 5, 4, 14, 0, 11, 12, 9, 0, 20, 0, 2, 0, 18, 0, 7, 3, 19 ]);;
gap> LQUO(f, g);
[2,11,4,5][10,7][12,1][15,20][19,3,13](8,18,14)(9)
gap> f^-1*g;
[2,11,4,5][10,7][12,1][15,20][19,3,13](8,18,14)(9)
gap> last=last2;
true
gap> f:=RandomPartialPerm(10000);;                             
gap> g:=RandomPartialPerm(9000);; 
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm22, Case 2 of 3, dom(g) known, deg(g)>deg(f)
gap> f:=PartialPermNC( [ 1, 2, 3, 5, 6, 7, 8, 11, 12, 16, 19 ], 
> [ 9, 18, 20, 11, 5, 16, 8, 19, 14, 13, 1 ] );;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 5, 7, 8, 10, 11, 13, 18, 19, 20 ], 
> [ 5, 1, 7, 3, 10, 2, 12, 14, 11, 16, 6, 9, 15 ] );;
gap> LQUO(f, g)=f^-1*g;
true
gap> LQUO(f, g);
[8,12][16,2][18,1,9,5][19,11,10][20,7]
gap> f:=RandomPartialPerm(9000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(10000);; DomainOfPartialPerm(g);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm22, Case 3 of 3, dom(g) known, deg(g)<=deg(f)
gap> f:=RandomPartialPerm(10000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(9000);; DomainOfPartialPerm(g);;
gap> LQUO(f, g)=f^-1*g; 
true

# LQuoPPerm24, Case 1 of 3, dom(g) unknown
gap> f:=RandomPartialPerm(100);;
gap> g:=RandomPartialPerm(100000);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm24, Case 2 of 3, dom(g) known, deg(g)>deg(f)
gap> f:=RandomPartialPerm(100);;
gap> g:=RandomPartialPerm(100000);; DomainOfPartialPerm(g);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm24, Case 3 of 3, dom(g) known, deg(g)<=deg(f)
gap> f:=RandomPartialPerm(9000);;
gap> g:=RandomPartialPerm(100);;  
gap> g:=JoinOfPartialPerms(g, PartialPermNC([101], [100000]));;
gap> DomainOfPartialPerm(g);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm42, Case 1 of 3, dom(g) unknown
gap> f:=RandomPartialPerm(100000);;
gap> g:=RandomPartialPerm(100);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm42, Case 2 of 3, dom(g) known, deg(g)>deg(f)
gap> f:=RandomPartialPerm(100000);;
gap> g:=RandomPartialPerm(100);; 
gap> g:=JoinOfPartialPerms(g, PartialPermNC([100001],[101]));;
gap> DomainOfPartialPerm(g);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm42, Case 3 of 3, dom(g) known, deg(g)<=deg(f)
gap> f:=RandomPartialPerm(100000);;
gap> g:=RandomPartialPerm(100);; DomainOfPartialPerm(g);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm44, Case 1 of 3, dom(g) unknown
gap> f:=RandomPartialPerm(65536);;
gap> g:=RandomPartialPerm(65536);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm44, Case 2 of 3, dom(g) known, deg(g)>deg(f)
gap> f:=RandomPartialPerm(65536);;
gap> g:=RandomPartialPerm(66000);; DomainOfPartialPerm(g);;
gap> LQUO(f, g)=f^-1*g;
true

# LQuoPPerm44, Case 3 of 3, dom(g) known, deg(g)<=deg(f)
gap> f:=RandomPartialPerm(66000);;
gap> g:=RandomPartialPerm(66553);; DomainOfPartialPerm(g);;
gap> LQUO(f, g)=f^-1*g;
true

# PowPPerm22, Case 1 of 6, dom(f) not known, codeg(f)<=deg(g)
gap> f:=PartialPermNC(
> [ 3, 12, 14, 4, 11, 18, 17, 2, 0, 9, 5, 15, 0, 0, 0, 8, 20, 10, 19]);;
gap> g:=PartialPermNC( 
> [ 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 16, 18, 19, 21, 22, 
>  23, 25, 29, 30 ], [ 13, 1, 8, 24, 5, 4, 14, 11, 25, 12, 9, 21, 20, 2, 22, 
>  23, 18, 30, 7, 3, 19 ] );;
gap> f^g;
[1,12][4,2,11][13,8,21](5,25)(22)(24)
gap> g^-1*f*g;
[1,12][4,2,11][13,8,21](5,25)(22)(24)
gap> f:=RandomPartialPerm(20000);; 
gap> g:=RandomPartialPerm(30000);;
gap> f^g=g^-1*f*g;
true

# PowPPerm22, Case 2 of 6, dom(f) not known, codeg(f)> deg(g)
gap> f:=PartialPermNC(
> [ 28, 4, 16, 6, 14, 9, 17, 0, 19, 22, 0, 12, 0, 7, 23, 25, 15, 0, 0, 0, 0, 0, 
>   26, 0, 0, 24, 0, 0, 0, 5 ]);;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 8, 9, 10, 15, 16, 17, 19, 20 ], 
> [ 9, 3, 15, 17, 20, 2, 12, 10, 18, 11, 6, 7, 8, 4 ] );;
gap> f^g=g^-1*f*g;
true

# PowPPerm22, Case 3 of 6, dom(f)     known, deg(f)>deg(g),   codeg(f)<=deg(g)
gap> f:= 
> PartialPermNC( [ 1, 2, 3, 4, 8, 10, 100 ], [ 5, 10, 4, 3, 6, 1, 9 ] );;
gap> g:=
> PartialPermNC( [ 1, 2, 3, 5, 7, 9, 11, 14, 15, 16, 17, 18 ], 
> [ 4, 14, 2, 3, 17, 7, 9, 16, 15, 10, 11, 1 ] );;
gap> f^g=g^-1*f*g;
true

# PowPPerm22, Case 4 of 6, dom(f)     known, deg(f)>deg(g),   codeg(f)> deg(g)
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 16, 18, 19,
> 21, 22, 23, 25, 29, 30 ], [ 13, 1, 8, 24, 5, 4, 14, 11, 25, 12, 9, 21, 20, 2,
> 22, 23, 18, 30, 7, 3, 19 ] );;
gap> g:=PartialPermNC( [ 1, 2, 3, 5, 6, 7, 8, 11, 12, 16, 19 ], 
> [ 9, 18, 20, 11, 5, 16, 8, 19, 14, 13, 1 ] );;
gap> DegreeOfPartialPerm(f); DegreeOfPartialPerm(g);
30
19
gap> CodegreeOfPartialPerm(f); CodegreeOfPartialPerm(g);
30
20
gap> f^g;
[18,9][20,8](11)(14)
gap> g^-1*f*g;                    
[18,9][20,8](11)(14)
gap> last=last2;
true
gap> f:=RandomPartialPerm(50000);;
gap> g:=RandomPartialPerm(40000);;
gap> f^g=g^-1*f*g;
true

# PowPPerm22, Case 5 of 6, dom(f)     known, deg(f)<=deg(g),  codeg(f)<=deg(g)
gap> f:=
> PartialPermNC( [ 1, 2, 3, 4, 5, 9, 10 ], [ 3, 6, 4, 2, 1, 10, 7 ] );;
gap> g:=
> PartialPermNC( [ 1, 2, 3, 5, 7, 9, 11, 14, 15, 16, 17, 18 ], 
> [ 4, 14, 2, 3, 17, 7, 9, 16, 15, 10, 11, 1 ] );
[5,3,2,14,16,10][18,1,4](7,17,11,9)(15)
gap> f^g;
[3,4,2]
gap> g^-1*f*g;
[3,4,2]

# PowPPerm22, Case 6 of 6, dom(f)     known, deg(f)<=deg(g),  codeg(f)> deg(g)
gap> f:=
> PartialPermNC( [ 1, 2, 3, 6, 7, 8, 9, 10 ], [ 5, 8, 2, 4, 7, 3, 1, 100 ] );;
gap> g:=
> PartialPermNC( [ 1, 2, 3, 4, 5, 6, 7, 10, 11, 13, 15, 16, 17, 18, 19 ], 
> [ 17, 1, 10, 6, 13, 4, 19, 11, 7, 12, 16, 2, 9, 8, 20 ] );;
gap> f^g;
[4,6][10,1][17,13](19)
gap> g^-1*f*g;
[4,6][10,1][17,13](19)

# PowPPerm24, Case 1 of 6, dom(f) not known, codeg(f)<=deg(g)
gap> f:=RandomPartialPerm(10);;                           
gap> g:=RandomPartialPerm(65536);;
gap> f^g=g^-1*f*g;
true

# PowPPerm24, Case 2 of 6, dom(f) not known, codeg(f)> deg(g)
gap> f:=RandomPartialPerm(10);;
gap> f:=JoinOfPartialPerms(f, PartialPermNC([11], [100]));;
gap> g:=PartialPermNC([10], [65536]);;
gap> g:=JoinOfPartialPerms(g, RandomPartialPerm(9));;
gap> f^g=g^-1*f*g;
true

# PowPPerm24, Case 3 of 6, dom(f)     known, deg(f)>deg(g),   codeg(f)<=deg(g)
gap> f:=PartialPerm( [ 1, 2, 4, 6, 7 ], [ 6, 9, 8, 5, 7 ] );;                            
gap> f:=JoinOfPartialPerms(f, PartialPermNC([11], [100]));;
gap> f:=f^-1;; DomainOfPartialPerm(f);;
gap> g:=PartialPermNC([20], [65536]);;              
gap> g:=JoinOfPartialPerms(g, RandomPartialPerm(9));;
gap> DegreeOfPartialPerm(f)>DegreeOfPartialPerm(g);
true
gap> CodegreeOfPartialPerm(f)<=DegreeOfPartialPerm(g);
true
gap> f^g = g^-1*f*g;
true

# PowPPerm24, Case 4 of 6, dom(f)     known, deg(f)>deg(g),   codeg(f)> deg(g)
gap> f:=RandomPartialPerm(30);; DomainOfPartialPerm(f);;
gap> DegreeOfPartialPerm(f)>DegreeOfPartialPerm(g);
true
gap> CoDegreeOfPartialPerm(f)>DegreeOfPartialPerm(g);
true
gap> f^g=g^-1*f*g;
true

# PowPPerm24, Case 5 of 6, dom(f)     known, deg(f)<=deg(g),  codeg(f)<=deg(g)
gap> f:=RandomPartialPerm(30);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(65536);;                  
gap> f^g=g^-1*f*g;
true

# PowPPerm24, Case 6 of 6, dom(f)     known, deg(f)<=deg(g),  codeg(f)> deg(g)
gap> g:=PartialPermNC([20], [65536]);;              
gap> g:=JoinOfPartialPerms(g, PartialPerm( [ 1, 2, 6, 7, 9 ], [ 6, 3, 9, 1, 8 ] ));;
gap> f:=PartialPermNC( [ 10] , [22]);;
gap> f^g;
<empty partial perm>
gap> g^-1*f*g;
<empty partial perm>
gap> f:=JoinOfPartialPerms(f, PartialPerm( [ 1, 2, 3, 4 ], [ 7, 6, 4, 5 ] ));; 
gap> DomainOfPartialPerm(f);;
gap> f^g=g^-1*f*g;
true

# PowPPerm42, Case 1 of 6, dom(f) not known, codeg(f)<=deg(g)
gap> f:=PartialPermNC([ 2, 6, 7, 0, 0, 9, 0, 1, 0, 5, 100000 ]);;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 6, 7, 8, 10, 100001 ], 
> [ 3, 8, 1, 9, 4, 10, 5, 6, 11 ] );;
gap> f^g=g^-1*f*g;
true

# PowPPerm42, Case 2 of 6, dom(f) not known, codeg(f)> deg(g)
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 6, 7, 8, 9, 11, 13, 14, 15, 17, 18 ], 
> [ 19, 14, 20, 16, 13, 9, 18, 1, 5, 7, 3, 10, 2, 12 ] );;
gap> f^g;
[18,19,14,13,1][20,9]
gap> f^g=g^-1*f*g;
true

# PowPPerm42, Case 3 of 6, dom(f)     known, deg(f)>deg(g),   codeg(f)<=deg(g)
gap> f:=PartialPermNC( [ 1, 2, 4, 5, 8, 10, 100002 ], 
> [ 6, 2, 7, 8, 10, 4, 70000 ] );; DomainOfPartialPerm(f);;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 5, 9, 100000 ], 
> [ 9, 3, 8, 2, 10, 7, 11 ] );;
gap> DegreeOfPartialPerm(f);
100002
gap> DegreeOfPartialPerm(g);
100000
gap> CodegreeOfPartialPerm(f);
70000
gap> IsPPerm2Rep(g);
true
gap> f^g;
<identity partial perm on [ 3 ]>
gap> g^-1*f*g=last;
true

# PowPPerm42, Case 4 of 6, dom(f)     known, deg(f)>deg(g),   codeg(f)> deg(g)
gap> f:=RandomPartialPerm(70000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(10);;                                                
gap> f^g=g^-1*f*g;
true

# PowPPerm42, Case 5 of 6, dom(f)     known, deg(f)<=deg(g),  codeg(f)<=deg(g)
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 5, 9, 100000 ],
> [ 9, 3, 8, 2, 10, 7, 11 ] );;
gap> f:=RandomPartialPerm(70000);; DomainOfPartialPerm(f);;
gap> f^g=g^-1*f*g;
true

# PowPPerm42, Case 6 of 6, dom(f)     known, deg(f)<=deg(g),  codeg(f)> deg(g)
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 8, 10, 11 ], 
> [ 4, 3, 7, 6, 5, 9, 2, 70000 ] );; DomainOfPartialPerm(f);;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 7, 8, 11, 15, 16, 19 ], 
> [ 10, 2, 18, 17, 16, 5, 13, 20, 15, 11, 4, 6 ] );;
gap> f^g;
[2,18,13][10,17,5](16)
gap> g^-1*f*g=last;             
true

# PowPPerm44, Case 1 of 6, dom(f) not known, codeg(f)<=deg(g)
gap> f:=PartialPermNC( [ 1, 2, 3, 6, 8, 10, 11 ], 
> [ 2, 6, 7, 9, 1, 5, 100000 ] );;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 6, 7, 8, 10, 21, 100001 ], 
> [ 3, 8, 1, 9, 4, 10, 5, 6, 100000, 11 ] );;
gap> f^g;
[1,10][5,3,8,4]
gap> g^-1*f*g=last;
true

# PowPPerm44, Case 2 of 6, dom(f) not known, codeg(f)> deg(g)
gap> f:=PartialPermNC( [ 1, 2, 3, 6, 8, 10, 11 ], 
> [ 2, 6, 7, 9, 1, 5, 100000 ] );;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 6, 7, 8, 9, 11, 13, 14, 15, 17, 18, 21 ], 
> [ 19, 14, 20, 16, 13, 9, 18, 1, 5, 7, 3, 10, 2, 12, 100000 ] );;
gap> g^-1*f*g;
[18,19,14,13,1][20,9]
gap> f^g=last;
true

# PowPPerm44, Case 3 of 6, dom(f)     known, deg(f)>deg(g),   codeg(f)<=deg(g)
gap> f:=PartialPermNC( [ 1, 2, 4, 5, 8, 10, 100002 ], 
> [ 6, 2, 7, 8, 10, 4, 70000 ] );; DomainOfPartialPerm(f);;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 6, 7, 8, 10, 21, 100001 ], 
> [ 3, 8, 1, 9, 4, 10, 5, 6, 100000, 11 ] );;
gap> DegreeOfPartialPerm(f);
100002
gap> DegreeOfPartialPerm(g);
100001
gap> CodegreeOfPartialPerm(f);
70000
gap> f^g;                   
[3,4][5,6,9,10](8)
gap> g^-1*f*g=last;
true

# PowPPerm44, Case 4 of 6, dom(f)     known, deg(f)>deg(g),   codeg(f)> deg(g)
gap> f:=RandomPartialPerm(70000);;                                             
gap> DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(66000);;
gap> f^g=g^-1*f*g;
true

# PowPPerm44, Case 5 of 6, dom(f)     known, deg(f)<=deg(g),  codeg(f)<=deg(g)
gap> f:=RandomPartialPerm(66000);; DomainOfPartialPerm(f);;
gap> g:=RandomPartialPerm(70000);;
gap> f^g=g^-1*f*g;
true

# PowPPerm44, Case 6 of 6, dom(f)     known, deg(f)<=deg(g),  codeg(f)> deg(g)
gap> f:=PartialPermNC( [ 1, 2, 3, 4, 5, 8, 10, 11 ], 
> [ 4, 3, 7, 6, 5, 9, 2, 70000 ] );; DomainOfPartialPerm(f);;
gap> g:=PartialPermNC( [ 1, 2, 3, 4, 5, 6, 7, 8, 11, 15, 16, 19 ], 
> [ 10, 2, 18, 17, 16, 5, 13, 20, 15, 11, 4, 6 ] );;
gap> g:=JoinOfPartialPerms(g, PartialPerm([65536], [65536]));;
gap> f^g;
[2,18,13][10,17,5](16)
gap> g^-1*f*g=last;             
true

# from Semigroups...
gap> f:=PartialPermNC([0,1,0,20]);
[2,1][4,20]
gap> f^2;
<empty partial perm>
gap> f^-1;
[1,2][20,4]
gap> f:=PartialPermNC([0,20,0,1]); 
[2,20][4,1]
gap> f^2;
<empty partial perm>
gap> f^-1;
[1,4][20,2]
gap> ImageSetOfPartialPerm(f^-1);
[ 2, 4 ]
gap> ImageSetOfPartialPerm(f);   
[ 1, 20 ]
gap> f^-1<f;
false
gap> f<f^-1;
true
gap> f:=PartialPermNC([2,4], [20,1]);
[2,20][4,1]
gap> f^-1=f;
false
gap> f=f^-1;
false
gap> f^-1;
[1,4][20,2]
gap> f*f^-1;
<identity partial perm on [ 2, 4 ]>
gap> f^-1*f;   
<identity partial perm on [ 1, 20 ]>
gap> f^2;
<empty partial perm>
gap> f:=[PartialPermNC([ 1, 2, 5 ], [ 1, 7, 4 ]), 
> PartialPermNC([ 1, 2, 3, 4, 8 ], [ 1, 7, 5, 6, 8 ]),
> PartialPermNC([ 1, 2, 4, 5, 7 ], [ 3, 4, 5, 2, 7 ]),
> PartialPermNC([ 1, 2, 3, 5, 6, 7 ], [ 5, 2, 6, 8, 1, 7 ])];;
gap> f[1]*f[2];
[5,6](1)
gap> f[1]*f[2]*f[3]; 
[1,3]
gap> f[4]*f[1]*f[3];
[1,5][2,7][6,3]
gap> f[4]^4;
[3,8](2)(7)
gap> f[4]^5;
<identity partial perm on [ 2, 7 ]>
gap> f[4]^10;
<identity partial perm on [ 2, 7 ]>
gap> f[4]^-4; 
[8,3](2)(7)
gap> 
gap> f:=RandomPartialPerm(10000);;
gap> g:=f^-1;;
gap> ForAll(DomainOfPartialPerm(f), i-> (i^f)^g=i);
true
gap> ForAll(ImageSetOfPartialPerm(f), i-> (i^g)^f=i);     
true
gap> p:=(1,3,2)(4,5);;
gap> f:=PartialPermNC([ 1, 3, 4, 5, 6, 7, 9, 10 ], [ 6, 1, 4, 9, 2, 3, 7, 5 ]);
[10,5,9,7,3,1,6,2](4)
gap> p*f;
[10,5,4,9,7,3](1)(2,6)
gap> f*p;
[10,4,5,9,7,2](1,6)(3)
gap> FixedPointsOfPartialPerm(f*p);
[ 3 ]
gap> f:=PartialPermNC([ 1, 2, 3, 5, 6, 7, 8, 10 ],
> [ 6, 2, 5, 4, 7, 8, 9, 10 ]);
[1,6,7,8,9][3,5,4](2)(10)
gap> g:=PartialPermNC([ 1, 2, 3, 5, 7, 8 ], [ 8, 10, 9, 1, 5, 6 ]);
[2,10][3,9][7,5,1,8,6]
gap> f<g;
false
gap> g<f;
true
gap> f=g;
false
gap> f/g;
[10,2](1,8,3,7)
gap> f/g=f*g^-1;
true
gap> f/g^-1=f*g;
true
gap> AsPermutation(f);
fail
gap> AsTransformation(f);
<transformation: 6,2,5,10,4,7,8,9,10>
gap> AsTransformation(f, 12);
<transformation: 6,2,5,12,4,7,8,9,12,10,12>
gap> f;
[1,6,7,8,9][3,5,4](2)(10)
gap> f:=PartialPermNC([ 1, 3, 4, 5, 6, 9 ], [ 9, 10, 5, 7, 2, 8 ]);;
gap> AsTransformation(f);
<transformation: 9,11,10,5,7,2,11,11,8,11>
gap> AsTransformation(f);
<transformation: 9,11,10,5,7,2,11,11,8,11>
gap> OnTuples([1..DegreeOfPartialPerm(f)], f);
[ 9, 10, 5, 7, 2, 8 ]
gap> g:=PartialPermNC([ 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 19 ],
> [ 3, 17, 12, 13, 6, 1, 2, 20, 9, 16, 4, 15, 8 ]);;
gap> OnTuples([1..DegreeOfPartialPerm(f)], f);
[ 9, 10, 5, 7, 2, 8 ]
gap> DomainOfPartialPerm(f)=ImageSetOfPartialPerm(f^-1);
true
gap> ImageSetOfPartialPerm(f)=DomainOfPartialPerm(f^-1);   
true
gap> FixedPointsOfPartialPerm(f);
[  ]
gap> FixedPointsOfPartialPerm(f^-1);
[  ]
gap> FixedPointsOfPartialPerm(g);   
[  ]
gap> f:=PartialPermNC([ 1, 3, 4, 5, 6, 9 ], [ 9, 10, 5, 7, 2, 8 ]);;
gap> ImageSetOfPartialPerm(g);
[ 1, 2, 3, 4, 6, 8, 9, 12, 13, 15, 16, 17, 20 ]
gap> OnSets(DomainOfPartialPerm(f), f)=ImageListOfPartialPerm(f);
false
gap> OnSets(DomainOfPartialPerm(f), f)=ImageSetOfPartialPerm(f);
true
gap> OnTuples(DomainOfPartialPerm(f), f)=ImageSetOfPartialPerm(f);
false
gap> OnTuples(DomainOfPartialPerm(f), f)=ImageListOfPartialPerm(f);   
true
gap> OnTuples(ImageListOfPartialPerm(f), f^-1)=DomainOfPartialPerm(f);
true
gap> OnSets(ImageSetOfPartialPerm(f), f^-1)=DomainOfPartialPerm(f);
true
gap> OnSets(ImageSetOfPartialPerm(g), g^-1)=DomainOfPartialPerm(g);
true
gap> OnTuples(ImageListOfPartialPerm(g), g^-1)=DomainOfPartialPerm(f);
false
gap> OnTuples(ImageListOfPartialPerm(g), g^-1)=DomainOfPartialPerm(g);
true

#gap> f:=ReadSemigroups(file, 6)[1];   
#<partial perm on 31542 pts>
#
gap> f:=PartialPermNC([ 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 19 ],
> [ 5, 13, 7, 6, 10, 15, 9, 14, 4, 20, 19, 2 ]);
[1,5,10][3,7,9][11,14,19,2,13,20][12,4,6,15]
gap> One(f);
<identity partial perm on 
[ 1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 19, 20 ]>
gap> One(f)*f=f*One(f);
true
gap> One(f)*f=f;
true
gap> OnSets([1..100], f);
[ 2, 4, 5, 6, 7, 9, 10, 13, 14, 15, 19, 20 ]
gap> f:=PartialPermNC([2039, 2149, 21443, 13431, 1, 2, 3]);
[4,13431][5,1,2039][6,2,2149][7,3,21443]
gap> OnSets([1..10000], f); 
[ 1, 2, 3, 2039, 2149, 13431, 21443 ]
gap> ImageListOfPartialPerm(f);
[ 2039, 2149, 21443, 13431, 1, 2, 3 ]
gap> ImageListOfPartialPerm(f);
[ 2039, 2149, 21443, 13431, 1, 2, 3 ]
gap> ImageSetOfPartialPerm(f);
[ 1, 2, 3, 2039, 2149, 13431, 21443 ]
gap> ImageSetOfPartialPerm(f);
[ 1, 2, 3, 2039, 2149, 13431, 21443 ]
gap> RankOfPartialPerm(f);
7
gap> f:=PartialPermNC(
> [ 9, 45, 53, 15, 42, 97, 71, 66, 7, 88, 6, 98, 95, 36, 20, 59, 94, 0, 81, 70,
>  65, 29, 78, 37, 74, 48, 52, 4, 32, 93, 18, 13, 55, 0, 49, 0, 99, 46, 35,
>  84, 0, 79, 80, 0, 85, 0, 89, 0, 0, 27, 0, 0, 0, 73, 33, 0, 77, 69, 41, 0,
>  63, 0, 0, 0, 75, 56, 0, 0, 0, 90, 64, 0, 0, 0, 100, 0, 0, 3, 0, 0, 2, 26,
>  11, 39, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 10, 61, 25 ]);
[1,9,7,71,64][5,42,79][12,98][14,36][16,59,41][17,94][19,81,2,45,85]
[21,65,75,100][22,29,32,13,95,10,88][23,78,3,53][24,37,99][28,4,15,20,70,90]
[30,93][31,18][38,46][40,84,39,35,49][43,80][47,89][50,27,52][54,73][57,77]
[58,69][82,26,48][83,11,6,97,25,74][92,8,66,56][96,61,63](33,55)
gap> 50^f;
27
gap> 27^f;
52
gap> 52^f;
0
gap> 50^f;
27
gap> 27^f;
52

#
gap> f:=PartialPermNC( [ 1, 2, 3, 6, 8, 10 ], [ 2, 6, 7, 9, 1, 5 ] );;
gap> f<f;
false

#
gap> f:=PartialPermNC([]);;
gap> f<f;
false

# Test for the bug in RestrictedPartialPerm
gap> RestrictedPartialPerm(EmptyPartialPerm(), [1,2,3,4]);
<empty partial perm>
gap> RestrictedPartialPerm(PartialPerm([1],[1]), [2,3,4]);                     
<empty partial perm>

# Test for bug in QuoPPerm2 as reported by Bill Allombert
gap> x := PartialPerm([70000], [1]);
[70000,1]
gap> CodegreeOfPartialPerm(x / x);
70000

# Test Zero and MultiplicativeZeroOp
gap> x := PartialPerm([1, 2, 4, 7, 9], [5, 3, 7, 4, 9]);;
gap> Zero(x);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `ZeroMutable' on 1 arguments
gap> MultiplicativeZeroOp(x);
<empty partial perm>
gap> MultiplicativeZero(x);
<empty partial perm>

#
gap> SetUserPreference("PartialPermDisplayLimit", display);;
gap> SetUserPreference("NotationForPartialPerm", notationpp);;
gap> SetUserPreference("NotationForTransformations", notationt);;

#
gap> STOP_TEST( "pperm.tst", 1);
