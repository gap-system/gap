# GAP used to set the IsFinitelyGeneratedGroup property for every finitely
# generated magma-with-inverses, even those which are not groups.
gap> A:=[[1,2,3,4],[2,1,4,2],[3,4,1,3],[4,2,3,1]];
[ [ 1, 2, 3, 4 ], [ 2, 1, 4, 2 ], [ 3, 4, 1, 3 ], [ 4, 2, 3, 1 ] ]
gap> M:=MagmaWithInversesByMultiplicationTable(A);
<magma-with-inverses with 4 generators>
gap> IsFinitelyGeneratedGroup(M);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `IsFinitelyGeneratedGroup' on 1 argument\
s
gap> IsGroup(M);
false
