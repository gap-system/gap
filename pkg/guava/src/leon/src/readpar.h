#ifndef READPAR
#define READPAR

extern Partition *readPartition(
   char *libFileName,
   char *libName,
   Unsigned degree)
;

extern void writePartition(
   char *libFileName,
   char *libName,
   char *comment,
   Partition *partn)
;

#endif
