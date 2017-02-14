# Bug with commutator subgroups of fp groups, was causing infinite recursion,
# also when computing automorphism groups
# Fix and test case added by MH on 2012-06-05.
gap> F:=FreeGroup(3);;
gap> G:=F/[F.1^2,F.2^2,F.3^2,(F.1*F.2)^3, (F.2*F.3)^3, (F.1*F.3)^2];;
gap> U:=Subgroup(G, [G.3*G.1*G.3*G.2*G.1*G.3*G.2*G.3*G.1*G.3*G.1*G.3]);;
gap> StructureDescription(CommutatorSubgroup(G, U));
"C2 x C2"
gap> StructureDescription(AutomorphismGroup(G));
"S4"
