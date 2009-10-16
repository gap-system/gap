/* 	$Id: hashfunc.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: hashfunc.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:14:06  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: hashfunc.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

# include	"debug.h"
# include	"hash.h"


#define NBITS_IN_UNSIGNED	( sizeof(unsigned int)<<3 )
#define SEVENTY_FIVE_PERCENT	( (int)(NBITS_IN_UNSIGNED * .75) )
#define TWELVE_PERCENT		( (int)(NBITS_IN_UNSIGNED * .125) )
#define HIGH_BITS			( ~( (unsigned)(~0) >> TWELVE_PERCENT) )

unsigned hash_add ( unsigned char *name )
{
	unsigned h;
	
	for ( h = 0; *name; h += *name++ );
	return h;
}

unsigned hash_pjw ( unsigned char *name )
{
	unsigned h = 0;
	unsigned g;
	
	for ( ; *name; ++name ) {
		h = (h << TWELVE_PERCENT) + *name;
		if ( (g = h & HIGH_BITS) != 0 )
			h = (h ^ (g >> SEVENTY_FIVE_PERCENT)) & ~HIGH_BITS;
	}
	return h;
}

