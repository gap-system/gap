#############################################################################
##
#W  dt.tst
##
##  Test the (undocumented!) deep thought collector code implemented by
##  src/dt.{c,h}, src/dteval.{c,h}, lib/dt.g, lib/rwsdt.gi, lib/rwspcclt.gd
##
gap> START_TEST("dt.tst");

# simple function to create a pc group isomorphic to an unitriangular group,
# optionally using deep through polynomials.
gap> UnitriangularPcGroup := function(n, p, useDeepThought)
>     local l, f, c, gens, pairs, i, j, k, o;
>     l := n*(n-1)/2;
>     f := FreeGroup(l);
>     if useDeepThought then
>         c := DeepThoughtCollector( f, p );
>     else
>         c := SingleCollector( f, p );
>     fi;
>     gens := GeneratorsOfGroup(f);
>     pairs := ListX([1..n-1], i -> [1..n-i], {i,j} -> [j, i+j]);
>     # read of pc presentation by determining commutators of elementary matrices
>     for i in [1..l] do
>         # commutators
>         for j in [i+1..l] do
>             if pairs[i][1] = pairs[j][2] then
>                 k := Position(pairs, [pairs[j][1], pairs[i][2]]);
>                 o := gens[j]*gens[k];
>                 SetConjugate( c, j, i, o );
>             elif pairs[i][2] = pairs[j][1] then
>                 k := Position(pairs, [pairs[i][1], pairs[j][2]]);
>                 o := gens[j]*gens[k]^(p-1);
>                 SetConjugate( c, j, i, o );
>             else
>                 # commutator is trivial
>             fi;
>         od;
>     od;
>     # update the collector -- this compute the deep thought polynomials
>     UpdatePolycyclicCollector( c );
>     # translate from collector to group
>     return GroupByRws(c);
> end;;

# compute a group, once with DT, once without ...
gap> G:=UnitriangularPcGroup(5,7,false);;
gap> H:=UnitriangularPcGroup(5,7,true);;
computing deep thought polynomials  ...
done
computing generator orders  ...
done

# ... and verify the results are isomorphic
gap> IsBijective(GroupHomomorphismByImages(G,H));
true
gap> IsBijective(GroupHomomorphismByImages(H,G));
true

# Test various arithmetic properties by comparing them
# between computations with and without DT polynomials
gap> iso := GroupHomomorphismByImages(H,G);;
gap> for i in [1..100] do
>   g:=Random(H); h:=Random(H);
>   Assert(0, g^iso * h^iso = (g*h)^iso);
>   Assert(0, g^iso / h^iso = (g/h)^iso);
>   Assert(0, ForAll([-10..10], n -> (g^n)^iso = (g^iso)^n));
>   Assert(0, ForAll([-10..10], n -> IsOne(g^n * g^-n)));
>   Assert(0, ForAll([-10..10], n -> IsOne(g^-n * g^n)));
>   Assert(0, ForAll([-10..10], n -> IsOne(g^n / g^n)));
>   k:=Random(H);
>   Assert(0, g*(k*h) = (g*k)*h);
> od;

#
gap> STOP_TEST("dt.tst", 1);
