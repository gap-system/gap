gap> START_TEST("AutomorphismGroup.tst");
gap> SimpleAutTest:=function(from,to)
> local it,g,a,p;
>   it:=SimpleGroupsIterator(from);
>   g:=NextIterator(it);
>   while Size(g)<=to do
>     a:=AutomorphismGroup(g);
>     Info(InfoWarning,2,g," ",Size(g)," ",Size(a)/Size(g));
>     p:=Image(IsomorphismPermGroup(a));
>     if Size(p)<>Size(a) then
>       return g;
>     fi;
>     g:=NextIterator(it);
>   od;
>   return true;
> end;;
gap> SimpleAutTest(1,10^5);
true
gap> SimpleAutTest(10^5,3*10^6:nopsl2);
true

#
gap> G:=GL(IsPermGroup,3,3);;
gap> H:=AutomGrpSR(G);;
gap> StructureDescription(H);
"PSL(3,3) : C2"

#
gap> G:=GL(IsPermGroup,3,3);;
gap> H:=AutomorphismGroupMorpheus(G);;
gap> StructureDescription(H);
"PSL(3,3) : C2"

#
gap> STOP_TEST("AutomorphismGroup.tst",1);
