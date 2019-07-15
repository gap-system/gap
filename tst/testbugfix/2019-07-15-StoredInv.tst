# When TRIM_PERM causes a permutation 'p' to change TNAM, the stored inverse
# must be cleared, as the stored inverse of 'p' must have the
# same TNAM as 'p'

# Make p a Perm4
gap> p := (1,2,3,4)*(2^16,2^16+1)*(2^16,2^16+1);
(1,2,3,4)
gap> IsPerm4Rep(p);
true

# Force inverse calculation
gap> q := p^-1;
(1,4,3,2)
gap> IsPerm4Rep(q);
true

# Now trim
gap> TRIM_PERM(p, 4);
gap> IsPerm2Rep(p);
true

# Check inverse is also a perm2
gap> IsPerm2Rep(p^-1);
true

# But this has not changed q
gap> IsPerm4Rep(q);
true

# and it's inverse is the correct type
gap> IsPerm4Rep(q^-1);
true

# Check some calculations that use the inverse
gap> List([1..5], x -> x/p);
[ 4, 1, 2, 3, 5 ]

# And on q (to ensure it's inverse is not still 'p')
gap> List([1..5], x -> x/q);
[ 2, 3, 4, 1, 5 ]
