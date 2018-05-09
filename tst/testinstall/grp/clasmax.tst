#
gap> List(ClassicalMaximals("L",3,2), Size);
[ 24, 24, 21 ]
gap> List(ClassicalMaximals("L",3,3), Size);
[ 432, 432, 39, 24 ]
gap> ClassicalMaximals("L",3,4);
fail
gap> ClassicalMaximals("L",3,9);
fail
gap> ClassicalMaximals("L",13,3);
fail
gap> ClassicalMaximals("U",3,3);
fail

#
gap> for d in [1..10] do
>   for p in [2,3,5,7,11] do
>     m := RandomInvertibleMat(d, GF(p));;
>     m := List(m, r->List(r,Int));
>     m2 := UncompressStrMat(CompresStrMat(m,p),p);
>     Assert(0, m = m2);
>   od;
> od;
