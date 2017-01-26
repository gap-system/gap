# 2005/05/04 (SL)
gap> c := [1,1,0,1]*Z(2);
[ Z(2)^0, Z(2)^0, 0*Z(2), Z(2)^0 ]
gap> m := [1,1]*Z(2);
[ Z(2)^0, Z(2)^0 ]
gap> PowerModCoeffs(c, 1, m);
[ Z(2)^0 ]
gap> ConvertToVectorRep(c, 2);
2
gap> ConvertToVectorRep(m, 2);
2
gap> Print(PowerModCoeffs(c, 1, m), "\n");
[ Z(2)^0 ]
