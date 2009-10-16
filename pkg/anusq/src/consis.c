/****************************************************************************
**
**    consis.c                 ANU SQ                        Alice C Niemeyer
**
**    Copyright 1994                             Mathematics Research Section
**                                            School of Mathematical Sciences
**                                             Australian National University
*/

#include <sys/types.h>
#include <stdio.h>
#include <malloc.h> 
#include "sq.h"
#include "modmem.h"
#include "arith.h"
#include "pcparith.h"

extern int chat;

void Consistency (f)
FILE *f;

{
    register uint i, j, k;
    ExtensionElement *e, *h, *ee, *lhs, *rhs, *ei, *ej, *ek, *eij;


    if ( chat >= 2 ) {
        fprintf( FN, "#I  Testing if presentation is consist\n");
        fprintf( FN, "#I  Checking the power relations\n");
      }

    h = NewExtensionElement();
    for ( i = 1; i <= P->Nr_GroupGenerators; i++ ) {
	ei = NumberExtensionElement(i); 
	h->group = P->relations[i][i].group;
	h->vector = P->relations[i][i].vector;
	lhs = MultiplyEELocal( h, ei );
	rhs = MultiplyEELocal( ei, h ); 
	if ( PrintMERelation( lhs, rhs, f ) ) fprintf( f, ";" );
	fprintf(f, "\n" );
        if ( chat == 4 || chat == 5 || chat == 7 ) {
            fprintf( FN, "#I  ");
	    PrintGenerator( FN, i ); fprintf( FN, "^%d * ", P->exponents[i] );
	    PrintGenerator( FN, i ); fprintf( FN, "\n" );
            fprintf( FN, "#I  "); PrintExtensionElement(lhs,FN);
            fprintf( FN, "\n#I  "); PrintExtensionElement(rhs,FN);
            fprintf(FN,"\n");
	}
        FreeExtensionElement(lhs);
        FreeExtensionElement(rhs);
	FreeExtensionElement(ei);
    }
	
    if ( chat >= 2 ) fprintf( FN, "#I  Checking the other relations\n");

    /* j^p * i */
    for ( i = 1; i < P->trivial + PDIM(1); i++ )  {
	ei = NumberExtensionElement(i); 
        for ( j = i+1; j <= P->Nr_GroupGenerators; j++ ) {
	    h->group  = P->relations[j][j].group;
	    h->vector = P->relations[j][j].vector;
/*
            if ( i >= P->trivial && IsDefinition(P->Nr_GroupGenerators,j,i) )
	        continue; 
*/
	    lhs = MultiplyEELocal( h, ei );

	    ej = NumberExtensionElement(j);
	    rhs = MultiplyEELocal( ej, ei ); 

	    for ( k = 0; k < P->exponents[j] - 1; k++ ) {
	        ee = MultiplyEELocal( ej, rhs ); 
		FreeExtensionElement(rhs);
		rhs = ee;
	    }
	    if( PrintMERelation( lhs, rhs, f ) )
		fprintf( f, ";" );
            if ( chat == 4 || chat == 5 || chat == 7 ) {
	        fprintf( FN, "#I  "); PrintGenerator( FN, j );
	        fprintf( FN, "^%d * ", P->exponents[j] );
	        PrintGenerator( FN, i ); fprintf( FN, "\n" );
	        fprintf( FN, "#I  "); PrintExtensionElement( lhs, FN );
                fprintf( FN, "\n#I  " ); PrintExtensionElement( rhs, FN );
	        fprintf( FN, "\n" );
	      }
	    FreeExtensionElement(ej);
	    FreeExtensionElement(rhs);
	    FreeExtensionElement(lhs);
	    fprintf(f, "\n" );
	  }
	  FreeExtensionElement(ei);
      }


    /* j * i^p */
    for ( i = 1; i <= P->Nr_GroupGenerators; i++ )  {
	ei = NumberExtensionElement(i);
        for ( j = i+1; j <= P->Nr_GroupGenerators; j++ ) {
	    h->group  = P->relations[i][i].group; 
	    h->vector = P->relations[i][i].vector;
	    k = h->group->gen;
/*
            if ( k>=P->trivial && k<j && P->definedby[k] != NULL &&
                 P->definedby[k][0]==i && P->definedby[k][1] == i)
	        continue;
*/
            ej = NumberExtensionElement(j);
	    lhs = MultiplyEELocal( ej, h );
	    rhs = MultiplyEELocal( ej, ei ); 
 	    for ( k = 0; k < P->exponents[i] - 1; k++ ) {
	        ee = MultiplyEELocal( rhs, ei ); 
		FreeExtensionElement(rhs);
		rhs = ee;
	    }
	    if ( PrintMERelation( lhs, rhs, f ) ) 
		fprintf( f, ";" );
            if ( chat == 4 || chat == 5 || chat == 7 ) {
                fprintf( FN, "#I  "); PrintGenerator( FN, j );
	        fprintf( FN, "* "); PrintGenerator( FN, i );
     	        fprintf( FN, "^%d ",  P->exponents[i] );
	        fprintf( FN, "\n#I  " );
	        PrintExtensionElement( lhs, FN );
	        fprintf( FN, "\n#I  " );
	        PrintExtensionElement( rhs, FN );
	        fprintf( FN, "\n" );
	    }
	    FreeExtensionElement(ej);
	    FreeExtensionElement(rhs);
	    FreeExtensionElement(lhs);
	    fprintf(f, "\n" );
	 }
	FreeExtensionElement(ei);
      }


    /* k * j * i */
    for ( i = 1; i < P->trivial+PDIM(1); i++ )  {
	ei = NumberExtensionElement(i); 
        for ( j = i+1; j <= P->Nr_GroupGenerators; j++ ) {
	    ej = NumberExtensionElement(j); 
	    eij = MultiplyEELocal( ej, ei ); 
            for ( k = j+1; k <= P->Nr_GroupGenerators; k++ ) {
/*
	        if ( i>=P->trivial && IsDefinition(P->Nr_GroupGenerators,j,i) )
		    continue;
*/
		ek = NumberExtensionElement(k); 
		ee = MultiplyEELocal( ek, ej);
		lhs = MultiplyEELocal( ee, ei );
		FreeExtensionElement( ee );

		rhs = MultiplyEELocal( ek, eij );
		if ( PrintMERelation(lhs,rhs,f) ) fprintf( f, ";" );
                if ( chat == 4 || chat == 5 || chat == 7 ) {
	            fprintf( FN, "#I  " );
	            PrintGenerator( FN, k ); fprintf( FN, "* ");
	            PrintGenerator( FN, j ); fprintf( FN, "* ");
	            PrintGenerator( FN, i );
	            fprintf( FN, "\n#I  " );
	            PrintExtensionElement( lhs, FN );
	            fprintf( FN, "\n#I  " );
	            PrintExtensionElement( rhs, FN );
		    fprintf( FN, "\n" );
		  }
		FreeExtensionElement(ek);
		FreeExtensionElement(rhs);
		FreeExtensionElement(lhs);
		fprintf(f, "\n" );
	    }
	    FreeExtensionElement(ej);
	    FreeExtensionElement(eij);
	}
	FreeExtensionElement(ei);
    }

    Free( (void *) h );
}


