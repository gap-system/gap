#2016/04/27 (FL, bug reported on support list)
gap> l := [1,,,5];;
gap> Remove(l);
5
gap> [l, Length(l)];
[ [ 1 ], 1 ]
gap> l := [,,,"x"];;
gap> Remove(l);
"x"
gap> [l, Length(l)];
[ [  ], 0 ]
gap> l := [1,2,,[],"x"];;
gap> Remove(l);
"x"
gap> [l, Length(l)];
[ [ 1, 2,, [  ] ], 4 ]
