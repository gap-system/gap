# Unrefinable series
gap> g:=Group((1,17)(2,18)(3,15,4,16)(5,13)(6,14)(7,11,8,12)(9,10)
> (19,45,20,46)(21,43,22,44)(23,42)(24,41)(25,40)(26,39)(27,38,28,37)
> (29,36)(30,35)(31,33,32,34),
> (1,29,12,40,22,3,32,14,42,24,6,34,15,44,26,8,36,17,45,28,10,38,19)(2,30,11,
> 39,21,4,31,13,41,23,5,33,16,43,25,7,35,18,46,27,9,37,20));;
gap> home:=HomePcgs(g);;
gap> ind:=IndicesEANormalStepsBounded(home,2^15);;
gap> BoundedRefinementEANormalSeries(home,ind,2^15);;
gap> List(ChiefNormalSeriesByPcgs(home),Size);
[ 192937984, 96468992, 4194304, 1 ]
