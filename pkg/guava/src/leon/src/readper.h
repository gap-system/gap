#ifndef READPER
#define READPER

extern Permutation *readPermutation(
   char *libFileName,
   char *libName,
   const Unsigned requiredDegree,
   const BOOLEAN inverseFlag)               /* If true, adjoin inverse. */
;

extern void writePermutation(
   char *libFileName,
   char *libName,
   Permutation *perm,
   char *format,
   char *comment)
;

extern void writePermutationRestricted(
   char *libFileName,
   char *libName,
   Permutation *perm,
   char *format,
   char *comment,
   Unsigned restrictedDegree)
;

#endif
