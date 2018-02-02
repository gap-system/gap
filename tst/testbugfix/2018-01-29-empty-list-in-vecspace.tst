#
# See <https://github.com/gap-system/gap/issues/2117>
#
gap> V := GF(5)^0;;
gap> e := Enumerator(V);;
gap> Position(e, Zero(V));
1
gap> Coefficients(Basis(V), Zero(V));
[  ]

#
gap> V := GF(257)^0;;
gap> e := Enumerator(V);;
gap> Position(e, Zero(V));
1
gap> Coefficients(Basis(V), Zero(V));
[  ]
