# bug reported by David Roe on the GAP Forum: the command
#   AutomorphismGroup(TransitiveGroup(45, 3878));
# sometimes gives a result that is too small. Traced back to
# a bug in MTX.ModuleAutomorphisms
gap> mats:=Z(3)^0*[
> [ [ 0, 0, 0, 2, 0, 0, 0, 1, 0, 1, 0 ],
>   [ 0, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0 ],
>   [ 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0 ],
>   [ 0, 0, 0, 1, 0, 2, 0, 1, 0, 0, 0 ],
>   [ 0, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0 ],
>   [ 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0 ],
>   [ 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0 ],
>   [ 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 1 ],
>   [ 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 0 ],
>   [ 0, 0, 1, 0, 0, 0, 0, 2, 0, 0, 0 ],
>   [ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0 ] ],
> [ [ 0, 0, 0, 0, 2, 0, 1, 0, 0, 1, 0 ],
>   [ 0, 0, 1, 0, 2, 0, 1, 2, 0, 2, 0 ],
>   [ 0, 0, 0, 1, 0, 0, 1, 1, 0, 2, 0 ],
>   [ 0, 0, 0, 0, 2, 0, 1, 0, 2, 2, 0 ],
>   [ 0, 0, 0, 0, 2, 0, 2, 2, 0, 2, 0 ],
>   [ 0, 0, 0, 0, 0, 2, 1, 1, 0, 1, 0 ],
>   [ 0, 0, 0, 0, 1, 0, 1, 1, 0, 2, 1 ],
>   [ 1, 0, 0, 0, 1, 0, 2, 1, 0, 2, 0 ],
>   [ 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0 ],
>   [ 0, 2, 0, 0, 1, 0, 1, 2, 0, 0, 0 ],
>   [ 0, 0, 0, 0, 0, 0, 2, 1, 0, 0, 0 ] ]
> ];;
gap> m:=GModuleByMats(mats,GF(3));;
gap> MTX.ModuleAutomorphisms(m);
<matrix group of size 2 with 2 generators>
gap> MTX.ModuleAutomorphisms(m);
<matrix group of size 2 with 2 generators>
gap> MTX.ModuleAutomorphisms(m);
<matrix group of size 2 with 2 generators>
gap> MTX.ModuleAutomorphisms(m);
<matrix group of size 2 with 2 generators>
gap> MTX.ModuleAutomorphisms(m);
<matrix group of size 2 with 2 generators>
