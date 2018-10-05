# Ensure OnLeftInverse preserves the mutability of its
# input arguments.
gap> m:=IdentityMat(2);
[ [ 1, 0 ], [ 0, 1 ] ]
gap> IsMutable(m);
true
gap> IsMutable(m/m);
true
gap> IsMutable(LQUO(m,m));
true
gap> IsMutable(OnRight(m,m));
true
gap> IsMutable(OnLeftInverse(m,m));
true

#
gap> MakeImmutable(m);
[ [ 1, 0 ], [ 0, 1 ] ]
gap> IsMutable(m/m);
false
gap> IsMutable(LQUO(m,m));
false
gap> IsMutable(OnRight(m,m));
false
gap> IsMutable(OnLeftInverse(m,m));
false
