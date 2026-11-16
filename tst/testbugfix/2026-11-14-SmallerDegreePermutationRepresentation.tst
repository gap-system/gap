# test for regular action reduction
gap> G := Image(RegularActionHomomorphism(AlternatingGroup(5)));;
gap> SetIsSimpleGroup(G, true);
gap> NrMovedPoints(Image(SmallerDegreePermutationRepresentation(G:cheap))) < 60;
true
