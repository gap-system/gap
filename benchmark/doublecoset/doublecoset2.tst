#############################################################################
##
#W  doublecoset.tst                                     Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This  file  tests for double coset calculations
##
gap> START_TEST("doublecoset2.tst");
gap> g:=SimpleGroup("J3");;
gap> m:=MaximalSubgroupClassReps(g);;
gap> u:=First(m,x->Index(g,x)=43605);;
gap> dc:=DoubleCosetRepsAndSizes(g,u,u);;
gap> Length(dc);Sum(dc,x->x[2])=Size(g);
57
true
gap> STOP_TEST( "doublecoset2.tst", 1);
