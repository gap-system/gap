#@local l, M, q
gap> START_TEST("ImmutableMatrix.tst");

#
# ImmutableMatrix compresses rows that are vector objects
#
gap> for q in [ 2, 9, 257 ] do
>      l:= [ NewVector( IsPlistVectorRep, GF(q), [ Z(q), 0*Z(q) ] ),
>            NewVector( IsPlistVectorRep, GF(q), [ 0*Z(q), Z(q)^0 ] ) ];
>      for M in [ ImmutableMatrix( GF(q), l ),
>                 ImmutableMatrix( GF(q), List( l, Immutable ) ) ] do
>        if M <> ImmutableMatrix( GF(q), List( l, Unpack ) ) or IsMutable( M )
>           or ( q < 257 and not ( IsGF2MatrixRep( M ) or Is8BitMatrixRep( M ) ) )
>        then
>          Print( "wrong result for q = ", q, "\n" );
>        fi;
>      od;
>    od;

#
gap> STOP_TEST("ImmutableMatrix.tst");
