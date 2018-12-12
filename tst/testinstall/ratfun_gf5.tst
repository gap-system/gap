gap> START_TEST("ratfun_gf5.tst");

#
gap> t:=Indeterminate(GF(5),100);;
gap> SetName(t,"t");;
gap> u:=Indeterminate(GF(5),101);;
gap> SetName(u,"u");;

#
# test basic properties
#
gap> data := [ 0*t, t^0, t, t+1, 1/t, 1/(t+1), t+u, t/u, t/(u+1), 0, 1/2 ];;
gap> List(data, IsRat);
[ false, false, false, false, false, false, false, false, false, true, true ]
gap> List(data, IsRationalFunction);
[ true, true, true, true, true, true, true, true, true, false, false ]
gap> List(data, IsConstantRationalFunction);
[ true, true, false, false, false, false, false, false, false, false, false ]
gap> List(data, IsPolynomial);
[ true, true, true, true, false, false, true, false, false, false, false ]
gap> List(data, IsUnivariatePolynomial);
[ true, true, true, true, false, false, false, false, false, false, false ]
gap> List(data, IsUnivariateRationalFunction);
[ true, true, true, true, true, true, false, false, false, false, false ]
gap> List(data, IsLaurentPolynomial);
[ true, true, true, true, true, false, false, false, false, false, false ]

#
# arithmetics
#

# multiplication
gap> ForAll(List(data, x -> x * Zero(t)), IsUnivariatePolynomial and IsZero);
true
gap> ForAll(List(data, x -> Zero(t) * x), IsUnivariatePolynomial and IsZero);
true
gap> ForAll(List(data, x -> One(t) * x) - data, IsUnivariatePolynomial and IsZero);
true
gap> ForAll(List(data, x -> x * One(t)) - data, IsUnivariatePolynomial and IsZero);
true

# addition
gap> ForAll(List(data, x -> Zero(t) + x) - data, IsUnivariatePolynomial and IsZero);
true
gap> ForAll(List(data, x -> x + Zero(t)) - data, IsUnivariatePolynomial and IsZero);
true

# commutative
gap> SetX(data, data, {x,y} -> x*y = y*x);
[ true ]
gap> SetX(data, data, {x,y} -> x+y = y+x);
[ true ]

# associative
gap> SetX(data, data, data, {x,y,z} -> (x*y)*z = x*(y*z));
[ true ]
gap> SetX(data, data, data, {x,y,z} -> (x+y)+z = x+(y+z));
[ true ]

# distributive
gap> SetX(data, data, data, {x,y,z} -> (x+y)*z = x*z+y*z);
[ true ]

#
gap> Value(0*t,1);
0
gap> Value(t^0,1);
Z(5)^0
gap> Value(t^0,-1);
Z(5)^0
gap> Value(t,-1);
Z(5)^2

#
gap> y1:=Indeterminate(Rationals,1);;
gap> y2:=Indeterminate(Rationals,2);;
gap> y3:=Indeterminate(Rationals,3);;
gap> mat:=[[y1,1,0],[y2,y1,1],[y3,y2,y1]];;
gap> det:=DeterminantMat(mat*y1^0);;
gap> Value(det,[y1,y2,y3],[1,-5,1]);
12
gap> 1/( y1*y2 );
1/(x_1*x_2)

#
gap> Factors(t^24-1);
[ t+Z(5)^0, t+Z(5), t-Z(5)^0, t+Z(5)^3, t^2+Z(5), t^2+Z(5)^3, t^2+t+Z(5)^0, 
  t^2+t+Z(5), t^2+Z(5)*t-Z(5)^0, t^2+Z(5)*t+Z(5)^3, t^2-t+Z(5)^0, t^2-t+Z(5), 
  t^2+Z(5)^3*t-Z(5)^0, t^2+Z(5)^3*t+Z(5)^3 ]
gap> (t^24-1)/(t^16-1);
(t^16+t^8+Z(5)^0)/(t^8+Z(5)^0)
gap> (t^24-1)/(t^-16-1);
(t^32+t^24+t^16)/(-t^8-Z(5)^0)

#
# multivariate
#
gap> (t^24-u^2)/(t^16-u^4);
(t^24-u^2)/(t^16-u^4)
gap> f:=u*(t^24-1);; g:=u^2*(t^16-1);;
gap> f/g;
(t^24*u-u)/(t^16*u^2-u^2)
gap> Factors(f);
[ u, t+Z(5)^0, t+Z(5), t-Z(5)^0, t+Z(5)^3, t^2+Z(5), t^2+Z(5)^3, 
  t^2+t+Z(5)^0, t^2+t+Z(5), t^2+Z(5)*t-Z(5)^0, t^2+Z(5)*t+Z(5)^3, 
  t^2-t+Z(5)^0, t^2-t+Z(5), t^2+Z(5)^3*t-Z(5)^0, t^2+Z(5)^3*t+Z(5)^3 ]
gap> Factors(t^4-u^4);
[ t+u, t+Z(5)*u, t-u, t+Z(5)^3*u ]

# multivariate gcd
gap> Gcd(DefaultRing(f),f,g);
t^8*u-u
gap> Gcd(f,g);
t^8*u-u

#
gap> STOP_TEST( "ratfun_gf5.tst", 1);
