gap> START_TEST("TriangulizedMat.tst");

#
gap> a:=[];;
gap> b:=TriangulizedMat(a);
[  ]
gap> a = [];
true
gap> IsIdenticalObj(a, b);
false

#
gap> a:=[[42]];;
gap> b:=TriangulizedMat(a);
[ [ 1 ] ]
gap> a = [[42]];
true

#
gap> a:=[[Z(7)]];;
gap> b:=TriangulizedMat(a);
[ [ Z(7)^0 ] ]
gap> a = [[Z(7)]];
true

#
gap> TriangulizedMat([[1,2],[3,4]]);
[ [ 1, 0 ], [ 0, 1 ] ]
gap> TriangulizedMat([[1,2],[3,6]]);
[ [ 1, 2 ], [ 0, 0 ] ]

#
gap> STOP_TEST("TriangulizedMat.tst", 1);
