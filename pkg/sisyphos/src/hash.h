/* 	$Id: hash.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: hash.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:29:07  pluto
 * Initial version under RCS control.
 *	 */

#ifdef ANSI
#define _( params ) params
#else
#define _( params ) ()
#endif

typedef struct bucket {
	struct bucket *next;
	struct bucket **prev;
} BUCKET;

typedef struct hash_tab {
	int size;
	int numsyms;
	unsigned (*hash)();
	int (*cmp)();
	BUCKET *table[1];
} HASH_TAB;

HASH_TAB *maketab 		_(( unsigned maxsym, unsigned (*hash)(), int (*cmp)() ));
void *newsym			_(( int size ));
void freesym			_(( void *sym ));
void *addsym			_(( HASH_TAB *tabp, void *sym ));
void *findsym			_(( HASH_TAB *tabp, void *sym ));
void *nextsym			_(( HASH_TAB *tabp, void *last ));
void delsym			_(( HASH_TAB *tabp, void *sym ));
int ptab				_(( HASH_TAB *tabp, void (*prnt)(), void *par, int srt ));
unsigned hash_add		_(( unsigned char *name ));
unsigned hash_pjw		_(( unsigned char *name ));

	
