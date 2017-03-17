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
gap> STOP_TEST( "union.tst", 1);

#############################################################################
##
#E
