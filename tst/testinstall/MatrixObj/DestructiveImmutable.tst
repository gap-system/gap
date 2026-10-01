gap> START_TEST("DestructiveImmutable.tst");

# TransposedMatDestructive and BaseMatDestructive need a mutable matrix
gap> TransposedMatDestructive( Immutable( [ [ 1, 2 ], [ 3, 4 ] ] ) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `TransposedMatDestructive' on 1 argument\
s
gap> BaseMatDestructive( Immutable( [ [ 1, 2 ], [ 3, 4 ] ] ) );
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `BaseMatDestructive' on 1 arguments
gap> TransposedMatDestructive( [ [ 1, 2, 3 ], [ 4, 5, 6 ] ] );
[ [ 1, 4 ], [ 2, 5 ], [ 3, 6 ] ]
gap> BaseMatDestructive( [ [ 1, 2, 3 ], [ 4, 5, 6 ], [ 5, 7, 9 ] ] );
[ [ 1, 2, 3 ], [ 0, 1, 2 ] ]

#
gap> STOP_TEST("DestructiveImmutable.tst");
