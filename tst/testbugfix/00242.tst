# Reported by Burkhard Hoefling on 2012/3/17, added by SL on 2012/3/17
# Converting a compressed vector of length 0 to a bigger field failed.
gap> v := [0*Z(3)];
[ 0*Z(3) ]
gap> ConvertToVectorRep(v);
3
gap> Unbind(v[1]);
gap> ConvertToVectorRep(v,9);
9
