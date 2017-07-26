# RepresentativeAction used to produce incorrect answers for both
# symmetric and alternating groups, with both OnTuples and OnSets, by
# producing elements outside the group.
# This bug was originally reported by Mun See Chang.
gap> RepresentativeAction(SymmetricGroup([5,7,11,15]),[7,11],[5,15],OnTuples);
(5,7)(11,15)
gap> RepresentativeAction(AlternatingGroup([5,7,11,15]),[7,11],[5,15],OnTuples);
(5,7)(11,15)
gap> RepresentativeAction(SymmetricGroup([5,7,11,15]),[7,11],[5,15],OnSets);
(5,7)(11,15)
gap> RepresentativeAction(AlternatingGroup([5,7,11,15]),[7,11],[5,15],OnSets);
(5,7)(11,15)
