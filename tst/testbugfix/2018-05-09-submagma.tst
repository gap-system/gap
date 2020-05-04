#
# There was a bug where we marked a sub additive magma
# with empty generator list as trivial, even though it is empty.
#
# There was also a wrong implication, from "IsFiniteOrderElementCollection and
# IsMagma" to IsMagmaWithInverses. But a collection with the former filters may
# be empty, and then it isn't a IsMagmaWithInverses.
#
gap> amgm:=AdditiveMagma([0]);
<additive magma with 1 generator>
gap> Size(amgm);
1
gap> IsTrivial(amgm);
true
gap> IsEmpty(amgm);
false
gap> IsMagmaWithInverses(amgm);
false

#
gap> asub:=SubadditiveMagma(amgm, []);
<additive magma with 0 generators>
gap> Size(asub);
0
gap> IsTrivial(asub);
false
gap> IsEmpty(asub);
true
gap> IsMagmaWithInverses(asub);
false

#
gap> mgm:=Magma( () );;
gap> Size(mgm);
1
gap> IsTrivial(mgm);
true
gap> IsEmpty(mgm);
false

#
gap> sub:=Submagma(mgm,[]);
<empty semigroup>
gap> Size(sub);
0
gap> IsTrivial(sub);
false
gap> IsEmpty(sub);
true
gap> IsMagmaWithInverses(sub);
false
