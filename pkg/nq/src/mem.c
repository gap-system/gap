/****************************************************************************
**
**    mem.c                           NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include <stdio.h>
#include "mem.h"

static void AllocError(const char *str) {
	fflush(stdout);

	fprintf(stderr, "%s failed: ", str);
	perror("");
	exit(4);
}

void    *Allocate(unsigned nchars) {
	void    *ptr;

	ptr = (void *)calloc(nchars, sizeof(char));
	if (ptr == 0) AllocError("Allocate");

	if ((unsigned long)ptr & 0x3)
		printf("Warning, pointer not aligned.\n");
	return ptr;
}

void    *ReAllocate(void *optr, unsigned nchars) {
	optr = (void *)realloc((char *)optr, nchars);
	if (optr == (void *)0) AllocError("ReAllocate");

	if ((unsigned long)optr & 0x3)
		printf("Warning, pointer not aligned.\n");
	return optr;
}

void    Free(void *ptr) {
	free(ptr);
}
