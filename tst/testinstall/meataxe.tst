gap> START_TEST("meataxe.tst");

#
#
#
gap> G:=SymmetricGroup(3);;
gap> M:=PermutationGModule(G,GF(2));
rec( IsOverFiniteField := true, dimension := 3, field := GF(2), 
  generators := [ <an immutable 3x3 matrix over GF2>, 
      <an immutable 3x3 matrix over GF2> ], isMTXModule := true )
gap> M2:=TensorProductGModule(M,M);
rec( IsOverFiniteField := true, dimension := 9, field := GF(2), 
  generators := [ <an immutable 9x9 matrix over GF2>, 
      <an immutable 9x9 matrix over GF2> ], isMTXModule := true )
gap> MTX.ModuleAutomorphisms(M);
<matrix group of size 1 with 4 generators>
gap> MTX.ModuleAutomorphisms(M2);
<matrix group of size 1344 with 9 generators>
gap> MTX.IsIndecomposable(M);
false
gap> MTX.IsIndecomposable(M);
false
gap> MTX.IsAbsolutelyIrreducible(M);
false

#
#
#
gap> G:=SymmetricGroup(5);;
gap> M:=PermutationGModule(G,GF(49));
rec( IsOverFiniteField := true, dimension := 5, field := GF(7^2), 
  generators := 
    [ 
      [ [ 0*Z(7), Z(7)^0, 0*Z(7), 0*Z(7), 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), Z(7)^0, 0*Z(7), 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), 0*Z(7), Z(7)^0, 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), 0*Z(7), 0*Z(7), Z(7)^0 ], 
          [ Z(7)^0, 0*Z(7), 0*Z(7), 0*Z(7), 0*Z(7) ] ], 
      [ [ 0*Z(7), Z(7)^0, 0*Z(7), 0*Z(7), 0*Z(7) ], 
          [ Z(7)^0, 0*Z(7), 0*Z(7), 0*Z(7), 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), Z(7)^0, 0*Z(7), 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), 0*Z(7), Z(7)^0, 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), 0*Z(7), 0*Z(7), Z(7)^0 ] ] ], isMTXModule := true 
 )
gap> MTX.ModuleAutomorphisms(M);
<matrix group of size 2304 with 4 generators>
gap> MTX.IsIndecomposable(M);
false
gap> MTX.IsAbsolutelyIrreducible(M);
false

#
gap> M2:=MTX.CompositionFactors(M)[2];
rec( IsIrreducible := true, IsOverFiniteField := true, dimension := 4, 
  field := GF(7^2), 
  generators := 
    [ 
      [ [ 0*Z(7), Z(7)^0, 0*Z(7), 0*Z(7) ], [ 0*Z(7), 0*Z(7), Z(7)^0, 0*Z(7) ],
          [ 0*Z(7), 0*Z(7), 0*Z(7), Z(7)^0 ], 
          [ Z(7)^3, Z(7)^3, Z(7)^3, Z(7)^3 ] ], 
      [ [ Z(7)^3, Z(7)^3, Z(7)^3, Z(7)^3 ], [ 0*Z(7), Z(7)^0, 0*Z(7), 0*Z(7) ]
            , [ 0*Z(7), 0*Z(7), Z(7)^0, 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), 0*Z(7), Z(7)^0 ] ] ], isMTXModule := true, 
  smashMeataxe := 
    rec( 
      algebraElement := [ [ [ 2, 1 ], [ 1, 2 ], [ 1, 4 ] ], 
          [ Z(7^2)^14, Z(7^2)^46, Z(7^2)^4, Z(7)^2, Z(7)^0 ] ], 
      algebraElementMatrix := 
        [ [ Z(7^2)^25, Z(7^2)^19, Z(7^2)^34, Z(7^2)^22 ], 
          [ 0*Z(7), Z(7^2)^46, Z(7^2)^31, Z(7)^0 ], 
          [ Z(7)^0, 0*Z(7), Z(7^2)^46, Z(7^2)^31 ], 
          [ Z(7^2)^12, Z(7^2)^35, Z(7^2)^35, Z(7^2)^18 ] ], 
      characteristicPolynomial := x_1^4+x_1^3+Z(7^2)^38*x_1^2+Z(7^2)^11, 
      charpolFactors := x_1+Z(7^2)^6, ndimFlag := 1, 
      nullspaceVector := [ Z(7^2)^47, Z(7^2)^30, Z(7), Z(7)^0 ] ) )
gap> IdGroup(MTX.ModuleAutomorphisms(M2));
[ 48, 2 ]
gap> MTX.IsIndecomposable(M2);
true
gap> MTX.IsAbsolutelyIrreducible(M2);
true
gap> MTX.InvariantBilinearForm(M2);
[ [ Z(7)^3, Z(7)^2, Z(7)^2, Z(7)^2 ], [ Z(7)^2, Z(7)^3, Z(7)^2, Z(7)^2 ], 
  [ Z(7)^2, Z(7)^2, Z(7)^3, Z(7)^2 ], [ Z(7)^2, Z(7)^2, Z(7)^2, Z(7)^3 ] ]
gap> MTX.InvariantSesquilinearForm(M2);
[ [ Z(7)^3, Z(7)^2, Z(7)^2, Z(7)^2 ], [ Z(7)^2, Z(7)^3, Z(7)^2, Z(7)^2 ], 
  [ Z(7)^2, Z(7)^2, Z(7)^3, Z(7)^2 ], [ Z(7)^2, Z(7)^2, Z(7)^2, Z(7)^3 ] ]
gap> MTX.InvariantQuadraticForm(M2);
[ [ Z(7), Z(7)^0, Z(7)^0, Z(7)^0 ], [ Z(7)^0, Z(7), Z(7)^0, Z(7)^0 ], 
  [ Z(7)^0, Z(7)^0, Z(7), Z(7)^0 ], [ Z(7)^0, Z(7)^0, Z(7)^0, Z(7) ] ]
gap> MTX.BasisInOrbit(M2);
[ [ Z(7)^0, 0*Z(7), 0*Z(7), 0*Z(7) ], [ 0*Z(7), Z(7)^0, 0*Z(7), 0*Z(7) ], 
  [ Z(7)^3, Z(7)^3, Z(7)^3, Z(7)^3 ], [ 0*Z(7), 0*Z(7), Z(7)^0, 0*Z(7) ] ]
gap> MTX.OrthogonalSign(M2);
1

#
gap> STOP_TEST("meataxe.tst", 10000);
