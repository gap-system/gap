gap> START_TEST("meataxe.tst");

#
#
#
gap> G:=SymmetricGroup(3);;
gap> M:=PermutationGModule(G,GF(2));
rec( IsOverFiniteField := true, dimension := 3, field := GF(2), 
  generators := [ <an immutable 3x3 matrix over GF2>, 
      <an immutable 3x3 matrix over GF2> ], isMTXModule := true )
gap> MTX.ModuleAutomorphisms(M);
<matrix group of size 1 with 4 generators>
gap> MTX.IsIndecomposable(M);
false
gap> MTX.IsIndecomposable(M);
false
gap> MTX.IsAbsolutelyIrreducible(M);
false
gap> Display(MTX.IsomorphismModules(M,M));
 1 . .
 . 1 .
 . . 1

#
#
#
gap> M2:=TensorProductGModule(M,M);
rec( IsOverFiniteField := true, dimension := 9, field := GF(2), 
  generators := [ <an immutable 9x9 matrix over GF2>, 
      <an immutable 9x9 matrix over GF2> ], isMTXModule := true )
gap> IdGroup(MTX.ModuleAutomorphisms(M2));
[ 1344, 11301 ]

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
gap> M2:=First(MTX.CompositionFactors(M), m -> m.dimension = 4);
rec( IsIrreducible := true, IsOverFiniteField := true, dimension := 4, 
  field := GF(7^2), 
  generators := 
    [ 
      [ [ Z(7^2)^7, Z(7^2)^41, 0*Z(7), 0*Z(7) ], 
          [ Z(7^2)^45, Z(7)^4, Z(7^2)^12, Z(7^2)^18 ], 
          [ Z(7)^3, Z(7^2)^11, Z(7^2)^5, Z(7)^0 ], 
          [ Z(7)^3, Z(7^2)^11, Z(7^2)^5, 0*Z(7) ] ], 
      [ [ Z(7^2)^11, Z(7^2)^9, Z(7^2)^3, 0*Z(7) ], 
          [ Z(7)^0, Z(7^2)^35, Z(7^2), 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), Z(7)^0, 0*Z(7) ], 
          [ 0*Z(7), 0*Z(7), 0*Z(7), Z(7)^0 ] ] ], isMTXModule := true, 
  smashMeataxe := 
    rec( 
      algebraElement := 
        [ [ [ 2, 1 ], [ 2, 3 ] ], [ Z(7^2)^10, Z(7^2)^6, Z(7^2), Z(7^2)^46 ] ]
        , algebraElementMatrix := [ [ Z(7^2)^3, Z(7^2), Z(7^2)^19, 0*Z(7) ], 
          [ Z(7^2)^36, Z(7^2)^35, Z(7^2)^23, Z(7^2)^2 ], 
          [ Z(7), Z(7^2)^43, Z(7^2)^7, Z(7)^4 ], 
          [ Z(7), Z(7^2)^43, Z(7^2)^37, Z(7^2)^6 ] ], 
      characteristicPolynomial := x_1^4+Z(7^2)^27*x_1^3+Z(7^2)^28*x_1^2+Z(7^2)\
^30*x_1+Z(7^2)^36, charpolFactors := x_1+Z(7^2)^25, ndimFlag := 1, 
      nullspaceVector := [ 0*Z(7), Z(7), Z(7^2)^26, Z(7)^0 ] ) )
gap> IdGroup(MTX.ModuleAutomorphisms(M2));
[ 48, 2 ]
gap> MTX.IsIndecomposable(M2);
true
gap> MTX.IsAbsolutelyIrreducible(M2);
true
gap> MTX.InvariantBilinearForm(M2);
[ [ Z(7^2)^6, Z(7^2)^36, Z(7^2)^28, Z(7^2)^28 ], 
  [ Z(7^2)^36, Z(7^2)^23, Z(7^2)^12, Z(7^2)^18 ], 
  [ Z(7^2)^28, Z(7^2)^12, Z(7^2)^13, Z(7^2)^45 ], 
  [ Z(7^2)^28, Z(7^2)^18, Z(7^2)^45, Z(7^2)^13 ] ]
gap> MTX.InvariantSesquilinearForm(M2);
[ [ Z(7)^2, Z(7^2)^41, Z(7^2)^31, Z(7^2)^31 ], 
  [ Z(7^2)^47, Z(7)^0, Z(7^2)^15, Z(7^2)^21 ], 
  [ Z(7^2)^25, Z(7^2)^9, Z(7)^2, Z(7)^0 ], 
  [ Z(7^2)^25, Z(7^2)^3, Z(7)^0, Z(7)^2 ] ]
gap> MTX.InvariantQuadraticForm(M2);
[ [ Z(7^2)^38, Z(7^2)^20, Z(7^2)^12, Z(7^2)^12 ], 
  [ Z(7^2)^20, Z(7^2)^7, Z(7^2)^44, Z(7^2)^2 ], 
  [ Z(7^2)^12, Z(7^2)^44, Z(7^2)^45, Z(7^2)^29 ], 
  [ Z(7^2)^12, Z(7^2)^2, Z(7^2)^29, Z(7^2)^45 ] ]
gap> MTX.BasisInOrbit(M2);
[ [ Z(7)^0, 0*Z(7), 0*Z(7), 0*Z(7) ], [ Z(7^2)^7, Z(7^2)^41, 0*Z(7), 0*Z(7) ],
  [ Z(7^2)^11, Z(7^2)^9, Z(7^2)^3, 0*Z(7) ], 
  [ 0*Z(7), Z(7^2)^7, Z(7^2)^5, Z(7^2)^11 ] ]
gap> MTX.OrthogonalSign(M2);
1

#
gap> Display(MTX.IsomorphismModules(M,M));
 1 . . . .
 . 1 . . .
 . . 1 . .
 . . . 1 .
 . . . . 1
gap> mat:=
> [[ Z(7^2)^35, 0*Z(7), Z(7^2)^31, Z(7^2)^13, Z(7^2)^9 ],
>  [ Z(7^2)^39, Z(7^2)^3, Z(7^2)^4, Z(7^2)^26, Z(7^2)^36 ],
>  [ Z(7^2)^35, Z(7^2)^38, Z(7^2)^19, 0*Z(7), Z(7^2)^28 ],
>  [ Z(7^2)^45, Z(7^2)^7, Z(7^2)^11, Z(7^2)^25, Z(7^2)^42 ],
>  [ Z(7^2)^37, Z(7^2)^27, Z(7^2)^4, Z(7^2)^44, Z(7^2)^5 ] ];;
gap> M3:=PermutationGModule(G,GF(49));;
gap> M3.generators := List(M3.generators, x -> x^mat);;
gap> fail <> MTX.IsomorphismModules(M,M3);
true

#
gap> M4:=InducedGModule(SymmetricGroup(6),G,M);
rec( IsOverFiniteField := true, dimension := 30, field := GF(7^2), 
  generators := [ < immutable compressed matrix 30x30 over GF(49) >, 
      < immutable compressed matrix 30x30 over GF(49) > ], 
  isMTXModule := true )
gap> SortedList(List(MTX.CompositionFactors(M4), m -> m.dimension));
[ 1, 5, 5, 9, 10 ]

#
gap> M5:=WedgeGModule(M);
rec( IsOverFiniteField := true, dimension := 10, field := GF(7^2), 
  generators := [ < immutable compressed matrix 10x10 over GF(49) >, 
      < immutable compressed matrix 10x10 over GF(49) > ], 
  isMTXModule := true )
gap> SortedList(List(MTX.CompositionFactors(M5), m -> m.dimension));
[ 4, 6 ]

#
gap> STOP_TEST("meataxe.tst", 10000);
