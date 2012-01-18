/****************************************************************************
**
**    trmetab.c                       NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include "nq.h"
#include "engel.h"
#include "glimt.h"

static int NrWords = 0;
static int TrMetAb = 0;

static void Error(word v, word w) {
	printf("Overflow in collector computing [ ");
	printWord(v, 'a');
	printWord(w, 'a');
	printf(" ]\n");
}

static void eval8Power(word u) {
	word  uu;
	int   needed;

	/*    printf( "eval8Power() called with : " );
	    printWord( u, 'A' );
	    putchar( '\n' );
	*/
	uu = Exponentiate(u, 8);
	needed = addRow(ExpVecWord(uu));

	if (needed) {
		printf("#    (");
		printWord(u, 'A');
		printf(")^8\n");
	}
	free(uu);
}

static void evalTrMetAbRel(word *ul) {
	word    u, uu, vv;
	long    i, needed;

	/*      printf( "evalTrMetAbRel() called with : " );
	        for( i = 0; i < 6; i++ ) {
	            printWord( ul[i], 'A' ); printf( "    " );
	        }
	        putchar( '\n' );
	*/
	NrWords++;
	/* Calculate [ [ ul[0], ul[1] ], ul[2] ] */
	if ((u = Commutator(ul[0], ul[1])) == (word)0) {
		Error(ul[0], ul[1]);
		return;
	}
	if ((uu = Commutator(u, ul[2])) == (word)0) {
		Error(u, ul[2]);
		return;
	}
	free(u);
	/* Calculate [ [ ul[3], ul[4] ], ul[5] ] */
	if ((u = Commutator(ul[3], ul[4])) == (word)0) {
		Error(ul[3], ul[4]);
		return;
	}
	if ((vv = Commutator(u, ul[5])) == (word)0) {
		Error(u, ul[5]);
		return;
	}
	free(u);

	u = Commutator(uu, vv);
	free(uu);
	free(vv);

	needed = addRow(ExpVecWord(u));
	if (needed) {
		printf("#    [ [");
		for (i = 0; i < 3; i++) {
			printWord(ul[i], 'A');
			if (i != 2) printf(",");
		}
		printf("], [");
		for (i = 3; i < 6; i++) {
			printWord(ul[i], 'A');
			if (i != 5) printf(",");
		}
		printf("] ]\n");
	}

	free(u);
}

static void buildTuple(word *ul, long i, gen g, long wt, long which) {
	long    save_wt;
	word    u;

	if (wt == 0 && which == 5 && i > 0) {
		eval8Power(ul[5]);
	}

	if (wt == 0 && which == 0 && i > 0) {
		evalTrMetAbRel(ul);
		return;
	}

	if (i > 0 && which > 0) buildTuple(ul, 0, 1, wt, which - 1);

	if (g > NrPcGens) return;

	save_wt = wt;
	u = ul[ which ];
	while (!EarlyStop && g <= NrPcGens && Wt(g) <= wt) {
		u[i].g   = g;
		u[i].e   = (expo)0;
		u[i + 1].g = EOW;
		while (!EarlyStop && Wt(g) <= wt) {
			u[i].e++;
			if (Exponent[g] > (expo)0 && Exponent[g] == u[i].e) break;
			wt -= Wt(g);
			buildTuple(ul, i + 1, g + 1, wt, which);
			/* now build the same word with negative exponent */
			if (!EarlyStop && !SemigroupOnly && Exponent[g] == (expo)0) {
				u[i].g *= -1;
				buildTuple(ul, i + 1, g + 1, wt, which);
				u[i].g *= -1;
			}
		}
		wt = save_wt;
		g++;
	}
	u[i].g = EOW;
	u[i].e = (expo)0;
	if (EarlyStop || SemigroupOnly || !SemigroupFirst) return;

	while (!EarlyStop && g <= NrPcGens && Wt(g) <= wt) {
		u[i].g   = -g;
		u[i].e   = (expo)0;
		u[i + 1].g = EOW;
		while (!EarlyStop && Wt(g) <= wt) {
			u[i].e++;
			if (Exponent[g] > (expo)0 && Exponent[g] == u[i].e) break;
			wt -= Wt(g);
			buildTuple(ul, i + 1, g + 1, wt, which);
			if (EarlyStop) return;
			/* now build the same word with negative exponent */
			if (!EarlyStop && !SemigroupOnly && Exponent[g] == (expo)0) {
				u[i].g *= -1;
				buildTuple(ul, i + 1, g + 1, wt, which);
				u[i].g *= -1;
			}
		}
		wt = save_wt;
		g++;
	}
	u[i].g = EOW;
	u[i].e = (expo)0;
}

void EvalTrMetAb(void) {

	word u, ul[6];
	int i, c;

	if (!TrMetAb) return;

	for (i = 0; i < 6; i++)
		ul[i] = (word)Allocate((NrPcGens + NrCenGens + 1) * sizeof(gpower));

	u = ul[0];
	for (i = 1; i <= NrCenGens; i++) {
		u[0].g = i;
		u[0].e = (expo)1;
		u[1].g = EOW;
		u[1].e = (expo)0;
		eval8Power(u);
	}

	for (c = 2; !EarlyStop && c <= Class + 1; c++) {
		for (i = 0; i < 6; i++) {
			ul[i][0].g = EOW;
			ul[i][0].e = (expo)0;
		}
		NrWords = 0;
		if (Verbose)
			printf("#    Checking tuples of words of weight %d\n", c);
		buildTuple(ul, 0, 1, c, 5);
		if (Verbose) printf("#    Checked %d words.\n", NrWords);
	}

	for (i = 0; i < 6; i++)
		free(ul[i]);
}

void InitTrMetAb(int t) {
	TrMetAb = t;
}
