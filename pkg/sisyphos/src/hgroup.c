/********************************************************************/
/*  Module        : H group                                         */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies the routines needed to deal with free presented     */
/*     p-groups.                                                    */
/*                                                                  */
/********************************************************************/

/* 	$Id: hgroup.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: hgroup.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 11:57:04  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:01:11  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: hgroup.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "storage.h"
#include "hgroup.h"

static char cstring[4096];
static char **genlist;
GRPDSC *h_desc;
extern GRPDSC *g_desc;


void p_f_read_in ( FILE *in_file, int pos, GRPDSC *g_desc )
{
	int i;
	
	/* search start of group description in in_file */
	i = 0;
	do {
		fgets ( cstring, 128, in_file );
		if ( cstring[0] == '-' ) i++;
	} while ( i < pos );

	/* parse_presentation ( in_file, g_desc ); */
}


void p_read_in ( GRPDSC *g_desc )
{
	g_desc = NULL;
}

void get_p_group ( int grflag, GRPDSC *g_desc, int nr )
{
	int dsc_num;
	char a_file_name[13];
	char *file_n;
	FILE *a_file;

	if ( grflag == 0 )			/* read interactively */
		p_read_in ( g_desc );
	else if ( grflag == 1 ) {					/* read description from text file */
		printf ( "name of ascii file : " );
		scanf ( "%s", a_file_name );
		printf ( "number of entry    : " );
		scanf ( "%d", &dsc_num ); 										
		file_n = add_path ( "GROUPDSC", a_file_name );
		printf ( "opening file %s\n", file_n );
		a_file = fopen ( file_n, "r" );
		p_f_read_in ( a_file, dsc_num, g_desc );
		fclose ( a_file );
	}
	else {
		a_file = fopen ( "i:\\sis.neu\\groups\\m1024r", "r" );
		p_f_read_in ( a_file, nr, g_desc );
		fclose ( a_file );
	}

}

void tree_walk ( node p )
{
	switch ( p->nodetype ) {
		case GGEN:
				printf ( "%s", genlist[p->value] );
				break;
		case EQ  :
				tree_walk ( p->left );
				if ( p->right != NULL ) {
					printf ( "=" );
					tree_walk ( p->right );
				}
				break;
		case COMM:
				printf ( "[" );
				tree_walk ( p->left );
				printf ( "," );
				tree_walk ( p->right );
				printf ( "]" );
				break;
		case EXP :
				if ( p->left->nodetype != GGEN )
					printf ( "(" );
				tree_walk ( p->left );
				if ( p->left->nodetype != GGEN )
					printf ( ")" );
				printf ( "^%1d", p->value );
				break;
		case MULT:
				tree_walk ( p->left );
				printf ( "*" );
				tree_walk ( p->right );
				break;
		default:
				puts ( "Error in relation" );
	}
}

void show_rel ( GRPDSC *g_desc )
{
	int i;
	
	printf ( "\nrelations of group " );
	if ( g_desc->group_name[0] != '\0' )
		printf ( "%s", g_desc->group_name );
	printf ( ":\n" );
	for ( i = 0; i < g_desc->num_rel; i++ ) {
		tree_walk ( g_desc->rel_list[i] );
		printf ( "\n" );
	}
}

void show_group_rels ( GRPDSC *h, char *name )
{
    char **new_names;
    int i, nl;

    nl = strlen ( name );
    PUSH_STACK();
    new_names = ARRAY ( h->num_gen, char * );
    for ( i = 0; i < h->num_gen; i++ ) {
	   new_names[i] = CALLOCATE ( nl + 2 + 3 );
	   sprintf ( new_names[i], "%s[%1d]", name, i+1 );
    }
    genlist = new_names;
    printf ( "[\n" );
    for ( i = 0; i < h->num_rel; i++ ) {
	   tree_walk ( h->rel_list[i] );
	   if ( i < h->num_rel-1 )
		  printf ( ",\n" );
	   else
		  printf ( "\n" );
    }
    printf ( "]\n" );
    POP_STACK();
}

void show_grpdsc ( GRPDSC *g_desc )
{
	int i;
	
	genlist = g_desc->gen;
	printf ( "prime        : %4d\n", g_desc->prime );
	printf ( "num_gen      : %4d\n", g_desc->num_gen );
	printf ( "num_rel      : %4d\n", g_desc->num_rel );
	printf ( "is_minimal   : " );
	if ( g_desc->is_minimal )
		printf ( "TRUE\n" );
	else
		printf ( "FALSE\n" );
	if ( g_desc->group_name[0] != '\0' )
		printf ( "group name   : %s\n", g_desc->group_name );
	printf ( "gen	     : [" );
	for ( i = 0; i < g_desc->num_gen; i++ ) {
		printf ( "%s", g_desc->gen[i] );
		if ( i != g_desc->num_gen-1 )
			printf ( "," );
		else
			printf ( "]\n" );
	}
	printf ( "\n" );
	show_rel ( g_desc );
}

/*void p_f_read_in ( FILE *in_file, int pos, GRPDSC *g_desc )
{
	int i; */
	
	/* search start of group description in in_file */
/*	if ( pos != -1 ) {
		i = 0;
		do {
			fgets ( cstring, 80, in_file );
			if ( cstring[0] == '-' ) i++;
		} while ( i < pos );
	}

	parse_presentation ( in_file, g_desc );
} */

void set_h_group ( GRPDSC *h_group )
{
	h_desc = h_group;
}


