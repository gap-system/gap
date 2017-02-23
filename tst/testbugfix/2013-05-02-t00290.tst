# 2013/05/02 (BH)
gap> a := IntHexString("0000000000000000000000");
0
gap> a = 0;
true
gap> IsSmallIntRep(a);
true
gap> a := IntHexString("0000000000000000000001");
1
gap> a = 1;
true
gap> IsSmallIntRep(a);
true
