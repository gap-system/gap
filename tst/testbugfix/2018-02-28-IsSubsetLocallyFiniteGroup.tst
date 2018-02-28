# there used to be a bad implication from IsFFECollection and IsMagma to
# IsSubsetLocallyFiniteGroup, which caused all finite fields to be in filter
# IsSubsetLocallyFiniteGroup -- verify this is not the case anymore.
gap> HasIsSubsetLocallyFiniteGroup(GF(2));
false
gap> HasIsSubsetLocallyFiniteGroup(GF(2^20));
false

# that implication was replaced by one from IsFFECollection and IsMagmaWithInverses
# to IsSubsetLocallyFiniteGroup -- verify that it works
gap> G:=Units(GF(2));;
gap> HasIsSubsetLocallyFiniteGroup(G);
true
gap> HasIsFinite(G);
true

#
gap> G:=Group(Z(2));;
gap> HasIsSubsetLocallyFiniteGroup(G);
true
gap> HasIsFinite(G);
true

#
gap> G:=Group(Z(2^20));;
gap> HasIsSubsetLocallyFiniteGroup(G);
true
gap> HasIsFinite(G);
true
