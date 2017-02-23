# 2015/02/02 (AH, reported by Petr Savicky)
gap> it := SimpleGroupsIterator(17971200);
<iterator>
gap> G := NextIterator(it); # 2F(4,2)'
2F(4,2)'
gap> ClassicalIsomorphismTypeFiniteSimpleGroup(G);
rec( parameter := [ "T" ], series := "Spor" )
