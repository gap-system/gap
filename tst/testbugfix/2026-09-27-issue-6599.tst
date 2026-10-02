# Vectors and matrices built from an existing ZmodnZ vector or matrix took
# over its type, and with it the properties stored once it was immutable.
# See https://github.com/gap-system/gap/issues/6599
#@local R, z, v, w, one, zm, u
gap> START_TEST( "2026-09-27-issue-6599.tst" );

# the example from the issue, with modulus 257 instead of 7
gap> z := Vector( IsZmodnZVectorRep, Integers mod 257, [ 0, 0 ] );;
gap> MakeImmutable( z );;
gap> IsZero( z );
true
gap> IsZero( Vector( [ ZmodpZObj( 3, 257 ) ], z ) );
false

# vectors
gap> R := Integers mod 8;;
gap> z := Vector( IsZmodnZVectorRep, R, [ 0, 0 ] );;
gap> v := Vector( IsZmodnZVectorRep, R, [ 0, 1 ] );;
gap> MakeImmutable( z );; MakeImmutable( v );;
gap> [ IsZero( z ), IsZero( v ) ];
[ true, false ]
gap> List( [ Vector( [ 3, 4 ], z ), Vector( [ 1 .. 2 ], z ), z + v, z - v ],
>          IsZero );
[ false, false, false, false ]
gap> List( [ v{ [ 1 ] }, ZeroMutable( v ), 0 * v ], IsZero );
[ true, true, true ]
gap> w := ShallowCopy( z );; w[1] := 1;; IsZero( w );
false

# matrices
gap> one := IdentityMatrix( IsZmodnZMatrixRep, R, 2 );;
gap> zm := ZeroMatrix( IsZmodnZMatrixRep, R, 2, 2 );;
gap> u := Matrix( IsZmodnZMatrixRep, R, [ [ 1, 1 ], [ 0, 1 ] ] );;
gap> MakeImmutable( one );; MakeImmutable( zm );; MakeImmutable( u );;
gap> [ IsOne( one ), IsZero( zm ), IsUpperTriangularMatrix( u ) ];
[ true, true, true ]
gap> List( [ Matrix( [ [ 1, 1 ], [ 0, 1 ] ], 2, one ),
>            ExtractSubMatrix( one, [ 2, 1 ], [ 1, 2 ] ),
>            one + one, one - one ], IsOne );
[ false, false, false, false ]
gap> List( [ AdditiveInverseSameMutability( one ),
>            AdditiveInverseImmutable( one ), AdditiveInverseMutable( one ),
>            ZeroSameMutability( one ), ZeroImmutable( one ),
>            ZeroMutable( one ) ], IsOne );
[ false, false, false, false, false, false ]
gap> List( [ IdentityMatrix( 2, zm ), One( zm ), OneMutable( zm ) ], IsZero );
[ false, false, false ]
gap> w := MutableCopyMatrix( one );; w[1,2] := 1;; IsOne( w );
false
gap> IsUpperTriangularMatrix( TransposedMat( u ) );
false

# results that are documented to be mutable
gap> List( [ v{ [ 1 ] }, ExtractSubMatrix( one, [ 1 ], [ 1 ] ),
>            TransposedMatMutable( u ) ], IsMutable );
[ true, true, true ]

# row list operations
gap> IsOne( one{ [ 2, 1 ] } );
false
gap> w := ShallowCopy( one );; w[1] := w[2];; IsOne( w );
false
gap> List( [ one{ [ 1 ] }, ExtractSubMatrix( one, [ 1 ], [ 1 ] )[1] ],
>          IsMutable );
[ true, true ]

#
gap> STOP_TEST( "2026-09-27-issue-6599.tst" );
