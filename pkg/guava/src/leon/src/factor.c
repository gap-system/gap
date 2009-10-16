/* File factor.c. */

#include "group.h"
#include "errmesg.h"

CHECK( factor)

extern Unsigned primeList[];


/*-------------------------- gcd ------------------------------------------*/

/* The function gcd( a, b) returns the greatest common divisor of log
   integers a and b. */

unsigned long gcd(
   unsigned long a,
   unsigned long b)
{
   unsigned long temp_a;

   if (a < b)
      {temp_a = a;  a = b;  b = temp_a;}
   while (b != 0) {
      temp_a = a;
      a = b;
      b = temp_a % b;
   }
   return a;
}


/*-------------------------- factMultiply ---------------------------------*/

/* The function factMultiply multiplies two factored integers.  Specifically,
   fmultiply( a, b) replaces a by the product a*b.  (b remains unchanged.) */

void factMultiply(
   FactoredInt *const a,
   FactoredInt *const b)   /* a = a * b */
{
   Unsigned  aIndex = 0, bIndex = 0, i;
   a->prime[a->noOfFactors] = b->prime[b->noOfFactors] = MAX_INT;
   while ( a->prime[aIndex] < MAX_INT || b->prime[bIndex] < MAX_INT )
      if ( a->prime[aIndex] < b->prime[bIndex] )
         ++aIndex;
      else if ( a->prime[aIndex] == b->prime[bIndex] )
         a->exponent[aIndex++] += b->exponent[bIndex++];
      else
         if ( a->noOfFactors < MAX_PRIME_FACTORS ) {
            for ( i = ++a->noOfFactors ; i > aIndex ; --i ) {
               a->prime[i] = a->prime[i-1];
               a->exponent[i] = a->exponent[i-1];
            }
            a->prime[aIndex] = b->prime[bIndex];
            a->exponent[aIndex++] = b->exponent[bIndex++];
         }
         else
            ERROR1i( "fMultiply", "Number of prime factored exceeded bound "
                                  "of ", MAX_PRIME_FACTORS, ".")
}



/*-------------------------- factDivide -----------------------------------*/

/* The function factDivide divides two factored integers.  Specifically,
   fmultiply( a, b) replaces a by the quotient a/b.  (b remains unchanged.)
   If b does not divide a, an error occurs. */

void factDivide(
   FactoredInt *const a,
   FactoredInt *const b)   /* a = a / b */
{
   Unsigned  aIndex = 0, bIndex = 0, i;
   a->prime[a->noOfFactors] = b->prime[b->noOfFactors] = MAX_INT;
   while ( a->prime[aIndex] < MAX_INT && b->prime[bIndex] < MAX_INT )
      if ( a->prime[aIndex] < b->prime[bIndex] )
         ++aIndex;
      else if ( a->prime[aIndex] == b->prime[bIndex] )
         if ( a->exponent[aIndex] > b->exponent[bIndex] )
            a->exponent[aIndex++] -= b->exponent[bIndex++];
         else if ( a->exponent[aIndex] == b->exponent[bIndex] ) {
            --a->noOfFactors;
            for ( i = aIndex ; i <= a->noOfFactors ; ++i ) {
               a->prime[i] = a->prime[i+1];
               a->exponent[i] = a->exponent[i+1];
            }
            ++bIndex;
         }
         else
            ERROR( "factDivide", "Divisor does not divide dividend in factored "
                                 "integer division.")
      else
         ERROR( "factDivide", "Divisor does not divide dividend in factored "
                              "integer division.")
}


/*-------------------------- factorize ------------------------------------*/

FactoredInt factorize(
   Unsigned n)
{
   FactoredInt  nFactored;
   Unsigned  i = 0, lastPrime = 0;

   nFactored.noOfFactors = 0;
   while ( primeList[i] * primeList[i] <= n && primeList[i] )
      if ( n % primeList[i] == 0 ) {
         if ( primeList[i] == lastPrime )
            ++nFactored.exponent[nFactored.noOfFactors-1];
         else if ( nFactored.noOfFactors < MAX_PRIME_FACTORS ) {
            nFactored.prime[nFactored.noOfFactors] = primeList[i];
            nFactored.exponent[nFactored.noOfFactors++] = 1;
            lastPrime = primeList[i];
         }
         else
            ERROR1i( "factorize", "Number of prime factors exceeded "
                                  "maximum of ", MAX_PRIME_FACTORS, ".")
         n /= primeList[i];
      }
      else
         ++i;

   if ( primeList[i] == 0 )
      ERROR( "factorize", "Prime number list overflow.")
   else if ( n > 1)
      if ( n == lastPrime )
         ++nFactored.exponent[nFactored.noOfFactors-1];
      else if ( nFactored.noOfFactors < MAX_PRIME_FACTORS ) {
         nFactored.prime[nFactored.noOfFactors] = n;
         nFactored.exponent[nFactored.noOfFactors++] = 1;
      }
      else
         ERROR1i( "factorize", "Number of prime factors exceeded "
                  "maximum of ", MAX_PRIME_FACTORS, ".")

   return nFactored;
}


/*-------------------------- factEqual ------------------------------------*/

BOOLEAN factEqual(
   FactoredInt *a,
   FactoredInt *b)
{
   Unsigned i;

   if ( a->noOfFactors != b->noOfFactors )
      return FALSE;
   for ( i = 0 ; i < a->noOfFactors ; ++i )
      if ( a->prime[i] != b->prime[i] || a->exponent[i] != b->exponent[i] )
         return FALSE;

   return TRUE;
}
