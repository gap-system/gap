gap> START_TEST("Test of FreeGroups package");

gap> f:=FreeGroup(2);                                                 
<free group on the generators [ f1, f2 ]>
gap> g:=Group(f.1*f.2*f.1);
Group([ f1*f2*f1 ])
gap> f.1*f.2 in g;
false
gap> f.2 in g;
false
gap> f.1*f.2*f.1 in g;
true
gap> Rank(g);
1
gap> RepresentativeAction(f,f.1*f.2,f.2*f.1);
f1
gap> RepresentativeAction(g,f.1*f.2,f.2*f.1);
f1*f2*f1
gap> RepresentativeAction(g,f.2*f.1,f.1*f.2);
f1^-1*f2^-1*f1^-1
gap> RepresentativeAction(Group(f.1*f.2),f.1*f.2,f.2*f.1);
fail

gap> f:=FreeGroup(3);
<free group on the generators [ f1, f2, f3 ]>
gap> e:=Enumerator(f);
<enumerator of <free group on the generators [ f1, f2, f3 ]>>
gap> g:=Group(List(e{[2..187]},g->g^2));;
gap> FreeGeneratorsOfGroup(g);
[ f1^2, f2*f1*f2^-1*f1^-1, f2^2, f3*f1*f3^-1*f1^-1, f3*f2*f3^-1*f2^-1, f3^2, 
  f1*f2*f1*f2^-1, f1*f2^2*f1^-1, f1*f3*f1*f3^-1, f1*f3*f2*f3^-1*f2^-1*f1^-1, 
  f1*f3^2*f1^-1, f2*f3*f1*f3^-1*f2^-1*f1^-1, f2*f3*f2*f3^-1, f2*f3^2*f2^-1, 
  f1*f2*f3*f1*f3^-1*f2^-1, f1*f2*f3*f2*f3^-1*f1^-1, f1*f2*f3^2*f2^-1*f1^-1 ]
gap> Index(f,g);
8
gap> n:=Normalizer(f,g);
Group(<free, no generators known>)
gap> Rank(n);
3

gap> g:=Group((f.1*f.2)^5);;
gap> FreeGeneratorsOfGroup(Normalizer(f,g^f.3));
[ f3^-1*f1*f2*f3 ]
gap> RepresentativeAction(f,g^f.3,g^(f.2*f.3));
f3^-1*f2*f3
gap> Centralizer(f,g);
Group([ f1*f2 ])
gap> Centralizer(f,g^f.3);
Group([ f3^-1*f1*f2*f3 ])
gap> Centralizer(g,Group((f.1*f.2)^2));
Group([ f1*f2*f1*f2*f1*f2*f1*f2*f1*f2 ])

gap> g1:=Group((f.1*f.2)^15);;
gap> Index(g,g1);
3

gap> RankOfFreeGroup(Intersection(Group(f.2^f.1,f.1^2),Group(f.2,f.1*f.2*f.1^2,f.1^2*f.2*f.1,f.1^3)));
4

gap> STOP_TEST( "FGA.tst", 100000);
