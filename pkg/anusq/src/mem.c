/****************************************************************************
**
**    mem.c                           NQ                       Werner Nickel
**
**    Copyright 1992                            Mathematics Research Section
**                                           School of Mathematical Sciences 
**                                            Australian National University
*/

#include <stdio.h>
#include "pres.h"
extern FILE *FN;

void	AllocError( str )
char	*str;

{	fflush( stdout );

	fprintf( stderr, "%s failed: ", str );
	perror( "" );
	exit( 4 );
}
    
void	*Allocate( nchars )
unsigned nchars;

{	void	*ptr;

	ptr = (void *)calloc( nchars, sizeof(char) );
	if( ptr == (void *) 0 ) AllocError( "Allocate" );
/*	fprintf( FN, "A%d, Size: %d, File: %s, Line: %d\n", 
		      ptr, nchars, __FILE__, __LINE__); */

#ifdef DEBUG
	if( (unsigned long)ptr & 0x3 )
	    printf( "Warning, pointer not aligned.\n" );
#endif
	return ptr;
}

void	*Mallocate( nchars )
unsigned nchars;

{	void	*ptr;

	ptr = (void *)malloc( nchars, sizeof(char) );
	if( ptr == (void *) 0 ) AllocError( "CAllocate" );

#ifdef DEBUG
	if( (unsigned long)ptr & 0x3 )
	    printf( "Warning, pointer not aligned.\n" );
#endif
	return ptr;
}

void	*ReAllocate( optr, nchars )
void	 *optr;
unsigned nchars;

{	optr = (void *)realloc( (char *)optr, nchars );
	if( optr == (void *)0 ) AllocError( "ReAllocate" );

#ifdef DEBUG
	if( (unsigned long)optr & 0x3 )
	    printf( "Warning, pointer not aligned.\n" );
#endif
	return optr;
}

void	Free( ptr )
void	*ptr;

{	free( (char *)ptr );
	/* fprintf( FN, "F%d\n", ptr ); */
 }



