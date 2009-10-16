/****************************************************************************
**
**    arith.c                  ANU SQ                        Alice C Niemeyer
**
**    Copyright 1994                             Mathematics Research Section
**                                            School of Mathematical Sciences 
**                                             Australian National University
**
**
**  This file contains the basic arithmetic operations with the data 
**  structures. They are used for the interface to the functions that read 
**  a presentation.
**
*/

#include "pres.h"
#include "sq.h"
#include "modmem.h"

/*
** This function returns an ExtensionElement with the group part
** corresponding to the argument <nr>.
*/
ExtensionElement *NumberExtensionElement( g )
gen g;

{
    ExtensionElement  *e;

    e = NewExtensionElement();

    e->group    = NewGroupWord(1);
    e->vector   = NewVector(0);

    e->group[0].gen = (usgshort) g;
    e->group[0].exp = (uint)   1;

    return e;

}


/*
** Computes the length of an GroupWord.
*/

uint LengthGroupWord( gw )
GroupWord gw;

{   register uint i;

    if ( gw == NULL ) return 0;
    for ( i = 0; ISBOUNDGG(gw); i++, gw++ );

    return i;
}

uint LengthVector( v )
Vector v;

{   register uint i;

    for ( i = 0; ISBOUNDMG(v); i++, v++ );

    return i;
}

uint LengthRingWord( v )
RingWord v;

{
    GroupWord w;
    register uint i;

    for ( i = 0; ISBOUNDRE(v); i++, v++ );

    return i;
}


GroupWord InverseGroupWord( w )
GroupWord w;

{
    uint      l;
    GroupWord v;
  
    l = LengthGroupWord(w);
    v = NewGroupWord(l);
    if ( l == 0 ) return v;
    for ( v = v+l-1; ISBOUNDGG(w); v--, w++ ) {
	v->gen =   w->gen;
	v->exp = - w->exp;
    }

    return v+1;
}

RingWord InverseRingWord( w )
RingWord w;
{
    uint     l;
    RingWord v;
    GroupWord gw;

    l = LengthRingWord( w );
    v = NewRingWord( l );

    for ( ; ISBOUNDRE(w); v++, w++) {
      v->mult = - w->mult;
      v->ring = CopyGroupWord( w->ring );
    }

    return v;
}


Vector InverseVector( v )
Vector v;

{

    int    l;
    Vector w;
    
    if ( v == (Vector) NULL ) return v;

    l = LengthVector( v );
    w = NewVector(l);
    if ( l == 0 ) return w;
    for ( w = w+l-1; ISBOUNDMG(v); w--, v++ ) {
	w->gen = v->gen;
	w->exp = InverseRingWord(v->exp);
    }

    return v+1;

}
    

GroupWord MultiplyGroupWordLocal( w1, w2 )
GroupWord w1, w2;
{
     GroupWord w, r;

    r = w = NewGroupWord(LengthGroupWord(w1)+LengthGroupWord(w2));

    while ( ISBOUNDGG(w1) )
        *w++ = *w1++;
    while ( ISBOUNDGG(w2) )
        *w++ = *w2++;

    return r;
}

/*
** This function multiplies two ExtensionElements by concatenation. It 
** does not free the ExtensionElements <e1> and <e2>.
*/
ExtensionElement *MultiplyExtensionElementLocal( e1, e2 )
ExtensionElement *e1, *e2;

{

    ExtensionElement   *e;

    if ( e1 == (ExtensionElement *) NULL )
      return e2;
    if ( e2 == (ExtensionElement *) NULL )
      return e1;

    e = NewExtensionElement();

    e->group = MultiplyGroupWordLocal( e1->group, e2->group );
    e->vector = NewVector(0);

    return e;

}

/*
** This function multiplies the ExtensionElement <e1> and <e2> and frees
** the ExtensionElements <e1> and <e2>.
*/
ExtensionElement *MultiplyExtensionElement( e1, e2 )
ExtensionElement e1, e2;

{
    ExtensionElement *e;

    e = MultiplyExtensionElementLocal(e1, e2);
    FreeExtensionElement( e1 ); 
    FreeExtensionElement( e2 );

    return e;

}


/*
** This function computs the p-th power of the ExtensionElement <e>, where
** multiplication corresponds to concatenation.
** It does not free the argument <e>.
*/

ExtensionElement *PowerExtensionElementLocal( e, p )
ExtensionElement *e;
int              *p;
{
        uint              l;
        int             exp;
	ExtensionElement *res;
	GroupWord        w, pt, h;

	exp = *p;

	res = NewExtensionElement();
	res->vector = NewVector(0);
	l = LengthGroupWord( e->group );

        if( exp < 0 ) {
	    w = InverseGroupWord(e->group);
	    exp = -exp;
	}
        else if( exp > 0 ) {
	    w = CopyGroupWord( e->group );
	}
	res->group = w;
	if( exp == 1 ) return res;

	h = NewGroupWord(0);
	while( exp > 0 ) {
	    if( exp % 2 == 1 ) {
		w = h; h = MultiplyGroupWordLocal( h, res->group ); 
                FreeGroupWord( (void *)w );
	    }
	    if ( exp > 1 ) {
                w = res->group; 
                res->group = MultiplyGroupWordLocal(res->group,res->group); 
                FreeGroupWord( (void *)w );
	    }
	    exp = exp / 2;
	}
	FreeGroupWord( (void *) res->group );

	res->group = h;
	return res;  
}

ExtensionElement	*PowerExtensionElement( e, p )
ExtensionElement        *e;
int	                *p;

{	ExtensionElement *w;

	w = PowerExtensionElementLocal( e, p );
	FreeExtensionElement( (void *)e );

	return w;
}


ExtensionElement	*ConjugateExtensionElement( w, e )
ExtensionElement        *w, *e;

{	ExtensionElement	*g, *h;
	int	                inv = -1;

	h = PowerExtensionElementLocal( e, &inv );
        g = MultiplyExtensionElementLocal( h, w ); 
        FreeExtensionElement( (void *)h );
	h = MultiplyExtensionElementLocal( g, e );
        FreeExtensionElement( (void *)g );
	FreeExtensionElement( (void *)w ); 
	FreeExtensionElement( (void *)e ); 

	return h;
}

ExtensionElement	*CommutatorExtensionElement( e1, e2 )
ExtensionElement	*e1, *e2;

{	ExtensionElement	*g, *h;
	int	                inv = -1;

	g = MultiplyExtensionElementLocal( e2, e1 );
	h = PowerExtensionElementLocal( g, &inv );  
        FreeExtensionElement( (void *)g );
	g = MultiplyExtensionElementLocal( h, e1 );
        FreeExtensionElement( (void *)h );
	h = MultiplyExtensionElementLocal( g, e2 ); Free( (void *)g );
        FreeExtensionElement( (void *)g );
        FreeExtensionElement( (void *)e1 );
        FreeExtensionElement( (void *)e2 );

	return	h;
}

	
ExtensionElement *RelationExtensionElement( lhs, rhs )
ExtensionElement *lhs, *rhs;

{	
    ExtensionElement *g, *h;
    int	e = -1;

    h = PowerExtensionElementLocal( rhs, &e );
    g = MultiplyExtensionElementLocal( lhs, h ); 
    FreeExtensionElement( h );

    FreeExtensionElement( lhs ); FreeExtensionElement( rhs );
    return g;

}

void	InitExtensionElement() {

	SetEvalFunc( TGEN,  (void *(*)())NumberExtensionElement );
	SetEvalFunc( TMULT, (void *(*)())MultiplyExtensionElement );
	SetEvalFunc( TPOW,  (void *(*)())PowerExtensionElement );
	SetEvalFunc( TCONJ, (void *(*)())ConjugateExtensionElement );
	SetEvalFunc( TCOMM, (void *(*)())CommutatorExtensionElement );
	SetEvalFunc( TREL,  (void *(*)())RelationExtensionElement );
}



