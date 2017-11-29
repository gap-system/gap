#
gap> NumeratorRat(1/2);
1
gap> DenominatorRat(1/2);
2
gap> Rat(1/2) = 1/2;
true
gap> Rat(1) = 1;
true
gap> Rat(0.5) = 1/2;
true
gap> Rat("1/2");
1/2
gap> Rat("0.565");
113/200
gap> Rat("3-5");
fail
gap> Rat(3.7e-1);                                                  
37/100

#
