/****************************************************************************
**
**    updatepres.c             ANU SQ                        Alice C Niemeyer
**
**    Copyright 1994                             Mathematics Research Section
**                                            School of Mathematical Sciences 
**                                             Australian National University
**
**
**  This file contains the functions to update the power conjugate 
**  presentation to incorporate the module computed by the vector 
**  enumerator.   
**
*/

#include "pres.h"          
#include "sq.h"            /* header file for data structures             */
#include "modmem.h"        /* header file for memory management           */
#include "pcparith.h"      /* header file for arithmetic functions        */
#include "veinter.h"       /* header file for vector enumerator interface */

extern int chat;

FindRel( i, onr) 
int i, onr;
{
	register int k, j;
	GroupWord      gw;

	/* i => nr 16.1.93 (had a def r := r^d) */
	for ( j = 1; j <= P->Nr_Generators; j++ ) 
	    for ( k = 1; k <= j; k++ ){
		if ( !IsDefinition(P->Nr_Generators,j,k) ) {
		    gw=P->relations[j][k].group;
		    for ( ; gw && ISBOUNDGG(gw); gw++ ) 
			if ( gw->gen == i && gw->exp == 1 && 
                             (gw+1)->gen == NULL && i != k && i != j) {
			     /* Added i!= k && i != j. 16.1.93 */
			     P->definedby[i][0] = k;
			     P->definedby[i][1] = j;
			     return 1;
			 }
		}
	    }
			
	return 0;

}

AlterRelation( j, k, s, t, onr )
int j, k, s;
GroupWord t;
int onr;

{
      register  i, l;
      GroupWord gw, ng, ptn, ptg, pt, nt;

      ptn = ng = NewGroupWord( P->Nr_Generators );
      ptg = gw = P->relations[j][k].group;
      /* copy the rhs up to and not including s */
      for ( ; ptg->gen < s; ptn++, ptg++ ) {
	  ptn->gen = ptg->gen;
	  ptn->exp = ptg->exp;
      }
      /* now copy s, note that ptg points to position of s */
      ptn->gen = ptg->gen;
      ptn->exp = ptg->exp;
      ptn++;

      /* compute the correct power of t */
      pt = nt = NewGroupWord( LengthGroupWord(t) );
      for ( ; ISBOUNDGG(t); pt++, t++ ) {
	  pt->gen = t->gen;
	  pt->exp = (t->exp * ptg->exp) % P->prime;
      }
      pt = t = nt;
      ptg++;
      /* from the remainder just subtract t (since we know it
      ** is part of the module 
      */
      for (  ; ISBOUNDGG(pt) && ISBOUNDGG(ptg);  )
	  if ( pt->gen < ptg->gen ) {
	      ptn->gen = pt->gen;
	      ptn->exp = (int)P->prime-pt->exp;
	      if( ptn->exp != 0 ) ptn ++;
	      pt ++;
	  }
	  else if ( pt->gen > ptg->gen ) {
	      ptn->gen = ptg->gen;
	      ptn->exp = ptg->exp;
	      ptn++; ptg++;
	  }
          else {
	      ptn->gen = pt->gen;
	      ptn->exp = ptg->exp - pt->exp;
	      if ( ptn->exp < 0 ) ptn->exp += P->prime;
	      if ( ptn->exp != 0 ) ptn ++;
	      ptg++; pt++;
	  }

      while ( ISBOUNDGG(pt) ) {
	      ptn->gen = pt->gen;
	      ptn->exp = (int)P->prime-pt->exp;
	      if( ptn->exp != 0 ) ptn ++;
	      pt ++;
      }

      while ( ISBOUNDGG(ptg) ) {
	      ptn->gen = ptg->gen;
	      ptn->exp = ptg->exp;
	      ptn++; ptg++;
      }

      l = 0;
      for ( ptn = ng; ISBOUNDGG(ptn) && ptn->exp != 0; ptn++)
	  l++;
      ng = ReAllocate(ng,(l+1)*sizeof(GroupGenerator));
      (ng+l)->gen = 0;
      FreeGroupWord( gw );
      P->relations[j][k].group = ng;

      FreeGroupWord(t);
}

Substitute( s, t, onr )
int s;
GroupWord t;
int onr;

{
    register a, j, l, k;
    ExtensionElement *e, *e1;
    GroupWord gw, ptg, pt;

    /* for group generators a we multiply s^a * t^a.
    ** we immidiately change the relations 
    */
    for ( a = 1; a <= onr; a++ ) {
        e = NewExtensionElement();
	e->group = CopyGroupWord( P->relations[t->gen][a].group );
	e->vector = CopyVector( P->relations[t->gen][a].vector );
        for ( pt = t+1; ISBOUNDGG(pt); pt++ ) {
	    e1 = MultiplyEELocal( e, &P->relations[pt->gen][a] );
	    FreeExtensionElement(e);
	    e = e1;
	}
	e1 = MultiplyEELocal( &P->relations[s][a], e );
	FreeExtensionElement(e);
	P->relations[s][a].group = e1->group;
	P->relations[s][a].vector = e1->vector;
	Free( e1 );
    }

    /* for module generators i the task is a bit easier, since they
    ** act trivially on t, hence we just have to do nothing
    */
    /* Now all sorts of relations involve s instead of s*t
    ** and we have to change that
    */
    for ( j = 1; j <= P->Nr_Generators; j++ ) 
	for ( k = 1; k <= j; k++ ){
	    gw=P->relations[j][k].group;
	    for ( ; gw && ISBOUNDGG(gw); gw++ ) 
   		if ( gw->gen == s && (j != s || k <= onr) )
		    AlterRelation( j, k, s, t, onr ); 
	}
    

}

/* There was no relation defining 's', thus we have to define a new
** module generator
*/
ChangeRel( s, onr )
int s, onr;
{
	register int k, j, found, l;
	GroupWord      gw, pgw, t, pt;


	for ( j = 1; j <= P->Nr_Generators; j++ ) 
	    for ( k = 1; k <= j; k++ ){
		if ( !IsDefinition(P->Nr_Generators,j,k) ) {
		    gw=P->relations[j][k].group;
		    for ( found = 0; !found && gw && ISBOUNDGG(gw); gw++ ) 
			if ( gw->gen==s && gw->exp==1 && s!=k && s!=j) {
			     P->definedby[s][0] = k;
			     P->definedby[s][1] = j;
			     found = 1;
			 }
		    if (found) {
		        for ( l = 0, pgw = gw; pgw && ISBOUNDGG(pgw); pgw++)
			    l++;
			pt = t = NewGroupWord(l);
		        for ( pgw = gw; pgw && ISBOUNDGG(pgw); pgw++, pt++){
			    pt->gen = pgw->gen;
			    pt->exp = pgw->exp;
			}
			Substitute( s, t, onr );
			return;
		    }
		}
	    }
			
	fprintf( stderr, "#W ChangeRel: Couldn't find defining relation\n" );
	fprintf( stderr, "#W The next factor to be computed may be wrong\n" );
}

/* UpdatePresentation updates the power conjugate presentation according
** to the results of the module enumerator and stores the time the
** module enumerator uses in the time pointed to by the argument time
*/
int  UpdatePresentation(time) 
long *time;
{

    int newdim, olddim,  **images, i, j, k, l, *tv, *pt, nr, *def;
    /* int  **definedby, g, **im, **mat, isdef, onr, chpr; */
    int  **definedby, g, **im, **mat, isdef, onr, chpr, md;
    uint *defepi;
    Vector v;
    GroupWord gw, hw, ptg;
    FILE * fpt;
    char c;
    long hlpt;
    

    if (chat>= 2)
	fprintf( FN, "#I  Updating the presentation\n");
    if ( (fpt = fopen("meout.pa","r")) == NULL ) {
	perror("for meout.pa");
	exit(1);
    }
    
    fscanf( fpt, "%d", &newdim );
    P->Nr_firstmgen = P->Nr_GroupGenerators+1;
    while ( (c = getc(fpt)) != '\n' ) ;

    /* Case 1 : The module is trivial */
    if ( newdim == 0 ) { 
        /* delete the tail entries in Epimorphism */
        for ( i = 1; i <= P->Nr_Orig; i++ ) {
            FreeVector( P->Epimorphism[i].vector );
	    P->Epimorphism[i].vector = VectorOne();
	    if( ISONEGG(P->Epimorphism[i].group) )
		P->defepi[IsDefEpi(i)] = 0;
	}
        /* Update the relations and insert the new realtions. */
	for ( i = 1; i <= P->Nr_GroupGenerators; i++ ) 
	    for ( j = 1; j <= i; j ++ ) {
	        FreeVector( P->relations[i][j].vector );
	        P->relations[i][j].vector = VectorOne();
	    }
	
	/* We just free the entries in definedby. The length of definedby,
        ** & exponents will be reduced in the next ReAlloc().
        */
	for ( i = P->Nr_GroupGenerators + 1; i <= P->Nr_Generators; i++ ) 
	    Free( P->definedby[i] );

	P->Nr_Generators = P->Nr_GroupGenerators;
    
	/* the time used by ve is stored as the last entry in fpt */
        hlpt = -1;
	while ( fscanf( fpt, "%d", time) != EOF )
            hlpt = *time;
     
        if ( hlpt == -1 )
	    fprintf(FN, "#I Warning : Couldn't get VE time\n");
        *time = hlpt;
        fclose(fpt);
	Commute();

	return 1;
    }


    chpr = ( P->exponents[P->Nr_GroupGenerators] == P->prime ? 0 : 1 );
    /* Case 2: The module is not trivial */
    olddim = P->Nr_Generators - P->Nr_GroupGenerators;
    images = (int **) Allocate( olddim * sizeof(int *) );
    for ( i = 0; i < olddim; i++ ) {
	images[i] = (int *) Allocate( newdim * sizeof(int) );
	for ( pt = images[i], j = 0; j < newdim; j++, pt++ )
	    fscanf( fpt, "%d", pt );
    }

    /* Update the relations and insert the new realtions. */
    nr = P->Nr_GroupGenerators + newdim;
    P->relations =               ReAllocate(P->relations, 
                                            (nr+1)*sizeof(ExtensionElement*));
    P->exponents      = (int*)   ReAllocate(P->exponents,
                                            (nr+1)*sizeof(int) );

    for ( i = 1;i <= P->Nr_GroupGenerators; i++ )
	P->relations[i] = 
        ReAllocate( P->relations[i], (i+2)*sizeof(ExtensionElement) );

    for ( i = P->Nr_GroupGenerators+1; i <= nr; i++ ) {
        P->relations[i]      = (ExtensionElement *) 
                               Allocate((i+2)*sizeof(ExtensionElement) );
        P->exponents[i]      = P->prime;
    }

    tv  = Allocate( (newdim+1) * sizeof(int) );

    /* Update the relations */
    for ( i = 1; i <= P->Nr_GroupGenerators; i++ ) 
        for ( k = 1; k <= i; k++ ) {
            for ( j = 0; j < newdim; j++ ) tv[j] = 0;
 	    for ( v=P->relations[i][k].vector;
		 v!=NULL&&ISBOUNDMG(v)&&!ISONEMG(v);v++ ) 
	        for ( j=0; j<newdim && v->exp!=NULL && v->exp->mult; j++ )
	            tv[j] = (tv[j]+v->exp->mult * 
                    images[v->gen-P->Nr_GroupGenerators-1][j]) % P->prime ;
	    FreeVector( P->relations[i][k].vector );
	    P->relations[i][k].vector = VectorOne();
	    for ( j = 0, l = 0; j < newdim; j++ )
	        if ( tv[j] ) l++;
	    if ( P->relations[i][k].group == NULL || 
                 ISONEGG( P->relations[i][k].group ) ) {
	        FreeGroupWord( P->relations[i][k].group );
	        P->relations[i][k].group = NewGroupWord(l);
		ptg = P->relations[i][k].group;
	    }
	    else {
	        j = LengthGroupWord( P->relations[i][k].group );
	        P->relations[i][k].group = 
                                ReAllocate( P->relations[i][k].group, 
                                (j+l+1)*sizeof(GroupGenerator));
		(P->relations[i][k].group+j+l)->gen = 0;
		(P->relations[i][k].group+j+l)->exp = 0;
                ptg = P->relations[i][k].group + j;
	    }
	    for ( j = 0; j < newdim; j++ ) 
	        if ( tv[j] ) {
	            ptg->gen = P->Nr_GroupGenerators+j+1;
	            ptg->exp = tv[j];
		    ptg++;
                 }
        }

    /* Update the epimorphism */
    /*for ( i = P->Nr_GroupGenerators+1; i <= P->Nr_Orig; i++ ) { */
    for ( i = 1; i <= P->Nr_Orig; i++ ) {

	    /* set tv to the image of the vector in the new basis */
            for ( j = 0; j < newdim; j++ ) tv[j] = 0;
 	    for (v=P->Epimorphism[i].vector;
		 v!=NULL&&ISBOUNDMG(v)&&!ISONEMG(v); v++ ) 
	        for ( j = 0; j < newdim; j++ )
	            tv[j] = (tv[j]+images[v->gen-P->Nr_GroupGenerators-1][j]) 
                            % P->prime ;
	    for ( j = 0, l = 0; j < newdim; j++ )
	        if ( tv[j] ) l++;

	    FreeVector( P->Epimorphism[i].vector );
	    P->Epimorphism[i].vector = VectorOne();

	    /* enlarge the group component to allow for the image */
	    if ( !ISONEGG( P->Epimorphism[i].group ) ) {
	        P->Epimorphism[i].group = gw 
                           = ReAllocate( P->Epimorphism[i].group,  
                           (LengthGroupWord(P->Epimorphism[i].group)+l+1)
                           *sizeof(GroupGenerator) );
	        ptg = gw+LengthGroupWord(P->Epimorphism[i].group);
                (ptg+l)->gen = 0; /* 5 July */
                (ptg+l)->exp = 0;
	    }
	    else {
		FreeGroupWord( P->Epimorphism[i].group );
		if (l) ptg = gw = P->Epimorphism[i].group = NewGroupWord(l+1);
		else   ptg = gw = P->Epimorphism[i].group = GroupWordOne();
	    }

	    /* l == 0 : the image of the tail part is 0
	    ** IsDefEpi(i) > P->Nr_GroupGenerators :
	    ** phi(i) =: IsDefEpi(i) =: a and a is a tail word
	    ** since it is bigger that P->Nr_GroupGenerators.
	    */ 
            if ( IsDefEpi(i) > P->Nr_GroupGenerators && l == 0 ) 
		P->defepi[IsDefEpi(i)] = 0; /*2 July */

	    for ( j = 0; j < newdim; j++ ) 
	        if ( tv[j] ) {
		    /* if phi(i) was a definition and the image is
		    ** a single tail generator mark it as definition.
		    */
		    if ( l == 1 && IsDefEpi(i) ) 
			P->defepi[P->Nr_GroupGenerators+j+1] = i; 
	            ptg->gen = P->Nr_GroupGenerators+j+1;
	            ptg->exp = tv[j];
		    ptg++;
                 }
        } 

    for ( i = 0; i < olddim; i++ )
        Free( images[i] );
    Free( images);
    Free( tv );

    md = (P->Nr_GroupGenerators<P->Nr_Orig?P->Nr_Orig:P->Nr_GroupGenerators);
    if ( md < nr ) md = nr;
    definedby = (int **) Allocate( (md+1) *sizeof(int*) );
    for ( i = 1; i <= P->Nr_GroupGenerators; i++ )
        definedby[i] = P->definedby[i];
    for ( i = P->Nr_GroupGenerators+1; i<= md; i++ )
        definedby[i] = 0;
 
    defepi = (uint *) Allocate( (md+1)*sizeof(int) );
    for ( i = 1; i <= P->Nr_GroupGenerators; i++ )
        defepi[i] = P->defepi[i];
    for ( i = P->Nr_GroupGenerators+1; i<= md; i++ )
        defepi[i] = (uint) 0;

    /* Now we insert the information that the module enumerator computed */

    def = (int  *) Allocate( (newdim+1) * sizeof(int) );
    im  = (int **) Allocate( (newdim+1) * sizeof(int *) );
    for (i = 1; i <= newdim; i++ ) {
        fscanf( fpt, "%d", def+i );
        im[i] = GetGroupWord( fpt );
    }


    /* Read the new action */
    mat = (int **) Allocate ( newdim * sizeof(int *) );
    for ( i = 0; i < newdim; i++ )
        mat[i] = Allocate( newdim * sizeof (int) );

    for ( i = 0; i < P->Nr_GroupGenerators; i++ ) {
	ReadMat( mat, newdim, fpt );
	for ( j = 0; j < newdim; j++ ) {
	    for ( k = 0, l = 0; k < newdim; k++ )
	        if ( mat[j][k] ) l++;
	    ptg = gw = NewGroupWord( l );
            for ( k = 0; k < newdim; k++ )
	        if ( mat[j][k] ) {
		    ptg->gen = P->Nr_GroupGenerators+k+1;
		    ptg->exp = mat[j][k];
		    ptg++;
		}
	    P->relations[P->Nr_GroupGenerators+j+1][i+1].group = gw;
	    P->relations[P->Nr_GroupGenerators+j+1][i+1].vector = VectorOne();
	}
    } 
    for ( j = 0; j < newdim; j++ )
	Free( mat[j] );
    Free( mat );

    for ( i = P->Nr_GroupGenerators+1; i <= P->Nr_GroupGenerators+newdim; i++ )
        for ( j = P->Nr_GroupGenerators + 1; j < i; j++ ) {
	    P->relations[i][j].group = NewGroupWord(1);
            P->relations[i][j].group->gen = i;
            P->relations[i][j].group->exp = 1;
        }

    /* update the debinedby entries */
    for ( i = 1; i <= newdim; i++ ) {
	if ( im[i][0] == 0 )  {
	    definedby[P->Nr_GroupGenerators+i] = 
            P->definedby[P->Nr_GroupGenerators+def[i]];
            defepi[P->Nr_GroupGenerators+i] =
	    P->defepi[P->Nr_GroupGenerators+def[i]];
	}
	else 
	    /* we need to substitue g by the no of the new basis ele */
	    /* assumptiion on me output */
	    definedby[P->Nr_GroupGenerators+i] = Allocate ( 2*sizeof(int) );
     }   

    /* Look for the new generators which are not just defined 
    ** as the images of other ones. Find a relation
    ** which contains them it in its rhs and mark it as
    ** the defintion.
    */
    Free( P->definedby );
    P->definedby = definedby;
    Free( P->defepi );
    P->defepi = defepi;

    onr = P->Nr_GroupGenerators;
    P->Nr_GroupGenerators = nr;
    P->Nr_Generators = nr;
    Commute();

    for ( i = onr+1; i <= nr; i++ )
        if ( !P->defepi[i] && P->definedby[i][0]==0 && P->definedby[i][1]==0 )
            if( FindRel( i, onr ) == 0 ) {
	        ChangeRel( i, onr );
	    }
        

    Free(def);
    for ( i = 0; i < newdim+1; i++ )
        Free(im[i]);
    Free(im);


    /* Update the Lseries entries */
    if ( chpr ) {
        P->Lseries = ReAllocate( P->Lseries, (P->Lfactor + 2)*sizeof(int*));
	P->Lfactor ++;
	P->Lseries[ P->Lfactor ] = (uint *) Allocate( 2*sizeof(int) );
        PLENGTH(P->Lfactor) = 1;
	P->Lseries[P->Lfactor][PLENGTH(P->Lfactor)] = newdim;
    }
    else {
        P->Lseries[P->Lfactor] = ReAllocate( P->Lseries[P->Lfactor],
        ( PLENGTH(P->Lfactor)+2 )*sizeof(int) );
        PLENGTH(P->Lfactor)++;
	P->Lseries[P->Lfactor][PLENGTH(P->Lfactor)] = newdim;
    }

    hlpt = -1;
    while ( fscanf( fpt, "%d", time) != EOF )
        hlpt = *time;
     
    if ( hlpt == -1 )
        fprintf(FN, "#I Warning : Couldn't get VE time\n");
    *time = hlpt;
    fclose(fpt);
    return 0;
}
