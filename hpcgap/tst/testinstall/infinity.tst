#############################################################################
##
#W  infinity.tst                GAP Library                  Markus Pfeiffer
##
##
#Y  Copyright (C) 2014,  University of St Andrews, Scotland
##
##
gap> START_TEST("infinity.tst");

# unary minus
gap> infinity;
infinity
gap> -infinity;
-infinity

# addition and subtraction
gap> infinity + infinity;
infinity
gap> -infinity - infinity;
-infinity
gap> infinity + 1;
infinity
gap> 1 + infinity;
infinity
gap> -infinity + 1;
-infinity
gap> 1 - infinity;
-infinity

#
gap> infinity + -infinity;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `+' on 2 arguments
gap> infinity - infinity;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `+' on 2 arguments
gap> -infinity + infinity;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `+' on 2 arguments
gap> -infinity - (-infinity);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `+' on 2 arguments

# comparison
gap> cycls := [ -infinity, -10, 0, 42, E(5), infinity ];
[ -infinity, -10, 0, 42, E(5), infinity ]
gap> for op in [ \=, \< ] do
>   for i in [1..Length(cycls)] do
>     for j in [1..Length(cycls)] do
>       if IsCyc(cycls[i]) and IsCyc(cycls[j]) then
>         continue;
>       fi;
>       Print(cycls[i], NameFunction(op), cycls[j]);
>       Print(" gives correct result? ");
>       Print(op(cycls[i], cycls[j]) = op(i, j));
>       Print("\n");
>     od;
>   od;
> od;
-infinity=-infinity gives correct result? true
-infinity=-10 gives correct result? true
-infinity=0 gives correct result? true
-infinity=42 gives correct result? true
-infinity=E(5) gives correct result? true
-infinity=infinity gives correct result? true
-10=-infinity gives correct result? true
-10=infinity gives correct result? true
0=-infinity gives correct result? true
0=infinity gives correct result? true
42=-infinity gives correct result? true
42=infinity gives correct result? true
E(5)=-infinity gives correct result? true
E(5)=infinity gives correct result? true
infinity=-infinity gives correct result? true
infinity=-10 gives correct result? true
infinity=0 gives correct result? true
infinity=42 gives correct result? true
infinity=E(5) gives correct result? true
infinity=infinity gives correct result? true
-infinity<-infinity gives correct result? true
-infinity<-10 gives correct result? true
-infinity<0 gives correct result? true
-infinity<42 gives correct result? true
-infinity<E(5) gives correct result? true
-infinity<infinity gives correct result? true
-10<-infinity gives correct result? true
-10<infinity gives correct result? true
0<-infinity gives correct result? true
0<infinity gives correct result? true
42<-infinity gives correct result? true
42<infinity gives correct result? true
E(5)<-infinity gives correct result? true
E(5)<infinity gives correct result? true
infinity<-infinity gives correct result? true
infinity<-10 gives correct result? true
infinity<0 gives correct result? true
infinity<42 gives correct result? true
infinity<E(5) gives correct result? true
infinity<infinity gives correct result? true

#
gap> STOP_TEST( "infinity.tst", 1);

#############################################################################
##
#E
