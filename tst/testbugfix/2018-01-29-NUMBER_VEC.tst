# Fix NUMBER_GF2VEC crash if input is empty vector
# See https://github.com/gap-system/gap/issues/2121
gap> v:=[];; CONV_GF2VEC(v); v;
<a GF2 vector of length 0>
gap> NUMBER_GF2VEC(v);
1

# Fix NUMBER_VEC8BIT to return correct result for empty vector
gap> v:=[];; CONV_VEC8BIT(v,5); v;
< mutable compressed vector length 0 over GF(5) >
gap> NUMBER_VEC8BIT(v);
1
