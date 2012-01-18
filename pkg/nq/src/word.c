/*****************************************************************************
**
**    word.c                          NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


#include "nq.h"

void    printGen(gen g, char c) {
	putchar(c + (g - 1) % 26);
	if ((g - 1) / 26 != 0)
		printf("%d", (g - 1) / 26);
}

void    printWord(word w, char c) {
	if (w == (word)0 || w->g == EOW) {
		printf("Id");
		return;
	}

	while (w->g != EOW) {
		if (w->g > 0) {
			printGen(w->g, c);
			if (w->e != (expo)1)
				printf("^"EXP_FORMAT, w->e);
		} else {
			printGen(-w->g, c);
			printf("^"EXP_FORMAT, -w->e);
		}
		w++;
		if (w->g != EOW) putchar('*');
	}
}
