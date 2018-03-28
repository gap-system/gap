gap> START_TEST("SimpleGroup.tst");

#
gap> SimpleGroup("Alt(5)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
A5
60
rec( 
  name := "A(5) ~ A(1,4) = L(2,4) ~ B(1,4) = O(3,4) ~ C(1,4) = S(2,4) ~ 2A(1,4\
) = U(2,4) ~ A(1,5) = L(2,5) ~ B(1,5) = O(3,5) ~ C(1,5) = S(2,5) ~ 2A(1,5) = U\
(2,5)", parameter := 5, series := "A", shortname := "A5" )
gap> SimpleGroup("A6"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
A6
360
rec( 
  name := "A(6) ~ A(1,9) = L(2,9) ~ B(1,9) = O(3,9) ~ C(1,9) = S(2,9) ~ 2A(1,9\
) = U(2,9)", parameter := 6, series := "A", shortname := "A6" )
gap> SimpleGroup("A4");
Error, illegal parameter for alternating groups

#
gap> SimpleGroup("M");
Error, Monster not yet supported
gap> SimpleGroup("FG"); # friendly giant
Error, Monster not yet supported

# skip baby monster for now

# Mathieu groups
gap> SimpleGroup("M10");
Error, illegal parameter for Mathieu groups
gap> SimpleGroup("M11"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
M11
7920
rec( name := "M(11)", series := "Spor", shortname := "M11" )

#
gap> SimpleGroup("J1"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
J_1
175560
rec( name := "J(1)", series := "Spor", shortname := "J1" )
gap> SimpleGroup("J_2"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
J_2
604800
rec( name := "HJ = J(2) = F(5-)", series := "Spor", shortname := "J2" )
gap> SimpleGroup("J5");
Error, illegal parameter for Janko groups

#
gap> SimpleGroup("CO3"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Co_3
495766656000
rec( name := "Co(3)", series := "Spor", shortname := "Co3" )
gap> SimpleGroup("CO(2)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Co(2)
42305421312000
rec( name := "Co(2)", series := "Spor", shortname := "Co2" )
gap> SimpleGroup("CO4");
Error, illegal parameter for Conway groups

#
gap> SimpleGroup("Fi20");
Error, illegal parameter for Fischer groups

#
gap> SimpleGroup("SuZ"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Suz
448345497600
rec( name := "Suz", series := "Spor", shortname := "Suz" )
gap> SimpleGroup("Sz(8)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Sz(8)
29120
rec( name := "2B(2,8) = 2C(2,8) = Sz(8)", parameter := 8, series := "2B", 
  shortname := "Sz(8)" )
gap> SimpleGroup("Suzuki(32)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Sz(32)
32537600
rec( name := "2B(2,32) = 2C(2,32) = Sz(32)", parameter := 32, series := "2B", 
  shortname := "Sz(32)" )
gap> SimpleGroup("Suz(8)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Sz(8)
29120
rec( name := "2B(2,8) = 2C(2,8) = Sz(8)", parameter := 8, series := "2B", 
  shortname := "Sz(8)" )
gap> SimpleGroup("Sz(9)");
Error, illegal parameter for Suzuki groups
gap> SimpleGroup("Suz(16)");
Error, illegal parameter for Suzuki groups

#
gap> SimpleGroup("R(27)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Ree(27)
10073444472
rec( name := "2G(2,27) = Ree(27)", parameter := 27, series := "2G", 
  shortname := "R(27)" )
gap> SimpleGroup("Ree(27)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Ree(27)
10073444472
rec( name := "2G(2,27) = Ree(27)", parameter := 27, series := "2G", 
  shortname := "R(27)" )
gap> SimpleGroup("2G(243)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
Ree(243)
49825657439340552
rec( name := "2G(2,243) = Ree(243)", parameter := 243, series := "2G", 
  shortname := "R(243)" )
gap> SimpleGroup("Ree(9)");
Error, illegal parameter for Ree groups
gap> SimpleGroup("Ree(16)");
Error, illegal parameter for Ree groups

#
gap> SimpleGroup("HE"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
He
4030387200
rec( name := "He = F(7)", series := "Spor", shortname := "He" )
gap> SimpleGroup("HS"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
HS
44352000
rec( name := "HS", series := "Spor", shortname := "HS" )
gap> SimpleGroup("McL"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
McL
898128000
rec( name := "Mc", series := "Spor", shortname := "McL" )
gap> SimpleGroup("T"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
2F(4,2)'
17971200
rec( name := "2F(4,2)' = Ree(2)' = Tits", parameter := 2, series := "2F", 
  shortname := "2F4(2)'" )

#
# linear groups
#
gap> SimpleGroup("L(2,2)");
Error, illegal parameter for linear groups
gap> SimpleGroup("L(2,3)");
Error, illegal parameter for linear groups
gap> SimpleGroup("L(2,4)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
PSL(2,4)
60
rec( 
  name := "A(5) ~ A(1,4) = L(2,4) ~ B(1,4) = O(3,4) ~ C(1,4) = S(2,4) ~ 2A(1,4\
) = U(2,4) ~ A(1,5) = L(2,5) ~ B(1,5) = O(3,5) ~ C(1,5) = S(2,5) ~ 2A(1,5) = U\
(2,5)", parameter := 5, series := "A", shortname := "A5" )
gap> SimpleGroup("L(3,2)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
PSL(3,2)
168
rec( 
  name := "A(1,7) = L(2,7) ~ B(1,7) = O(3,7) ~ C(1,7) = S(2,7) ~ 2A(1,7) = U(2\
,7) ~ A(2,2) = L(3,2)", parameter := [ 2, 7 ], series := "L", 
  shortname := "L3(2)" )
gap> SimpleGroup("L(4,2)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
PSL(4,2)
20160
rec( name := "A(8) ~ A(3,2) = L(4,2) ~ D(3,2) = O+(6,2)", parameter := 8, 
  series := "A", shortname := "A8" )
gap> SimpleGroup("L(4,6)");
Error, field order must be a prime power

#
# unitary groups
#
gap> SimpleGroup("U(2,2)");
Error, illegal parameter for unitary groups
gap> SimpleGroup("U(3,2)");
Error, illegal parameter for unitary groups
gap> SimpleGroup("U(4,2)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
PSU(4,2)
25920
rec( 
  name := "B(2,3) = O(5,3) ~ C(2,3) = S(4,3) ~ 2A(3,2) = U(4,2) ~ 2D(3,2) = O-\
(6,2)", parameter := [ 2, 3 ], series := "B", shortname := "U4(2)" )

#
# symplectic groups
#
gap> SimpleGroup("Sp(2,2)");
Error, illegal parameter for symplectic groups
gap> SimpleGroup("S(2,3)");
Error, illegal parameter for symplectic groups
gap> SimpleGroup("PSp(2,4)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
PSp(2,4)
60
rec( 
  name := "A(5) ~ A(1,4) = L(2,4) ~ B(1,4) = O(3,4) ~ C(1,4) = S(2,4) ~ 2A(1,4\
) = U(2,4) ~ A(1,5) = L(2,5) ~ B(1,5) = O(3,5) ~ C(1,5) = S(2,5) ~ 2A(1,5) = U\
(2,5)", parameter := 5, series := "A", shortname := "A5" )
gap> SimpleGroup("S(3,2)");
Error, the dimension <d> must be even
gap> SimpleGroup("Sp(4,2)");
Error, illegal parameter for symplectic groups
gap> SimpleGroup("Sp(4,3)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
PSp(4,3)
25920
rec( 
  name := "B(2,3) = O(5,3) ~ C(2,3) = S(4,3) ~ 2A(3,2) = U(4,2) ~ 2D(3,2) = O-\
(6,2)", parameter := [ 2, 3 ], series := "B", shortname := "U4(2)" )

#
# orthogonal groups
#
gap> SimpleGroup("O-(5,2)");
Error, wrong dimension/parity for O
gap> SimpleGroup("O(+,5,2)");
Error, wrong dimension/parity for O
gap> SimpleGroup("O(8,2)");
Error, wrong dimension/parity for O
gap> SimpleGroup("O+(2,23)");
Error, illegal parameter for orthogonal groups
gap> SimpleGroup("O-(2,29)");
Error, illegal parameter for orthogonal groups
gap> SimpleGroup("O(+,4,17)");
Error, illegal parameter for orthogonal groups
gap> SimpleGroup("O(1,6,2)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
O+(6,2)
20160
rec( name := "A(8) ~ A(3,2) = L(4,2) ~ D(3,2) = O+(6,2)", parameter := 8, 
  series := "A", shortname := "A8" )
gap> SimpleGroup("O(-,4,2)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
O-(4,2)
60
rec( 
  name := "A(5) ~ A(1,4) = L(2,4) ~ B(1,4) = O(3,4) ~ C(1,4) = S(2,4) ~ 2A(1,4\
) = U(2,4) ~ A(1,5) = L(2,5) ~ B(1,5) = O(3,5) ~ C(1,5) = S(2,5) ~ 2A(1,5) = U\
(2,5)", parameter := 5, series := "A", shortname := "A5" )
gap> SimpleGroup("O-(4,2)");
O-(4,2)

#
# exceptional groups
#
# we mostly restrict ourselves to testing the parameter validation,
# to avoid dependency on atlasrep package
#
gap> SimpleGroup("E(5,2)");
Error, E(n,q) needs n=6,7,8

#
gap> SimpleGroup("F3(3)");
Error, F(n,q) needs n=4
gap> SimpleGroup("F4(3)");
Error, Can't do yet

#
gap> SimpleGroup("G3(3)");
Error, G(n,q) needs n=2
gap> SimpleGroup("G2(2)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
PSU(3,3)
6048
rec( name := "2A(2,3) = U(3,3)", parameter := [ 2, 3 ], series := "2A", 
  shortname := "U3(3)" )
gap> SimpleGroup("G2(3)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
G(2, 3)
4245696
rec( name := "G(2,3)", parameter := 3, series := "G", shortname := "G2(3)" )
gap> SimpleGroup("G2(4)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
G(2, 4)
251596800
rec( name := "G(2,4)", parameter := 4, series := "G", shortname := "G2(4)" )
gap> SimpleGroup("G2(5)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
G_2(5)
5859000000
rec( name := "G(2,5)", parameter := 5, series := "G", shortname := "G2(5)" )

#
gap> SimpleGroup("3D(4,2)"); Size(last); IsomorphismTypeInfoFiniteSimpleGroup(last2);
3D(4, 2)
211341312
rec( name := "3D(4,2)", parameter := 2, series := "3D", shortname := "3D4(2)" 
 )
gap> SimpleGroup("3D(4,4)");
Error, Can't do yet

#
gap> SimpleGroup("2E(5,2)");
Error, 2E(n,q) needs n=6

#
gap> SimpleGroup("X(4,3)");
Error, Can't handle type X

#
gap> STOP_TEST("SimpleGroup.tst", 10000);
