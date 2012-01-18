/*****************************************************************************
**
**    nq.c                            NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include <unistd.h>
#include <ctype.h>

#include "nq.h"
#include "engel.h"
#include "glimt.h"
#include "presentation.h"
#include "relations.h"
#include "time.h"

int     Debug = 0;
int     Gap = 0;
int     AbelianInv = 0;
int     NilpMult;
int     Verbose = 0;

extern int RawMatOutput;

const char    *InputFile;

static char     *ProgramName;
static int      Cl;

static
void    usage(const char *error) {
	int     i;

	if (error != 0) fprintf(stderr, "%s\n", error);
	fprintf(stderr, "usage: %s", ProgramName);
	fprintf(stderr, " [-a] [-M] [-d] [-g] [-v] [-s] [-f] [-c] [-m]\n");
	for (i = strlen(ProgramName) + 7; i > 0; i--) fputc(' ', stderr);
	fprintf(stderr, " [-t <n>] [-l <n>] [-r <n>] [-n <n>] [-e <n>]\n");
	for (i = strlen(ProgramName) + 7; i > 0; i--) fputc(' ', stderr);
	fprintf(stderr, " [-y] [-o] [-p] [-E] [<presentation>] [<class>]\n");
	exit(1);
}

static int   leftEngel = 0,
             rightEngel = 0,
             revEngel = 0,
             engel = 0,
             nrEngelGens = 1;

static int trmetab = 0;

static const char *Ordinal(int n) {

	switch (n) {
	case 1:
		return "st";
	case 2:
		return "nd";
	case 3:
		return "rd";
	default:
		return "th";
	}
}

static
void    printHeader(void) {

	printf("#\n");
	printf("#    The ANU Nilpotent Quotient Program (Version %s)\n",
	       PACKAGE_VERSION);
	printf("#    Calculating a nilpotent quotient\n");
	printf("#    Input: %s", InputFile);
	if (leftEngel) {
		if (nrEngelGens > 1)
			printf(" & the first %d generators are", nrEngelGens);
		else
			printf(" &");
		printf(" %d%s left Engel", leftEngel, Ordinal(leftEngel));
	}
	if (rightEngel) {
		if (nrEngelGens > 1)
			printf(" & the first %d generators are", nrEngelGens);
		else
			printf(" &");
		printf(" %d%s right Engel", rightEngel, Ordinal(rightEngel));
	}
	if (engel) {
		printf(" %d%s Engel", engel, Ordinal(engel));
	}
	printf("\n");
	if (Cl != 666) printf("#    Nilpotency class: %d\n", Cl);
	printf("#    Program: %s\n", ProgramName);
	printf("#    Size of exponents: %d bytes\n#\n", (int)sizeof(expo));
}

int main(int argc, char *argv[]) {
	FILE    *fp;
	long     t, time;
	long    begin, printEpim = 1;
#ifdef HAVE_SBRK
	void    *start;
#endif
	gen     g;

	CatchSignals();
#ifdef HAVE_SBRK
	start = sbrk(0);	/* TODO: Add HAVE_SBRK macro */
#endif
	begin = RunTime();

	ProgramName = argv[0];
	argc--;
	argv++;

	setbuf(stdout, NULL);

	while (argc > 0 && argv[0][0] == '-') {
		if (argv[0][2] != '\0') {
			fprintf(stderr, "unknown option: %s\n", argv[0]);
			usage((char *)0);
		}
		switch (argv[0][1]) {
		case 'h':
			usage((char *)0);
			break;
		case 'r':
			if (--argc < 1) usage("-r requires an argument");
			argv++;
			if ((rightEngel = atoi(argv[0])) <= 0) {
				fprintf(stderr, "%s\n", argv[0]);
				usage("<n> must be positive.");
			}
			break;
		case 'l':
			if (--argc < 1) usage("-l requires an argument.");
			argv++;
			if ((leftEngel = atoi(argv[0])) <= 0) {
				fprintf(stderr, "%s\n", argv[0]);
				usage("<n> must be positive.");
			}
			break;
		case 'n':
			if (--argc < 1) usage("-n requires an argument.");
			argv++;
			if ((nrEngelGens = atoi(argv[0])) <= 0) {
				fprintf(stderr, "%s\n", argv[0]);
				usage("<n> must be positive.");
			}
			break;
		case 'e':
			if (--argc < 1) usage("-e requires an argument");
			argv++;
			if ((engel = atoi(argv[0])) <= 0) {
				fprintf(stderr, "%s\n", argv[0]);
				usage("<n> must be positive.");
			}
			break;
		case 't':
			if (--argc < 1) usage("-t requires an argument");
			argv++;
			if ((t = atoi(argv[0])) <= 0) {
				fprintf(stderr, "%s\n", argv[0]);
				usage("<n> must be positive.");
			}
			switch (argv[0][strlen(argv[0]) - 1]) {
			case 'd' :
				t *= 24;
			case 'h' :
				t *= 60;
			case 'm' :
				t *= 60;
			}
			SetTimeOut(t);
			break;
		case 'p':
			printEpim = !printEpim;
			break;
		case 'g':
			Gap = !Gap;
			break;
		case 'a':
			AbelianInv = !AbelianInv;
			break;
		case 'M':
			NilpMult = !NilpMult;
			break;
		case 'v':
			Verbose = !Verbose;
			break;
		case 'd':
			Debug = !Debug;
			break;
		case 's':
			SemigroupOnly = !SemigroupOnly;
			break;
		case 'c':
			CheckFewInstances = !CheckFewInstances;
			break;
		case 'f':
			SemigroupFirst = !SemigroupFirst;
			break;
		case 'o':
			ReverseOrder = !ReverseOrder;
			break;
		case 'm':
			RawMatOutput = !RawMatOutput;
			break;
		case 'y':
			trmetab = 1;
			break;
		case 'E':
			revEngel = !revEngel;
			break;
		case 'C':
			UseCombiCollector = !UseCombiCollector;
			break;
		case 'S':
			UseSimpleCollector = !UseSimpleCollector;
			break;
		default :
			fprintf(stderr, "unknown option: %s\n", argv[0]);
			usage((char *)0);
			break;
		}
		argc--;
		argv++;
	}

	/*
	** The default is to read from stdin and have no (almost no)
	** class bound.
	*/
	InputFile = "<stdin>";
	Cl = 666;

	/* Parse the remaining arguments. */
	switch (argc) {
	case 0:
		break;
	case 1:
		if (!isdigit(argv[0][0]))
			/* The only argument left is a file name. */
			InputFile = argv[0];
		else
			/* The only argument left is the class.   */
			Cl = atoi(argv[0]);	/* TODO: Use strtol instead of atoi */
		break;
	case 2:
		/* Two arguments left. */
		InputFile = argv[0];
		Cl = atoi(argv[1]);	/* TODO: Use strtol instead of atoi */
		break;
	default:
		usage((char *)0);
		break;
	}
	if (Cl <= 0) usage("<class> must be positive.");

	/* Open the input stream. */
	if (strcmp(InputFile, "<stdin>") == 0) {
		fp = stdin;
	} else {
		if ((fp = fopen(InputFile, "r")) == NULL) {
			perror(InputFile);
			exit(1);
		}
	}

	/* Read in the finite presentation. */
	Presentation(fp, InputFile);
	/* Set the number of generators. */
	WordInit(Epimorphism);
	InitEngel(leftEngel, rightEngel, revEngel, engel, nrEngelGens);
	InitTrMetAb(trmetab);
	InitPrint(stdout);

	printHeader();

	time = RunTime();

	if (Gap) printf("NqLowerCentralFactors := [\n");

	if (Gap & Verbose) fprintf(stderr, "#I  Class 1:");

	printf("#    Calculating the abelian quotient ...\n");
	InitEpim();

	EvalAllRelations();
	EvalEngel();
	EvalTrMetAb();

	ElimEpim();

	if (NrCenGens == 0) {
		printf("#    trivial abelian quotient\n");
		goto end;
	}

	/*      if( Cl == 1 ) goto end;
	 */

	InitPcPres();

	if (Gap & Verbose) {
		fprintf(stderr,
		        " %d generators with relative orders ",
		        Dimension[Class]);
		for (g = NrPcGens - Dimension[Class] + 1; g <= NrPcGens; g++)
			fprintf(stderr, " %d", (int)(Exponent[g]));
		fprintf(stderr, "\n");
	}

	printf("#    The abelian quotient");
	printf(" has %d generators\n", Dimension[Class]);
	printf("#        with the following exponents:");
	for (g = NrPcGens - Dimension[Class] + 1; g <= NrPcGens; g++)
		printf(" %d", (int)(Exponent[g]));
	printf("\n");
	if (Verbose) {
		printf("#    runtime       : %ld msec\n", RunTime() - time);
		printf("#    total runtime : %ld msec\n", RunTime() - begin);
#ifdef HAVE_SBRK
		printf("#    total size    : %ld byte\n", (long)((char *)sbrk(0) - (char *)start));
#endif
	}
	printf("#\n");

	while (Class < Cl) {
		time = RunTime();
		if (Gap & Verbose) {
			fprintf(stderr, "#I  Class %d:", Class + 1);
		}
		printf("#    Calculating the class %d quotient ...\n", Class + 1);

		AddGenerators();
		Tails();
		Consistency();

		if (NilpMult) OutputMatrix("nilp");

		EvalAllRelations();
		EvalEngel();
		EvalTrMetAb();

		if (NilpMult) OutputMatrix("mult");

		ElimGenerators();
		if (NrCenGens == 0) goto end;
		ExtPcPres();

		if (Gap & Verbose) {
			fprintf(stderr, " %d generators", Dimension[Class]);
			fprintf(stderr, " with relative orders:");
			for (g = NrPcGens - Dimension[Class] + 1; g <= NrPcGens; g++)
				fprintf(stderr, " %d", (int)(Exponent[g]));
			fprintf(stderr, "\n");
		}
		printf("#    Layer %d of the lower central series", Class);
		printf(" has %d generators\n", Dimension[Class]);
		printf("#          with the following exponents:");
		for (g = NrPcGens - Dimension[Class] + 1; g <= NrPcGens; g++)
			printf(" %d", (int)(Exponent[g]));
		printf("\n");
		if (Verbose) {
			printf("#    runtime       : %ld msec\n", RunTime() - time);
			printf("#    total runtime : %ld msec\n", RunTime() - begin);
#ifdef HAVE_SBRK
			printf("#    total size    : %ld byte\n", (long)((char *)sbrk(0) - (char *)start));
#endif
		}
		printf("#\n");

	}

end:
	TimeOutOff();

	if (printEpim) {
		printf("\n\n#    The epimorphism :\n");
		PrintEpim();
		printf("\n\n#    The nilpotent quotient :\n");
		PrintPcPres();
		printf("\n\n#    The definitions:\n");
		PrintDefs();
	}
	printf("#    total runtime : %ld msec\n", RunTime() - begin);
#ifdef HAVE_SBRK
	printf("#    total size    : %ld byte\n", (long)((char *)sbrk(0) - (char *)start));
#endif

	if (Gap) printf("];\n");

	if (Gap) { PrintRawGapPcPres(); }

	if (Gap & Verbose)
		fprintf(stderr, "\n");

	TimeOutOn();

	PrintCollectionTimes();

	return 0;
}
