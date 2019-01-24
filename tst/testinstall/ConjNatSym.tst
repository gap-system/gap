# The following two test use the new version for natural symmetric group

gap> IsConjugate( SymmetricGroup(5), Group((1,2)), Group((3,4)));
true
gap> IsConjugate( SymmetricGroup(5), Group((1,2)), Group((3,4,5)));
false

# This runs into the TryNextMethod case
gap> IsConjugate( SymmetricGroup(200),PrimitiveGroup(200,4), PrimitiveGroup(200,3));
false

# Here, using SubgpConjSymmgp yields a significant speedup
gap> IsConjugate(SymmetricGroup(250),Group([ (1,5,9,7)(2,3)(4,8,6,10), (1,9)(5,7)(8,10), (1,9)(8,10) ]), Group([ (1,3)(2,8,10)(4,6)(5,11,7,9), (2,8)(9,11), (1,3)(4,6)(5,9,7,11)(8,10) ]));
false
