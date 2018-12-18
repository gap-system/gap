# reported by Giles Gardam. The code for eliminating element orders can run astray if 
# a quotent by a generator power is cyclic, but also has cyclic subgroups of infinite
# index.
gap> F := FreeGroup("a", "b", "c");;
gap> G := F/ParseRelators(F,"a2b5a2b2C2,a5c3B2");;
gap> Length(GQuotients(G,AlternatingGroup(5)));
1
