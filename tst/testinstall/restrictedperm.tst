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

# Check behaviour on ranges
gap> RestrictedPerm((1,3,5,7)(2,4,6,8)(9,10,11,12),[2,4..8]);
(2,4,6,8)
gap> RestrictedPerm((1,3,5,7)(2,4,6,8)(9,10,11,12),[8,6..2]);
(2,4,6,8)
gap> RestrictedPerm((1,3,5,7)(2,4,6,8)(9,10,11,12),[9,10..12]);
(9,10,11,12)
gap> RestrictedPerm((1,3,5,7)(2,4,6,8)(9,10,11,12),[12,11..9]);
(9,10,11,12)

# Check error / bounds checking on ranges
gap> RestrictedPerm((1,2),[2,4..6]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((2,4),[2,4..6]);
(2,4)
gap> RestrictedPerm((4,6),[2,4..6]);
(4,6)
gap> RestrictedPerm((6,7),[2,4..6]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((6,7),[6,4..2]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((4,6),[6,4..2]);
(4,6)
gap> RestrictedPerm((2,4),[6,4..2]);
(2,4)
gap> RestrictedPerm((1,2),[6,4..2]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>

# Check handling of negative inputs (and boundary cases)
gap> RestrictedPerm((2,4),[-4,-2..4]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((2,4),[4,2..-4]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((1,5),[1,3..7]);
(1,5)
gap> RestrictedPerm((1,5),[7,5..1]);
(1,5)
gap> RestrictedPerm((2,4),[0,2..6]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
gap> RestrictedPerm((2,4),[6,4..0]);
Error, <g> must be a permutation and <D> a plain list or range,
   consisting of a union of cycles of <g>
