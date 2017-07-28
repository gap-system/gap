# This test is designed to check we handle swapping master pointers in various
# different cases. There are various things we test:
# 1) Do we correctly handle if the swapped objects are young or old?
# 2) Do we correctly handle objects allocated before, between, and after the objects?

gap> START_TEST("mptr.tst");
gap> checkswap := function(switches)
>     local l1,l2,l3,x,y,i,check;
>     check := true;
>     l1 := List([1..10], x -> [(1,2)]);;
>     x := [(1,2)];;
>     if 1 in switches then
>       GASMAN("collect");
>     fi;
>     l2 := List([1..10], x -> [(1,2)]);;
>     y := [(1,2)];;
>     l3 := List([1..10], x -> [(1,2)]);;
>     if 2 in switches then
>       GASMAN("collect");
>     fi;
>     if 3 in switches then
>         for i in [1..10] do
>             l1[i][1] := (2,3);
>         od;
>     fi;
>     if 4 in switches then
>         x[1] := (2,3);
>     fi;
>     if 5 in switches then
>         for i in [1..10] do
>             l2[i][1] := (2,3);
>         od;
>     fi;
>     if 6 in switches then
>         y[1] := (2,3);
>     fi;
>     if 7 in switches then
>         for i in [1..10] do
>             l3[i][1] := (2,3);
>         od;
>     fi;
>     if 8 in switches then
>       GASMAN("collect");
>     fi;
>     if 9 in switches then
>        SWITCH_OBJ(x,y);
>     else
>        SWITCH_OBJ(y,x);
>     fi;
>     # If something went wrong, this call may
>     # crash, corrupt x or y, or something else
>     GASMAN("collect");
>     # Remember these are now swapped!
>     if 4 in switches then
>         check := check and y = [(2,3)];
>     else
>         check := check and y = [(1,2)];
>     fi;
>     if 6 in switches then
>         check := check and x = [(2,3)];
>     else
>         check := check and x = [(1,2)];
>     fi;
>     return check;
>  end;;
gap> ForAll(Combinations([1,2,3,4,5,6,7,8,9]), checkswap);
true
gap> STOP_TEST( "mptr.tst", 1);
