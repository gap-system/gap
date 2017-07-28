# Fixes https://github.com/gap-system/gap/issues/826
# Modified BlownUpMat to return fail for invalid input
gap> BlownUpMat(Basis(CF(4)), [[1]]);
[ [ 1, 0 ], [ 0, 1 ] ]
gap> BlownUpMat(Basis(CF(4)), [[E(4)]]);
[ [ 0, 1 ], [ -1, 0 ] ]
gap> BlownUpMat(Basis(CF(4)), [[Sqrt(2)]]);
fail

# Simplified version of example from issue #826
gap> i:=E(4);;
gap> S:=((1+i)/Sqrt(2))*DiagonalMat([i,i,1,1]);;
gap> T:=((1+i)/2)*[[-i,0,0,i],[0,1,1,0],[1,0,0,1],[0,-i,i,0]];;
gap> g:=Group(T);;
gap> Order(g);
10
gap> S in g;
false
