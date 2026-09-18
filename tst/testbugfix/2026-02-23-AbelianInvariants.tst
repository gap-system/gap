# Fix bug in MaximalAbelianQuotient
# (format of the AbelianInvariants value)
#@local G
gap> START_TEST("AbelianInvariants.tst");

#
gap> G:= AbelianGroup( IsFpGroup, [ 2, 3, 4 ] );;
gap> AbelianInvariants( G );
[ 2, 3, 4 ]
gap> G:= AbelianGroup( IsFpGroup, [ 2, 3, 4 ] );;
gap> MaximalAbelianQuotient( G );;  # sets the abelian invariants
gap> HasAbelianInvariants( G );
true
gap> AbelianInvariants( G );
[ 2, 3, 4 ]

#
gap> STOP_TEST("AbelianInvariants.tst");
