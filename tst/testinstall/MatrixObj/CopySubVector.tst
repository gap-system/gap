#@local l1, v1, l2, v2, v3, v4, x, src, dst, expected, from, to, len, one
#@local l3, l4
gap> START_TEST("CopySubVector.tst");

#
gap> l1 := [1,2,3,4,5,6];
[ 1, 2, 3, 4, 5, 6 ]
gap> v1 := Vector(IsPlistVectorRep, Rationals, l1);
<plist vector over Rationals of length 6>
gap> l2 := [1,1,1,2,2,2,3,3,3];
[ 1, 1, 1, 2, 2, 2, 3, 3, 3 ]
gap> v2 := Vector(IsPlistVectorRep, Rationals, l2);
<plist vector over Rationals of length 9>
gap> CopySubVector( v2, v1, [1,2,4], [2,4,6] );
gap> Unpack(v1);
[ 1, 1, 3, 1, 5, 2 ]

#
gap> l3 := [10,20,30,40,50,60];
[ 10, 20, 30, 40, 50, 60 ]
gap> CopySubVector( l1, l3, [1,3,5], [6,4,2] );
gap> l3;
[ 10, 5, 30, 3, 50, 1 ]

#
gap> CopySubVector( l1, v1, [2,4,6], [1,3,5] );
gap> Unpack(v1);
[ 2, 1, 4, 1, 6, 2 ]

#
gap> v3 := Vector(GF(5), l1*One(GF(5)));
[ Z(5)^0, Z(5), Z(5)^3, Z(5)^2, 0*Z(5), Z(5)^0 ]
gap> v4 := Vector(GF(5), l2*One(GF(5)));
[ Z(5)^0, Z(5)^0, Z(5)^0, Z(5), Z(5), Z(5), Z(5)^3, Z(5)^3, Z(5)^3 ]
gap> CopySubVector( v3, v4, [1,2,3], [2,4,6] );
gap> v4;
[ Z(5)^0, Z(5)^0, Z(5)^0, Z(5), Z(5), Z(5)^3, Z(5)^3, Z(5)^3, Z(5)^3 ]

#
gap> x := IdentityMat(72, GF(2));;
gap> src := x[72];;
gap> dst := ZeroVector(9, x[1]);;
gap> CopySubVector(src, dst, [64..71], [2..9]);
gap> List(dst{[2..9]}, IntFFE);
[ 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> src := x[64];;
gap> dst := ZeroVector(9, x[1]);;
gap> CopySubVector(src, dst, [63..70], [2..9]);
gap> List(dst{[2..9]}, IntFFE);
[ 0, 1, 0, 0, 0, 0, 0, 0 ]
gap> src := x[65];;
gap> dst := ZeroVector(9, x[1]);;
gap> CopySubVector(src, dst, [64..71], [2..9]);
gap> List(dst{[2..9]}, IntFFE);
[ 0, 1, 0, 0, 0, 0, 0, 0 ]
gap> one := One(GF(2));;
gap> src := Vector(GF(2), List([1..80], i -> one));;
gap> for from in [1,2,63,64,65] do
> for to in [1,2,3,63,64,65] do
> for len in [1,2,7,8,9,16] do
>   dst := ZeroVector(90, src);;
>   expected := ZeroVector(90, src);;
>   CopySubVector(src, dst, [from..from+len-1], [to..to+len-1]);
>   expected{[to..to+len-1]} := List([1..len], i -> one);
>   if List(dst, IntFFE) <> List(expected, IntFFE) then
>     Error("unexpected result for from=", from,
>           ", to=", to, ", len=", len);
>   fi;
> od;
> od;
> od;

#
gap> l4 := [0,0,0,0,0,0,0,0,0];
[ 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> CopySubVector( v3, l4, [1,2,3], [2,4,6] );
gap> l4;
[ 0, Z(5)^0, 0, Z(5), 0, Z(5)^3, 0, 0, 0 ]

#
gap> CopySubVector( l1, l3, [1,2], [1] );
Error, source and destination index lists must be of equal length

#
gap> STOP_TEST("CopySubVector.tst");
