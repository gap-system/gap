/****************************************************************************
**
**    mem.h                           NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#ifndef MEM_H
#define MEM_H

#include <stdlib.h>     /* for malloc, calloc */
#include <string.h> /* for memcpy */

extern void     *Allocate(unsigned nchars);
extern void     *ReAllocate(void *optr, unsigned nchars);
extern void     Free(void *ptr);

#endif
