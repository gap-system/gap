## bug 16-18 for fix 4
gap> AbelianInvariantsMultiplier(SL(3,2));
[ 2 ]
gap> AllPrimitiveGroups(Size,60,NrMovedPoints,[2..2499]);
[ A(5), PSL(2,5), A(5) ]
gap> ix18:=X(GF(5),1);;f:=ix18^5-1;;
gap> Discriminant(f);
0*Z(5)
