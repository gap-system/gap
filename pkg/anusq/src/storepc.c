/****************************************************************************
**
**    storepc.c                ANU SQ                        Alice C Niemeyer
**
**    Copyright 1994                             Mathematics Research Section
**                                            School of Mathematical Sciences 
**                                             Australian National University
*/

#include <stdio.h>
#include "pres.h"
#include "sq.h"
#include "modmem.h"

extern char * GenName();

static	void	StoreError( str )
char	*str;

{	InitPrint( stderr );
	fprintf( stderr, "%s:\n    ", str );
	PrintNode( CurrentRelation() );
	fprintf( stderr, "\n" );
	fflush( stderr );

	exit( 7 );
}


Presentation *InitPresentation()
{
    register      i;
    uint         nr;

    nr = NumberOfGens();
    P = NewPresentation();
    P->Nr_GroupGenerators = nr;
    P->Nr_Generators = nr;
    P->Nr_Orig = nr;
    nr ++; /* the generators a numbered starting from 1 and we 
              want to use these numbers in addressing           */

    P->exponents = (int*) Allocate( nr*sizeof(int) );
    P->exponents[0] = 0;
    P->relations = (ExtensionElement **)
                          Allocate ((nr+1)*sizeof(ExtensionElement *));

    for ( i = 1; i < nr; i++ ) 
        P->relations[i] = (ExtensionElement *) 
                          Allocate((i+2)*sizeof(ExtensionElement) );
    

    P->definedby = (int **) Allocate( (nr+1) *sizeof(int*) );

    P->defepi = (uint *) Allocate( (nr+1) * sizeof(int) );
    P->Epimorphism = (ExtensionElement *) 
                     Allocate( (nr+1) * sizeof(ExtensionElement) );
    for ( i = 1; i <= nr; i++ ) {
        P->Epimorphism[i].group = NewGroupWord(1);
        P->Epimorphism[i].group->gen = (gen) i;
        P->Epimorphism[i].group->exp = 1;
	P->defepi[i] = i;
    }        
 
    return P;

}

int IsDefinition( nr, i,j )
int nr, i, j;

{
    int ** pt, l;

    if ( i > j ) { l = i; i = j; j = l; }
    for ( pt = P->definedby+1, l = 1; l <= nr; pt++, l++ )
        if (!P->defepi[l] && (*pt) && (*pt)[0] == i && (*pt)[1] == j ) return 1;

    return 0;
}

IsDefEpi (i) 
int i;

{
	register j;
 
	for ( j = 1; 
	      j <= (P->Nr_GroupGenerators < P->Nr_Orig ? 
		    P->Nr_Orig: P->Nr_GroupGenerators); j++ )
		if ( P->defepi[j] == i )
			return j;

	return 0;

}

void	StorePower( g, e, rhs, defining )
gen	           g;
int                e;
ExtensionElement   *rhs;
int	           defining;

{	
	GroupWord gw;
	gen      rg;

	if( e <= 0 ) StoreError( "Negative power not allowed" );

	if( P->exponents[g] != 0 )
	    StoreError( "Duplicate power relation" );
	P->exponents[g] = e;
	if ( rhs == (ExtensionElement *) NULL ){
		rhs = NewExtensionElement();
		rhs->group = NewGroupWord(0);
		rhs->vector = NewVector(0);
	}
	P->relations[g][g] = *rhs;

	gw = rhs->group;
	while( ISBOUNDGG(gw) ) {
	    if( gw->gen < g ) 
		StoreError("Right hand side has gens of too small weight");
	    gw++;
	}

	if( defining ) {
	    if (LengthGroupWord(rhs->group) > 1 ||
		(rhs->group)->exp != 1 )
		    StoreError("Right hand side not a single generator");
	    rg = (rhs->group)->gen;
	    if ( P->definedby[rg] != (int *) NULL )
		    StoreError("Generator already defined\n" );
	    P->definedby[rg] = (int *) Allocate( 2*sizeof(int) );
	    P->definedby[rg][0] = g;
	    P->definedby[rg][1] = g;
	}
}

void	StoreConj( h, g, rhs, defining )
gen	h, g;
ExtensionElement  *rhs;
int	defining;

{	
	 GroupWord gw;
	 gen      rg;
	 int       l;

	/* g might be the inverse of a generator. */
	if( h <= g )
	    StoreError( "Wrong left hand side" );

	if( ISBOUNDEE(P->relations[h][g]) )
	    StoreError( "Duplicate conjugate relation" );
	P->relations[h][g] = *rhs;

	gw = rhs->group;
	while( ISBOUNDGG(gw) ) {
	    if( gw->gen < g )
		StoreError("Right hand side has gens of too small weight");
	    gw++;
	}


	if( defining ) {
	    l = LengthGroupWord(rhs->group);
	    rg = (rhs->group[l-1]).gen;
	    if ( P->definedby[rg] != (int *) NULL ) 
		    StoreError( "Generator already defined\n" );
	    P->definedby[rg] = (int *) Allocate( 2*sizeof(int) );
	    P->definedby[rg][0] = h;
	    P->definedby[rg][1] = g;
	}
}

static	int	DoNotCommute( h, g )
usgshort	h, g;

{	if( P->relations[h]            == (ExtensionElement *) 0 )  return 0;
	if( P->relations[h][g].group  == NULL &&
	    P->relations[h][g].vector == NULL )                    return 0;
	if( P->relations[h][g].group->gen == h &&
	    P->relations[h][g].group->exp == 1 &&
	    P->relations[h][g].group[1].gen == NULL ) return 0;

	return 1;
}

