/********************************************************************/
/*                                                                  */
/*  Module        : SISCode                                         */
/*                                                                  */
/*  Description :                                                   */
/*     Contains functions handling SISCode.                         */
/*                                                                  */
/********************************************************************/
/* 	$Id: siscode.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: siscode.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 1.3  1995/08/10 11:51:03  pluto
 * 	Added code to handle gmodule and cohomology structures.
 *
 * 	Revision 1.2  1995/06/29 09:54:28  pluto
 * 	Initial revision under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: siscode.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#include <ctype.h>
#include "aglobals.h"
#include "fdecla.h"
#include "graut.h"
#include "aut.h"
#include "pc.h"
#include "parsesup.h"
#include "grpring.h"
#include "gmodule.h"
#include "cohomol.h"
#include "storage.h"
#include "siscode.h"
#include "error.h"

#define NINT *(int *)p->value.gv

extern DSTYLE displaystyle;

static DYNLIST pp = NULL;

void write_intlist ( int value, int is_start, int is_end )
{
	static int count;
	
	if ( is_start ) {
		count = 0;
		return;
	}
	printf ( "%d", value );
	if ( !is_end )
		printf ( "," );
	if ( ++count == 12 ) {
		count = 0;
		printf ( "\n" );
	}
}
	
void node_to_code ( node p )
{
	if ( p == NULL )
		write_intlist ( -1, FALSE, FALSE );
	else {
		write_intlist ( p->nodetype, FALSE, FALSE );
		write_intlist ( p->value, FALSE, FALSE );
		node_to_code ( p->left );
		node_to_code ( p->right );
	}
}

node code_to_node (void)
{
	node n;
	
	if ( *(int *)pp->value.gv == -1 ) {
		pp = pp->next;
		return ( NULL );
	}
	n = ALLOCATE ( sizeof ( rel_node ) );
	n->nodetype = *(int *)pp->value.gv; pp = pp->next;
	n->value = *(int *)pp->value.gv; pp = pp->next;
	n->left = code_to_node();
	n->right = code_to_node();
	return ( n );
}

void pcgroup_to_code ( PCGRPDESC *g, int bracket )
{
	int i, j, cnr;
	size_t l;
	char *rec_prefx, *rec_postfx;

	if ( displaystyle == GAP ) {
		rec_prefx = "SISYPHOS.SISCODE :=  [";
		rec_postfx = "];\n";
	}
	else {
		rec_prefx = "[";
		rec_postfx = "]\n";
	}
	

	cnr = ( g->num_gen * ( g->num_gen -1 ) ) >> 1;

	if ( bracket ) {
		printf ( "%s%d,\n", rec_prefx, PCGROUP );
		write_intlist ( 0, TRUE, FALSE );
	}
	else
		printf ( "%d,\n", PCGROUP );
		
	write_intlist ( g->prime, FALSE, FALSE );
	write_intlist ( g->num_gen, FALSE, FALSE );
	write_intlist ( g->group_card, FALSE, FALSE );
	write_intlist ( g->max_id, FALSE, FALSE );
	write_intlist ( g->min_gen, FALSE, FALSE );
	write_intlist ( g->defs, FALSE, FALSE );
	for ( i = 0; i < 50; i++ )
		write_intlist ( g->group_name[i], FALSE, FALSE );

	for ( i = 0; i < g->num_gen; i++ )
		write_intlist ( g->g_max[i], FALSE, FALSE );
	for ( i = 0; i < g->num_gen; i++ )
		write_intlist ( g->g_ideal[i], FALSE, FALSE );
	for ( i = 0; i < g->num_gen; i++ )
		write_intlist ( g->image[i], FALSE, FALSE );
	for ( i = 0; i < g->num_gen; i++ )
		write_intlist ( g->pimage[i], FALSE, FALSE );
	
	for ( i = 0; i < g->num_gen; i++ ) {
		l = strlen ( g->gen[i] );
		write_intlist ( (int)l, FALSE, FALSE );
		for ( j = 0; j < l; j++ )
			write_intlist ( g->gen[i][j], FALSE, FALSE );
	}	

	for ( i = 0; i < g->num_gen; i++ ) {
		for ( j = 0; j < g->num_gen; j++ )
			write_intlist (  g->nom[i][j], FALSE, FALSE );
	}	

	for ( i = 0; i < cnr; i++ )
		write_intlist ( g->c_len[i], FALSE, FALSE );
	for ( i = 0; i < g->num_gen; i++ )
		write_intlist ( g->p_len[i], FALSE, FALSE );

	for ( i = 0; i < cnr; i++ ) {
		if ( g->c_list[i] == NULL )
			write_intlist ( 0, FALSE, FALSE );
		else {
			for ( j = 0; j < g->c_len[i]+1; j++ ) {
				write_intlist ( g->c_list[i][j].g, FALSE, FALSE );
				write_intlist ( g->c_list[i][j].e, FALSE, FALSE );
			}
		}
	}
	
	for ( i = 0; i < g->num_gen; i++ ) {
		if ( g->p_list[i] == NULL )
			write_intlist ( 0, FALSE, FALSE );
		else {
			for ( j = 0; j < g->p_len[i]+1; j++ ) {
				write_intlist ( g->p_list[i][j].g, FALSE, FALSE );
				write_intlist ( g->p_list[i][j].e, FALSE, FALSE );
			}
		}
	}
	
	for ( i = 0; i < g->num_gen; i++ )
		node_to_code ( g->def_list[i] );
	
	write_intlist ( g->exp_p_class, FALSE, FALSE );
	for ( i = 0; i <= g->exp_p_class; i++ ) {
		write_intlist ( g->exp_p_lcs[i].i_start, FALSE, FALSE );
		write_intlist ( g->exp_p_lcs[i].i_end, FALSE, FALSE );
		write_intlist ( g->exp_p_lcs[i].i_dim, FALSE, FALSE );
	}
	
	for ( i = 0; i < g->num_gen-1; i++ )
		write_intlist ( g->pc_weight[i], FALSE, FALSE );
	
	if ( bracket ) {
		write_intlist ( g->pc_weight[g->num_gen-1], FALSE, TRUE );
		printf ( "%s", rec_postfx );
	}
	else
		write_intlist ( g->pc_weight[g->num_gen-1], FALSE, FALSE ); 
}


PCGRPDESC *code_to_pcgroup ( DYNLIST p )
{
	int i, j, l, cnr;
	PCGRPDESC *pc_desc = ALLOCATE ( sizeof ( PCGRPDESC ) );
	
	pc_desc->prime = NINT; p = p->next;
	pc_desc->num_gen = NINT; p = p->next;
	pc_desc->group_card = NINT; p = p->next;
	pc_desc->max_id = NINT; p = p->next;
	pc_desc->min_gen = NINT; p = p->next;
	pc_desc->defs = NINT; p = p->next;
	pc_desc->gen = ALLOCATE ( pc_desc->num_gen * sizeof ( char * ) );
	pc_desc->g_max = CALLOCATE ( pc_desc->num_gen * sizeof ( int ) );
	pc_desc->g_ideal = CALLOCATE ( pc_desc->num_gen * sizeof ( int ) );
	pc_desc->image = CALLOCATE ( pc_desc->num_gen * sizeof ( int ) );
	pc_desc->pimage = CALLOCATE ( pc_desc->num_gen * sizeof ( int ) );
	pc_desc->p_list = (ge_pair **)ALLOCATE ( pc_desc->num_gen * sizeof ( ge_pair *) );
	pc_desc->p_len = (int *)ALLOCATE ( pc_desc->num_gen * sizeof ( int ) );
	zero_vector ( pc_desc->group_name, 50 );
	for ( i = 0; i < 50; i++,p = p->next )
		pc_desc->group_name[i] = NINT;
		
	for ( i = 0; i < pc_desc->num_gen; i++,p = p->next )
		pc_desc->g_max[i] = NINT;

	for ( i = 0; i < pc_desc->num_gen; i++,p = p->next )
		pc_desc->g_ideal[i] = NINT;
	for ( i = 0; i < pc_desc->num_gen; i++,p = p->next )
		pc_desc->image[i] = NINT;
	for ( i = 0; i < pc_desc->num_gen; i++,p = p->next )
		pc_desc->pimage[i] = NINT;

	cnr = ( pc_desc->num_gen * ( pc_desc->num_gen -1 ) ) >> 1;

	pc_desc->c_list = (ge_pair **)ALLOCATE ( cnr * sizeof ( ge_pair * ) );
	pc_desc->c_len = (int *)ALLOCATE ( cnr * sizeof ( int ) );
	pc_desc->def_list = ALLOCATE ( pc_desc->num_gen * sizeof ( GENDEF ) );
	pc_desc->pc_weight = ALLOCATE ( pc_desc->num_gen * sizeof ( int ) );
	pc_desc->exp_p_lcs = ALLOCATE ( (pc_desc->exp_p_class+1) * sizeof ( FILT ) );
	for ( i = 0; i < pc_desc->num_gen; i++ ) {
		l = NINT; p = p->next;
		pc_desc->gen[i] = ALLOCATE ( l+1 );
		for ( j = 0; j < l; j++, p=p->next )
			pc_desc->gen[i][j] = NINT;
		pc_desc->gen[i][l] = '\0';
	}	

	pc_desc->nom = ALLOCATE ( pc_desc->num_gen * sizeof ( PCELEM ) );
	for ( i = 0; i < pc_desc->num_gen; i++ ) {
		pc_desc->nom[i] = CALLOCATE ( pc_desc->num_gen );
		for ( j = 0; j < pc_desc->num_gen; j++, p=p->next )
			pc_desc->nom[i][j] = NINT;
	}

	for ( i = 0; i < cnr; i++,p = p->next )
		pc_desc->c_len[i] = NINT;
	for ( i = 0; i < pc_desc->num_gen; i++,p = p->next )
		pc_desc->p_len[i] = NINT;

	for ( i = 0; i < cnr; i++ ) {
		if ( pc_desc->c_len[i] == 0 ) {
			pc_desc->c_list[i] = NULL;
			p = p->next;
		}
		else {
			pc_desc->c_list[i] = ALLOCATE ( (pc_desc->c_len[i]+1) * sizeof ( ge_pair ) );
			for ( j = 0; j < pc_desc->c_len[i]+1; j++, p=p->next ) {
				pc_desc->c_list[i][j].g = NINT; p=p->next;
				pc_desc->c_list[i][j].e = NINT;
			}
		}
	}
	
	for ( i = 0; i < pc_desc->num_gen; i++ ) {
		if ( pc_desc->p_len[i] == 0 ) {
			pc_desc->p_list[i] = NULL;
			p = p->next;
		}
		else {
			pc_desc->p_list[i] = ALLOCATE ( (pc_desc->p_len[i]+1) * sizeof ( ge_pair ) );
			for ( j = 0; j < pc_desc->p_len[i]+1; j++, p=p->next ) {
				pc_desc->p_list[i][j].g = NINT; p=p->next;
				pc_desc->p_list[i][j].e = NINT;
			}
		}
	}
	
	pp = p;
	for ( i = 0; i < pc_desc->num_gen; i++ )
		pc_desc->def_list[i] = code_to_node();

	p = pp;
	pc_desc->exp_p_class = NINT; p = p->next;
	
	pc_desc->exp_p_lcs = ALLOCATE ( (pc_desc->exp_p_class+1) * sizeof ( FILT ) );
	for ( i = 0; i <= pc_desc->exp_p_class; i++,p = p->next ) {
		pc_desc->exp_p_lcs[i].i_start = NINT; p=p->next;
		pc_desc->exp_p_lcs[i].i_end = NINT; p=p->next;
		pc_desc->exp_p_lcs[i].i_dim = NINT;
	}	
	for ( i = 0; i < pc_desc->num_gen; i++,p = p->next )
		pc_desc->pc_weight[i] = NINT;
	pc_desc->autg = NULL;
	pp = p;
	
	return ( pc_desc );
}

void hom_to_code ( HOM *a )
{
	int i, j, l, numgen;
	PCGRPDESC *g = a->g;
	char *rec_prefx, *rec_postfx;

	if ( a->auts == 0 && !a->elements )
		return;

	if ( displaystyle == GAP ) {
		rec_prefx = "SISYPHOS.SISCODE :=  [";
		rec_postfx = "];\n";
	}
	else {
		rec_prefx = "[";
		rec_postfx = "]\n";
	}
	
	numgen = g->defs ? g->min_gen : g->num_gen;
	printf ( "%s%d,\n", rec_prefx, HOMREC );
	pcgroup_to_code ( g, FALSE );	
	write_intlist ( a->auts, FALSE, FALSE );
	write_intlist ( a->class1_generators, FALSE, FALSE );
	write_intlist ( a->inn_log, FALSE, FALSE );
	write_intlist ( a->out_log, FALSE, FALSE );
	write_intlist ( a->only_normal_auts, FALSE, FALSE );
	write_intlist ( a->with_inner, FALSE, FALSE );

	for ( i = 1; i <= g->exp_p_class; i++ )
		write_intlist ( a->aut_gens_dim[i], FALSE, FALSE );
	for ( i = 1; i <= g->exp_p_class; i++ )
		write_intlist ( a->out_gens_dim[i], FALSE, FALSE );

	for ( i = 1; i <= g->exp_p_class; i++ ) {
		for ( j = 0; j < a->aut_gens_dim[i]; j++ )
			for ( l = 0; l < g->num_gen * numgen; l++ )
				write_intlist ( a->aut_gens[i][j][l], FALSE, FALSE );
	}
	
	write_intlist ( a->elements, FALSE, TRUE );
	printf ( "%s", rec_postfx );
}

HOM *code_to_hom ( DYNLIST p )
{
	int i, j, l, numgen;
	HOM *a = ALLOCATE ( sizeof(HOM) );
	PCGRPDESC *g;
	
	/* skip id */
	p = p->next;
	a->g = g = code_to_pcgroup ( p );
	p = pp;

	numgen = g->defs ? g->min_gen : g->num_gen;
	a->h = NULL;
	a->auts = NINT; p = p->next;
	a->class1_generators = NINT; p = p->next;
	a->inn_log = NINT; p = p->next;
	a->out_log = NINT; p = p->next;
	a->only_normal_auts = NINT; p = p->next;
	a->with_inner = NINT; p = p->next;

	a->aut_gens_dim = tallocate ( (g->exp_p_class+1) * sizeof ( int ) );
	a->out_gens_dim = tallocate ( (g->exp_p_class+1) * sizeof ( int ) );
	a->aut_gens = tallocate ( (g->exp_p_class+1) * sizeof ( VEC* ) );
	a->epimorphism = NULL;

	a->stabs = NULL;

	for ( i = 1; i <= g->exp_p_class; i++,p=p->next )
		a->aut_gens_dim[i] = NINT;
	for ( i = 1; i <= g->exp_p_class; i++,p=p->next )
		a->out_gens_dim[i] = NINT;

	for ( i = 1; i <= g->exp_p_class; i++ ) {
		a->aut_gens[i] = tallocate ( a->aut_gens_dim[i] * sizeof ( VEC ) );
		for ( j = 0; j < a->aut_gens_dim[i]; j++ )
			a->aut_gens[i][j] = tallocate ( g->num_gen * numgen);
	}	
		
	for ( i = 1; i <= g->exp_p_class; i++ ) {
		for ( j = 0; j < a->aut_gens_dim[i]; j++ )
			for ( l = 0; l < g->num_gen * numgen; l++, p=p->next )
				a->aut_gens[i][j][l] = NINT;
	}
	a->elements = NINT;
	
	return ( a );
}

GRHOM *code_to_grhom ( DYNLIST p )
{
    return ( NULL );
}

void grhom_to_code ( GRHOM *a )
{
    return;
}

void gmodule_to_code ( GMODULE *gm, int bracket )
{
	int numgen;
	int dq, i, j;
	char *rec_prefx, *rec_postfx;
	
	numgen = gm->g->num_gen;
	dq = gm->dim * gm->dim;

	if ( displaystyle == GAP ) {
		rec_prefx = "SISYPHOS.GMODULE.code :=  [";
		rec_postfx = "];\n";
	}
	else {
		rec_prefx = "[";
		rec_postfx = "]\n";
	}
	if ( bracket )
	    printf ( "%s%d,\n", rec_prefx, GMODREC );
	else
	    printf ( "%d,\n", GMODREC );

	pcgroup_to_code ( gm->g, FALSE );	
	write_intlist ( gm->dim, FALSE, FALSE );

	for ( i = 0; i < numgen; i++ ) 
	    for ( j = 0; j < dq; j++ )
		   write_intlist ( gm->m[i][j], FALSE, FALSE );
	
	if ( gm->echelon != NULL ) {
	    for ( i = 0; i < numgen; i++ ) 
		   for ( j = 0; j < dq; j++ )
			  write_intlist ( gm->echelon[i][j], FALSE, FALSE );
	    for ( j = 0; j < dq; j++ )
		   write_intlist ( gm->T[j], FALSE, FALSE );
	    for ( j = 0; j < dq; j++ )
		   write_intlist ( gm->TI[j], FALSE, FALSE );
	}
	write_intlist ( -99, FALSE, bracket );
	if ( bracket )
	    printf ( "%s", rec_postfx );
}

GMODULE *code_to_gmodule ( DYNLIST p )
{
	int i, j, numgen;
	GMODULE *gm = ALLOCATE ( sizeof(GMODULE) );
	PCGRPDESC *g;
	int dq;
	
	/* skip id */
	p = p->next;
	gm->g = g = code_to_pcgroup ( p );
	p = pp;

	numgen = g->num_gen;
	gm->dim = NINT; p = p->next;
	dq = gm->dim * gm->dim;
	gm->T = gm->TI = NULL;
	gm->echelon = NULL;
	gm->m = tallocate ( numgen * sizeof ( VEC ) );
	for ( i = 0; i < numgen; i++ ) {
	    gm->m[i] = tallocate ( dq );
	    for ( j = 0; j < dq; j++ ) {
		   gm->m[i][j] = NINT;
		   p = p->next;
	    }
	}
	if ( NINT != -99 ) {
	    /* we have an echelonized basis */
	    gm->echelon = tallocate ( numgen * sizeof ( VEC ) );
	    for ( i = 0; i < numgen; i++ ) {
		   gm->echelon[i] = tallocate ( dq );
		   for ( j = 0; j < dq; j++ ) {
			  gm->echelon[i][j] = NINT;
			  p = p->next;
		   }
	    }
	    gm->T = tallocate ( dq );
	    gm->TI = tallocate ( dq );
	    for ( j = 0; j < dq; j++ ) {
		   gm->T[j] = NINT;
		   p = p->next;
	    }
	    for ( j = 0; j < dq; j++ ) {
		   gm->TI[j] = NINT;
		   p = p->next;
	    }
	}
	pp = p;
	return ( gm );
}

void cohomology_to_code ( COHOMOLOGY *cohomol )
{
	int len, i, j, numgen;
	char *rec_prefx, *rec_postfx;
	
	len = cohomol->module_dim;
	numgen = cohomol->gm->g->num_gen;

	if ( displaystyle == GAP ) {
		rec_prefx = "SISYPHOS.COHOMOLOGY.code :=  [";
		rec_postfx = "];\n";
	}
	else {
		rec_prefx = "[";
		rec_postfx = "]\n";
	}
	printf ( "%s%d,\n", rec_prefx, COHOMOLREC );
	gmodule_to_code ( cohomol->gm, FALSE );	
	write_intlist ( cohomol->degree, FALSE, FALSE );
	write_intlist ( cohomol->dim, FALSE, FALSE );
	write_intlist ( cohomol->z_dim, FALSE, FALSE );
	write_intlist ( cohomol->module_dim, FALSE, FALSE );
	
	for ( i = 0; i < cohomol->dim; i++ )
	    for ( j = 0; j < len*numgen; j++ )
		   write_intlist ( cohomol->basis[i][j], FALSE, FALSE );
	write_intlist ( -99, FALSE, TRUE );
	printf ( "%s", rec_postfx );
}

COHOMOLOGY *code_to_cohomology ( DYNLIST p )
{
	int i, j, numgen, len;
	COHOMOLOGY *cohomol = ALLOCATE ( sizeof(COHOMOLOGY) );
	GMODULE *gm;
	
	/* skip id */
	p = p->next;
	cohomol->gm = gm = code_to_gmodule ( p );
	p = pp;

	/* skip end marker */
	p = p->next;

	numgen = gm->g->num_gen;
	cohomol->degree = NINT; p=p->next;
	cohomol->dim = NINT; p=p->next;
	cohomol->z_dim = NINT; p=p->next;
	cohomol->module_dim  = len = NINT; p=p->next;

	cohomol->basis = tallocate ( cohomol->dim * sizeof ( VEC ) );
	for ( i = 0; i < cohomol->dim; i++ )
	    cohomol->basis[i] = tallocate ( len*numgen );
	for ( i = 0; i < cohomol->dim; i++ )
	    for ( j = 0; j < len*numgen; j++ ) {
		   cohomol->basis[i][j] = NINT;
		   p = p->next;
	    }
	pp = p;
	return ( cohomol );
}

/* end of module siscode */









