# 2013/02/28 (BH). More tests added by AK
gap> Length( AbsolutIrreducibleModules( AlternatingGroup(5), GF(4), 120) );
2
gap> Length( IrreducibleRepresentations( DihedralGroup(10), GF(2^2) ) );
3
gap> Length( AbsoluteIrreducibleModules( CyclicGroup(3), GF(4), 1) );
2
gap> G:=DihedralGroup(20);; b:=G.1*G.2;; Order(b);
2
gap> ForAll( IrreducibleRepresentations(G,GF(8)), phi -> IsOne(Image(phi,b)^2));
true
