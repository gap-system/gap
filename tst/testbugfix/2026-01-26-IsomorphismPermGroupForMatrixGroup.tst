# Fix bug in IsomorphismPermGroupForMatrixGroup, see #6205
#@local G, iso, H, nice
gap> START_TEST("IsomorphismPermGroupForMatrixGroup.tst");

#
# test with a nice mono that has a permutation group as range
#

# Source(nice) = G, IsSurjective(nice)
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> H:=CyclicGroup(IsPermGroup, 2);;
gap> nice:=GroupHomomorphismByFunction(G, H, x -> H.1^(2/Int(DeterminantMat(x))));;
gap> HasNiceMonomorphism(G);  # double check: no nice mono has been set so far
false
gap> SetNiceMonomorphism(G, nice);
gap> IsBijective(IsomorphismPermGroupForMatrixGroup(G));
true

# Source(nice) = G, not IsSurjective(nice)
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> H:=CyclicGroup(IsPermGroup, 4);;
gap> nice:=GroupHomomorphismByFunction(G, H, x -> H.1^(4/Int(DeterminantMat(x))));;
gap> HasNiceMonomorphism(G);  # double check: no nice mono has been set so far
false
gap> SetNiceMonomorphism(G, nice);
gap> IsBijective(IsomorphismPermGroupForMatrixGroup(G));
true

# Source(nice) <> G, IsSurjective(nice)
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> H:=CyclicGroup(IsPermGroup, 2);;
gap> nice:=GroupHomomorphismByFunction(GL(2,3), H, x -> H.1^(2/Int(DeterminantMat(x))));;
gap> HasNiceMonomorphism(G);  # double check: no nice mono has been set so far
false
gap> SetNiceMonomorphism(G, nice);
gap> IsBijective(IsomorphismPermGroupForMatrixGroup(G));
true

# Source(nice) <> G, not IsSurjective(nice)
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> H:=CyclicGroup(IsPermGroup, 4);;
gap> nice:=GroupHomomorphismByFunction(GL(2,3), H, x -> H.1^(4/Int(DeterminantMat(x))));;
gap> HasNiceMonomorphism(G);  # double check: no nice mono has been set so far
false
gap> SetNiceMonomorphism(G, nice);
gap> IsBijective(IsomorphismPermGroupForMatrixGroup(G));
true

#
# test with a nice mono that does not have a permutation group as range
#

# Source(nice) = G, IsSurjective(nice)
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> H:=CyclicGroup(IsPcGroup, 2);;
gap> nice:=GroupHomomorphismByFunction(G, H, x -> H.1^(2/Int(DeterminantMat(x))));;
gap> HasNiceMonomorphism(G);  # double check: no nice mono has been set so far
false
gap> SetNiceMonomorphism(G, nice);
gap> IsBijective(IsomorphismPermGroupForMatrixGroup(G));
true

# Source(nice) = G, not IsSurjective(nice)
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> H:=CyclicGroup(IsPcGroup, 4);;
gap> nice:=GroupHomomorphismByFunction(G, H, x -> H.1^(4/Int(DeterminantMat(x))));;
gap> HasNiceMonomorphism(G);  # double check: no nice mono has been set so far
false
gap> SetNiceMonomorphism(G, nice);
gap> IsBijective(IsomorphismPermGroupForMatrixGroup(G));
true

# Source(nice) <> G, IsSurjective(nice)
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> H:=CyclicGroup(IsPcGroup, 2);;
gap> nice:=GroupHomomorphismByFunction(GL(2,3), H, x -> H.1^(2/Int(DeterminantMat(x))));;
gap> HasNiceMonomorphism(G);  # double check: no nice mono has been set so far
false
gap> SetNiceMonomorphism(G, nice);
gap> IsBijective(IsomorphismPermGroupForMatrixGroup(G));
true

# Source(nice) <> G, not IsSurjective(nice)
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> H:=CyclicGroup(IsPcGroup, 4);;
gap> nice:=GroupHomomorphismByFunction(GL(2,3), H, x -> H.1^(4/Int(DeterminantMat(x))));;
gap> HasNiceMonomorphism(G);  # double check: no nice mono has been set so far
false
gap> SetNiceMonomorphism(G, nice);
gap> IsBijective(IsomorphismPermGroupForMatrixGroup(G));
true

#
# Verify that things that were computed as being isomorphisms
# also *know* they are isomorphisms
#
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> iso:= IsomorphismPermGroupForMatrixGroup( G );;
gap> HasIsBijective( iso );
true
gap> G:=Group(Z(3)^0*[[2,0],[0,1]]);;
gap> NiceMonomorphism( G );;
gap> iso:= IsomorphismPermGroupForMatrixGroup( G );;
gap> HasIsBijective( iso );
true

#
gap> STOP_TEST("IsomorphismPermGroupForMatrixGroup.tst");
