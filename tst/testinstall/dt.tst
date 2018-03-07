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
#
#
gap> famG:=ElementsFamily(FamilyObj(G));
<Family: "MultiplicativeElementsWithInversesFamilyBy8BitsSingleCollector(...)"\
>
gap> collG:=famG!.rewritingSystem;
<<up-to-date single collector, 8 Bits>>
gap> Rules(collG);
[ f1^7, f2^7, f3^7, f4^7, f5^7, f6^7, f7^7, f8^7, f9^7, f10^7, 
  f1^-1*f2*f1*f5^-6*f2^-1, f1^-1*f3*f1*f3^-1, f2^-1*f3*f2*f6^-6*f3^-1, 
  f1^-1*f4*f1*f4^-1, f2^-1*f4*f2*f4^-1, f3^-1*f4*f3*f7^-6*f4^-1, 
  f1^-1*f5*f1*f5^-1, f2^-1*f5*f2*f5^-1, f3^-1*f5*f3*f8^-1*f5^-1, 
  f4^-1*f5*f4*f5^-1, f1^-1*f6*f1*f8^-6*f6^-1, f2^-1*f6*f2*f6^-1, 
  f3^-1*f6*f3*f6^-1, f4^-1*f6*f4*f9^-1*f6^-1, f5^-1*f6*f5*f6^-1, 
  f1^-1*f7*f1*f7^-1, f2^-1*f7*f2*f9^-6*f7^-1, f3^-1*f7*f3*f7^-1, 
  f4^-1*f7*f4*f7^-1, f5^-1*f7*f5*f10^-6*f7^-1, f6^-1*f7*f6*f7^-1, 
  f1^-1*f8*f1*f8^-1, f2^-1*f8*f2*f8^-1, f3^-1*f8*f3*f8^-1, 
  f4^-1*f8*f4*f10^-1*f8^-1, f5^-1*f8*f5*f8^-1, f6^-1*f8*f6*f8^-1, 
  f7^-1*f8*f7*f8^-1, f1^-1*f9*f1*f10^-6*f9^-1, f2^-1*f9*f2*f9^-1, 
  f3^-1*f9*f3*f9^-1, f4^-1*f9*f4*f9^-1, f5^-1*f9*f5*f9^-1, f6^-1*f9*f6*f9^-1, 
  f7^-1*f9*f7*f9^-1, f8^-1*f9*f8*f9^-1, f1^-1*f10*f1*f10^-1, 
  f2^-1*f10*f2*f10^-1, f3^-1*f10*f3*f10^-1, f4^-1*f10*f4*f10^-1, 
  f5^-1*f10*f5*f10^-1, f6^-1*f10*f6*f10^-1, f7^-1*f10*f7*f10^-1, 
  f8^-1*f10*f8*f10^-1, f9^-1*f10*f9*f10^-1 ]

#
gap> famH:=ElementsFamily(FamilyObj(H));
<Family: "MultiplicativeElementsWithInversesFamilyByPolycyclicCollector(...)">
gap> collH:=famH!.rewritingSystem;
<< deep thought collector >>
gap> Rules(collH);
[ f1^7, f2^7, f3^7, f4^7, f5^7, f6^7, f7^7, f8^7, f9^7, f10^7, 
  f1^-1*f2*f1*f5^-6*f2^-1, f1^-1*f3*f1*f3^-1, f2^-1*f3*f2*f6^-6*f3^-1, 
  f1^-1*f4*f1*f4^-1, f2^-1*f4*f2*f4^-1, f3^-1*f4*f3*f7^-6*f4^-1, 
  f1^-1*f5*f1*f5^-1, f2^-1*f5*f2*f5^-1, f3^-1*f5*f3*f8^-1*f5^-1, 
  f4^-1*f5*f4*f5^-1, f1^-1*f6*f1*f8^-6*f6^-1, f2^-1*f6*f2*f6^-1, 
  f3^-1*f6*f3*f6^-1, f4^-1*f6*f4*f9^-1*f6^-1, f5^-1*f6*f5*f6^-1, 
  f1^-1*f7*f1*f7^-1, f2^-1*f7*f2*f9^-6*f7^-1, f3^-1*f7*f3*f7^-1, 
  f4^-1*f7*f4*f7^-1, f5^-1*f7*f5*f10^-6*f7^-1, f6^-1*f7*f6*f7^-1, 
  f1^-1*f8*f1*f8^-1, f2^-1*f8*f2*f8^-1, f3^-1*f8*f3*f8^-1, 
  f4^-1*f8*f4*f10^-1*f8^-1, f5^-1*f8*f5*f8^-1, f6^-1*f8*f6*f8^-1, 
  f7^-1*f8*f7*f8^-1, f1^-1*f9*f1*f10^-6*f9^-1, f2^-1*f9*f2*f9^-1, 
  f3^-1*f9*f3*f9^-1, f4^-1*f9*f4*f9^-1, f5^-1*f9*f5*f9^-1, f6^-1*f9*f6*f9^-1, 
  f7^-1*f9*f7*f9^-1, f8^-1*f9*f8*f9^-1, f1^-1*f10*f1*f10^-1, 
  f2^-1*f10*f2*f10^-1, f3^-1*f10*f3*f10^-1, f4^-1*f10*f4*f10^-1, 
  f5^-1*f10*f5*f10^-1, f6^-1*f10*f6*f10^-1, f7^-1*f10*f7*f10^-1, 
  f8^-1*f10*f8*f10^-1, f9^-1*f10*f9*f10^-1 ]

#
gap> STOP_TEST("dt.tst", 1);
