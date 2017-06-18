# These functions all worked incorrectly when given symmetric or alternating groups
# Which were not not defined on a domain of the form [1..n]
gap> RepresentativeAction(SymmetricGroup([5,7,11,15]),[7,11],[5,15],OnTuples);
(5,7)(11,15)
gap> RepresentativeAction(AlternatingGroup([5,7,11,15]),[7,11],[5,15],OnTuples);
(5,7)(11,15)
gap> RepresentativeAction(SymmetricGroup([5,7,11,15]),[7,11],[5,15],OnSets);
(5,7)(11,15)
gap> RepresentativeAction(AlternatingGroup([5,7,11,15]),[7,11],[5,15],OnSets);
(5,7)(11,15)
