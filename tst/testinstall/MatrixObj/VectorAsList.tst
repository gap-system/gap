#@local v, l, m, q
gap> START_TEST("VectorAsList.tst");

# plain lists
gap> v:= [ 1, 2, 3 ];;  l:= VectorAsList( v );
[ 1, 2, 3 ]
gap> IsMutable( l ) and not IsIdenticalObj( l, v );
true
gap> l:= VectorAsList( Immutable( v ) );;  IsMutable( l );
true
gap> VectorAsList( [] );
[  ]

# compressed vectors keep their representation; the argument is unchanged
gap> for q in [ 2, 9, 251 ] do
>      m:= ImmutableMatrix( GF(q), [ [ Z(q), 0*Z(q) ], [ 0*Z(q), Z(q)^0 ] ] );
>      for v in [ m[1], ShallowCopy( m[2] ), Immutable( ShallowCopy( m[2] ) ) ] do
>        l:= VectorAsList( v );
>        if not ( IsGF2VectorRep( l ) or Is8BitVectorRep( l ) )
>           or not IsMutable( l ) or IsLockedRepresentationVector( l )
>           or l <> v or IsIdenticalObj( l, v ) then
>          Print( "wrong result for q = ", q, "\n" );
>        fi;
>        l[1]:= Zero( GF(q) );
>      od;
>      if m[1][1] <> Z(q) then
>        Print( "argument changed for q = ", q, "\n" );
>      fi;
>    od;

# other vector objects give plain lists
gap> v:= Vector( IsPlistVectorRep, GF(9), [ Z(9), 0*Z(9) ] );;
gap> l:= VectorAsList( v );;  IsPlistRep( l ) and IsMutable( l ) and l = Unpack( v );
true
gap> v:= Vector( IsZmodnZVectorRep, Integers mod 6, [ 1, 5 ] * One( Integers mod 6 ) );;
gap> l:= VectorAsList( v );;  IsPlistRep( l ) and l = Unpack( v );
true

#
gap> STOP_TEST("VectorAsList.tst");
