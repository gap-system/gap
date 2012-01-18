/****************************************************************************
 *
 * cpoly.C                                                       René Hartung
 *                                                          Laurent Bartholdi
 *
 *   @(#)$id: fr_dll.c,v 1.18 2010/10/26 05:19:40 gap exp $
 *
 * Copyright (c) 2011, Laurent Bartholdi
 *
 ****************************************************************************
 *
 * template for root-finding of complex polynomial
 *
 ****************************************************************************/

// CAUCHY COMPUTES A LOWER BOUND ON THE MODULI OF THE ZEROS OF A
// POLYNOMIAL - PT IS THE MODULUS OF THE COEFFICIENTS.
//
static xcomplex cauchy(const int deg, xcomplex *P)
{
  xreal x, xm, f, dx, df, tmp[deg+1];

  for(int i = 0; i<=deg; i++){ tmp[i] = xabs(P[i]); };

  // Compute upper estimate bound
  x = xroot(tmp[deg],deg) / xroot(tmp[0],deg);
  if(tmp[deg - 1] != 0.0) {
    // Newton step at the origin is better, use it
    xm = tmp[deg] / tmp[deg-1];
    if (xm < x) x = xm;
  }
  
  tmp[deg] = -tmp[deg];

  // Chop the interval (0,x) until f < 0
  while(1) {
    xm = x * 0.1;
    // Evaluate the polynomial <tmp> at <xm>
    f = tmp[0];
    for(int i = 1; i <= deg; i++)
      f = f * xm + tmp[i];
    
    if(f <= 0.0) break;
    x = xm;
  }
  dx = x;
   
   // Do Newton iteration until x converges to two decimal places
  while(fabs(dx / x) > 0.005) {
    f  = tmp[0];
    df = 0.0;
    for(int i = 1; i <= deg; i++){
      df = df * x + f;
      f  =  f * x + tmp[i];
    }
    
    dx = f / df;
    x -= dx;				// Newton step
  }

  return (xcomplex)(x);
}

// RETURNS A SCALE FACTOR TO MULTIPLY THE COEFFICIENTS OF THE POLYNOMIAL.
// THE SCALING IS DONE TO AVOID OVERFLOW AND TO AVOID UNDETECTED UNDERFLOW
// INTERFERING WITH THE CONVERGENCE CRITERION.  THE FACTOR IS A POWER OF THE
//int BASE.
// PT - MODULUS OF COEFFICIENTS OF P
// ETA, INFIN, SMALNO, BASE - CONSTANTS DESCRIBING THE FLOATING POINT ARITHMETIC.
//
static void scale(const int deg, xcomplex* P)
{
   int hi, lo, max, min, x, sc;

   // Find largest and smallest moduli of coefficients
   hi = (int)(xdata.MAX_EXP / 2.0);
   lo = (int)(xdata.MIN_EXP - xbits(P[0]));
   max = xlogb(P[0]); // leading coefficient does not vanish!
   min = xlogb(P[0]); 

   for(int i = 0; i <= deg; i++) {
      if (P[i] != xdata.ZERO){
        x = xlogb(P[i]);
        if(x > max) max = x;
        if(x < min) min = x;
      }
    }

   // Scale only if there are very large or very small components
   if(min >= lo && max <= hi) return;
 
   x = lo - min;
   if(x <= 0) 
      sc = -(max+min) / 2;
   else {
      sc = x;
      if(xdata.MAX_EXP - sc > max) sc = 0;
      }

   // Scale the polynomial
   for(int i = 0; i<= deg; i++){ xscalbln(&P[i],sc); }
}

// COMPUTES  THE DERIVATIVE  POLYNOMIAL AS THE INITIAL H
// POLYNOMIAL AND COMPUTES L1 NO-SHIFT H POLYNOMIALS.
//
static void noshft(const int l1, int deg, xcomplex *P, xcomplex *H)
{
  int i, j, jj;
  xcomplex t;

  // compute the first H-polynomial as the (normed) derivative of P
  for(i = 0; i < deg; i++)
    H[i] = (P[i] * (deg-i)) / deg;

  for(jj = 1; jj <= l1; jj++) {
    if(xnorm(H[deg - 1]) > xeta(P[deg-1])*xeta(P[deg-1])* 10*10 * xnorm(P[deg - 1])) {
      t = -P[deg] / H[deg-1];
      for(i = 0; i < deg-1; i++){
	j = deg - i - 1;
	H[j] = t * H[j-1] + P[j];
      }
      H[0] = P[0];
    } else {
      // if the constant term is essentially zero, shift H coefficients
      for(i = 0; i < deg-1; i++) {
	j = deg - i - 1;
	H[j] = H[j - 1];
      }
      H[0] = xdata.ZERO;
    }
  }
}

// EVALUATES A POLYNOMIAL  P  AT  S  BY THE HORNER RECURRENCE
// PLACING THE PARTIAL SUMS IN Q AND THE COMPUTED VALUE IN PV.
//
static xcomplex polyev(const int deg, const xcomplex s, const xcomplex *Q, xcomplex *q) {
   q[0] = Q[0];
   for(int i = 1; i <= deg; i++){ q[i] = q[i-1] * s + Q[i]; };
   return q[deg];
}

// COMPUTES  T = -P(S)/H(S).
// BOOL   - LOGICAL, SET TRUE IF H(S) IS ESSENTIALLY ZERO.
//
static xcomplex calct(bool *bol, int deg, xcomplex Ps, xcomplex *H, xcomplex *h, xcomplex s){
  xcomplex Hs;
  Hs = polyev(deg-1, s, H, h);
  *bol = xnorm(Hs) <= xeta(H[deg-1])*xeta(H[deg-1]) * 10*10 * xnorm(H[deg-1]);
  if(!*bol)
    return -Ps / Hs;
  else
    return xdata.ZERO;
}

// CALCULATES THE NEXT SHIFTED H POLYNOMIAL.
// BOOL   -  LOGICAL, IF .TRUE. H(S) IS ESSENTIALLY ZERO
//
static void nexth(const bool bol, int deg, xcomplex t, xcomplex *H, xcomplex *h, xcomplex *p){
   if(!bol){
      for(int j = 1; j < deg; j++)
         H[j] = t * h[j-1] + p[j];
      H[0] = p[0];
      }
   else { 
     // If h[s] is zero replace H with qh
     for(int j = 1; j < deg; j++)
        H[j] = h[j - 1];
     h[0] = xdata.ZERO;
   }
}

// BOUNDS THE ERROR IN EVALUATING THE POLYNOMIAL BY THE HORNER RECURRENCE.
// QR,QI - THE PARTIAL SUMS
// MS    -MODULUS OF THE POINT
// MP    -MODULUS OF POLYNOMIAL VALUE
// ARE, MRE -ERROR BOUNDS ON COMPLEX ADDITION AND MULTIPLICATION
//
static xreal errev(const int deg, const xcomplex *p, const xreal ms, const xreal mp){
   xreal MRE = 2.0 * sqrt(2.0) * xeta(p[0]);
   xreal e =  xabs(p[0]) * MRE / (xeta(p[0]) + MRE);

   for(int i = 0; i <= deg; i++)
      e = e * ms + xabs(p[i]);
   
   return e * (xeta(p[0]) + MRE) - MRE * mp;
}

// CARRIES OUT THE THIRD STAGE ITERATION.
// L3 - LIMIT OF STEPS IN STAGE 3.
// ZR,ZI   - ON ENTRY CONTAINS THE INITIAL ITERATE, IF THE
//           ITERATION CONVERGES IT CONTAINS THE FINAL ITERATE ON EXIT.
// CONV    -  .TRUE. IF ITERATION CONVERGES
//
static bool vrshft(const int l3, int deg, xcomplex *P, xcomplex *p, xcomplex *H, xcomplex *h, xcomplex *zero, xcomplex *s){
  bool bol, conv, b;
  int i, j;
  xcomplex Ps, t;
  xreal mp, ms, omp = 0.0, relstp = 0.0, tp;

  conv = b = false;
  *s = *zero;

  // Main loop for stage three
  for(i = 1; i <= l3; i++) {
    // Evaluate P at S and test for convergence
    Ps = polyev(deg, *s, P, p);
    mp = xabs(Ps);
    ms = xabs(*s);
    if(mp <= 20 * errev(deg, p, ms, mp)) {
      // Polynomial value is smaller in value than a bound on the error
      // in evaluating P, terminate the iteration
      conv = true;
      *zero = *s;
      return conv;
    }
    
    if(i != 1) {
      if(!(b || mp < omp || relstp >= 0.05)){
	//       if(!(b || xlogb(mp) < omp || real(relstp) >= 0.05)){
	// Iteration has stalled. Probably a cluster of zeros. Do 5 fixed 
	// shift steps into the cluster to force one zero to dominate
	tp = relstp;
	b = true;
	if(relstp < xeta(P[0])) tp = xeta(P[0]);
	
	*s *= 1.0 + (1.0+1.0i)*sqrt(tp);

	Ps = polyev(deg, *s, P, p);
	for(j = 1; j <= 5; j++){
	  t = calct(&bol, deg, Ps, H, h, *s);
	  nexth(bol, deg, t, H, h, p);
	}
	omp = xdata.INFIN;
	goto _20;
      }
         
      // Exit if polynomial value increase significantly
      if(mp * 0.1 > omp) return conv;
    }
    
    omp = mp;

    // Calculate next iterate
  _20:  t = calct(&bol, deg, Ps, H, h, *s);
    nexth(bol, deg, t, H, h, p);
    t = calct(&bol, deg, Ps, H, h, *s);
    if(!bol) {
      relstp = xabs(t) / xabs(*s);
      *s += t;
    }
  } // end for
  
  return conv;
}

// COMPUTES L2 FIXED-SHIFT H POLYNOMIALS AND TESTS FOR CONVERGENCE.
// INITIATES A VARIABLE-SHIFT ITERATION AND RETURNS WITH THE
// APPROXIMATE ZERO IF SUCCESSFUL.
// L2 - LIMIT OF FIXED SHIFT STEPS
// ZR,ZI - APPROXIMATE ZERO IF CONV IS .TRUE.
// CONV  - LOGICAL INDICATING CONVERGENCE OF STAGE 3 ITERATION
//
static bool fxshft(const int l2, int deg, xcomplex *P, xcomplex *p, xcomplex *H, xcomplex *h, xcomplex *zero, xcomplex *s){
   bool bol, conv;	 	       // boolean for convergence of stage 2
   bool test, pasd;
   xcomplex old_T, old_S, Ps, t;
   xcomplex Tmp[deg+1];

   Ps = polyev(deg, *s, P, p);
   test = true;
   pasd = false;

   // Calculate first T = -P(S)/H(S)
   t = calct(&bol, deg, Ps, H, h, *s);

   // Main loop for second stage
   for(int j = 1; j <= l2; j++){
      old_T = t;

      // Compute the next H Polynomial and new t
      nexth(bol, deg, t, H, h, p);
      t = calct(&bol, deg, Ps, H, h, *s);
      *zero = *s + t;

      // Test for convergence unless stage 3 has failed once or this
      // is the last H Polynomial
      if(!(bol || !test || j == l2)){
         if(xabs(t - old_T) < 0.5 * xabs(*zero)) {
            if(pasd) {
               // The weak convergence test has been passwed twice, start the third stage
               // Iteration, after saving the current H polynomial and shift
               for(int i = 0; i < deg; i++) 
                  Tmp[i] = H[i]; 
               old_S = *s;

               conv = vrshft(10, deg, P, p, H, h, zero, s);
               if(conv) return conv;

               //The iteration failed to converge. Turn off testing and restore h,s,pv and T
               test = false;
               for(int i = 0; i < deg; i++)
                  H[i] = Tmp[i];
               *s = old_S;

               Ps = polyev(deg, *s, P, p);
               t = calct(&bol, deg, Ps, H, h, *s);
               continue;
               }
            pasd = true;
            }
         else
            pasd = false;
      }
   }

   // Attempt an iteration with final H polynomial from second stage
   conv = vrshft(10, deg, P, p, H, h, zero, s);
   return conv;
}

// Main function
//
int cpoly(int degree, const xcomplex poly[], xcomplex Roots[])
{
  xcomplex PhiDiff = -0.069756473 + 0.99756405i;
  xcomplex PhiRand = (1.0-1.0i) /sqrt(2.0);
  xcomplex P[degree+1], H[degree+1], h[degree+1], p[degree+1], zero, s, bnd;
  unsigned int conv = 0;

  while(poly[0] == xdata.ZERO) {
    poly++;
    degree--;
    if (degree < 0)
      return -1;
  };

  int deg = degree;

  // Remove the zeros at the origin if any
  while(poly[deg] == xdata.ZERO){
    Roots[degree - deg] = xdata.ZERO;
    deg--;
  }

  if (deg == 0) return degree;
 
  // Make a copy of the coefficients
  for(int i = 0; i <= deg; i++) { P[i] = poly[i]; }

  scale(deg, P);

 search:

  if(deg <= 1){
    Roots[degree-1] = - P[1] / P[0];
    return degree;
  }
  
  // compute a bound of the moduli of the roots (Newton-Raphson)
  bnd = cauchy(deg, P);
     
  // Outer loop to control 2 Major passes with different sequences of shifts
  for(int cnt1 = 1; cnt1 <= 2; cnt1++) {
    // First stage  calculation , no shift
    noshft(5, deg, P, H);
  
    // Inner loop to select a shift
    for(int cnt2 = 1; cnt2 <= 9; cnt2++) {
      // Shift is chosen with modulus bnd and amplitude rotated by 94 degree from the previous shif
      PhiRand = PhiDiff * PhiRand;
      s = bnd * PhiRand;

      // Second stage calculation, fixed shift
      conv = fxshft(10 * cnt2, deg, P, p, H, h, &zero, &s);
      if(conv) {
	// The second stage jumps directly to the third stage iteration
	// If successful the zero is stored and the polynomial deflated
	Roots[degree - deg] = zero;

	// continue with the remaining polynomial
	deg--;
	for(int i = 0; i <= deg; i++){ P[i] = p[i]; };
	goto search;
      }
      // if the iteration is unsuccessful another shift is chosen
    }

    // if 9 shifts fail, the outer loop is repeated with another sequence of shifts
  }

  // The zerofinder has failed on two major passes
  // return empty handed with the number of roots found (less than the original degree)
  return degree - deg;
}
