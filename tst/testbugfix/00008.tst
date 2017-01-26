## EulerianFunction (10)
gap> EulerianFunction( DihedralGroup(8), 2);
24
gap> EulerianFunction( CyclicGroup(6), 1 );
2
gap> EulerianFunction( CyclicGroup(5), 1 );
4
gap> g:=SmallGroup(1,1);;
gap> ConjugacyClassesSubgroups(g);;
gap> g:=Group([ (3,5), (1,3,5) ]);;
gap> MaximalSubgroups(g);;
