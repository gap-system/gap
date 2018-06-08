# There was a bug where composition of an identity mapping and another
# mapping x where the Source of the identity mapping contained the
# ImagesSource of x, but not its whole range, simply returned x,
# resulting in a composition whose Range was strictly bigger than that
# of its first argument, and causing problems in IsomorphismPermGroup
#
gap> g := SymmetricGroup(7);;
gap> phi := GroupGeneralMappingByImages(g,g,[(1,2,3,4,5),(1,2)],[(1,2,3,4,6),(1,2)]);
[ (1,2,3,4,5), (1,2) ] -> [ (1,2,3,4,6), (1,2) ]
gap> psi := IdentityMapping(SymmetricGroup(6));
IdentityMapping( Sym( [ 1 .. 6 ] ) )
gap> Range(CompositionMapping(psi,phi));
Sym( [ 1 .. 6 ] )
