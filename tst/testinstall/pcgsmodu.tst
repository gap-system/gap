#@local BruteTail,G,M,N,P,U,elms,hom,iso,p,pcgs
gap> START_TEST("pcgsmodu.tst");

# the smallest position from which on <pcgs> generates an elementary abelian
# group
gap> BruteTail := function(pcgs)
>   local ro, t;
>   ro := RelativeOrders(pcgs);
>   t := Length(pcgs) + 1;
>   while t > 1 and IsPrimeInt(ro[t-1]) and ro[t-1] = Last(ro)
>         and IsOne(pcgs[t-1]^ro[t-1])
>         and ForAll([t .. Length(pcgs)], k -> IsOne(Comm(pcgs[t-1], pcgs[k]))) do
>     t := t - 1;
>   od;
>   return t;
> end;;

# family pcgs
gap> ForAll(AllSmallGroups(2^5),
>      G -> IndexOfElementaryAbelianTail(Pcgs(G)) = BruteTail(Pcgs(G)));
true
gap> P := Image(EpimorphismPGroup(FreeGroup(2), 3, 5));;
gap> pcgs := Pcgs(P);;
gap> [ Length(pcgs), IndexOfElementaryAbelianTail(pcgs), BruteTail(pcgs) ];
[ 32, 19, 19 ]

# induced pcgs
gap> U := Subgroup(P, [ pcgs[2], pcgs[12], pcgs[20] * pcgs[25] ]);;
gap> BruteTail(InducedPcgs(pcgs, U))
>    <= IndexOfElementaryAbelianTail(InducedPcgs(pcgs, U));
true

# pcgs with known elementary abelian steps
gap> pcgs := PcgsElementaryAbelianSeries(SymmetricGroup(4));;
gap> IndexOfElementaryAbelianTail(pcgs);
3
gap> IdGroup(PcGroupWithPcgs(pcgs));
[ 24, 12 ]

# a central denominator in the elementary abelian tail, which is not a tail
gap> pcgs := Pcgs(P);;
gap> N := NormalClosure(P, [ pcgs[19] * pcgs[21], pcgs[26] ]);;
gap> M := pcgs mod InducedPcgs(pcgs, N);;
gap> IsDenominatorInElementaryAbelianTailRep(M);
true
gap> elms := List([1 .. 50], i -> Random(P));;
gap> ForAll(elms, g -> ForAll(ExponentsOfPcElement(M, g), e -> e in [0 .. 2])
>      and LeftQuotient(PcElementByExponents(M, ExponentsOfPcElement(M, g)), g)
>          in N);
true
gap> hom := NaturalHomomorphismByNormalSubgroup(P, N);;
gap> ForAll(GeneratorsOfGroup(N), x -> IsOne(ImagesRepresentative(hom, x)));
true
gap> ForAll(elms, g -> ForAll(elms{[1 .. 10]}, h ->
>      ImagesRepresentative(hom, g * h)
>      = ImagesRepresentative(hom, g) * ImagesRepresentative(hom, h)));
true

# the same denominator in a maximal subgroup, with an induced numerator
gap> U := Subgroup(P, Concatenation([ pcgs[1] ], pcgs{[3 .. 32]}));;
gap> Index(P, U);
3
gap> M := InducedPcgs(pcgs, U) mod InducedPcgs(pcgs, N);;
gap> IsDenominatorInElementaryAbelianTailRep(M);
true
gap> elms := List([1 .. 50], i -> Random(U));;
gap> ForAll(elms, g -> ForAll(ExponentsOfPcElement(M, g), e -> e in [0 .. 2])
>      and LeftQuotient(PcElementByExponents(M, ExponentsOfPcElement(M, g)), g)
>          in N);
true

# all such denominators in groups of order 3^4, against the permutation group
# route
gap> ForAll(AllSmallGroups(3^4), function(G)
>      local pcgs, iso, N, M, hom;
>      pcgs := Pcgs(G);
>      iso := IsomorphismPermGroup(G);
>      for N in NormalSubgroups(G) do
>        M := pcgs mod InducedPcgs(pcgs, N);
>        if not IsDenominatorInElementaryAbelianTailRep(M) then
>          continue;
>        fi;
>        if ForAny(G, g -> not LeftQuotient(PcElementByExponents(M,
>                            ExponentsOfPcElement(M, g)), g) in N) then
>          return false;
>        fi;
>        hom := NaturalHomomorphismByNormalSubgroup(G, N);
>        if IdGroup(Image(hom))
>           <> IdGroup(FactorGroup(Image(iso), Image(iso, N))) then
>          return false;
>        fi;
>      od;
>      return true;
>    end);
true

# prime fields of any size
gap> for p in [ 2, 257, 65537 ] do
>      G := ElementaryAbelianGroup(IsPcGroup, p^3);
>      pcgs := Pcgs(G);
>      M := pcgs mod InducedPcgs(pcgs, Subgroup(G, [ pcgs[1] * pcgs[2] ]));
>      Print(IsDenominatorInElementaryAbelianTailRep(M), " ",
>            List(pcgs, x -> ExponentsOfPcElement(M, x)), "\n");
>    od;
true [ [ 1, 0 ], [ 1, 0 ], [ 0, 1 ] ]
true [ [ 256, 0 ], [ 1, 0 ], [ 0, 1 ] ]
true [ [ 65536, 0 ], [ 1, 0 ], [ 0, 1 ] ]

#
gap> STOP_TEST("pcgsmodu.tst");
