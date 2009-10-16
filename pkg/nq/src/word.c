/*****************************************************************************
**
**    word.c                          NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/


#include "nq.h"

void	printGen( g, c )
gen	g;
char	c;

{	putchar( c + (g-1) % 26 );
	if( (g-1) / 26 != 0 )
	    printf( "%d", (g-1) / 26 );
}

void	printWord( w, c )
word	w;
char	c;

{	if( w == (word)0 || w->g == EOW ) {
	    printf( "Id" );
	    return;
	}
	
	while( w->g != EOW ) {
	    if( w->g > 0 ) {
		printGen( w->g, c );
		if( w->e != (exp)1 )
#ifdef LONGLONG
		    printf( "^%Ld", w->e );
#else
		    printf( "^%d", w->e );
#endif
	    }
	    else {
		printGen( -w->g, c );
#ifdef LONGLONG
		printf( "^%Ld", -w->e );
#else
		printf( "^%d", -w->e );
#endif
	    }
	    w++;
	    if( w->g != EOW ) putchar( '*' );
	}
}
