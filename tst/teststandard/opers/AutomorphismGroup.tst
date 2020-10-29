gap> START_TEST("AutomorphismGroup.tst");

# Assertions at level 2 kill runtime of automorphism group computations
gap> SetAssertionLevel(0);

#
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
gap> H:=AutomorphismGroup(G);;
gap> StructureDescription(H);
"PSL(3,3) : C2"

#
gap> SetAssertionLevel(0);
gap> g:=PerfectGroup(IsPermGroup,15360,1);;
gap> h:=g^(1,129);;
gap> AutomorphismGroup(g);; # pull out of isom. test (reduce timeout risk)
gap> AutomorphismGroup(h);;
gap> IsomorphismGroups(g,h:forcetest)<>fail;
true

#
gap> STOP_TEST("AutomorphismGroup.tst",1);
