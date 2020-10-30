gap> START_TEST("Lattice.tst");

#
gap> g:=PerfectGroup(IsPermGroup,30720,10);;
gap> l:=LowLayerSubgroups(g,2);;
gap> [Length(l),Sum(l,Size)];
[ 41, 80896 ]

#
gap> STOP_TEST("Lattice.tst",1);
