# 2014/09/05 (TB, reported by Benjamin Sambale)
gap> OrthogonalEmbeddings([[4]]);
rec( norms := [ 1, 1/4 ], solutions := [ [ 1 ], [ 2, 2, 2, 2 ] ], 
  vectors := [ [ 2 ], [ 1 ] ] )

# 2014/10/22 (CJ)
gap> Stabilizer(SymmetricGroup(5), [1,2,1,2,1], OnTuples) = Group([(3,5),(4,5)]);
true
