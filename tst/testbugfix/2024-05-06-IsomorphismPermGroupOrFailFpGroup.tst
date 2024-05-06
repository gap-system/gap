# Verify regression in IsomorphismPermGroupOrFailFpGroup is
# resolved, see <https://github.com/gap-system/gap/issues/5697>
gap> F:= FreeGroup(2);
<free group on the generators [ f1, f2 ]>
gap> gens:= GeneratorsOfGroup( F );
[ f1, f2 ]
gap> x:= gens[1];; y:= gens[2];;
gap> rels:= [ y*x^-1*y^-1*x*y^-1*x^-1, x^-1*y*x*y*x^-1*y^-2 ];;
gap> G:= F / rels;
<fp group on the generators [ f1, f2 ]>
gap> IsomorphismPermGroupOrFailFpGroup(G, 100000) <> fail;
true
