# see https://github.com/gap-system/gap/issues/5330
gap> z:= Immutable( ZeroVector( Integers, 1 ) );;
gap> IsZero( z );  HasIsZero( z );
true
true
gap> v:= Vector( [ 1 ], z );;
gap> HasIsZero( v );  IsZero( v ); # this used to incorrectly return true
false
false
