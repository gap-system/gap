/****************************************************************************
**
*A  power.c                     ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: power.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"

void zero_array ();
void copy_array ();

/* power routine - written by M J Smith, May 1991.

   raise exponent vector with base address cp to power exp; 
   the method used depends on the value of the prime P;

   P = 2, 3: For each factor of P in the power the word is raised
   to the power P by multiplication P - 1 times. Any factor of the 
   power remaining is done using a P-ary decomposition.

   P > 3: A P-ary decomposition is used. Calculation of the powers
   up to P at each step are done using a binary expansion.

   Storage:
   X - exponent vect contains word on entry, will contain
       on exit of routine. Always accumulating answer.
   A - exponent string - used for multiplying a word a number of
       times in a loop (small primes) or for squaring words in binary.
   Z - In binary method, accumulates the word to the prime p
       exponent. This is used as the base word in the next iteration.
   B - Is used only in binary expansion to square the string A.
       A is unpacked into B, then collected onto B, then packed from B. */

void power (exp, cp, pcp)
int exp;
int cp;
struct pcp_vars *pcp; 
{
#include "define_y.h"

   register int p = pcp->p;
   register int lastg = pcp->lastg;
   register int x = cp;
   register int a = pcp->submlg - (lastg + 1);
   register int b = a - (lastg + 1);
   register int z = b - (lastg + 1);
   register int q, r, pp, nn;
   register int i;

   if (exp == 1) return;

   /* nn is the exponent requested */
   nn = exp;

   /* first consider small primes */
   if (p == 2 || p == 3) {

      /* extract all powers of the prime from the exponent */
      while (MOD (nn, p) == 0) {
	 nn /= p;

	 /* pack word in X into string for multiplication p - 1 times */
	 vector_to_string (x, a, pcp);
	 if (y[a + 1] == 0) return;

	 /* now multiply p - 1 times to get X^p */
	 for (i = 1; i <= p - 1; ++i) {
	    collect (-a, x, pcp);
	 }
      }

      if (nn == 1) return;

      /* have extracted all powers of p from exponent - 
	 now do rest using prime p expansion */

      /* move X into Z, set X to 1 */
      copy_array (x, lastg, z, pcp);
      zero_array (x, lastg, pcp);

      while (nn > 0) {
	 r = MOD (nn, p);
	 nn /= p;

	 /* move Z into A to multiply onto Z p - 1 times and 
	    onto X r times */
	 vector_to_string (z, a, pcp);

	 /* now calculate Z = Z^p and X = X * Z^r */
	 if (y[a + 1] != 0) {
	    for (i = 1; i <= p - 1; ++i) {
	       if (i <= r) 
		  collect (-a, x, pcp);
	       collect (-a, z, pcp);
	    }
	 }
      }
   }

   /* for larger primes, use prime p decomposition and subsequent 
      binary expansion */

   else {
      /* move X into Z and set X to 1 */
      vector_to_string (x, z, pcp);
      zero_array (x, lastg, pcp);

      while (nn > 0) {

	 /* move word w in Z into A, and set Z to 1; A will square each 
	    iteration, and Z will accumulate some of these powers to 
	    end up with w^p at end of while loop */

	 string_to_vector (z, a, pcp);
	 zero_array (z, lastg, pcp);

	 q = nn / p;
	 r = MOD (nn, p);
	 pp = p;

	 /* Now use binary expansion of both PP (ie p) and remainder R
	    to accumulate w^p in Z and w^R onto X from squaring of w.
	    Must continue until we have last w^R on X or until we get 
	    w^p in Z if there is any remaining exponent (ie Q > 0) */

	 while (r > 0 || (pp > 0 && q > 0)) {

	    /* collect onto answer if needed (ie R = 1) */
	    if (MOD (r, 2) == 1) {
	       copy_array (a, lastg, b, pcp);
	       if (y[x + 1] > 0) {
		  collect (-x, b, pcp);
	       }
	       vector_to_string (b, x, pcp);
	    }

	    /* collect onto Z for next power of w if next iteration reqd */
	    if (MOD (pp, 2) == 1 && q > 0) {
	       copy_array (a, lastg, b, pcp);
	       if (y[z + 1] > 0) {
		  collect (-z, b, pcp);
	       }
	       vector_to_string (b, z, pcp);
	    }

	    r = r >> 1;
	    pp = pp >> 1;

	    /* if powers still needed for answer X or for w^p in Z for
	       another iteration (ie Q > 0) then square A by unpacking into
	       exponent vector B, collecting A and B, then repacking into A */

	    if (r > 0 || (pp > 0 && q > 0)) {
	       /* square A */
	       vector_to_string (a, b, pcp);
	       if (y[b + 1] > 0) {
		  collect (-b, a, pcp);
	       }
	    }
	 }
	 nn = q;
      }

      /* now X is the answer as a string, so convert to exponent vector */
      string_to_vector (x, b, pcp);
      copy_array (b, lastg, x, pcp);
   }
}

/* zero a section of the array, y */

void zero_array (ptr, length, pcp)
int ptr;
int length;
struct pcp_vars *pcp; 
{
#include "define_y.h"

   register int i;

   for (i = 1; i <= length; ++i)
      y[ptr + i] = 0;
}

/* copy a section of the array, y */

void copy_array (old, length, new, pcp)
int old;
int length;
int new;
struct pcp_vars *pcp; 
{
#include "define_y.h"

   register int i;

   for (i = 1; i <= length; ++i)
      y[new + i] = y[old + i];
}
