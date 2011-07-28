#############################################################################
##
#W  perlist.tst                GAP4 Package `RCWA'                Stefan Kohl
##
##  This file contains automated tests of RCWA's functionality dealing with
##  periodic lists.
##
#############################################################################

gap> START_TEST( "perlist.tst" );
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
gap> l1 := PeriodicList([1,2,3],[1,2]);
[ 1, 2, 3, / 1, 2 ]
gap> l2 := PeriodicList([1,2,3,4],[1,2,3]);
[ 1, 2, 3, 4, / 1, 2, 3 ]
gap> -l1;
[ -1, -2, -3, / -1, -2 ]
gap> l1+l2;
[ 2, 4, 6, 5, / 3, 3, 5, 2, 4, 4 ]
gap> last-l1;
[ 1, 2, 3, 4, / 1, 2, 3 ]
gap> 2*l1;
[ 2, 4, 6, / 2, 4 ]
gap> 2*l1-l1*2;
[/ 0 ]
gap> (2*l1)/2;
[ 1, 2, 3, / 1, 2 ]
gap> l1+1;
[ 2, 3, 4, / 2, 3 ]
gap> 3+l1;
[ 4, 5, 6, / 4, 5 ]
gap> 1-l1;
[ 0, -1, -2, / 0, -1 ]
gap> T := RcwaMapping([[1,0,2],[3,1,2]]);
<rcwa mapping of Z with modulus 2>
gap> l := PeriodicList([],[1]);
[/ 1 ]
gap> Permuted(l,T);
[/ 1, 1, 2 ]
gap> Permuted(last,T);
[/ 1, 2, 2, 1, 2, 2, 1, 2, 3 ]
gap> Permuted(last,T);
[/ 1, 2, 4, 1, 3, 3, 1, 2, 4, 1, 2, 4, 1, 3, 3, 1, 2, 4, 1, 2, 4, 1, 3, 3, 1, 
2, 5 ]
gap> Sum(Period(last));
64
gap> l := PeriodicList([],[1,E(3),E(3)^2]);
[/ 1, E(3), E(3)^2 ]
gap> Permuted(l,T);
[/ 1, E(3)^2, 2*E(3), 1, E(3)^2, -E(3)^2, 1, E(3)^2, -1 ]
gap> Sum(Period(last));
0
gap> Permuted(last2,T);
[/ 1, 2*E(3), 2*E(3)^2, 1, -1, -E(3), 1, -E(3)^2, 0, 1, 2*E(3), 2*E(3)^2, 1, 
-1, -E(3), 1, -E(3)^2, 2*E(3)+E(3)^2, 1, 2*E(3), 2*E(3)^2, 1, -1, -E(3), 1, 
-E(3)^2, E(3)+2*E(3)^2 ]
gap> Sum(Period(last));
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
gap> Ball(G,l,4,Permuted);
[ [/ 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
    1, 1, 1, 1, 1, 1, 1, 1 ], [/ 1, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 
    1 ], [/ 1, 2, 1, 1, 1, 1, 1, 1 ], [/ 1, 2, 1, 1 ], [/ 1, 2 ], 
  [/ 1, 2, 2, 2 ], [/ 1, 2, 2, 2, 2, 2, 2, 2 ], 
  [/ 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2 ], 
  [/ 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 
    2, 2, 2, 2, 2, 2, 2, 2 ] ]
gap> List([1..6],k->Length(Ball(G,l,k,Permuted)));
[ 3, 5, 7, 9, 11, 13 ]
gap> l := PeriodicList([],[1,2,3]);
[/ 1, 2, 3 ]
gap> List([1..6],k->Length(Ball(G,l,k,Permuted)));
[ 4, 10, 22, 44, 84, 155 ]
gap> l := PeriodicList([],[1..8]);
[/ 1, 2, 3, 4, 5, 6, 7, 8 ]
gap> List([1..6],k->Length(Ball(G,l,k,Permuted)));
[ 4, 9, 16, 24, 32, 40 ]
gap> l := PeriodicList([],[1..16]);
[/ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 ]
gap> List([1..8],k->Length(Ball(G,l,k,Permuted)));
[ 4, 10, 21, 37, 58, 84, 114, 148 ]
gap> RCWADoThingsToBeDoneAfterTest();
gap> STOP_TEST( "perlist.tst", 4000000000 );

#############################################################################
##
#E  perlist.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here