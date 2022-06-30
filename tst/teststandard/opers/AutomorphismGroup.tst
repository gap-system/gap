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

# went wrong in 4.11
gap> g:=Group((1,27)(2,26)(3,10)(4,12)(5,24)(6,25)(7,15)(8,21)(9,18)(11,22)
>   (14,23)(16,19), (1,10,16,2,21)(3,27,11,26,19)(4,14,18,7,17)(5,24,23,20,9)
>   (6,12,15,25,13));;
gap> Size(AutomorphismGroup(g));
1440

#
gap> STOP_TEST("AutomorphismGroup.tst",1);
