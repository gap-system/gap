/****************************************************************************
**
**    pcarith.h                       PC                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#ifndef PCARITH_H
#define PCARITH_H

#include "genexp.h"

typedef word (*WordGenerator)(gen);

extern  void    WordCopyExpVec(expvec ev, word w);
extern  word    WordExpVec(expvec ev);
extern  expvec  ExpVecWord(word w);
extern  int     WordCmp(word u, word w);
extern  void    WordCopy(word u, word w);
extern  int     WordLength(word w);
extern  void    WordInit(WordGenerator generator);
extern  void    WordPrint(word gs);


extern word WordGen(gen g);
extern word WordEngel(word u, word w, int *e);
extern word WordComm(word u, word w);

#endif
