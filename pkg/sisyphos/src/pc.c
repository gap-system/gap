/********************************************************************/
/*  Module        : PC group                                        */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies the routines needed to compute in pc presented      */
/*     groups.                                                      */
/*                                                                  */
/********************************************************************/

/* 	$Id: pc.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: pc.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.5  1997/05/02 09:33:06  pluto
 * 	Removed superfluous line in conv_rel.
 *
 * 	Revision 3.4  1995/12/15 10:06:16  pluto
 * 	Changed order of arguments in call to 'strcpy' in 'conv_rel'.
 *
 * 	Revision 3.3  1995/12/12 17:14:14  pluto
 * 	Corrected copying of generator names in 'conv_rel'.
 *
 * 	Revision 3.2  1995/08/10 16:03:22  pluto
 * 	Added additional parameters to 'pcgroup_to_gap'.
 *
 * 	Revision 3.1  1995/08/10 11:53:15  pluto
 * 	Added routine 'pcgroup_to_gap'.
 *
 * 	Revision 3.0  1995/06/23 09:35:04  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  16:54:01  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: pc.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#include <ctype.h>
#include "aglobals.h"
#include "graut.h"
#include "aut.h"
#include "pc.h"
#include "fdecla.h"
#include "storage.h"
#include "parsesup.h"
#include "error.h"

extern int prime;
int s_int = (int)sizeof ( int );
extern PCGRPDESC *group_desc;
extern DSTYLE presentation_type;
extern FILE *pres_file;

/* parameters of the representation of a pc element */

extern VEC *vector;

int pc_automorphisms 			_(( int with_inner, int use_gl, int t_g_ngen, int t_h_ngen,
							 int t_num_rel, int t_min_gen ));
void parse_presentation 			_(( FILE *in_file, GRPDSC *g_desc ));
void get_pc_weights 			_(( PCGRPDESC *g_desc ));
int set_group_quotient			_(( int class ));
void add_string 				_(( vtype it, int len , int exp ));
PCELEM ge_pair_to_exp_vec 		_(( ge_pair *vec, int len ));
void get_definitions 			_(( PCGRPDESC *g_desc ));
void sc_monom_write 			_(( PCELEM el, PCGRPDESC *g ));
void normalize_presentation 		_(( PCGRPDESC *g_desc ));
static PCELEM calc_image 		_(( VEC r, node p ));
void n_expand 					_(( node p ));
PCELEM image_of_generator 		_(( VEC r, int g ));
void output_prae                   _(( int len, int start, int unitgrp,
							    int mod_id, char *name ));
void output_post                   _(( int len, int start, int def_gens,
							    char *name ));
void output_relation               _(( VEC index, int e1, int e2, int is_pow,
							    int len, int start ));
static cstack_item cstack[2048];
static int sp = 0;
/* static int msp = 0; */

#define PUSH_STR(val,l,e)		{sp++; cstack[sp].type.pair_vec = val;\
							cstack[sp].len = -l;\
							cstack[sp].exp = e;}
/*							if ( sp > msp ) {\
							msp = sp;\
							printf ( "msp : %d\n", msp );}} */

#define PUSH_GEN(val,l,e)		{sp++; cstack[sp].type.gen = val;\
							cstack[sp].len = l;\
							cstack[sp].exp = e;}
/*							if ( sp > msp ) {\
							msp = sp;\
							printf ( "msp : %d\n", msp );}}*/

#define PR_WEIGHT(i,j)			g_desc->pc_weight[g_desc->p_list[i][j].g]
#define CR_WEIGHT(i,j)			g_desc->pc_weight[g_desc->c_list[i][j].g]
#define EPWEIGHT(i)				group_desc->pc_weight[i]
									
int bperelem = 0;
int exp_p_class = 0;
int beginlastclass = 0;
int **ap_len;
int **ac_len;
static int *p_len;
static int *c_len;
static PCELEM u;

int set_group_quotient ( int class )
{
	int last_class = exp_p_class;
	
	if ( class >  0 ) {
		exp_p_class = class;
		beginlastclass = EXP_P_LCS[class].i_start;
		bperelem = EXP_P_LCS[class].i_end+1;
		if ( class < EXP_P_CLASS ) {
			p_len = ap_len[class];
			c_len = ac_len[class];
		}
		else {
			p_len = group_desc->p_len;
			c_len = group_desc->c_len;
		}
	}
	return ( last_class );
}	

ge_pair *exp_vec_to_ge_pair ( PCELEM el, int *size )
{
	int i, j, exp;
	ge_pair *pair;
	
	pair = ALLOCATE((bperelem+1) * sizeof ( ge_pair ) );
	j = 0;
	for ( i = 0; i < bperelem; i++ )
		if ( (exp = el[i]) != 0 ) {
			pair[j].g = i;
			pair[j].e = exp;
			j++;
		}
	*size = j;
	pair[j].g = pair[j].e = -1;
	return ( pair );
}

PCELEM ge_pair_to_exp_vec ( ge_pair *vec, int len )
{
	register int i;
	PCELEM el = IDENTITY;
	
	for ( i = 0; i < len; i++ )
		el[vec[i].g] = vec[i].e;
	return ( el );
}

int len_gep ( ge_pair *p )
{
	register int l = 0;
	
	while ( ((*p).g != -1) && ((*p).g < bperelem) ) {
		l++;
		p++;
	}
	return ( l );
}

PCELEM monom_mul ( PCELEM li, PCELEM r )
{
	ge_pair *u_ge_pair;
	register int len, j, g, b, k, l, f;
	register int cexp, cgen;
	register unsigned long lv;
	vtype nit;
	
	/* Step 0 : initialize */
	
	u = IDENTITY;
	copy_vector ( li, u, bperelem );
	PUSH_STACK();
	sp = 0;
	u_ge_pair = ALLOCATE(bperelem * sizeof ( ge_pair ) );
	len = 0;
	for ( j = 0; j < bperelem; j++ )
		if ( (b = r[j]) != 0 ) {
			u_ge_pair[len].g = j;
			u_ge_pair[len++].e = b;
		}
	if ( len == 0 ) {
		POP_STACK();
		return ( u );
	}
	PUSH_STR ( u_ge_pair, len, 1 );
	
	/* Step 1 : Process next triple on the stack */
	while ( sp > 0 ) {
		
		/* fetch triple from stack */
		if ( cstack[sp].len > 0 ) { /* x_i^exp */
			cgen = cstack[sp].type.gen;
			cexp = cstack[sp--].exp;
			if ( (EPWEIGHT ( cgen ) << 1) > exp_p_class ) {
				nit.gen = cgen;
				add_string ( nit, 1, cexp );
				continue;
			}
		}
		else { /* string of ge-pairs */
			nit.pair_vec = cstack[sp].type.pair_vec;
			cgen = nit.pair_vec[0].g;
			cexp = nit.pair_vec[0].e;
			k = cstack[sp].exp;
			l = -cstack[sp--].len;
			if ( (EPWEIGHT ( cgen ) << 1) > exp_p_class ) {
				add_string ( nit, -l, k );
				continue;
			}
			if ( l > 1 ) {
				cstack[++sp].type.pair_vec++;
				cstack[sp].len++;
			}
		}

		j = exp_p_class-EPWEIGHT(cgen);
		f = EXP_P_LCS[j].i_end;

		if ( 3*EPWEIGHT ( cgen ) > exp_p_class ) {
			/* Step 6 : Collect X_cgen^cexp without stacking entries */
			for ( g = f; g > cgen; g-- ) {
				nit.pair_vec = group_desc->c_list[CN(g,cgen)];
				if ( ((b=u[g]) !=0) && (nit.pair_vec != NULL) ) {
					add_string ( nit, -c_len[CN(g,cgen)], cexp*b );
				}
			}
			lv = u[cgen];
			lv += cexp;
			u[cgen] = lv % prime;
			if ( ((j = lv / prime) > 0) && (group_desc->p_list[cgen] != NULL) ) {
				for ( g = f; g > cgen; g-- ) {
					if ( (b=u[g]) != 0 ) {
						u[g] = 0;
						PUSH_GEN ( g, 1, b );
					}
				}
				PUSH_STR ( group_desc->p_list[cgen], p_len[cgen], j );
			}
			continue;
		}
		
		/* Step 2 : Combinatorial collection of x_cgen^cexp */

		l = (j >> 1);
		l = EXP_P_LCS[l].i_end;
			
		if ( cexp > 1 ) {
			PUSH_GEN ( cgen, 1, cexp-1 );
			cexp = 1;
		}
		
		for ( g = f; g > cgen; g-- ) {
			if ( (b=u[g]) != 0 ) {
				if (  (nit.pair_vec=group_desc->c_list[CN(g,cgen)]) != NULL ) {
					if ( g <= l )
						break; 
					add_string ( nit, -c_len[CN(g,cgen)], b );
				}
			}
		}
		
		if ( g == cgen ) {
			if ( u[g] == prime-1 ) {
				if ( group_desc->p_list[g] == NULL ) {
					u[g] = 0;
					continue;
				}
			}
			else {
				++u[g];
				continue;
			}
		}
		
		for ( k = f; k > g; k-- ) {
			if ( (b=u[k]) != 0 ) {
				u[k] = 0;
				PUSH_GEN ( k, 1, b );
			}
		}
		

		/* Step 3 : Ordinary collection of x_cgen^cexp */
		for ( ; g > cgen; g-- ) {
			if ( (b=u[g]) != 0 ) {
				u[g] = 0;
				if ( group_desc->c_list[CN(g,cgen)] == NULL ) {
					PUSH_GEN ( g, 1, b );
				}
				else {
					if ( cexp > 1 ) {
						PUSH_GEN ( cgen, 1, cexp-1 );
						cexp = 1;
					}
					for ( j = 1; j <= b; j++ ) {
						PUSH_STR ( group_desc->c_list[CN(g,cgen)],
							c_len[CN(g,cgen)], 1 );
						PUSH_GEN ( g, 1, 1 );
					}
				}
			}
		}

		/* Step 4 : add to cgen-th entry of exponent vector */
		nit.gen = cgen;
		add_string ( nit, 1, 1 );
	}
	POP_STACK();
	return ( u );
}

void collect ( PCELEM li, GEP r )
{
	GEP gep;
	register int len, j, g, b, k, l, f;
	register int cexp, cgen;
	register unsigned long lv;
	register char *bc;
	int wg, hw, tw;
	vtype nit;
	
	/* Step 0 : initialize */
	
	PUSH_STACK();
	u = li;
	sp = 0;
	if ( (len = len_gep ( r )) == 0 ) {
		POP_STACK();
		return;
	}
	PUSH_STR ( r, len, 1 );
	
	hw = exp_p_class >> 1;
	tw = exp_p_class / 3;
	
	/* Step 1 : Process next triple on the stack */
	while ( sp > 0 ) {
		
		/* fetch triple from stack */
		if ( cstack[sp].len > 0 ) { /* x_i^exp */
			cgen = cstack[sp].type.gen;
			cexp = cstack[sp--].exp;
			wg = EPWEIGHT ( cgen );
			if ( wg > hw ) {
				nit.gen = cgen;
				add_string ( nit, 1, cexp );
				continue;
			}
		}
		else { /* string of ge-pairs */
			nit.pair_vec = cstack[sp].type.pair_vec;
			cgen = nit.pair_vec[0].g;
			cexp = nit.pair_vec[0].e;
			k = cstack[sp].exp;
			l = -cstack[sp--].len;
			wg = EPWEIGHT ( cgen );
			if ( wg > hw ) {
				add_string ( nit, -l, k );
				continue;
			}
			if ( l > 1 ) {
				cstack[++sp].type.pair_vec++;
				cstack[sp].len++;
			}
		}

		j = exp_p_class-wg;
		f = EXP_P_LCS[j].i_end;

		if ( wg > tw ) {
			/* Step 6 : Collect X_cgen^cexp without stacking entries */
			for ( g = f; g > cgen; g-- ) {
				k = CN(g,cgen);
				nit.pair_vec = group_desc->c_list[k];
				if ( ((b=u[g]) !=0) && (nit.pair_vec != NULL) ) {
					add_string ( nit, -c_len[k], cexp*b );
				}
			}
			lv = u[cgen];
			lv += cexp;
			u[cgen] = lv % prime;
			if ( ((j = lv / prime) > 0) && (group_desc->p_list[cgen] != NULL) ) {
				for ( g = f,bc=u+g; g > cgen; g--,bc-- ) {
					if ( *bc != 0 ) {
						PUSH_GEN ( g, 1, *bc );
						*bc = 0;
					}
				}
				PUSH_STR ( group_desc->p_list[cgen], p_len[cgen], j );
			}
			continue;
		}
		
		/* Step 2 : Combinatorial collection of x_cgen^cexp */

		l = (j >> 1);
		l = EXP_P_LCS[l].i_end;
			
		if ( cexp > 1 ) {
			PUSH_GEN ( cgen, 1, cexp-1 );
			cexp = 1;
		}
		
		for ( g = f,bc = u+g; g > cgen; g--,bc-- ) {
			if ( *bc != 0 ) {
				k = CN(g,cgen);
				if (  (nit.pair_vec=group_desc->c_list[k]) != NULL ) {
					if ( g <= l )
						break; 
					add_string ( nit, -c_len[k], *bc );
				}
			}
		}
		
		if ( g == cgen ) {
			if ( *bc == prime-1 ) {
				if ( group_desc->p_list[g] == NULL ) {
					*bc = 0;
					continue;
				}
			}
			else {
				++(*bc);
				continue;
			}
		}
		
		for ( k = f,bc=u+k; k > g; k--,bc-- ) {
			if ( *bc != 0 ) {
				PUSH_GEN ( k, 1, *bc );
				*bc = 0;
			}
		}
		

		/* Step 3 : Ordinary collection of x_cgen^cexp */
		for ( bc=u+g; g > cgen; g--,bc-- ) {
			if ( *bc != 0 ) {
				if ( group_desc->c_list[CN(g,cgen)] == NULL ) {
					PUSH_GEN ( g, 1, *bc );
				}
				else {
					if ( cexp > 1 ) {
						PUSH_GEN ( cgen, 1, cexp-1 );
						cexp = 1;
					}
					k = CN(g,cgen);
					len = c_len[k];
					gep = group_desc->c_list[k];
					for ( j = 1; j <= *bc; j++ ) {
						PUSH_STR ( gep, len, 1 );
						PUSH_GEN ( g, 1, 1 );
					}
				}
				*bc = 0;
			}
		}

		/* Step 4 : add to cgen-th entry of exponent vector */
		nit.gen = cgen;
		add_string ( nit, 1, 1 );
	}
	POP_STACK();
}

void add_string ( vtype it, int len , int exp )
{
	register int j;
	register int b;
	register int cgen;
	register int cexp;
	register unsigned long lv;
	register ge_pair *gep;
	vtype nit;
	

	if ( len > 0 ) {
		/* Step 4 : add to cgen-th entry of exponent vector */

		cgen = it.gen;
		b = u[cgen] + exp;
		u[cgen] = b % prime;
		if ( cgen < beginlastclass ) {
			if ( ((j = b / prime) > 0) && ( (nit.pair_vec=group_desc->p_list[cgen]) != NULL) )
				add_string ( nit, -p_len[cgen], j );
		}
	}
	else {
		/* Step 5 : Add word to exponent vector */
		
		len = -len;
		for ( j = 0,gep = it.pair_vec; j < len; j++,gep++ ) {
			cexp = (*gep).e;
			cgen = (*gep).g;
			lv = u[cgen] + cexp * exp;
			u[cgen] = lv % prime;
			if ( cgen < beginlastclass ) {
				if ( ((b = lv / prime) > 0) && ( (nit.pair_vec=group_desc->p_list[cgen]) != NULL) )
					add_string ( nit, -p_len[cgen], b );
			}
		}
	}
}

void or_el ( PCELEM el1, PCELEM el2 )
{
	register int i;
	for ( i = bperelem; i--; )
		el2[i] |= el1[i];
}

int is_id ( PCELEM el )
{
	register int i;
	
	for ( i = 0; i < bperelem; i++ ) {
		if ( el[i] != 0 ) 
			return ( FALSE );
	}
	return ( TRUE );
	
}

int inc_count ( VEC coeff, int last )
{
	register int carry = TRUE;
	register int j = last;
	char x;

	while ( carry && j-- ) {
		x = coeff[j];
		carry = ( x == prime-1 );
		coeff[j] = carry ? 0 : ++x;
	}
	return ( !carry );
}

int inc_el ( PCELEM el )
{
	register int carry = TRUE;
	register int j = bperelem;
	PCGEN x;
	
	while ( carry && j-- ) {
		x = el[j];
		carry = ( x == prime-1 );
		el[j] =  carry ? 0 : ++x;
	}
	return ( !carry );
}

PCELEM og_invers ( register PCELEM el )
{
	PCELEM res = IDENTITY;
	register PCELEM l, i;
	
	if ( !is_id ( el ) ) {
		PUSH_STACK();
		i = l = el;
		while ( !is_id ( i = g_expo ( i, GPRIME ) )  ) {
			l = monom_mul ( i, l );
		}
		i = g_expo ( l, GPRIME-1 );
		copy_vector ( i, res, bperelem );
		POP_STACK();
	}
	return ( res );
}
		
PCELEM g_invers ( register PCELEM el )
{
	PCELEM res = IDENTITY;
	register PCELEM h;
	GEP elgep;
	int i, j, k;
	int old_class;

	old_class = set_group_quotient ( 0 );
	PUSH_STACK();
	h = IDENTITY;
	copy_vector ( el, h, bperelem );
	elgep = ARRAY ( bperelem+1, ge_pair );
	for ( i = 1; i < old_class; i++ ) {
		k = 0;
		for ( j = EXP_P_LCS[i].i_start; j <= EXP_P_LCS[i].i_end; j++ ) {
			if ( h[j] != 0 ) {
				elgep[k].e = res[j] = GPRIME - h[j];
				elgep[k++].g = j;
			}
		}
		elgep[k].g = elgep[k].e = -1;
		collect ( h, elgep );
	}
	for ( j = EXP_P_LCS[old_class].i_start; j <= EXP_P_LCS[old_class].i_end; j++ ) {
		if ( h[j] != 0 )
			res[j] = GPRIME - h[j];
	}
	
	POP_STACK();
	set_group_quotient ( old_class );
	return ( res );
}

PCELEM g_expo ( register PCELEM el, register int power )
{
	register int i = 4096;
	int dummy;
	PCELEM res = IDENTITY;
	GEP elgep, hgep;
	
	PUSH_STACK();
	copy_vector ( el, res, bperelem );
	elgep = exp_vec_to_ge_pair ( el, &dummy );
	while ( !(power & i ) ) i >>= 1;
	while ( (i >>= 1) != 0 ) {
		hgep = exp_vec_to_ge_pair ( res, &dummy );
		collect ( res, hgep );
		if ( power & i )
			collect ( res, elgep );
	}
	POP_STACK();
	return ( res );
}

PCELEM g_comm ( PCELEM el, PCELEM er )
{
	PCELEM cp1, cp2, cp3, cp4, res;
	GEP h;
	int i;
	int r, exp;
	
	res = IDENTITY;
	PUSH_STACK();
	cp1 = IDENTITY;
	cp2 = IDENTITY;
	cp3 = IDENTITY;
	cp4 = IDENTITY;
	
	copy_vector ( er, cp1, bperelem );
	copy_vector ( er, cp4, bperelem );
	copy_vector ( el, cp2, bperelem );
	copy_vector ( el, cp3, bperelem );
	
	for ( i = 0; i < bperelem; i++ ) {
		r = cp3[i] + cp4[i] - ( cp1[i] + cp2[i] );
		while ( r < 0 ) r += prime;
		r %= prime;
		
		res[i] = r;
		
		if ( cp4[i] != 0 ) {
			SGEP ( h, i, cp4[i] ); 
			collect ( cp3, h );
			cp3[i] = 0;
		}
		
		exp = cp2[i] + r;
		while ( exp < 0 ) exp += prime;
		exp %= prime;
		
		if ( cp2[i] + r >= prime )
			cp2[i] = prime - r;
		if ( r != 0 ) {
			SGEP ( h, i, r );
			collect ( cp2, h );
		}
		
		if ( cp1[i] + exp >= prime )
			cp1[i] = prime - exp;
		if ( exp != 0 ) {
			SGEP ( h, i, exp );
			collect ( cp1, h );
		}
	}
	POP_STACK();
	return ( res );
}

/* wrapper functions */

GE *ge_mul ( GE *l, GE *r )
{
    GE *res;
    PCGRPDESC *old_pc_group;
    
    if ( l->g != r->g )
	   return ( NULL );
    res = ALLOCATE ( sizeof ( GE ) );
    res->g = l->g;
    old_pc_group = group_desc;
    set_main_group ( l->g );
    res->el = monom_mul ( l->el, r->el );
    set_main_group ( old_pc_group );
    return ( res );
}

GE *ge_exp ( GE *l, int power )
{
    GE *res;
    PCGRPDESC *old_pc_group;

    res = ALLOCATE ( sizeof ( GE ) );
    res->g = l->g;
    old_pc_group = group_desc;
    set_main_group ( l->g );
    
    if ( power < 0 ) {
		res->el = g_expo ( l->el, -power );
		res->el = g_invers ( res->el );
    }
    else
	   res->el = g_expo ( l->el, power );
    set_main_group ( old_pc_group );
    return ( res );
}

GE *ge_inv ( GE *l )
{
    GE *res;
    PCGRPDESC *old_pc_group;

    res = ALLOCATE ( sizeof ( GE ) );
    res->g = l->g;
    old_pc_group = group_desc;
    set_main_group ( l->g );
    res->el = g_invers ( l->el );
    set_main_group ( old_pc_group );
    return ( res );
}

GE *ge_comm ( GE *l, GE *r )
{
    GE *res;
    PCGRPDESC *old_pc_group;

    if ( l->g != r->g )
	   return ( NULL );
    res = ALLOCATE ( sizeof ( GE ) );
    res->g = l->g;
    old_pc_group = group_desc;
    set_main_group ( l->g );
    res->el = g_comm ( l->el, r->el );
    set_main_group ( old_pc_group );
    return ( res );
}

int g_order ( register PCELEM el )
{
	register PCELEM i;
	register int order = 1;
	
	PUSH_STACK();
	i = IDENTITY;
	copy_vector ( el, i, bperelem );
	while ( !is_id ( i ) ) {
		i = g_expo ( i, prime );
		order *= prime;
	}
	POP_STACK();
	return ( order );
}

int log_g_order ( register PCELEM el )
{
	register PCELEM i;
	register int lorder = 0;
	
	PUSH_STACK();
	i = IDENTITY;
	copy_vector ( el, i, bperelem );
	while ( !is_id ( i ) ) {
		i = g_expo ( i, prime );
		lorder++;
	}
	POP_STACK();
	return ( lorder );
}

void sc_monom_write ( PCELEM el, PCGRPDESC *g )
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

void print_gr_relations ( PCGRPDESC *g_desc )
{
	int i, j, k, cnr;
	PCELEM w;
	PCGRPDESC *old_pc_group;
	
	old_pc_group = group_desc;
	set_main_group ( g_desc );
	set_group_quotient ( g_desc->exp_p_class );
		
	PUSH_STACK();
	printf ( "\nrelations of group " );	
	if ( g_desc->group_name[0] != '\0' )
		printf ( "%s", g_desc->group_name );
	printf ( ":\n" );
	for ( i = 0; i < g_desc->num_gen; i++ ) {
		printf ( "%s^%1d = ", g_desc->gen[i], g_desc->prime );
		w = IDEL ( g_desc );
		for ( k = 0; k < g_desc->p_len[i]; k++ )
			w[g_desc->p_list[i][k].g] = g_desc->p_list[i][k].e;

		sc_monom_write ( w, g_desc );
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
				sc_monom_write ( w, g_desc );
				printf ( "\n" );
			}
		}
	}
	printf ( "minimal number of generators : %d\n", g_desc->min_gen );
	POP_STACK();
	set_main_group ( old_pc_group );
}

ge_pair *get_normal_word ( node n, int *len )
{
	ge_pair *pair;
	int i;
	node p;
	
	*len = 0;
	if ( n == NULL )
		return ( NULL );

	p = n;
	for ( p = n; p != NULL; p = p->left )
		if ( p->nodetype == MULT ) (*len)++;
	(*len)++;
	pair = (ge_pair *)ALLOCATE((*len+1) * sizeof ( ge_pair ) );
	
	i = (*len) - 1 ;
	pair[*len].g = pair[*len].e = -1;
	for ( p = n; p->nodetype == MULT; p = p->left ) {
		if ( p->right->nodetype == EXP ) {
			pair[i].e = p->right->value;
			pair[i].g = p->right->left->value;
		}
		else {
			pair[i].e = 1;
			pair[i].g = p->right->value;
		}
		i--;
	}
	if ( p->nodetype == EXP ) {
		pair[0].e = p->value;
		pair[0].g = p->left->value;
	}
	else {
		pair[0].e = 1;
		pair[0].g = p->value;
	}
	return ( pair );
}

PCGRPDESC *grp_to_pcgrp  ( GRPDSC *g_desc )
{
	int i, j, cnr;
	int finished, len;
	int exp_rel = FALSE;
	int num = 0;
	ge_pair *pair_list;
	PCGRPDESC *pc_desc = ALLOCATE ( sizeof ( PCGRPDESC ) );
	node c_node;

	prime = pc_desc->prime = g_desc->prime;
	swap_arith ( g_desc->prime );
	pc_desc->num_gen = g_desc->num_gen;

	pc_desc->max_id = 0;
	pc_desc->gen = ALLOCATE ( g_desc->num_gen * sizeof ( char * ) );
	pc_desc->g_max = CALLOCATE ( g_desc->num_gen * sizeof ( int ) );
	pc_desc->g_ideal = CALLOCATE ( g_desc->num_gen * sizeof ( int ) );
	pc_desc->image = CALLOCATE ( g_desc->num_gen * sizeof ( int ) );
	pc_desc->pimage = CALLOCATE ( g_desc->num_gen * sizeof ( int ) );
	pc_desc->p_list = (ge_pair **)ALLOCATE ( g_desc->num_gen * sizeof ( ge_pair *) );
	pc_desc->p_len = (int *)ALLOCATE ( g_desc->num_gen * sizeof ( int ) );
	pc_desc->group_name[0] = '\0';
	cnr = ( g_desc->num_gen * ( g_desc->num_gen -1 ) ) >> 1;
	pc_desc->c_list = (ge_pair **)ALLOCATE ( cnr * sizeof ( ge_pair * ) );
	pc_desc->c_len = (int *)ALLOCATE ( cnr * sizeof ( int ) );
	pc_desc->group_card = 1;
	pc_desc->def_list = ALLOCATE ( pc_desc->num_gen * sizeof ( GENDEF ) );
	for ( i = 0; i < g_desc->num_gen; i++ ) {
		pc_desc->gen[i] = ALLOCATE ( strlen ( g_desc->gen[i] ) + 1 );
		strcpy ( pc_desc->gen[i], g_desc->gen[i] );
	}	
	for ( i = 0; i < g_desc->num_gen; i++ ) {
		pc_desc->g_max[i] = prime;
		pc_desc->group_card *= prime;
	}

	/* get relations */
	
	/* initialize commutators with 1 */
	for ( i = 1; i < g_desc->num_gen; i++ ) {
		for ( j = 0; j < i; j++ ) {
			pc_desc->c_list[CN(i,j)] = NULL;
			pc_desc->c_len[CN(i,j)] = 0;
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
			pc_desc->p_list[num] = pair_list;
			pc_desc->p_len[num] = len;
		}
		else {
			pc_desc->c_list[num] = pair_list;
			pc_desc->c_len[num] = len;
		}			
	}

	num = pc_desc->num_gen;
	pc_desc->nom = ALLOCATE ( num * sizeof ( PCELEM ) );
	for ( i = 0; i < num; i++ ) {
		pc_desc->nom[i] = IDEL ( pc_desc );
		set_el ( pc_desc->nom[i], i, 1 );
	}

	pc_desc->autg = NULL;
	
	pc_desc->pc_weight = ALLOCATE ( num * sizeof ( int ) );
	for ( i = 0; i < num; i++ )
		pc_desc->pc_weight[i] = 1;
	pc_desc->exp_p_class = num; 

	pc_desc->exp_p_lcs = ALLOCATE ( (pc_desc->exp_p_class+1) * sizeof ( FILT ) );

	pc_desc->exp_p_lcs[0].i_start = -1;
	pc_desc->exp_p_lcs[0].i_end = -1;
	pc_desc->exp_p_lcs[0].i_dim = 0;

	for ( i = 1; i <= num; i++ ) {
		pc_desc->exp_p_lcs[i].i_start = pc_desc->exp_p_lcs[i-1].i_end+1;
		pc_desc->exp_p_lcs[i].i_end = i-1;
		pc_desc->exp_p_lcs[i].i_dim = 1;
	}

	get_definitions ( pc_desc );
	normalize_presentation ( pc_desc );

	/* get definitions for non minimal generators */
	
	return ( pc_desc );		
}

PCGRPDESC *p_quotient  ( PCGRPDESC *g_desc, int class )
{
	int i, j, k, cnr;
	int numgen;
	PCGRPDESC *pc_desc = ALLOCATE ( sizeof ( PCGRPDESC ) );

	prime = pc_desc->prime = g_desc->prime;
	numgen = g_desc->exp_p_lcs[class].i_end + 1;
	swap_arith ( g_desc->prime );
	pc_desc->num_gen = numgen;

	pc_desc->max_id = 0;
	pc_desc->exp_p_class = class;
	pc_desc->min_gen = g_desc->min_gen;
	pc_desc->gen = ALLOCATE ( numgen * sizeof ( char * ) );
	pc_desc->g_max = CALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->g_ideal = CALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->image = CALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->pimage = CALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->p_list = (ge_pair **)ALLOCATE ( numgen * sizeof ( ge_pair *) );
	pc_desc->p_len = (int *)ALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->group_name[0] = '\0';
	cnr = ( numgen * ( numgen -1 ) ) >> 1;
	pc_desc->c_list = (ge_pair **)ALLOCATE ( cnr * sizeof ( ge_pair * ) );
	pc_desc->c_len = (int *)ALLOCATE ( cnr * sizeof ( int ) );
	pc_desc->group_card = 1;
	pc_desc->def_list = ALLOCATE ( numgen * sizeof ( GENDEF ) );
	for ( i = 0; i < numgen; i++ ) {
		pc_desc->gen[i] = ALLOCATE ( strlen ( g_desc->gen[i] ) );
		strcpy ( pc_desc->gen[i], g_desc->gen[i] );
	}	
	for ( i = 0; i < numgen; i++ ) {
		pc_desc->g_max[i] = prime;
		pc_desc->group_card *= prime;
	}

	/* copy tailored pc-relations */
	for ( i = 0; i < numgen; i++ ) {
		j = 0;
		for ( k = 0; k < g_desc->p_len[i]; k++ ) {
			if ( g_desc->p_list[i][k].g < numgen )
				j++;
			else
				break;
		}
		pc_desc->p_len[i] = j;
		if ( j == 0 )
			pc_desc->p_list[i] = NULL;
		else {
			pc_desc->p_list[i] = ALLOCATE ( (j+1)*sizeof ( ge_pair ) );
			pc_desc->p_list[i][j].g = pc_desc->p_list[i][j].e = -1;
			memcpy ( pc_desc->p_list[i], g_desc->p_list[i], j*sizeof ( ge_pair ) );
		}
	}
	for ( i = 0; i < cnr; i++ ) {
		j = 0;
		for ( k = 0; k < g_desc->c_len[i]; k++ ) {
			if ( g_desc->c_list[i][k].g < numgen )
				j++;
			else
				break;
		}
		pc_desc->c_len[i] = j;
		if ( j == 0 )
			pc_desc->c_list[i] = NULL;
		else {
			pc_desc->c_list[i] = ALLOCATE ( (j+1)*sizeof ( ge_pair ) );
			pc_desc->c_list[i][j].g = pc_desc->c_list[i][j].e = -1;
			memcpy ( pc_desc->c_list[i], g_desc->c_list[i], j*sizeof ( ge_pair ) );
		}
	}
				
	pc_desc->nom = ALLOCATE ( numgen * sizeof ( PCELEM ) );
	for ( i = 0; i < numgen; i++ ) {
		pc_desc->nom[i] = IDEL ( pc_desc );
		set_el ( pc_desc->nom[i], i, 1 );
	}

	pc_desc->autg = NULL;
	
	pc_desc->pc_weight = ALLOCATE ( numgen * sizeof ( int ) );
	for ( i = 0; i < numgen; i++ )
		pc_desc->pc_weight[i] = 1;
	pc_desc->exp_p_class = numgen; 

	pc_desc->exp_p_lcs = ALLOCATE ( (pc_desc->exp_p_class+1) * sizeof ( FILT ) );

	pc_desc->exp_p_lcs[0].i_start = -1;
	pc_desc->exp_p_lcs[0].i_end = -1;
	pc_desc->exp_p_lcs[0].i_dim = 0;

	for ( i = 1; i <= numgen; i++ ) {
		pc_desc->exp_p_lcs[i].i_start = pc_desc->exp_p_lcs[i-1].i_end+1;
		pc_desc->exp_p_lcs[i].i_end = i-1;
		pc_desc->exp_p_lcs[i].i_dim = 1;
	}

	get_definitions ( pc_desc );
	normalize_presentation ( pc_desc );

	return ( pc_desc );		
}

PCGRPDESC *ag_max_p_quotient  ( AGGRPDESC *g_desc )
{
	int i, j, k, cnr;
	int numgen, class;
	PCGRPDESC *pc_desc = ALLOCATE ( sizeof ( PCGRPDESC ) );

	prime = pc_desc->prime = g_desc->powers[0];
	class = 1;
	while ( g_desc->powers[g_desc->elab_series[class].i_start] == prime ) class++;
	pc_desc->exp_p_class = --class;
	numgen = g_desc->elab_series[class].i_end + 1;
	swap_arith ( prime );
	pc_desc->num_gen = numgen;

	pc_desc->max_id = 0;
	
	pc_desc->min_gen = g_desc->elab_series[1].i_dim;
	pc_desc->gen = ALLOCATE ( numgen * sizeof ( char * ) );
	pc_desc->g_max = CALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->g_ideal = CALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->image = CALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->pimage = CALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->p_list = (ge_pair **)ALLOCATE ( numgen * sizeof ( ge_pair *) );
	pc_desc->p_len = (int *)ALLOCATE ( numgen * sizeof ( int ) );
	pc_desc->group_name[0] = '\0';
	cnr = ( numgen * ( numgen -1 ) ) >> 1;
	pc_desc->c_list = (ge_pair **)ALLOCATE ( cnr * sizeof ( ge_pair * ) );
	pc_desc->c_len = (int *)ALLOCATE ( cnr * sizeof ( int ) );
	pc_desc->group_card = 1;
	pc_desc->def_list = ALLOCATE ( numgen * sizeof ( GENDEF ) );
	for ( i = 0; i < numgen; i++ ) {
		pc_desc->gen[i] = ALLOCATE ( strlen ( g_desc->gen[i] ) );
		strcpy ( pc_desc->gen[i], g_desc->gen[i] );
	}	
	for ( i = 0; i < numgen; i++ ) {
		pc_desc->g_max[i] = prime;
		pc_desc->group_card *= prime;
	}

	/* copy tailored pc-relations */
	for ( i = 0; i < numgen; i++ ) {
		j = 0;
		for ( k = 0; k < g_desc->p_len[i]; k++ ) {
			if ( g_desc->p_list[i][k].g < numgen )
				j++;
			else
				break;
		}
		pc_desc->p_len[i] = j;
		if ( j == 0 )
			pc_desc->p_list[i] = NULL;
		else {
			pc_desc->p_list[i] = ALLOCATE ( (j+1)*sizeof ( ge_pair ) );
			pc_desc->p_list[i][j].g = pc_desc->p_list[i][j].e = -1;
			memcpy ( pc_desc->p_list[i], g_desc->p_list[i], j*sizeof ( ge_pair ) );
		}
	}
	for ( i = 0; i < cnr; i++ ) {
		j = 0;
		for ( k = 0; k < g_desc->c_len[i]; k++ ) {
			if ( g_desc->c_list[i][k].g < numgen )
				j++;
			else
				break;
		}
		pc_desc->c_len[i] = j;
		if ( j == 0 )
			pc_desc->c_list[i] = NULL;
		else {
			pc_desc->c_list[i] = ALLOCATE ( (j+1)*sizeof ( ge_pair ) );
			pc_desc->c_list[i][j].g = pc_desc->c_list[i][j].e = -1;
			memcpy ( pc_desc->c_list[i], g_desc->c_list[i], j*sizeof ( ge_pair ) );
		}
	}
				
	pc_desc->nom = ALLOCATE ( numgen * sizeof ( PCELEM ) );
	for ( i = 0; i < numgen; i++ ) {
		pc_desc->nom[i] = IDEL ( pc_desc );
		set_el ( pc_desc->nom[i], i, 1 );
	}

	pc_desc->autg = NULL;
	
	pc_desc->pc_weight = ALLOCATE ( numgen * sizeof ( int ) );
	for ( i = 0; i < numgen; i++ )
		pc_desc->pc_weight[i] = 1;
	pc_desc->exp_p_class = numgen; 

	pc_desc->exp_p_lcs = ALLOCATE ( (pc_desc->exp_p_class+1) * sizeof ( FILT ) );

	pc_desc->exp_p_lcs[0].i_start = -1;
	pc_desc->exp_p_lcs[0].i_end = -1;
	pc_desc->exp_p_lcs[0].i_dim = 0;

	for ( i = 1; i <= numgen; i++ ) {
		pc_desc->exp_p_lcs[i].i_start = pc_desc->exp_p_lcs[i-1].i_end+1;
		pc_desc->exp_p_lcs[i].i_end = i-1;
		pc_desc->exp_p_lcs[i].i_dim = 1;
	}

	get_definitions ( pc_desc );
	normalize_presentation ( pc_desc );

	return ( pc_desc );		
}

static PCELEM *rel_rows;
static node *rside;
static int x_dim, y_dim;
static int *defrel;
static char *done;
static int *not_minimal;

int definition ( PCELEM e, int col )
{
	int isdef;
	char x;
	
	x = e[col];
	e[col] = 0;
	
	isdef = iszero ( e, bperelem );
	e[col] = x;
	return ( isdef );
}

void col_eliminate ( int row, int col )
{
	register int i = y_dim;
	register char x;
	node hn1, hn2;
	PCELEM h1, h2;
	
	for ( i = 0; i < y_dim; i++ ) {
		if ( i != row ) {
			if ( (x = rel_rows[i][col]) != 0 ) {
				if ( definition ( rel_rows[i], col ) )
					continue;
				PUSH_STACK();
				h1 = g_invers ( rel_rows[row] );
				h1 = g_expo ( h1, x );
				h2 = monom_mul ( h1, rel_rows[i] );
				copy_vector ( h2, rel_rows[i], bperelem );
				POP_STACK();
				if ( definition ( rel_rows[i], col ) )
					done[i] = 0;
				E_NODE ( hn1, node_cpy ( rside[row], FALSE ), -x );
				M_NODE ( hn2, hn1, rside[i] );
				rside[i] = hn2;
			}
		}
	}
}

void rels_eliminate (void)
{
	register int ix;
	register int iy = 0;
	register char value = '\0';
	PCELEM h;
	node hn;
      
	done = ALLOCATE ( y_dim );
	for ( iy = 0; iy < y_dim; iy++ )
		done[iy] = 1;
		
	while ( !iszero ( done, y_dim ) ) {	
		for ( iy = 0; iy < y_dim; iy++ ) {
			if ( iszero ( rel_rows[iy], x_dim ) ) {
				done[iy] = 0;
				continue;
			}
			for ( ix = 0; ix < x_dim; ix++ )
				if ( (value=rel_rows[iy][ix]) != 0 )
					break;
			if ( definition ( rel_rows[iy], ix ) )
				done[iy] = 0;
			value = fp_inv ( value );
			PUSH_STACK();
			h = g_expo ( rel_rows[iy], value );
			copy_vector ( h, rel_rows[iy], bperelem );
			POP_STACK();
			if ( value != 1 ) {
				E_NODE ( hn, rside[iy], value );
				rside[iy] = hn;
			}
			col_eliminate ( iy, ix );
		}
	}
}

static int gweight ( node p )
{
	int w = 1;
	int w1, w2;
	
	switch ( p->nodetype ) {
		case GGEN:
				w = group_desc->pc_weight[p->value];
				break;
		case COMM:
				w =  gweight ( p->left ) + gweight ( p->right );
				break;
		case EXP :
				if ( p->value == prime )
					w = gweight ( p->left ) + 1;
				else
					w = gweight ( p->left );
				break;
		case MULT:
				w1 = gweight ( p->left );
				w2 = gweight ( p->right );
				w = w1 > w2 ? w2 : w1;
				break;
		default:
				puts ( "Error in structure" );
	}
	return ( w );
}

void check_definition ( ge_pair *rel, int rlen, int rnum )
{
	int e, g;
	
	if ( rlen == 1 ) {
		g = rel[0].g;
		e = rel[0].e;
		if ( (e == 1) && (defrel[g] == -1) ) {
			defrel[g] = rnum;
		}
	}
}			

void check_minimal (void)
{
	int i, j;
	
	for ( i = 0; i < y_dim; i++ )
		for ( j = 0; j < bperelem; j++ )
			if ( rel_rows[i][j] != 0 )
				not_minimal[j] = TRUE;
}

int check_recursive ( node p, node s )
{
	
	switch ( p->nodetype ) {
		case GGEN:
				if ( ( group_desc->def_list[p->value] == NULL ) ||
					( group_desc->def_list[p->value] != s ) )
					return ( FALSE );
				else
					return ( TRUE );
				break;
		case COMM:
				return ( check_recursive ( p->left, s ) | 
					    check_recursive ( p->right, s ) );
				break;
		case EXP :
				return ( check_recursive ( p->left, s ) );
				break;
		case MULT:
				return ( check_recursive ( p->left, s ) | 
					    check_recursive ( p->right, s ) );
				break;
		default:
				puts ( "Error in structure" );
	}
	return ( TRUE );
}

void get_definitions ( PCGRPDESC *g_desc )
{
	int i, j, c, cnr, num, v;
	node hn1, hn2;
	PCGRPDESC *old_pcgroup = group_desc;
	int *weights;
	int changed;
	int do_elim;
	char value = '\0';
	
	set_main_group ( g_desc );
	
	cnr = (g_desc->num_gen*(g_desc->num_gen-1))>>1;
	num = g_desc->num_gen;
	rel_rows = ARRAY ( cnr + num, PCELEM );
	rside = ARRAY ( cnr + num, node );
	defrel = ARRAY ( num, int );
	not_minimal = CALLOCATE ( num * sizeof ( int ) );
	group_desc->def_list = ARRAY ( num, node );
	
	for ( i = 0; i < num; i++ )
		defrel[i] = -1;
	
	y_dim = 0;
	for ( i = 0; i < num; i++ ) {
		if ( g_desc->p_len[i] > 0 ) {
			G_NODE ( hn1, i );
			E_NODE ( rside[y_dim], hn1, g_desc->prime );
			check_definition ( g_desc->p_list[i], g_desc->p_len[i], y_dim );
			rel_rows[y_dim++] = ge_pair_to_exp_vec ( g_desc->p_list[i], g_desc->p_len[i] );
		}
	}
	for ( i = 1; i < num; i++ ) {
		for ( j = 0; j < i; j++ ) {
			c = CN ( i, j );
			if ( g_desc->c_len[c] > 0 ) {
				G_NODE ( hn1, i );
				G_NODE ( hn2, j );
				C_NODE ( rside[y_dim], hn1, hn2 );
				check_definition ( g_desc->c_list[c], g_desc->c_len[c], y_dim );
				rel_rows[y_dim++] = ge_pair_to_exp_vec ( g_desc->c_list[c], g_desc->c_len[c] );
			}
		}
	}
	x_dim = bperelem;
	do_elim = FALSE;
	check_minimal();
	for ( i = 0; i < num; i++ )
		if ( (defrel[i] == -1) && not_minimal[i] ) {
			do_elim = TRUE;
			break;
		}
		
	if ( do_elim ) {
		fprintf ( stderr, "#I SISYPHOS: no complete set of defining relations!\n" );
		rels_eliminate();
		/* determine definitions */
		for ( i = 0; i < y_dim; i++ ) {
			for ( j = 0; j < bperelem; j++ )
				if ( (value=rel_rows[i][j]) != 0 ) break;
			if ( value != 0 && defrel[j] == -1 )
				defrel[j] = i;
		}
	}
	
	weights = g_desc->pc_weight;
	for ( i = 0; i < num; i++ )
		weights[i] = 1;
	do {
	    changed = FALSE;
	    for ( i = 0; i < y_dim; i++ ) {
		   if ( !iszero ( rel_rows[i], num ) ) {
			  for ( j = 0; j < num; j++ )
				 if ( rel_rows[i][j] != 0 ) {
					if ( (v=gweight ( rside[i] )) > 
						weights[j] ) {
					    changed = TRUE;
					    weights[j] = v;
					}
				 }
		   }
	    }
	} while ( changed );

	group_desc->defs = TRUE;
	for ( i = 0; i < num; i++ ) {
		if ( defrel[i] == -1 )
			group_desc->def_list[i] = NULL;
		else {
			hn1 = group_desc->def_list[i] = rside[defrel[i]];
			if ( check_recursive ( hn1, hn1 ) )
/*				fprintf ( stderr, "#D recursive definitions\n" ); */
				group_desc->defs = FALSE;
		}
/*		printf ( "w[%d] = %d\n", i, weights[i] ); */
	}
	
	g_desc->exp_p_class = 1;
	for ( i = 1; i < num; i++ )
		if ( PC_WEIGHT(i) > g_desc->exp_p_class )
			g_desc->exp_p_class = PC_WEIGHT(i);

	set_main_group ( old_pcgroup );
}

void renumber ( node p, int map[] )
{
	
	switch ( p->nodetype ) {
		case GGEN:
				p->value = map[p->value];
				break;
		case COMM:
				renumber ( p->left, map );
				renumber ( p->right, map );
				break;
		case EXP :
				renumber ( p->left, map );
				break;
		case MULT:
				renumber ( p->left, map );
				renumber ( p->right, map );
				break;
		default:
				puts ( "Error in structure" );
	}
}

void normalize_presentation ( PCGRPDESC *g_desc )
{
	int i, j, l, k, offset, com;
	int *map, *pmap;
	char **names;
	ge_pair **rlist;
	int *lrlist;
	int *invert;
	node *dlist;
	PCELEM res, r, h;
	PCGRPDESC *old_pcgroup;
	int ngen = g_desc->num_gen;
	int changed = FALSE;
	
	map = g_desc->image;
	pmap = g_desc->pimage;
	names = ARRAY ( ngen, VEC );
	rlist = ARRAY ( ((ngen*(ngen-1))>>1), ge_pair* );
	lrlist = ARRAY ( ((ngen*(ngen-1))>>1), int );
	invert = ARRAY ( ((ngen*(ngen-1))>>1), int );
	
	PUSH_STACK();
	/* initialize map to identity */
	for ( i = 0; i < ngen; i++ ) {
		map[i] = i;
		pmap[i] = i;
		names[i] = g_desc->gen[i];
	}
		
	offset = 0;
	for ( i = 1; i <= g_desc->exp_p_class; i++ ) {
		g_desc->exp_p_lcs[i].i_dim = 0;
		for ( j = 0; j < ngen; j++ ) {
			if ( g_desc->pc_weight[j] == i ) {
				g_desc->exp_p_lcs[i].i_dim++;
				pmap[offset] = j;
				map[j] = offset++;
			}
		}
	}
	
	/* recompute exp_p_lcs */
	
	for ( i = 1; i <= g_desc->exp_p_class; i++ ) {
		g_desc->exp_p_lcs[i].i_start = g_desc->exp_p_lcs[i-1].i_end+1;
		g_desc->exp_p_lcs[i].i_end = g_desc->exp_p_lcs[i].i_start +
			g_desc->exp_p_lcs[i].i_dim - 1;
		for ( j = g_desc->exp_p_lcs[i].i_start; j <= g_desc->exp_p_lcs[i].i_end; j++ )
			g_desc->pc_weight[j] = i;
	}
	
	g_desc->min_gen = g_desc->exp_p_lcs[1].i_dim;

	for ( i = 0; i < ngen; i++ ) {
		if ( map[i] != i ) {
			fprintf ( stderr, "#I SISYPHOS: order of generators has been changed!\n" );
			changed = TRUE;
			break;
		}
	}

	if ( !changed ) {
		/* nothing to do */
		POP_STACK();
		return;
	}
	

	/* reorder generators */
	
	for ( i = 0; i < ngen; i++ )
		g_desc->gen[map[i]] = names[i];
		
	/* change relations */
	for ( i = 0; i < ngen; i++ ) {
		for ( j = 0; j < g_desc->p_len[i]; j++ )
			g_desc->p_list[i][j].g = map[g_desc->p_list[i][j].g];
	}
	for ( i = 0; i < ((ngen*(ngen-1))>>1); i++ )
		for ( j = 0; j < g_desc->c_len[i]; j++ )
			g_desc->c_list[i][j].g = map[g_desc->c_list[i][j].g];
	
	
	for ( i = 0; i < ngen; i++ ) {
		rlist[i] = g_desc->p_list[i];
		lrlist[i] = g_desc->p_len[i];
	}
	for ( i = 0; i < ngen; i++ ) {
		g_desc->p_list[map[i]] = rlist[i];
		g_desc->p_len[map[i]] = lrlist[i];
	}
	
	for ( i = 0; i < ((ngen*(ngen-1))>>1); i++ ) {
		rlist[i] = g_desc->c_list[i];
		lrlist[i] = g_desc->c_len[i];
	}		
	for ( i = 1; i < ngen; i++ ) {
		for ( j = 0; j < i; j++ ) {
			if ( map[i] < map[j] ) {
				com = CN(map[j],map[i]);
				invert[com] = TRUE;
			}
			else {
				com = CN(map[i],map[j]);
				invert[com] = FALSE;
			}
			g_desc->c_list[com] = rlist[CN(i,j)];
			g_desc->c_len[com] = lrlist[CN(i,j)];
		}
	}
	POP_STACK();

	/* recalculate right sides of relations */
	
	old_pcgroup = group_desc;
	set_main_group ( g_desc );
	
	for ( i = g_desc->exp_p_class; i > 0; i-- ) {
		
		/* powers */
		for ( j = g_desc->exp_p_lcs[i].i_start; j <= g_desc->exp_p_lcs[i].i_end; j++ ) {
			res = r = IDENTITY;
			PUSH_STACK();
			for ( k = 0; k < g_desc->p_len[j]; k++ ) {
				h = g_expo ( g_desc->nom[g_desc->p_list[j][k].g],
					g_desc->p_list[j][k].e );
				r = monom_mul ( r, h );
			}
			copy_vector ( r, res, bperelem );
			POP_STACK();
			g_desc->p_list[j] = g_desc->p_len[j] == 0 ? NULL : exp_vec_to_ge_pair ( res, &g_desc->p_len[j] );
		}

		/* commutators */
		for ( j = g_desc->exp_p_lcs[i].i_start; j <= g_desc->exp_p_lcs[i].i_end; j++ ) {
			for ( l = 0; l < j; l++ ) {
				com = CN(j,l);
				res = r = IDENTITY;
				PUSH_STACK();
				for ( k = 0; k < g_desc->c_len[com]; k++ ) {
					h = g_expo ( g_desc->nom[g_desc->c_list[com][k].g],
						g_desc->c_list[com][k].e );
					r = monom_mul ( r, h );
				}
				if ( invert[com] )
					r = g_invers ( r );
				copy_vector ( r, res, bperelem );
				POP_STACK();
				g_desc->c_list[com] = g_desc->c_len[com] == 0 ? NULL : exp_vec_to_ge_pair ( res, &g_desc->c_len[com] );
			}
		}
	}
	
	/* reorder definition list */
	PUSH_STACK();
	dlist = ARRAY ( ngen, node );
	for ( i = 0; i < ngen; i++ ) {
		dlist[i] = g_desc->def_list[i];
	}
	for ( i = 0; i < ngen; i++ ) {
		g_desc->def_list[map[i]] = dlist[i];
	}
	POP_STACK();
	
	/* renumber generators in defining relations */
	
	for ( i = 0; i < GNUMGEN; i++ )
		if ( group_desc->def_list[i] != NULL )
			renumber ( group_desc->def_list[i], map );
			
	set_main_group ( old_pcgroup );				
}

void set_main_group ( PCGRPDESC *g_desc )
{
	group_desc = g_desc;
	if ( group_desc != NULL ) {
		prime = group_desc->prime;
		swap_arith ( prime );
		set_group_quotient ( group_desc->exp_p_class );
	}
}

GRPDSC *conv_rel ( PCGRPDESC *g_desc )
{
	int i, j, k, c;
	node no, no1, no2, no3, no4, no5;
	GRPDSC *h_desc = ALLOCATE ( sizeof ( GRPDSC ) );
	
	h_desc->prime = g_desc->prime;
	h_desc->num_gen = g_desc->num_gen;
	h_desc->num_rel = CN ( g_desc->num_gen, 0 ) + g_desc->num_gen;

	h_desc->gen = ALLOCATE ( g_desc->num_gen * sizeof ( char * ) );
	for ( i = 0; i < g_desc->num_gen; i++ )
		h_desc->gen[i] = ALLOCATE ( strlen ( g_desc->gen[i] )+1 );
	for ( i = 0; i < g_desc->num_gen; i++ )
		strcpy ( h_desc->gen[i], g_desc->gen[i] );
	h_desc->is_minimal = FALSE;
	h_desc->pc_pres = g_desc;
	h_desc->isog = NULL;
	
	h_desc->rel_list = ALLOCATE ( h_desc->num_rel * sizeof ( node ) );
	
	/* power relations */
	for ( i = 0; i < h_desc->num_gen; i++ ) {
		G_NODE ( no1, i );
		E_NODE ( no2, no1, h_desc->prime );
		no = NULL;
		for ( j = 0; j < g_desc->p_len[i]; j++ ) {
			G_NODE ( no3, g_desc->p_list[i][j].g );
			if ( g_desc->p_list[i][j].e > 1 ) {
				E_NODE ( no4, no3, g_desc->p_list[i][j].e );
			}
			else
				no4 = no3;
			if ( no != NULL ) {
				M_NODE ( no3, no, no4 );
				no = no3;
			}
			else
				no = no4;
		}
		R_NODE ( h_desc->rel_list[i], no2, no );
	}

	/* commutator relations */
	for ( i = 1; i < h_desc->num_gen; i++ ) {
		for ( j = 0; j < i; j++ ) {
			c = CN(i,j);
			G_NODE ( no1, i );
			G_NODE ( no2, j );
			C_NODE ( no5, no1, no2 );
			no = NULL;
			for ( k = 0; k < g_desc->c_len[c]; k++ ) {
				G_NODE ( no3, g_desc->c_list[c][k].g );
				if ( g_desc->c_list[c][k].e > 1 ) {
					E_NODE ( no4, no3, g_desc->c_list[c][k].e );
				}
				else
					no4 = no3;
				if ( no != NULL ) {
					M_NODE ( no3, no, no4 );
					no = no3;
				}
				else
					no = no4;
			}
			R_NODE ( h_desc->rel_list[c+h_desc->num_gen], no5, no );
		}
	}
	return ( h_desc );
}

void n_expand ( node p )
{
	if ( p->left != NULL ) {
		if ( p->left->nodetype == GGEN ) {
			if ( p->left->value >= group_desc->min_gen ) {
				p->left = node_cpy ( group_desc->def_list[p->left->value], FALSE );
				n_expand ( p->left );
			}
		}
		else
			n_expand ( p->left );
	}
	if ( p->right != NULL ) {
		if ( p->right->nodetype == GGEN ) {
			if ( p->right->value >= group_desc->min_gen ) {
				p->right = node_cpy ( group_desc->def_list[p->right->value], FALSE );
				n_expand ( p->right );
			}
		}
		else
			n_expand ( p->right );
	}
}

node gen_to_node ( int g )
{
	node n;

	if ( (g < group_desc->min_gen) || (!group_desc->defs) ) {
		G_NODE ( n, g );
	}
	else {
		n = node_cpy ( group_desc->def_list[g], FALSE );
		n_expand ( n );
	}
	return ( n );
}

node word_to_node ( VEC word, int len )
{
	int i;
	int first = TRUE;
	node n, n0, n1, n2;
	char val;
		
	n = NULL;
	for ( i = 0; i < len; i++ ) {
		if ( (val=word[i]) != 0 ) {
			n0 = n1 = gen_to_node ( i );
			if ( val != 1 ) {
				E_NODE ( n0, n1, val );
			}
			if ( !first ) {
				M_NODE ( n2, n, n0 );
				n = n2;
			}
			else {
				first = FALSE;
				n = n0;
			}
		}
	}
	return ( n );
}

static PCELEM calc_image ( VEC r, node p )
{
	register PCELEM h1;
	register PCELEM obs;
	int dummy;
	
	obs = IDENTITY;
	PUSH_STACK();

	switch ( p->nodetype ) {
		case GGEN:
				copy_vector ( image_of_generator ( r, p->value ), obs, bperelem );
				break;
		case COMM:
				h1 = g_comm ( calc_image ( r, p->left ), calc_image ( r, p->right ) );
				copy_vector ( h1, obs, bperelem );
				break;
		case EXP :
				h1 = g_expo ( calc_image ( r, p->left ), (p->value > 0) ? p->value : -p->value );
				if ( p->value < 0 )
					h1 = g_invers ( h1 );
				copy_vector ( h1, obs, bperelem );
				break;
		case MULT:
				copy_vector ( calc_image ( r, p->left ), obs, bperelem );
				collect ( obs, exp_vec_to_ge_pair ( calc_image ( r, p->right ), &dummy ) );
				break;
		default:
				puts ( "Error in relation" );
	}
	POP_STACK();
	return ( obs );
}

PCELEM image_of_generator ( VEC r, int g )
{
	PCELEM im = ALLOCATE ( bperelem );
	
	PUSH_STACK();
	if ( (g < group_desc->min_gen) || (!group_desc->defs) )
		copy_vector ( r+g*bperelem, im, bperelem );
	else {
		copy_vector ( calc_image ( r, group_desc->def_list[g] ), im, bperelem );
	}
	POP_STACK();
	return ( im );
}

void pcgroup_to_gap ( PCGRPDESC *g, char *name, int def_gens, char *file_n )
{
    int i, j;
    PCELEM expvec;
    PCGRPDESC *old_pcgroup;

    old_pcgroup = group_desc;
    set_main_group ( g );

    presentation_type = GAP;
    if ( file_n == NULL )
	   pres_file = stdout;
    else {
	   pres_file = fopen ( file_n, "w" );
    }

    PUSH_STACK();
    expvec = CALLOCATE ( g->num_gen+1 );
    output_prae ( g->num_gen+1, 1, FALSE, 0, name );
    
    /* print power relations */
    for ( i = 0; i < g->num_gen; i++ ) {
	   if ( g->p_list[i] == NULL )
		  zero_vector ( expvec, g->num_gen+1 );
	   else
		  copy_vector ( ge_pair_to_exp_vec ( g->p_list[i], g->p_len[i] ),
					 expvec+1, g->num_gen );
	   output_relation ( expvec, i+1, 0, TRUE, g->num_gen+1, 1 );
    }

    /* print commutator relations */
    for ( i = 1; i < g->num_gen; i++ )
	   for ( j = 0; j < i; j++ ) {
		  if ( g->c_list[CN(i,j)] == NULL )
			 zero_vector ( expvec, g->num_gen+1 );
		  else
			 copy_vector ( ge_pair_to_exp_vec ( g->c_list[CN(i,j)],
									 g->c_len[CN(i,j)] ),
						expvec+1, g->num_gen );
		  output_relation ( expvec, i+1, j+1, FALSE, g->num_gen+1, 1 );
	   }
    
    output_post ( g->num_gen+1, 1, def_gens, name );
    POP_STACK();
    set_main_group ( old_pcgroup );
}

/* end of module pc */
