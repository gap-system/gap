# Sometimes GAP was able to compute the size of an fp group but then
# for any further action failed to compute a permutation representation.
# See https://github.com/gap-system/gap/issues/5764 for the report,
# and https://github.com/gap-system/gap/pull/5770 for the fix.
gap> f := FreeGroup("a","b","c");;
gap> g := f / [ f.1*f.1*f.1,f.1*f.2*f.3*f.1*f.3^-1*f.2*f.3*f.3,f.1*f.3*f.2^-1 ];
<fp group on the generators [ a, b, c ]>
gap> Size(g);
84
gap> IdGroup(g);
[ 84, 1 ]
