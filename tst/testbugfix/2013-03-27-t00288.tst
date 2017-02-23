# 2013/03/27 (AK)
gap> im := [ [ [E(3)^2,0], [0,E(3)] ], [ [0,E(3)], [E(3)^2,0] ] ];;
gap> hom := GroupHomomorphismByImages( SymmetricGroup(3), Group(im), im );;
gap> NaturalCharacter(hom);
Character( CharacterTable( Sym( [ 1 .. 3 ] ) ), [ 2, 0, -1 ] )
