# NiceMonomorphism of a group of automorphisms was not faithful if a
# generator class representative was fixed by all automorphisms, but its
# conjugates were not. This then caused SubgroupsSolvableGroup to fail.
gap> G:= SmallGroup( 42, 4 );;
gap> gens:= Pcgs( G );;
gap> imgs:= [ gens[1], gens[2]^2, gens[3]^2 ];;
gap> hom:= GroupHomomorphismByImages( G, G, gens, imgs );;
gap> au:= GroupByGenerators( [ hom ], IdentityMapping( G ) );;
gap> IsGroupOfAutomorphismsFiniteGroup( au );
true
gap> Size( au );
6
gap> l:= SubgroupsSolvableGroup( G, rec( actions:= [ hom ] ) );;
gap> SortedList( List( l, Size ) );
[ 1, 2, 3, 6, 7, 14, 21, 42 ]
gap> ForAll( l, U -> Image( hom, U ) = U );
true
