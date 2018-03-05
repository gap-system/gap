gap> START_TEST("CyclesFromList");

#
gap> CycleFromList( [1..10] );
(1,2,3,4,5,6,7,8,9,10)
gap> CycleFromList( [1,5,4,8] );
(1,5,4,8)
gap> CycleFromList( [9,10,3,5]);
(3,5,9,10)
gap> CycleFromList( [1,3,,9] );
fail
gap> CycleFromList( [1,3,3,8] );
fail

# Errors
gap> CycleFromList( [7,2,0,3] );
Error, CycleFromList: List must only contain positive integers.
gap> CycleFromList( [9,3,-7,8,9] );
Error, CycleFromList: List must only contain positive integers.
gap> CycleFromList( [2,2,1/2,6] );
Error, CycleFromList: List must only contain positive integers.

# 
gap> CycleFromList( [] );
()
gap> CycleFromList( [7] );
()
gap> CycleFromList( [0] );
Error, CycleFromList: List must only contain positive integers.
gap> CycleFromList( [true] );
Error, CycleFromList: List must only contain positive integers.
gap> STOP_TEST("CyclesFromList", 1);
