/****************************************************************************
**
**    engel.c                         NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


#include "nq.h"
#include "engel.h"
#include "presentation.h"
#include "glimt.h"

static  int     LeftEngel = 0, RightEngel = 0, Engel = 0;
static  int     RevEngel = 0;
static  int     NrEngelGens = 0;
static  int     NrWords;
static  int     Needed;
static  word    A;
int     SemigroupOnly  = 0;
int     SemigroupFirst = 0;
int     CheckFewInstances = 0;
int     ReverseOrder = 0;

static
void    Error(word v, word w, char type) {
	printf("Overflow in collector computing [ ");
	printWord(v, 'a');
	if (type == 'e') printf(" , %d ", Engel);
	if (type == 'l') printf(" , %d ", LeftEngel);
	if (type == 'r') printf(" , %d ", RightEngel);
	printWord(w, 'a');
	printf(" ]\n");
}


word    EngelCommutator(word v, word w, int engel) {
	long    n;
	word    v1;


	if (Class + 1 < engel) {
		v1 = (word)Allocate(sizeof(gpower));
		v1[0].g = EOW;
		v1[0].e = (expo)0;
		return v1;
	}

	/*
	** If the current class reaches the weight of the engel condition,
	** then we want to speed up the evaluation of the engel relations by
	** evaluating each commutator only with the required precision.  The
	** last commutator of an Engel-n commutator has to be evaluated in
	** class (Class+1) quotient (i.e. the full group), the second last in
	** the class Class quotient, etc.  The first commutator has to be
	** evaluated in the class (Class+1-(n-1)) quotient.  See also the
	** function SetupCommuteList() in addgen.c
	*/

	n = 1;
	Class = Class - (engel - 1);

	if ((v = Commutator(v, w)) == (word)0)
		return (word)0;

	n++;
	while (n <= engel) {
		Class++;

		if ((v1 = Commutator(v, w)) == (word)0)
			return (word)0;

		Free(v);
		v = v1;

		n++;
	}
	return v;
}

static
void    evalEngelRel(word v, word w) {
	word    comm;
	long    needed;

	/*      printf( "evalEngelRel() called with : " );
	        printWord( v, 'A' ); printf( "    " );
	        printWord( w, 'A' ); putchar( '\n' ); */

	NrWords++;

	/* Calculate [ v, w, .., w ] */
	if ((comm = EngelCommutator(v, w, Engel)) == (word)0) {
		Error(v, w, 'e');
		return;
	}

	needed = addRow(ExpVecWord(comm));
	if (needed) {
		printf("#    [ ");
		printWord(v, 'a');
		printf(", %d ", Engel);
		printWord(w, 'a');
		printf(" ]\n");
	}
	if (CheckFewInstances) Needed |= needed;
	else                    Needed = 1;

	Free(comm);
}

static
void    buildPairs(word u, long i, gen g, word v, long wt, long which) {
	long    save_wt;


	/* First we check if the Engel condition is trivially
	   satisfied for weight reasons. The commutator
	   [u, n v] is 1 if w(u) + n*w(v) > Class+1. */
	if (which == 1 && i == 1 &&
	        Wt(abs(u[0].g)) + Engel * Wt(abs(v[0].g)) > Class + 1)
		return;

	if (wt == 0 && which == 1 && i > 0) {
		evalEngelRel(u, v);
		return;
	}

	/* Keep u and start to build v. */
	if (i > 0 && which == 2) buildPairs(v, 0, 1, u, wt, 1);

	if (g > NrPcGens) return;

	save_wt = wt;
	while (!EarlyStop &&
	        g <= NrPcGens && Wt(g) <= Class + 1 - Engel && Wt(g) <= wt) {
		u[i].g   = g;
		u[i].e   = (expo)0;
		u[i + 1].g = EOW;
		while (!EarlyStop && Wt(g) <= wt) {
			u[i].e++;
			if (Exponent[g] > (expo)0 && Exponent[g] == u[i].e) break;
			wt -= Wt(g);
			buildPairs(u, i + 1, g + 1, v, wt, which);
			/* now build the same word with negative exponent */
			if (!EarlyStop && !SemigroupOnly && Exponent[g] == (expo)0) {
				u[i].g *= -1;
				buildPairs(u, i + 1, g + 1, v, wt, which);
				u[i].g *= -1;
			}
		}
		wt = save_wt;
		g++;
	}
	u[i].g = EOW;
	u[i].e = (expo)0;
	if (EarlyStop || SemigroupOnly || !SemigroupFirst) return;

	while (!EarlyStop &&
	        g <= NrPcGens && Wt(g) <= Class + 1 - Engel && Wt(g) <= wt) {
		u[i].g   = -g;
		u[i].e   = (expo)0;
		u[i + 1].g = EOW;
		while (!EarlyStop && Wt(g) <= wt) {
			u[i].e++;
			if (Exponent[g] > (expo)0 && Exponent[g] == u[i].e) break;
			wt -= Wt(g);
			buildPairs(u, i + 1, g + 1, v, wt, which);
			if (EarlyStop) return;
			/* now build the same word with negative exponent */
			if (!EarlyStop && !SemigroupOnly && Exponent[g] == (expo)0) {
				u[i].g *= -1;
				buildPairs(u, i + 1, g + 1, v, wt, which);
				u[i].g *= -1;
			}
		}
		wt = save_wt;
		g++;
	}
	u[i].g = EOW;
	u[i].e = (expo)0;
}

static
void    evalEngel(void) {
	word    u, v;
	long    c;

	u = (word)Allocate((NrPcGens + NrCenGens + 1) * sizeof(gpower));
	v = (word)Allocate((NrPcGens + NrCenGens + 1) * sizeof(gpower));

	/* For `production purposes' I don't want to run through       */
	/* those classes that don't yield non-trivial instances of the */
	/* Engel law. Therefore, we stop as soon as we ran through a   */
	/* class that didn't yield any non-trivial instances. This is  */
	/* done through the static variable Needed which is set by     */
	/* evalEngelRel() as soon as a non-trivial instance has been   */
	/* found if the flag CheckFewInstances (option -c) is set.     */
	if (ReverseOrder)
		for (c = Class + 1; !EarlyStop && c >= 2; c--) {
			u[0].g = EOW;
			u[0].e = (expo)0;
			v[0].g = EOW;
			v[0].e = (expo)0;
			NrWords = 0;
			if (Verbose)
				printf("#    Checking pairs of words of weight %ld\n", c);
			buildPairs(u, 0, 1, v, c, 2);
			if (Verbose) printf("#    Checked %d words.\n", NrWords);
		}
	else {
		Needed = 1;
		for (c = 2; !EarlyStop && Needed && c <= Class + 1; c++) {
			Needed = 0;
			u[0].g = EOW;
			u[0].e = (expo)0;
			v[0].g = EOW;
			v[0].e = (expo)0;
			NrWords = 0;
			if (Verbose)
				printf("#    Checking pairs of words of weight %ld\n", c);
			buildPairs(u, 0, 1, v, c, 2);
			if (Verbose) printf("#    Checked %d words.\n", NrWords);
		}
		for (; !EarlyStop && c <= Class + 1; c++)
			printf("#    NOT checking pairs of words of weight %ld\n", c);
	}
	free(u);
	free(v);
}

static
void    evalRightEngelRel(word w) {
	word    comm;
	long    n,  needed;

	/*      printf( "evalRightEngelRel() called with : " );*/
	/*      printWord( w, 'A' );*/
	/*      putchar( '\n' );*/

	NrWords++;
	/* Calculate [ a, w, .., w ] */
	if ((comm = EngelCommutator(A, w, RightEngel)) == (word)0) {
		Error(A, w, 'r');
		return;
	}

	needed = addRow(ExpVecWord(comm));
	if (needed) {
		printf("#    [ ");
		printWord(A, 'a');
		for (n = RightEngel - 1; n >= 0; n--) {
			printf(", ");
			printWord(w, 'a');
		}
		printf(" ]\n");
	}
	if (CheckFewInstances) Needed |= needed;
	else                    Needed = 1;

	Free(comm);
}

static
void    evalLeftEngelRel(word w) {
	word    comm;
	long    n,  needed;

	/*      printf( "evalLeftEngelRel() called with : " );*/
	/*      printWord( w, 'A' );*/
	/*      putchar( '\n' );*/

	NrWords++;
	/* Calculate [ w, a, .., a ] */

	if ((comm = EngelCommutator(w, A, LeftEngel)) == (word)0) {
		Error(w, A, 'l');
		return;
	}

	needed = addRow(ExpVecWord(comm));
	if (needed) {
		printf("#    [ ");
		printWord(w, 'a');
		for (n = LeftEngel - 1; n >= 0; n--) {
			printf(", ");
			printWord(A, 'a');
		}
		printf(" ]\n");
	}
	if (CheckFewInstances) Needed |= needed;
	else                    Needed = 1;

	Free(comm);
}

static
void    buildWord(word u, long i, gen g, long wt) {
	long    save_wt;

	if (wt == 0 && i > 0) {
		if (RightEngel) evalRightEngelRel(u);
		if (LeftEngel)  evalLeftEngelRel(u);
		return;
	}

	if (g > NrPcGens) return;

	save_wt = wt;
	while (!EarlyStop && g <= NrPcGens && Wt(g) <= wt) {
		u[i].g   = g;
		u[i].e   = (expo)0;
		u[i + 1].g = EOW;
		while (!EarlyStop && Wt(g) <= wt) {
			u[i].e++;
			if (Exponent[g] > (expo)0 && Exponent[g] == u[i].e) break;
			wt -= Wt(g);
			buildWord(u, i + 1, g + 1, wt);
			/* now build the same word with negative exponent */
			if (!EarlyStop && !SemigroupOnly &&
			        !SemigroupFirst && Exponent[g] == (expo)0) {
				u[i].g *= -1;
				buildWord(u, i + 1, g + 1, wt);
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
			buildWord(u, i + 1, g + 1, wt);
		}
		wt = save_wt;
		g++;
	}
	u[i].g = EOW;
	u[i].e = (expo)0;
}

static
void    evalLREngel(void) {

	word    u;
	int     n;
	long    cl;

	A = (word)Allocate(2 * sizeof(gpower));
	u = (word)Allocate((NrPcGens + NrCenGens + 1) * sizeof(gpower));

	for (n = 1; !EarlyStop && n <= NrEngelGens; n++) {

		if (RevEngel) A[0].g = NumberOfAbstractGens() - n + 1;
		else           A[0].g = n;
		A[0].e = (expo)1;
		A[1].g = EOW;
		A[1].e = (expo)0;

		Needed = 1;
		for (cl = 2; !EarlyStop && Needed && cl <= Class + 1; cl++) {
			Needed = 0;
			u[0].g = EOW;
			u[0].e = (expo)0;
			NrWords = 0;
			if (Verbose) printf("#    Checking words of weight %ld\n", cl - 1);
			buildWord(u, 0, 1, cl - 1);
			if (Verbose) printf("#    Checked %d words.\n", NrWords);
		}
		for (; !EarlyStop && cl <= Class + 1; cl++)
			printf("#    NOT checking words of weight %ld\n", cl);

	}
	free(u);
	free(A);
}

void    EvalEngel(void) {

	long    t = 0;

	if (Verbose) t = RunTime();

	if (LeftEngel || RightEngel) evalLREngel();
	if (Engel) evalEngel();

	if (Verbose)
		printf("#    Evaluated Engel condition (%ld msec).\n", RunTime() - t);
}

void    InitEngel(int l, int r, int v, int e, int n) {
	LeftEngel = l;
	RightEngel = r;
	RevEngel = v;

	Engel = e;

	NrEngelGens = n;
}
