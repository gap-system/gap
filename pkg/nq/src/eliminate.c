/*****************************************************************************
**
**    eliminate.c                     NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


#include <assert.h>

#include "nq.h"
#include "glimt.h"
#include "relations.h" /* for ElimAllEpim */

long appendExpVector(gen k, expvec ev, word w, gen *renumber) {
	long    l = 0;

	/* Copy the negative of the exponent vector ev[] into w. */
	for (; k <= NrCenGens; k++) {
		if (ev[k] > (expo)0) {
			if (Exponent[renumber[k]] != (expo)0)
				printf("Warning: Positive entry in matrix.");
			else {
				w[l].g = -renumber[k];
				w[l].e = ev[k];
			}
		} else if (ev[k] < (expo)0) {
			w[l].g = renumber[k];
			w[l].e = -ev[k];
		} else
			continue;
		if (Exponent[abs(w[l].g)] != (expo)0) {
			if (w[l].g < 0)
				printf("Negative exponent for torsion generator.\n");
			if (w[l].e >= Exponent[w[l].g])
				printf("Unreduced exponent for torsion generators.\n");
		}
		l++;
	}
	w[l].g = EOW;
	w[l].e = (expo)0;
	l++;
	return l;
}

static word elimRHS(word v, long *eRow, gen *renumber, expvec ev, expvec *M) {
	word    w;
	gen     cg;
	long    j, k, l;
	expo    s;

	w = (word)malloc((NrPcGens + NrCenGens + 1) * sizeof(gpower));
	if (w == (word)0) {
		perror("elimRHS(), w");
		exit(2);
	}

	/* copy the first NrPcGens generators into w. */
	l = 0;
	while (v->g != EOW && abs(v->g) <= NrPcGens) { w[l] = *v++; l++; }

	/* copy the eliminating rows into ev[]. */
	while (v->g != EOW) {
		cg = abs(v->g) - NrPcGens;
		if (cg <= 0)
			printf("Warning : non-central generator in elimRHS()\n");
		if (eRow[ cg ] == -1 || M[eRow[cg]][cg] != (expo)1)
			/* generator cg survives. */
			ev[ cg ] += sgn(v->g) * v->e;
		else
			for (k = cg + 1; k <= NrCenGens; k++)
				ev[k] -= sgn(v->g) * v->e * M[eRow[cg]][k];
		v++;
	}
	/* Reduce all entries modulo the exponents. */
	for (k = 1; k <= NrCenGens; k++)
		if (renumber[k] > 0 && Exponent[renumber[k]] > (expo)0)
			if ((s = ev[k] / Exponent[renumber[k]]) != (expo)0
			        || ev[k] < (expo)0) {
				if (ev[k] - s * M[eRow[k]][k] < (expo)0)  s--;
				for (j = k; j <= NrCenGens; j++)
					ev[j] -= s * M[eRow[k]][j];
			}
	/* Now copy the exponent vector back into the word. */
	for (k = 1; k <= NrCenGens; k++) {
		if (ev[k] > (expo)0) {
			w[l].g = renumber[k];
			w[l].e = ev[k];
		} else if (ev[k] < (expo)0) {
			w[l].g = -renumber[k];
			w[l].e = -ev[k];
		} else continue;
		if (Exponent[abs(w[l].g)] != (expo)0) {
			if (w[l].g < 0)
				printf("Negative exponent for torsion generator.\n");
			if (w[l].e >= Exponent[w[l].g])
				printf("Unreduced exponent for torsion generators.\n");
		}
		l++;
	}
	w[l].g = EOW;
	w[l].e = (expo)0;
	l++;

	for (k = 1; k <= NrCenGens; k++) ev[k] = (expo)0;

	return (word)realloc(w, l * sizeof(gpower));
}

void ElimGenerators(void) {

	long    i, j, k, l, n = 0, *eRow, t = 0;
	expvec  ev, *M = 0;
	gen     *renumber;
	word    v, w;

	if (Verbose) t = RunTime();

	M = MatrixToExpVecs();

	/* first assign a new number to each central generator which is
	   not to be eliminated. */
	renumber = (gen*) calloc(NrCenGens + 1, sizeof(gen));
	if (renumber == (gen*)0) {
		perror("elimGenerators(), renumber");
		exit(2);
	}
	for (k = 1, i = 0; k <= NrCenGens; k++)
		if (i >= NrRows || k != Heads[i])
			renumber[ k ] = NrPcGens + k - n;
		else if (M[i][k] != 1) {  /* k will become a torsion element */
			renumber[ k ] = NrPcGens + k - n;
			Exponent[ renumber[k] ] = M[i][k];
			i++;
		} else {                  /* k will be eliminated. */
			n++;
			i++;
		}

	/* extend the memory for Power[], note that n is the number of
	   generators to be eliminated. */
	Power = (word*)realloc(Power, (NrPcGens + NrCenGens + 1 - n) * sizeof(word));
	if (Power == (word*)0) {
		perror("elimGenerators(), Power");
		exit(2);
	}

	/* extend the memory for Definition[]. */
	Definition =
	    (def*)realloc(Definition, (NrPcGens + NrCenGens + 1 - n) * sizeof(def));
	if (Definition == (def*)0) {
		perror("elimGenerators(), Definition");
		exit(2);
	}

	/* first we eliminate ALL central generators that occur in the
	** epimorphism. */
	i = ElimAllEpim(n, M, renumber);

	/* secondly we eliminate ALL generators from right hand sides of
	** power relations. */
	for (j = 1; j <= NrPcGens; j++)
		if (Exponent[j] != (expo)0) {
			l = WordLength(Power[ j ]);
			w = (word)malloc((l + NrCenGens + 1 - n) * sizeof(gpower));
			WordCopy(Power[ j ], w);
			l--;
			l += appendExpVector(w[l].g + 1 - NrPcGens, M[i], w + l, renumber);

			if (Power[j] != (word)0) free(Power[j]);
			if (l == 1) {
				Power[j] = (word)0;
				free(w);
			} else
				Power[j] = (word)realloc(w, l * sizeof(gpower));
			i++;
		}

	/* Thirdly we eliminate the generators from the right hand
	** side of conjugates, but before that we fix the definitions
	** of surviving generators. */

	/* set up an array that specifies the row which eliminates a
	** generator. */
	eRow = (long*)malloc((NrCenGens + 1) * sizeof(long));
	if (eRow == (long*)0) {
		perror("elimGenerators(), eRow");
		exit(2);
	}
	for (k = 0; k <= NrCenGens; k++) eRow[ k ] = -1;
	for (k = 0; k <  NrRows;    k++) eRow[ Heads[k] ] = k;


	ev = (expvec)calloc((NrCenGens + 1), sizeof(expo));
	if (ev == (expvec)0) {
		perror("elimGenerators(), ev");
		exit(2);
	}
	for (j = 1; j <= NrPcGens; j++)
		for (i = 1; i < j; i++) {
			if (Wt(j) + Wt(i) > Class + 1) continue;

			k = Conjugate[j][i][1].g - NrPcGens;
			if (k > 0 &&
			        i <= Dimension[1] && j > NrPcGens - Dimension[Class] &&
			        (eRow[ k ] == -1 || M[eRow[k]][k] != (expo)1)) {
				/* Fix the definitions of surviving generators and
				** their power relations. */
				Conjugate[j][i][1].g = renumber[k];
				Definition[ renumber[k] ].h  = j;
				Definition[ renumber[k] ].g  = i;
				if (eRow[ k ] != -1) {
					w = (word)malloc((NrCenGens + 1 - n) * sizeof(gpower));
					if (w == (word)0) {
						perror("elimGenerators(), w");
						exit(2);
					}
					l = appendExpVector(k + 1, M[eRow[k]], w, renumber);
					w = (word)realloc(w, l * sizeof(gpower));
					Power[ renumber[k] ] = w;
				}
			} else {
				v = elimRHS(Conjugate[j][i], eRow, renumber, ev, M);
				if (Conjugate[j][i] != Generators[j])
					free(Conjugate[j][i]);
				Conjugate[j][i] = v;
			}

			if (Exponent[i] == (expo)0) {
				v = elimRHS(Conjugate[j][-i], eRow, renumber, ev, M);
				if (Conjugate[j][-i] != Generators[j])
					free(Conjugate[j][-i]);
				Conjugate[j][-i] = v;
			}
			if (Exponent[j] == (expo)0) {
				v = elimRHS(Conjugate[-j][i], eRow, renumber, ev, M);
				if (Conjugate[-j][i] != Generators[-j])
					free(Conjugate[-j][i]);
				Conjugate[-j][i] = v;
			}
			if (Exponent[j] + Exponent[i] == (expo)0) {
				v = elimRHS(Conjugate[-j][-i], eRow, renumber, ev, M);
				if (Conjugate[-j][-i] != Generators[-j])
					free(Conjugate[-j][-i]);
				Conjugate[-j][-i] = v;
			}
		}

	/* Now adjust the sizes of the arrays */
	assert(Commute == CommuteList[ Class + 1 ]);
	Commute   = (gen*)realloc(Commute,
	                          (NrPcGens + NrCenGens + 1 - n) * sizeof(gen));
	CommuteList[ Class + 1 ] = Commute;
	Exponent = (expo*)realloc(Exponent,
	                         (NrPcGens + NrCenGens + 1 - n) * sizeof(expo));

	free(renumber);
	free(ev);
	free(eRow);

	if (M != (expvec*)0) freeExpVecs(M);
	NrCenGens -= n;

	if (Verbose)
		printf("#    Eliminated generators (%ld msec).\n", RunTime() - t);
}
