# Fix GitHub issue #4659, reported by Daniel Pook-Kolb
gap> p_gens := [PermutationMat((1,2), 6), PermutationMat((1,2,3,4,5,6), 6)];;
gap> p_group := Group(p_gens);;
gap> s1 := DiagonalMat([-1, -1, 1, 1, 1, 1]);;
gap> s_gens := Orbit(p_group, s1);;
gap> ps_gens := Concatenation(p_gens, s_gens);;
gap> ps_group := Group(ps_gens);;
gap> v := [1,2,1,1,0,0];;
gap> orbit := Orbit(ps_group, v);;
gap> Size(ps_group);;
gap> stab := Stabilizer(ps_group, v);;
gap> Size(orbit) * Size(stab) = Size(ps_group);
true
