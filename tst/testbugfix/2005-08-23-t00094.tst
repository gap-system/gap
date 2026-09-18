# 2005/08/23 (TB)
# At that time, the fix meant to exit from a method that computes
# the degrees, in order to get into a method that uses the stored
# irreducibles.
# With the changes from 'https://github.com/gap-system/gap/pull/6075',
# the method that uses the stored irreducibles has higher rank,
# thus a delegation via 'TryNextMethod' is not necessary anymore.

gap> g:= SymmetricGroup( 4 );; IsSolvable( g );; Irr( g );;
gap> meth:= ApplicableMethod( CharacterDegrees, [ g ] );;
gap> info:= First( MethodsOperation( CharacterDegrees, 1 ),
>                  r -> r.func = meth );;
gap> info.info = "CharacterDegrees: for a group with known Irr value";
true
