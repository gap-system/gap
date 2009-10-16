/****************************************************************************
**
**    eapquot.c                ANU SQ                        Alice C Niemeyer
**
**    Copyright 1994                             Mathematics Research Section
**                                            School of Mathematical Sciences 
**                                             Australian National University
**
**  This file contains all actions necessary to compute the elementart abelian
**  $p$-quotient.
**
*/

#include "pres.h"
#include "sq.h"
#include "modmem.h"
#include "pcparith.h"

extern int chat;

int * SubVec( v, w, m, dim )
int *v, *w, m, dim;

{
    int *x, i;

    x = (int *) Allocate( (dim+1) * sizeof(int) );

    for ( i = 0; i < dim; i++ ) {
        x[i] = (v[i] - m*w[i]);
	while ( x[i] < 0 ) x[i] += P->prime;
	x[i] %= P->prime;
    }

    return x;

}

int * MultVec( m, v, dim )
int m, *v, dim;

{
    int *w, i;

    w = (int *) Allocate( (dim+1)*sizeof(int) );
    for ( i = 0; i < dim; i++ )
        w[i] = (m*v[i]) % P->prime;

    return w;
}

void PrintVec( v, dim, FN )
int *v, dim;
FILE *FN;
{
     int i;

     for ( i = 0; i < dim; i++ )
        fprintf( FN, "%d ", v[i] );

     fprintf( FN, "\n");

}


Sift( linsys, heads, v, dim )
int ** linsys, *heads, *v, dim;

{
	int i, pos, **ls;

        for ( i = 0, ls = linsys; *ls != NULL; ls++, i++ )
		v = SubVec( v,  *ls, v[heads[i]], dim );

	for ( pos = 0; pos < dim && v[pos] == 0; pos++ )
		;

	if ( pos >= dim ) return;
        heads[i] = pos;

	i = 1; while ( (i*v[pos])% P->prime != 1 ) i++;
        *ls = MultVec( i, v, dim );
	
}

int InvP ( r )
int r;

{
    int l;
    
    if ( r == 0 ) return r;
    for ( l = 1; l < P->prime; l++ )
      if ( (l*r) % P->prime == 1 ) return l;

  }

int ** Gauss( sys, n, dim )
int ** sys, n, dim;

{
	int **linsys, **ls, *heads, *v, i, j, h, sorted;

        linsys = (int **) Allocate( (n+1)*sizeof(int *) );
        heads  = (int *)  Allocate( (n+1)*sizeof(int *) );

	
        /* Change it such that the vectors get sifted as
	** they get computed 
        */
	for ( ls = sys; *ls != NULL; ls++ ) {
		Sift( linsys, heads, *ls, dim );
		Free( (void *) *ls );
	}
	
	if ( *linsys == NULL ) { Free( (void *) sys ); return linsys; }

	sorted = 0;
	while ( !sorted ) {
	     for ( i=0, sorted=1; linsys[i]!=NULL && linsys[i+1]!=NULL; i++ ) 
	         if ( heads[i] > heads[i+1] ) {
		       sorted = 0;
		       v = linsys[i];
		       linsys[i] = linsys[i+1];
		       linsys[i+1] = v;
		       h = heads[i];
		       heads[i] = heads[i+1];
		       heads[i+1] = h;
		  }
	}


        for ( i = 0; linsys[i] != NULL; i++ )
	    for ( j = 0; j < i; j++ ) {
		if ( linsys[j][heads[i]]  != 0 ) {
		    v = linsys[j];
		    linsys[j] = SubVec( v, linsys[i], InvP(v[heads[i]]), dim );
		    Free( v );
		}
	    }

        Free( (void *) sys );
	return linsys;
}



int ** EApQuot( fpt )
FILE *fpt;
{
	node	               *r;
	ExtensionElement       *w; 
        int                  i, j, start, **sys, *pts, nrr, **ls;
	GroupWord              gw;
  
    for ( i = 1; i <= P->Nr_GroupGenerators; i++ ) 
	    for ( j = 1; j <= i; j++ )  {
		if ( !ISBOUNDEE(P->relations[i][j])  ){ 
                    /* If the relation is not bound, then make it
                    ** a trivial relation. I.e. if it is a power 
                    ** relation make the rhs trivial and if it is
		    ** a conjugate realtion let the rhs consist of
		    ** base generator. 
		    */
	            P->relations[i][j].group = GroupWordOne();
                    if ( i > j ) {
	                P->relations[i][j].group->gen = i;
	                P->relations[i][j].group->exp = 1;
		    }
		    P->relations[i][j].vector = VectorOne();
	        }
      	    }

        if (chat >= 3) 
            PrintExPresentation(fpt);
	Commute();
	nrr =  NumberOfRels();
	sys = (int **) Allocate( (nrr+1)*sizeof(int *) );
	for ( i = 0; i < nrr; i++ )
	    sys[i] = (int *) Allocate ( P->Nr_GroupGenerators*sizeof(int) );

	r = FirstRelation();
	j = 0;
	while( r != (node *)0 ) {
	    w = EvalNode( r );
	    gw = w->group;
            if ( gw != (GroupWord) NULL && !ISONEGG(gw) ) { 
	        for ( i = 1; i <= P->Nr_GroupGenerators ; i++  )
	            if ( gw->gen == i )
			sys[j][i-1] = gw++->exp;
		    else sys[j][i-1] = 0;
	    }
	    FreeExtensionElement(w);
	    r = NextRelation();
            j++;
	}
	
	sys = Gauss( sys, nrr, P->Nr_GroupGenerators );

  
	if ( chat >= 4 ) {
	    fprintf( FN,"#I  Equations of the elementary abelian quotient :\n");
            for ( ls = sys; *ls != NULL; ls ++ ) {
	        fprintf( FN, "#I  " );
                for ( j = 0; j < P->Nr_GroupGenerators; j++ )
                    fprintf( FN, "%d ", (*ls)[j] );
	        fprintf( FN, "\n" );
	    }
       }
  return sys;
}


ElimTailsOne( ls )
int ** ls;
{
    int           i, j, l, m, n, g, nr, onr;
    GroupWord     gw;
    Presentation  *Q;

    onr = nr = P->Nr_GroupGenerators;
    for ( i = 0; ls != NULL && ls[i] != NULL && nr > 0; i++ ) {
        /* The first non-zero entry yields the generator to be removed */
	j = 0;
        while ( j < P->Nr_GroupGenerators && ls[i][j] == 0 )
	    j++;
        /* The generator j+1 is removed in the epi */
	g = j+1;
/*	P->defepi[g] = 0; 22jan */
	for ( n = 0; n <= onr; n++ )
	    if (P->defepi[n] == g )
	        P->defepi[n] = 0;
	j++;
	--nr;
	while (j < P->Nr_GroupGenerators && ls[i][j]==0) 
	    j++;
#ifdef SAFE
       if ( g > P->Nr_Orig ) 
	      fprintf( stderr, "#W Epimorphic-image of %d used\n", g);
#endif
	if ( j == P->Nr_GroupGenerators ) {
              /* g was the only non-trivial entry */
	      P->Epimorphism[g].group = GroupWordOne();
	}
        else {
	    /* If g was not the only non-trivial entry, then we want
            ** to keep it and express the first non-trivial entry l as
            ** a word in the others.
            */
	    l = 1;
	    /* WHAT IS THIS l thing here XXX */
	    gw = P->Epimorphism[g].group = NewGroupWord(l);
            /* j is the fisrt position after g which is non-trivial */
            for ( ; j < P->Nr_GroupGenerators; j++ ) 
		if ( ls[i][j] != 0 ) { 
		    gw->gen = j+1;
		    gw->exp = P->prime - ls[i][j];
		    gw++;
		}
	    /* Now here we actually do have to take the inverse  of */
	    /* the resulting group word. Still needs to be done. */
	    /* XXX  */

	}
	ls[i][0] = g; /* save the deleted generator */
    }

    /* if an intermediate generator was removed count the	
    ** numbers of the others down and update the defepi entries.
    */
    for ( i = 0; ls != NULL && ls[i] != NULL && nr > 0; i++ ) { 
        /* loop throught the entries of the epimorphism and 
        ** count them down, if they are after a deleted generator 
        */
	for ( j = 1; j <= P->Nr_Orig; j++ )
	    for ( n = 0; n < LengthGroupWord(P->Epimorphism[j].group); n++ )
		if ( (P->Epimorphism[j].group+n)->gen > ls[i][0] ) 
		   ( P->Epimorphism[j].group+n)->gen -= 1; 
        /* update the generators to be deleted 
        */
        for ( j = i+1; ls != NULL && ls[j] != NULL; j++ )
	    ls[j][0] --;
	for ( j = ls[i][0]+1; j <= P->Nr_GroupGenerators; j++ ) {
		P->defepi[j-1] = P->defepi[j];
		P->defepi[j] = 0;
	}
    }

	if ( ls != NULL ) {
        for ( i = 0; ls[i] != NULL; i++ )
	    Free( ls[i] );
	Free( ls );
    }

    Q = NewPresentation();
    if (chat >= 1 ) 
	fprintf( FN, "#I  First step : %d dimensions\n", nr );

    Q->Nr_GroupGenerators = nr;
    Q->Nr_Generators = nr;
    Q->Lseries = (uint**) Allocate( sizeof( int*) );
    Q->Lseries[0] = (uint *) Allocate ( 2*sizeof(int) );
    Q->Lseries[0][0] = 1;
    Q->Lseries[0][1] = nr;
    Q->Lfactor = 0;
    Q->Nr_Orig = P->Nr_GroupGenerators;
    nr ++; /* the generators are numbered starting from 1 and we
              want to use these numbers in addressing           */
  
    Q->exponents = (int*) Allocate( nr*sizeof(int) );
    Q->exponents[0] = 0;
    Q->relations = (ExtensionElement **)
                          Allocate ((nr+1)*sizeof(ExtensionElement *));

    for ( i = 1; i < nr; i++ ) {
        Q->relations[i] = (ExtensionElement *)
                          Allocate((i+2)*sizeof(ExtensionElement) );
        /* 7.8.94 The right hand side of the relations needs
        ** to be updated - this showed up in class 1 groups.
        ** If the right hand side is not present in AddDefinitions,
        ** then it is added there.
        */ 
        for ( j = 1; j <= i; j++ ) { 
		Q->relations[i][j].group = GroupWordOne();
                if ( i > j ) {
                        Q->relations[i][j].group->gen = i;
                        Q->relations[i][j].group->exp = 1;
                }
                Q->relations[i][j].vector = VectorOne();
         }
        Q->exponents[i] = P->prime;
    }
    Q->definedby = (int **) Allocate( (nr+1) *sizeof(int*) );
    Q->prime = P->prime;

    Q->Epimorphism = P->Epimorphism;
    Q->defepi      = P->defepi;
    Q->name = P->name;
    Q->trivial = P->trivial;
    Q->Commute = P->Commute;
    Free( P->exponents );
    for ( i = 0; i <= P->Nr_GroupGenerators; i++ ) {
	Free( P->relations[i] );
	Free( P->definedby[i] );
    }
    Free( P->relations );
    Free( P->definedby );
    Free(P);
    P = Q;

}
