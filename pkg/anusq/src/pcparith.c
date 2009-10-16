/****************************************************************************
**
**    pcarith.c                ANU SQ                        Alice C Niemeyer
**
**    Copyright 1994                             Mathematics Research Section
**                                            School of Mathematical Sciences 
**                                             Australian National University
**
**  This module contains the arithmetic functions for computing with
**  Extension Elements.
**
*/
#include "pres.h"
#include "sq.h"
#include "modmem.h"
#include "arith.h"

ExtensionElement *MappedEE( g )
gen g;

{ 
#ifdef SAFE
    if ( g > P->Nr_Orig )
        fprintf( stderr, "#W MappedEE( %d ) called\n", (int) g );
#endif

return CopyExtensionElement( &(P->Epimorphism[(int)g]) );
}


#define STACKHEIGHT (1<<16)
#define ISTRIVIAL(gw) ( (!gw || ((gw) && !*gw)) ? 1 : 0 )

extern Presentation *P;
/* extern int malloc_verify(); */
MalErr()
{

	fprintf( stderr, "A malloc error has occurred\n");

}

GroupWord CollectGroupWord();

/*
** Return the subword of w which acts non-trivally on the module.
** Assumes that w is in normal form.
**
**  FreeInformation :   w      : not freed
**                      result : newly allocated
*/
GroupWord NonTrivial(w)
GroupWord w;

{   GroupWord  v, r;
    uint       ll;

    if ( w == NULL || w == IdGrp ) return w;
    if ( ISONEGG(w) ) return IdGrp;

    r = w;
    for ( ll = 0; ISBOUNDGG(w); w++ )
	if ( w->gen < P->trivial )
            ll++;
    
    w = r;
    r = v = NewGroupWord( ll );

    for ( ; ISBOUNDGG(w); w++ ) {
	if ( w->gen < P->trivial ) {
	    v->gen = w->gen;
	    v->exp = w->exp;
	    v++;
	}
    }
   
   return r;
}

int IsEqGroupWord( gw1, gw2 )
GroupWord gw1, gw2;

{

    int i, l;


    l = LengthGroupWord( gw1 );

    if ( gw1 == NULL ) {
	if ( gw2 == NULL ) return 1;
	else return 0;
    }
    if ( gw2 == NULL ) return 0;

    if ( l != LengthGroupWord( gw2 ) )
        return 0;

    for (  ; ISBOUNDGG(gw1); gw1++, gw2++ ) 
        if ( gw1->gen != gw2->gen || gw1->exp != gw2->exp )
	    return 0;

    return 1;

}

void ConCatinateGroupWord( rw, gw )
RingWord  rw; 
GroupWord gw;

{
     GroupWord v;
     uint l1, l2;

     if ( !ISBOUNDGG(gw) || ISONEGG(gw) ) return;
     if ( !ISBOUNDRE(rw) || ISONEGG(rw->ring) ) {
	 FreeGroupWord( rw->ring);
	 rw->ring = CopyGroupWord(gw);
	 return;
     }
	 
     l1 = LengthGroupWord(rw->ring);
     l2 = LengthGroupWord(gw);

     rw->ring = (GroupWord) ReAllocate( rw->ring,
		(l1+l2+1)*sizeof(struct _GroupGenerator));
     rw->ring[l1+l2].gen = 0;
     rw->ring[l1+l2].exp = 0;

     for ( v = rw->ring+l1; ISBOUNDGG(gw); v++, gw++ ) {
	 v->gen = gw->gen;
	 v->exp = gw->exp;
     }


}

/* The collection routines regard all pointers to data structures
   as only used by them and free them when not needed in this
   context. Therefore make sure to have copied the data structures
   before handing them to the collection routines, if they are
   needed in any other context. 
*/

RingWord AppendRingWord( rw, gw, m )
RingWord  rw;
GroupWord gw;
int       m;

{
    uint l;
    register uint i;
    GroupWord w;
    RingWord pt;

    if ( !ISBOUNDGG(gw) ) return rw;
    w = NonTrivial(gw);
    if ( w == NULL || !ISBOUNDGG(w) ) { FreeGroupWord(w); return rw; }

    if ( rw == NULL ) {
        rw = NewRingWord(1);
        l = 0;
    }
    else {
	for ( pt = rw; ISBOUNDRE(pt); pt++ ) 
	    /* if ( IsEqGroupWord( pt->ring, gw ) ) {  1.2.93 */
	    if ( IsEqGroupWord( pt->ring, w ) ) {
		pt->mult += m;
		pt->mult %= P->prime;
		FreeGroupWord(w);
		return rw;
	    }

        l = LengthRingWord(rw);
        rw = ReAllocate( rw, (l+2) * sizeof(struct RingElement) );
	rw[l+1].mult = 0;
	rw[l+1].ring = NULL;
    }
    rw[l].mult = m;
    rw[l].ring = w;

    return rw;
}


RingWord AddRingWord( w1, w2 )
RingWord w1, w2; 
{
    RingWord      h, res, pt;
    int           l, *x, i;

    if ( w1 == NULL  && w2 == NULL ) return w1;
    if ( w1 == NULL ) return CopyRingWord(w2);
    if ( w2 == NULL ) return CopyRingWord(w1);

    l = LengthRingWord(w2);
    res = NewRingWord ( LengthRingWord(w1)+l );
    x = (int *) Allocate ( l*sizeof(int) );

    /* Copy the entries of w1 into h */
    for ( h = res; ISBOUNDRE(w1); w1++ ) {
	h->mult = w1->mult;
	/* loop through w2 and see if there is the same group word.
	** if so add its multiplicity to that of w1.
	*/
	for ( i = 0, pt = w2; i < l; i++, pt++ )
           if ( x[i] == 0 && IsEqGroupWord( w1->ring, pt->ring ) ) {
		x[i] = 1;
		h->mult = (h->mult + pt->mult) % P->prime;
		if ( h->mult < 0 ) h->mult += P->prime;
	    }
	if ( h->mult ) {
	    h->ring = CopyGroupWord( w1->ring );
	    h++;
	}                       /* 29 Jan. 93 */
    }
   
    for ( i = 0, pt = w2; i < l; i++, pt++, h++ ) 
	if ( x[i] == 0 ) {
	    h->mult = pt->mult;
	    h->ring = CopyGroupWord( pt->ring );
        }

    Free( (void *) x );
    return res;

}


RingWord SubRingWord( w1, w2 )
RingWord w1, w2; 
{
    RingWord      h, res, pt;
    int           l, *x, i;

    if ( w1 == NULL  && w2 == NULL ) return w1;
    if ( w1 == NULL ) {
	w2 = CopyRingWord(w2);
	for ( w1 = w2; ISBOUNDRE( w1 ); w1++ )
	    if ( w1->mult )
	        w1->mult = P->prime - w1->mult;
	return w2;
    }
    if ( w2 == NULL ) return CopyRingWord(w1);

    l = LengthRingWord(w2);
    x = (int *) Allocate ( l*sizeof(int) );
    res = NewRingWord ( LengthRingWord(w1)+l );
    for ( h = res; ISBOUNDRE(w1); w1++ ) {
	h->mult = w1->mult;
	for ( i = 0, pt = w2; i < l; i++, pt++ )
           if ( x[i] == 0 && IsEqGroupWord( w1->ring, pt->ring ) ) {
		x[i] = 1;
		h->mult -= pt->mult;
		if ( h->mult < 0 ) h->mult += P->prime;
	    }
	if ( h->mult ) {
	     h->ring = CopyGroupWord( w1->ring );
             h++;
	}

    }
   
    for ( i = 0, pt = w2; i < l; i++, pt++ ) 
	if ( x[i] == 0 ) {
	    h->mult = -pt->mult;
	    if ( h->mult < 0 ) h->mult += P->prime;
	    h->ring = CopyGroupWord( pt->ring );
	    h++;
        }

    Free( (void *) x );
    return res;
}

/* The following function returs a vector, which represents the
** argument vector acted upon by the argument group word. 
** This function changes its first argument. Make sure(!) that this
** is alright!!!
**
**  FreeInformation :  v : result
**                     w : not freed
*/

Vector ActL( v, w )
Vector v;
GroupWord w;
   
{
    uint l;
    RingWord rw;
    GroupWord ww;

    ww = NonTrivial(w);
    if (v == NULL||!ISBOUNDMG(v)||ISONEMG(v)||ISONEGG(ww)||!ISBOUNDGG(ww) ) {
	FreeGroupWord(ww);
        return v;
    }


    l = LengthVector(v);

    for  ( ; ISBOUNDMG(v); v++ ) 
	if ( v->exp != (RingWord) NULL )
	    for ( rw = v->exp; ISBOUNDRE(rw); rw++ )
                ConCatinateGroupWord( rw, ww );


    FreeGroupWord(ww);
    return v-l;

}


/* AddL (v1, v2 ) adds v1 and v2  and stores result in v1. It assumes
   v1 is of right length and the generators are stored in the 
   correct positions. 
*/
Vector AddL( v1, v2 )
Vector v1, v2;

{
    Vector   h1;
    RingWord h2;

    if ( v2 == NULL || !ISBOUNDMG(v2) || ISONEMG(v2) ) return v1;

    if ( v1 == NULL )
       v1 = NormalNewVector (P->Nr_Generators - P->Nr_GroupGenerators);
      
    for( h1 = v1; ISBOUNDMG(h1) && ISBOUNDMG(v2 ); h1++ ) 
	if ( h1->gen == v2->gen ) { 
	    for ( h2 = v2->exp; h2 != NULL && ISBOUNDRE(h2); h2++ )
		h1->exp = AppendRingWord( h1->exp, h2->ring, h2->mult );
            ++v2; 
        }

    return v1;
}


/*
** Multiply the vector v in place by m.
*/

Vector MultiplyVector ( v, m )
Vector v;
int    m;

{
    register Vector   ptv;
    register RingWord ptr;

    if ( v == NULL || !ISBOUNDMG(v) ) return v;

    for ( ptv = v; ISBOUNDMG(ptv); ptv++ )
        for( ptr = ptv->exp; ptr != NULL && ISBOUNDRE(ptr); ptr++ ) {
	    ptr->mult = (ptr->mult * m );
	    if ( ptr->mult > (int) P->prime ) 
                      ptr->mult %= P->prime;
	    else if ( ptr->mult < 0 )   
	              ptr->mult += P->prime;
	}

    return v;

}

/* AddVector (v1, v2 ) adds v1 and m*v2 .
** Can be speeded up.
*/
Vector AddVector( v1, v2, m )
Vector v1, v2;
int    m;

{
    Vector   h1, h2, res, ptr;
    RingWord e2;
    

    if ( v2 == NULL || !ISBOUNDMG(v2) || ISONEMG(v2) ) 
        return CopyVector( v1 );
    if ( v1 == NULL || !ISBOUNDMG(v1) || ISONEMG(v1) ) {
        res = CopyVector( v2 );
	return MultiplyVector( res, m);
    }

    ptr = res = NewVector( LengthVector(v1)+LengthVector(v2) );
    v2 = CopyVector(v2);
    h2 = MultiplyVector( v2, m );
     
    for( h1 = v1; ISBOUNDMG(h1) && ISBOUNDMG(h2); ) 
        if ( h1->exp == NULL ) 
	    h1++;
        else if ( h2->exp == NULL )
	    h2++;
	else if ( h1->gen == h2->gen ) { 
	    ptr->gen = h1->gen;
	    ptr->exp = CopyRingWord( h1->exp );
	    for ( e2 = h2->exp; e2 != NULL && ISBOUNDRE(e2); e2++ )
		ptr->exp = AppendRingWord( ptr->exp, e2->ring, e2->mult );
            h1++; h2++; ptr++;
        }
	else if ( h1->gen < h2->gen ) { 
	    ptr->gen = h1->gen;
	    ptr->exp = CopyRingWord( h1->exp );
            h1++; ptr++;
        }
        else  {
	    ptr->gen = h2->gen;
	    ptr->exp = CopyRingWord( h2->exp );
            h2++; ptr++;
        }

        while( ISBOUNDMG(h1) ) 
            if ( h1->exp == NULL ) 
	        h1++;
	    else {
                ptr->gen = h1->gen;
	        ptr->exp = CopyRingWord( h1->exp );
                h1++; ptr++;
	    }

        while( ISBOUNDMG(h2) ) 
            if ( h2->exp == NULL ) 
	        h2++;
	    else {
	        ptr->gen = h2->gen;
	        ptr->exp = CopyRingWord( h2->exp );
                h2++; ptr++;
	    }

        res = ReAllocate(res,(LengthVector(res)+1)*sizeof(ModuleGenerator));

        return res;
}

/* 
**  Compute the group word corresponding to an exponent vector
**
**  FreeInformation :    evec   : not freed
**                       result : newly allocated
*/

GroupWord GroupWordExpVec( evec )
ExpVec    evec;
{

    register int       i, l;
    register GroupWord gw, ptg;

    ptg = gw = NewGroupWord( P->Nr_GroupGenerators );

    for ( i = 1; i <= P->Nr_GroupGenerators; i++ )
	if ( evec[i] != 0 ) {
	    ptg->gen = i;
	    ptg->exp = evec[i];
	    ptg++;
	}

/*    gw = ReAllocate( gw, (ptg - gw + 1) * sizeof( GroupGenerator ) ); */

    return gw;

}


int DoNotCommute( g, h )
int g, h;

{

    if ( (P->relations[g][h].group != NULL && 
          !ISONEGG( P->relations[g][h].group )) || 
         (P->relations[g][h].vector != NULL && 
          !ISONEMG( P->relations[g][h].vector )) )
      return 1;

    return 0;
}

/****************************************************************************
**
**    Commute() computes P->Commute.
**    P->Commute[i] is the smallest j >= i such that a_i,...,a_n
**    commute with a_(j+1),...,a_n.
*/
Commute() {

        tgen    g, h;

	if( P->Commute != NULL ) Free( P->Commute );

	P->Commute = (uint *)Allocate((P->Nr_GroupGenerators+1)*sizeof(uint));
	P->Commute[P->Nr_GroupGenerators] = P->Nr_GroupGenerators;
	for( g = P->Nr_GroupGenerators-1; g >= 1; g-- ) {
	    /*
	    **    After the following loop two cases can occur :
	    **    a) h > g+1. In this case h is the first generator among
	    **       a_n,...,a_(j+1) with which g does not commute.
	    **    b) h == g+1. Then P->Commute[g+1] == g+1 follows and g
	    **       commutes with all generators a_(g+2),..,a_n. So it
	    **       has to be checked whether a_g and a_(g+1) commute.
	    **       If that is the case, then P->Commute[g] = g. If not
	    **       then P->Commute[g] = g+1 = h.
	    */
	    for( h = P->Nr_GroupGenerators; h > P->Commute[g+1]; h-- )
		if( DoNotCommute( h, g ) )
		    break;

	    if( h == g+1 && !DoNotCommute(h,g) )
		    P->Commute[g] = g;
	    else    P->Commute[g] = h;
	}
	    
}


/*
**    Collection from the left needs 4 stacks during the collection.
**
**    The word stack containes conjugates of generators, that were created
**        by moving a generator through the exponent vector to its correct
**        place or it containes powers of generators.
**    The word exponent stack containes the exponent of the corresponding
**        word in the word stack.
**    The generator stack containes the current position in the corresponding
**        word in the word stack.
**    The generator exponent stack containes the exponent of the generator
**        determined by the corrsponding entry in the generator stack.
**
**    The maximum number of elements on each stack is determined by the macro
**    STACKHEIGHT.
**
**    FreeInfo : lhs    : contains resulting group exponent vector
**               rhs    : not freed
**               result : returned in newly allocated vector
*/


static  GroupWord  WordStack[STACKHEIGHT];
static  Vector     VectorStack[STACKHEIGHT];
static  char       DeleteVectors[STACKHEIGHT];
static	int        WordExpStack[STACKHEIGHT];
static	GroupWord  GenStack[STACKHEIGHT];
static	int        GenExpStack[STACKHEIGHT];
static  GroupWord  GrW = NULL;

Vector                  Collect( lhs, rhs )
register ExpVec	        lhs;
register GroupWord      rhs;

{	register GroupWord	*ws = WordStack;
	register Vector         *ms = VectorStack;
	register char           *md = DeleteVectors;
	register int    	*wes = WordExpStack;
	register GroupWord      *gs = GenStack;
	register int	        *ges = GenExpStack, i;
	register tgen	        g, h;
	register int	        e, sp = 0, top;
	         Vector         tv;
		 int            ntv;

	ws[ sp ]  = rhs;
	gs[ sp ]  = rhs;
	ms[ sp ]  = IdVec; 
	wes[ sp ] = 1;
	if( rhs != NULL ) ges[ sp ] = rhs->exp;

	if ( GrW == (GroupWord) NULL )
	    GrW = NewGroupWord(1);
	GrW->exp = 1;

        /* the tail vector in normal form */
/*        tv = NormalNewVector (P->Nr_Generators - P->Nr_GroupGenerators); */
        tv = 0;
	ntv = 0;

	while( sp >= 0 ) {
	    if( gs[sp] != NULL && ISBOUNDGG(gs[sp]) && !ISONEGG(gs[sp]) ) {
		g = gs[sp]->gen;
		e = (g == P->Commute[g]) ? gs[ sp ]->exp : 1;
		if( (ges[ sp ] -= e) == 0 ) {
		    /* The power of the generator g will have been moved
		       completely to its correct position after this
		       collection step. Therefore advance the generator
		       pointer. */
		    gs[ sp ]++; ges[ sp ] = gs[ sp ]->exp;
		}
		/* Now move the generator g to its correct position
		   in the exponent vector lhs. */
		   /* buegeln! */
		GrW->gen = g;
		for ( i = 0; i < e; i ++ ) tv = ActL( tv, GrW );
		++sp;
		if (sp && md[sp]) FreeVector( ms[sp] );
		ms[sp] = tv; md[sp] = 1; ntv = 1;
		gs[sp] = ws[sp] = NULL;
		ges[sp] = wes[sp] = 1;
		if ( ntv ) {
		    tv = 0;
		    ntv = 0;
		}

		for( h = P->Commute[g]; h > g; h-- ) {
		    if( lhs[h] != 0 ) {
			if( ++sp == STACKHEIGHT )
			    Error( "Out of stack space" );
			gs[ sp ]  = ws[ sp ] = P->relations[h][g].group;
			if ( sp && md[sp]) FreeVector( ms[sp] );
			ms[ sp ]  = P->relations[h][g].vector; md[ sp ]  = 0;
			wes[ sp ] = lhs[h]; lhs[h] = 0;
			ges[ sp ] = gs[ sp ]->exp;
		    }
		}
		lhs[ g ] += e;
	        while( lhs[g] >= P->exponents[g] ) {
		    if( ++sp == STACKHEIGHT )
		        Error( "Out of stack space" );
		    gs[ sp ] = ws[ sp ] = P->relations[g][g].group;
		    if ( sp && md[sp]) FreeVector( ms[sp] );
		    ms[ sp ] = P->relations[g][g].vector; md[ sp ]  = 0;
		    wes[ sp ] = 1;
		    if ( gs[sp] == NULL ) ges[ sp ] = 0;
		    else ges[ sp ] = gs[ sp ]->exp;
		    lhs[ g ] -= P->exponents[ g ];
		}
	    }
	    else {
		/* the top word on the stack has been examined completely,
		   first take care of its module component and then check 
                   if its exponent is zero. */
		tv = AddL( tv, ms[sp] );
		/*if (sp&&(gs[sp]==NULL||md[sp])) FreeVector(ms[sp]); 1.4.93*/
		if ( sp && md[sp] ) FreeVector( ms[sp] ); 
		if( md[sp] ) md[sp] = 0;
		if( --wes[ sp ] <= 0 ) { /* 8.1.93 <= since 0 occured */
		    /* All powers of this word have been treated, so
		       we have to move down in the stack. */
		       sp--;
		}
		else {
	           /* setze erzeuger auf den Anfang des Wortes */
		    gs[ sp ] = ws[ sp ]; 
		    /* setze exp auf den exp des neuen erzeugers */
		    ges[ sp ] = gs[ sp ]->exp;
		}
	    }
	}


	return tv;
}


/*
**  CollectEE( lgev, lv, rgw, rv )
**
**  computes a normal form for lgev lv * rgw rv, where
**  lgev is an exponent vector for a group word, lv is a Vector
**  rgw is a GroupWord and rv is a Vector.
**  The result is stored in lgev, containing the resulting 
**  exponent vector for the group word and in lv, containing 
**  the tail vector.
**
**  FreeInfo :      lgev : result
**                  lv   : result
**                  rgw  : not freed.
**                  rv   : not freed.
*/

void               *CollectEE( lgev, lv, rgw, rv )
ExpVec	           lgev;
Vector             lv;
GroupWord          rgw;
Vector             rv;

{
	ExtensionElement *e;
	Vector            t;

	t = Collect( lgev, rgw );
	if ( rgw != NULL ) 
	    lv = AddL( ActL(lv,rgw), t );
	else
	    lv = AddL( lv, t );
	FreeVector(t);
	lv = AddL( lv, rv );


}

ExtensionElement         *MapHomGW( gw, phi )
GroupWord gw;
ExtensionElement *phi;
{

	Vector            t, tv;
	int               l;
        register          i, j;
        ExtensionElement  *e;
        ExpVec            ev;

	l = LengthGroupWord(gw);

        ev = (ExpVec) Allocate((P->Nr_GroupGenerators+1)*sizeof(int) );
        tv = NormalNewVector (P->Nr_Generators - P->Nr_GroupGenerators );
        for ( i = 0; i < l; i++, gw++ ) {
            for ( j = 0; j < gw->exp; j++ ) {
	        t = Collect( ev, phi[gw->gen].group );
                tv = AddL( ActL(tv,phi[gw->gen].group), t );
                FreeVector(t);
                tv = AddL( tv, phi[gw->gen].vector );
	    }
	}

	e = NewExtensionElement();
        e->group = GroupWordExpVec(ev);
        e->vector = tv;
	return e;
}



/*
**    Solve the equation   u x = v   for x.
*/
ExtensionElement	*SolveEE( e1, e2 )
ExtensionElement        *e1, *e2;

{	GroupWord	x, y, u, v;
	tgen	        g;
	long	        lv, lx, l;
	texp	        ev;
	ExpVec	        uvec;
	Vector           tv, t;
	int              i;
	ExtensionElement *e;
	
	u = e1->group;
	v = e2->group;
	l = LengthGroupWord( v );
	y = NewGroupWord( 1 );
	uvec = (ExpVec) Allocate( (P->Nr_GroupGenerators+1)*sizeof(int) );
	x = (GroupWord)NewGroupWord( P->Nr_GroupGenerators );

	t = Collect( uvec, u );
        /* the tail vector in normal form */
        tv = NormalNewVector (P->Nr_Generators - P->Nr_GroupGenerators );
	tv = AddL( tv, t );
	tv = AddL( tv, e1->vector );
	FreeVector( t );

	for( lv = lx = 0, g = 1; g <= P->Nr_GroupGenerators; g++ ) {
	    if( v[lv].gen == g && lv < l )       ev =  v[ lv++ ].exp;
	    else                                 ev = 0;

	    if( ev != uvec[g] ) {
		y[0].gen = x[lx].gen  = g;
    
		if( ev > uvec[g] )                     /* ev - uvec[g] > 0 */
                    y[0].exp = x[lx++].exp = ev - uvec[g];
		else                                   /* ev - uvec[g] < 0 */ 
		    y[0].exp = x[lx++].exp = ev - uvec[g] + P->exponents[g];

		t  = Collect( uvec, y );
		tv = ActL( tv, y );
		tv = AddL( tv, t );
		FreeVector( t );
	    }
	}

	FreeGroupWord( y );
	Free( uvec );

	x[lx].gen = 0;
	x[lx++].exp = 0;

	tv = MultiplyVector( tv, -1 );
	tv = AddL( tv, e2->vector );
	x = (GroupWord)ReAllocate( x, lx*sizeof(GroupGenerator) );
	e = NewExtensionElement();
	e->group = x;
	e->vector = tv;

	return e;
}


/* This function collects a group word 
*/
GroupWord CollectGroupWord( gw )
GroupWord gw;

{
        ExpVec           ev;
        GroupWord        cgw;
	Vector           tv;
	
       if ( gw == NULL || !ISBOUNDGG(gw) || ISONEGG(gw ) )
            return CopyGroupWord(gw);
	ev = (ExpVec) Allocate( (P->Nr_GroupGenerators+1)*sizeof(int) );

	tv = Collect( ev, gw  );
	cgw = GroupWordExpVec(ev);
	Free(ev);
	FreeVector(tv);

	return cgw;

}

/*  This function multiplies two ExtensionElements and returns as a result
**  and ExtensionWord in normal form.
**
**  FreeInformation :  e1     : not freed
**                     e2     : not freed
**                     result : newly allocated
*/
ExtensionElement *MultiplyEELocal( e1, e2 )
ExtensionElement *e1, *e2;

{
        ExpVec           ev;
        ExtensionElement *e;
	Vector            tv, v;

	ev = (ExpVec) Allocate( (P->Nr_GroupGenerators+1)*sizeof(int) );
        /* the tail vector in normal form */
        tv = NormalNewVector (P->Nr_Generators - P->Nr_GroupGenerators );
	v  = VectorOne();

	CollectEE( ev, tv, e1->group, e1->vector );
	CollectEE( ev, tv, e2->group, e2->vector );

	FreeVector( v );
	e = NewExtensionElement();
	e->group  = GroupWordExpVec(ev);
	e->vector = tv;

	Free(ev);

	return e;
}


ExtensionElement *MultiplyEE( e1, e2 )
ExtensionElement *e1, *e2;
{

	ExtensionElement *e;
		
	e = MultiplyEELocal( e1, e2 );
	FreeExtensionElement( e1 );
	FreeExtensionElement( e2 );

	return e;
}

ExtensionElement *InverseEE( ee )
ExtensionElement *ee;
{
	ExtensionElement *id, *e;

	id = NewExtensionElement();
	id->group = IdGrp;
	id->vector = VectorOne();
	e = SolveEE( ee, id );
	FreeExtensionElement( id );

	return e;
	
}


ExtensionElement *PowerEELocal( e, n )
ExtensionElement *e;
int	         n;

{
	ExpVec	          ev;
	int	          copied_e;
	ExtensionElement  *ee;
	Vector            tv, v;


	ev = (ExpVec) Allocate( (P->Nr_GroupGenerators+1)*sizeof(int) );
        /* the tail vector in normal form */
        tv = NormalNewVector (P->Nr_Generators - P->Nr_GroupGenerators );
	v  = VectorOne();


	copied_e = 0;
	if( n < 0 ) { 
	    e = InverseEE( e ); 
	    copied_e = 1; 
	    n = -n;
	}

	while( n > 0 ) {
	    if( n % 2 )
		 CollectEE( ev, tv, e->group, e->vector );
	    n /= 2;
	    if( n > 0 ) {
		ee = MultiplyEELocal( e, e );
		if( copied_e ) FreeExtensionElement( e );
		e = ee;
		copied_e = 1;
	    }
	}

	if( copied_e ) FreeExtensionElement( e );
	FreeVector(v);
	e  = NewExtensionElement();
	e->group = GroupWordExpVec( ev );
	e->vector = tv;
	Free( ev );

	return e;
}


ExtensionElement        *PowerEE( e, p )
ExtensionElement        *e;
int                     *p;

{       ExtensionElement *w;

        w = PowerEELocal( e, *p );
        FreeExtensionElement( e );

        return w;
}


ExtensionElement        *ConjugateEE( w, e )
ExtensionElement        *w, *e;

{       ExtensionElement        *g, *h;

        h = PowerEELocal( e, -1 );
        g = MultiplyEE( h, w );
        h = MultiplyEE( g, e );

        return h;
}

ExtensionElement        *CommutatorEE( e1, e2 )
ExtensionElement        *e1, *e2;

{       ExtensionElement        *g, *h;

        g = MultiplyEELocal( e2, e1 );
        h = PowerEELocal( g, -1 );
        FreeExtensionElement( (void *)g );
        g = MultiplyEE( h, e1 );
        h = MultiplyEE( g, e2 ); 

        return  h;
}

ExtensionElement *RelationEE( lhs, rhs )
ExtensionElement *lhs, *rhs;

{
    ExtensionElement *g, *h;

    h = PowerEELocal( rhs, -1 );
    g = MultiplyEE( lhs, h );
    FreeExtensionElement( rhs );

    return g;

}

void    InitCollectExtensionElement() {

        SetEvalFunc( TGEN,  (void *(*)())MappedEE );
        SetEvalFunc( TMULT, (void *(*)())MultiplyEE );
        SetEvalFunc( TPOW,  (void *(*)())PowerEE );
        SetEvalFunc( TCONJ, (void *(*)())ConjugateEE );
        SetEvalFunc( TCOMM, (void *(*)())CommutatorEE );
        SetEvalFunc( TREL,  (void *(*)())RelationEE );
}
