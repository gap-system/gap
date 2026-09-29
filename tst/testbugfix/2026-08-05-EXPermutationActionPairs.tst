# `EXPermutationActionPairs' rebuilds the first direct factor with
# `random := 1'. That is sound there, as the closure is validated against the
# known group order, but the value used to stay on the resulting group, so
# every stabilizer chain computed inside it later on was built randomly and
# without any limit to validate it against -- yielding wrong group orders.
gap> G := PcGroupCode(379875911272818017220001991, 4356);;
gap> D := DirectProduct(AutomorphismGroup(G), GL(1,11));;
gap> Reset(GlobalMersenneTwister, 4);; Reset(GlobalRandomSource, 4);;
gap> P := DirectProductInfo(EXPermutationActionPairs(D).permgroup).groups[1];;
gap> StabChainOptions(P).random = DefaultStabChainOptions.random;
true
gap> Size(P) = 172497600;
true
gap> AbelianInvariants(P) = AbelianInvariants(Group(GeneratorsOfGroup(P)));
true
