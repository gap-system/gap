# Regression test for issue #5923: the 8-bit kernel path for
# CosetLeadersMatFFE must not leave holes in the result list.
gap> F := GF(4);;
gap> M := One(F)*[[1,0,Z(4)],[0,1,Z(4)^2]];;
gap> L := CosetLeadersMatFFE(M, F);;
gap> Length(L) = Size(F)^2;
true
gap> ForAll([1..Length(L)], i -> IsBound(L[i]));
true
gap> List(L, v -> NumberFFVector(M * v, Size(F))) = [0..Length(L)-1];
true

# some additional tests "because we can" for other cases
gap> F := GF(2);;
gap> M := One(F)*[[1,0,1,0,1,0],[1,1,1,0,0,0]];;
gap> L := CosetLeadersMatFFE(M, F);;
gap> Length(L) = Size(F)^2;
true
gap> ForAll([1..Length(L)], i -> IsBound(L[i]));
true
gap> List(L, v -> NumberFFVector(M * v, Size(F))) = [0..Length(L)-1];
true

# some additional tests "because we can" for other cases
gap> F := GF(257);;
gap> M := One(F)*[[1,0,1,0,1,0],[1,1,1,0,0,0]];;
gap> L := CosetLeadersMatFFE(M, F);;
gap> Length(L) = Size(F)^2;
true
gap> ForAll([1..Length(L)], i -> IsBound(L[i]));
true
gap> List(L, v -> NumberFFVector(M * v, Size(F))) = [0..Length(L)-1];
true
