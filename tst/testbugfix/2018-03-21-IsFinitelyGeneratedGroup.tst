# There was an incorrect method for IsFinitelyGeneratedGroup which assumed
# that a group given by an infinite generating set is not finitely generated,
# which is of course false: any finitely generated infinite group is generated
# by its set of elements.
#
# Test that this is not the case anymore:
gap> F:=FreeGroup(1);;
gap> G:=SubgroupShell(F);
Group(<free, no generators known>)
gap> SetGeneratorsOfGroup(G, Enumerator(F));

# We are defensive: GAP should either not know that G is finitely generated
# (that's the situation right now), or, if it ever is improved to handle this
# case, it should correctly determine that G = F is finitely generated (even
# cyclic)
gap> not HasIsFinitelyGeneratedGroup(G) or IsFinitelyGeneratedGroup(G);
true
