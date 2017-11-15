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
Error, Permutation literal exceeds maximum permutation degree -- 1099511627776\
 vs 4294967295
gap> RestrictedPerm((1,2^17),[ 1, () ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,2^17),[ 1, 2 ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,2^17),[ 1, 2^17 ]);
(1,131072)
