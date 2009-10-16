/********************************************************************/
/*  Module        : Group ring automorphism group                   */
/*                                                                  */
/*  Description :                                                   */
/*     Module is used to compute the automorphism group of th       */
/*     group algebra F_pG of a p-group G                            */
/*                                                                  */
/********************************************************************/

/* 	$Id: graut.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: graut.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.5  1995/10/30 08:49:04  pluto
 * 	Corrected handling of the case when no non trivial homomorphisms
 * 	modulo I^2 exist.
 *
 * 	Revision 3.4  1995/08/25 13:44:34  pluto
 * 	Changed order of 'mpz' calls.
 *
 * 	Revision 3.3  1995/08/23 09:56:29  pluto
 * 	Call 'span_space' in 'gr_vs_image'.
 *
 * 	Revision 3.2  1995/08/10 11:45:38  pluto
 * 	Initialized 'old_top' to NULL in 'gr_comp_aut'.
 *
 * 	Revision 3.1  1995/07/28 09:27:53  pluto
 * 	'gr_lift_id' now aborts if free presentation of G is not valid.
 *
 * 	Revision 3.0  1995/06/23 09:40:20  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	Implementation of new algorithm producing a
 * 	generating system for Aut(FG).
 * 	Added support for GNU mp.
 *
 * Revision 2.0  1995/03/20  09:43:18  pluto
 * Bases for the subspaces of lifting spaces are now computed and used.
 *
 * Revision 1.12  1995/03/02  15:03:09  pluto
 * Changed 'gr_lift_control' to keep a maximal epimorphism.
 *
 * Revision 1.11  1995/03/01  16:27:17  pluto
 * Added code to save and restore old values for 'cut' and 'fend'
 * in 'gr_lift_control'.
 *
 * Revision 1.10  1995/02/27  14:52:34  pluto
 * Added support for small group rings in new routines.
 *
 * Revision 1.9  1995/02/13  12:47:10  pluto
 * Corrected range of for loop in gr_comp_aut.
 *
 * Revision 1.8  1995/01/11  16:01:54  pluto
 * Added new function gr_lift_control as interface for
 * new lifting routines.
 * Isomorphism check is now possible.
 *
 * Revision 1.7  1995/01/09  10:40:32  pluto
 * Added <limit> to cut lifting process at FG/I^<limit>.
 *
 * Revision 1.6  1995/01/05  17:24:04  pluto
 * Changed header to new style.
 *
 * Revision 1.5  1995/01/05  16:45:23  pluto
 * Included handling of group automorphisms.
 *
 * Revision 1.4  1994/12/29  13:05:36  pluto
 * Just for fun2.
 *	 */

#ifndef lint
static char vcid[] = "$Id: graut.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "config.h"
#include "aglobals.h"
#include "fdecla.h"
#include <ctype.h>
#include <math.h>
#include "pc.h"
#include "hgroup.h"
#include "grpring.h"
#include "storage.h"
#include "error.h"
#include "aut.h"
#include "graut.h"
#include "solve.h"

#ifdef HAVE_LIBGMP
#include <gmp.h>
#endif

#ifdef UNIX
#ifdef NeXT
#include <libc.h>
#else
#include <unistd.h>
#endif
#include <fcntl.h>
#endif


typedef struct {
    VEC e;
    VEC i_e;
} GRCOUPLE;

#ifdef ANSI
void exit ( int status );
#endif

void init_gl				_(( int dim ));
int is_id 				_(( PCELEM el ));
int inc_el 				_(( PCELEM el ));
PCELEM g_comm				_(( PCELEM el, PCELEM er ));
int g_h1_mat	      		_(( int start, int dim, int *y ));
static void handle_gr_aut 		_(( int class ));
int check_iso 				_(( VEC vector, int c2_dim ));
static VEC *gr_do_reduce 		_(( int *h1_dim, VEC h1[], int d, char *mempt ));
int inc2_count 		_(( VEC coeff, int last ));
VEC aut_Idmat 				_(( void ));
VEC exp_concatenate_aut 		_(( VEC l, int power ));
int aut_isIdmat 			_(( VEC m ));
int is_aut_id	 			_(( VEC m ));
int get_ideal                 _(( int s ));
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
void output_prae 			_(( int len, int start, int unitgrp, int mod_id ));
void output_post 			_(( void ));
void output_relation 		_(( VEC index, int e1, int e2, int is_pow, int len, int start ));
int log_g_order 			_(( register PCELEM el ));
VEC mult_comm                 _(( VEC u1, VEC u2, int mod_id ));
VEC gr_invers                 _(( VEC elem, int mod_id ));
VEC h1_mat_row                _(( int dim, node p ));
void get_op_mats              _(( void ));
void get_all_op_mats          _(( int ncut ));
void get_centralizer          _(( int ncut ));
void save_set                 _(( void ));
void restore_set              _(( void ));
int handle_central_involutions _(( int ydim ));
int gr_single_lift            _(( VEC rho[], int from, int lahead, VEC **h1 ));
int gr_single_verify          _(( VEC rho[], int limit ));
VEC sn_group_mul		_(( VEC vec1, VEC vec2, int cut ));
VEC sngroup_exp		_(( VEC vector, int power, int cut ));
void small_grpring		_(( VEC mask ));
long gl_order            _(( int dim ));
int do_dimino            _(( VEC m[], int l_m, int d ));
VEC gr_image_of_generator    _(( VEC r, int g ));
SPACE *span_space        _(( DYNLIST vl, int len_vl ));

extern int (*get_gl_element)	_(( void ));
extern void (*add_to_list)	_(( void ));
extern void (*add_to_fail_list)	_(( int mark ));

#define GET_GL_ELEMENT (*get_gl_element)
#define ADD_TO_LIST (*add_to_list)
#define ADD_TO_FAIL_LIST (*add_to_fail_list)

extern int prime;
extern PCGRPDESC *group_desc;
extern GRPDSC *h_desc;
extern GRPRING *group_ring;
extern int new_xdim, new_cut, cut, fend, start, rho_dim, part_start;
extern IHEADER h_out;
extern VEC can_to_new[];
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
extern int verbose;
extern VEC *rlist;
extern int blocks;

static int gr_aut_num = 0;
static int gr_out_log;
static int gr_inn_log;

extern HOM *dgroup_auts;
extern VEC *mautgens;
extern int n_mautgens;
static int isfirst = TRUE;
extern VEC gl_mat;
extern VEC ind;
extern COUPLE **zentrum;
extern int critical_class;

extern VEC *centre;
extern VEC *i_centre;
extern int cent_dim;
extern VEC *l_matrix, *r_matrix;

/* algorithm flags */
extern int use_filtration;
extern int use_max_elab_sections;
extern int only_normal_auts;
extern int with_inner;

int elim_grp_aut = TRUE;
extern int elim_central_involutions;

VEC *grho;
int max_id;
int jennings_la = 0;
VEC **lcentre;
VEC **li_centre;
int *lc_dim;
VEC **al_matrix, **ar_matrix;

static int section;
static int gcard;
static int nmin;
static int search_for_iso = FALSE;
static VEC **gr_id_gens;
static VEC **gr_cid_gens;
static VEC **gr_inn_gens;
static VEC **gr_cinn_gens;
static VEC **gr_aut_gens;
static VEC **gr_caut_gens;
static int *gr_id_gens_dim;
static int *gr_aut_gens_dim;
static int *gr_inn_gens_dim;
static LISTP *list_aut_gens;
static GRHOM *hom_rec;
static VEC TI;
static VEC dum_abs;
static int use_gl_iteration;
static int msection;
static int liftid = FALSE;
static int do_compute_centre = TRUE;
static int limit;    /* liftings are only computed up to to FG/I^<limit> */
static int max_lift; /* maximal power of I with isomorphisms 
				    onto FG/I^<max_lift> */
static VEC *epi;     /* epimorphism onto FG/I^<max_lift> */

static GRCOUPLE **gr_orbgen; /* generators for inner automorphisms */
static int *gr_orbgen_cnt;   /* numbers of generators of inner automorphosms */
static VEC **gr_gauts;       /* generators for group automorphisms */
static int *gr_gauts_cnt;    /* numbers of generators of group automorphisms */
static int gr_comp_inner = TRUE;  /* compute inner automorphisms */
static int gr_comp_gauts = TRUE;  /* compute group automorphisms */

static VEC gr_obstr ( node p )
/* compute the obstruction corresponding to the
   relation given as expression tree <p> */
{
	register VEC h1;
	register VEC obs;
	int fend = FILTRATION[cut].i_start;
	
	obs = GRZERO;
	PUSH_STACK();

	switch ( p->nodetype ) {
		case GGEN:
				copy_vector ( grho[p->value], obs, fend );
				break;
		case EQ  :
				if ( p->right != NULL )
					copy_vector ( gr_obstr ( p->right ), obs, fend );
				SUBA_VECTOR ( gr_obstr ( p->left ), obs, fend );
				break;
		case COMM:
				h1 = mult_comm ( gr_obstr ( p->left ), gr_obstr ( p->right ), cut );
				copy_vector ( h1, obs, fend );
				break;
		case EXP :
				h1 = GROUP_EXP ( gr_obstr ( p->left ), (p->value > 0) ? p->value : -p->value, cut );
				if ( p->value < 0 )
					h1 = gr_invers ( h1, cut );
				copy_vector ( h1, obs, fend );
				break;
		case MULT:
				copy_vector ( GROUP_MUL ( gr_obstr ( p->left ), gr_obstr ( p->right ), cut ), obs, fend );
				break;
		default:
				puts ( "(gr_obstr) Error in relation" );
	}
	POP_STACK();
	return ( obs );
}

void get_centralizer ( int ncut )
{
    centre = lcentre[ncut];
    i_centre = li_centre[ncut];
    cent_dim = lc_dim[ncut];
}

void get_all_op_mats ( int ncut )
{
    l_matrix = al_matrix[ncut];
    r_matrix = ar_matrix[ncut];
}

void gr_get_centralizer ( int lift_limit )
/* compute the centralizers of FG/I^n for 
   n = 2 to <lift_limit>.
   Note: To compute all liftings from FG/I^n to FG/I^(n+1), lcentre[n+1] and
   li_centre[n+1] are needed.
   */
{
    int i, xd;

    lcentre = ARRAY ( max_id+1, VEC* );
    li_centre = ARRAY ( max_id+1, VEC* );
    lc_dim = ARRAY ( max_id+1, int );
    
    lcentre[0] = lcentre[1] = lcentre[2] = NULL;
    li_centre[0] = li_centre[1] = li_centre[2] = NULL;

    for ( i = 3; i <= lift_limit; i++ ) {
	   /* Note: lcentre[i] = centralizer modulo I^(i-1) ! */
	   xd = FILTRATION[i].i_start;
/*	   printf ( "centralizer no. %d\n", i ); */
	   centralizer ( NGEN_VEC, i, GMINGEN );
	   lcentre[i] = centre;
	   li_centre[i] = i_centre;
	   lc_dim[i] = cent_dim;
    }
}

void gr_get_all_op_mats ( int lift_limit )
/* compute the matrices describing the FG-module operation on
   I^n/I^(2n). The matrices for left operation are stored in al_matrix[n],
   those for right operation in ar_matrix[n]. 
   Note: To compute all liftings from FG/I^n to FG/I^(n+1), al_matrix[n] and
   ar_matrix[n] are needed.
   */
{
    int i, j;
    
    al_matrix = ARRAY ( max_id+1, VEC* );
    ar_matrix = ARRAY ( max_id+1, VEC* );
    
    al_matrix[0] = al_matrix[1] = ar_matrix[0] = ar_matrix[1] = NULL;

    /* e = (max_id & 1) == 0 ? max_id >> 1 : (max_id >> 1) + 1; */
    for ( i = 2; i < lift_limit; i++ ) {
	   cut = i<<1;
	   if ( cut > max_id )
		  cut = max_id;
	   start = rho_dim = FILTRATION[i].i_start;
	   fend	= FILTRATION[cut].i_start;
	   dim = fend - start;
	   dquad = dim * dim;
	   l_matrix = ARRAY ( rho_dim, VEC );
	   r_matrix = ARRAY ( rho_dim, VEC );
	   for ( j = rho_dim; j--; ) {
		  l_matrix[j] = ALLOCATE ( dquad );
		  r_matrix[j] = ALLOCATE ( dquad );
	   }
	   get_op_mats();
	   al_matrix[i] = l_matrix;
	   ar_matrix[i] = r_matrix;
    }
}

/* this routine is not yet used */
/*
static int gr_h1_mat ( int start, int dim, int *y )
{
	VEC rel_obs;
	int i, j, k;
	int offset = 0;
	
	*y = 0;
*/	
	/* if ( !use_filtration )
		completely_liftable = TRUE; */
/*	PUSH_STACK(); */
	
	/* setup matrix for system of linear equations by tensoring
	   <gl_mat> with identity matrix of dimension <dim>, where
	   <dim> is the dimension of I^n/I^(n+1). */

/*	for ( i = 0; i < NUMREL; i++ ) {
		for ( k = 0; k < dim; k++ ) {
			zero_vector ( matrix[(long)(offset+k)], dim*NUMGEN );
			for ( j = 0; j < NUMGEN; j++ )
				matrix[(long)(offset+k)][(long)(k+j*dim)] = 
				    gl_mat[(long)i*NUMGEN+(long)j];
		}
		rel_obs = gr_obstr( RELATION[i] ); */
		/* if ( !use_filtration )
			completely_liftable &= iszero ( rel_obs+start, GCARD-start ); */
/*		if ( ind[i] ) {
			if ( !iszero ( rel_obs+start, dim ) ) {
				POP_STACK();
				return ( FALSE );
			}
		}
		else {
			*y += dim;	
			SMUL_VECTOR ( prime - 1, rel_obs+start, dim );
			copy_vector ( rel_obs+start, absolut+offset, dim );
			offset += dim;
		}
	}
	POP_STACK();
	return ( TRUE );
}
*/

static void handle_gr_aut ( int class )
/* collect generators of automorphism group
   list_aut_gens[n] contains automorphisms modulo I^(n+1) */
{
	register int j;
	VEC sr;
	int gens;
	
	gens = group_desc->defs ? GMINGEN : GNUMGEN;
	
	/* save grho in dynamic list */
	if ( list_aut_gens[class].last == NULL ) {
		list_aut_gens[class].last = list_aut_gens[class].first = ALLOCATE ( sizeof ( dynlistitem ) );
	}
	else {
		list_aut_gens[class].last->next = ALLOCATE ( sizeof ( dynlistitem ) );
		list_aut_gens[class].last = list_aut_gens[class].last->next;
	}
	sr = list_aut_gens[class].last->value.gv = ALLOCATE ( gens * GCARD );
	for ( j = 0; j < gens; j++ )
		copy_vector ( grho[j], sr + j*GCARD, GCARD );
	list_aut_gens[class].last->next = NULL;
	hom_rec->aut_gens_dim[class]++;
	
	gr_aut_num++;
}

static void gr_handle_inner_aut ( int lift_limit )
{
	int i, j, k;
	VEC sr;
	VEC iel, el;
	int gens;
	
	gens = group_desc->defs ? GMINGEN : GNUMGEN;
	
	for ( i = 2; i < lift_limit; i++ ) {
		hom_rec->out_gens_dim[i] = hom_rec->aut_gens_dim[i];
		hom_rec->aut_gens_dim[i] += gr_orbgen_cnt[i+1];
		for ( j = 0; j < gr_orbgen_cnt[i+1]; j++ ) {
		    if ( list_aut_gens[i].last == NULL ) {
			   list_aut_gens[i].last = list_aut_gens[i].first = ALLOCATE ( sizeof ( dynlistitem ) );
		    }
		    else {
			   list_aut_gens[i].last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			   list_aut_gens[i].last = list_aut_gens[i].last->next;
		    }
		    sr = list_aut_gens[i].last->value.gv = ALLOCATE ( gens * GCARD );
		    iel = gr_orbgen[i+1][j].i_e;
		    el = gr_orbgen[i+1][j].e;
		    PUSH_STACK();
		    for ( k = 0; k < gens; k++ ) {
			   copy_vector ( GROUP_MUL ( iel, GROUP_MUL ( 
				  group_ring->ngen_vec[k], el, max_id ), max_id ), 
						  sr + k* GCARD, GCARD );
			   sr[k*GCARD] = 1;
		    }
		    POP_STACK();
		}
	}
}

static void gr_handle_gauts ( int lift_limit )
{
	int i, j, k, l;
	VEC sr;
	VEC el, res, zwres;
	int gens, stabs_n;
	int fend = FILTRATION[max_id].i_start;
	char val;
	
	gens = group_desc->defs ? GMINGEN : GNUMGEN;
	

	/* handle automorphisms which are <> Id on FG/I^2 */
	
	hom_rec->mod_grauts_gens_dim = ARRAY ( lift_limit, int );
	for ( i = 1; i < lift_limit; i++ ) {
	    stabs_n = 0;
	    if ( i > 1 )
		   while ( dgroup_auts->stabs[i][stabs_n] != -1 ) stabs_n++;
	    hom_rec->mod_grauts_gens_dim[i] = gr_gauts_cnt[i+1];
	    hom_rec->aut_gens_dim[i] += gr_gauts_cnt[i+1];
	    for ( j = 0; j < gr_gauts_cnt[i+1]; j++ ) {
		   if ( list_aut_gens[i].last == NULL ) {
			  list_aut_gens[i].last = list_aut_gens[i].first = ALLOCATE ( sizeof ( dynlistitem ) );
		   }
		   else {
			  list_aut_gens[i].last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			  list_aut_gens[i].last = list_aut_gens[i].last->next;
		   }
		   sr = list_aut_gens[i].last->value.gv = ALLOCATE ( gens * GCARD );
		   for ( k = 0; k < gens; k++ ) {
			  copy_vector ( NGEN_VEC[k], sr+k*GCARD, GCARD );
			  sr[k*GCARD] = 1;
		   }
		   
		   if ( i > 1 ) {
			  el = gr_gauts[i+1][j];
			  for ( l = 0; l < stabs_n; l++ ) {
				 val = el[l];
				 for ( ;val;val-- ) {
					for ( k = 0; k < gens; k++ ) {
					    PUSH_STACK();
					    res = n_apply ( dgroup_auts->stabs[i][l],
									sr+k*GCARD, max_id );
					    copy_vector ( res, sr+k*GCARD, GCARD );
					    POP_STACK();
					}
				 }
			  }
		   }
		   else {
			  /* automorphisms which are <> Id on FG/I^2 */
			  for ( k = 0; k < gens; k++ ) {
				 PUSH_STACK();
				 GRIDENTITY( res );
				 GRIDENTITY( zwres );
				 for ( l = 0; l < gens; l++ ) {
					if ( (val=mautgens[j][(gens-1-l)*gens + gens-1-k]) != 0 ) {
					    copy_vector ( NGEN_VEC[l]+1, zwres+1, fend-1 );
					    zwres = GROUP_EXP ( zwres, val, max_id );
					    res = GROUP_MUL ( res, zwres, max_id );
					}
				 }
				 copy_vector ( res, sr+k*GCARD, fend );
				 POP_STACK();
			  }
		   }
	    }
	}
}


void gr_gen_inner ( int lift_limit )
{
	register int i, k;
	int j;
	int section;
	VEC  z, i_z, res;
	char **PM = NULL;
	int s, d, x;
	char val;
	VEC help, zwres;
	
	if ( gr_comp_inner ) {
	    gr_orbgen_cnt = ARRAY ( lift_limit+1, int );
	    gr_orbgen = ARRAY ( lift_limit+1, GRCOUPLE* );
	    gr_orbgen_cnt[0] = gr_orbgen_cnt[1] = gr_orbgen_cnt[2] = 0;
	}

	for ( section = lift_limit; section > 2; section-- ) {

		d = FILTRATION[section-1].i_dim;
		s = FILTRATION[section-1].i_start;
		x = d * NUMGEN;
	
		k = lc_dim[section];
		gr_inn_gens[section] = ARRAY ( k,  VEC  );

		for ( i = 0; i < k; i++ ) {
			z = lcentre[section][i];
			i_z = li_centre[section][i];
			gr_inn_gens[section][i] = CALLOCATE ( x );
			for ( j = NUMGEN; j--; ) {
				PUSH_STACK();
				res = GROUP_MUL ( group_ring->ngen_vec[j], z, section );
				res = GROUP_MUL ( i_z, res, section );
				copy_vector ( res+s, gr_inn_gens[section][i]+j*d, d );
				POP_STACK();
			}
		}
		if ( gr_comp_inner ) {
		    PM = ARRAY ( k, VEC );
		    for ( i = 0; i < k; i++ )
			   PM[i] = ALLOCATE ( k );
		}
		    
		k = gr_inn_gens_dim[section] = get_rank ( gr_inn_gens[section], k, 
										  x, TRUE, PM );
		gr_cinn_gens[section] = ARRAY ( k,  VEC  );
		for ( i = 0; i < k; i++ ) {
		    gr_cinn_gens[section][i] = CALLOCATE ( x );
		    copy_vector ( gr_inn_gens[section][i], gr_cinn_gens[section][i],
					   x );
		}
		
		/* compute orbit generators */
		gr_orbgen_cnt[section] = 0;
		if ( gr_comp_inner && ( k > 0) ) {
		    gr_orbgen[section] = ARRAY ( k, GRCOUPLE );
		    k = lc_dim[section];
		    for ( i = 0; i < k; i++ ) {
			   if ( !iszero ( PM[i], k ) ) {
				  GRIDENTITY ( res );
				  gr_orbgen[section][gr_orbgen_cnt[section]].e = res;
				  PUSH_STACK();
				  GRIDENTITY ( help );
				  z = GRZERO;
				  for ( j = 0; j < k; j++ ) {
					if ( (val=PM[i][j]) != 0 ) {
					    copy_vector ( lcentre[section][j], z, s+d );
					    zwres = GROUP_EXP ( z, val, max_id );
					    help = GROUP_MUL ( help, zwres, max_id );
					}
				  }
				  copy_vector ( help, res, FILTRATION[max_id].i_start );
				  POP_STACK();
				  gr_orbgen[section][gr_orbgen_cnt[section]].i_e = 
					 gr_invers ( res, max_id );
				  gr_orbgen_cnt[section]++;
			   }
		    }
		}
	}
}

void gr_gen_groupaut ( int lift_limit )
/* compute modifications corresponding to group automorphisms of G */
{
	register int i, k;
	int j, stabs_n;
	int section;
	VEC res;
	int s, d, x;
	char **PM = NULL;
	HOM *maps = dgroup_auts;
	
	if ( gr_comp_gauts ) {
	    gr_gauts_cnt = ARRAY ( lift_limit+1, int );
	    gr_gauts = ARRAY ( lift_limit+1, VEC* );
	    gr_gauts_cnt[0] = gr_gauts_cnt[1] = 0;
	    gr_gauts_cnt[2] = n_mautgens;
	}

	for ( section = lift_limit; section > 2; section-- ) {

		d = FILTRATION[section-1].i_dim;
		s = FILTRATION[section-1].i_start;
		x = d * NUMGEN;
	
		k = 0;
		while ( maps->stabs[section-1][k] != -1 ) k++;
		gr_aut_gens_dim[section] = stabs_n = k;
		gr_aut_gens[section] = ARRAY ( k,  VEC  );

		for ( i = 0; i < k; i++ ) {
		    gr_aut_gens[section][i] = CALLOCATE ( x );
		    PUSH_STACK();
		    for ( j = 0; j < GMINGEN; j++ ) {
			   res = n_apply ( maps->stabs[section-1][i], 
							 NGEN_VEC[j], max_id );
			   copy_vector ( res+s, gr_aut_gens[section][i]+j*d, d );
		    }
		    POP_STACK();
		}
		if ( gr_comp_gauts ) {
		    PM = ARRAY ( k, VEC );
		    for ( i = 0; i < k; i++ )
			   PM[i] = ALLOCATE ( k );
		}

		k = gr_aut_gens_dim[section] = get_rank ( gr_aut_gens[section], k, 
										  x, TRUE, PM );
		gr_caut_gens[section] = ARRAY ( k,  VEC  );
		for ( i = 0; i < k; i++ ) {
		    gr_caut_gens[section][i] = CALLOCATE ( x );
		    copy_vector ( gr_aut_gens[section][i], gr_caut_gens[section][i],
					   x );
		}

		/* compute orbit generators */
		gr_gauts_cnt[section] = 0;
		if ( gr_comp_gauts && ( k > 0) ) {
		    gr_gauts[section] = ARRAY ( k, VEC );
		    k = stabs_n;
		    for ( i = 0; i < k; i++ ) {
			   if ( !iszero ( PM[i], k ) ) {
				  gr_gauts[section][gr_gauts_cnt[section]] = PM[i];
				  gr_gauts_cnt[section]++;
			   }
		    }
		}
	}
}

static VEC *gr_do_reduce ( int *h1_dim, VEC h1[], int ncut, char *mempt )
/* factor out parameters belonging to inner automorphisms
   and parameters stemming from liftings of the identity */
{
	register int i, j;
	int k = 0;
	int d, e, oe, nxd;
	VEC *compl_h1;

	d = FILTRATION[ncut-1].i_dim;
	e = FILTRATION[ncut].i_start;
	oe = FILTRATION[ncut-1].i_start;
	nxd = NUMGEN * d;
	
	/* parameters corresponding to inner automorphisms */
 	for ( i = 0; i < gr_inn_gens_dim[ncut]; i++ ) {
	    copy_vector ( gr_cinn_gens[ncut][i], matrix[k], nxd ); 
	    k++;
 	}

	/* parameters correspondig to group automorphisms of G */
 	if ( gr_aut_gens_dim[ncut] != 0 ) {
	    for ( i = 0; i < gr_aut_gens_dim[ncut]; i++ ) {
		   copy_vector ( gr_caut_gens[ncut][i], matrix[k], nxd );
		   k++;
	    }
 	}
	
	/* parameters corresponding to liftings of the identity */
 	if ( gr_id_gens_dim[ncut] != -1 ) {
	    for ( i = 0; i < gr_id_gens_dim[ncut]; i++ ) {
		   copy_vector ( gr_cid_gens[ncut][i], matrix[k], nxd );
		   k++;
	    }
 	}

	j = k;
	for ( i = *h1_dim; i--; )
		copy_vector ( h1[i], matrix[k++], nxd );
	/* reset memory pointer */
	if ( mempt != NULL )
	    SET_TOP ( mempt );
	*h1_dim = dcomplement ( matrix, j, nxd, k, &compl_h1 );
	return ( compl_h1 );
}

int olift_grho ( int curr_sec )
/* lift homomorphisms FG/I^curr_sec -> FG/I^(curr_sec + delta) */
{
	int i;
	int j = 0;
	VEC *h1;
	VEC ind_vec;
	char *h1_mod;
	char *ih_save;
	int h1_dim;
	int is_iso = FALSE;
	int d, s, x;
	char val;
	char *old_top;
	
	section = curr_sec;
	if ( section == limit )
	    /* we have indeed a homomorphisms */
	    return ( TRUE );
	
	/* if ( use_filtration ) {
		old_class = set_group_quotient ( section );
		set_number_of_relations ( section );
	} */
	
	d = FILTRATION[section].i_dim;
	s = FILTRATION[section].i_start;
	x = d * NUMGEN;
	
	if ( section > 1 ) {
		for ( i = NUMGEN; i--; )
			zero_vector ( grho[i]+s, GCARD-s );
	}

	old_top = GET_TOP();
	
	h1_dim = gr_single_lift ( grho, section, 0, &h1 );
	
	if ( h1_dim != -1 ) {
	    if ( max_lift < section+1 ) {
		   max_lift = section + 1;
		   /* save epimorphism */
		   for ( j = 0; j < NUMGEN; j++ )
			  copy_vector ( grho[j], epi[j], GCARD );
	    }
	    is_iso = TRUE;
	    ih_save = ALLOCATE ( x );

	    /* save special solution/lifting */
	    for ( j = 0; j < NUMGEN; j++ )
		   copy_vector ( grho[j]+s, ih_save+j*d, d );
	    ind_vec = CALLOCATE ( h1_dim );
	    h1_mod = ALLOCATE ( x );
	    
	    if ( is_iso ) {
		   do {
			  zero_vector ( h1_mod, x );
			  for ( i = h1_dim; i--; ) {
				 if ( ( val = ind_vec[i] ) != 0 ) {
					ADD_MULT ( val, h1[i], h1_mod, x );
				 }
			  }
			  for ( i = NUMGEN; i--; ) {
				 copy_vector ( ih_save+i*d, grho[i]+s, d );
				 ADD_VECTOR ( h1_mod+i*d, grho[i]+s, d );
			  }
			  is_iso = olift_grho ( curr_sec + 1 );
		   } while ( inc_count ( ind_vec, h1_dim ) && !is_iso);
	    } /* if is_iso */
	}
	SET_TOP ( old_top );
	return ( is_iso );
}

int gr_lift_id ( void )
{
	int i, j, k;
	VEC *h1;
	VEC ind_vec;
	char *h1_mod;
	VEC *srho;
	int h1_dim;
	int d, s, x;
	char val;
	int found;
	int dc;
	VEC ih_save;
	
	liftid = TRUE;
	gr_out_log = 0;
	
	/* old_class = set_group_quotient ( 0 );
	set_number_of_relations ( old_class ); */
	
	srho = ARRAY ( NUMGEN, VEC );
	for ( i = 0; i < NUMGEN; i++ ) {
		srho[i] = GRZERO;
		copy_vector ( grho[i], srho[i], fend );
	}
	for ( i = limit-1; i > 1; i-- ) {
		section = msection = i;
		/* printf ( "section: %d", section ); */
		/* we are lifting from FG/I^i to FG/I^(i+1) */

		d = FILTRATION[section].i_dim;
		s = FILTRATION[section].i_start;
		x = d * NUMGEN;
	
		/* reset grho */
		for ( k = NUMGEN; k--; ) {
			copy_vector ( srho[k], grho[k], s );
			zero_vector ( grho[k]+s, GCARD-s );
		}
	
		ih_save = ALLOCATE ( x );
		
		/* try to lift rho */
		h1_dim = gr_single_lift ( grho, i, 0, &h1 );
		if ( h1_dim < 0 ) {
		    /* short presentation is not valid */
		    fprintf ( stderr, "ERROR: free presentation for G is invalid\n" );
		    set_error ( SPECIAL_ERROR );
		    return ( FALSE );
		}
		
		if ( verbose )
		    printf ( "in lift_id: class %d - dim(H1): %d\n", i, h1_dim );
		
          /* save special solution/lifting */
		for ( j = 0; j < NUMGEN; j++ )
		    copy_vector ( grho[j]+s, ih_save+j*d, d );

		/* save parameters */
		gr_id_gens[i+1] = ARRAY ( h1_dim,  VEC  );
		gr_cid_gens[i+1] = ARRAY ( h1_dim,  VEC  );
		dc = 0;
		if ( i == limit-1 ) {
			gr_id_gens_dim[i+1] = h1_dim;
			for ( j = h1_dim; j--; ) {
				gr_id_gens[i+1][dc] = ALLOCATE ( x );
				gr_cid_gens[i+1][dc] = ALLOCATE ( x );
				copy_vector ( h1[j], gr_cid_gens[i+1][dc], x );
				copy_vector ( h1[j], gr_id_gens[i+1][dc++], x );
				for ( k = NUMGEN; k--; ) {
					copy_vector ( ih_save+k*d, grho[k]+s, d );
					ADD_VECTOR ( h1[j]+k*d, grho[k]+s, d );
				}
				handle_gr_aut ( i );
				gr_out_log++;
			}
		}
		else {
			h1_mod = ALLOCATE ( x );
			while ( h1_dim > 0 ) {
				ind_vec = CALLOCATE ( h1_dim );
				ind_vec[h1_dim-1] = 1;
				found = FALSE;
				do {
					zero_vector ( h1_mod, x );
					for ( j = h1_dim; j--; ) {
						if ( ( val = ind_vec[j] ) != 0 ) {
							ADD_MULT ( val, h1[j], h1_mod, x );
						}
					}
					for ( j = NUMGEN; j--; ) {
						zero_vector ( grho[j]+s, GCARD - s );
						if ( j < NUMGEN ) {
							copy_vector ( ih_save+j*d, grho[j]+s, d );
							ADD_VECTOR ( h1_mod+j*d, grho[j]+s, d );
						}
					}
					found = olift_grho ( i + 1 );
				} while ( inc2_count ( ind_vec, h1_dim ) && !found );

				if ( found ) {
					gr_id_gens[i+1][dc] = ALLOCATE ( x );
					gr_cid_gens[i+1][dc] = ALLOCATE ( x );
					copy_vector ( h1_mod, gr_cid_gens[i+1][dc], x );
					copy_vector ( h1_mod, gr_id_gens[i+1][dc++], x );
					handle_gr_aut ( i );
					gr_out_log++;
					copy_vector ( h1_mod, matrix[0], NUMGEN*d );
					k = 1;
					for ( j = h1_dim; j--; )
						copy_vector ( h1[j], matrix[k++], NUMGEN*d );
					h1_dim = complement ( 1, NUMGEN*d, k );
					for ( j = h1_dim; j--; )
						h1[j] = fsolution[j];
				}
				else
					h1_dim = 0;
			}
			gr_id_gens_dim[i+1] = dc;
			if ( verbose )
			    printf ( "after reduction: dim(H1): %d\n", dc );
		}
	}
	/* if ( use_filtration ) {
		set_group_quotient ( old_class );
		set_number_of_relations ( old_class );
	} */
	liftid = FALSE;
	return ( TRUE );
}
		

void prepare_grho ( int isfirst )
{
    int i, j, k, l;
    int d, x;
    VEC vec;
    char val;
    
    PUSH_STACK();
    /* copy mat \in GL(nmin,P) to grho list in reverse order. 
	  Note that the generators are sorted in reverse order
	  with respect to the Jennings basis. mat is changed too. */

    for ( i = 0; i < nmin; i++ ) {
	   copy_vector ( mat+i*nmin, grho[nmin-i-1]+1, nmin );
	   zero_vector ( grho[i]+nmin+1, GCARD - nmin - 1 );
    }
    
    for ( i = 0; i < nmin; i++ )
	   copy_vector ( grho[i]+1, mat+i*nmin, nmin );

    for ( i = nmin; i < NUMGEN; i++ )
	   zero_vector ( grho[i], GCARD );
    
    if ( !isfirst ) {
	   /* we have to set dim and dquad for MATRIX_MUL to work !!! */
	   dim = nmin;
	   dquad = nmin*nmin;
	   vec = MATRIX_MUL ( mat, TI );
	   for ( i = limit; i > 2; i-- ) {
		  d = FILTRATION[i-1].i_dim;
		  x = d * nmin;
		  /* condider gr_(c)id_gens[i][j] as nmin x d matrix,
			then: gr_cid_gens = mat*TI*gr_id_gens */
		  for ( j = 0; j < gr_id_gens_dim[i]; j++ ) {
			 zero_vector ( gr_cid_gens[i][j], x );
			 for ( k = 0; k < nmin; k++ ) 
				for ( l = 0; l < nmin; l++ )
				    if ( (val=vec[k*nmin+l]) != 0 )
					   ADD_MULT ( val, gr_id_gens[i][j]+l*d, 
							    gr_cid_gens[i][j]+k*d, d );
		  }
		  /* condider gr_(c)aut_gens[i][j] as nmin x d matrix,
			then: gr_caut_gens = mat*TI*gr_aut_gens */
		  for ( j = 0; j < gr_aut_gens_dim[i]; j++ ) {
			 zero_vector ( gr_caut_gens[i][j], x );
			 for ( k = 0; k < nmin; k++ ) 
				for ( l = 0; l < nmin; l++ )
				    if ( (val=vec[k*nmin+l]) != 0 )
					   ADD_MULT ( val, gr_aut_gens[i][j]+l*d, 
							    gr_caut_gens[i][j]+k*d, d );
		  }
		  
		  /* condider gr_(c)inn_gens[i][j] as nmin x d matrix,
			then: gr_cinn_gens = mat*TI*gr_inn_gens */
		  for ( j = 0; j < gr_inn_gens_dim[i]; j++ ) {
			 zero_vector ( gr_cinn_gens[i][j], x );
			 for ( k = 0; k < nmin; k++ ) 
				for ( l = 0; l < nmin; l++ )
				    if ( (val=vec[k*nmin+l]) != 0 )
					   ADD_MULT ( val, gr_inn_gens[i][j]+l*d, 
							    gr_cinn_gens[i][j]+k*d, d );
		  }
	   }
    }
    POP_STACK();
}				 


void prepare_gr_trafo ( void )
{
	int i, j;
	
	TI = ALLOCATE ( nmin*nmin );
	for ( i = 0; i < nmin; i++ ) {
		copy_vector ( mat+i*nmin, matrix[i], nmin );
	}
	gauss_p_eliminate ( nmin, nmin );
	for ( i = 0; i < nmin; i++ )
		for ( j = 0; j < nmin; j++ )
			if ( matrix[i][j] != 0 ) {
				copy_vector ( matrix[i]+nmin, TI+j*nmin, nmin );
				break;
			}
}

int gr_class1_group ( VEC ml[], int l_ml, int d )
/* Compute the order of the subgroup of GL(d,p) that is induced
   by the automorphism group of FG/I^n.
   <ml> is a generating set of automorphisms (modulo I^2),
   <l_ml> is the cardinality of the set and <d> the minimal number
   of generators of G.
   */
{
    int i, j, k, order;
    VEC *m;
    
    PUSH_STACK();
    m = ARRAY ( l_ml, VEC );
    for ( i = 0; i < l_ml; i++ ) {
	   m[i] = ALLOCATE ( d*d );
	   for ( j = 0; j < d; j++ )
		  for ( k = 0; k < d; k++ )
			 m[i][j*d+k] = ml[i][j*GCARD+d-k];
    }
    order = do_dimino ( m, l_ml, d );
    POP_STACK();
    return ( order );
}

int gr_comp_aut ( GRPDSC *h, GRPDSC *g, int gl_iteration, 
			   int test_iso, int lift_limit )
{
    int i, j, k, mnumrel;
    int auts = 0;
    /* int c2_dim;
    VEC c2_vector; */
    int isomorphic = FALSE;
    void *old_top = NULL;
    int valid = TRUE;
    DYNLIST p;
    VEC *trho;
    GRPDSC *old_p_group;

    old_p_group = h_desc;

    gcard = GCARD;
    limit = lift_limit > max_id ? max_id : lift_limit;
    
    set_h_group ( h );

    gr_aut_num = max_lift = 0;
    isfirst = TRUE;
    search_for_iso = test_iso;
    
    gr_get_centralizer ( limit );
    gr_get_all_op_mats ( limit );

    dim = nmin = GMINGEN;
    dquad = dim * dim;
    
    if ( test_iso )
	   mnumrel = h->num_rel > g->num_rel ? h->num_rel : g->num_rel;
    else
	   mnumrel = h->num_rel;

    absolut = ALLOCATE ( mnumrel * GCARD );
    dum_abs = CALLOCATE ( GCARD*GCARD );
    ind = CALLOCATE ( mnumrel );
    
    hom_rec = ALLOCATE ( sizeof ( GRHOM ) );
    hom_rec->g = group_desc;
    hom_rec->h = h;
    hom_rec->gg = g;
    hom_rec->elements = FALSE;
    hom_rec->aut_gens_dim = CALLOCATE ( (limit) * sizeof ( int ) );
    hom_rec->out_gens_dim = CALLOCATE ( (limit) * sizeof ( int ) );
    hom_rec->aut_gens = NULL;
    hom_rec->epimorphism = NULL;
    hom_rec->with_inner = TRUE;
    hom_rec->only_normal_auts = only_normal_auts;

    if ( do_compute_centre ) {
	   gr_id_gens = ARRAY ( limit+1,  VEC* );
	   gr_cid_gens = ARRAY ( limit+1, VEC* );
	   gr_inn_gens = ARRAY ( limit+1,  VEC* );
	   gr_cinn_gens = ARRAY ( limit+1, VEC* );
	   gr_aut_gens = ARRAY ( limit+1, VEC* );
	   gr_caut_gens = ARRAY ( limit+1, VEC* );
	   gr_id_gens_dim = ARRAY ( limit+1, int  );
	   gr_inn_gens_dim = ARRAY ( limit+1, int  );
	   gr_aut_gens_dim = ARRAY ( limit+1, int  );
    }

    /* compute vector spaces corresponding to inner automorphisms */
    gr_gen_inner ( limit );
    /* compute vector spaces corresponding to group automorphisms */
    gr_gen_groupaut ( limit );

    
    list_aut_gens = ARRAY ( limit+1, LISTP );
    for ( i = 1; i <= limit+1; i++ ) {
	   gr_id_gens_dim[i] = -1;
	   list_aut_gens[i].first = list_aut_gens[i].last = NULL;
    }
    /* set_len(); */
    
    /* compute coefficient matrix of system of linear equations
    
    gl_mat = CALLOCATE ( NUMGEN*NUMREL );
    for ( i = 0; i < NUMREL; i++ ) {
	   copy_vector ( h1_mat_row ( NUMGEN, RELATION[i] ),
				  gl_mat+(long)i*NUMGEN, NUMGEN );
	   if ( iszero ( gl_mat+i*NUMGEN, NUMGEN ) )
		  ind[i] = 1;
    } */
    
    /* if ( do_compute_centre ) {
		  comp_centre();
		  gr_inn_log = gen_inner();
    } */

    inhom = ALLOCATE ( NUMGEN * GCARD );
    grho = ARRAY ( NUMGEN, VEC );
    epi = ARRAY ( NUMGEN, VEC );

    for ( i = 0; i < NUMGEN; i++ ) {
	   grho[i] = GRZERO;
	   epi[i] = GRZERO;
	   grho[i][GMINGEN-i] = grho[i][0] = 1;
    }
	
    /* loop over gl(nmin,Fp) */
    use_gl_iteration = gl_iteration;
    
    mat = CALLOCATE ( dquad );
    
    /* if we are testing for isomorphisms we have to compute
	  the normalized automorphism group of FG first */
    if ( test_iso ) {
	   set_h_group ( g );
	   copy_vector ( rlist[0], mat, nmin*nmin );
	   prepare_grho ( isfirst );
	   if ( (valid=gr_lift_id()) ) {
		  prepare_gr_trafo();
		  isfirst = FALSE;
	   
		  /* compute automorphisms <> id on FG/I^2 */
		  for ( i = 1; i < blocks; i++ ) {
			 copy_vector ( rlist[i], mat, nmin*nmin );
			 prepare_grho ( isfirst );
			 old_top = GET_TOP();
			 if ( olift_grho ( 2 ) ) {
				handle_gr_aut ( 1 );
				old_top = GET_TOP();
				auts++;
			 }
		  }
		  SET_TOP ( old_top );
	   }
	   set_h_group ( h );
	   max_lift = 0;
	   if ( !valid )
		  return ( FALSE );
    }

    for ( i = 0; i < blocks; i++ ) {
	   copy_vector ( rlist[i], mat, nmin*nmin );
	   prepare_grho ( isfirst );
	   old_top = GET_TOP();
	   if ( olift_grho ( 2 ) ) {
		  isomorphic = TRUE;
		  if ( test_iso ) {
			 hom_rec->isomorphic = TRUE;
			 break;
		  }
		  if ( isfirst ) {
			 gr_lift_id();
			 prepare_gr_trafo();
			 old_top = GET_TOP();
			 isfirst = FALSE;
		  }
		  else {
			 handle_gr_aut ( 1 );
			 old_top = GET_TOP();
		  }
		  auts++;
	   }
	   SET_TOP ( old_top );
    }
    
    if ( test_iso )
	   set_h_group ( g );

    if ( TRUE ) {
	   hom_rec->class1_generators = gl_order ( GMINGEN ) / blocks;
	   hom_rec->auts = -1;
	   hom_rec->max_id = max_id;
	   hom_rec->lift_limit = lift_limit;
	   hom_rec->max_lift = max_lift;
	   
	   hom_rec->out_log = gr_out_log;
	   if ( gr_comp_inner )
		  gr_handle_inner_aut ( limit );
	   if ( gr_comp_gauts )
		  gr_handle_gauts ( limit );
	   hom_rec->aut_gens = ARRAY ( limit+1, VEC* );
	   for ( i = 1; i < limit; i++ ) {
		  hom_rec->aut_gens[i] = ARRAY ( hom_rec->aut_gens_dim[i], VEC );
		  p = list_aut_gens[i].first;
		  for ( j = 0; j < hom_rec->aut_gens_dim[i]; j++ ) {
			 hom_rec->aut_gens[i][j] = p->value.gv;
			 p = p->next;
		  }
	   }

	   hom_rec->isomorphic = isomorphic;
	   if ( !only_normal_auts && hom_rec->aut_gens_dim[1] > 0 )
		  hom_rec->auts = gr_class1_group ( hom_rec->aut_gens[1], 
									 hom_rec->aut_gens_dim[1], nmin);
	   else
		  hom_rec->auts = 1;
	   hom_rec->inn_log = gr_inn_log;

	   if ( isomorphic ) {
		  hom_rec->epimorphism = ALLOCATE ( nmin * GCARD );
		  for ( i = 0; i < nmin; i++ )
			 copy_vector ( epi[i], hom_rec->epimorphism+i*GCARD, GCARD );
	   }
    }
    
    if ( verbose ) {
	   PUSH_STACK();
	   trho = ARRAY ( nmin, VEC );
	   for ( i = 0; i < nmin; i++ )
		  trho[i] = ALLOCATE ( GCARD );
	   for ( i = 1; i < limit; i++ ) {
		  for ( j = 0; j < hom_rec->aut_gens_dim[i]; j++ ) {
			 for ( k = 0; k < nmin; k++ ) {
				copy_vector ( hom_rec->aut_gens[i][j]+k*GCARD, trho[k], GCARD );
			 }
			 gr_single_verify ( trho, limit );
		  }
	   }
	   POP_STACK();
    }
    
    set_h_group ( old_p_group );
    return ( isomorphic );
}


int gr_single_lift ( VEC rho[], int from, int lahead, VEC **h1 )
/* this routine tries to lift <rho> from FG/I^<from> to FG/I^(<from>+1)
   using a lookahead of <lahead> with <lahead> <= <from>*2. If a lifting
   exists, <rho> is modified to a special lifting and a basis of the 
   lifting space is stored in <h1>. The dimension of this space is returned.
   */
{
	int h1_dim, z1_dim, j, i;
	int odim, offset, rank;
	VEC *save_z1;
	char **M;
	VEC Abs, Inh;
	VEC *fsol;
	char *old_top = GET_TOP();
	
	/* set global variables */
	part_start = from;
	cut = lahead;
	if ( (cut > (part_start<<1)) || (cut <= from) )
	    cut = (part_start<<1);
	if ( cut > max_id )
	    cut = max_id;
	new_cut = part_start + 1;

	start = rho_dim = FILTRATION[part_start].i_start;
	fend	= FILTRATION[cut].i_start;
	dim = fend - start;
	dquad = dim * dim;
	odim = FILTRATION[new_cut].i_start - FILTRATION[part_start].i_start;
	new_xdim = NUMGEN * odim;
	
	get_centralizer ( new_cut );
	
	x_dim = dim * NUMGEN;
	y_dim = dim * NUMREL;
	
	get_all_op_mats ( part_start );
	
	get_sle_space ( &M, &Abs, &Inh, x_dim, y_dim );
	z1_mat ( rho, M, Abs );
	
	/* compute lifting and Z^1 if possible */
	rank = dsolve_equations ( M, Abs, Inh, x_dim, y_dim, &fsol );
	
	/* not liftable ? */
	if ( rank == -1 ) {
	    if ( verbose )
		   puts ( "######## not liftable ########" );
	    SET_TOP ( old_top );
	    return ( -1 );
	}
	
	/* rho ist liftable */
	if ( verbose ) 
	    puts ( ">>>>>>>> liftable <<<<<<<<" );
	
	/* modify rho[i] with special solution */
	offset = x_dim;
	for ( i = NUMGEN; i--; ) {
	    offset -= dim;
	    copy_vector ( Inh+offset, rho[i]+start, dim );
	}
	
	/* get dimension of H^1 and save information about lifted rho */
	z1_dim = x_dim - rank;
	if ( verbose )
	    printf ( "dimension of Z1 : %d \n", z1_dim );
	
	/* save Z1 */
	save_z1 = ARRAY ( z1_dim, VEC );
	for ( i = z1_dim; i--; ) {
	    save_z1[z1_dim-i-1] = ALLOCATE ( new_xdim );
	    for ( j = 0; j < NUMGEN; j++ )
		   copy_vector ( fsol[i]+j*dim, save_z1[z1_dim-i-1]+j*odim, odim );
	}
    
	/* factor out inner automorphisms */
	h1_dim = z1_dim;
	if ( verbose )
	    printf ( "dimension of H1 : %d \n", h1_dim );
	*h1 = gr_do_reduce ( &h1_dim, save_z1, new_cut, old_top );
	
	return ( h1_dim );
}

int gr_single_verify ( VEC rho[], int limit )
/* checks whether <rho> is a homomorphism from FH to FG by checking
   the relations of H. If a relation is not zero, the number of this
   relation, the first nonzero index and the value of the relation are
   printed. */
{
	int j, i;
	VEC *rel_obs;
	int not_okay;

	part_start = cut = limit;
	start = rho_dim = FILTRATION[part_start].i_start;
	fend = FILTRATION[cut].i_start;
	dim = fend - start;
	dquad = dim * dim;

	PUSH_STACK();
	rel_obs = ARRAY ( NUMREL, VEC );
	for ( i = NUMREL; i--; ) 
	    rel_obs[i] = obstruct ( RELATION[i], rho );
	not_okay = 0;
	i = NUMREL;

	printf ( "testing rho\n" );
	for ( j = 0; j < NUMGEN; j++ )
	    n_group_write ( rho[j], cut );
	while ( i-- && !not_okay ) {
	    j = fend;
	    while ( --j && !not_okay ) {
		   if ( rel_obs[i][j] ) {
			  printf ( "i = %d j = %d\n", i, j );
			  n_group_write ( rel_obs[i], cut );
		   }
		   not_okay |= rel_obs[i][j];
	    }
	}
	if ( !not_okay )
	    puts ( ">>>>>>>>>> okay! <<<<<<<<<<" );
	else {
	    puts ( "########## error! ##########" );
	}
	POP_STACK();
	return ( !not_okay );
}

int do_single_verify ( SGRHOM *rho_rec )
{
    VEC *r;
    int i;
    int check = TRUE;
    GRPDSC *old_p_group;

    old_p_group = h_desc;

    PUSH_STACK();
    set_h_group ( rho_rec->h );

    r = ARRAY ( rho_rec->h->num_gen, VEC );
    for ( i = 0; i < rho_rec->h->num_gen; i++ ) {
	   r[i] = GRZERO;
    }
    
    for ( i = 0; i < rho_rec->h->num_gen; i++ )
	   copy_vector ( rho_rec->image_list+i*GCARD, r[i], GCARD );

    check = gr_single_verify ( r, rho_rec->lift_limit );
    
    POP_STACK();
    set_h_group ( old_p_group );
    return ( check );
}

VEC *gr_get_obstructs ( GRPDSC *h, VEC rho[], int limit )
/* evaluates the relations of <h> for the list of images <rho>
   in the actual group ring. The values are returned as a list of
   length the number of relations of <h>. */
{
    int i;
    VEC *rel_obs;
    GRPDSC *old_p_group;

    old_p_group = h_desc;

    set_h_group ( h );

    if ( limit == 0 ) limit = MAX_ID;
    part_start = cut = limit;
    start = rho_dim = FILTRATION[part_start].i_start;
    fend = FILTRATION[cut].i_start;
    dim = fend - start;
    dquad = dim * dim;

    rel_obs = ARRAY ( NUMREL, VEC );
    for ( i = NUMREL; i--; ) 
	   rel_obs[i] = obstruct ( RELATION[i], rho );

    set_h_group ( old_p_group );
    return ( rel_obs );
}

void gr_show_hom ( GRHOM *auts )
{
    int cnt, i, j, k;
    unsigned long aut_log = 0;
#ifdef HAVE_LIBGMP
    MP_INT p_mp;
    MP_INT power;
    MP_INT order;
#endif

    printf ( "limit: %d, max_id: %d\n", auts->lift_limit, auts->max_id );
    for ( i = 2; i < auts->lift_limit; i++ )
	   aut_log += auts->aut_gens_dim[i];

#ifdef HAVE_LIBGMP
    mpz_init_set_ui ( &p_mp, (unsigned long) GPRIME );
    mpz_init ( &power );
    mpz_pow_ui ( &power, &p_mp, aut_log );
    mpz_init ( &order );
    mpz_mul_ui ( &order, &power, (unsigned long) auts->auts );
    printf ( "order of automorphism group: " );
    mpz_out_str ( stdout, 10, &order );
    printf ( " (%d*%1d^%1ld)\n", auts->auts, GPRIME, aut_log );
    mpz_clear ( &p_mp );
    mpz_clear ( &power );
    mpz_clear ( &order );
#else
    printf ( "order of automorphism group: " );
    printf ( "(%d*%1d^%1ld)\n", auts->auts, GPRIME, aut_log );
#endif

    if ( auts->isomorphic ) {
	   printf ( "group rings are isomorphic modulo I^%1d\n", limit );
	   cnt = 0;
	   for ( i = 1; i < auts->lift_limit; i++ ) {
		  printf ( "\nclass %d\n", i );
		  for ( j = 0; j < auts->aut_gens_dim[i]; j++ ) {
			 printf ( "    rho no. %d:\n", cnt++ );
			 for ( k = 0; k < auts->h->num_gen; k++ ) {
				printf ( "      gen[%1d]: ", k );
				n_group_write ( auts->aut_gens[i][j]+k*GCARD, auts->max_id );
			 }
		  }
	   }
	   
	   printf ( "epimorphism:\n" );
	   for ( i = 0; i < auts->h->num_gen; i++ ) {
		  printf ( "   image( h.%1d ) : ", i );
		  n_group_write ( auts->epimorphism + i*GCARD, auts->max_id );
	   }
	   printf ( "\n   modulo I^2 - dim(id): %d, dim(inn): %d, num(aut): %d\n",
				 auts->out_gens_dim[1], 
				 auts->aut_gens_dim[1] - auts->out_gens_dim[1] - 
				 auts->mod_grauts_gens_dim[1], auts->auts  );
	   for ( i = 3; i <= auts->lift_limit; i++ )
		  printf ( "   modulo I^%1d - dim(id): %d, dim(inn): %d, dim(aut): %d\n",
				 i, auts->out_gens_dim[i-1], 
				 auts->aut_gens_dim[i-1] - auts->out_gens_dim[i-1] - 
				 auts->mod_grauts_gens_dim[i-1], auts->mod_grauts_gens_dim[i-1] );
    }
    else {
	   printf ( "group rings are not isomorphic modulo I^%1d\n", auts->lift_limit );
	   printf ( "liftings exist up to I^%1d\n", auts->max_lift );
    }
}

void gr_show_shom ( SGRHOM *rho_rec )
{
    int i;
    for ( i = 0; i < rho_rec->h->num_gen; i++ ) {
	   printf ( "   image( h.%1d ) : ", i );
	   n_group_write ( rho_rec->image_list + i*GCARD, rho_rec->lift_limit );
    }
}

GRHOM *gr_lift_control ( GRPDSC *h, GRPDSC *k, int limit, int test_iso, 
				   int lookahead, int sublift, int smallgrpring )
{
    int old_cut = cut;
    int old_fend = fend;

    if ( smallgrpring ) {
	   group_mul = sn_group_mul;
	   group_exp = sngroup_exp;
	   small_grpring ( NULL );
    } 
	
	
    max_id = (lookahead > MAX_ID) || (lookahead == 0) ? MAX_ID : lookahead;
    max_id = ( jennings_la > MAX_ID) || (jennings_la == 0) ? max_id : 
	   jennings_la;
    limit = (limit > max_id) || (limit < 1) ? max_id : limit;

    gr_comp_aut ( h, k, TRUE, test_iso, limit );
    
    cut = old_cut;
    fend = old_fend;
    if ( smallgrpring ) {
	   group_mul = n_group_mul;
	   group_exp = ngroup_exp;
    }
    
    return ( hom_rec );
}

SGRHOM *gr_get_homom ( GRPDSC *h, LISTP *imlist, int limit )
{
    SGRHOM *homo;
    DYNLIST p;
    int i;
    
    homo = ALLOCATE ( sizeof ( SGRHOM ) );
    homo->h = h;
    homo->image_list = ALLOCATE ( h->num_gen * GCARD );
    homo->lift_limit = limit == 0 ? MAX_ID : limit;
    
    i = 0;
    for ( p = imlist->first; p != NULL; p = p->next ) {
	   copy_vector ( (VEC)p->value.gv, homo->image_list + i*GCARD, GCARD );
	   i++;
    }
    return ( homo );
}
    
SGRHOM *gr_homom_fetch ( GRHOM *auts, int class, int no )
{
    int i;
    SGRHOM *homo;

    homo = ALLOCATE ( sizeof ( SGRHOM ) );

    if ( class == 0 )
	   homo->h = auts->h;
    else
	   homo->h = auts->gg;
    homo->image_list = ALLOCATE ( homo->h->num_gen * GCARD );
    homo->lift_limit = auts->lift_limit;

    if ( class == 0 ) {
	   for ( i = 0; i < homo->h->num_gen; i++ )
		  copy_vector ( auts->epimorphism+i*GCARD, homo->image_list+i*GCARD, GCARD );
    }
    else {
	   if ( (class >= auts->lift_limit) ||
		   (no >= auts->aut_gens_dim[class]) ) {
		  set_error ( NO_SUCH_HOM );
	   }
	   else {
		  for ( i = 0; i < homo->h->num_gen; i++ )
			 copy_vector ( auts->aut_gens[class][no]+i*GCARD, homo->image_list+i*GCARD, GCARD );
	   }
    }
    return ( homo );
}

static int gr_bperelem;
static int gr_cut;

static VEC gr_calc_image ( VEC r, node p )
{
	VEC h1;
	VEC obs;
	
	obs = CALLOCATE ( gr_bperelem );
	PUSH_STACK();

	switch ( p->nodetype ) {
		case GGEN:
				copy_vector ( gr_image_of_generator ( r, p->value ), obs, 
						    gr_bperelem );
				break;
		case COMM:
				h1 = mult_comm ( gr_calc_image ( r, p->left ),
							  gr_calc_image ( r, p->right ),
							  gr_cut );
				copy_vector ( h1, obs, gr_bperelem );
				break;
		case EXP :
				h1 = GROUP_EXP ( gr_calc_image ( r, p->left ),
							  (p->value > 0) ? p->value : -p->value,
							  gr_cut );
				if ( p->value < 0 )
					h1 = gr_invers ( h1, gr_cut );
				copy_vector ( h1, obs, gr_bperelem );
				break;
		case MULT:
				h1 = GROUP_MUL ( gr_calc_image ( r, p->left ),
						  gr_calc_image ( r, p->right ),
						  gr_cut );
				copy_vector ( h1, obs, gr_bperelem );
				break;
		default:
				puts ( "Error in relation" );
	}
	POP_STACK();
	return ( obs );
}

VEC gr_image_of_generator ( VEC r, int g )
{
	VEC im = ALLOCATE ( gr_bperelem );
	
	PUSH_STACK();
	if ( (g < group_desc->min_gen) || (!group_desc->defs) )
		copy_vector ( r+g*GCARD, im, gr_bperelem );
	else {
		copy_vector ( gr_calc_image ( r, group_desc->def_list[g] ), im, gr_bperelem );
	}
	POP_STACK();
	return ( im );
}

static  VEC *im_g;

static VEC gr_monom_get_image ( VEC monom )
{
    VEC im_monom;
    VEC zwres, res;
    int i;
    char val;
    
    im_monom = ALLOCATE ( gr_bperelem );
    PUSH_STACK();
    res = CALLOCATE ( gr_bperelem );
    res[0] = 1;
    for ( i = 0; i < GNUMGEN; i++ ) {
	   if ( (val = monom[i]) != 0 ) {
		  zwres = GROUP_EXP ( im_g[i], val, gr_cut );
		  res = GROUP_MUL ( res, zwres, gr_cut );
	   }
    }
    copy_vector ( res, im_monom, gr_bperelem );
    POP_STACK();
    return ( im_monom );
}

VEC gr_get_image ( SGRHOM *rho_rec, VEC el )
/* compute image of <el> under homomorphism <rho_rec> */
{
    VEC image_el;
    VEC zwres, res;
    char val;
    int i;

    gr_cut = rho_rec->lift_limit;
    gr_bperelem = FILTRATION[gr_cut].i_start;

    image_el = ALLOCATE ( gr_bperelem );
    PUSH_STACK();
    im_g = ARRAY ( GNUMGEN, VEC );

    /* get images of (g_i - 1) for pc_generators g_i */
    for ( i = 0; i < GNUMGEN; i++ ) {
	   im_g[i] = gr_image_of_generator ( rho_rec->image_list, i );
	   im_g[i][0] = 0;
    }
    
    
    /* compute images of nonzero monomials of <el> and add up */
    res = CALLOCATE ( gr_bperelem );
    for ( i = 0; i < gr_bperelem; i++ )
	   if ( (val=el[i]) != 0 ) {
		  zwres = gr_monom_get_image ( N_MONOM[i] );
		  if ( val != 1 )
			 SMUL_VECTOR ( val, zwres, gr_bperelem );
		  ADD_VECTOR ( zwres, res, gr_bperelem );
	   }
    copy_vector ( res, image_el, gr_bperelem );
    POP_STACK();
    return ( image_el );
}

SPACE *gr_vs_image ( SGRHOM *rho_rec, SPACE *vs )
/* compute image of vector space <vs> under homomorphism <rho_rec> */
{
    DYNLIST p = NULL;
    DYNLIST nbasis_l = NULL;
    VEC el, res, zwres;
    int i, j;
    int is_first = TRUE;
    char val;
    

    gr_cut = get_ideal ( vs->total_dim );
    if ( (gr_cut > rho_rec->lift_limit) || (vs->b_flag != UPPER) )
	   return ( NULL );

    gr_bperelem = FILTRATION[gr_cut].i_start;

    im_g = ARRAY ( GNUMGEN, VEC );

    /* get images of (g_i - 1) for pc_generators g_i */
    for ( i = 0; i < GNUMGEN; i++ ) {
	   im_g[i] = gr_image_of_generator ( rho_rec->image_list, i );
	   im_g[i][0] = 0;
    }
    
    /* compute images of basis elements */
    for ( j = 0; j < vs->dimension; j++ ) {
	   el = vs->basis + j*vs->total_dim;

	   /* compute images of nonzero monomials of <el> and add up */
	   res = CALLOCATE ( gr_bperelem );
	   for ( i = 0; i < gr_bperelem; i++ )
		  if ( (val=el[i]) != 0 ) {
			 zwres = gr_monom_get_image ( N_MONOM[i] );
			 if ( val != 1 )
				SMUL_VECTOR ( val, zwres, gr_bperelem );
			 ADD_VECTOR ( zwres, res, gr_bperelem );
		  }
	   if ( is_first ) {
		  p = nbasis_l =  ALLOCATE ( sizeof ( dynlistitem ) );
		  is_first = FALSE;
	   }
	   else {
		  p->next = ALLOCATE ( sizeof ( dynlistitem ) );
		  p = p->next;
	   }
	   p->value.gv = res;
	   p->type = GRELEMENT;
	   p->next = NULL;
    }
    return ( span_space ( nbasis_l, vs->dimension) );
}

SGRHOM *gr_concatenate ( SGRHOM *l, SGRHOM *r )
{
    SGRHOM *res;
    int i;
    int gr_end;
    
    if ( (l->h != r->h) || (l->lift_limit != r->lift_limit) )
	   return ( NULL );

    gr_end = FILTRATION[l->lift_limit].i_start;
    res = ALLOCATE ( sizeof ( SGRHOM ) );
    res->h = l->h;
    res->lift_limit = l->lift_limit;
    res->image_list = CALLOCATE ( GCARD * l->h->num_gen );
    PUSH_STACK();
    for ( i = 0; i < l->h->num_gen; i++ )
	   copy_vector ( gr_get_image ( l, r->image_list+i*GCARD ),
				  res->image_list+i*GCARD, gr_end );
    POP_STACK();
    return ( res );
}

SGRHOM *gr_exp_concatenate ( SGRHOM *l, int power )
{
    SGRHOM *res;
    SGRHOM *h;
    int i = 4096;
    int gr_end;

    gr_end = FILTRATION[l->lift_limit].i_start;
    res = ALLOCATE ( sizeof ( SGRHOM ) );
    res->image_list = ALLOCATE ( GCARD * l->h->num_gen );
    PUSH_STACK();
    res->h = l->h;
    res->lift_limit = l->lift_limit;
    h = res;
    copy_vector ( l->image_list, h->image_list, GCARD * l->h->num_gen );
    while ( !(power & i ) ) i >>= 1;
    while ( (i >>= 1) != 0 ) {
	   h = gr_concatenate ( h, h );
	   if ( power & i )
		  h = gr_concatenate ( h, l );
    }
    copy_vector ( h->image_list, res->image_list, GCARD * l->h->num_gen );
    POP_STACK();
    return ( res );
}

SGRHOM *gr_aut_Id ( GRPDSC *h, int limit )
{
    SGRHOM *res;
    int i;

    res = ALLOCATE ( sizeof ( SGRHOM ) );
    res->h = h;
    res->lift_limit = limit;
    res->image_list = CALLOCATE ( GCARD * h->num_gen );
    for ( i = 0; i < h->num_gen; i++ ) {
	   copy_vector ( NGEN_VEC[i], res->image_list+i*GCARD, GCARD );
	   res->image_list[i*GCARD] = 1;
    }
    return ( res );
}
    
int is_graut_id ( SGRHOM *r )
{
    VEC help;
    int i;
    int res;
    
    PUSH_STACK();
    help = ALLOCATE ( GCARD * r->h->num_gen );
    copy_vector ( r->image_list, help, GCARD * r->h->num_gen );
    for ( i = 0; i < r->h->num_gen; i++ ) {
	   help[i*GCARD] = 0;
	   SUBA_VECTOR ( NGEN_VEC[i], help+i*GCARD, GCARD );
    }
    res = iszero ( help, GCARD * r->h->num_gen );
    POP_STACK();
    return ( res );
}

SGRHOM *gr_inv_concatenate ( SGRHOM *el )
{
	SGRHOM *res = gr_aut_Id ( el->h, el->lift_limit );
	SGRHOM *l, *i;
	
	if ( !is_graut_id ( el ) ) {
		PUSH_STACK();
		i = l = el;
		while ( !is_graut_id ( i = gr_exp_concatenate ( i, GPRIME ) ) ) {
			l = gr_concatenate ( i, l );
		}
		i = gr_exp_concatenate ( l, GPRIME-1 );
		copy_vector ( i->image_list, res->image_list, GCARD * l->h->num_gen  );
		POP_STACK();
	}
	return ( res );
}

/* end of module group ring automorphism group */













