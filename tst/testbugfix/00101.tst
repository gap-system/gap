# 2005/06/08 (SL)
gap> gamma := [[2,5],[3],[4,5],[1],[]];
[ [ 2, 5 ], [ 3 ], [ 4, 5 ], [ 1 ], [  ] ]
gap> STRONGLY_CONNECTED_COMPONENTS_DIGRAPH(gamma);
[ [ 5 ], [ 1, 2, 3, 4 ] ]
