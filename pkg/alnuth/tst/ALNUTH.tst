gap> START_TEST("Installation test of Alnuth package");  
gap> mats := ExamUnimod( 1 );;
gap> F := FieldByMatrices( mats );
<rational matrix field of degree 4>
gap> DegreeOverPrimeField( F );
4
gap> EquationOrderBasis( F );
Basis( <rational matrix field of degree 4>, 
[ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
  [ [ -1, 1, 1, 0 ], [ 5, -5, -5, 11 ], [ 3, -4, -7, 11 ], [ 3, -3, -4, 7 ] ],
  [ [ 9, -10, -13, 22 ], [ -12, 17, 21, -33 ], [ -11, 18, 28, -44 ],
      [ -9, 13, 18, -28 ] ],
  [ [ -32, 45, 62, -99 ], [ 61, -82, -112, 187 ], [ 53, -81, -121, 198 ],
      [ 44, -62, -88, 145 ] ] ] )

# testing maxord.gp
gap> IsIntegerOfNumberField( F, mats[1] );
true
gap> MaximalOrderBasis( F );;

# testing units.gp
gap> UnitGroup( F );
<matrix group with 4 generators>
gap> IsCyclotomicField( F );
false

# testing fracidea.gp and decompra.gp
gap> IsomorphismPcpGroup( F, mats{[2..5]} );
[ [ [ 57641556673, -51250063536, -73214376480, 161071628256 ], 
      [ 21964312944, 28355806081, 43928625888, 0 ], 
      [ -14642875296, 43928625888, 64962994321, -80535814128 ], 
      [ 0, 29285750592, 43928625888, -37537132751 ] ], 
  [ [ 13, 0, -21, 0 ], [ -42, 97, 105, -231 ], [ -21, 0, 34, 0 ], 
      [ -21, 21, 42, -50 ] ], 
  [
      [ 6113341760402965, -3032143586011050, -4159967272068153,
          14002438585824810 ],
      [ 10588511869480164, -5251666322974043, -7205040811308855,
          24252552936374367 ],
      [ 3778184141734557, -1873864241780610, -2570850209123252,
          8653736311352880 ],
      [ 5051133104082267, -2505235179386847, -3437063756709534,
          11569395035183716 ] ] ] -> [ g1, g2, g3 ]
gap> RelationLatticeOfUnits( F, mats );
[ [ 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 2, -2 ],
  [ 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0 ],
  [ 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2 ],
  [ 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, -1, 0 ],
  [ 0, 0, 0, 0, 2, 0, 1, 0, 0, 0, 0, 1, -4 ],
  [ 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 2 ],
  [ 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 2 ],
  [ 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 2 ],
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0 ],
  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, -3 ] ]

# testing polyfactors.gp
gap> pol := UnivariatePolynomial( Rationals, [0,0,8,0,8,2,0,2] );
2*x_1^7+2*x_1^5+8*x_1^4+8*x_1^2
gap> f := UnivariatePolynomial( Rationals, [-4,0,0,1] );
x_1^3-4
gap> L := FieldByPolynomial( f );
<algebraic extension over the Rationals of degree 3>
gap> FactorsPolynomialAlgExt( L, pol );
[ !2*x_1, x_1, x_1+a, x_1^2+!1, x_1^2+(-a)*x_1+a^2 ]
gap> pol := UnivariatePolynomial( Rationals, [ 1, 3, 2, -1, 2, 3, 1 ] );
x_1^6+3*x_1^5+2*x_1^4-x_1^3+2*x_1^2+3*x_1+1
gap> f := UnivariatePolynomial( Rationals,[ 11/64, 59/16, -7/4, 1 ] );
x_1^3-7/4*x_1^2+59/16*x_1+11/64
gap> L := FieldByPolynomial( f );
<algebraic extension over the Rationals of degree 3>
gap> FactorsPolynomialAlgExt( L, pol );
[ x_1^2+x_1+(-a+1/4), x_1^2+(-a^2+3/2*a-21/16)*x_1+!1, 
  x_1^2+(a^2-3/2*a+53/16)*x_1+(a^2-3/2*a+53/16) ]

# testing norm.gp and fracidea.gp
gap> pol := UnivariatePolynomial( Rationals, [ 1, 0, -1, 1 ] );
x_1^3-x_1^2+1
gap> L := FieldByPolynomial( pol );
<algebraic extension over the Rationals of degree 3>
gap> cosets := NormCosetsOfNumberField( L, 5 );
[ a^2-2*a ]
gap> ExponentsOfFractionalIdealDescription( L, cosets );
[ [ 1 ] ]
gap> STOP_TEST( "ALNUTH.tst", 100000);   




















