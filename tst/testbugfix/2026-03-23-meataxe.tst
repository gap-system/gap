# Handling of irreducible Meataxe modules with lots of generators was far
# slower than necessary at least via the "high level" Meataxe APIs.
# See also <https://github.com/gap-system/gap/issues/6271>.
#
# The main test here is for performance: before the fix for issue #6271 this
# would have run for minutes, with the fix it should take far less than a
# second on a modern computer.
gap> n:=200;;   # increase this to make the effect even stronger
gap> G:=GL(56,GF(25));;
gap> H:=Subgroup(G, Concatenation(GeneratorsOfGroup(G),List([1..n],i->PseudoRandom(G))));;
gap> MTX.IsomorphismModules(NaturalGModule(H), NaturalGModule(H)) <> fail;
true
