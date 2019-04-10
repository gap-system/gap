# Check we can make non-homogeneous lists into SSortedLists.
gap> l:= [ 1, Z(2) ];;
gap> SetIsSSortedList( l, true );
gap> IsSSortedList( l );
true
gap> Filtered( l, IsObject );
[ 1, Z(2)^0 ]
