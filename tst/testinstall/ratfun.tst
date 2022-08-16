#@local det,mat,p0,p1,p2,q0,q1,q2,t,y1,y2,y3,u,f,g,data
gap> START_TEST("ratfun.tst");

#
gap> t:=Indeterminate(Rationals,100);;
gap> SetName(t,"t");;
gap> u:=Indeterminate(Rationals,101);;
gap> SetName(u,"u");;

#
# test basic properties
#
gap> data := [ 0*t, t^0, t, t+1, 1/t, 1/(t+1), t+u, t/u, t/(u+1), 0, 1/2 ];
[ 0, 1, t, t+1, t^-1, (1)/(t+1), t+u, t/u, t/(u+1), 0, 1/2 ]
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
gap> List(data, x -> x * Zero(t));
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> ForAll(last,IsUnivariatePolynomial and IsZero);
true
gap> List(data, x -> Zero(t) * x);
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> ForAll(last,IsUnivariatePolynomial and IsZero);
true
gap> List(data, x -> One(t) * x);
[ 0, 1, t, t+1, t^-1, (1)/(t+1), t+u, t/u, t/(u+1), 0, 1/2 ]
gap> last = data*t^0;
true
gap> List(data, x -> x * One(t));
[ 0, 1, t, t+1, t^-1, (1)/(t+1), t+u, t/u, t/(u+1), 0, 1/2 ]
gap> last = data*t^0;
true

# addition
gap> List(data, x -> x + Zero(t));
[ 0, 1, t, t+1, t^-1, (1)/(t+1), t+u, t/u, t/(u+1), 0, 1/2 ]
gap> last = data*t^0;
true
gap> List(data, x -> Zero(t) + x);
[ 0, 1, t, t+1, t^-1, (1)/(t+1), t+u, t/u, t/(u+1), 0, 1/2 ]
gap> last = data*t^0;
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
1
gap> Value(t^0,-1);
1
gap> Value(t,-1);
-1

#
gap> t(0);
0
gap> t(1);
1
gap> (t+1)(3);
4
gap> data[4](3);
4

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
[ t-1, t+1, t^2-t+1, t^2+1, t^2+t+1, t^4-t^2+1, t^4+1, t^8-t^4+1 ]
gap> (t^24-1)/(t^16-1);
(t^16+t^8+1)/(t^8+1)
gap> (t^24-1)/(t^-16-1);
(t^32+t^24+t^16)/(-t^8-1)

# factor over rationals
gap> Factors(t^0);
[ 1 ]
gap> Factors(t^1);
[ t ]
gap> Factors(t^2);
[ t, t ]
gap> Factors(t-1);
[ t-1 ]
gap> Factors((t-1)*t);
[ t-1, t ]
gap> Factors((t-1)*t^2);
[ t-1, t, t ]
gap> Factors(t^2-1);
[ t-1, t+1 ]
gap> Factors((t^2-1)*t);
[ t-1, t, t+1 ]
gap> Factors((t^2-1)*t^2);
[ t-1, t, t, t+1 ]

# factor over abelian number field
gap> Factors(E(7)*t^0);
[ E(7) ]
gap> Factors(E(7)*t^1);
[ E(7)*t ]
gap> Factors(E(7)*t^2);
[ E(7)*t, t ]
gap> Factors(E(7)*(t-1));
[ E(7)*t+(-E(7)) ]
gap> Factors(E(7)*(t-1)*t);
[ E(7)*t, t-1 ]
gap> Factors(E(7)*(t-1)*t^2);
[ E(7)*t, t, t-1 ]
gap> Factors(E(7)*t^2-1);
[ E(7)*t+(-E(7)^4), t+E(7)^3 ]
gap> Factors(E(7)*(t^2-1)*t);
[ E(7)*t+(-E(7)), t, t+1 ]
gap> Factors(E(7)*(t^2-1)*t^2);
[ E(7)*t+(-E(7)), t, t, t+1 ]

# gcd
gap> Gcd(t-2,t^2-2*t);
t-2
gap> Gcd((t-2)*(t^15-7*t^6+123456),(t^2-2*t)*(t^13+t^2-1));
t-2

# ApproxRootBound, RootBound
gap> f := t-1;; ApproxRootBound(f); RootBound(f);
67/60
67/60
gap> f := t-2;; ApproxRootBound(f); RootBound(f);
fail
2
gap> f := t^13+t^2-1;; ApproxRootBound(f); RootBound(f);
fail
2
gap> f := t^15-7*t^6+123456;; ApproxRootBound(f); RootBound(f);
1309/580
1309/580
gap> f := (t-2)*(t^15-7*t^6+123456)*(t^2-2*t)*(t^13+t^2-1);;
gap> ApproxRootBound(f); RootBound(f);
fail
6350587813037534063249833/74175632498330000000000

# PolynomialModP
gap> PolynomialModP(t^5 + 20 * t + 25, 2);
x_100^5+Z(2)^0
gap> PolynomialModP(t^5 + 20 * t + 25, 3);
x_100^5-x_100+Z(3)^0

#
# multivariate
#
gap> (t^24-u^2)/(t^16-u^4);
(t^24-u^2)/(t^16-u^4)
gap> f:=u*(t^24-1);; g:=u^2*(t^16-1);;
gap> f/g;
(t^24*u-u)/(t^16*u^2-u^2)
gap> Factors(f);
[ u, t-1, t+1, t^2+1, t^2-t+1, t^2+t+1, t^4+1, t^4-t^2+1, t^8-t^4+1 ]
gap> Factors(t^4-u^4);
[ t-u, t+u, t^2+u^2 ]

# multivariate gcd
gap> Gcd(DefaultRing(f),f,g);
t^8*u-u
gap> Gcd(f,g);
t^8*u-u
gap> Gcd(t, u/3);
1

#
gap> STOP_TEST( "ratfun.tst", 1);
