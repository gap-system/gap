# 2013/02/27 (AK)
gap> F := FreeGroup("a","b");;
gap> G := F/[F.1*F.2*F.1*F.2*F.1];;
gap> IsAbelian(G);
true
gap> DerivedSubgroup(G);
Group([  ])
