# Fix inconsistent error handling in DeterminantMat, see #5264

gap> DeterminantMat([[1,2,1],[0,1,1],[1,0,1,1]]);
Error, DeterminantMat: <mat> must be a nonempty square matrix
gap> DeterminantMat([[1,2,1],[0,1,1],[1,0]]);
Error, DeterminantMat: <mat> must be a nonempty square matrix
gap> DeterminantMat([ [ Z(2)^0, 0*Z(2), Z(2)^0 ],
>   [ Z(2)^0, Z(2)^0, Z(2)^0 ],
>   [ Z(2)^0, Z(2)^0 ] ]);
Error, DeterminantMat: <mat> must be a nonempty square matrix
