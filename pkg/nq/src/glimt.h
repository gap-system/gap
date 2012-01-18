/****************************************************************************
**
**    glimt.h
*/

#ifndef GLIMT_H
#define GLIMT_H

#include "genexp.h" /* for expvec */

extern void freeExpVecs(expvec *M);
extern void OutputMatrix(const char *suffix);
extern int addRow(expvec ev);
extern expvec *MatrixToExpVecs(void);

#endif
