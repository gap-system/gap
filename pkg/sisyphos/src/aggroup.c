/* 	$Id: aggroup.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: aggroup.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:48:24  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:19:20  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: aggroup.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include <ctype.h>
#include "aglobals.h"
#include "pc.h"
#include	"aggroup.h"
#include "fdecla.h"
#include	"storage.h"
#include	"error.h"


ge_pair *get_normal_word 		_(( node n, int *len ));
symbol *find_symbol 			_(( char *symname ));
int is_id                          _(( PCELEM el ));
int ag_gauss 					_(( PCELEM *words, int nw  ));
void ag_centre                     _(( AGGRPDESC *ag_group ));
void sg_automorphisms              _(( AGGRPDESC *ag_group ));

extern int bperelem;

AGGRPDESC *aggroup = NULL;

int inc_ag ( PCELEM el, int len, int *powers )
{
	register int carry = TRUE;
	register int j = len;
	PCGEN x;
	
	while ( carry && j-- ) {
		x = el[j];
		carry = ( x == powers[j]-1 );
		el[j] =  carry ? 0 : ++x;
	}
	return ( !carry );
}

void ag_monom_write ( PCELEM el, AGGRPDESC *g )
{
	register int i;
	int exp;
	
	if ( is_id ( el ) )
		printf ( "1" );
	else {
		for ( i = 0; i < g->num_gen; i++ ) {
			exp = el[i];
			if ( exp == 1 )
				printf ( "%s", g->gen[i] );
			else if ( exp > 1 ) 
				printf ( "%s^%1d", g->gen[i], exp );
		}
	}
}

void print_ag_relations ( AGGRPDESC *g_desc )
{
	int i, j, k, cnr;
	PCELEM w;
	int bpe = bperelem;
	
	bperelem = g_desc->num_gen;
	PUSH_STACK();
	printf ( "\nrelations of group " );	
	if ( g_desc->group_name[0] != '\0' )
		printf ( "%s", g_desc->group_name );
	printf ( ":\n" );
	for ( i = 0; i < g_desc->num_gen; i++ ) {
		printf ( "%s^%1d = ", g_desc->gen[i], g_desc->powers[i]);
		w = IDEL ( g_desc );
		for ( k = 0; k < g_desc->p_len[i]; k++ )
			w[g_desc->p_list[i][k].g] = g_desc->p_list[i][k].e;

		ag_monom_write ( w, g_desc );
		printf ( "\n" );
	}
	for ( i = 1; i < g_desc->num_gen; i++ ) {
		for ( j = 0; j < i; j++ ) {
			cnr = CN ( i, j );
			w = IDEL ( g_desc );
			for ( k = 0; k < g_desc->c_len[cnr]; k++ )
				w[g_desc->c_list[cnr][k].g] = g_desc->c_list[cnr][k].e;
			if ( !is_id ( w ) ) {
				printf ( "[%s,%s] = ", g_desc->gen[i],
					g_desc->gen[j] );
				ag_monom_write ( w, g_desc );
				printf ( "\n" );
			}
		}
	}
	printf ( "\nconjugates:\n" );
	for ( i = 1; i < g_desc->num_gen; i++ ) {
		for ( j = 0; j < i; j++ ) {
			if ( g_desc->c_len[CN(i,j)] != 0 ) {
				cnr = CN ( i, j );
				w = IDEL ( g_desc );
				for ( k = 0; g_desc->conjugates[cnr][k].g != -1; k++ )
					w[g_desc->conjugates[cnr][k].g] = g_desc->conjugates[cnr][k].e;
				printf ( "%s^%s = ", g_desc->gen[i], g_desc->gen[j] );
				ag_monom_write ( w, g_desc );
				printf ( "\n" );
			}
		}
	}
	printf ( "minimal number of generators : %d\n", g_desc->min_gen );
	POP_STACK();
	bperelem = bpe;
}

void show_aggrpdesc ( AGGRPDESC *g )
{
	int i;
	
	printf ( "powers       : [" );
	for ( i = 0; i < g->num_gen-1; i++ )
		printf ( "%1d,", g->powers[i] );
	printf ( "%1d]\n", g->powers[g->num_gen-1] );
	printf ( "]\n" );
	printf ( "num_gen      : %4d\n", g->num_gen );
	printf ( "group_card   : %4d\n", g->group_card );
	printf ( "min_gen      : %4d\n", g->min_gen );
	if ( g->group_name[0] != '\0' )
		printf ( "group name   : %s\n",  g->group_name );
	printf ( "gen	     : [" );
	for ( i = 0; i < g->num_gen; i++ ) {
		printf ( "%s", g->gen[i] );
		if ( i != g->num_gen-1 )
			printf ( "," );
		else
			printf ( "]\n" );
	}
	printf ( "\n" );
	printf ( "avec         : [" );
	for ( i = 0; i < g->num_gen-1; i++ )
		printf ( "%1d,", g->avec[i] );
	printf ( "%1d]\n", g->avec[g->num_gen-1] );
	printf ( "length of el.ab. series  : %4d\n", g->elab_length );
	print_ag_relations ( g );
}

void get_ag_elab_series ( AGGRPDESC *g_desc )
{

	int i, j, l, c;
	int start, next, pot;
	int gens = g_desc->num_gen;
	
	g_desc->elab_series = ALLOCATE ( (gens+1) * sizeof ( FILT ) );

	i = 1;
	start = 0;

	while ( start < g_desc->num_gen ) {

		pot = g_desc->powers[start];

		next = start;
		while ( (g_desc->powers[next] == pot) && (next < gens) )
			next++;
			 
		if ( g_desc->p_len[start] != 0 )
			next = g_desc->p_list[start][0].g;
		
		for ( j = start+1; j < gens; j++ ) {
			c = CN ( j, start );
			if ( g_desc->c_len[c] != 0 ) {
				if ( g_desc->c_list[c][0].g < next )
					next = g_desc->c_list[c][0].g;
			}
		}
		if ( next ==  start )
			next = gens;
		
		g_desc->elab_series[i].i_start = start;
		g_desc->elab_series[i].i_end = next - 1;
		g_desc->elab_series[i].i_dim = next - start;
			
		start = next;
		i++;
	}
	g_desc->elab_series[i].i_start = gens;
	g_desc->elab_series[i].i_end = 0;
	g_desc->elab_series[i].i_dim = 0;
	
	g_desc->elab_length = i-1;
	l = (gens-i)*sizeof ( FILT );
	l -= (l % 4);
/*	SET_TOP ( GET_TOP() - l ); */

	g_desc->avec[gens-1] = gens;
	
	for ( i = gens-1; i--; ) {
		g_desc->avec[i] = g_desc->avec[i+1] == i+2 ? i+1 : g_desc->avec[i+1];
		for ( j = gens-1; j >= g_desc->avec[i+1] - 1; j-- ) {
			c = CN ( j, i );
			if ( g_desc->c_len[c] != 0 ) {
				g_desc->avec[i] = j + 1;
				break;
			}
		}
	}
				
}

AGGRPDESC *set_ag_group ( AGGRPDESC *ag_group )
{
	AGGRPDESC *oldaggroup;
	
	if ( ag_group == NULL )
		return ( aggroup );
		
	oldaggroup = aggroup;
	aggroup = ag_group;
	bperelem = ag_group->num_gen;
	return ( oldaggroup );
}

AGGRPDESC *grp_to_aggrp  ( GRPDSC *g_desc )
{
	int i, j, cnr, k;
	int finished, len;
	int pot = 0;
	int exp_rel = FALSE;
	int num = 0;
	ge_pair *pair_list;
	AGGRPDESC *ag_desc = ALLOCATE ( sizeof ( PCGRPDESC ) );
	AGGRPDESC *old_ag_group;
	PCELEM li, re, r;
	node c_node;

	ag_desc->num_gen = ag_desc->min_gen = g_desc->num_gen;

	ag_desc->gen = ALLOCATE ( g_desc->num_gen * sizeof ( char * ) );
	ag_desc->powers = CALLOCATE ( g_desc->num_gen * sizeof ( int ) );
	ag_desc->avec = CALLOCATE ( g_desc->num_gen * sizeof ( int ) );
	ag_desc->p_list = (ge_pair **)ALLOCATE ( g_desc->num_gen * sizeof ( ge_pair *) );
	ag_desc->p_len = (int *)ALLOCATE ( g_desc->num_gen * sizeof ( int ) );
	ag_desc->group_name[0] = '\0';
	cnr = ( g_desc->num_gen * ( g_desc->num_gen -1 ) ) >> 1;
	ag_desc->c_list = (ge_pair **)ALLOCATE ( cnr * sizeof ( ge_pair * ) );
	ag_desc->c_len = (int *)ALLOCATE ( cnr * sizeof ( int ) );
	ag_desc->conjugates = ALLOCATE ( cnr * sizeof ( ge_pair * ) );
	ag_desc->group_card = 1;
	ag_desc->def_list = ALLOCATE ( ag_desc->num_gen * sizeof ( GENDEF ) );
	for ( i = 0; i < g_desc->num_gen; i++ ) {
		ag_desc->gen[i] = ALLOCATE ( strlen ( g_desc->gen[i] ) );
		strcpy ( ag_desc->gen[i], g_desc->gen[i] );
	}	

	/* get relations */
	
	/* initialize conjugates with  */
	for ( i = 1; i < g_desc->num_gen; i++ ) {
		for ( j = 0; j < i; j++ ) {
			ag_desc->c_list[CN(i,j)] = NULL;
			ag_desc->c_len[CN(i,j)] = 0;
		}
	}

	for ( i = 0; i < g_desc->num_rel; i++ ) {
		c_node = g_desc->rel_list[i];
		finished = FALSE;
		pair_list = NULL;
		len = 0;
		while ( !finished ) {
			if ( c_node->nodetype == EQ ) {
				pair_list = get_normal_word ( c_node->right, &len );
				c_node = c_node->left;
			}
			else if ( c_node->nodetype == EXP ) {
				num = c_node->left->value;
				pot = c_node->value;
				exp_rel = TRUE;
				finished = TRUE;
			}
			else if ( c_node->nodetype == COMM ) {
				num = CN ( c_node->left->value, c_node->right->value );
				exp_rel = FALSE;
				finished = TRUE;
			}
			else
				set_error ( INV_PC_REL );
		}
		if ( exp_rel ) {
			ag_desc->p_list[num] = pair_list;
			ag_desc->p_len[num] = len;
			ag_desc->powers[num] = pot;
			ag_desc->group_card *= pot;
		}
		else {
			ag_desc->c_list[num] = pair_list;
			ag_desc->c_len[num] = len;
		}			
	}

	get_ag_elab_series ( ag_desc );

	/* compute conjugates */
	old_ag_group = aggroup;
	set_ag_group ( ag_desc );
	
	li = CALLOCATE ( bperelem );
	re = CALLOCATE ( bperelem );
	for ( i = bperelem; i--; ) {
		for ( j = i-1; j >= 0; j-- ) {
			cnr = CN ( i, j );
			if ( aggroup->c_len[cnr] == 0 ) {
				ag_desc->conjugates[cnr] = ALLOCATE ( 2 * sizeof ( ge_pair ) );
				ag_desc->conjugates[cnr][0].g = i;
				ag_desc->conjugates[cnr][0].e = 1;
				ag_desc->conjugates[cnr][1].e = ag_desc->conjugates[cnr][1].g = -1;
			}
			else {
				zero_vector ( li, bperelem );
				zero_vector ( re, bperelem );
				li[i] = 1;
				for ( k = 0; k < aggroup->c_len[cnr]; k++ )
					re[aggroup->c_list[cnr][k].g] = aggroup->c_list[cnr][k].e;
				r = agcollect ( li, re );
				len = 0;
				for ( k = 0; k < bperelem; k++ )
					if ( r[k] != 0 ) len++;
				ag_desc->conjugates[cnr] = ALLOCATE ( (len+1) * sizeof ( ge_pair ) );
				len = 0;
				for ( k = 0; k < bperelem; k++ ) {
					if ( r[k] != 0 ) {
						ag_desc->conjugates[cnr][len].g = k;
						ag_desc->conjugates[cnr][len++].e = r[k];
					}
				}
				ag_desc->conjugates[cnr][len].e = ag_desc->conjugates[cnr][len].g = -1;
			}
		}
	}
	
	set_ag_group ( old_ag_group );
	
	num = ag_desc->num_gen;
	ag_desc->nom = ALLOCATE ( num * sizeof ( PCELEM ) );
	for ( i = 0; i < num; i++ ) {
		ag_desc->nom[i] = IDEL ( ag_desc );
		set_el ( ag_desc->nom[i], i, 1 );
	}

	ag_desc->autg = NULL;
	
/*	get_ag_elab_series ( ag_desc ); */

	return ( ag_desc );		
}

PCELEM agcollect ( PCELEM li, PCELEM r )
{
	ge_pair *u_ge_pair;
	register int len, ug, xr, nmv, sp, j;
	int b;
	int stksize;
	ge_pair **wstk, **ostk;
	int *kstk, *jstk;
	PCELEM p, u;
	
	u = CALLOCATE ( bperelem );
	copy_vector ( li, u, bperelem );

	PUSH_STACK();
	sp = 0;
	u_ge_pair = ALLOCATE((bperelem+1) * sizeof ( ge_pair ) );
	len = 0;
	for ( j = 0; j < bperelem; j++ )
		if ( (b = r[j]) != 0 ) {
			u_ge_pair[len].g = j;
			u_ge_pair[len++].e = b;
		}
	u_ge_pair[len].g = u_ge_pair[len].e = -1;

	if ( len == 0 ) {
		POP_STACK();
		return ( u );
	}

	stksize = bperelem * (bperelem+1) >> 1;
	wstk = ARRAY ( stksize, ge_pair* );
	ostk = ARRAY ( stksize, ge_pair* );
	kstk = ARRAY ( stksize, int );
	jstk = ARRAY ( stksize, int );
	sp = 0;
	
	*wstk = *ostk = u_ge_pair;
	*jstk = 1;
	*kstk = u_ge_pair[0].e;
	
	while ( sp >= 0 ) {
		ug = (**ostk).g;
		if ( ug == -1 )
			sp--, wstk--, ostk--, kstk--;
		else {
			*kstk -= AVEC[ug] == ug + 1 ? (nmv = *kstk) : (nmv = 1);
			if ( ! *kstk ) {
				++*ostk;
				if ( (**ostk).g == -1 ) {
					if ( --*jstk > 0 ) {
						*ostk = *wstk;
						*kstk = (**wstk).e;
					}
					else
						sp--, wstk--, ostk--, kstk--, jstk--;
				}
				else
					*kstk = (**ostk).e;
			}
			for ( xr = AVEC[ug] -1, p = u+xr; xr > ug; xr--, p-- ) {
				if ( *p ) {
					sp++, wstk++, ostk++, kstk++, jstk++;
					*wstk = *ostk = CONJUGATES[CN(xr,ug)];
					*kstk = (**ostk).e;
					*jstk = *p;
					*p = 0;
				}
			}
			*p += nmv;
			if ( *p < POWERS[ug] )
				continue;
			*p -= POWERS[ug];
			if ( POTS[ug] != NULL ) {
				sp++, wstk++, ostk++, kstk++, jstk++;
				*wstk = *ostk = POTS[ug];
				*kstk = (**ostk).e;
				*jstk = 1;
			}
		}
	}
	POP_STACK();
	return ( u );
}

void test_ag (void)
{
	symbol *s;
	
	s = find_symbol ( "g" );
	set_ag_group ( (AGGRPDESC *)s->object );
	
/*	words = ARRAY ( 2, PCELEM );
	words[0] = AIDENTITY;
	words[1] = AIDENTITY;
	
	words[0][0] = words[0][2] = words[1][1] = words[1][2] = 1;
	
	printf ( "Rang: %d\n", ag_gauss ( words, 2 ) ); */
	ag_centre ( aggroup );
	sg_automorphisms ( aggroup );
/*	li = CALLOCATE ( bperelem );
	re = CALLOCATE ( bperelem );
	do {
		zero_vector ( re, bperelem );
		do {
			PUSH_STACK();
			ag_monom_write ( li, aggroup );
			printf ( " * " );
			ag_monom_write ( re, aggroup );
			printf ( " = " );
			r = agcollect ( li, re );
			ag_monom_write ( r, aggroup );
			printf ( "\n" );
			POP_STACK();
		} while ( inc_ag ( re, aggroup ) );
	} while ( inc_ag ( li, aggroup ) ); */
}				

PCELEM ag_invers ( register PCELEM el )
{
	PCELEM res = AIDENTITY;
	register PCELEM h, m, r;
	int i, pow;

/*	old_class = set_group_quotient ( 0 ); */
	PUSH_STACK();
	r = AIDENTITY;
	h = AIDENTITY;
	m = AIDENTITY;
	copy_vector ( el, h, bperelem );
	
	do {
		pow = 0;
		for ( i = bperelem; i--;  ) {
			if ( (pow=h[i]) != 0 ) {
				break;
			}
		}
		
		zero_vector ( m, bperelem );
		m[i] = (pow == 0) ?  0 : POWERS[i] - pow;
		h = agcollect (  h, m );
		r = agcollect (  r, m );
	} while ( pow != 0 );
	
	copy_vector ( r, res, bperelem );
	POP_STACK();
/*	set_group_quotient ( old_class ); */
	return ( res );
}

PCELEM ag_comm ( PCELEM li, PCELEM re )
{
	PCELEM res = AIDENTITY;
	PCELEM h1, h2;
	
	PUSH_STACK();
	h1 = ag_invers ( li );
	h2 = ag_invers ( re );
	h1 = agcollect ( h1, h2 );
	h2 = agcollect ( li, re );
	copy_vector ( agcollect ( h1, h2 ), res, bperelem );
	POP_STACK();
	return ( res );
}

PCELEM ag_expo ( register PCELEM el, register int power ){
	register int i = 4096;
	PCELEM res = AIDENTITY;
	PCELEM h;
	
	PUSH_STACK();
	copy_vector ( el, res, bperelem );
	h = res;
	while ( !(power & i ) ) i >>= 1;
	while ( (i >>= 1) != 0 ) {
		h = agcollect ( h, h );
		if ( power & i )
			h = agcollect ( h, el );
	}
	copy_vector ( h, res, bperelem );
	POP_STACK();
	return ( res );
}
