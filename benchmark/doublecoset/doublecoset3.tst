#############################################################################
##
#W  doublecoset.tst                                     Alexander Hulpke
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  This  file  tests for double coset calculations
##
gap> START_TEST("doublecoset3.tst");
gap> g:=SimpleGroup("Co3");;
gap> m:=MaximalSubgroupClassReps(g);;
gap> u:=First(m,x->Index(g,x)=17931375);;
gap> dc:=DoubleCosetRepsAndSizes(g,u,u);;
gap> Length(dc);Sum(dc,x->x[2])=Size(g);
913
true
gap> STOP_TEST( "doublecoset3.tst", 1);
