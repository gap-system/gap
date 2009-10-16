/****************************************************************************
**
**    modmem.c                 ANU SQ                        Alice C Niemeyer
**
**  Copyright 1994                               Mathematics Research Section
**                                            School of Mathematical Sciences
**                                             Australian National University
*/

#include <stdio.h>
#include "pres.h"
#include "sq.h"
#include "pcparith.h"

extern Presentation *P;
extern GroupWord CollectGroupWord();

/* The Error Function */
void Error( str )
char *str;

{
    fprintf( stderr, "%s\n", str );
    exit(1);
}


/****************************************************************************
**
**                  Memory Allocation
**
** The following functions allocate memory for the various data objects.
*/

/*
** Allocate storage for a group word of length <nr>.
*/
GroupWord NewGroupWord( nr )
uint nr;

{
    GroupWord       w;

    w = (GroupWord) Allocate( (nr+1)*sizeof(GroupGenerator) );


    return w;
}

GroupWord GroupWordOne()
{
    GroupWord  w;

    w = NewGroupWord(1);
    w->gen = 1;
    w->exp = 0;
    return w;
}

GroupWord CopyGroupWord(w)
GroupWord w;
{
    GroupWord v, r;

    if ( w == (GroupWord) NULL ) return w;
    if ( ISONEGG(w) ) return IdGrp;

    r = v = NewGroupWord( LengthGroupWord(w) );

    while( ISBOUNDGG(w) ) {
      v->gen = w->gen;
      v->exp = w->exp;
      v++; w++;
    }

    return r;
}

/*
** The elements of the group ring are arrays of RingElements.
** Allocate storage for an array of length <nr>.
** Note that no storage is allocated for the group words.
*/
RingWord NewRingWord( nr )
uint nr;
{
    RingWord        w;

    w = (RingWord) Allocate( (nr+1)*sizeof(struct RingElement) );

    return w;
}

RingWord RingWordOne()
{
    RingWord  r;

    r = NewRingWord(1);
    r->mult = 1;
    r->ring =  IdGrp;
    return r;
}

RingWord CopyRingWord(w)
RingWord w;
{
    RingWord  r, v;

    if ( w == (RingWord) NULL ) return w;
    if ( ISONERE(w) ) return RingWordOne();

    r = NewRingWord( LengthRingWord(w) );

    for ( v = r; ISBOUNDRE(w); v++, w++){
      v->ring = CopyGroupWord( w->ring );
      v->mult = w->mult;
    }

    return r;
}

/*
** Allocate storage for a vector of length <nr>.
*/
Vector NewVector( nr )
uint nr;
{
    Vector v;

    v = (Vector) Allocate( (nr+1)*sizeof(ModuleGenerator) );

    return v;
}

Vector VectorOne()
{
    Vector v;
    
    v = NewVector(1);
    v->gen = 1;
    v->exp = NULL;
    
    return v;
}

Vector NormalNewVector( l )
uint l;
{
    Vector tv;
    int    i;

    tv = NewVector (l);
    for ( i = 0; i < l; i++ ) {
        tv[i].gen = P->Nr_GroupGenerators + i + 1;
        tv[i].exp = (RingWord) NULL;
    }

    return tv;
}

Vector CopyVector(v)
Vector v;
{
    Vector w, x;

    if ( v == (Vector) NULL) return v;
    if ( ISONEMG(v) ) return VectorOne();

    w = NewVector (LengthVector (v));

    for ( x = w; ISBOUNDMG(v); v++, x++ ) {
      x->gen = v->gen;
      x->exp = CopyRingWord( v->exp );
    }

    return w;

}

ExtensionElement *CopyExtensionElement(ee)
ExtensionElement *ee;
{
    ExtensionElement *res;

    res = (ExtensionElement *) Allocate( sizeof(ExtensionElement) );
    res->group = CopyGroupWord( ee->group );
    res->vector = CopyVector( ee->vector );

    return res;

}

Presentation *NewPresentation()
{
    Presentation *P;

    P = (Presentation*) Allocate( sizeof(Presentation) );
    P->name = "SqPresentation";

    return P;
}

    
/*
** Allocate storage for an ExtensionElement.
** Note that no storage is allocated for the struct entries.
*/
ExtensionElement *NewExtensionElement()
{
    ExtensionElement *e;

    e = (ExtensionElement *) Allocate( sizeof(struct _ExtensionElement) );

    return e;
}

/****************************************************************************
**
**                        Free
**
** The following functions deal with freeing the data structures.
*/

void FreeGroupWord( w )
GroupWord w;
{
    if ( w == (GroupWord) NULL || w == IdGrp ) return;

    Free( (void *) w); 
}

void FreeRingWord( w )
RingWord w;
{
    RingWord    v;

    if ( w == (RingWord) NULL ) return;

    for ( v = w; ISBOUNDRE(v); v++ )
        FreeGroupWord(v->ring);

    Free( (void *) w);

}


void FreeVector( v )
Vector v;
{
    Vector        w;

    if ( v == (Vector) NULL ) return;

    for ( w = v; ISBOUNDMG(w); w++ )
        FreeRingWord(w->exp);

    Free( (void *) v);

}

void FreeExtensionElement( e )
ExtensionElement *e;
{
    FreeGroupWord( e->group );
    FreeVector( e->vector );

    Free( (void *) e );
}

/****************************************************************************
**
**                      Print
**
** The following functions print the data structures.
*/


PrintGeneratorVE( fpt, i )
FILE * fpt;
int      i;

{
    i -= 1;
    while ( i >= 0) {
      fputc( 'a' + i%26, fpt );
      i /= 26;
      i -= 1;
    }
}

PrintGenerator( fpt, i )
FILE * fpt;
int      i;

{
    fprintf( fpt, "a.%d", i );
}

/*
** The following function prints a GroupWord. If the flag ve is  non-zero, 
** it is printed in the format used by the Vector Enumerator. This means in
** particular that the power a^2 is printed as a2. If ve is zero it is 
** printed in GAP format.
*/

PrintGroupWord (g,f,ve)
GroupWord g;
FILE *f;
int ve;
{   
    char c;

    if ( g == (GroupWord) NULL ) return;
    if ( ISONEGG(g) ) {
        fprintf( f, "1" );
        return;
    }

    c = ' ';
    if (ve) 
        for ( ; ISBOUNDGG(g); g++ ) {
	    fputc( c, f );
	    PrintGeneratorVE( f, g->gen );
            if ( g->exp != 1 )  
                fprintf( f, "%d", g->exp );
            c = '*';
         }
    else 
        for ( ; ISBOUNDGG(g); g++ ) {
	    if ( c != ' ' )
		fputc( c, f );
	    PrintGenerator( f, g->gen );
            if ( g->exp != 1 )  
                fprintf( f, "^%d", g->exp );
            c = '*';
         }
}


PrintRingWord ( w, f, ve )
RingWord w;
FILE *f;
int ve;
{
    int printed;
    GroupWord gw;

    if ( w == (RingWord) NULL || (w->mult == 0 && w->ring == NULL)) {
        fprintf( f, "0" );
        return;
    }
   

    printed = 0;
    for ( ; ISBOUNDRE(w); w++ ){
        if ( w->mult != 0 ) {
	    if ( printed ) fprintf( f, " + " );
#ifdef COLLECT
	    gw = CollectGroupWord( w->ring );
#else
            gw = w->ring;
#endif
            if ( w-> mult != 1 ) fprintf( f, "%d * ", w->mult );
            if( gw != NULL && ISBOUNDGG(gw) )  
                PrintGroupWord( gw, f, ve );
	    else
	        fprintf( f, "1" );
            printed = 1;
#ifdef COLLECT
            FreeGroupWord( gw );
#endif
	}
    }

    if ( !printed )
        fprintf( f, "0" );
}

PrintVector (v, f)
Vector v;
FILE *f;
{
    char    c;

    if ( v == (Vector) NULL ) return;
    
    if ( ISONEMG(v) ) {
        fprintf( f, "1" );
	return;
    }

    c = ' ';
    for ( ; ISBOUNDMG(v); v++ ) {
        if ( v->exp != (RingWord) NULL && (v->exp)->mult != 0 ) {
	    if ( c == '*' ) fputc( c, f );
            fprintf( f, "t%d", v->gen-P->Nr_GroupGenerators);
	    c = '*';
	    if ( ISBOUNDRE(v->exp) && !ISONERE(v->exp) ){
		fprintf( f, "^(" );
		PrintRingWord( v->exp, f, 0 );
		fprintf( f, ")" );
	    }
	}
    }
}

PrintExtensionElement (e,f)
ExtensionElement *e;
FILE *f;
{
	int vecone, grpone;

	vecone = grpone = 1;

	if ( e == (ExtensionElement *) NULL ) return;

	if ( e->vector != NULL && ISBOUNDMG(e->vector) && !ISONEMG(e->vector) )
		vecone = 0;
	if ( e->group != NULL && ISBOUNDGG(e->group) && !ISONEGG(e->group) )
		grpone = 0;

	if ( !grpone  )
	    PrintGroupWord( e->group, f, 0 );
	if ( !vecone || (grpone && vecone) )  {
	    if (!grpone) fprintf( f, "*" );
	    PrintVector( e->vector, f );
	}

}


PrintExPresentation (f)
FILE *f;
{

    register i, j;


    if ( P->Nr_Generators == P->Nr_GroupGenerators ) {
	fprintf( f, "a := FreeGroup( %d, \"a\" );\n", P->Nr_Generators );
    }

    fprintf(f,"%s := rec(\n", P->name );
    fprintf(f,"      generators := [ ");
    for ( i = 1; i < P->Nr_Generators; i++ ) {
	if ( i <= P->Nr_GroupGenerators )
	    PrintGenerator( f, i );
	else 
	    fprintf( f, "t%d", i-P->Nr_GroupGenerators );
	fprintf( f, ", ");
    }
    if ( P->Nr_GroupGenerators == P->Nr_Generators ) {
	PrintGenerator( f, P->Nr_Generators );
	fprintf( f, " ],\n" );
    }
    else 
	fprintf( f, "t%d ],\n", P->Nr_Generators-P->Nr_GroupGenerators );

    /*    fprintf(f,"      exponents := [");
    for ( i = 1; i < P->Nr_Generators; i++ )
      fprintf(f,"%d,", P->exponents[i] );
    fprintf(f,"%d ],\n", P->exponents[P->Nr_Generators] );
    */
    fprintf(f,"      relators := [\n");

    /* Don't print the other relations, since they are not inserted!! */
    for ( i = 1; i <= P->Nr_GroupGenerators; i++ ){
	for ( j = 1; j <= i; j++ ){
	    if ( i != j ) {
		PrintGenerator( f, i );
		fprintf( f, "^" );
		PrintGenerator( f, j );
	    }
	    else {
		PrintGenerator( f, i );
		fprintf( f, "^%d", P->exponents[i] );
	    }
	    if ( (P->relations[i][j]).group !=  (GroupWord) NULL )
		    if ( !ISONEEE(&P->relations[i][j]) &&
                        (P->relations[i][j].group->gen != 0 ||
			 (P->relations[i][j].vector != NULL &&
			  !ISONEMG(P->relations[i][j].vector))) ){
			fprintf( f, "/(");
			PrintExtensionElement( &P->relations[i][j],f );
			fprintf( f, ")");
		    }
		if ( j <= i ) fprintf( f, ",  " );
	    }
	    fprintf(f, "\n");
	  }  
	fprintf( f, "]\n" );

    fprintf( f, "# Definitions\n");
    for ( i = 1; i <= P->Nr_Generators; i++ ) 
        if ( !P->defepi[i] && P->definedby[i] != (int *) NULL ) {
            if ( i > P->Nr_GroupGenerators )
	        fprintf( f, "# t%d <- ", i - P->Nr_GroupGenerators );
            else {
		 fprintf( f, "# ");
	         PrintGenerator( f, i );
                 fprintf( f, " <- " );
	    }
	    if ( P->definedby[i][0] == P->definedby[i][1] ) {
	         /* defined as a $p$-th power */
	         if ( P->definedby[i][0] > P->Nr_GroupGenerators ) 
		     fprintf ( f, "t%d^%d\n", 
                     P->definedby[i][0]-P->Nr_GroupGenerators,
                     P->exponents[P->definedby[i][0]-P->Nr_GroupGenerators] );
		 else {
		     PrintGenerator ( f, P->definedby[i][0] );
		     fprintf( f, "^%d\n", P->exponents[P->definedby[i][0]] );
		 }
	    }
            else {
	         if ( P->definedby[i][1] > P->Nr_GroupGenerators ) {
		     fprintf ( f, "t%d^" );
                     PrintGenerator(f,P->definedby[i][1]-P->Nr_GroupGenerators);
	         }
		 else {
		     PrintGenerator( f, P->definedby[i][1] );
		     fprintf ( f, "^" );
		 }
	         if ( P->definedby[i][0] > P->Nr_GroupGenerators )  {
		     fprintf ( f, "t%d\n", 
                     P->definedby[i][0]-P->Nr_GroupGenerators );
		 }
		 else {
		     PrintGenerator ( f,  P->definedby[i][0] );
		     fprintf ( f, "\n" );
		 }
	  }
    }   

    fprintf( f, "# Epimorphism : " );
    for ( i = 1; i <= P->Nr_Orig; i++ ) {
        fprintf( f, "phi(%d) ", i );
	if ( IsDefEpi(i) ) fprintf( f, ":" );
	fprintf( f, "= ");
        PrintExtensionElement( &(P->Epimorphism[i]), f );
	if ( i < P->Nr_Orig )
	    fprintf( f, ", " );
	else
	    fprintf( f, " " );
    }


    fprintf( f, "\n)\n\n");
}


IsTrivialRingWord ( w )
RingWord w;

{
	for ( ; ISBOUNDRE(w); w++ )
		if (w->mult != 0) return 0;

	return 1;
}

/* 
** Print the module enumerator relations in packed format.
*/ 
int PrintMERelation( lhs, rhs, f )
ExtensionElement *lhs, *rhs;
FILE *f;

{
     RingWord    r;
     Vector v1, v2;
     uint        i, printed;


     v1 = lhs->vector; 
     v2 = rhs->vector;
     printed = 0;
     for ( i = 1; i <= P->Nr_Generators - P->Nr_GroupGenerators; i++ ) {
         if ( v1 && ISBOUNDMG(v1) && (v1->gen == i+P->Nr_GroupGenerators) ) {
	     if ( (v2 == NULL) || 
                  (ISBOUNDMG(v2) && (v2->gen != i+P->Nr_GroupGenerators))){
	           if ( v1->exp != NULL && ISBOUNDRE(v1->exp) &&
		        !IsTrivialRingWord( v1->exp ) )  {
		       if ( printed ) fprintf( f, ", " );
		       else fprintf( f, "[" );
		       fprintf( f, "%d, ", i );
		       PrintRingWord( v1->exp, f, 1 );
		       printed = 1;
		   }
	     }
	     else {
	         r = SubRingWord( v1->exp, v2->exp );
		 if ( r != NULL && ISBOUNDRE(r) && !IsTrivialRingWord(r) ) {
	             if ( printed ) fprintf( f, ", " );
		       else fprintf( f, "[" );
		     fprintf( f, "%d, ", i );
		     PrintRingWord( r, f, 1 );
		     printed = 1;
		 }
		 FreeRingWord(r);
		 v2++;
	     }
	     v1++;
	 }
        else if (v2 && ISBOUNDMG(v2) && (v2->gen == i+P->Nr_GroupGenerators)){
               if ( v2->exp != NULL && ISBOUNDRE(v2->exp) )  {
		       if ( printed ) fprintf( f, ", " );
		       else fprintf( f, "[" );
		       fprintf( f, "%d, ", i );
	               r = SubRingWord( 0, v2->exp );
		       PrintRingWord( r, f, 1 );
		       printed = 1;
		       FreeRingWord(r);
		   }
	         v2++;
        }
       }
	if( printed ) fprintf( f, "]" );

	return printed;
}
