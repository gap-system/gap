/* 	$Id: symtab.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: symtab.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 09:53:05  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	Added support for function entries.
 *
 * Revision 1.2  1995/01/05  17:14:32  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: symtab.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "hash.h"
#include "symtab.h"
#include "graut.h"
/* #include "dispatch.h" */

/*
#define NAME_MAX 32
#define MAXSYM 127

typedef struct symtabentry {
	char name[NAME_MAX+1];
	TYPE type;
	int value1;
	int value2;
	void *object;
	void *etype;
	int level;
} symbol;
*/

extern FUNCDSC func_desc[];
extern char *func_names[];
extern char *type_str[];


static HASH_TAB *symtab;

int cmp ( symbol *sym1, symbol *sym2 )
{
	return strcmp ( sym1->name, sym2->name );
}

void init_sym_tab (void)
{
    symbol *sp;
    int i;

    symtab = maketab ( MAXSYM, hash_pjw, cmp );
    for ( i = 0; strcmp ( func_names[i], "dummy" ); i++ ) {
	   sp = new_symbol ( func_names[i], 0 );
	   sp->value1 = sp->value2 = -1;
	   sp->object = &func_desc[i];
	   add_symbol ( sp );
    }
}

symbol *new_symbol ( char *name, int scope )
{
	symbol *sym_p;
	
	sym_p = (symbol *)newsym ( sizeof ( symbol ) );
	strncpy ( sym_p->name, name, sizeof ( sym_p->name ) );
	sym_p->type = NOTYPE;
	sym_p->value1 = sym_p->value2 = 0;
	sym_p->object = sym_p->etype = NULL;
	sym_p->level = scope;
	
	return ( sym_p );
}

symbol *add_symbol ( symbol *sym )
{
	return (symbol *)addsym ( symtab, sym );
}

symbol *find_symbol ( char *symname )
{
	return (symbol *)findsym ( symtab, symname );
}

void symprint ( symbol *sym, FILE *stream )
{
	fprintf ( stream, "%-32s of type %s\n", sym->name, type_str[sym->type] );
}

void show_symbols (void)
{
	ptab ( symtab, symprint, stdout, TRUE );
}
	
















