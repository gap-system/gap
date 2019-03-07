# see https://github.com/gap-system/gap/pull/3331
gap> F := FreeGroup( 1 );;
gap> IsFinite( F );;
gap> S := SymmetricGroup( 3 );;
gap> IsFinite( S );;
gap> IsomorphismGroups( F, S );
fail
gap> IsomorphismGroups( S, F );
fail
