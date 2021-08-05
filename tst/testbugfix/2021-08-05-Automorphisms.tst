# Fix GitHub issue #4624   (second issue), reported by Graham Erskine
# When extending the series, must reduce radical automorphisms to valid ones
gap> G:=Group([(1,2,3)(4,5,6),(1,7,5)(2,9,4)(3,8,6),
> (10,14,26)(11,24,13)(12,21,15)(16,20,22)(17,27,19)(18,25,23),
> (10,11,16)(12,25,23)(13,20,26)(14,24,22)(15,18,27)]);;
gap> Size(AutomorphismGroup(G));
8571080448
