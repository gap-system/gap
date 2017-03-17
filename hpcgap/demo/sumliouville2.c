
/* The Liouville function on a integer n is L(n) = (-1)^r where r is
   the number of prime factors in the prime factorization of n (L(1) = 1).
   This program is called as 
           sumliouville2 begin end intlen
   and prints the sum of L(n) for n from 'begin' to 'end'. The sums are
   computed interval wise, and the length of the intervals is given as
   'intlen' (such that one can play with this length, values between 
   10000 and 100000 seem to be good).
  
   Compile with 
               gcc -O2 -Wall -g -o sumliouville2 sumliouville2.c -lm 
*/
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <math.h>

long begin, end, intlen, len, l;
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
    for (k = start; k <= len; k += q){
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
  long beginall, endall, i, k, p, n, n2, off, sum;
  char *erat, *resall;

  beginall = atol(argv[1]);
  endall = atol(argv[2]);
  intlen = atol(argv[3]);

  /* compute primes */
  n = lsqrt(endall)+1;
  n2 = n/2;
  erat = (char*) malloc((n2+1) * sizeof(char));
  for (i=0; (2*i+1)*(2*i+1) <= n; ) {
    i++;
    while (erat[i] == 1) i++;
    p = 2*i+1;
    for (k = (p*p-1)/2; k <= n2; k += p) erat[k] = 1;
  }
  
  /* init memory */
  l = endall - beginall + 1;
  resall = (char*) malloc((l+1)*sizeof(char));
  for(i=1; i<=l; i++) resall[i] = 1;
  found = (long*) malloc((intlen+1)*sizeof(long));
  
  end = beginall + intlen - 1;
  if (end > endall) end = endall;
  for (begin = beginall, res = resall; end <= endall; 
                                       begin += intlen, res += intlen) {
    len = end - begin + 1;
    for(i=1; i<=len; i++) found[i] = 1;
    /* mark parity of number of prime factors */
    do_p(2);
    for (i = 1; i <= n2; i++) {
      if (erat[i] == 0) {do_p(2*i + 1); }
    }
    /* adjust if one more prime */
    off = begin-1;
    for (i=1; i<=len; i++) 
      if (found[i] < off+i) res[i] = -res[i];

    /* end of next intervall */
    if (end == endall)
      end += 1;
    else {
      end += intlen;
      if (end > endall) end = endall;
    }
  }
  
  /* compute sum */
  sum = 0;
  for (i=1; i<=l; i++) {
    sum += resall[i];
  }
  printf("%ld\n", sum);
  return 0;
}

