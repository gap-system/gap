# 2012/04/13 (MN)
gap> Characteristic(Z(2));
2
gap> Characteristic(0*Z(2));
2
gap> Characteristic(0*Z(5));
5
gap> Characteristic(Z(5));
5
gap> Characteristic(Z(257));
257
gap> Characteristic(Z(2^60));
2
gap> Characteristic(Z(3^20));
3
gap> Characteristic(0);
0
gap> Characteristic(12);
0
gap> Characteristic(12123123123);
0
gap> Characteristic(E(4));
0
gap> Characteristic([Z(2),Z(4)]);
2
gap> v := [Z(2),Z(4)];
[ Z(2)^0, Z(2^2) ]
gap> ConvertToVectorRep(v,4);
4
gap> Characteristic(v);
2
gap> Characteristic([Z(257),Z(257)^47]);
257
gap> Characteristic([[Z(257),Z(257)^47]]);
257
gap> Characteristic(ZmodnZObj(2,6));
6
gap> Characteristic(ZmodnZObj(2,5));
5
gap> Characteristic(ZmodnZObj(2,5123123123));
5123123123
gap> Characteristic(ZmodnZObj(0,5123123123));
5123123123
gap> Characteristic(GF(2,3));
2
gap> Characteristic(GF(2));
2
gap> Characteristic(GF(3,7));
3
gap> Characteristic(GF(1031));
1031
gap> Characteristic(Cyclotomics);
0
gap> Characteristic(Integers);
0
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1/2, 1, 2/3, 2 ] );
gap> a := AlgebraByStructureConstants(Rationals,T);
<algebra of dimension 2 over Rationals>
gap> Characteristic(a);
0
gap> a := AlgebraByStructureConstants(Cyclotomics,T);
<algebra of dimension 2 over Cyclotomics>
gap> Characteristic(a);
0
gap> a := AlgebraByStructureConstants(GF(7),T);
<algebra of dimension 2 over GF(7)>
gap> Characteristic(a);
7
gap> T:= EmptySCTable( 2, 0 );;
gap> SetEntrySCTable( T, 1, 1, [ 1, 1, 2, 2 ] );
gap> r := RingByStructureConstants([7,7],T);
<ring with 2 generators>
gap> Characteristic(r);
7
gap> r := RingByStructureConstants([7,5],T);
<ring with 2 generators>
gap> Characteristic(r);
35
