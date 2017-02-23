# 2013/08/20 (MH)
gap> G:=SmallGroup(2^7*9,33);;
gap> H:=DirectProduct(G, ElementaryAbelianGroup(2^10));;
gap> Exponent(H); # should take at most a few milliseconds
72
gap> K := PerfectGroup(2688,3);;
gap> Exponent(K); # should take at most a few seconds
168
