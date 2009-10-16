#############################################################################
##
#W  perlist.tst                GAP4 Package `RCWA'                Stefan Kohl
##
#H  @(#)$Id: perlist.tst,v 1.2 2007/10/22 08:55:52 stefan Exp $
##
##  This file contains automated tests of RCWA's functionality dealing with
##  periodic lists.
##
gap> START_TEST("$Id: perlist.tst,v 1.2 2007/10/22 08:55:52 stefan Exp $");
gap> RCWADoThingsToBeDoneBeforeTest();
gap> l := PeriodicList([],[1,2]);
[/ 1, 2 ]
gap> Sum(l);
infinity
gap> Product(l);
infinity
gap> l := PeriodicList([0],[1,2]);
[ 0, / 1, 2 ]
gap> Sum(l);
infinity
gap> Product(l);
0
gap> l := PeriodicList([1,2,3],[1,2,0]);
[ 1, 2, 3, / 1, 2, 0 ]
gap> Sum(l);
infinity
gap> Product(l);
0
gap> l := PeriodicList([0],[0]);
[ 0, / 0 ]
gap> Sum(l);
0
gap> Product(l);
0
gap> l := PeriodicList([-1],[1]);
[ -1, / 1 ]
gap> Sum(l);
infinity
gap> Product(l);
-1
gap> l := PeriodicList([-1],[-1]);
[ -1, / -1 ]
gap> Product(l);
fail
gap> l := PeriodicList([-1],[1,-1]);
[ -1, / 1, -1 ]
gap> Sum(l);
fail
gap> Product(l);
fail
gap> l := PeriodicList([],[1,-1,0]);
[/ 1, -1, 0 ]
gap> Sum(l);
fail
gap> Product(l);
0
gap> l := PeriodicList([-1],[1,-1,0]);
[ -1, / 1, -1, 0 ]
gap> Sum(l);
fail
gap> Product(l);
0
gap> G := WreathProduct(Group(ClassTransposition(0,2,1,2)),
>                       Group(ClassShift(0,1)));
<wild rcwa group over Z with 2 generators>
gap> IsSubgroup(CT(Integers),G);
true
gap> StructureDescription(G);
"C2 wr Z"
gap> l := PeriodicList([],[1,2]);
[/ 1, 2 ]
gap> Ball(G,l,4,OnPoints);
[ [/ 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
    1, 1, 1, 1, 1, 1, 1, 1 ], [/ 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
    1 ], [/ 1, 2, 1, 1, 1, 1, 1, 1 ], [/ 1, 2, 1, 1 ], [/ 1, 2 ], 
  [/ 1, 2, 2, 2 ], [/ 1, 2, 2, 2, 2, 2, 2, 2 ], 
  [/ 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ], 
  [/ 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 
    2, 2, 2, 2, 2, 2, 2, 2 ] ]
gap> List([1..6],k->Length(Ball(G,l,k,OnPoints)));
[ 3, 5, 7, 9, 11, 13 ]
gap> l := PeriodicList([],[1,2,3]);
[/ 1, 2, 3 ]
gap> List([1..6],k->Length(Ball(G,l,k,OnPoints)));
[ 4, 10, 22, 44, 84, 155 ]
gap> l := PeriodicList([],[1..8]);
[/ 1, 2, 3, 4, 5, 6, 7, 8 ]
gap> List([1..6],k->Length(Ball(G,l,k,OnPoints)));
[ 4, 9, 16, 24, 32, 40 ]
gap> l := PeriodicList([],[1..16]);
[/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]
gap> List([1..8],k->Length(Ball(G,l,k,OnPoints)));
[ 4, 10, 21, 37, 58, 84, 114, 148 ]
gap> RCWADoThingsToBeDoneAfterTest();
gap> STOP_TEST( "perlist.tst", 100000000 );

#############################################################################
##
#E  perlist.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here