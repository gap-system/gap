# 2005/04/12 (AH)
gap> f:=FreeGroup(IsSyllableWordsFamily,8);;
gap> g:=GeneratorsOfGroup(f);;
gap> g1:=g[1];;
gap> g2:=g[2];;
gap> g3:=g[3];;
gap> g4:=g[4];;
gap> g5:=g[5];;
gap> g6:=g[6];;
gap> g7:=g[7];;
gap> g8:=g[8];;
gap> rws:=SingleCollector(f,[ 2, 3, 2, 3, 2, 3, 2, 3 ]);;
gap> r:=[
>   [1,g4*g6],
>   [3,g4],
>   [5,g6*g8^2],
>   [7,g8],
> ];;
gap> for x in r do SetPower(rws,x[1],x[2]);od;
gap> G:= GroupByRwsNC(rws);;
gap> f1:=G.1;;
gap> f2:=G.2;;
gap> f3:=G.3;;
gap> f4:=G.4;;
gap> f5:=G.5;;
gap> f6:=G.6;;
gap> f7:=G.7;;
gap> f8:=G.8;;
gap> a:=Subgroup(G,[f3*f6*f8^2, f5*f6*f8^2, f7*f8, f4*f6^2*f8 ]);;
gap> b:=Subgroup(G,[f2^2*f4^2*f6*f7*f8^2, f2*f4*f6^2*f8^2, f5*f6^2*f8,
>                   f2^2*f6^2*f8, f2*f3*f4, f2^2]);;
gap> Size(Intersection(a,b))=Number(a,i->i in b);
true
