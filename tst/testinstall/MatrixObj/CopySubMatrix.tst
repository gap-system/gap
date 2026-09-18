#@local m1, m2, m3, m4, m5, AsDummyMatrix, DummyMatrixAsList
gap> START_TEST("CopySubMatrix.tst");
gap> DeclareRepresentation( "IsDummyCopySubMatrixRep6305",
>      IsComponentObjectRep and IsAttributeStoringRep and IsMatrixObj, [] );
gap> InstallMethod( BaseDomain,
>      [ IsDummyCopySubMatrixRep6305 ],
>      M -> M!.basedomain );
gap> InstallMethod( NumberRows,
>      [ IsDummyCopySubMatrixRep6305 ],
>      M -> Length( M!.entries ) );
gap> InstallMethod( NumberColumns,
>      [ IsDummyCopySubMatrixRep6305 ],
>      M -> Length( M!.entries[1] ) );
gap> InstallMethod( \[\],
>      [ IsDummyCopySubMatrixRep6305, IsPosInt, IsPosInt ],
>      function( M, row, col )
>        return M!.entries[row][col];
>      end );
gap> InstallMethod( \[\]\:\=,
>      [ IsDummyCopySubMatrixRep6305 and IsMutable, IsPosInt, IsPosInt, IsObject ],
>      function( M, row, col, obj )
>        M!.entries[row][col] := obj;
>      end );
gap> AsDummyMatrix := function( entries, mutable )
>      local filt, M;
>      filt := IsDummyCopySubMatrixRep6305;
>      if mutable then
>        filt := filt and IsMutable;
>      fi;
>      M := Objectify(
>        NewType( CollectionsFamily( CollectionsFamily( FamilyObj( Zero( Rationals ) ) ) ),
>                 filt ),
>        rec(
>          basedomain := Rationals,
>          entries := StructuralCopy( entries ) ) );
>      if not mutable then
>        MakeImmutable( M!.entries );
>      fi;
>      return M;
>    end;;
gap> DummyMatrixAsList := function( M )
>      return List( [ 1 .. NumberRows( M ) ],
>                   i -> List( [ 1 .. NumberColumns( M ) ], j -> M[i, j] ) );
>    end;;

#
gap> m1 := [ [ 1, 2, 3 ], [ 4, 5, 6 ] ];
[ [ 1, 2, 3 ], [ 4, 5, 6 ] ]
gap> m2 := [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ];
[ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ]
gap> CopySubMatrix( m1, m2, [ 2, 1 ], [ 1, 3 ], [ 3, 1 ], [ 2, 4 ] );
gap> m2;
[ [ 0, 6, 0, 4 ], [ 0, 0, 0, 0 ], [ 0, 3, 0, 1 ] ]

#
gap> m3 := AsDummyMatrix(
>      [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ], true );;
gap> CopySubMatrix( m1, m3, [ 1, 2 ], [ 2, 3 ], [ 2, 3 ], [ 4, 1 ] );
gap> DummyMatrixAsList(m3);
[ [ 0, 0, 0, 0 ], [ 3, 0, 0, 2 ], [ 6, 0, 0, 5 ] ]

#
gap> m4 := [ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ];
[ [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ], [ 0, 0, 0, 0 ] ]
gap> CopySubMatrix( m3, m4, [ 3, 2 ], [ 1, 2 ], [ 1, 4 ], [ 3, 2 ] );
gap> m4;
[ [ 0, 5, 6, 0 ], [ 0, 2, 3, 0 ], [ 0, 0, 0, 0 ] ]

#
gap> m5 := AsDummyMatrix( m1, false );;
gap> CopySubMatrix( m5, m4, [ 2, 1 ], [ 2, 3 ], [ 2, 1 ], [ 1, 4 ] );
gap> m4;
[ [ 0, 5, 6, 0 ], [ 5, 2, 3, 4 ], [ 2, 0, 0, 1 ] ]

#
gap> CopySubMatrix( m5, m4, [ 1, 2 ], [ 1 ], [ 1 ], [ 1 ] );
Error, source and destination row lists must be of equal length

#
gap> CopySubMatrix( m5, m4, [ 1 ], [ 1 ], [ 1, 2 ], [ 1 ] );
Error, source and destination column lists must be of equal length

# IsGF2MatrixRep
gap> m1 := IdentityMatrix( IsPlistMatrixRep, Rationals, 10 );
<10x10-matrix over Rationals>
gap> m2 := ZeroMatrix( 6, 6, m1 );
<6x6-matrix over Rationals>
gap> CopySubMatrix( m1, m2, [ 1..3 ], [ 3..5 ], [ 2..4 ], [ 4..6 ] );
gap> IsOne(m1);
true
gap> Display(m2);
<6x6-matrix over Rationals:
[[ 0, 0, 0, 0, 0, 0 ]
 [ 0, 0, 0, 0, 0, 0 ]
 [ 0, 0, 0, 0, 0, 0 ]
 [ 0, 0, 0, 1, 0, 0 ]
 [ 0, 0, 0, 0, 1, 0 ]
 [ 0, 0, 0, 0, 0, 0 ]
]>

# IsGF2MatrixRep
gap> m1 := IdentityMatrix( GF(2), 10 );
<a 10x10 matrix over GF2>
gap> m2 := ZeroMatrix( 6, 6, m1 );
<a 6x6 matrix over GF2>
gap> CopySubMatrix( m1, m2, [ 1..3 ], [ 3..5 ], [ 2..4 ], [ 4..6 ] );
gap> IsOne(m1);
true
gap> Display(m2);
 . . . . . .
 . . . . . .
 . . . . . .
 . . . 1 . .
 . . . . 1 .
 . . . . . .

# Is8BitMatrixRep
gap> m1 := IdentityMatrix( GF(3), 10 );
< mutable compressed matrix 10x10 over GF(3) >
gap> m2 := ZeroMatrix( 6, 6, m1 );
< mutable compressed matrix 6x6 over GF(3) >
gap> CopySubMatrix( m1, m2, [ 1..3 ], [ 3..5 ], [ 2..4 ], [ 4..6 ] );
gap> IsOne(m1);
true
gap> Display(m2);
 . . . . . .
 . . . . . .
 . . . . . .
 . . . 1 . .
 . . . . 1 .
 . . . . . .

#
gap> STOP_TEST("CopySubMatrix.tst");
