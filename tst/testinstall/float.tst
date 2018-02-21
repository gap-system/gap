#############################################################################
##
#W  float.tst                   GAP Tests                         Stefan Kohl
##
##
gap> START_TEST("float.tst");

# make sure we are testing the built-in machine floats
gap> SetFloats(IEEE754FLOAT);

# some special values we will use again later on
gap> posinf := 1.0/0.0;
inf
gap> neginf := -1.0/0.0;
-inf
gap> nan := 0.0/0.0;
nan

#
# Convert things to floats
#
gap> Float(3);
3.
gap> Float(-4);
-4.
gap> Float(2/3);
0.666667
gap> Float("-4");
-4.
gap> Float("4.1");
4.1
gap> Float("4.1e-1");
0.41
gap> Float(infinity);
inf
gap> Float(-infinity);
-inf

#
# input floats directly
#
gap> 0.6;
0.6
gap> -0.7;
-0.7

#
# some arithmetic
#
gap> 355.0/113.0;
3.14159
gap> last = 355.0/113;
false
gap> 355.0/113.0-355/113;
0.
gap> 355.0/113.0 = 355.0/113;
false
gap> 355.0/113.0 < 355.0/113;
false
gap> 355.0/113.0 > 355.0/113;
true
gap> 355.0/113;
3.14159
gap> 355.0/113.0 - 355.0/113;
4.44089e-16
gap> 355/113.0 = 355.0/113.0;
false
gap> 355/113.0 - 355.0/113.0;
-4.44089e-16
gap> 355/113.0 - 355.0/113;
0.
gap> 355/113.0 = 355.0/113;
true

#
# convert floats to other types
#
gap> Rat(355.0/113.0);
355/113
gap> Int(1.0);
1
gap> Int(1.5);
1
gap> Int(-1.0);
-1
gap> Int(-1.5);
-1
gap> Rat(0.5);
1/2
gap> Rat(0.0);
0

#
#
#
gap> Sqrt(2.0);
1.41421
gap> MinimalPolynomial(Rationals,last);
-2*x_1^2+1
gap> r:=Rat("2.7182818");; r:=Rat(Float(String(NumeratorRat(r)))/Float(String(DenominatorRat(r))));
2683788193/987310511
gap> Float(String(NumeratorRat(r)))/Float(String(DenominatorRat(r)));
2.71828
gap> AbsoluteValue(Float("1")/Float("2"));
0.5
gap> AbsoluteValue(Float("-1")/Float("2"));
0.5
gap> AbsoluteValue(-Float("1")/Float("2"));
0.5
gap> AbsoluteValue(-Float("0"));
0.
gap> Float(List([1..100],n->1/Factorial(n)));
[ 1., 0.5, 0.166667, 0.0416667, 0.00833333, 0.00138889, 0.000198413, 
  2.48016e-05, 2.75573e-06, 2.75573e-07, 2.50521e-08, 2.08768e-09, 
  1.6059e-10, 1.14707e-11, 7.64716e-13, 4.77948e-14, 2.81146e-15, 
  1.56192e-16, 8.22064e-18, 4.11032e-19, 1.95729e-20, 8.89679e-22, 
  3.86817e-23, 1.61174e-24, 6.44695e-26, 2.4796e-27, 9.18369e-29, 
  3.27989e-30, 1.131e-31, 3.76999e-33, 1.21613e-34, 3.80039e-36, 1.15163e-37, 
  3.38716e-39, 9.67759e-41, 2.68822e-42, 7.26546e-44, 1.91196e-45, 
  4.90247e-47, 1.22562e-48, 2.98931e-50, 7.11741e-52, 1.65521e-53, 
  3.76184e-55, 8.35965e-57, 1.81732e-58, 3.86663e-60, 8.05548e-62, 
  1.64397e-63, 3.28795e-65, 6.44696e-67, 1.2398e-68, 2.33925e-70, 
  4.33194e-72, 7.87625e-74, 1.40647e-75, 2.4675e-77, 4.2543e-79, 7.21068e-81, 
  1.20178e-82, 1.97013e-84, 3.17763e-86, 5.04386e-88, 7.88103e-90, 
  1.21247e-91, 1.83707e-93, 2.7419e-95, 4.0322e-97, 5.84377e-99, 
  8.34824e-101, 1.17581e-102, 1.63307e-104, 2.23708e-106, 3.02308e-108, 
  4.03077e-110, 5.30365e-112, 6.88785e-114, 8.83058e-116, 1.1178e-117, 
  1.39724e-119, 1.72499e-121, 2.10365e-123, 2.53452e-125, 3.01728e-127, 
  3.54974e-129, 4.12761e-131, 4.74438e-133, 5.39134e-135, 6.05769e-137, 
  6.73076e-139, 7.39644e-141, 8.03961e-143, 8.64474e-145, 9.19653e-147, 
  9.68056e-149, 1.00839e-150, 1.03958e-152, 1.0608e-154, 1.07151e-156, 
  1.07151e-158 ]
gap> 1.5e10;
1.5e+10
gap> -1.5e0;
-1.5
gap> 0.7e-10;
7.e-11
gap> -0.8e-0;
-0.8
gap> 1000000000000000000000000000000000000000000000000000000000000000\
> 00000000000000000000000000000000000000000000000000000000000000.0;
1.e+125
gap> 1.5+1;
2.5
gap> last-1.6;
0.9
gap> last*2;
1.8
gap> last/2.0;
0.9
gap> Sqrt(last);
0.948683
gap> Log(last);
-0.0526803
gap> Exp(last);
0.948683
gap> last^2;
0.9

#
# some tests with infinity
#
gap> 1.0/0.0;
inf
gap> -1.0/0.0;
-inf
gap> List([posinf, neginf, nan, 0.0, 1.0], IsPInfinity);
[ true, false, false, false, false ]
gap> List([posinf, neginf, nan, 0.0, 1.0], IsNInfinity);
[ false, true, false, false, false ]
gap> -posinf = neginf;
true
gap> posinf = -neginf;
true
gap> neginf < posinf;
true
gap> neginf <> posinf;
true
gap> neginf < 0.0;
true
gap> 0.0 < posinf;
true
gap> MakeFloat(1.0, infinity) = posinf;
true
gap> -MakeFloat(1.0, infinity) = neginf;
true
gap> MakeFloat(1.0, -infinity) = neginf;
true

#
# test sign handling
#
gap> SignBit(posinf);
false
gap> SignFloat(posinf);
1
gap> SignBit(neginf);
true
gap> SignFloat(neginf);
-1
gap> SignBit(+0.0);
false
gap> SignFloat(+0.0);
0
gap> SignBit(-0.0);
true
gap> SignFloat(-0.0);
0
gap> SignBit(42.0);
false
gap> SignFloat(42.0);
1
gap> SignBit(-42.0);
true
gap> SignFloat(-42.0);
-1

# sign of NaN is machine specific; but we can still test whether
# SignBit and SignFloat return consistent results
gap> SignBit(nan) = (SignFloat(nan) = -1);
true
gap> SignBit(-nan) = (SignFloat(-nan) = -1);
true

#
# test float comparison
#

#
gap> EqFloat(1.0, 1.1);
false
gap> EqFloat(1.0, 1.0);
true
gap> EqFloat(0.0/0.0,0.0/0.0);
false
gap> EqFloat(0.0,0.0/0.0);
false

#
# float literal expressions in functions
#

# eager literal
gap> f := {} -> 0.0_;; f();
0.
gap> f := {} -> 1.0_;; f();
1.
gap> f := {} -> 42.0_;; f();
42.
gap> Display(f);
function (  )
    return 42.0_;
end

# lazy literal
gap> g := {} -> 0.0;; g();
0.
gap> g := {} -> 1.0;; g();
1.
gap> g := {} -> 23.0;; g();
23.
gap> Display(g);
function (  )
    return 23.0;
end

#
gap> STOP_TEST( "float.tst", 1);

#############################################################################
##
#E  float.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
