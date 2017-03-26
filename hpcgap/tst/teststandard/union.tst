#############################################################################
##
#W  union.tst                GAP library                     Chris Jefferson
##
##
#Y  Copyright (C)  2014,  University of St Andrews
##
##
gap> START_TEST("union.tst");
gap> for i in [-4..4] do
>      for j in [-3,-2,-1,1,2,3] do
>        for k in [-2..2] do
>          for a in [-6..6] do
>            for b in [-3,-2,-1,1,2,3] do
>              for c in [-3..3] do
>                l1 := [i,i+j..i+(j*k)];
>                l2 := [a,a+b..a+(b*c)];
>                l3 := List(l1, x->x);
>                l4 := List(l2, x->x);
>                if Union(l1,l2) <> Union(l3,l4) then
>                  Print("Invalid compare 1:",[l1,l2,l3,l4]);
>                fi;
>                if Union([i,j],l2) <> Union([i,j],l4) then
>                  Print("Invalid compare 2:",[[i,j],l2,[i,j],l4]);
>                fi;
>                if Union([i],l2) <> Union([i],l4) then
>                  Print("Invalid compare 3:",[[i],l2,[i],l4]);
>                fi;
>                if Union(l1,[i,j],l2) <> Union(l3,[i,j],l4) then
>                  Print("Invalid compare 4:",[l1,l2,l3,l4]);
>                fi;
>              od;
>            od;
>          od;
>        od;
>      od;
>    od;
gap> mylist := [ [ 1 ], [ -1 ], [ 2 ], [ -5, -2 ], [ 3 ], [ -3 ], [ 4 ], [ -4 ], [ 5 ], [ 6 ], [ -6 ] ];;
gap> Set( Flat( mylist ) ) = Union( mylist );
true
gap> Union([]);
[  ]
gap> Union([Z(5)]);
Error, Union: arguments must be lists or collections
gap> l := [1,4,2];;
gap> Union([l,l]);
[ 1, 2, 4 ]
gap> Union([1..5],[1/2]);
[ 1/2, 1, 2, 3, 4, 5 ]
gap> Union([1..5],[1,3,4]);
[ 1 .. 5 ]
gap> Union([1..5],[1/2,7]);
[ 1/2, 1, 2, 3, 4, 5, 7 ]
gap> Union([[1],[1],[1]]);
[ 1 ]
gap> Union([1,2],"a");
[ 1, 2, 'a' ]
gap> Union([1,2],"a",[3,4]);
[ 1, 2, 3, 4, 'a' ]
gap> Union([1,5..19997],[3],[7,11,19999],[15,23..19991],[19,27..19995]);
[ 1, 3 .. 19999 ]
gap> IsRangeRep(Union([1,5..19997],[3],[7,15,19999],[15,23..19991],[19,27..19995]));
false
gap> f := x -> List([1..x], y -> [y*5..(y+1)*5]);; Union(f(10000));
[ 5 .. 50005 ]
gap> f := x -> List([1..x], y -> [y*15,(y+1)*15..(y+5)*15]);; Union(f(10000));
[ 15, 30 .. 150075 ]
gap> IsGroup (Union ([SymmetricGroup (4)]));
true
gap> Union(Group((1,2)), Group((1,2)), Group((1,2))) = Group((1,2));
true
gap> STOP_TEST( "union.tst", 1);

#############################################################################
##
#E
