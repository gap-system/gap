#ifndef READPTS
#define READPTS

extern PointSet *readPointSet(
   char *libFileName,
   char *libName,
   Unsigned degree)
;

extern void writePointSet(
   char *libFileName,
   char *libName,
   char *comment,
   PointSet *P)
;

#endif
