gap> START_TEST("HallSubgroup.tst");
gap> G := GL(3,4);;
gap> HallSubgroup(G, [2,3]);
fail
gap> G := PSL(4,2);;
gap> IdGroup(HallSubgroup(G, [2,3]));
[ 576, 8654 ]
gap> G := PSp(4,5);;
gap> IdGroup(HallSubgroup(G,[2,3]));
[ 576, 8277 ]
gap> G := Group([ [ [ Z(2)^0, 0*Z(2), 0*Z(2) ],
> [ 0*Z(2), Z(2)^0, 0*Z(2) ],
> [ 0*Z(2), Z(2)^0, Z(2)^0 ] ], 
> [ [ 0*Z(2), Z(2)^0, 0*Z(2) ],
> [ 0*Z(2), 0*Z(2), Z(2)^0 ],
> [ Z(2)^0, 0*Z(2), 0*Z(2) ] ] ]);;
gap> List(HallSubgroup(G, [2,3]), IdGroup);
[ [ 24, 12 ], [ 24, 12 ] ]
gap> STOP_TEST("HallSubgroup.tst", 1);
