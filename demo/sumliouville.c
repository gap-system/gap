
/* The Liouville function on a integer n is L(n) = (-1)^r where r is
   the number of prime factors in the prime factorization of n (L(1) = 1).
   This program is called as 
           sumliouville begin end 
   and prints the sum of L(n) for n from 'begin' to 'end'. 
  
   Compile with 
               gcc -O2 -Wall -g -o sumliouville sumliouville.c -lm 

   This program is an interesting example with respect to starting
   several of them at the same time. On an Intel quad-core with 
   hyperthreading I found that the single processes can become a factor
   of 6 and more slower when 8 instances of this program are started at
   the same time. 

   The slightly more complicated variant sumliouville2 is more
   efficient for well chosen interval lengths, and behaves well when
   several instances are run in parallel.
*/

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <math.h>

long begin, end, l;
char *res;
long * found;

long lsqrt(long n)
{
  double dn;
  dn = sqrt(n);
  return floor(dn);
}

inline void do_p(long p)
{
  long q, k, start;
  for (q = p; q <= end; q *= p){
    start = (-begin) % q + 1;
    if (start <= 0) start += q; 
    for (k = start; k <= l; k += q){
      res[k] = -res[k];
      found[k] *= p;
    }
  }
  /*
  printf("\n"); for (k=1; k<=l; k++) printf("%ld ",(long)res[k]);
  printf("\n"); for (k=1; k<=l; k++) printf("%ld ",found[k]);
  printf("\n"); */
}

int main(int argc, char *argv[])
{
  long i, k, p, n, n2, off, sum;
  char *erat;

  begin = atol(argv[1]);
  end = atol(argv[2]);

  /* compute primes */
  n = lsqrt(end)+1;
  n2 = n/2;
  erat = (char*) malloc((n2+1) * sizeof(char));
  for (i=0; (2*i+1)*(2*i+1) <= n; ) {
    i++;
    while (erat[i] == 1) i++;
    p = 2*i+1;
    for (k = (p*p-1)/2; k <= n2; k += p) erat[k] = 1;
  }
  
  /* init memory */
  l = end - begin + 1;
  res = (char*) malloc((l+1)*sizeof(char));
  for(i=1; i<=l; i++) res[i] = 1;
  found = (long*) malloc((l+1)*sizeof(long));
  for(i=1; i<=l; i++) found[i] = 1;
 
  /* mark parity of number of prime factors */
  do_p(2);
  for (i = 1; i <= n2; i++) {
    if (erat[i] == 0) {do_p(2*i + 1); }//printf("%ld ",2*i+1); fflush(stdout);}
  }
  
  /* compute sum */
  sum = 0;
  off = begin-1;
  for (i=1; i<=l; i++) {
    if (found[i] < off+i) sum -= res[i]; /* one more prime */
    else sum += res[i];
  }
  printf("%ld\n", sum);
  return 0;
}

