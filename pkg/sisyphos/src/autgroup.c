/********************************************************************/
/*  Module        : Automorphism group                              */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies routines to compute with automorphisms of a         */
/*     p-group given via a pc-representation.                       */
/*                                                                  */
/*                                                                  */
/********************************************************************/


/* 	$Id: autgroup.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: autgroup.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/08/10 11:48:23  pluto
 * 	Initial revision under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: autgroup.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include <ctype.h>
#include	<math.h>
#include	"pc.h"
#include	"hgroup.h"
#include	"storage.h"
#include	"error.h"
#include	"aut.h"
#include	"solve.h"

#ifdef UNIX
#ifdef NeXT
#include <libc.h>
#else
#include <unistd.h>
#endif
#include <fcntl.h>
#endif

#ifdef ANSI
void exit ( int status );
#endif

void init_gl				_(( int dim ));
int is_id 				_(( PCELEM el ));
int inc_el 				_(( PCELEM el ));
PCELEM g_comm				_(( PCELEM el, PCELEM er ));
int g_h1_mat			     _(( int start, int dim, int *y ));
int check_iso 				_(( VEC vector, int c2_dim ));
int inc2_count 		     _(( VEC coeff, int last ));
void liftings_mod2            _(( VEC autgens[], int n_autgens, int n, int p ));
VEC aut_Idmat 				_(( void ));
VEC exp_concatenate_aut 		_(( VEC l, int power ));
int aut_isIdmat 			_(( VEC m ));
int is_aut_id	 			_(( VEC m ));
void show_aut_pres 			_(( HOM *hom, int only_outer ));
void copy_group 			_(( GRPDSC *src, GRPDSC *dest, int perm ));
int set_group_quotient		_(( int class ));
void word_write 			_(( PCELEM elem ));
GRPDSC *change_presentation 	_(( VEC iso[] ));
int aut_dimino 			_(( VEC m[], int t, int c1order, int all_auts ));
int gl_subgroup_order 		_(( void ));
int maps_to_liftable 		_(( int sclass, int eclass ));
void reorder_rels 			_(( void ));
PCGRPDESC *p_quotient		_(( PCGRPDESC *g_desc, int quotient ));
int setup_section 			_(( int class, VEC **h, int *next_class ));
void output_prae              _(( int len, int start, int unitgrp, int mod_id,
						    char *name ));
void output_post              _(( int len, int start, int def_gens,
						    char *name ));
void output_relation 		_(( VEC index, int e1, int e2, int is_pow, int len, int start ));
int log_g_order 			_(( register PCELEM el ));

extern int (*get_gl_element)	_(( void ));
extern void (*add_to_list)	_(( void ));
extern void (*add_to_fail_list)	_(( int mark ));

extern int prime;
extern PCGRPDESC *group_desc;
extern GRPDSC *h_desc;
extern GRPRING *group_ring;
extern int new_xdim, new_cut;
extern IHEADER h_out;
extern VEC can_to_new[MAXCARD];
extern int s_int;
extern int s_rel;
extern int s_reldesc;
extern int dim, dquad;
extern int quiet;
extern DSTYLE displaystyle;
extern VEC mat;
extern int bperelem;
extern int exp_p_class;
extern int **ap_len;
extern int **ac_len;
extern int adim, adquad;
extern int initialized;
extern DSTYLE presentation_type;
extern FILE *pres_file;
extern PCELEM *rho;
extern OPTION aut_pres_style;
extern LISTP *list_aut_gens;


/* routines for computations with elements of automorphism groups */

extern int g_gens;		/* number of group generators used to compute
					   automorphism group */
static int dimension = 0;
					   
VEC concatenate_aut ( VEC l, VEC r )
{
	PCELEM res, rhor, rhol;
	VEC resv;
	int i, j, pow;
	
	resv = ALLOCATE ( g_gens * bperelem );
	PUSH_STACK();
	for ( i = 0; i < g_gens; i++ ) {
		rhor = r+i*bperelem;
		res = IDENTITY;
		for ( j = 0; j < bperelem; j++ ) {
			if ( (pow = rhor[j]) != 0 ) {
				rhol = image_of_generator ( l, j );  
				res = monom_mul ( res, g_expo ( rhol, pow ) );
			}
		}
		copy_vector ( res, resv+i*bperelem, bperelem );
	}
	POP_STACK();
	return ( resv );
}	

VEC exp_concatenate_aut ( VEC l, int power )
/* power != 0 only */
{
	register int i = 4096;
	VEC resv, h;
	
	resv = ALLOCATE ( g_gens * bperelem );
	PUSH_STACK();
	h = resv;
	copy_vector ( l, h, g_gens * bperelem );
	while ( !(power & i ) ) i >>= 1;
	while ( (i >>= 1) != 0 ) {
		h = concatenate_aut ( h, h );
		if ( power & i )
			h = concatenate_aut ( h, l );
	}
	copy_vector ( h, resv, g_gens * bperelem );
	POP_STACK();
	return ( resv );
}

VEC inv_concatenate_aut ( VEC el )
{
	VEC resv = aut_Idmat();
	VEC l, i;
	
	if ( !is_aut_id ( el ) ) {
		PUSH_STACK();
		i = l = el;
		while ( !is_aut_id ( i = exp_concatenate_aut ( i, GPRIME ) ) ) {
			l = concatenate_aut ( i, l );
		}
		i = exp_concatenate_aut ( l, GPRIME-1 );
		copy_vector ( i, resv, dimension );
		POP_STACK();
	}
	return ( resv );
}

VEC comm_concatenate_aut ( VEC l, VEC r )
{
	VEC resv = ALLOCATE ( dimension );
	VEC help;
	
	PUSH_STACK();
	help = concatenate_aut ( inv_concatenate_aut ( l ), inv_concatenate_aut ( r ) );
	help = concatenate_aut ( help, l );
	help = concatenate_aut ( help, r );
	copy_vector ( help, resv, dimension );
	POP_STACK();
	return ( resv );
}

VEC generate_aut ( VEC autlist[], VEC ind, int d )
{
	VEC resv, res;
	int j, pow;
	
	resv = ALLOCATE ( g_gens * GNUMGEN );
	PUSH_STACK();
	res = CALLOCATE ( g_gens * GNUMGEN );
	for ( j = 0; j < g_gens; j++ )
		res[j+j*GNUMGEN] = 1;
	for ( j = 0; j < d; j++ ) {
		if ( (pow = ind[j]) != 0 ) {
			res = concatenate_aut ( res, exp_concatenate_aut ( autlist[j], pow ) );
		}
	}
	copy_vector ( res, resv, g_gens * GNUMGEN );
	POP_STACK();
	return ( resv );
}

int ppot ( int n )
/* compute prime^n */
{
	int r = 1;
	for ( ; n--; ) r *= prime;
	return ( r );
}

static VEC class1_list[300000];		/* elements */

/* wrapper functions for concatenation routines */

SHOM *aut_concatenate ( SHOM *l, SHOM *r )
{
    SHOM *res;
    PCGRPDESC *old_pc_group;
    
    if ( (l->h != r->h) || (l->g != r->g) )
	   return ( NULL );
    
    res = ALLOCATE ( sizeof ( SHOM ) );
    res->lift_limit = 0;
    res->h = l->h;
    res->g = l->g;
    res->num_images = l->num_images;
    old_pc_group = group_desc;
    set_main_group ( l->g );
    g_gens = l->num_images;
    dimension = g_gens * GNUMGEN;
    res->image_list = concatenate_aut ( l->image_list, r->image_list );
    set_main_group ( old_pc_group );
    return ( res );
}

SHOM *aut_exp_concatenate ( SHOM *l, int power )
{
    SHOM *res;
    PCGRPDESC *old_pc_group;
    
    res = ALLOCATE ( sizeof ( SHOM ) );
    res->lift_limit = 0;
    res->h = l->h;
    res->g = l->g;
    res->num_images = l->num_images;
    old_pc_group = group_desc;
    set_main_group ( l->g );
    g_gens = l->num_images;
    dimension = g_gens * GNUMGEN;
    res->image_list = exp_concatenate_aut ( l->image_list, power );
    set_main_group ( old_pc_group );
    return ( res );
}

SHOM *aut_inv_concatenate ( SHOM *l )
{
    SHOM *res;
    PCGRPDESC *old_pc_group;
    
    res = ALLOCATE ( sizeof ( SHOM ) );
    res->lift_limit = 0;
    res->h = l->h;
    res->g = l->g;
    res->num_images = l->num_images;
    old_pc_group = group_desc;
    set_main_group ( l->g );
    g_gens = l->num_images;
    dimension = g_gens * GNUMGEN;
    res->image_list = inv_concatenate_aut ( l->image_list );
    set_main_group ( old_pc_group );
    return ( res );
}

SHOM *aut_homom_fetch ( HOM *auts, int class, int no )
{
    int i;
    SHOM *homo;
    int g_gens, h_gens, bperel;

    homo = ALLOCATE ( sizeof ( SHOM ) );

    homo->h = auts->h;
    homo->g = auts->g;
    bperel = auts->g->num_gen;
    g_gens = auts->g->defs ? auts->g->min_gen : bperel;
    h_gens = (class == 0) ? auts->h->num_gen : g_gens;
    homo->num_images = h_gens;
    homo->image_list = ALLOCATE ( h_gens * bperel  );
    homo->lift_limit = auts->g->exp_p_class;

    if ( class == 0 ) {
	   for ( i = 0; i < h_gens; i++ )
		  copy_vector ( auts->epimorphism+i*bperel, 
					 homo->image_list+i*bperel, bperel );
    }
    else {
	   if ( (class > auts->g->exp_p_class) ||
		   (no >= auts->aut_gens_dim[class]) ) {
		  set_error ( NO_SUCH_HOM );
		  homo = NULL;
	   }
	   else {
		  for ( i = 0; i < h_gens; i++ )
			 copy_vector ( auts->aut_gens[class][no]+i*bperel,
						homo->image_list+i*bperel, bperel );
	   }
    }
    return ( homo );
}

SHOM *get_group_homom ( PCGRPDESC *g, LISTP *imlist, GRPDSC *h )
{
    SHOM *homo;
    DYNLIST p;
    int i, num_images;
    
    homo = ALLOCATE ( sizeof ( SHOM ) );
    homo->g = g;
    homo->h = h;
    homo->num_images = num_images = h != NULL ? h->num_gen : g->min_gen;
    homo->image_list = ALLOCATE ( num_images * g->num_gen );
    homo->lift_limit = 0;
    
    i = 0;
    for ( p = imlist->first; p != NULL; p = p->next ) {
	   copy_vector ( ((GE *)p->value.gv)->el, homo->image_list + i*g->num_gen,
				  g->num_gen );
	   i++;
	   if ( i >= num_images ) break;
    }
    
    return ( homo );
}

HOM *generate_automorphism_group ( HOM *hom, int only_outer )
/* only for automorphism groups */
{
	HOM *fauts;
	PCGRPDESC *old_pc_group;
	int i, j, k, ha, hb, auts_order, d;
	int class1_order;
	VEC indvec, help;
	int *dimlist;
	
	old_pc_group = group_desc;
	
	set_main_group ( hom->g );
	
	g_gens = group_desc->defs ? GMINGEN : GNUMGEN;
	dimension = g_gens * GNUMGEN;
	
	fauts = ALLOCATE ( sizeof ( HOM ) );
	fauts->g = hom->g;
	fauts->h = hom->h;
	fauts->elements = TRUE;
	fauts->stabs = NULL;
	
	/* if we do not have inner automorphisms, compute Out(G)
	if ( !hom->with_inner && !only_outer ) {
		only_outer = TRUE;
		set_warning ( NO_INNER_AUTOMORPHISMS );
	} */
	
	dimlist = only_outer == TRUE ? hom->out_gens_dim : hom->aut_gens_dim;
	for ( i = 0, ha = 1; i < hom->out_log; i++, ha *= hom->g->prime );
	
	fauts->aut_gens_dim = CALLOCATE ( (group_desc->exp_p_class+1) * sizeof ( int ) );
	fauts->out_gens_dim = CALLOCATE ( (group_desc->exp_p_class+1) * sizeof ( int ) );
	fauts->aut_gens = ARRAY ( group_desc->exp_p_class+1, VEC* );
	fauts->auts = hom->auts;
	fauts->class1_generators = hom->class1_generators;
	
	fauts->out_log = hom->out_log;
	fauts->inn_log = hom->inn_log;

	if ( hom->elements ) {
		auts_order = aut_dimino ( hom->aut_gens[1], hom->class1_generators, 0, TRUE );
		fauts->auts = auts_order;
	}
	else {
		auts_order = hom->auts * ha;
		if ( !only_outer ) {
			for ( i = 0, hb = 1; i < hom->inn_log; i++, hb *= hom->g->prime );
			auts_order *= hb;
		}
	}

	fauts->aut_gens[1] = ARRAY ( auts_order, VEC );
	fauts->aut_gens_dim[1] = fauts->out_gens_dim[1] = auts_order;
	if ( hom->epimorphism != NULL ) {
		fauts->epimorphism = ALLOCATE ( hom->h->num_gen * GNUMGEN );
		copy_vector ( hom->epimorphism, fauts->epimorphism, hom->h->num_gen * GNUMGEN );
	}
	else
		fauts->epimorphism = NULL;

	/* only element list given, return group generated by its elements */
	if ( hom->elements ) {
		k = 0;
		for ( i = 0; i < auts_order; i++ )
			fauts->aut_gens[1][k++] = class1_list[i];
		set_main_group ( old_pc_group );
		return ( fauts );
	}		

	for ( i = group_desc->exp_p_class; i > 1; i-- ) {
		fauts->aut_gens_dim[i] = ppot ( dimlist[i] );
		fauts->out_gens_dim[i] = ppot ( hom->out_gens_dim[i] );
		if ( i < group_desc->exp_p_class ) {
			fauts->aut_gens_dim[i] *= fauts->aut_gens_dim[i+1];
			fauts->out_gens_dim[i] *= fauts->out_gens_dim[i+1];
		}
		fauts->aut_gens[i] = ARRAY ( fauts->aut_gens_dim[i], VEC );
	}
	for ( i = 1; i <= group_desc->exp_p_class; i++ )
		for ( j = 0; j < fauts->aut_gens_dim[i]; j++ )
			fauts->aut_gens[i][j] = ALLOCATE ( g_gens * GNUMGEN );

	PUSH_STACK();
	for ( i = group_desc->exp_p_class; i > 1; i-- ) {
		d = dimlist[i];
		indvec = CALLOCATE ( d );
		k = 0;
		do {
			PUSH_STACK();
			if ( i == group_desc->exp_p_class )
				copy_vector ( generate_aut ( hom->aut_gens[i], indvec, d ),
				fauts->aut_gens[i][k++], g_gens * GNUMGEN );
			else {
				help = generate_aut ( hom->aut_gens[i], indvec, d );
				for ( j = 0; j < fauts->aut_gens_dim[i+1]; j++ )
					copy_vector ( concatenate_aut ( help, fauts->aut_gens[i+1][j] ),
					fauts->aut_gens[i][k++], g_gens * GNUMGEN );
			}
			POP_STACK();
		} while ( inc_count ( indvec, d ) );
	}
	k = 0;

	/* generate full group of automorphisms != Id on G/P_1(G) */
	class1_order = aut_dimino ( hom->aut_gens[1], hom->class1_generators, hom->auts, FALSE );
	if ( group_desc->exp_p_class > 1 ) {
		for ( i = 0; i < fauts->aut_gens_dim[2]; i++ )
			copy_vector ( fauts->aut_gens[2][i],
			fauts->aut_gens[1][k++], g_gens * GNUMGEN );
		for ( i = 1; i < class1_order; i++ ) {
			help = class1_list[i];
			for ( j = 0; j < fauts->aut_gens_dim[2]; j++ )
				copy_vector ( concatenate_aut ( help, fauts->aut_gens[2][j] ),
				fauts->aut_gens[1][k++], g_gens * GNUMGEN );
		}
	}
	else {
		for ( i = 0; i < class1_order; i++ ) {
			copy_vector ( class1_list[i],
				fauts->aut_gens[1][k++], g_gens * GNUMGEN );
		}
	}		
	POP_STACK();			
	set_main_group ( old_pc_group );
	return ( fauts );
}

VEC aut_Idmat (void)
{
	VEC r = CALLOCATE ( dimension );
	int i;
	
	for ( i = 0; i < g_gens; i++ )
		r[i*GNUMGEN+i] = 1;
		
	return ( r );
}

int aut_isIdmat ( VEC m )
{
	VEC help;
	int i;
	int isid = TRUE;

	PUSH_STACK();
	help = aut_Idmat();
	SUBB_VECTOR ( m, help, dimension );
	POP_STACK();
	for ( i = 0; i < GMINGEN; i++ )
		isid &= iszero ( help+i*GNUMGEN, GMINGEN );
	return ( isid );
}

int is_aut_id ( VEC m )
{
	VEC help;

	help = aut_Idmat();
	return ( !memcmp ( help, m, dimension ) );
}

int n_aut_is_in_elements ( VEC m, int order )
{
	int isin = FALSE;
	int i, j;
	VEC help;
	
	PUSH_STACK();
	help = ALLOCATE ( dimension );
	for ( i = 0; i < order; i++ ) {
		copy_vector ( class1_list[i], help, dimension );
		SUBB_VECTOR ( m, help, dimension );
		isin = TRUE;
		for ( j = 0; j < GMINGEN; j++ )
			isin &= iszero ( help+j*GNUMGEN, GMINGEN );
		if ( isin )
			break;
	}
	POP_STACK();
	return ( isin );
}


int aut_is_in_elements ( VEC m, int order )
{
	int isin = FALSE;
	int i;
	
	for ( i = 0; i < order; i++ ) {
		isin = !memcmp ( class1_list[i], m, dimension );
		if ( isin )
			break;
	}
	return ( isin );
}

int aut_dimino ( VEC m[], int t, int c1order, int all_auts )
{
	int i, j, k;
	int prev_order, rep_pos, order;
	int (*is_in_elements)(VEC,int);
	int (*is_id)(VEC);
	VEC g;
	

	/* set up functions */
	if ( all_auts ) {
		is_in_elements = aut_is_in_elements;
		is_id = is_aut_id;
	}
	else {
		is_in_elements = n_aut_is_in_elements;
		is_id = aut_isIdmat;
	}
	
	/* first element is identity */
	order = 1;
	class1_list[0] = aut_Idmat();

	if ( t == 0 )
		return ( order );
	g = m[0];
	while ( !(*is_id) ( g ) ) {
		if ( g == m[0] ) {
			class1_list[order] = CALLOCATE ( dimension );
			copy_vector ( g, class1_list[order], dimension );
		}
		else
			class1_list[order] = g;
		order++;
		g =  concatenate_aut ( g, m[0] );
	}

	for ( k = 1; k < t; k++ ) {

		if ( !(*is_in_elements) ( m[k], order ) ) {
			/* not redundant */
			
			prev_order = order;
			
			/* add coset of m */
			class1_list[order] = CALLOCATE ( dimension );
			copy_vector ( m[k], class1_list[order], dimension );
			order++;
			for ( j = 1; j < prev_order; j++ )
				class1_list[order++] = concatenate_aut ( class1_list[j], m[k] );
			rep_pos = prev_order;
			do {
				for ( i = 0; i <= k; i++ ) {
					g = concatenate_aut ( class1_list[rep_pos], m[i] );
					if ( !(*is_in_elements) ( g, order ) ) {
						/* add coset */
						
						class1_list[order++] = g;
						for ( j = 1; j < prev_order; j++ )
							class1_list[order++] = concatenate_aut ( class1_list[j], g );
					}
				}
			
				/* position of next representative */
				rep_pos += prev_order;
			} while ( rep_pos < order && (c1order == 0 ? TRUE : order < c1order) );
/*			printf ( "order: %d\n", order ); */
		}
	}
	return ( order );
}


static int idgens;

VEC aut_factorize ( HOM *hom, VEC el, int only_outer )
{
	VEC index, w, wn, a, h;
	int i, j, k, l;
	int first, firsto, dima, dimo, dimg, offset;
	int g_gens, dimension;
	char val;
		
	g_gens = GMINGEN;
	dimension = g_gens * GNUMGEN;
	first = dima = firsto = dimo = 0;
	index = CALLOCATE ( idgens );
	PUSH_STACK();
	w = ALLOCATE ( dimension );
	copy_vector ( el, w, dimension );
	
	for ( i = 2; i <= EXP_P_CLASS; i++ ) {
		PUSH_STACK();
		first += dima;
		firsto += dimo;
		dima = hom->aut_gens_dim[i];
		dimo = hom->out_gens_dim[i];
		dimg = EXP_P_LCS[i].i_dim;
		absolut = ALLOCATE ( g_gens * dimg );
		inhom = ALLOCATE ( dima+1 );
		for ( j = 0; j < dima; j++ ) {
			offset = EXP_P_LCS[i].i_start;
			for ( l = 0; l < g_gens; l++ ) {
				for ( k = 0; k < dimg; k++ )
					matrix[(long)(l*dimg+k)][(long)j] = hom->aut_gens[i][j][offset+k];
				offset += GNUMGEN;
			}
		}
		offset = EXP_P_LCS[i].i_start;
		for ( l = 0; l < g_gens; l++ ) {
			copy_vector ( w+offset, absolut+l*dimg, dimg );
			offset += GNUMGEN;
		}
		k = solve_equations ( dima, dimg*g_gens );
		if ( k == -1 ) 
			puts ( "\ncan't factorize" );
		if ( only_outer == TRUE )
			copy_vector ( inhom, index+firsto, dimo );
		else	
			copy_vector ( inhom, index+first, dima );
		a = aut_Idmat();
		l = only_outer == TRUE ? dimo : dima;
		for ( j = 0; j < l; j++ ) {
			if ( (val=inhom[j]) != 0 ) {
				h = exp_concatenate_aut ( hom->aut_gens[i][j], val );
				a = concatenate_aut ( a, h );
			}
		}
		wn = concatenate_aut ( inv_concatenate_aut ( a ), w );
		copy_vector ( wn , w, dimension );
		POP_STACK();
	}
	POP_STACK();
	return ( index );
}

typedef struct {
	int level;
	int nr;
} AUTNO;


void show_aut_pres ( HOM *hom, int only_outer )
{
	PCGRPDESC *old_pc_group;
	int i, j, offset, dima;
	VEC res;
	AUTNO *liste;
	int *dliste;
	int inner_flag;	
	
	pres_file = stdout;
	if ( !hom->with_inner ) {
		set_error ( NO_INNER_AUTOMORPHISMS );
		return;
	}
	
	old_pc_group = group_desc;
	
	set_main_group ( hom->g );
	
	if ( (hom->out_log == 0 && only_outer) || hom->inn_log == 0 ) {
		fprintf ( pres_file, "SISYPHOS.SISISO := CyclicGroup ( AgWords, 1 );\n" );
		PUSH_STACK();
		/* save flags */
		inner_flag = hom->with_inner;
		hom->with_inner = !only_outer;
		aut_pres_style = IMAGES;
		show_hom ( hom, ".SISAuts" );
		POP_STACK();
		/* restore flags */
		hom->with_inner = inner_flag;
		return;
	}
			
	g_gens = group_desc->defs ? GMINGEN : GNUMGEN;
	dimension = g_gens * GNUMGEN;
	idgens  = 0;
	dliste = only_outer == TRUE ? hom->out_gens_dim : hom->aut_gens_dim;
	for ( i = 2; i <= EXP_P_CLASS; i++ )
		idgens += dliste[i];

	PUSH_STACK();
	liste = ARRAY ( idgens, AUTNO );
	presentation_type = GAP;
	output_prae ( idgens, 0, FALSE, 0, "SISYPHOS.SISISO" );

	offset = dima = 0;
	for ( i = 2; i <= EXP_P_CLASS; i++ ) {
		offset += dima;
		dima = dliste[i];
		for ( j = 0; j < dima; j++ ) {
			liste[offset+j].level = i;
			liste[offset+j].nr = j;
			PUSH_STACK();
			res = exp_concatenate_aut ( hom->aut_gens[i][j], GPRIME );
			output_relation ( aut_factorize ( hom, res, only_outer ), offset+j, 0, TRUE, idgens, 0 );
			POP_STACK();
		}
	}

	for ( i = 1; i < idgens; i++ ) {
		for ( j = 0; j < i; j++ ) {
			PUSH_STACK();
			res = comm_concatenate_aut ( hom->aut_gens[liste[i].level][liste[i].nr],
				hom->aut_gens[liste[j].level][liste[j].nr] );
			if ( !is_aut_id ( res ) ) {
				output_relation ( aut_factorize ( hom, res, only_outer ), i, j, FALSE, idgens, 0 );
			}
			POP_STACK();
		}
	}

	output_post ( idgens, 0, FALSE, "SISYPHOS.SISISO" );
	/* save flags */
	inner_flag = hom->with_inner;
	hom->with_inner = !only_outer;	
	aut_pres_style = IMAGES;
	show_hom ( hom, ".SISAuts" );
	/* restore flags */
	hom->with_inner = inner_flag;
	POP_STACK();
	

	set_main_group ( old_pc_group );

}	

SHOM *evaluate_aut ( LISTP *homlist, LISTP *expl, int len )
{

    SHOM *fres, *help, *res;
    DYNLIST p;
    DYNLIST q;
    int i;
    int val;
    int dim;
    
    dim = ((SHOM *)homlist->first->value.gv)->g->num_gen *
	   ((SHOM *)homlist->first->value.gv)->num_images;
	   
    fres = ALLOCATE ( sizeof ( SHOM ) );
    fres->image_list = ALLOCATE ( dim );
	
    PUSH_STACK();
    help = NULL;
    for ( i = 0, p = homlist->first, q = expl->first; i < len; i++,
          p = p->next, q = q->next ) {
	   if ( (val = *(int *)q->value.gv) != 0 ) {
		  res = aut_exp_concatenate ( (SHOM *)p->value.gv, val );
		  if ( help != NULL )
			 help = aut_concatenate ( help, res );
		  else
			 help = res;
	   }
    }
    
    copy_vector ( help->image_list, fres->image_list, dim );
    fres->g = help->g;
    fres->h = help->h;
    fres->num_images = help->num_images;
    fres->lift_limit = help->lift_limit;
    POP_STACK();
    return ( fres );
}	

int get_class ( VEC rhov )
{
	int class, min, i, j;
	VEC id;
	
	PUSH_STACK();
	id = CALLOCATE ( GMINGEN * GNUMGEN );
	for ( i = 0; i < GMINGEN; i++ )
		id[i+i*GNUMGEN] = 1;
	SUBA_VECTOR ( rhov, id, GMINGEN * GNUMGEN );
	
	min = GNUMGEN;
	for ( i = 0; i < GMINGEN; i++ ) {
		for ( j = 0; j < GNUMGEN; j++ )
			if ( id[i*GNUMGEN+j] != 0 ) break;
		if ( j < min ) min = j;
	}
	
	for ( class = 1; class <= EXP_P_CLASS; class++ )
		if ( EXP_P_LCS[class].i_start <= min &&
			min <= EXP_P_LCS[class].i_end )
		break;
		
	POP_STACK();
	return class;
}

HOM *conv_to_hom ( LISTP *autgens, int list_only )
{
	PCGRPDESC *old_pc_group, *g_desc;
	HOM *autom_rec;
	DYNLIST p;
	VEC rhov;
	SHOM *hom;
	int i, j, class, listdim;
	
	hom = (SHOM *)autgens->first->value.gv;
	g_desc = hom->g;

	old_pc_group = group_desc;
	set_main_group ( g_desc );

	g_gens = hom->num_images;
	dimension = g_gens * GNUMGEN;

	autom_rec = ALLOCATE ( sizeof ( HOM ) );
	autom_rec->g = g_desc;
	autom_rec->h = NULL;
	autom_rec->elements = list_only ? TRUE : FALSE;
	autom_rec->stabs = NULL;
	autom_rec->aut_gens_dim = CALLOCATE ( (g_desc->exp_p_class+1) * 
								   sizeof ( int ) );
	autom_rec->out_gens_dim = CALLOCATE ( (g_desc->exp_p_class+1) * 
								   sizeof ( int ) );
	autom_rec->aut_gens = NULL;
	autom_rec->epimorphism = NULL;
	autom_rec->with_inner = FALSE;
	
	listdim = (list_only ? 1 : EXP_P_CLASS)+1;
	list_aut_gens = ARRAY ( listdim, LISTP );
	for ( i = 1; i <= listdim; i++ ) {
		list_aut_gens[i].first = list_aut_gens[i].last = NULL;
	}
	
	for ( p = autgens->first; p != NULL; p = p->next ) {
	    rhov = CALLOCATE ( g_gens * GNUMGEN );
	    hom = (SHOM *)p->value.gv;
	    copy_vector ( hom->image_list, rhov, dimension );
	    class = list_only ? 1 : get_class ( rhov );
	    autom_rec->aut_gens_dim[class]++;
	    
	    /* save rho in dynamic list */
	    if ( list_aut_gens[class].last == NULL ) {
		   list_aut_gens[class].last = list_aut_gens[class].first = 
			  ALLOCATE ( sizeof ( dynlistitem ) );
	    }
	    else {
		   list_aut_gens[class].last->next = 
			  ALLOCATE ( sizeof ( dynlistitem ) );
		   list_aut_gens[class].last = list_aut_gens[class].last->next;
	    }
	    list_aut_gens[class].last->value.gv = rhov;
	}	
	
	autom_rec->out_log  = autom_rec->inn_log = 0;
	autom_rec->aut_gens = ARRAY ( group_desc->exp_p_class+1, VEC* );
	for ( i = 1; i <= group_desc->exp_p_class; i++ ) {
	    autom_rec->aut_gens[i] = ARRAY ( autom_rec->aut_gens_dim[i], VEC );
	    autom_rec->out_gens_dim[i] = autom_rec->aut_gens_dim[i];
	    if ( i > 1 ) {
		   autom_rec->out_log += autom_rec->out_gens_dim[i];
	    }			
	    p = list_aut_gens[i].first;
	    for ( j = 0; j < autom_rec->aut_gens_dim[i]; j++ ) {
		   autom_rec->aut_gens[i][j] = p->value.gv;
		   p = p->next;
	    }
	}
	autom_rec->class1_generators = autom_rec->aut_gens_dim[1];
	PUSH_STACK();
	autom_rec->auts = list_only ? 0 : aut_dimino ( autom_rec->aut_gens[1],
                autom_rec->class1_generators, 0, FALSE );
	POP_STACK();
	autom_rec->only_normal_auts = 
	    autom_rec->class1_generators == 0 ? TRUE : FALSE;
	
	set_main_group ( old_pc_group );
	return ( autom_rec );
}

/* end of module autgroup */









