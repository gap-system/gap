/* File primes.c.  Contains a null-terminated array of primes up to 256. */

#include "group.h"

#include "errmesg.h"

CHECK( primes)

Unsigned primeList[] = {2,3,5,7,9,11,13,17,19,23,29,31,37,41,43,47,53,59,
                          61,67,71,73,79,83,89,97,101,103,107,109,113,127, 131,
                          137,139,149,151,157,163,167,173,179,181,191,193,197,
                          199,211,223,227,229,233,239,241,251,0};


/*-------------------------- isPrime --------------------------------------*/

/* The function isPrime( n) returns TRUE exactly when the quantity n
   of type Unsigned is prime.  It can only be used to test positive integers
   which, if not prime, have a prime factor in the list primeList above. 
   (This is not checked.) */

BOOLEAN isPrime(
   const Unsigned n)
{
   Unsigned d;

   if ( n > 256L * 256L )
      ERROR( "isPrime", "Attempt to apply function isPrime to integer out of range.");

   for ( d = 0 ; primeList[d] != 0 && (unsigned long) primeList[d] * primeList[d] 
                 <= (unsigned long) n ; ++d )
      if ( n % primeList[d] == 0 )
         return FALSE;

   return TRUE;
}


