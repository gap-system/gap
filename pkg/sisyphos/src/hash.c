/* 	$Id: hash.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: hash.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:13:38  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: hash.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

# include	<ctype.h>
# include	<stdlib.h>
# include	"aglobals.h"
# include	"hash.h"
# include	"storage.h"

void assort 			_(( BUCKET **base, int nel, int elsize, int (*cmp)() ));
static int internal_cmp 	_(( BUCKET **p1, BUCKET **p2 ));

void assort ( BUCKET **base, int nel, int elsize, int (*cmp)() )
{
	int i, j, gap;
	BUCKET *tmp, **p1, **p2;
	
	for ( gap = 1; gap <= nel; gap = 3*gap + 1 );
	
	for ( gap /= 3; gap > 0; gap /= 3 )
		for ( i = gap; i < nel; i++ )
			for ( j = i - gap; j >= 0; j -= gap ) {
				p1 = base + ( j );
				p2 = base + ((j+gap));
				
				if ( (*cmp)( p1, p2 ) <= 0 )
					break;
					
				tmp = *p1;
				*p1 = *p2;
				*p2 = tmp;
			}
}

void *newsym ( int size )
{
	BUCKET *sym;
	
	if ( (sym = (BUCKET *)callocate ( size + sizeof ( BUCKET ) )) == NULL ) {
		fprintf ( stderr, "Can't get memory for BUCKET\n" );
		return NULL;
	}
	return (void *)(sym+1);
}

/* !!!!! change this !!!!! */
void freesym ( void *sym )
{
	free ( (BUCKET *)sym - 1 );
}

HASH_TAB *maketab ( unsigned maxsym, unsigned (*hash_function)(), int (*cmp_function)() )
{
	HASH_TAB *p;
	
	if ( !maxsym )
		maxsym = 127;
		
	if ( (p = (HASH_TAB*)callocate ( (maxsym
			* sizeof ( BUCKET*)) + sizeof(HASH_TAB)) ) != NULL ) {
		p->size = maxsym;
		p->numsyms = 0;
		p->hash = hash_function;
		p->cmp = cmp_function;
	}
	else {
		fprintf ( stderr, "Insufficient memory for symbol table\n" );
		return NULL;
	}
	return p;
}

void *addsym ( HASH_TAB *tabp, void *isym )
{
	BUCKET **p, *tmp;
	BUCKET *sym = (BUCKET *)isym;
	
	p = & (tabp->table) [(*tabp->hash)( sym-- ) % tabp->size ];
	
	tmp = *p;
	*p = sym;
	sym->prev = p;
	sym->next = tmp;
	
	if ( tmp )
		tmp->prev = &sym->next;
	
	tabp->numsyms++;
	return (void*)(sym+1);
}

void delsym ( HASH_TAB *tabp, void *isym )
{
	BUCKET *sym = (BUCKET *)isym;
	
	if ( tabp && sym ) {
		--tabp->numsyms;
		--sym;
		if ( (*(sym->prev) = sym->next) != NULL )
			sym->next->prev = sym->prev;
	}
}

void *findsym ( HASH_TAB *tabp, void *sym )
{
	BUCKET *p;
	
	if ( !tabp )
		return NULL;
	
	p = (tabp->table)[(*tabp->hash)(sym) % tabp->size ];
	
	while ( p && (*tabp->cmp)( sym, p+1 ) )
		p = p->next;
		
	return (void *)( p ? p + 1 : NULL );
}

void *nextsym ( HASH_TAB *tabp, void *i_last )
{
	BUCKET *last = (BUCKET *)i_last;
	
	for ( --last; last->next; last = last->next )
		if ( (tabp->cmp)(last+1, last->next+1) == 0 )
			return (char *)(last->next+1);
	return NULL;
}

static int (*User_cmp)();

int ptab ( HASH_TAB *tabp, void (*print)(), void *param, int sort )
{
	BUCKET **outtab, **outp, *sym, **symtab;
	int internal_cmp();
	int i;
	
	if ( !sort ) {
		for ( symtab = tabp->table, i = tabp->size; --i >= 0; symtab++ ) {
			for ( sym = *symtab; sym; sym = sym->next )
				(*print)( sym +1, param );
		}
	}
	else {
		PUSH_STACK();
		if ( (outtab = (BUCKET **)ALLOCATE ( tabp->numsyms * sizeof(BUCKET*)) ) == NULL )
			return 0;
			
		outp = outtab;
		
		for ( symtab = tabp->table, i = tabp->size; --i >= 0; symtab++ )
			for ( sym = *symtab; sym; sym = sym->next ) {
				if ( outp > outtab + tabp->numsyms ) {
					fprintf ( stderr, "Internal error [ptab], table overflow\n" );
					exit ( 1 );
				}
				*outp++ = sym;
			}
			
		User_cmp = tabp->cmp;
		assort ( outtab, tabp->numsyms, (int)sizeof ( BUCKET* ), internal_cmp );
		
		for ( outp = outtab, i = tabp->numsyms; --i >= 0; outp++ )
			(*print)( (*outp)+1, param );
			
		POP_STACK();
	}
	return 1;
}

static int internal_cmp ( BUCKET **p1, BUCKET **p2 )
{
	return (*User_cmp)( *p1+1, *p2+1 );
}


	
