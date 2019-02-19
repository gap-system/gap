gap> F := FreeGroup(1);;
gap> rels := [F.1^2, One(F)];;
gap> G := F / rels;;
gap> Order(G);
2
