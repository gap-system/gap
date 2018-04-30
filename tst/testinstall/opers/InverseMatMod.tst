gap> START_TEST("InverseMatMod.tst");

#
gap> for d in [1..10] do
>     id:=IdentityMat(d);
>     m:=RandomUnimodularMat(d);
>     for p in [2, 251, 65537] do
>         x:=InverseMatMod(m, p);
>         Assert(0, (x*m mod p) = id);
>     od;
> od;

#
gap> STOP_TEST("InverseMatMod.tst", 1);
