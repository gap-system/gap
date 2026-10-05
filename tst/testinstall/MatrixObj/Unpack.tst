#@local l, ll, m, q, u, v, v1, v5
gap> START_TEST("Unpack.tst");
gap> ll := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, ll);
<plist vector over Rationals of length 6>
gap> Unpack( v1 );
[ 1, 2, 3, 4, 5, 6 ]
gap> v5 := Vector(GF(5), ll*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> Unpack( v5 );
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]

#
# compressed vectors and matrices: the result is a new mutable plain list,
# the argument keeps its representation, mutability and lock
#
gap> for q in [ 2, 4, 251 ] do
>      l:= [ [ Z(q), 0*Z(q), Z(q)^0 ], [ 0*Z(q), Z(q)^0, Z(q) ] ];
>      m:= ImmutableMatrix( GF(q), l );
>      for v in [ m[1], ShallowCopy( m[2] ), Immutable( ShallowCopy( m[2] ) ) ] do
>        u:= Unpack( v );
>        if not IsPlistRep( u ) or not IsMutable( u ) or u <> v
>           or not IsDataObjectRep( v ) then
>          Print( "wrong result for q = ", q, "\n" );
>        fi;
>        u[1]:= Zero( GF(q) );
>      od;
>      if not IsLockedRepresentationVector( m[1] ) or m[1][1] <> Z(q) then
>        Print( "argument changed for q = ", q, "\n" );
>      fi;
>      u:= Unpack( m );
>      if u <> l or not ForAll( u, r -> IsPlistRep( r ) and IsMutable( r ) )
>         or not IsMutable( u ) then
>        Print( "wrong matrix result for q = ", q, "\n" );
>      fi;
>    od;

#
gap> STOP_TEST("Unpack.tst");
