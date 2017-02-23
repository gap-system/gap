# 2013/11/19 (AK)
gap> rel := BinaryRelationOnPoints([[2,3],[4,5],[4,5],[6],[6],[]]);
Binary Relation on 6 points
gap> rel := ReflexiveClosureBinaryRelation(TransitiveClosureBinaryRelation(rel));
Binary Relation on 6 points
gap> IsLatticeOrderBinaryRelation(rel);
false
gap> rel := BinaryRelationOnPoints([[2,3],[4,5],[4],[6],[6],[]]);
Binary Relation on 6 points
gap> rel := ReflexiveClosureBinaryRelation(TransitiveClosureBinaryRelation(rel));
Binary Relation on 6 points
gap> IsLatticeOrderBinaryRelation(rel);
true
