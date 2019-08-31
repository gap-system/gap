# Fix a bug in `MinimalFaithfulPermutationDegree`, #3636
gap> D:=DirectProduct(AlternatingGroup(5),SmallGroup(46,1));;
gap> D:=Image(IsomorphismPermGroup(D));;
gap> D:=Image(SmallerDegreePermutationRepresentation(D));;
gap> MinimalFaithfulPermutationDegree(D);
28
