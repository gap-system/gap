# Fix for https://github.com/gap-system/gap/issues/5808
# See also https://github.com/gap-system/gap/pull/5811
gap> G := AlternatingGroup( 6 );;
gap> hom1 := GroupHomomorphismByImages( G, G, [ (1,2,3,4,5), (4,5,6) ], [ (1,2,6,3,5), (1,4,5) ] );;
gap> hom2 := GroupHomomorphismByImages( G, G, [ (1,2,3,4,5), (4,5,6) ], [ (1,2,3,4,5), (4,5,6) ] );;
gap> tc := function ( g, h ) return (h^hom2)^-1 * g * h^hom1; end;;
gap> stab := Stabilizer( G, One(G), tc );;
gap> Size(stab);
5
gap> Set( stab ) = Set( Filtered( G, g -> tc( One(G), g ) = One(G) ) );
true
gap> Set(stab);
[ (), (1,2,6,4,5), (1,4,2,5,6), (1,5,4,6,2), (1,6,5,2,4) ]

#
gap> G := AlternatingGroup( 6 );;
gap> hom1 := GroupHomomorphismByImages( G, G, [ (1,2,3,4,5), (4,5,6) ], [ (1,2,6,3,5), (1,4,5) ] );;
gap> hom2 := IdentityMapping( G );;
gap> tc := function ( g, h ) return (h^hom2)^-1 * g * h^hom1; end;;
gap> stab := Stabilizer( G, One(G), tc );;
gap> Size(stab);
5
gap> Set( stab ) = Set( Filtered( G, g -> tc( One(G), g ) = One(G) ) );
true
gap> Set(stab);
[ (), (1,2,6,4,5), (1,4,2,5,6), (1,5,4,6,2), (1,6,5,2,4) ]
