# OnSets would sometimes return a mutable list when it should have returned an
# immutable one; in HPC-GAP this got worse, as the final object was a mutable
# and *public* list.
#
# This only happened if the acting element was not internal, i.e., not a
# permutation, partial permutation or transformation.
gap> g:=SymmetricGroup(5);;
gap> phi:=ConjugatorAutomorphism(g,One(g));;

# mutable -> mutable
gap> l:=OnSets([ (1,2) ], phi);
[ (1,2) ]
gap> IsMutable(l);
true
#@if IsHPCGAP
gap> IsPublic(l);
false
#@fi

# immutable -> immutable
gap> l:=OnSets(Immutable([ (1,2) ]), phi);
[ (1,2) ]
gap> IsMutable(l);
false
#@if IsHPCGAP
gap> IsPublic(l);
true
#@fi
