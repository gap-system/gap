/*****************************************************************************
**
**    glimt.c                         NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


#include "nq.h"
#include "time.h"
#include "glimt.h"

#undef min

/*
**    This module uses the arbitrary precision GNU integer package gmp.
*/
#include <gmp.h>

/*
**    Define the data type for large integers and vectors of large integers.
*/
typedef MP_INT  *large;
typedef large   *lvec;

/*
**    The name of the structure components in MINT have changed.  I
**    knew from the start that I shouldn't have done that.
*/
#if __GNU_MP__+0 >= 2
#    define NOTZERO(l) ((l)->_mp_size != 0)
#    define ISZERO(l)  ((l)->_mp_size == 0)
#    define ISNEG(l)   ((l)->_mp_size < 0)
#    define NEGATE(l)  ((l)->_mp_size = -(l)->_mp_size)
#    define SIGN(l)    (expo)(sgn((l)->_mp_size))
#    define SIZE(l)    ((l)->_mp_size)
#    define LIMB(l,i)  (expo)((l)->_mp_d[i])
#else
#    define NOTZERO(l) ((l)->size != 0)
#    define ISZERO(l)  ((l)->size == 0)
#    define ISNEG(l)   ((l)->size < 0)
#    define NEGATE(l)  ((l)->size = -(l)->size)
#    define SIGN(l)    (expo)(sgn((l)->size))
#    define SIZE(l)    ((l)->size)
#    define LIMB(l,i)  (expo)((l)->d[i])
#endif


/*
**    The variable 'Matrix' contains the pointer to the integer matrix.
**    The variable 'Heads' contains the pointer to an array whose i-th
**    component contains the position of the first non-zero entry in
**    i-th row of Matrix[]. The variable changedMatrix indicates whether
**    the integer matrix changed during the reduction of an integer
**    vector.
*/
lvec     *Matrix = (lvec*)0;
long     *Heads;
large    MaximalEntry;

static   long     changedMatrix = 0;

/*
**    The number of rows and columns in the integer matrix are stored in
**    the following two variables.
*/
long     NrRows = 0;
long     NrCols = 0;

/*
**    Take the time spend in this package.
*/
static  long Time = 0;

/*
**    Set a flag if the integer matrix is the identity.
**    This can be used as an early stopping criterion.
*/
int     EarlyStop;

/*
**    Set this flag if each non-zero vector handed to addRow() is to
**    be printed to a file.
*/
int     RawMatOutput;
FILE    *RawMatFile = NULL;


static large ltom(expo n) {
	char    x[64];
	MP_INT  *l = (MP_INT*)Allocate(sizeof(MP_INT));
	int     sign = 1;

	if (n < (expo)0) { sign = -1; n = -n; }

	/*
	** There does not seem to be a function that converts from long long
	** to a large integer.  So we have to do it a bit more complicated.
	*/
#ifdef HAVE_LONG_LONG_INT
	sprintf(x, "%llx", n);
#else
	sprintf(x, "%lx", n);
#endif

	mpz_init(l);
	mpz_set_str(l, x, 16);

	if (0) {
		printf(EXP_FORMAT" ", n);
		mpz_out_str(stdout, 10, l);
		printf("\n");
	}


	if (sign == -1) NEGATE(l);

	return l;
}

void freeExpVecs(expvec *M) {
	long    i;

	for (i = 0; i < NrRows; i++) free(M[i]);
	free(M);

	NrRows = NrCols = 0;
}

static void freeVector(lvec v) {
	long    i;

	for (i = 1; i <= NrCols; i++) { mpz_clear(v[i]); Free(v[i]); }
	Free(v);
}

static void freeMatrix(void) {

	long    i;

	if (Matrix == (lvec *)0) return;

	mpz_clear(MaximalEntry);
	Free(MaximalEntry);

	for (i = 0; i < NrRows; i++) freeVector(Matrix[i]);
	Free(Matrix);
	Matrix = (lvec*)0;
}

/*
static void printVector(lvec v) {
	long    i;

	for (i = 1; i <= NrCols; i++) {
		printf(" ");
		mpz_out_str(stdout, 10, v[i]);
	}
	printf("\n");
}
*/

static long survivingCols(expvec *M, long *surviving) {
	long nrSurv = 0, h = 1, i;

	for (i = 0; i < NrRows; i++) {
		for (; h < Heads[i]; h++) surviving[nrSurv++] = h;
		if (M[i][h] != (expo)1)    surviving[nrSurv++] = h;
		h++;
	}
	for (; h <= NrCols; h++) surviving[nrSurv++] = h;
	return nrSurv;
}

static void outputMatrix(expvec *M, const char *suffix) {
	long    i, j, nrSurv, *surviving;
	char    outputName[128];
	FILE    *fp;

	if (strlen(InputFile) > 100)
		sprintf(outputName, "NqOut.%s.%d", suffix, Class + 1);
	else
		sprintf(outputName, "%s.%s.%d", InputFile, suffix, Class + 1);
	if ((fp = fopen(outputName, "w")) == NULL) {
		perror(outputName);
		fprintf(stderr,
		        "relation matrix for class %d not written\n", Class + 1);
	}

	if (M == (expvec*)0) {
		fprintf(fp, "0\n");
		fclose(fp);
		return;
	}

	surviving = (long *)Allocate(NrCols * sizeof(long));
	nrSurv = survivingCols(M, surviving);

	fprintf(fp, "%ld    # Number of colums\n", nrSurv);
	for (i = 0; i < NrRows; i++) {
		if (M[i][Heads[i]] != (expo)1) {
			for (j = 0; j < nrSurv; j++)
				fprintf(fp, " "EXP_FORMAT, M[i][surviving[j]]);
			fprintf(fp, "\n");
		}
	}

	Free(surviving);
	fclose(fp);
}

void OutputMatrix(const char *suffix) {
	long    i, j;
	char    outputName[128];
	FILE    *fp;

	if (strlen(InputFile) > 100)
		sprintf(outputName, "NqOut.%s.%d", suffix, Class + 1);
	else
		sprintf(outputName, "%s.%s.%d", InputFile, suffix, Class + 1);
	if ((fp = fopen(outputName, "w")) == NULL) {
		perror(outputName);
		fprintf(stderr,
		        "relation matrix for class %d not written\n", Class + 1);
	}

	if (Matrix == (lvec*)0) {
		fprintf(fp, "0\n");
		fclose(fp);
		return;
	}

	fprintf(fp, "%ld\n", NrCols);
	for (i = 0; i < NrRows; i++) {
		for (j = 1; j <= NrCols; j++) {
			fputc(' ', fp);
			mpz_out_str(fp, 10, Matrix[i][j]);
		}
		fprintf(fp, "\n");
	}

	fclose(fp);
}

static void printGapMatrix(expvec *M) {
	long    i, j, first, nrSurv, *surviving;

	if (M == (expvec*)0) {
		printf("[\n[");
		for (j = 1; j <= NrCenGens; j++) {
			printf(" 0");
			if (j < NrCenGens) putchar(',');
		}
		printf(" ]\n],\n");
		return;
	}

	surviving = (long *)Allocate(NrCols * sizeof(long));
	nrSurv = survivingCols(M, surviving);

	if (nrSurv == 0) { Free(surviving); return; }

	printf("[\n");
	for (i = 0, first = 1; i < NrRows; i++) {
		if (M[i][Heads[i]] != (expo)1) {
			if (!first) printf(",\n");
			else         first = 0;
			printf("[");
			for (j = 0; j < nrSurv; j++) {
				printf(" "EXP_FORMAT, M[i][surviving[j]]);
				if (j < nrSurv) putchar(',');
			}
			printf("]");
		}
	}
	if (first) {
		printf("[");
		for (j = 0; j < nrSurv - 1; j++) printf(" 0,");
		printf(" 0]\n");
	}
	printf("],");
	putchar('\n');

	Free(surviving);
}

/*
**    Print the contents of Matrix[].
*/
static void printMatrix(void) {

	long    i, j;

	printf(" heads   vectors\n");
	for (i = 0; i < NrRows; i++) {
		printf("    %ld   ", Heads[i]);
		for (j = 1; j <= NrCols; j++) {
			putchar(' ');
			mpz_out_str(stdout, 10, Matrix[i][j]);
		}
		putchar('\n');
	}
}

/*
**    MatrixToExpVec() converts the contents of Matrix[] to a list of
**    exponent vectors which can be used easily by the elimination
**    routines. It also checks that the integers are not bigger than 2^15.
**    If this is the case it prints a warning and aborts.
*/
expvec *MatrixToExpVecs(void) {

	long    i, j, k;
	large   m;

	expo    c;
	expvec  *M;

	if (NrRows == 0) {
		freeMatrix();
		TimeOutOff();
		if (Gap) printGapMatrix((expvec*)0);
		if (AbelianInv) outputMatrix((expvec*)0, "abinv");
		if (RawMatOutput && RawMatFile != NULL) fclose(RawMatFile);
		TimeOutOn();
		return (expvec*)0;
	}

	M = (expvec*)malloc(NrRows * sizeof(expvec));
	if (M == (expvec*)0) { perror("MatrixToExpVecs(), M"); exit(2); }

	/* Convert. */
	for (i = 0; i < NrRows; i++) {
		M[i] = (expvec)calloc(NrCols + 1, sizeof(expo));
		if (M[i] == (expvec)0) {
			perror("MatrixToExpVecs(), M[]");
			exit(2);
		}
		for (j = Heads[i]; j <= NrCols; j++) {
			m = Matrix[i][j];
			if (mpz_sizeinbase(m, 2) > 8 * sizeof(signed int) - 2) {
				printf("Warning, Exponent too large.\n");
				printMatrix();
				exit(4);
			}
			M[i][j] = mpz_get_si(m);
		}
	}
	for (i = 0; i < NrRows; i++) freeVector(Matrix[i]);

	/* Make all entries except the head entries negative. */
	for (i = 0; i < NrRows; i++)
		for (j = i - 1; j >= 0; j--)
			if (abs(M[j][ Heads[i] ]) >= M[i][ Heads[i] ] ||
			        M[j][ Heads[i] ] > (expo)0) {
				c = M[j][ Heads[i] ] / M[i][ Heads[i] ];
				if (M[j][ Heads[i] ] > (expo)0 &&
				        M[j][ Heads[i] ] % M[i][ Heads[i] ] != (expo)0) c++;
				for (k = Heads[i]; k <= NrCols; k++)
					M[j][k] -= c * M[i][k];
			}

	free(Matrix);
	Matrix = (lvec *)0;

	printf("#    Time spent on the integer matrix: %ld msec.\n", Time);
	printf("#    Maximal entry: ");
	mpz_out_str(stdout, 10, MaximalEntry);
	printf("\n");


	TimeOutOff();
	if (Gap) printGapMatrix(M);
	if (AbelianInv) outputMatrix(M, "abinv");
	TimeOutOn();

	if (RawMatOutput) fclose(RawMatFile);

	return M;
}

/*
**    The following routines perform operations with vectors :
**
**    vNeg()  negates each entry of the vector v starting at v[a].
**    vSub()  subtracts a multiple of the vector w from the vector v.
**            The scalar w is multiplied with is v[a]/w[a], so that
**            the entry v[a] after the subtraction is smaller than
**            w[a].
**    vSubOnce()  subtracts the vector w from the vector v.
*/
static void vNeg(lvec v, long a) {
	while (a <= NrCols) {
		NEGATE(v[a]);
		a++;
	}
}

/*
static void vSubOnce(lvec v, lvec w, long a) {
	while (a <= NrCols) {
		mpz_sub(v[a], w[a], v[a]);
		a++;
	}
}
*/

static void vSub(lvec v, lvec w, long a) {
	mpz_t    q, t;

	if (NOTZERO(v[a])) {
		mpz_init(q);

		mpz_tdiv_q(q, v[a], w[a]);
		if (NOTZERO(q)) {
			mpz_init(t);

			while (a <= NrCols) {
				mpz_mul(t,    q,    w[a]);
				mpz_sub(v[a], v[a], t);

				mpz_abs(t, v[a]);
				if (mpz_cmp(t, MaximalEntry) > 0)
					mpz_set(MaximalEntry, v[a]);

				a++;
			}

			mpz_clear(t);
		}

		mpz_clear(q);
	}
}

static void lastReduce(void) {

	long    i, j;

	/* Reduce all the head columns. */
	for (i = 0; i < NrRows; i++)
		for (j = i - 1; j >= 0; j--)
			vSub(Matrix[j], Matrix[i], Heads[i]);
}

/*
**    vReduce() reduces the vector v against the vectors in Matrix[].
*/
static lvec vReduce(lvec v, long h) {
	long    i;
	lvec    w;

	for (i = 0; i < NrRows && Heads[i] <= h; i++) {
		if (Heads[i] == h) {
			while (NOTZERO(v[h]) && NOTZERO(Matrix[i][h])) {
				vSub(v, Matrix[i], h);
				if (NOTZERO(v[h])) {
					changedMatrix = 1;
					vSub(Matrix[i], v, h);
				}
			}
			if (NOTZERO(v[h])) {  /* v replaces th i-th row. */
				if (ISNEG(v[h])) vNeg(v, h);
				w = Matrix[i];
				Matrix[i] = v;
				v = w;
			}

			while (h <= NrCols && ISZERO(v[h])) h++;
			if (h > NrCols) { freeVector(v); v = (lvec)0; }
		}
	}

	return v;
}

int addRow(expvec ev) {
	long    h, i, t;
	lvec    v;

	IntMatTime -= RunTime();

	/* Initialize Matrix[] and Heads[] on the first call. */
	if (Matrix == (lvec *)0) {
		EarlyStop = 0;
		Time = 0;
		if ((Matrix = (lvec*)malloc(200 * sizeof(lvec))) == (lvec *)0) {
			perror("addRow, Matrix ");
			exit(2);
		}
		if ((Heads = (long*)malloc(200 * sizeof(long))) == (long*)0) {
			perror("addRow, Heads ");
			exit(2);
		}
		NrCols = NrCenGens;
		MaximalEntry = ltom((expo)0);

		if (RawMatOutput) {
			char *file;
			int  c;

			c = Class + 1;
			file = (char *)calloc(12, sizeof(char));
			strcpy(file, "matrix.XXX");
			file[9] = c % 10 + '0';
			c /= 10;
			file[8] = c % 10 + '0';
			c /= 10;
			file[7] = c % 10 + '0';
			if ((RawMatFile = fopen(file, "w")) == NULL) {
				perror(file);
				exit(1);
			}
			fprintf(RawMatFile, "%ld\n", NrCols);
			fflush(RawMatFile);
			free(file);
		}
	}

	changedMatrix = 0;

	/* Check if the first NrPcGens entries in the exponent vector
	** are zero. */
	for (i = 1; i <= NrPcGens; i++)
		if (ev[i] != 0) {
			printf("Warning, exponent vector is not a tail");
			printf(" at position %ld.\n", i);
			printEv(ev);
			printf("\n");
			break;
		}

	/* Find the head, i.e. the first non-zero entry, of ev. */
	for (h = 0, i = 1; i <= NrCols; i++)
		if (ev[NrPcGens + i] != 0) { h = i; break; }

	/* If ev is the null vector, free it and return. */
	if (h == 0) {
		Free(ev);
		IntMatTime += RunTime();
		return 0;
	}

	t = RunTime();

	/* Copy the last NrCenGens entries of ev and free it. */
	v = (lvec)malloc((NrCols + 1) * sizeof(large));
	if (v == (lvec)0) { perror("addRow(), v"); exit(2); }
	for (i = 1; i <= NrCols; i++)
		v[i] = ltom(ev[NrPcGens + i]);

	if (RawMatOutput) {
		for (i = 1; i <= NrCols; i++) {
			fprintf(RawMatFile, " "EXP_FORMAT, ev[NrPcGens + i]);
		}

		fprintf(RawMatFile, "\n");
		fflush(RawMatFile);
	}

	Free(ev);

	if ((v = vReduce(v, h)) != (lvec)0) {
		changedMatrix = 1;
		if (NrRows % 200 == 0) {
			Matrix = (lvec*)realloc(Matrix, (NrRows + 200) * sizeof(lvec));
			if (Matrix == (lvec*)0) {
				perror("addRow(), Matrix");
				exit(2);
			}
			Heads = (long*)realloc(Heads, (NrRows + 200) * sizeof(long));
			if (Heads == (long*)0) {
				perror("addRow(), Heads");
				exit(2);
			}
		}
		/* Insert ev such that Heads[] is in increasing order. */
		while (h <= NrCols && ISZERO(v[h])) h++;
		if (ISNEG(v[h])) vNeg(v, h);
		for (i = NrRows; i > 0; i--)
			if (Heads[i - 1] > h) {
				Matrix[i] = Matrix[i - 1];
				Heads[i] = Heads[i - 1];
			} else        break;
		/* Insert. */
		Matrix[ i ] = v;
		Heads[ i ] = h;
		NrRows++;
	}

	if (changedMatrix) lastReduce();


	/* Check if Matrix[] is the identity matrix. */
	if (NrRows == NrCenGens) {
		for (i = 0; i < NrRows; i++)
			/* Check if each leading entry is 1 */
			if (mpz_sizeinbase(Matrix[i][Heads[i]], 2) != 1) break;
		if (i == NrRows) EarlyStop = 1;
	}

	Time += RunTime() - t;
	if (EarlyStop)
		printf("#    Integer matrix is the identity.\n");

	IntMatTime += RunTime();
	return changedMatrix;
}

/*
void printLarge(large l) {
	mpz_out_str(stdout, 10, l);
	printf("\n");
}
*/
