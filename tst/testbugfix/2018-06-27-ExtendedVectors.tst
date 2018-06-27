# ExtendedVectors was relying on some specific internal behavior
# of vector space enumerators; but that was brittle, as a change in
# rank can lead to a different enumerator being installed. Make sure
# this is not the case anymore

# This is how you are "supposed" to call ExtendedVectors
gap> V:=GF(3)^0;;
gap> Enumerator(V);
<enumerator of ( GF(3)^0 )>
gap> ExtendedVectors(V);
A( ( GF(3)^0 ) )

# This is what happens if somehow a different enumerator gets installed
gap> V:=GF(3)^0;;
gap> SetEnumerator(V, Immutable( [ Zero( V ) ] ));
gap> Enumerator(V);
[ [  ] ]
gap> ExtendedVectors(V);
A( ( GF(3)^0 ) )
