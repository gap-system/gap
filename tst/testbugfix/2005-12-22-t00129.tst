# 2005/12/22 (Robert F. Morse)
# 2011/09/13 (Updated by AK as suggested by JM)
# 2013/09/04 (Updated by JM)
gap> t:=Transformation([1,2,3,3]);;
gap> s:=FullTransformationSemigroup(4);;
gap> ld:=GreensDClassOfElement(FullTransformationSemigroup(4),
> Transformation([1,2,3,3]));;
gap> rs:=AssociatedReesMatrixSemigroupOfDClass(ld);;
gap> mat:=MatrixOfReesZeroMatrixSemigroup(rs);;
gap> Length(mat);
4
gap> t:=UnderlyingSemigroupOfReesMatrixSemigroup(rs);;
gap> List(mat, x-> [Size(x), Number(x, y-> y=0)]);
[ [ 6, 3 ], [ 6, 3 ], [ 6, 3 ], [ 6, 3 ] ]
gap> Size(UnderlyingSemigroupOfReesZeroMatrixSemigroup(rs));
6
