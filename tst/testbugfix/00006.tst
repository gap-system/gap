## iterated autgp (5)
gap> g:=Group((1,2,3),(4,5,6),(2,3)(5,6));;
gap> aut:=AutomorphismGroup(g);;
gap> ccu:=ConjugacyClasses(aut);;
gap> aut2:=AutomorphismGroup(aut);;
