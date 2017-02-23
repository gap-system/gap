# 2006/03/02 (AH)
gap> x_1:=X(Rationals,"x_1":old);;
gap> x_2:=X(Rationals,"x_2":old);;
gap> x_3:=X(Rationals,"x_3":old);;
gap> x_4:=X(Rationals,"x_4":old);;
gap> x_5:=X(Rationals,"x_5":old);;
gap> L:=[(x_3+x_4)*x_5-x_1,(x_3+x_4)*x_4-x_2,x_5^2+x_4^2-1];;
gap> ReducedGroebnerBasis(L,MonomialLexOrdering([x_1,x_2,x_3,x_4,x_5]));
[ x_4^2+x_5^2-1, -x_3*x_4+x_5^2+x_2-1, -x_3*x_5-x_4*x_5+x_1 ]
gap> ReducedGroebnerBasis(L,MonomialLexOrdering([x_4,x_5,x_1,x_2,x_3]));
[ x_1^4+2*x_1^2*x_2^2-x_1^2*x_3^2+x_2^4-x_2^2*x_3^2-2*x_1^2*x_2-2*x_2^3+x_2^2,
  -x_1^3-x_1*x_2^2+x_1*x_3^2+x_2*x_3*x_5+x_1*x_2, 
  x_1^2*x_2+x_1*x_3*x_5+x_2^3-x_2*x_3^2-x_1^2-2*x_2^2+x_2, 
  x_1^2*x_5+x_2^2*x_5-x_1*x_3-x_2*x_5, -x_1^2-x_2^2+x_3^2+x_5^2+2*x_2-1, 
  -x_1^2-x_2^2+x_3^2+x_3*x_4+x_2, x_1*x_5+x_2*x_4-x_3-x_4, x_1*x_4-x_2*x_5, 
  x_3*x_5+x_4*x_5-x_1, x_1^2+x_2^2-x_3^2+x_4^2-2*x_2 ]
