# Verify that Orbits works when the given seeds are a range
# See https://github.com/gap-system/gap/issues/5056
gap> act := function(omega,g) return PowerModInt(omega,Int(g),15); end;;
gap> ugrp := Units(ZmodnZ(Phi(15)));
<group of size 4 with 2 generators>
gap> orbs := Orbits(ugrp,[1..5],act);
[ [ 1 ], [ 2, 8 ], [ 3, 12 ], [ 4 ], [ 5 ] ]
