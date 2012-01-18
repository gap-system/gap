/*****************************************************************************
**
**    time.c                          NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include "config.h"
#include "time.h"

#include <stdio.h>

int CombiCollectionTime  = 0;
int SimpleCollectionTime = 0;

int IntMatTime     = 0;

void PrintCollectionTimes(void) {

	if (CombiCollectionTime > 0)
		printf("##  Total time spent in combinatorial collection: %d\n",
		       CombiCollectionTime);

	if (SimpleCollectionTime > 0)
		printf("##  Total time spent in simple collection: %d\n",
		       SimpleCollectionTime);

	printf("##  Total time spent on integer matrices: %d\n", IntMatTime);

}
