#ifndef FACTOR
#define FACTOR

extern unsigned long gcd(
   unsigned long a,
   unsigned long b)
;

extern void factMultiply(
   FactoredInt *const a,
   FactoredInt *const b)   /* a = a * b */
;

extern void factDivide(
   FactoredInt *const a,
   FactoredInt *const b)   /* a = a / b */
;

extern FactoredInt factorize(
   Unsigned n)
;

extern BOOLEAN factEqual(
   FactoredInt *a,
   FactoredInt *b)
;

#endif
