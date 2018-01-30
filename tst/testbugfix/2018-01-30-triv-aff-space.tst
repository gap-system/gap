# Verify that enumerating "extended" vectors" over a trivial vector space
# works as intended (this used to fail, because testing whether the empty
# list [] is contained in the vector space V defined below, which is
# collection, by definition always fails in GAP, even though [] is e.g. equal
# to Zero(V). This is a major problem by itself, but difficult to resolve.
#
# In any case, we sidestep this larger issue, and just worry about the
# particular case of "extended" vectors.
gap> V:=GF(3)^0;;
gap> A:=ExtendedVectors(V);;
gap> [Z(3)^0] in A;
true

# test the original example from issue #2117
gap> g:= DirectProduct( AlternatingGroup(5), SymmetricGroup(3) );;
gap> Irr( g );;
