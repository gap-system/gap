# the following used to crash GAP due to infinite recursion
gap> MakeImmutable(rec(x:=~));
rec( x := ~ )

# just to be complete, also test this for plists
gap> MakeImmutable([1,~]);
[ 1, ~ ]
