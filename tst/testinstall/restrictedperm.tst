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
#@if 8*GAPInfo.BytesPerVariable = 64
gap> RestrictedPerm((1,2^40),[ 1, () ]);
Error, Permutation literal exceeds maximum permutation degree
#@else
gap> RestrictedPerm((1,2^40),[ 1, () ]);
Error, Permutation: <expr> must be a positive small integer (not a large posit\
ive integer)
#@fi
gap> RestrictedPerm((1,2^17),[ 1, () ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,2^17),[ 1, 2 ]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,2^17),[ 1, 2^17 ]);
(1,131072)
