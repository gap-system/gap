# Issue related to MagmaWith[One|Inverses] with family specified
#
gap> MagmaWithOne(CollectionsFamily(PermutationsFamily), [(1,2),(1,2,3)]);
Group([ (1,2), (1,2,3) ])
gap> Elements(last);
[ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ]
gap> MagmaWithInverses(CollectionsFamily(PermutationsFamily), [(1,2),(1,2,3)]);
Group([ (1,2), (1,2,3) ])
gap> Elements(last);
[ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ]
