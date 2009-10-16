/****************************************************************************
**
**    modifypres.c             ANU SQ                        Alice C Niemeyer
**
**    Copyright 1994                             Mathematics Research Section
**                                            School of Mathematical Sciences 
**                                             Australian National University
**
**
**  Modify a  presentation by adding tails.
**
*/

#include "pres.h"
#include "sq.h"
#include "modmem.h"
#include "arith.h"
#include "pcparith.h"

extern int chat;

#ifndef TAILS
/*
** AddDefinitions adds tail generators to the right hand sides of the 
** Power-Conjugate Presentation and to the right hand sides of the
** epimorphism. It takes two flags as arguments. 
**
** tail :
**
** If this flag is set we are changing the prime.
**
**      true : tails are added to the rhs of all relations
**             and to the rhs of the epimorphism
**      false: tails are only added to the rhs of those relations
**             whose lhs involves at least one generator whose 
**             exponent is the current prime
**             and to the rhs of the epimorphism
**
** maxnilp:
**
** If this flag is set we have completed a maximal nilpotent sub-
** quotient and are now computing a new one.
**
**      true : tails are only added to the rhs of the epimorphism
**      false: has no influence
**/

AddDefinitions(tail,maxnilp)
int tail;
int maxnilp;
{
    register          i, j;
    int               nxt, mr, nr, nrepi;
    ExtensionElement  r;

    if (chat >= 2 ) 
	fprintf(FN,
	"#I  AddDefinitions: Adding new generators to right hand sides\n");

    nxt = P->Nr_GroupGenerators;

    /* Add Tails to the Epimorphism */
    for ( i = 1; i <= P->Nr_Orig; i++ )
        if ( !IsDefEpi(i) || maxnilp ) {
	    FreeVector( P->Epimorphism[i].vector );
	    P->Epimorphism[i].vector = NewVector(1);
	    P->Epimorphism[i].vector->gen = (tgen) ++nxt;
	    P->Epimorphism[i].vector->exp = RingWordOne();
        }
    nrepi = nxt+1;

    /* add the tail generators */
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
		/* The defepi-condition is to ensure that
		** generators defined by the epimorphism get tails.
		** This is necessary - look at Z_6
		** This MUST match code a few lines further down.
		*/
	        if ( ((P->exponents[i] == P->prime)  ||
                      (P->exponents[j] == P->prime)  || tail ||
		       P->defepi[i] || P->defepi[j] ) &&
		       !IsDefinition(P->Nr_GroupGenerators,i,j)&& 
                       !maxnilp ) {
                      /* need to add a tail generator */
		        FreeVector( P->relations[i][j].vector );
	                P->relations[i][j].vector = NewVector(1);
                        P->relations[i][j].vector->gen = (tgen) ++nxt;
                        P->relations[i][j].vector->exp = RingWordOne();
	         }
	    }

    P->Nr_Generators = nxt;

    /* make room for the tail generators */
    P->exponents      = ReAllocate(P->exponents,      (nxt+2)*sizeof(int) );
    P->definedby      = ReAllocate(P->definedby,      (nxt+2)*sizeof(int*) );
    P->defepi         = ReAllocate(P->defepi,         (nxt+2)*sizeof(int) );

    /* set the additionally allocated space to 0 */
    for ( i = P->Nr_GroupGenerators+1; i <= nxt+1; i++ )
	P->defepi[i] = 0;

    /*
    for ( i = nrepi+1; i <= P->Nr_Orig; i++ )
        P->defepi[i] = 0;
    */

    /* mark the tail vectors defined by the epimorphism as such */
    for ( i = 1; i < nrepi && i <= P->Nr_Orig; i++ )
	if ( P->Epimorphism[i].vector != NULL
	  && !ISONEMG(P->Epimorphism[i].vector) )
            P->defepi[P->Epimorphism[i].vector->gen] = i;


    /* update defineby */
    nr = nrepi;
    for ( i = 1; i <= P->Nr_GroupGenerators; i++ ) 
	    for ( j = 1; j <= i; j++ ) 
	        if ( ((P->exponents[i] == P->prime)  ||
                      (P->exponents[j] == P->prime)  || tail ||
		       P->defepi[i] || P->defepi[j] ) &&
		       !IsDefinition(P->Nr_GroupGenerators,i,j)&& 
                       !maxnilp ) {
                      /* need to add a tail generator */
		      P->definedby[nr] = (int *)Allocate( 2 * sizeof(int));
		      P->definedby[nr][0] = j;
		      P->definedby[nr][1] = i;
		      nr++;
		  }

    for ( i = 1; i <= nxt-P->Nr_GroupGenerators; i++ ) {
        P->exponents[i+P->Nr_GroupGenerators] = P->prime;
    }

    P->exponents[nxt+1] = 0;
}
#endif

#ifdef TAILS
int AddGenerators( cl, nxt )
int cl, nxt;

{
      register pnr, i, j, nr;

      /* count the number of p-generators */
      for ( pnr=0, i=P->Nr_GroupGenerators; 
            i && P->exponents[i] == P->prime; i--) 
            pnr ++;
      nr = P->Nr_GroupGenerators - pnr;
      for ( i = 1; i < cl; i++ )
	  nr += PDIM(i);
      for ( i = nr + 1 ; i <= nr + PDIM(cl); i++ )  {
          /* if i > P->Nr_GroupGenerators-pnr, then it is one of the
          ** generators of the p-group. In this case we only add tails
          ** to the commutators of weight (c,1)  ...
          */
          for ( j = 1; j <= P->Lseries[P->Lfactor][1] ; j++ ) 
	      if ( (i > P->Nr_GroupGenerators-pnr+j) ) {
                  nxt = AddRelation( i, P->Nr_GroupGenerators-pnr+j, nxt );
	      }
          /* .. and to the $p^{th}$-powers of generators defined as $p$-th  
          ** powers of $P$-generators
          */ 
	  if (P->definedby[i] == NULL || 
              (P->definedby[i] != NULL  &&
               (        (P->definedby[i][0] > P->Nr_GroupGenerators - pnr
                       && P->definedby[i][0] == P->definedby[i][1]) 
                ||      (P->definedby[i][0] <= P->Nr_GroupGenerators-pnr
                         || P->definedby[i][1] <= 0 )
                ))) {
                  nxt = AddRelation( i, i, nxt );
		}
     }

	    
      P->Nr_Generators = nxt;

      return nxt;
}

/****************************************************************************
**
**  Tails( <nxt> ) . . . . . . . .  computes a covering presentation for <P>
**
**  'Tails' computes a not  necessarily consistent, covering  presentation
**  for P.  For  each class cl computed so far 'AddGenerators' is called
**  to   add   the   new/pseudo    generators.
**
**  'AddGenerators' modifies the relations of the form
**  1) $[ b, a ] = w$ with $wt(b) = cl$ and $wt(a) = 1$
**  2) $c^p      = v$  with $wt(c) = cl$ and $c$ is  either defined as $p$-th
**                                          power or $wt(c) = 1 (=cl)$.
**
**  A theoretical argument shows that for all other relations the word in the 
**  new/pseudo generators with  which  to modify  each  relation (called  the
**   `tail' of the relation) can be computed.  This  is done  in this function
**  and the relations are modified accordingly (see Celler, Newman, Nickel, 
**  Niemeyer ).
*/

int Tails( nxt )
int nxt;
{

    int    i, ir, j, k, clnrgen, cl, endcl, srtdim,  nrg, pnr, ex;
    ExtensionElement * x, *y, *z, *xy, *yp, *g, *lhs, *rhs;
    Vector  w;

    /* count the number of p-generators */
    for ( pnr=0, i=P->Nr_Generators; i && P->exponents[i]==P->prime; i--) 
          pnr ++;

    nrg = P->Nr_GroupGenerators - pnr; /* number of other generators */
    clnrgen = pnr;   /* set to the last generator of the given class */

    for (  cl = PLENGTH(P->Lfactor); cl >= 1; cl -- ) {

        /* add new/pseudo generators */
        nxt = AddGenerators(cl, nxt);

        /* Compute the tails of the new/pseudo generators.  First the tails of
        ** the $p^{th}$-powers are computed
        */
       for (  i=nrg+clnrgen; i > nrg+clnrgen-PDIM(cl); i--)  {
            /* compute tails  for $p^{th}$-powers  $a_i^p$ for which $a_i$  is
            ** defined as a commutator [y,z]
	    */
	  if ( ! (P->definedby[i] == NULL || 
              (P->definedby != NULL  &&
               (        (P->definedby[i][0] > nrg 
                       && P->definedby[i][0] == P->definedby[i][1]) 
                ||  (P->definedby[i][0] <= nrg || P->definedby[i][1] <= nrg )
                )))) {
	         ir = P->definedby[i][1];
                /*    (y^p*z) / (y^(p-1) * (y*z)) */
	        y = NumberExtensionElement(ir);
                z = NumberExtensionElement(P->definedby[i][0]);
                yp = NewExtensionElement();
	        yp->group = P->relations[ir][ir].group;
		yp->vector = VectorOne();
		lhs = MultiplyEELocal( yp, z);
		xy = MultiplyEELocal( y,z );
		for ( j = 1; j < P->prime; j++ ) {
		    x = MultiplyEELocal( y, xy );
		    FreeExtensionElement( xy );
		    xy = x;
		}
                w = AddVector( lhs->vector, xy->vector, -1 );
		FreeExtensionElement( y ); FreeExtensionElement( z );
		FreeExtensionElement(lhs); FreeExtensionElement(xy);
		FreeVector( yp->vector );  Free(yp);
                if ( !ISONEMG(w) ){
		    if ( P->relations[i][i].group == NULL )
		        P->relations[i][i].group = GroupWordOne();
		    P->relations[i][i].vector = w;
		 }
		 else FreeVector(w);
	      }
	  }
        clnrgen -= PDIM(cl);

        /* Next compute the tails of the commutators */
        for (  endcl = pnr, k =  cl; k <=  PLENGTH(P->Lfactor); k++ )
            endcl -= PDIM(k);

        for ( k=1, srtdim=PDIM(1)+1; cl-k >= k+1; k++, srtdim+=PDIM(k)  ) {
            for ( i = nrg + srtdim; i < nrg + srtdim + PDIM(k+1); i++ ){
                if (  P->definedby[i] != NULL && 
                     (P->definedby[i][0] != P->definedby[i][1])  ) {
                    /* the second generator is defined as commutator */
                    y = NumberExtensionElement(P->definedby[i][1]);
                    z = NumberExtensionElement(P->definedby[i][0]);
                    g = MultiplyEELocal( y, z );
                    for ( j=nrg+endcl; j>i && j >nrg+endcl-PDIM(cl-k); j--  ){
                        /*  ((x*y)*z) / (x*(y*z)) */
                        fprintf( FN, "[%d, %d ]\n", j, i );
		        x = NumberExtensionElement(j);
                        xy = MultiplyEELocal( x, y );
			lhs = MultiplyEELocal( xy,z);
			FreeExtensionElement(xy);
			xy = MultiplyEELocal( x, g );
			FreeExtensionElement(x);
			rhs = InverseEE( xy );
			xy = MultiplyEE( lhs, rhs );
                        if ( !ISONEEE(xy) ) {
		            if ( P->relations[j][i].group == NULL )
		                P->relations[j][i].group = GroupWordOne();
		            P->relations[j][i].vector = xy->vector;
		            FreeGroupWord( xy->group );
		            Free(xy);
		        }
		        else FreeExtensionElement( xy );
		    }
		    FreeExtensionElement(y);
		    FreeExtensionElement(z);
		    FreeExtensionElement(g);
		}
                else if (P->definedby[i] != NULL) { /* 14 July */ 

                    /* The second generator is defined as $p$-th power
                    ** and is not one of the first generators (which are
                    ** defined by the epimorphism).
                    */
                    y = NumberExtensionElement(P->definedby[i][0]);
		    yp = NewExtensionElement();
		    yp->group =
                    P->relations[P->definedby[i][0]][P->definedby[i][0]].group;
		    yp->vector = VectorOne();
		    ex = P->prime - 1;
                    z = PowerExtensionElementLocal(y,&ex);
                    for ( j = nrg+endcl; j>i && j>nrg+endcl-PDIM(cl-k); j-- ) {
                        /*  ((x*y) * y^(p-1)) / (x*y^p) */
                        x = NumberExtensionElement(j);
			xy = MultiplyEELocal( x, y );
			lhs = MultiplyEELocal( xy, z );
			rhs = MultiplyEELocal( x, yp );
			FreeExtensionElement(x);
			FreeExtensionElement(xy);
			xy = InverseEE( rhs );
			x = MultiplyEE( lhs, xy );
                        if ( !ISONEEE(xy) ) {
		            if ( P->relations[j][i].group == NULL )
		                P->relations[j][i].group = GroupWordOne();
		            P->relations[j][i].vector = x->vector;
		            FreeGroupWord( x->group );
		            Free(x);
		        } 
		        else FreeExtensionElement( x );
                    }
		    FreeExtensionElement(y);
		    FreeVector(yp->vector); Free(yp);
		    FreeExtensionElement(z);
		  }
                  else 
                     /* i was defined by the epimorphism. Add */
		     /* generators down its column. 14 July */
                     for ( j=nrg+endcl; j>i && j>nrg+endcl-PDIM(cl-k); j-- )
                         nxt = AddRelation( j, i, nxt );

	    }
            endcl  -= PDIM(cl-k);
	  }
      }

      return nxt;

}

AddRelation ( i, j, nxt, tail )
int i, j, nxt, tail;

{
	if ( !ISBOUNDEE(P->relations[i][j])  ){ 
                /* If the relation is not bound, then make it  a trivial 
                ** relation. I.e. if it is a power relation make the rhs 
                ** trivial and if it is a conjugate realtion let the rhs
                ** consist of base generator. 
		*/
	        P->relations[i][j].group = GroupWordOne();
                if ( i > j ) {
	            P->relations[i][j].group->gen = i;
	            P->relations[i][j].group->exp = 1;
		}
		P->relations[i][j].vector = VectorOne();
	}
	if ( ((P->exponents[i] == P->prime)  ||
              (P->exponents[j] == P->prime)  || tail ) &&
	      !IsDefinition(P->Nr_GroupGenerators,i,j) ) {
              /* need to add a tail generator */
              P->definedby = ReAllocate(P->definedby, (nxt+2)*sizeof(int*) );
	      FreeVector( P->relations[i][j].vector );
	      P->relations[i][j].vector = NewVector(1);
              P->relations[i][j].vector->gen = (tgen) ++nxt;
              P->relations[i][j].vector->exp = RingWordOne();
              P->definedby[nxt] = (int *)Allocate( 2 * sizeof(int));
	      P->definedby[nxt][0] = j;
	      P->definedby[nxt][1] = i;
	}

	return nxt;
 
}


/*
** AddDefinitions adds tail generators to the right hand sides of the 
** Power-Conjugate Presentation and to the right hand sides of the
** epimorphism. It takes two flags as arguments. 
**
** tail :
**
** If this flag is set we are changing the prime.
**
**      true : tails are added to the rhs of all relations
**             and to the rhs of the epimorphism
**      false: tails are only added to the rhs of those relations
**             whose lhs involves at least one generator whose 
**             exponent is the current prime
**             and to the rhs of the epimorphism
**
** maxnilp:
**
** If this flag is set we have completed a maximal nilpotent sub-
** quotient and are now computing a new one.
**
**      true : tails are only added to the rhs of the epimorphism
**      false: has no influence
**/

AddDefinitions(tail,maxnilp)
int tail;
int maxnilp;
{
    register          i, j, pnr;
    int               nxt, mr, nr, nrepi;
    ExtensionElement  r;


    if (chat >= 2 ) 
	fprintf(FN,
	"#I  AddDefinitions: Adding new generators to right hand sides\n");

    nxt = P->Nr_GroupGenerators;

    /* Add Tails to the Epimorphism */
    for ( i = 1; i <= P->Nr_Orig; i++ )
        if ( !IsDefEpi(i) || maxnilp ) {
	    FreeVector( P->Epimorphism[i].vector );
	    P->Epimorphism[i].vector = NewVector(1);
	    P->Epimorphism[i].vector->gen = (tgen) ++nxt;
	    P->Epimorphism[i].vector->exp = RingWordOne();
            P->definedby = ReAllocate(P->definedby,(nxt+2)*sizeof(int*) );
            P->definedby[nxt] = NULL; /* 14 July */
        }
    nrepi = nxt+1;

    /* add the tail generators */
    /* there are 2 cases : the case in which the last factor
    ** of the L-series was a q-group and we extend it by a p-group
    ** and the case that the last factor was already a pgroup.
    */

    /* case of q-group  extended by p-group */
    if ( P->exponents[P->Nr_GroupGenerators] != P->prime ) { 
        for ( i = 1; i <= P->Nr_GroupGenerators && !maxnilp; i++ ) 
	    for ( j = 1; j <= i; j++ )
                nxt = AddRelation( i, j, nxt, tail );
      } 

      /* we now deal with extending a p-group by a p-group */
    else {
          /* count the number of p-generators */
          for (pnr=0, i=P->Nr_Generators; i && P->exponents[i]==P->prime; i--) 
              pnr ++;

	nxt = Tails( nxt );
        for ( i=1; i<=P->Nr_GroupGenerators && !maxnilp; i++ ) 
	    for ( j = 1; j <= P->Nr_GroupGenerators - pnr && j <= i; j++ ) 
                nxt = AddRelation( i, j, nxt, tail );


    }


    /* make room for the tail generators */
    P->exponents      = ReAllocate(P->exponents,      (nxt+2)*sizeof(int) );
    P->defepi         = ReAllocate(P->defepi,         (nxt+2)*sizeof(int) );

    /* set the additionally allocated space to 0 */
    for ( i = P->Nr_GroupGenerators+1; i <= nxt+1; i++ )
	P->defepi[i] = 0;

    /*
    for ( i = nrepi+1; i <= P->Nr_Orig; i++ )
        P->defepi[i] = 0;
    */

    /* mark the tail vectors defined by the epimorphism as such */
    for ( i = 1; i < nrepi && i <= P->Nr_Orig; i++ )
	if ( P->Epimorphism[i].vector != NULL
	  && !ISONEMG(P->Epimorphism[i].vector) )
            P->defepi[P->Epimorphism[i].vector->gen] = i;

    for ( i = 1; i <= nxt-P->Nr_GroupGenerators; i++ ) {
        P->exponents[i+P->Nr_GroupGenerators] = P->prime;
    }

    P->exponents[nxt+1] = 0;
    /* It should be here since in AddGenerators() the old value is needed */
    P->Nr_Generators = nxt;  
}

#endif
