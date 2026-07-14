# see <https://github.com/gap-system/gap/issues/5809>
gap> F := FreeGroup(["a", "b"]);;
gap> a := F.1;;
gap> b := F.1;;
gap> p := 5;;
gap> G := F / [a^p, b^p, Comm(a,b)];;
gap> PQuotient(G, p, 1, 2 : noninteractive) <> fail;
true
gap> PQuotient(G, p, 1, 1 : noninteractive) = fail;
true
