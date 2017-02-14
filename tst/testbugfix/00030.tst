## bug 11 for fix 5
gap> m1:=[[0,1],[0,0]];;
gap> m2:=[[0,0],[1,0]];;
gap> m3:=[[1,0],[0,-1]];;
gap> M1:=MatrixByBlockMatrix(BlockMatrix([[1,1,m1]],2,2));;
gap> M2:=MatrixByBlockMatrix(BlockMatrix([[1,1,m2]],2,2));;
gap> M3:=MatrixByBlockMatrix(BlockMatrix([[1,1,m3]],2,2));;
gap> M4:=MatrixByBlockMatrix(BlockMatrix([[2,2,m1]],2,2));;
gap> M5:=MatrixByBlockMatrix(BlockMatrix([[2,2,m2]],2,2));;
gap> M6:=MatrixByBlockMatrix(BlockMatrix([[2,2,m3]],2,2));;
gap> L:=LieAlgebra(Rationals,[M1,M2,M3,M4,M5,M6]);
<Lie algebra over Rationals, with 6 generators>
gap> DirectSumDecomposition(L);
[ <two-sided ideal in <Lie algebra of dimension 6 over Rationals>, 
      (dimension 3)>, 
  <two-sided ideal in <Lie algebra of dimension 6 over Rationals>, 
      (dimension 3)> ]
