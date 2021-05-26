# https://github.com/gap-system/gap/issues/4030
#
gap> T := [
>   [ 1, 2, 6, 5, 4, 3 ],
>   [ 2, 1, 4, 2, 2, 5 ],
>   [ 6, 5, 1, 6, 6, 4 ],
>   [ 5, 6, 3, 4, 1, 2 ],
>   [ 4, 3, 2, 1, 5, 6 ],
>   [ 3, 4, 5, 3, 3, 1 ]
> ];;
gap> M := MagmaByMultiplicationTable(T);
<magma with 6 generators>
gap> IsAssociative(M);
false
gap> AsSemigroup(M);
fail
gap> M := MagmaByMultiplicationTable(T);
<magma with 6 generators>
gap> AsSemigroup(M);
fail
gap> AsSemigroup(Elements(M));
fail

#
gap> T := [
>   [ 1, 2, 3, 4, 5 ],
>   [ 2, 2, 2, 5, 5 ],
>   [ 3, 2, 3, 4, 5 ],
>   [ 4, 2, 4, 3, 5 ],
>   [ 5, 2, 5, 2, 5 ]
> ];;
gap> M := MagmaByMultiplicationTable(T);
<magma with 5 generators>
gap> IsAssociative(M);
true
gap> S := AsSemigroup(M);;
gap> IsSemigroup(S);
true
gap> Size(S);
5
gap> M := MagmaByMultiplicationTable(T);
<magma with 5 generators>
gap> S := AsSemigroup(M);;
gap> IsSemigroup(S);
true
gap> Size(S);
5
gap> S := AsSemigroup(Elements(M));;
gap> IsSemigroup(S);
true
gap> Size(S);
5
