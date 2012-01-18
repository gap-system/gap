gap> START_TEST("Test of examples from the Alnuth manual");

gap> m1 := [[1, 0, 0, -7],[7, 1, 0, -7],[0, 7, 1, -7],[0, 0, 7, -6]];;
gap> m2 := [[0, 0, -13, 14],[-1, 0, -13, 1],[13, -1, -13, 1],[0, 13, -14, 1]];;

gap> F := FieldByMatricesNC( [m1, m2] );
<rational matrix field of unknown degree>

gap> DegreeOverPrimeField(F);
4
gap> PrimitiveElement(F);
[ [ -1, 1, 1, 0 ], [ -2, 0, 2, 1 ], [ -2, -1, 1, 2 ], [ -1, -1, 0, 1 ] ]

gap> Basis(F);
Basis( <rational matrix field of degree 4>,
[ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ],
  [ [ 0, 1, 0, 0 ], [ -1, 1, 1, 0 ], [ -1, 0, 1, 1 ], [ -1, 0, 0, 1 ] ],
  [ [ 0, 0, 1, 0 ], [ -1, 0, 1, 1 ], [ -1, -1, 1, 1 ], [ 0, -1, 0, 1 ] ],
  [ [ 0, 0, 0, 1 ], [ -1, 0, 0, 1 ], [ 0, -1, 0, 1 ], [ 0, 0, -1, 1 ] ] ] )

gap> MaximalOrderBasis(F);
Basis( <rational matrix field of degree 4>,
[ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ],
  [ [ -1, 1, 1, 0 ], [ -2, 0, 2, 1 ], [ -2, -1, 1, 2 ], [ -1, -1, 0, 1 ] ],
  [ [ -3, -2, 2, 3 ], [ -3, -5, 0, 5 ], [ 0, -5, -3, 3 ], [ 2, -2, -3, 0 ] ],
  [ [ -1, -1, 0, 1 ], [ 0, -2, -1, 1 ], [ 1, -1, -2, 0 ], [ 1, 0, -1, -1 ] ]
 ] )

gap> U := UnitGroup(F);
<matrix group with 2 generators>

gap> u := GeneratorsOfGroup( U );;

gap> nat := IsomorphismPcpGroup(U);
[ [ [ 0, 0, 1, -1 ], [ 0, 0, 1, 0 ], [ -1, 0, 1, 0 ], [ 0, -1, 1, 0 ] ],
  [ [ 0, 1, 0, 0 ], [ -1, 1, 1, 0 ], [ -1, 0, 1, 1 ], [ -1, 0, 0, 1 ] ] ] ->
[ g1, g2 ]

gap> H := Image(nat);
Pcp-group with orders [ 10, 0 ]
gap> ImageElm( nat, u[1]*u[2] );
g1*g2
gap> PreImagesRepresentative(nat, GeneratorsOfGroup(H)[1] );
[ [ 0, 0, 1, -1 ], [ 0, 0, 1, 0 ], [ -1, 0, 1, 0 ], [ 0, -1, 1, 0 ] ]

gap> g := UnivariatePolynomial( Rationals, [ 16, 64, -28, -4, 1 ] );
x_1^4-4*x_1^3-28*x_1^2+64*x_1+16

gap> F := FieldByPolynomialNC(g);
<algebraic extension over the Rationals of degree 4>
gap> PrimitiveElement(F);
a
gap> MaximalOrderBasis(F);
Basis( <algebraic extension over the Rationals of degree 4>,
[ !1, 1/2*a, 1/4*a^2, 1/56*a^3+1/14*a^2+1/14*a-2/7 ] )

gap> U := UnitGroup(F);
<group with 4 generators>

gap> natU := IsomorphismPcpGroup(U);
[ !-1, 1/28*a^3-3/28*a^2-6/7*a+3/7, 1/56*a^3+1/14*a^2-3/7*a-2/7,
  1/56*a^3-5/28*a^2+1/14*a+5/7 ] -> [ g1, g2, g3, g4 ]

gap> elms := List( [1..10], x-> Random(F) );
[ a^3+3/4*a^2-1/2*a+3/2, 2*a^3-a^2+3/5*a+1/2, 5*a^3-3*a^2+3*a-3/2,
  1/2*a^2-2*a+3, -5/3*a^3+2*a^2-1/2*a-2, -1/2*a^3+1/2*a^2+2*a+1/6,
  -4/3*a^3-1/2*a^2+3/2*a, -1/5*a^3-1/2*a^2-2*a+3/2, -a^3-1/4*a^2+a-1,
  -1/2*a^3+2/3*a^2+2 ]

gap>  PcpPresentationOfMultiplicativeSubgroup( F, elms );
Pcp-group with orders [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]

gap> isom := IsomorphismPcpGroup( F, elms );
[ a^3+3/4*a^2-1/2*a+3/2, 2*a^3-a^2+3/5*a+1/2, 5*a^3-3*a^2+3*a-3/2,
  1/2*a^2-2*a+3, -5/3*a^3+2*a^2-1/2*a-2, -1/2*a^3+1/2*a^2+2*a+1/6,
  -4/3*a^3-1/2*a^2+3/2*a, -1/5*a^3-1/2*a^2-2*a+3/2, -a^3-1/4*a^2+a-1,
  -1/2*a^3+2/3*a^2+2 ] -> [ g1, g2, g3, g4, g5, g6, g7, g8, g9, g10 ]

gap> y := RandomGroupElement( elms );
400708754287890299488618740588744758125/181303461162849907973808794953656*a^3-\
1958247495699115084583186162669760013625/45325865290712476993452198738414*a^2+\
3464228138635737216341265036784021850125/45325865290712476993452198738414*a+44\
6487952435435917248872069547358046000/22662932645356238496726099369207

gap> z := ImageElm( isom, y );
g3^3*g5^2*g7*g8^-3*g9^-1

gap> PreImagesRepresentative( isom, z );
400708754287890299488618740588744758125/181303461162849907973808794953656*a^3-\
1958247495699115084583186162669760013625/45325865290712476993452198738414*a^2+\
3464228138635737216341265036784021850125/45325865290712476993452198738414*a+44\
6487952435435917248872069547358046000/22662932645356238496726099369207

gap> FactorsPolynomialAlgExt( F, g );
[ x_1+(-a), x_1+(a-2), x_1+(-1/7*a^3+3/7*a^2+31/7*a-40/7),
  x_1+(1/7*a^3-3/7*a^2-31/7*a+26/7) ]

gap> STOP_TEST( "manual.tst", 100000);   




















