/****************************************************************************
**
**    mem.h                           NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include <stdlib.h>	/* for malloc, calloc */
#include <string.h> /* for memcpy */

extern void	*Allocate();
extern void	*ReAllocate();
extern void	Free();

