/*****************************************************************************
**
**    gap.c                           NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include "nq.h"

void	printGapWord( w )
word	w;

{       int nrc = 30;      /* something has already been printed */

	if( w == (word)0 || w->g == EOW ) {
	    printf( "One(F)" );
	    return;
	}
	
	while( w->g != EOW ) {
	    if( w->g > 0 ) {
                nrc += printf( "NqF.%d", w->g );
		if( w->e != (exp)1 )
#ifdef LONGLONG
		    nrc += printf( "^%Ld", w->e );
#else
		    nrc += printf( "^%d", w->e );
#endif
	    }
	    else {
                nrc += printf( "NqF.%d", -w->g );
#ifdef LONGLONG
		nrc += printf( "^%Ld", -w->e );
#else
		nrc += printf( "^%d", -w->e );
#endif
	    }
	    w++;
	    if( w->g != EOW ) { 
              putchar( '*' ); 
              nrc++;

              /*
              **  Insert a line break, because GAP can't take lines that
              **  are too long.
              */
              if( nrc > 70 ) { printf( "\\\n  " ); nrc = 0; }
            }
              
	}
}


void	PrintGapPcPres() {

	gen	g;
	long	i, j;

        /*
        **  Commands that create the appropriate free group and the
        **  collector. 
        */
	printf( "NqF := FreeGroup( %d );\n", NrPcGens+NrCenGens );
        printf( "NqCollector := FromTheLeftCollector( NqF );\n" );
	for( i = 1; i <= NrPcGens+NrCenGens; i++ )
            if( Exponent[i] != (exp)0 ) {
                printf( "SetRelativeOrder( NqCollector, %d, ", i );
#               ifdef LONGLONG
                    printf( "%Ld", Exponent[i] );
#               else
                    printf( "%d", Exponent[i] );
#               endif
                printf( " );\n" );
            }

        /*
        **  Print the power relations.
        */
	for( i = 1; i <= NrPcGens+NrCenGens; i++ )
	    if( Exponent[i] != (exp)0 && 
                Power[i] != (word)0 && Power[i]->g != EOW ) {
                printf( "SetPower( NqCollector, %d, ", i );
                printGapWord( Power[i] );
                printf( " );\n" );
            }

        /*
        **  Print the conjugate relations.
        */
	for( j = 1; j <= NrPcGens; j++ ) {
	    i = 1;
	    while( i < j && Wt(i) + Wt(j) <= Class + (NrCenGens==0?0:1) ) {
              /*
                printf( "Print( %d, \" \", %d, \"\\n\" );\n", j, i );
              */
		/* print Conjugate[j][i] */
                printf( "SetConjugate( NqCollector, %d, %d, ", j, i );
		printGapWord( Conjugate[j][i] );
                printf( " );\n" );
		if( 1 && Exponent[i] == (exp)0 ) {
                    printf( "SetConjugate( NqCollector, %d, %d, ", j, -i );
		    printGapWord( Conjugate[j][-i] );
                    printf( " );\n" );
		}
		if( 1 && Exponent[j] == (exp)0 ) {
                    printf( "SetConjugate( NqCollector, %d, %d, ", -j, i );
		    printGapWord( Conjugate[-j][i] );
                    printf( " );\n" );
		}
		if( 1 && Exponent[i] + Exponent[j] == (exp)0 ) {
                    printf( "SetConjugate( NqCollector, %d, %d, ", -j, -i );
		    printGapWord( Conjugate[-j][-i], 'A' );
                    printf( " );\n" );
		}
		i++;
	    }
	}

        /*
        **  Print the epimorphism.  It is sufficient to list the images.
        */
        printf( "NqImages := [\n" );
        for( i = 1; i <= NumberOfAbstractGens(); i++ ) {
            printGapWord( Epimorphism( i ) );
            printf( ",\n" );
        }
        printf( "];\n" );

	printf( "NqClass := %d;\n", Class );
	printf( "NqRanks := [ " );
	for( i = 1; i <= Class; i++ ) printf( " %d,", Dimension[i] );
	printf( "];\n" );
}

void	printRawWord( w )
word	w;

{       int nrc = 15;      /* something has already been printed */

	if( w == (word)0 || w->g == EOW ) { return; }
	
	while( w->g != EOW ) {
	    if( w->g > 0 ) {
                nrc += printf( " %d,", w->g );
#               ifdef LONGLONG
                nrc += printf( " %Ld,", w->e );
#               else
		nrc += printf( " %d,", w->e );
#               endif
            }
            else {
                nrc += printf( " %d,", -w->g );
#               ifdef LONGLONG
                nrc += printf( " %Ld,", -w->e );
#               else
                nrc += printf( " %d,", -w->e );
#               endif
            }
            w++;
	    /* Avoid long lines, because GAP can't read them. */
            if( w->g != EOW && nrc > 70 ) { printf( "\\\n    " ); nrc = 0; }
        }
}

void    PrintRawGapPcPres() {

        gen     g;
        long    i, j;
	long    cl = Class + (NrCenGens==0 ? 0 : 1);


        /*
        **  Output the number of generators first and their relative
        **  orders.  
        */
        printf( "NqNrGenerators   :=  %d;\n", NrPcGens+NrCenGens );
        printf( "NqRelativeOrders := [ " );
        for( i = 1; i <= NrPcGens+NrCenGens; i++ ) {
#           ifdef LONGLONG
                printf( "%Ld,", Exponent[i] );
#           else
                printf( "%d,", Exponent[i] );
#           endif
            if( i % 30 == 0 ) printf( "\n                       " );    
        }
        printf( " ];\n" );

        /*
        **  Print weight information.
        */
        printf( "NqClass          := %d;\n", Class );
        printf( "NqRanks          := [" );
        for( i = 1; i <= cl; i++ ) printf( " %d,", Dimension[i] );
        printf( "];\n" );

        /*
        **  Print the epimorphism.  It is sufficient to list the images.
        */
        printf( "NqImages         := [\n" );
        for( i = 1; i <= NumberOfAbstractGens(); i++ ) {
            printf( "  [ " );
            printRawWord( Epimorphism( i ) );
            printf( "],  # image of generator %d\n", i );
        }
        printf( "];\n" );

        /*
        **  Print the power relations.
        */
        printf( "NqPowers         := [\n" );
        for( i = 1; i <= NrPcGens+NrCenGens; i++ )
            if( Exponent[i] != (exp)0 && 
                Power[i] != (word)0 && Power[i]->g != EOW ) {
                printf( "  [ %d,   ", i );
                printRawWord( Power[i] );
                printf( " ],\n" );
            }
        printf( "];\n" );

        /*
        **  Print the conjugate relations.
        */
	printf( "NqConjugates     := [\n" );
        for( j = 1; j <= NrPcGens; j++ ) {
            for( i = 1; i < j && Wt(i) + Wt(j) <= cl; i++ ) {

                printf( "  [ %d, %d,   ", j, i );
                printRawWord( Conjugate[j][i] );
                printf( "],\n" );
	    }
	}

        for( j = 1; j <= NrPcGens; j++ ) {
            for( i = 1; i < j && Wt(i) + Wt(j) <= cl; i++ ) {
	      if( Exponent[i] == (exp)0 ) {

                printf( "  [ %d, %d,   ", j, -i );
                printRawWord( Conjugate[j][-i] );
                printf( "],\n" );
	      }
	    }
	}

        for( j = 1; j <= NrPcGens; j++ ) {
            for( i = 1; i < j && Wt(i) + Wt(j) <= cl; i++ ) {
	      if( Exponent[j] == (exp)0 ) {

                printf( "  [ %d, %d,   ", -j, i );
                printRawWord( Conjugate[-j][i] );
                printf( "],\n" );
	      }
	    }
	}

        for( j = 1; j <= NrPcGens; j++ ) {
            for( i = 1; i < j && Wt(i) + Wt(j) <= cl; i++ ) {
	      if( Exponent[i] + Exponent[j] == (exp)0 ) {

                printf( "  [ %d, %d,   ", -j, -i );
                printRawWord( Conjugate[-j][-i] );
                printf( "],\n" );
	      }
	    }
	}
        printf( "];\n" );

        printf( "NqRuntime := %d;\n", RunTime() );
}
