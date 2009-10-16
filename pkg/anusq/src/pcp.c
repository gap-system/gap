/****************************************************************************
**
**    pcp.c                           NQ                       Werner Nickel
**
**    Copyright 1992                            Mathematics Research Section
**                                           School of Mathematical Sciences 
**                                            Australian National University
*/

#include "pres.h"
#include "sq.h"

static void	RelError( r, type )
node	*r;
int	type;

{	if( type == TREL )
	    printf( "The following is not a power or conjugate relation:\n" );
	if( type == TPOW )
	    printf( "The following is not the lhs of a power relation:\n" );
	if( type == TCONJ )
	    printf( "The following is not the lhs of a conjugate relation:\n" );
	PrintNode( r );
	printf( "\n" );

	exit( 5 );
}

static void	LookAtPow( r, a, n )
node	*r;
gen	*a;
int	*n;

{	if( r->type != TPOW ) RelError( r, TPOW );
	if( r->cont.op.l->type != TGEN ) RelError( r, TPOW );
	if( r->cont.op.r->type != TNUM ) RelError( r, TPOW );
	*a = r->cont.op.l->cont.g;
	*n = r->cont.op.r->cont.n;
}

static void	LookAtConj( r, a, b )
node	*r;
gen	*a, *b;

{	int	n;

	if( r->type != TCONJ ) RelError( r, TCONJ );

	if( r->cont.op.l->type != TGEN ) RelError( r, TCONJ );
	*a = r->cont.op.l->cont.g;

	if( r->cont.op.r->type != TGEN ) {
	    if( r->cont.op.r->type != TPOW ) RelError( r, TCONJ );
	    LookAtPow( r->cont.op.r, b, &n );
	    if( n != -1 ) RelError( r, TCONJ );
	    *b = -*b;
	}
	else
	    *b = r->cont.op.r->cont.g;
}

static void	ProcessRelation( r )
node	*r;

{	gen	a, b;
	int	n, defining = 0;
	void	*rhs;
	
	switch( r->type ) {
	    case TPOW: LookAtPow( r, &a, &n );
		       StorePower( a, n, (void *)0, 0 );
		       break;
	    case TDRELR: defining = 1;
	    case TREL: if( r->cont.op.l->type == TPOW ) {
			   LookAtPow( r->cont.op.l, &a, &n );
			   rhs = EvalNode( r->cont.op.r );
			   StorePower( a, n, rhs, defining );
			   break;
		       }
	               if( r->cont.op.l->type == TCONJ ) {
			   LookAtConj( r->cont.op.l, &a, &b );
			   rhs = EvalNode( r->cont.op.r );
			   StoreConj( a, b, rhs, defining );
			   break;
		       }
	    default:   RelError( r, TREL );
		       break;
	}
}

void	ProcessAllRelations() {

	gen	g;
	node	*r;

	r = FirstRelation();
	while( r != (node *)0 ) {
		ProcessRelation( r );
		r = NextRelation();
	}
}

void	ReadPcPres( fp, filename )
FILE	*fp;
char	*filename;

{	gen	g;

	GetPresentation( fp, filename );
#ifdef CHAT 
	fprintf( stdout, "read the following presentation\n" );
	PrintPresentation(stdout);
#endif

	InitExtensionElement();
	P = InitPresentation();

	ProcessAllRelations();

}
