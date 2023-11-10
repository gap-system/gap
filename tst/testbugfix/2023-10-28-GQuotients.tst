# Fix unexpected error in GQuotients.
# See https://github.com/gap-system/gap/issues/5525
#
gap> G := FreeGroup(2);;
gap> Q := G / [G.1*G.2^-2*G.1, G.1^-1*G.2^-3];;
gap> GQuotients(Q, SmallGroup(12, 1));
[  ]
