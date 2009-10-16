gap> START_TEST("Test of documentation examples in package RadiRoot");  
gap> f := UnivariatePolynomial( Rationals, [1,3,4,1] );
x_1^3+4*x_1^2+3*x_1+1
gap> L := SplittingField( f );
<algebraic extension over the Rationals of degree 6>
gap> FactorsPolynomialAlgExt( L, f );
[ x_1+((-168/47-535/94*a-253/94*a^2-24/47*a^3-3/94*a^4)), 
  x_1+((20/47-441/94*a-253/94*a^2-24/47*a^3-3/94*a^4)), 
  x_1+((336/47+488/47*a+253/47*a^2+48/47*a^3+3/47*a^4)) ]
gap> IsomorphicMatrixField( L );
<rational matrix field of degree 6>
gap> Display(RootsAsMatrices(f)[1]);
[ [   0,   1,   0,   0,   0,   0 ],
  [   0,   0,   1,   0,   0,   0 ],
  [  -1,  -3,  -4,   0,   0,   0 ],
  [   0,   0,   0,   0,   1,   0 ],
  [   0,   0,   0,   0,   0,   1 ],
  [   0,   0,   0,  -1,  -3,  -4 ] ]
gap> MinimalPolynomial( Rationals, RootsAsMatrices(f)[1]);
x_1^3+4*x_1^2+3*x_1+1
gap> iso := IsomorphismMatrixField( L );
MappingByFunction( <algebraic extension over the Rationals of degree
6>, <rational matrix field of degree
6>, function( x ) ... end, function( mat ) ... end )
gap> PreImages( iso, RootsAsMatrices( f ) );
[ (-336/47-488/47*a-253/47*a^2-48/47*a^3-3/47*a^4),
  (-20/47+441/94*a+253/94*a^2+24/47*a^3+3/94*a^4), 
  (168/47+535/94*a+253/94*a^2+24/47*a^3+3/94*a^4) ]
gap> GaloisGroupOnRoots(f);
Group([ (2,3), (1,2) ])
gap> g := UnivariatePolynomial( Rationals, [1,1,-1,-1,1] );
x_1^4-x_1^3-x_1^2+x_1+1
gap> RootsOfPolynomialAsRadicalsNC( g, "off" );
gap> SplittingField( g );
<algebraic extension over the Rationals of degree 8>
gap> GaloisGroupOnRoots( g );
Group([ (2,4), (1,2)(3,4) ])
gap> poly := UnivariatePolynomial( Rationals, [2,-4,0,0,0,1] );
x_1^5-4*x_1+2
gap> RootsOfPolynomialAsRadicals( poly );
#I  Polynomial is not solvable.
fail
gap> STOP_TEST( "docexmpl.tst", 100000);   




















