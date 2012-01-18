/*****************************************************************************
**
**    addgen.c                        NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include "config.h"
#include "nq.h"
#include "presentation.h"
#include "relations.h" /* for ExtendEpim */

/*
**    Set up a list of Commute[] arrays.  The array in CommuteList[c] is
**    Commute[] as if the current group had class c.  CommuteList[Class+1][]
**    is the same as Commute[].
*/
void    SetupCommuteList(void) {

	int c;
	gen g, h;

	if (CommuteList != (gen**)0) {
		for (c = 1; c <= Class; c++) Free(CommuteList[c]);
		Free(CommuteList);
	}

	CommuteList = (gen**)Allocate((Class + 2) * sizeof(gen*));
	for (c = 1; c <= Class + 1; c++) {
		CommuteList[ c ] =
		    (gen*)Allocate((NrPcGens + NrCenGens + 1) * sizeof(gen));

		for (g = 1; g <= NrPcGens; g++) {
			for (h = g + 1; Wt(g) + Wt(h) <= c; h++) ;
			CommuteList[c][g] = h - 1;
		}
		for (; g <= NrPcGens + NrCenGens; g++) CommuteList[c][g] = g;
	}
}

void    SetupCommute2List(void) {

	int    c;
	gen    g, h;

	if (Commute2List != (gen**)0) {
		for (c = 1; c <= Class; c++) Free(Commute2List[c]);
		Free(Commute2List);
	}

	Commute2List = (gen**)Allocate((Class + 2) * sizeof(gen*));
	for (c = 1; c <= Class + 1; c++) {
		Commute2List[ c ] =
		    (gen*)Allocate((NrPcGens + NrCenGens + 1) * sizeof(gen));

		for (g = 1; g <= NrPcGens && 3 * Wt(g) <= c; g++) {
			for (h = CommuteList[c][g]; h > g && 2 * Wt(h) + Wt(g) > c; h--) ;
			Commute2List[c][g] = h;
		}
		for (; g <= NrPcGens + NrCenGens; g++) Commute2List[c][g] = g;
	}
}

void SetupNrPcGensList(void) {
	int    c;

	if (NrPcGensList != (int *)0) Free(NrPcGensList);

	NrPcGensList = (int *)Allocate((Class + 2) * sizeof(int));

	if (Class == 0) {
		NrPcGensList[ Class + 1 ] = NrCenGens;
		return;
	}

	NrPcGensList[1] = Dimension[1];
	for (c = 2; c <= Class; c++)
		NrPcGensList[ c ] = NrPcGensList[c - 1] + Dimension[c];

	NrPcGensList[ Class + 1 ] = NrPcGensList[ Class ] + NrCenGens;

	printf("##  Sizes:");
	for (c = 1; c <= Class + 1; c++) printf("  %d", NrPcGensList[c]);
	printf("\n");
}


/*
**    Add new/pseudo generators to the power conjugate presentation.
*/
void AddGenerators(void) {

	long    t = 0;
	gen     i, j;
	int     l, G;
	word    w;

	if (Verbose) t = RunTime();

	G = NrPcGens;

	/*
	** Extend the definitions array by a safe amount.  We could compute
	** the exact number of new generators to be introduced, but is it
	** worth the effort?
	*/
	Definition =
	    (def*)realloc(Definition,
	                  (G + (Dimension[1] + 1) * NrPcGens + 1
	                   +  NumberOfAbstractGens()) * sizeof(def));
	if (Definition == (def*)0) {
		perror("AddGenerators(), Definition");
		exit(2);
	}

	G += ExtendEpim();

	/* Firstly mark all definitions in the pc-presentation. */
	for (j = Dimension[1] + 1; j <= NrPcGens; j++)
		Conjugate[ Definition[j].h ][ Definition[j].g ] =
		    (word)((unsigned long)
		           (Conjugate[Definition[j].h][Definition[j].g]) | 0x1);

	/* Secondly new generators are defined. */
	/* Powers */
	for (j = 1; j <= NrPcGens; j++)
		if (Exponent[j] != (expo)0) {
			G++;
			l = 0;
			if (Power[j] != (word)0) l = WordLength(Power[ j ]);
			w = (word)malloc((l + 2) * sizeof(gpower));
			if (Power[j] != (word)0) WordCopy(Power[ j ], w);
			w[l].g   = G;
			w[l].e   = (expo)1;
			w[l + 1].g = EOW;
			w[l + 1].e = (expo)0;
			if (Power[ j ] != (word)0) free(Power[ j ]);
			Power[ j ] = w;
			Definition[ G ].h = j;
			Definition[ G ].g = (gen)0;
			if (Verbose) {
				printf("#    generator %d = ", G);
				printGen(j, 'A');
				printf("^"EXP_FORMAT"\n", Exponent[j]);
			}
		}

	/* Conjugates */
	/* New/pseudo generators are only defined for commutators of the
	** form [x,1], the rest is computed in Tails(). */
	for (j = 1; j <= NrPcGens; j++)
		for (i = 1; i <= min(j - 1, Dimension[1]); i++)
			if (!((unsigned long)(Conjugate[j][i]) & 0x1)) {
				G++;
				l = WordLength(Conjugate[ j ][ i ]);
				w = (word)malloc((l + 2) * sizeof(gpower));
				WordCopy(Conjugate[j][i], w);
				w[l].g   = G;
				w[l].e   = (expo)1;
				w[l + 1].g = EOW;
				w[l + 1].e = (expo)0;
				if (Conjugate[j][i] != Generators[j])
					free(Conjugate[j][i]);
				Conjugate[j][i] = w;
				Definition[ G ].h = j;
				Definition[ G ].g = i;
				if (Verbose) {
					printf("#    generator %d = [", G);
					printGen(j, 'A');
					printf(", ");
					printGen(i, 'A');
					printf("]\n");
				}
			}

	if (G == NrPcGens) {
		printf("##  Warning : no new generators in addGenerators()\n");
		return;
	}

	/* Thirdly remove the marks from the definitions.*/
	for (j = Dimension[1] + 1; j <= NrPcGens; j++)
		Conjugate[Definition[j].h][Definition[j].g] =
		    (word)((unsigned long)
		           (Conjugate[Definition[j].h][Definition[j].g]) & ~0x1);

	/* Fourthly enlarge the necessary arrays, so that the collector
	   works. */

	/* Shrink Definition[] to the right size. */
	Definition = (def*)realloc(Definition, (G + 1) * sizeof(def));

	/* Enlarge Exponent[] ... */
	Exponent = (expo *)realloc(Exponent, (G + 1) * sizeof(expo));
	if (Exponent == (expo *)0) {
		perror("addGenerators(), Exponent");
		exit(2);
	}
	for (i = NrPcGens + 1; i <= G; i++) Exponent[i] = (expo)0;

	/* ... and Power[].       */
	Power = (word *)realloc(Power, (G + 1) * sizeof(word));
	if (Power == (word *)0) {
		perror("addGenerators(), Power");
		exit(2);
	}
	for (i = NrPcGens + 1; i <= G; i++) Power[i] = (word)0;

	Weight = (int *)realloc(Weight, (G + 1) * sizeof(long));
	if (Weight == (int *)0) {
		perror("addGenerators(), Weight");
		exit(2);
	}
	for (i = NrPcGens + 1; i <= G; i++) Weight[i] = Class + 1;

	NrCenGens = G - NrPcGens;


	SetupCommuteList();
	SetupCommute2List();
	SetupNrPcGensList();

	Commute  = CommuteList[ Class + 1 ];
	Commute2 = Commute2List[ Class + 1 ];

	if (Verbose)
		printf("#    Added new/pseudo generators (%ld msec).\n", RunTime() - t);
}
