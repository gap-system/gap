/****************************************************************************
**
**    sq.c                     ANU SQ                        Alice C Niemeyer
**
**
**    Copyright 1994                             Mathematics Research Section
**                                            School of Mathematical Sciences
**                                             Australian National University
**
** (7.1.1993) 29.3.94
*/
#include <sys/types.h>
#include <stdio.h>
#include <malloc.h>
#include <signal.h>
#ifdef SYSV 
extern struct utsname;
#endif
#include "sys.h"           /* header file for system functions  */
#include "pres.h"          /* header file for reading presentations  */
#include "sq.h"            /* header file containing data structures */
#include "arith.h"         /* header file for basic arithmetic functions */
#include "modmem.h"        /* header file for memory management    */
#include "pcparith.h"      /* header file for the  collector functions */
#include "veinter.h"       /* interface to the vector enumerator */
#include "eapquot.h"
#include "updatepres.h"    /* updateing the presentation         */

/*
** Global Variables
*/
FILE         * FN;
int          chat;

/*
** Static Variables
*/
static char	         *ProgramName; 
static unsigned long     start, begin, *vetime, *vpt, *psttime, *pst;
static int               vl, pl;

/*
**  The setting of CHAT has the following effect:
**
**  CHAT     0:    no chatting during program execution 
**           1:    the program will indicate which prime is currently used
**                 and the dimension of the computed module
**           2:    1 and the program will mark the begin of the execution
**                 of the following basic steps in the algorithm
**                    - Call to AddDefinitions() which adds new generators
**                    - Call to Consistency(), the consistency check function
**                    - Call to LiftEpimorphism(), to lift the epimorphism
**                    - Call to the vector enumerator
**                    - Call to UpdatePresentation, the function which updates
**                            the presentation according to VE output
**           3:    1, 2 and the presentation at the end of a completion 
**                 of pStep() is printed
**           4:    1, 2 and the relations computet in Consistency() and 
**                 LiftEpimorphism() are printed
**           5:    1, 2, 3 and 4
**           6:    5 and prints presentation at the begining of each pStep
**           7:    everything
**
**  Everything which is printed and is not in GAP input format is preceeded
**  by '#I', and thus is a GAP comment.
*/

GroupWord    STACK;    /* Collector Stack */
Vector       IdVec;    /* Identity Vector */
GroupWord    IdGrp;    /* Idetity element in group */


static  void usage( error )
char	*error;

{	int	i;

	if( error != (char *)0 ) fprintf( stderr, "%s\n", error );
	fprintf( stderr, "usage: %s", ProgramName );
	fprintf( stderr, "[-p <printlevel>]\n" );
	for( i = strlen(ProgramName)+7; i > 0; i-- )
	    fputc( ' ', stderr );
	fprintf( stderr, " <presentation> <Lseries>\n" );
    	exit( 1 );
}


/*
**  Compute the equations that have to hold such that the epimorphism 
**  lifts onto the extension.
**  The argument vefpt is a pointer to the file to which the input for
**  the vector enumerator is to be written.
*/
LiftEpimorphism( vefpt )
FILE * vefpt;
{
	node	               *r;
	ExtensionElement       *w, *naught;

        if( chat >= 2 ) fprintf( FN, "#I  Lifting Epimorphism\n");

	naught = NewExtensionElement();
	r = FirstRelation();
	while( r != (node *)0 ) {
	    fprintf( vefpt, ";\n" );
            w = EvalNode( r ); 
            PrintMERelation(w, naught, vefpt);
            if( chat >= 4 ) {
                PrintMERelation(w, naught, FN);
	        fprintf( FN, "\n" );
	    }
	    FreeExtensionElement(w);
    	    r = NextRelation();
	}
	fprintf( vefpt, " .\n");
	FreeExtensionElement(naught);
}



int  pStep( tail, maxnilp, fp )
int  tail;
int maxnilp;
FILE * fp;
{
        FILE *fpt, *f, *fpvetime;
        int  chprime, h, pid, onr, opt;
	char *fn, cm[40], *fnn;
        long vt;

        fn = TmpFileName();
 	if ( (fpt = fopen( fn, "w" )) == NULL ) {
            perror("fopen " );
	    exit(1);
	}

	
        if( chat >= 1 )  fprintf( FN, "\n#I  pStep( %d )\n", P->prime );

	AddDefinitions(tail, maxnilp);
	Commute();

        if( chat >= 6 )  PrintExPresentation(FN);

	PrintModuleHead( fpt );
        Consistency( fpt ); 
	PrintTrivial( fpt );
        LiftEpimorphism( fpt );
        PrintModuleEnd( fpt );
	if ( P->Nr_Generators > P->Nr_GroupGenerators ) {
     	    fclose (fpt );
            if( chat < 2 ) {
	        strcpy( cm, fn );
	        strcat( cm, "> /dev/null" );
	    }
           CallModuleEnumerator( fn );
           Unlink( fn );
	}
	else {
            if ( (f = fopen("meout.pa","w")) == NULL ) {
	        perror("for meout.pa");
	        exit(1);
            }
            fprintf( f, "%d\n", 0 );
	    fclose(f);
	}

	onr = P->Nr_GroupGenerators;
	opt = P->trivial;
	chprime = UpdatePresentation(&vt);
        if ( vpt - vetime  >= vl ) {
            vetime = ReAllocate( vetime, (vl+128)*sizeof(unsigned long));
            vpt = vetime + vl + 1; 
            vl += 128;
	} 
        *vpt++ = vt;

	return chprime;
}

/* SetPrime () reads the next integer from <fp> assuming it is a prime.
** If it is equal to P->prime it returns this integer, else t sets P->prime
** to this value and returns 1.
*/
int SetPrime ( fp ) 
FILE *fp;
{
	int prime;

        if( chat >= 2  ) 
	  fprintf( FN, "#I  Prime : ");

	if ( fscanf( fp, "%d", &prime ) == EOF ) {
	  if ( chat >= 2 )
	    fprintf( FN, "-\n" );
          return EOF;
        }
	if ( P->prime == prime ) return prime;
	P->prime = (uint) prime;
	if ( chat >= 2 )
	  fprintf( FN, "%d\n", prime );

	return 1;
}

static  void PrintHeader() {
 
	char *s, *hostname;
	
        hostname = GetHostName();


	printf( "#T \n" );
	printf( "#T \n" );
	printf( "#T    A Soluble Quotient Program (Version %s)\n", VERSION );
	printf( "#T          Calculating a soluble quotient\n" );
	printf( "#T \n" );
	printf( "#T    Program:       %s\n", ProgramName );
	printf( "#T    Machine:       %s\n", hostname );
	printf( "#T    Printlevel:    %d\n#I\n", chat );

}

static void PrintResources() {
            
            int i, j;
            unsigned long  t, v;

	    printf("#T    Runtime of the program (in msec): \n#I\n");
	    printf("#T    class        time      time in SQ    time in VE\n");
            t = v = 0;
            printf("#T    %3d    %10d    %10d\n",
                             1, psttime[0], psttime[0]  );
            for ( i = 1; i < pst-psttime; i++ ) {
                t = psttime[i] - psttime[i-1];
                v += vetime[i-1];
	        printf("#T    %3d    %10d    %10d    %10d\n",
                                i+1, t+vetime[i-1], t, vetime[i-1] );
	    }
	    printf("#T               ------        ------        ------\n");
	    printf("#T           %10d    %10d    %10d\n",
                                RunTime()-begin+v, *(pst-1), v );
	    printf("#T               (total)\n");
	    printf("#T\n#T    total size  of SQ  : %d byte\n",sbrk(0)-start); 
            printf("\n");
}

main( argc, argv )
int	argc;
char	*argv[];

{	FILE	         *fp;
	char	         c;
	long	         time;
	ExtensionElement **ggs;
	int              prime, class, errflg, i, cl, **ls, chprime;
        int              tail, maxnilp, factor, dogap;
        extern char      *optarg;
        extern int       optind;
	void             (*f1)();


	CatchSignals();
	start = sbrk(0);
	begin = RunTime();
        vetime  = (unsigned long*) Allocate( 128*sizeof(unsigned long*));
        psttime = (unsigned long*) Allocate( 128*sizeof(unsigned long*));
        pl = vl = 128;
        vpt = vetime;
        pst = psttime;

	ProgramName = argv[0]; 
	f1 = signal( SIGABRT, SIG_IGN );

#ifdef DEBUG
	malloc_debug( 2 );
#endif

        fp = stdin;
	FN = stdout;
	setbuf( FN, NULL ); 
#ifdef CHAT
	chat = CHAT;
#endif
	tail = 0;
	errflg = 0;
        while ((c = getopt(argc, argv, "gp:")) != EOF) {
		switch (c) {
		case 'p':
                    chat = (int) atoi( optarg );
                    if ( chat < 0 || chat > 7 )
                        usage("printlevel not in range 0 to 7" );
                    break;
		case 'g':
		    dogap = 1;
                    break;
		case '?':
		default :
		     errflg++;
		}
	   if (errflg)
		usage("unknown option");
         }


	GetPresentation( fp , "stdin" );
	P = InitPresentation();
	P->prime = 0;

	if ( SetPrime(fp) == EOF ) {
            PrintHeader();
            PrintResources();
 	    PrintExPresentation(FN);
	    fclose (FN);
	    return 0;
	}
        if( chat >= 2 && isatty(0) )  fprintf( FN, "#I  Class : ");
	fscanf( fp, "%d", &class );
		

	/* We initialise an elementary abelian p-group on
        ** the given number of generators. 
        */
        for ( i = 1; i <= P->Nr_GroupGenerators; i++ )
            P->exponents[i] = P->prime;

        /* Initially all generators  act trivially */
	P->trivial = 1;

	InitCollectExtensionElement();	
	IdVec = VectorOne();
	IdGrp = GroupWordOne();
        
	/* If tail is set we need to add tails to all 
	** relations, if not only to those involving a
	** generator of exponent P->prime.
	** If chprime is set we have to use a new prime.
	*/
	tail =  0;
	chprime = 0;
	maxnilp = 0;

	/* Perform the first step */
        ls = EApQuot( FN ); 
	ElimTailsOne (ls); 
        if( chat >= 5 || chat == 3 ) PrintExPresentation( FN );
	cl = 2;

	if ( P->Nr_GroupGenerators == 0 ) {
	    if ( (prime = SetPrime(fp)) == EOF ) {
 /*		PrintExPresentation(FN); */
		fclose (FN);
		return 0;
	    }
	    if ( prime == 1 ) P->trivial = tail = 1;
	}
 
        *pst++ = RunTime()-begin;

	do { 
	    while ( !chprime && cl <= class ) { 
		chprime = pStep(tail, maxnilp, fp);
                if( chat >= 5 || chat == 3  ) 
		    PrintExPresentation(FN);
/*		tail = 0; 5 July */ /* tail = 0 bad influence in grp1 */
		cl++;
                if ( pst - psttime  >= pl ) {
	           psttime=ReAllocate(psttime,(pl+128)*sizeof(unsigned long));
                   pst = psttime + pl + 1; 
                   pl += 128;
                }
                *pst++ = RunTime() - begin;
	    }
	    if ( (prime = SetPrime(fp)) == EOF )  {
                PrintHeader();
                PrintResources();
		PrintExPresentation(FN);
		fclose (FN);
		return 0;
	    }
	    if ( prime == 1 ) {
	        P->trivial = P->Nr_GroupGenerators+1;
	        tail    = 1;
		cl      = 1;
		chprime = 0;
	    }
	    else tail = 0;

            if( chat >= 2 && isatty(0)  )  fprintf( FN, "# Class : ");

	} while ( fscanf( fp, "%d", &class ) != EOF );



	signal ( SIGABRT, f1 );
	    
	PrintHeader();
        PrintResources();
        PrintExPresentation(FN);
	fclose (FN);
	return 0;
}
