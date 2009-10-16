/****************************************************************************
**
**    mem.c                           NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#include <stdio.h>
#include "mem.h"

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

	if( (unsigned long)ptr & 0x3 )
	    printf( "Warning, pointer not aligned.\n" );
	return ptr;
}

void	*ReAllocate( optr, nchars )
void	 *optr;
unsigned nchars;

{	optr = (void *)realloc( (char *)optr, nchars );
	if( optr == (void *)0 ) AllocError( "ReAllocate" );

	if( (unsigned long)optr & 0x3 )
	    printf( "Warning, pointer not aligned.\n" );
	return optr;
}

void	Free( ptr )
void	*ptr;

{	free( (char *)ptr );    }
