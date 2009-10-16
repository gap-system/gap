#ifndef READGRP
#define READGRP

extern FactoredInt readFactoredInt(void)
;

extern void writeFactoredInt(
   FactoredInt *fInt)
;

extern TokenType readCyclePerm(
   Permutation *perm)
;

extern TokenType readImagePerm(
   Permutation *perm)
;

extern Permutation *readPerm(
   const Unsigned degree,        /* Degree of permutation to be read. */
   PermFormat *const format,     /* Set to cycleFormat or imageFormat. */
   TokenType *const terminator)  /* Set to type of token (comma, semicolon, or
                                   eof, or right square bracket) that terminated
                                   the permutation. */
;

extern PermGroup *readPermGroup(
   char *libFileName,             /* The library file containing the group. */
   char *libName,                 /* The library defining the group. */
   const Unsigned requiredDegree, /* The degree that the group must have,
                                     or zero if group may have any degree. */
   const char *rpgOptions)        /* Options:
                                      Generate:       generate base/sgs
                                                      if absent,
                                      CompleteOrbits: construct complete orbit
                                                     structure. */
;

extern void setOutputFile(
   FILE *grpFile)
;

extern void writeCyclePerm(
   Permutation *s,        /* The permutation to write. */
   Unsigned startCol1,    /* First line starts in this column. */
   Unsigned startCol2,    /* Remaining lines start in this column. */
   Unsigned endCol)       /* Lines end by this column. */
;

extern void writeImagePerm(
   Permutation *s,          /* The permutation to write. */
   Unsigned startCol1,      /* First line starts in this column. */
   Unsigned startCol2,      /* Remaining lines start in this column. */
   Unsigned endCol)         /* Lines end by this column. */
;

extern void writeImageMonomialPerm(
   Permutation *s,          /* The permutation to write. */
   Unsigned fieldSize,
   Unsigned startCol2)      /* Remaining lines start in this column. */
;

extern void writePermGroup(
   char *libFileName,
   char *libName,
   PermGroup *G,
   char *comment)
;

extern void writePermGroupRestricted(
   char *libFileName,
   char *libName,
   PermGroup *G,
   char *comment,
   Unsigned restrictedDegree)
;

#endif
