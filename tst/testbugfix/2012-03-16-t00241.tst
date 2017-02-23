# Reported by Burkhard Hoefling on 2012/3/14, added by SL on 2012/3/16
# SHIFT_LEFT_VEC8BIT can fail to clean space to its right, which can then
# be picked up by a subsequent add to a longer vector
gap> v := [0*Z(4), 0*Z(4), 0*Z(4), 0*Z(4), Z(4)];
[ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2^2) ]
gap> ConvertToVectorRep (v, 4);
4
gap> SHIFT_VEC8BIT_LEFT(v,1);
gap> w := [0*Z(4), 0*Z(4), 0*Z(4), 0*Z(4),0*Z(4), 0*Z(4), Z(4)];
[ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2), Z(2^2) ]
gap> ConvertToVectorRep (w, 4);
4
gap> v+w; 
[ 0*Z(2), 0*Z(2), 0*Z(2), Z(2^2), 0*Z(2), 0*Z(2), Z(2^2) ]
