#############################################################################
##
##  This  file  tests for double coset calculations
##
gap> START_TEST("doublecoset2.tst");
gap> g:=SimpleGroup("J2");;
gap> m:=MaximalSubgroupClassReps(g);;
gap> u:=First(m,x->Index(g,x)=10080);;
gap> dc:=DoubleCosetRepsAndSizes(g,u,u);;
gap> Length(dc);Sum(dc,x->x[2])=Size(g);
191
true
gap> STOP_TEST( "doublecoset1.tst", 1);
