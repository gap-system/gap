# RestrictedPerm misbehaved when given non-integer values
gap> RestrictedPerm((1,2),[ [] ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,2),[ 1, () ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((),[ 1, () ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((),[ 1, 0 ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,2^40),[ 1, () ]);
Error, Permutation: <expr> must be a positive integer (not a integer (>= 2^28)\
)
gap> RestrictedPerm((1,2^17),[ 1, () ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,2^17),[ 1, 2 ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,2^17),[ 1, 2^17 ]);
(1,131072)
