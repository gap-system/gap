/* Test that overwrite error detection works reasonably.        */

#ifndef GC_DEBUG
# define GC_DEBUG
#endif

#include "gc.h"

#include <stdio.h>

#define COUNT 7000
#define SIZE  40

char * A[COUNT];

char * volatile q;

int main(void)
{
  int i;
  char *p;

  GC_INIT();

  for (i = 0; i < COUNT; ++i) {
     A[i] = p = (char*)GC_MALLOC(SIZE);

     if (i%3000 == 0) {
        q = NULL;
        GC_gcollect();
     } else if (i%5678 == 0 && p != 0) {
        /* Write a byte past the end of the allocated object    */
        /* but not beyond the last word of the object's memory. */
        /* A volatile intermediate pointer variable is used to  */
        /* avoid a compiler complain of out-of-bounds access.   */
        q = &p[(SIZE + i/2000) /* 42 */];
        *q = 42;
     }
  }
  return 0;
}
