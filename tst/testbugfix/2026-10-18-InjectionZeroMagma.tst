# InjectionZeroMagma is injective but not surjective
gap> map := InjectionZeroMagma( SymmetricGroup( 2 ) );;
gap> [ IsInjective( map ), IsSurjective( map ), IsBijective( map ) ];
[ true, false, false ]
gap> x := (1,2) ^ map;;
gap> PreImagesRepresentative( map, x );
(1,2)
gap> PreImagesElm( map, x );
[ (1,2) ]
gap> z := MultiplicativeZero( Range( map ) );;
gap> PreImagesRepresentative( map, z );
fail
gap> PreImagesElm( map, z );
[  ]
gap> PreImage( map, z );
Error, <map> must be an injective and surjective mapping
