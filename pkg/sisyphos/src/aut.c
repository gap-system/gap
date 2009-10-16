/********************************************************************/
/*  Module        : Automorphism group                              */
/*                                                                  */
/*  Description :                                                   */
/*     Module is used to compute the automorphism group of a        */
/*     p-group given via a pc-representation.                       */
/*                                                                  */
/*                                                                  */
/********************************************************************/

/* 	$Id: aut.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: aut.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.3  1997/05/02 09:36:23  pluto
 * 	Handle zero words in h1_mat_row.
 *
 * 	Revision 3.2  1995/08/10 11:58:21  pluto
 * 	Moved several routines dealing with automorphism groups to 'autgroup'.
 *
 * 	Revision 3.1  1995/06/26 16:24:36  pluto
 * 	Corrected calls to 'output_prae' and 'output_post'.
 *
 * 	Revision 3.0  1995/06/23 09:35:41  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.6  1995/01/12  11:07:07  pluto
 * Added "use_static_matrix" to direct calls of GAUSS_ELIMINATE.
 *
 * Revision 1.5  1995/01/05  17:16:29  pluto
 * Changed header to new style.
 *
 * Revision 1.4  1995/01/05  16:44:43  pluto
 * Changed stabilizer, maps->stabs[k] now only
 * contains automorphisms that are trivial mod I^k
 * but not modulo I^(k+1).
 *
 * Revision 1.3  1995/01/03  13:42:00  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: aut.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
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
static PCELEM g_obstr 		_(( node p ));
int g_h1_mat			_(( int start, int dim, int *y ));
static void handle_aut 		_(( int class ));
static void comp_centre 		_(( void ));
int check_iso 				_(( VEC vector, int c2_dim ));
static void do_reduce 		_(( int *h1_dim, VEC h1[], int d ));
int inc2_count 		_(( VEC coeff, int last ));
void liftings_mod2            _(( VEC autgens[], int n_autgens, int n, int p ));
static int alog2			_(( int n ));
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

#define GET_GL_ELEMENT (*get_gl_element)
#define ADD_TO_LIST (*add_to_list)
#define ADD_TO_FAIL_LIST (*add_to_fail_list)

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
int fd;
int aut_num = 0;
int out_log;
int inn_log;
int g_gens;

HOM *dgroup_auts = NULL;

static int isfirst = TRUE;
static FILE *a_out;
VEC gl_mat;
VEC ind;
COUPLE **zentrum;
COUPLE **orbgen;
int *obgen_cnt;
int critical_class;

/* algorithm flags */
int use_filtration = TRUE;
int use_max_elab_sections = FALSE;
int only_normal_auts = FALSE;
int with_inner = FALSE;
OPTION aut_pres_style = NONE;
int aut_pres_all = FALSE;

PCELEM *rho;
static int section;
static int gcard;
static int nmin;
static int cauto = FALSE;
static int search_for_iso = FALSE;
static int *apotrel;
static int *acomrel;
static int potrel;
static int comrel;
static int *z_dim;
static VEC **id_gens;
static VEC **cid_gens;
static VEC **inn_gens;
static VEC **cinn_gens;
static int *id_gens_dim;
LISTP *list_aut_gens;
static node *h_image;
static HOM *hom_rec;
static VEC T;
static VEC TI;
static VEC dum_abs;
static int use_gl_iteration;
static int msection;
static int liftid = FALSE;
static int completely_liftable = FALSE;
static int do_compute_centre = TRUE;

static int alog2 ( int n )
{
	int l = 0;
	while ( n != 0 ) {
		n >>= 1;
		l++;
	}
	return ( l );
}

int inc2_count (VEC coeff, int last)
{
    register int carry = TRUE;
    register int j = last-1;
    int i;
    char x;
    
    while ( carry && (j >= 0) ) {
	   x = coeff[j];
	   carry = ( x == prime-1 );
	   coeff[j--] = carry ? 0 : ++x;
    }
    if ( !carry ) {
	   for ( i = 0; i <= j + 1; i++ )
		  if ( coeff[i] != 0 )
			 break;
	   if ( (i == j+1) && ( coeff[i] > 1 ) ) {
		  coeff[i] = 0;
			if ( i > 0 )
			    coeff[i-1] = 1;
			else
			    carry = TRUE;
	   }
	}
    return ( !carry );
}

void set_number_of_relations ( int class )
{
	potrel = apotrel[class];
	comrel = acomrel[class];
}			

static PCELEM g_obstr ( node p )
{
	register PCELEM h1;
	register PCELEM obs;
	int dummy;
	
	obs = IDENTITY;
	PUSH_STACK();

	switch ( p->nodetype ) {
		case GGEN:
				copy_vector ( rho[p->value], obs, bperelem );
				break;
		case EQ  :
				if ( p->right != NULL )
					copy_vector ( g_obstr ( p->right ), obs, bperelem );
				SUBA_VECTOR ( g_obstr ( p->left ), obs, bperelem );
				break;
		case COMM:
				h1 = g_comm ( g_obstr ( p->left ), g_obstr ( p->right ) );
				copy_vector ( h1, obs, bperelem );
				break;
		case EXP :
				h1 = g_expo ( g_obstr ( p->left ), (p->value > 0) ? p->value : -p->value );
				if ( p->value < 0 )
					h1 = g_invers ( h1 );
				copy_vector ( h1, obs, bperelem );
				break;
		case MULT:
				copy_vector ( g_obstr ( p->left ), obs, bperelem );
				collect ( obs, exp_vec_to_ge_pair ( g_obstr ( p->right ), &dummy ) );
				break;
		default:
				puts ( "(g_obstr) Error in relation" );
	}
	POP_STACK();
	return ( obs );
}

VEC h1_mat_row ( int dim, node p )
/* compute row of relation matrix for trivial module.
   <p>   is an expression tree for the relation,
   <dim> is the number of generators of the group.  */
{
	register VEC h1;
	register VEC res;
	char val;
	
	res = CALLOCATE ( dim );
	PUSH_STACK();

	if ( p != NULL ) {
		switch ( p->nodetype ) {
		case GGEN:
			res[p->value] = 1;
			break;
		case EQ  :
			if ( p->right != NULL )
				copy_vector ( h1_mat_row ( dim, p->right ), res, dim );
			SUBA_VECTOR ( h1_mat_row ( dim, p->left ), res, dim );
			break;
		case COMM:
			break;
		case EXP :
			h1 = h1_mat_row ( dim, p->left );
			if ( p->value < 0 ) 
				val = (prime - (-(p->value) % prime)) % prime;
			else
				val = (p->value) % prime;
			if ( val != 0 )
				SMUL_VECTOR ( val, h1, dim );
			else
				zero_vector ( h1, dim );
			copy_vector ( h1, res, dim );
			break;
		case MULT:
			copy_vector ( h1_mat_row ( dim, p->right ), res, dim );
			ADD_VECTOR ( h1_mat_row ( dim, p->left ), res, dim );
			break;
		default:
			puts ( "(h1_mat_row) Error in relation" );
		}
	}
	POP_STACK();
	return ( res );
}

int g_h1_mat ( int start, int dim, int *y )
{
	PCELEM rel_obs;
	int i, j, k;
	int offset = 0;
	int currel;
	
	if ( comrel == 0 )
		currel = NUMREL;
	else
		currel = potrel;
	*y = 0;
	
	if ( !use_filtration )
		completely_liftable = TRUE;
	PUSH_STACK();
	for ( i = 0; i < currel; i++ ) {
		for ( k = 0; k < dim; k++ ) {
			zero_vector ( matrix[(long)(offset+k)], dim*potrel );
			for ( j = 0; j < potrel; j++ )
				matrix[(long)(offset+k)][(long)(k+j*dim)] = gl_mat[(long)i*NUMGEN+(long)j];
		}
		rel_obs = g_obstr( RELATION[i] );
		if ( !use_filtration )
			completely_liftable &= iszero ( rel_obs+start, GNUMGEN-start );
		if ( ind[i] ) {
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
	for ( i = GNUMGEN; i < GNUMGEN+comrel; i++ ) {	
		for ( k = 0; k < dim; k++ ) {
			zero_vector ( matrix[(long)(offset+k)], dim*potrel );
			for ( j = 0; j < potrel; j++ )
				matrix[(long)(offset+k)][(long)(k+j*dim)] = gl_mat[(long)i*NUMGEN+(long)j];
		}
		rel_obs = g_obstr( RELATION[i] );
		if ( !use_filtration )
			completely_liftable &= iszero ( rel_obs+start, GNUMGEN-start );
		if ( ind[i] ) {
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

void print_cycle ( int *perm )
{
	char *index;
	int i, j;
	int isidentity = TRUE;
	
	PUSH_STACK();
	index = CALLOCATE ( GCARD );
	
	for ( i = 0; i < GCARD; i++ ) {
		if ( index[i] == 0 ) {
			index[i] = 1;
			if ( (j=perm[i]) != i ) {
				isidentity = FALSE;
				fprintf ( a_out, "(%d", i );
				do {
					index[j] = 1;
					fprintf ( a_out, ",%d", j );
					j = perm[j];
				} while ( j != i );
				fprintf ( a_out, ")" );
			}
		}
	}
	if ( !isidentity )
		fprintf ( a_out, "\n" );
	else
		fprintf ( a_out, "(1)\n" );
	POP_STACK();
}

static void handle_aut ( int class )
{
	register int j;
	VEC sr;
	int gens;
	
	gens = group_desc->defs ? GMINGEN : GNUMGEN;
	
	/* save rho in dynamic list */
	if ( list_aut_gens[class].last == NULL ) {
		list_aut_gens[class].last = list_aut_gens[class].first = ALLOCATE ( sizeof ( dynlistitem ) );
	}
	else {
		list_aut_gens[class].last->next = ALLOCATE ( sizeof ( dynlistitem ) );
		list_aut_gens[class].last = list_aut_gens[class].last->next;
	}
	sr = list_aut_gens[class].last->value.gv = ALLOCATE ( gens * GNUMGEN );
	for ( j = 0; j < gens; j++ )
		copy_vector ( rho[j], sr + j*GNUMGEN, GNUMGEN );
	list_aut_gens[class].last->next = NULL;
	hom_rec->aut_gens_dim[class]++;
	
	aut_num++;
}

static void handle_inner_aut (void)
{
	int i, j, k;
	VEC sr;
	PCELEM iel, el;
	int gens;
	
	gens = group_desc->defs ? GMINGEN : GNUMGEN;
	
	for ( i = 1; i <= EXP_P_CLASS; i++ ) {
		hom_rec->out_gens_dim[i] = hom_rec->aut_gens_dim[i];
/*		if ( with_inner ) { */
			hom_rec->aut_gens_dim[i] += obgen_cnt[i];
			for ( j = 0; j < obgen_cnt[i]; j++ ) {
				if ( list_aut_gens[i].last == NULL ) {
					list_aut_gens[i].last = list_aut_gens[i].first = ALLOCATE ( sizeof ( dynlistitem ) );
				}
				else {
					list_aut_gens[i].last->next = ALLOCATE ( sizeof ( dynlistitem ) );
					list_aut_gens[i].last = list_aut_gens[i].last->next;
				}
				sr = list_aut_gens[i].last->value.gv = ALLOCATE ( gens * GNUMGEN );
				iel = orbgen[i][j].i_g;
				el = orbgen[i][j].g;
				PUSH_STACK();
				for ( k = 0; k < gens; k++ )
					copy_vector ( monom_mul ( iel, monom_mul ( group_desc->nom[k], el ) ), sr + k* GNUMGEN, GNUMGEN );
				POP_STACK();
			}
/*		}  */
	}
}

/*
static void do_inner ( h1_dim, h1, d )
int *h1_dim;
VEC h1[];
int d;
{
	register int i = 0;
	register int k = 0;
	int j;

	for ( i = 0; i < z_dim[section-1]; i++ ) {
		copy_vector ( cinn_gens[section][i], matrix[(long)k], potrel*d );
		k++;
	}

	j = k;
	for ( i = *h1_dim; i--; )
		copy_vector ( h1[i], matrix[(long)k++], potrel*d );
	*h1_dim = complement ( j, potrel*d, k );
	for ( i = *h1_dim; i--; )
		h1[i] = fsolution[i];
}
*/

static void do_reduce (int *h1_dim, VEC *h1, int d)
/* factor out parameters belonging to inner automorphisms
   and parameters stemming from liftings of the identity */
            
         
      
{
	register int i = 0;
	register int k = 0;
	int j;

	for ( i = 0; i < z_dim[section-1]; i++ ) {
		copy_vector ( cinn_gens[section][i], matrix[(long)k], potrel*d );
		k++;
	}

	if ( id_gens_dim[section] != -1 ) {
		for ( i = 0; i < id_gens_dim[section]; i++ ) {
			copy_vector ( cid_gens[section][i], matrix[(long)k], potrel*d );
			k++;
		}
	}
	j = k;
	for ( i = *h1_dim; i--; )
		copy_vector ( h1[i], matrix[(long)k++], potrel*d );
	*h1_dim = complement ( j, potrel*d, k );
	for ( i = *h1_dim; i--; )
		h1[i] = fsolution[i];
}

int check_iso ( VEC vector, int dim )
{
	int ret = FALSE;
	register int i;
	int ysave, xsave;
	VEC a_save;
	
	PUSH_STACK();
	for ( i = NUMGEN; i--; )
		copy_vector ( vector+i*dim, matrix[(long)i], dim );

	ysave = y_dim;
	xsave = x_dim;
	y_dim = NUMGEN;
	x_dim = nmin;
	a_save = absolut;
	absolut = CALLOCATE ( y_dim );
	use_static_matrix();
	if ( GAUSS_ELIMINATE() == nmin )
		ret = TRUE;
	y_dim = ysave;
	x_dim = xsave;
	absolut = a_save;
	POP_STACK();
	return ( ret );
}

int olift_rho ( int curr_sec )
{
	int i;
	int j = 0;
	VEC *h1;
	VEC ind_vec;
	char *h1_mod;
	char *ih_save;
	int h1_dim, rank;
	int do_it = TRUE;
	int is_iso = FALSE;
	int d, s, x, y;
	char val;
	char *old_top;
	int old_class = 0;
	
	section = curr_sec;
	if ( section == EXP_P_CLASS + 1 )
		return ( TRUE );
	if ( use_filtration ) {
		old_class = set_group_quotient ( section );
		set_number_of_relations ( section );
	}
	d = EXP_P_LCS[section].i_dim;
	s = EXP_P_LCS[section].i_start;
	x = d * potrel;
	
	if ( section > 1 ) {
		for ( i = potrel; i--; )
			zero_vector ( rho[i]+s, GNUMGEN-s );
	}
/*	if ( !isfirst && section == critical_class ) {
		PUSH_STACK();
		old_class = set_group_quotient ( EXP_P_CLASS );
		set_number_of_relations ( section );
		az1_mat();
		rank = solve_equations ( NUMGEN*adim, NUMREL*adim );
		POP_STACK();
		set_group_quotient ( old_class );
		set_number_of_relations ( old_class );
		if ( rank != -1 )
			return ( TRUE );
		else
			return ( FALSE );
	} */

	if ( do_it ) {
		old_top = GET_TOP();
		do_it &= g_h1_mat ( s, d, &y );
		if ( section == 1 ) {
			is_iso = iszero ( absolut, y ) && olift_rho ( 2 );
			SET_TOP ( old_top );
		}
		else {
		if ( do_it ) {
			if ( !use_filtration && completely_liftable ) {
				SET_TOP ( old_top );
				return ( TRUE );
			}
			rank = solve_equations ( x, y );
			if ( rank != -1 ) {
				is_iso = TRUE;
				ih_save = ALLOCATE ( x );
				copy_vector ( inhom, ih_save, x );
				h1_dim = x - rank;
				h1 = ARRAY ( h1_dim, VEC );
				for ( i = x; i--; ) {
					if ( fsolution[i] )
					h1[j++] = fsolution[i];
				}
				
				if ( !search_for_iso )
					do_reduce ( &h1_dim, h1, d );

				ind_vec = CALLOCATE ( h1_dim );
				if ( curr_sec == 1 )
					ind_vec[h1_dim-1] = 1;
				h1_mod = ALLOCATE ( x );

/*				if ( id_gens_dim[section] != -1 && liftid ) {
					for ( i = potrel; i--; )
						copy_vector ( ih_save+i*d, rho[i]+s, d );
					if ( !maps_to_liftable ( msection, section ) ) {
						printf ( "section %d failed!\n", section );
						is_iso = FALSE;
					}
				} */
				
				if ( is_iso ) {
				do {
					zero_vector ( h1_mod, x );
					for ( i = h1_dim; i--; ) {
						if ( ( val = ind_vec[i] ) != 0 ) {
							ADD_MULT ( val, h1[i], h1_mod, x );
						}
					}
					for ( i = potrel; i--; ) {
						copy_vector ( ih_save+i*d, rho[i]+s, d );
						ADD_VECTOR ( h1_mod+i*d, rho[i]+s, d );
					}
/*					printf ( "currsec : %d\n", curr_sec );
					maps_to_liftable ( section ); */
					is_iso = olift_rho ( curr_sec + 1 );
				} while ( inc_count ( ind_vec, h1_dim ) && !is_iso);
				} /* if is_iso */
/*				puts ( "stop" ); */
/*				for ( i = potrel; i--; )
					zero_vector ( rho[i]+s, d ); */
				SET_TOP ( old_top );
			}
		}
		} /* section == 1 */
	}
	if ( use_filtration ) {
		set_group_quotient ( old_class );
		set_number_of_relations ( old_class );
	}

	return ( is_iso );
}

int oolift_rho ( int curr_sec )
{
	int i;
	VEC *h1;
	VEC ind_vec;
	char *h1_mod;
	char *ih_save;
	int h1_dim;
	int is_iso = FALSE;
	int d, s, x;
	int nclass;
	char val;
	char *old_top;
	int old_class = 0;
	
	section = curr_sec;
	if ( section == EXP_P_CLASS + 1 )
		return ( TRUE );
	if ( use_filtration ) {
		old_class = set_group_quotient ( section );
		set_number_of_relations ( section );
	}

	s = EXP_P_LCS[section].i_start;
	
	if ( section > 1 ) {
		for ( i = potrel; i--; )
			zero_vector ( rho[i]+s, GNUMGEN-s );
	}

	old_top = GET_TOP();
	
	h1_dim =  setup_section ( section, &h1, &nclass );

	if ( h1_dim != -1 ) {
		d = (nclass == EXP_P_CLASS+1 ? GNUMGEN : EXP_P_LCS[nclass].i_start ) - EXP_P_LCS[section].i_start;
		x = d * potrel;
		is_iso = TRUE;
		ih_save = ALLOCATE ( x );
		copy_vector ( inhom, ih_save, x );
		
		ind_vec = CALLOCATE ( h1_dim );

		if ( curr_sec == 1 )
			ind_vec[h1_dim-1] = 1;
		h1_mod = ALLOCATE ( x );

		do {
			zero_vector ( h1_mod, x );
			for ( i = h1_dim; i--; ) {
				if ( ( val = ind_vec[i] ) != 0 ) {
					ADD_MULT ( val, h1[i], h1_mod, x );
				}
			}
			for ( i = potrel; i--; ) {
				copy_vector ( ih_save+i*d, rho[i]+s, d );
				ADD_VECTOR ( h1_mod+i*d, rho[i]+s, d );
			}
			is_iso = olift_rho ( nclass );
		} while ( inc_count ( ind_vec, h1_dim ) && !is_iso);
	}

	SET_TOP ( old_top );

	if ( use_filtration ) {
		set_group_quotient ( old_class );
		set_number_of_relations ( old_class );
	}

	return ( is_iso );
}

void lift_id (void)
{
	int i, j, k;
	VEC *h1;
	VEC ind_vec;
	char *h1_mod;
	PCELEM *srho;
	int h1_dim;
	int d, s, x, y;
	char val;
	int found;
	int dc;
	VEC ih_save;
	int old_class;
	
	
	liftid = TRUE;
	out_log = 0;
	old_class = set_group_quotient ( 0 );
	set_number_of_relations ( old_class );
	srho = ARRAY ( NUMGEN, PCELEM );
	for ( i = 0; i < NUMGEN; i++ ) {
		srho[i] = IDENTITY;
		copy_vector ( rho[i], srho[i], bperelem );
	}
	for ( i = EXP_P_CLASS; i > 1; i-- ) {
		section = msection = i;
		/* printf ( "section: %d", section ); */
		if ( use_filtration ) {
			set_group_quotient ( section );
			set_number_of_relations ( section );
		}
		d = EXP_P_LCS[section].i_dim;
		s = EXP_P_LCS[section].i_start;
		x = d * potrel;
	
		/* reset rho */
		for ( k = NUMGEN; k--; ) {
			copy_vector ( srho[k], rho[k], s );
			zero_vector ( rho[k]+s, GNUMGEN-s );
		}
	
		ih_save = ALLOCATE ( x );
		
		if ( !use_max_elab_sections ) {
			g_h1_mat ( s, d, &y );
			h1_dim = x - solve_equations ( x, y );
		}
		else
			h1_dim = setup_section ( i, &h1, &k );
		
		/* printf ( " h1v: %d", h1_dim ); */
		copy_vector ( inhom, ih_save, x );

		if ( use_filtration ) {
			h1 = ARRAY ( h1_dim, VEC );
			j = 0;
			for ( k = x; k--; ) {
				if ( fsolution[k] )
				h1[j++] = fsolution[k];
			}
		}
		
		do_reduce ( &h1_dim, h1, d );
		/* printf ( " h1n: %d\n", h1_dim ); */
		id_gens[i] = ARRAY ( h1_dim,  VEC  );
		cid_gens[i] = ARRAY ( h1_dim,  VEC  );
		dc = 0;
		if ( i == EXP_P_CLASS ) {
			id_gens_dim[i] = h1_dim;
			for ( j = h1_dim; j--; ) {
				id_gens[i][dc] = ALLOCATE ( x );
				cid_gens[i][dc] = ALLOCATE ( x );
				copy_vector ( h1[j], cid_gens[i][dc], x );
				copy_vector ( h1[j], id_gens[i][dc++], x );
				for ( k = potrel; k--; ) {
					copy_vector ( ih_save+k*d, rho[k]+s, d );
					ADD_VECTOR ( h1[j]+k*d, rho[k]+s, d );
				}
				handle_aut ( i );
				out_log++;
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
						zero_vector ( rho[j]+s, GNUMGEN - s );
						if ( j < potrel ) {
							copy_vector ( ih_save+j*d, rho[j]+s, d );
							ADD_VECTOR ( h1_mod+j*d, rho[j]+s, d );
						}
					}
					found = olift_rho ( i + 1 );
				} while ( inc2_count ( ind_vec, h1_dim ) && !found );

				if ( found ) {
					id_gens[i][dc] = ALLOCATE ( x );
					cid_gens[i][dc] = ALLOCATE ( x );
					copy_vector ( h1_mod, cid_gens[i][dc], x );
					copy_vector ( h1_mod, id_gens[i][dc++], x );
					handle_aut ( i );
					out_log++;
					copy_vector ( h1_mod, matrix[0L], potrel*d );
					k = 1;
					for ( j = h1_dim; j--; )
						copy_vector ( h1[j], matrix[(long)k++], potrel*d );
					h1_dim = complement ( 1, potrel*d, k );
					for ( j = h1_dim; j--; )
						h1[j] = fsolution[j];
				}
				else
					h1_dim = 0;
			}
			id_gens_dim[i] = dc;
		}
	}
	if ( use_filtration ) {
		set_group_quotient ( old_class );
		set_number_of_relations ( old_class );
	}
	liftid = FALSE;
}
		
void showmat (int x, int y)
{
	register long i, j;
	for ( i = 0; i < y; i++ ) {
		for ( j = 0; j < x; j++ )
			printf ( "%1d", matrix[i][j] );
		printf ( "\n" );
	}
}

static void comp_centre(void)
{
	register int j, i, sec, l, offset;
	int s, d, zd;
	PCELEM res, help;
	int z, val;
	int x, y;
	VEC a_save;

	z_dim = ARRAY ( EXP_P_CLASS,  int );
	zentrum = ARRAY ( EXP_P_CLASS, COUPLE* );
	y = GNUMGEN;
	a_save = absolut;
	absolut = CALLOCATE ( y*y );
	inhom = CALLOCATE ( GNUMGEN );
	z_dim[0] = 0;

	for ( sec = 1; sec < EXP_P_CLASS; sec++ ) {
		swap_arith ( group_desc->g_max[sec] );
		x = z_dim[sec-1];
		s = EXP_P_LCS[sec].i_start;
		d = EXP_P_LCS[sec].i_dim;
		zd = 0;
		y = s;
		PUSH_STACK();
		for ( j = 0; j < x; j++ ) {
			offset = 0;
			
			/* clear relevant piece of previous centre */
			help = IDENTITY;
			copy_vector ( zentrum[sec-1][j].g, help, s );
			for ( i = 0; i < y; i++ ) {
				res = monom_mul ( g_invers(group_desc->nom[i]), 
					 monom_mul ( help, group_desc->nom[i] ) );
				for ( l = 0; l < d; l++ )
					matrix[(long)(offset+l)][(long)j] = res[s+l];
				offset += d;
			}
		}
		POP_STACK();
		if ( x > 0 )
			zd = x - solve_equations ( x, y*d );
		zentrum[sec] = ARRAY ( zd+d, COUPLE );
		z = 0;
		for ( j = x; j--; )
			if ( fsolution[j] ) {
				res = zentrum[sec][z].g = IDENTITY;
				PUSH_STACK();
				for ( i = x; i--; )
					if ( (val = fsolution[j][i]) != 0 ) {
						help = g_expo ( zentrum[sec-1][i].g, val );
						res = monom_mul ( help, res );
					}
				copy_vector ( res, zentrum[sec][z].g, bperelem );
				POP_STACK();
				zentrum[sec][z].i_g = g_invers ( zentrum[sec][z].g );
				z++;
			}
		for ( j = EXP_P_LCS[sec].i_start; j <= EXP_P_LCS[sec].i_end; j++ ) {
			zentrum[sec][z].g = group_desc->nom[j];
			zentrum[sec][z++].i_g = g_invers ( group_desc->nom[j] );
		}
		z_dim[sec] = z;
	}
	absolut = a_save;
}	

int gen_inner (void)
{
	register int i, k;
	int j, l;
	int centralizer, section;
	register PCELEM  z, i_z;
	PCELEM res, zwres, help;
	int inner_aut = 0;
	int s, d, x;
	int val;
	int old_class;
	
	old_class = set_group_quotient ( 0 );
	set_number_of_relations ( old_class );

	obgen_cnt = ARRAY ( EXP_P_CLASS+1, int );
	orbgen = ARRAY ( EXP_P_CLASS+1, COUPLE* );
	obgen_cnt[0] = obgen_cnt[1] = 0;
	for ( section = EXP_P_CLASS; section > 1; section-- ) {
		set_group_quotient ( section );
		set_number_of_relations ( section );
		centralizer = section-1;
		d = EXP_P_LCS[section].i_dim;
		s = EXP_P_LCS[section].i_start;
		x = d * potrel;
	
		k = z_dim[centralizer];
		inn_gens[section] = ARRAY ( k,  VEC  );
		cinn_gens[section] = ARRAY ( k,  VEC  );

		l = 0;
		for ( i = 0; i < k; i++ ) {
			z = zentrum[centralizer][i].g;
			i_z = zentrum[centralizer][i].i_g;
			inn_gens[section][i] = CALLOCATE ( x );
			cinn_gens[section][i] = CALLOCATE ( x );
			for ( j = nmin; j--; ) {
				PUSH_STACK();
				res = monom_mul ( i_z, monom_mul ( group_desc->nom[j], z ) );
				copy_vector ( res+s, cinn_gens[section][i]+j*d, d );
				copy_vector ( res+s, inn_gens[section][i]+j*d, d );
				copy_vector ( res+s, matrix[(long)l]+(long)(j*d), d );
				POP_STACK();
			}
			l++;
		}
		i = gauss_p_eliminate ( nmin*d, k );
		
		orbgen[section] = ARRAY ( i, COUPLE );
		
		set_group_quotient ( EXP_P_CLASS );
		/* compute orbit generators */
		obgen_cnt[section] = 0;
		for ( i = 0; i < k; i++ ) {
			if ( !iszero ( matrix[(long)i], nmin*d ) ) {
				orbgen[section][obgen_cnt[section]].g = help = res = IDENTITY;
				PUSH_STACK();
				for ( j = 0; j < k; j++ ) {
					if ( (val=matrix[(long)i][(long)(nmin*d+j)]) != 0 ) {
						zwres = g_expo ( zentrum[centralizer][j].g, val );
						help = monom_mul ( help, zwres );
					}
				}
				copy_vector ( help, res, bperelem );
				POP_STACK();
				orbgen[section][obgen_cnt[section]].i_g = 
					g_invers ( orbgen[section][obgen_cnt[section]].g );
				obgen_cnt[section]++;
				inner_aut++;
			}
		}
	}

#ifdef DEBUG
	puts ( "\norbit generators:\n" );
	for ( j = EXP_P_CLASS; j >= 1; j-- ) {
		for ( i = 0; i < obgen_cnt[j]; i++ ) {
			c_monom_write ( orbgen[j][i].g );
			printf ( ", " );
			c_monom_write ( orbgen[j][i].i_g );
			printf ( "\n" );
		}
	}
#endif

	set_group_quotient ( old_class );
	set_number_of_relations ( old_class );

	return ( inner_aut );
}

void set_len (void)
{
	int i, j, cnr, len, e;

	ap_len = ARRAY ( EXP_P_CLASS+1, int* );
	ac_len = ARRAY ( EXP_P_CLASS+1, int* );
	apotrel = ARRAY ( EXP_P_CLASS+1, int );
  	acomrel = ARRAY ( EXP_P_CLASS+1, int );
	
	cnr = (GNUMGEN*(GNUMGEN-1))>>1;
	for ( i = 1; i <= EXP_P_CLASS; i++ ) {
		ap_len[i] = ARRAY ( GNUMGEN, int );
		ac_len[i] = ARRAY ( cnr, int );
		if ( cauto ) {
			apotrel[i] = group_desc->exp_p_lcs[i].i_end+1;
			if ( i > 1 ) {
				j = group_desc->exp_p_lcs[i].i_start;
				acomrel[i] = (j*(j-1))>>1;
			}
			else
				acomrel[i] = 0;
		}
		else {
			apotrel[i] = NUMGEN;
			acomrel[i] = 0;
		}
		e = EXP_P_LCS[i].i_end;
		for ( j = 0; j < GNUMGEN; j++ ) {
			len = group_desc->p_len[j];
			if ( len == 0 )
				ap_len[i][j] = 0;
			else {
				while ( (len > 0) && (group_desc->p_list[j][len-1].g > e) ) len--;
				ap_len[i][j] = len;
			}
		}
		for ( j = 0; j < cnr; j++ ) {
			len = group_desc->c_len[j];
			if ( len == 0 )
				ac_len[i][j] = 0;
			else {
				while ( (len > 0) && (group_desc->c_list[j][len-1].g > e) ) len--;
				ac_len[i][j] = len;
			}
		}
	}

/*	for ( i = 1; i <= EXP_P_CLASS; i++ ) {
		printf ( "class no. %d\n", i );
		for ( j = 0; j < GNUMGEN; j++ ) {
			printf ( "%d,", ap_len[i][j] );
		}
		printf ( "\n" );
	} */
}
		
int check_epi (void)
{
	int is_epi = TRUE;
	VEC *trho;
	VEC a_save = absolut;
	int i, j, s, old_class;
	
	PUSH_STACK();
	trho = ARRAY ( GNUMGEN, VEC );
	for ( j = 0; j < EXP_P_LCS[1].i_dim; j++ )
		trho[j] = rho[j];
	old_class = set_group_quotient ( 0 );
	for ( i = 2; i <= EXP_P_CLASS; i++ ) {
		set_group_quotient ( i );
		x_dim = y_dim = EXP_P_LCS[i].i_dim;
		s = EXP_P_LCS[i].i_start;
		absolut = CALLOCATE ( y_dim );
		for ( j = s; j <= EXP_P_LCS[i].i_end; j++ ) {
/*			if ( DEF_LIST[j].is_power ) {
				trho[j] = g_expo ( trho[DEF_LIST[j].el1], GPRIME );
			}
			else {
				trho[j] = g_comm ( trho[DEF_LIST[j].el1], trho[DEF_LIST[j].el2] );
			}
			copy_vector ( trho[j]+s, matrix[(long)(j-s)], x_dim ); */
		}
		use_static_matrix();
		if ( GAUSS_ELIMINATE() != x_dim ) {
			is_epi = FALSE;
			break;
		}
	}
	POP_STACK();
	set_group_quotient ( old_class );
	absolut = a_save;
	return ( is_epi );
}

int check_orders (void)
{
	int is_ok = TRUE;
	int i, old_class;
	
	PUSH_STACK();
	old_class = set_group_quotient ( 0 );
	for ( i = 1; i < nmin; i++ ) {
		if ( log_g_order ( rho[i] ) < log_g_order ( group_desc->nom[i] ) ) {
			is_ok = FALSE;
			break;
		}
	}
	POP_STACK();
	set_group_quotient ( old_class );
	return ( is_ok );
}
	
void prepare_rho ( int isfirst )
{
	int i, j, k, l;
	int d, x;
	VEC vec;
	char val;
	
	PUSH_STACK();
	for ( i = 0; i < nmin; i++ ) {
		copy_vector ( mat+i*dim, rho[i], dim );
		zero_vector ( rho[i]+nmin, GNUMGEN - nmin );
	}
	
	for ( i = nmin; i < NUMGEN; i++ )
		zero_vector ( rho[i], GNUMGEN );
	
	if ( !isfirst ) {
		vec = MATRIX_MUL ( mat, TI );
		for ( i = EXP_P_CLASS; i > 1; i-- ) {
			d = EXP_P_LCS[i].i_dim;
			x = d * apotrel[i];
			for ( j = 0; j < id_gens_dim[i]; j++ ) {
				zero_vector ( cid_gens[i][j], x );
				for ( k = 0; k < nmin; k++ ) 
					for ( l = 0; l < nmin; l++ )
						if ( (val=vec[k*dim+l]) != 0 )
							ADD_MULT ( val, id_gens[i][j]+l*d, cid_gens[i][j]+k*d, d );
			}

			for ( j = 0; j < z_dim[i-1]; j++ ) {
				zero_vector ( cinn_gens[i][j], x );
				for ( k = 0; k < nmin; k++ ) 
					for ( l = 0; l < nmin; l++ )
						if ( (val=vec[k*dim+l]) != 0 )
							ADD_MULT ( val, inn_gens[i][j]+l*d, cinn_gens[i][j]+k*d, d );
			}
		
		
		}
	}
	POP_STACK();
}				 


void prepare_trafo (void)
{
	int i, j;
	
	T  = ALLOCATE ( dquad );
	TI = ALLOCATE ( dquad );
	for ( i = 0; i < nmin; i++ ) {
		copy_vector ( mat+i*dim, matrix[(long)i], nmin );
		copy_vector ( mat+i*dim, T+i*dim, nmin );
	}
	gauss_p_eliminate ( nmin, nmin );
	for ( i = 0; i < nmin; i++ )
		for ( j = 0; j < nmin; j++ )
			if ( matrix[(long)i][(long)j] != 0 ) {
				copy_vector ( matrix[(long)i]+nmin, TI+j*dim, dim );
				break;
			}
/*	puts ( "trafo:" );
	show_mat ( T );
	puts ( "inverse:" );
	show_mat ( TI ); */
}

int comp_aut ( int gl_iteration, int test_iso )
{
	int i, j;
/*	int k;
	int isfirst = TRUE; */
	int auts = 0;
	int c2_dim;
	VEC c2_vector;
	int isomorphic = FALSE;
	void *old_top;
	DYNLIST p;

	gcard = GCARD;

	aut_num = 0;
	isfirst = TRUE;
	search_for_iso = test_iso;
	
	dim = nmin;
	dquad = nmin * nmin;

	absolut = ALLOCATE ( NUMREL * GNUMGEN );
	dum_abs = CALLOCATE ( GNUMGEN*GNUMGEN );
	ind = CALLOCATE ( NUMREL );

	if ( do_compute_centre ) {
		id_gens = ARRAY ( EXP_P_CLASS+1,  VEC* );
		cid_gens = ARRAY ( EXP_P_CLASS+1, VEC* );
		inn_gens = ARRAY ( EXP_P_CLASS+1,  VEC* );
		cinn_gens = ARRAY ( EXP_P_CLASS+1, VEC* );
		id_gens_dim = ARRAY ( EXP_P_CLASS+1, int  );
	}

	list_aut_gens = ARRAY ( EXP_P_CLASS+1, LISTP );
	for ( i = 1; i <= EXP_P_CLASS+1; i++ ) {
		id_gens_dim[i] = -1;
		list_aut_gens[i].first = list_aut_gens[i].last = NULL;
	}
	set_len();
/*	osetup_elab_sockle(); */
	
	/* compute coefficient matrix of system of linear equations */
	
	gl_mat = CALLOCATE ( (long)NUMGEN*NUMREL );
	for ( i = 0; i < NUMREL; i++ ) {
		copy_vector ( h1_mat_row ( NUMGEN, RELATION[i] ),
			 gl_mat+(long)i*NUMGEN, NUMGEN );
		if ( iszero ( gl_mat+i*NUMGEN, NUMGEN ) )
			ind[i] = 1;
	}

	if ( do_compute_centre ) {
		comp_centre();
		inn_log = gen_inner();
	}

	inhom = ALLOCATE ( NUMGEN * GNUMGEN );
	rho = ARRAY ( NUMGEN, PCELEM );
	
	for ( i = 0; i < NUMGEN; i++ ) {
		rho[i] = IDENTITY;
		rho[i][i] = 1;
	}
	
/*	if ( !test_iso )
		lift_id(); */

#ifdef DEBUG
	for ( i = 2; i <= EXP_P_CLASS; i++ ) {
		printf ( "id_gens_dim[%d] = %d\n", i, id_gens_dim[i] );
		for ( j = 0; j < id_gens_dim[i]; j++ ) {
			for ( k = 0; k < EXP_P_LCS[i].i_dim*NUMGEN; k++ )
				printf ( "%1d", id_gens[i][j][k] );
			printf ( "\n" );
		}
	}
#endif
	
	/* loop over gl(nmin,Fp) */
	use_gl_iteration = gl_iteration;
	
	if ( only_normal_auts ) {
		mat = CALLOCATE ( dquad );
		for ( i = 0; i < NUMGEN; i++ )
			mat[i+i*dim] = 1;
		prepare_rho ( isfirst );
		old_top = GET_TOP();
		if ( olift_rho ( 2 ) ) {
			isomorphic = TRUE;
			if ( isfirst ) {
				lift_id();
				prepare_trafo();
				old_top = GET_TOP();
				isfirst = FALSE;
				auts = 1;
			}
		}
	}
	
	
	else if ( use_gl_iteration ) {
		init_gl ( nmin );
		while ( GET_GL_ELEMENT() ) {
			prepare_rho ( isfirst );

/*			if ( !isfirst ) {
				for ( i = 0; i < nmin; i++ ) {
					for ( j = 0; j < nmin; j++ )
						printf ( "%1d", rho[i][j] );
				}
				printf ( "\n" );
			}
			if ( !check_epi() ) {
				printf ( "check_epi failed\n" );
				ADD_TO_FAIL_LIST ( !test_iso );
				continue;
			}

			if ( !check_orders() ) {
				printf ( "check_orders failed\n" );
				ADD_TO_FAIL_LIST( !test_iso );
				continue;
			}
*/
			old_top = GET_TOP();
			if ( olift_rho ( 2 ) ) {
				isomorphic = TRUE;
				if ( test_iso ) 
					break;
				if ( isfirst ) {
					ADD_TO_LIST();
					lift_id();
					prepare_trafo();
					old_top = GET_TOP();
					isfirst = FALSE;
				}
				else {
					SET_TOP ( old_top );
					ADD_TO_LIST();
					handle_aut ( 1 );
					old_top = GET_TOP();
				}
				auts++;
			}
			else 
				ADD_TO_FAIL_LIST ( !test_iso );
			SET_TOP ( old_top );
		}
	}
	else {
		c2_dim = EXP_P_LCS[1].i_dim;
		c2_vector = CALLOCATE ( c2_dim * NUMGEN );
		c2_vector[c2_dim*NUMGEN-1] = 1;
		do {
			if ( check_iso ( c2_vector, c2_dim ) ) {
				for ( i = 0; i < NUMGEN; i++ )
					copy_vector ( c2_vector+i*c2_dim, rho[i], c2_dim );
				old_top = GET_TOP();
				if ( olift_rho ( 1 ) ) {
					isomorphic = TRUE;
					if ( test_iso )
						break;
					if ( isfirst ) {
						lift_id();
						old_top = GET_TOP();
						isfirst = FALSE;
					}
					else {
						SET_TOP ( old_top );
						handle_aut ( 1 );
						old_top = GET_TOP();
					}
					auts++;
				}
				SET_TOP ( old_top );
			}
		} while ( inc_count ( c2_vector, c2_dim*NUMGEN ) );
	}
	
	if ( !test_iso ) {
		hom_rec->class1_generators = auts-1;
		if ( auts != 0 ) {
			if ( !only_normal_auts )
				hom_rec->auts = gl_subgroup_order();
			else
				hom_rec->auts = 1;
			hom_rec->inn_log = inn_log;
		}
		else
			hom_rec->inn_log = -1;
		hom_rec->out_log = out_log;
		handle_inner_aut();
		hom_rec->aut_gens = ARRAY ( group_desc->exp_p_class+1, VEC* );
		for ( i = 1; i <= group_desc->exp_p_class; i++ ) {
			hom_rec->aut_gens[i] = ARRAY ( hom_rec->aut_gens_dim[i], VEC );
			p = list_aut_gens[i].first;
			for ( j = 0; j < hom_rec->aut_gens_dim[i]; j++ ) {
				hom_rec->aut_gens[i][j] = p->value.gv;
				p = p->next;
			}
		}
	}
/*	puts ( "fail stat:" );
	for ( i = 0; i < NUMREL; i++ )
		printf ( "rel. no. %2d : %d\n", i, fail_cnt[i] ); */
	
	return ( isomorphic );
}

HOM *automorphisms ( PCGRPDESC *g_desc, int quotient )
{
	PCGRPDESC *old_pc_group;
	GRPDSC *old_p_group;
	HOM *autom_rec;
	
	old_pc_group = group_desc;
	old_p_group = h_desc;
	
	if ( quotient > 0 && quotient <= g_desc->exp_p_class )
		set_main_group ( p_quotient ( g_desc, quotient ) );
	else
		set_main_group ( g_desc );
	set_h_group (  conv_rel ( g_desc ) );
	
	cauto = TRUE;
	autom_rec = ALLOCATE ( sizeof ( HOM ) );
	autom_rec->g = group_desc;
	autom_rec->h = NULL;
	autom_rec->elements = FALSE;
	autom_rec->stabs = NULL;
	autom_rec->aut_gens_dim = CALLOCATE ( (group_desc->exp_p_class+1) * sizeof ( int ) );
	autom_rec->out_gens_dim = CALLOCATE ( (group_desc->exp_p_class+1) * sizeof ( int ) );
	autom_rec->aut_gens = NULL;
	autom_rec->epimorphism = NULL;
	autom_rec->with_inner = TRUE;
	autom_rec->only_normal_auts = only_normal_auts;
	hom_rec = autom_rec;
	
	initialized = FALSE;
	
	nmin = GMINGEN;

	a_out = stdout;

	do_compute_centre = TRUE;
	comp_aut ( TRUE, FALSE );
	
	set_main_group ( old_pc_group );
	set_h_group ( old_p_group );
	cauto = FALSE;
	return ( autom_rec );
}

int group_hom_verify ( SHOM *f )
{
	PCGRPDESC *old_pc_group;
	GRPDSC *old_p_group;
	int i;
	PCELEM rel_obs;
	
	old_pc_group = group_desc;
	old_p_group = h_desc;
	
	set_main_group ( f->g );
	if ( f->h != NULL )
	    set_h_group ( f->h );
	else
	    set_h_group (  conv_rel ( f->g ) );
	
	PUSH_STACK();
	rho = ARRAY ( f->h == NULL ? f->g->num_gen : f->num_images, PCELEM );
	for ( i = 0; i < f->num_images; i++ ) {
	    rho[i] = ALLOCATE ( f->g->num_gen );
	    copy_vector ( f->image_list+i*f->g->num_gen, rho[i], f->g->num_gen );
	}
	if ( f->h == NULL )
	    for ( i = f->num_images; i < f->g->num_gen; i++ ) {
		   rho[i] = ALLOCATE ( f->g->num_gen );
		   copy_vector ( image_of_generator ( f->image_list, i ),
					  rho[i], f->g->num_gen );
	    }

	for ( i = 0; i < NUMREL; i++ ) {
	    rel_obs = g_obstr( RELATION[i] );
	    if ( !iszero ( rel_obs, GNUMGEN ) )
		   return ( FALSE );
	}
	
	set_main_group ( old_pc_group );
	set_h_group ( old_p_group );
	POP_STACK();
	return ( TRUE );
}

HOM *isomorphisms ( PCGRPDESC *g_desc, void *h_group, int is_pcgroup, int quotient )
{
	PCGRPDESC *old_pc_group;
	GRPDSC *old_p_group;
	GRPDSC *h2_desc;
	HOM *isom_rec;
	int minimal;
	int iso = TRUE;
	int j;
	
/*	FILT *org_exp_p_lcs;
	int org_exp_p_class; */
	
	old_pc_group = group_desc;
	old_p_group = h_desc;
	
	if ( quotient > 0 && quotient <= g_desc->exp_p_class )
		set_main_group ( p_quotient ( g_desc, quotient ) );
	else
		set_main_group ( g_desc );

	if ( is_pcgroup ) 
		h2_desc = conv_rel ( (PCGRPDESC *)h_group );
	else
		h2_desc = (GRPDSC *)h_group;

	set_h_group ( h2_desc );

	isom_rec = ALLOCATE ( sizeof ( HOM ) );
	isom_rec->h = h_group;
	isom_rec->g = group_desc;
	isom_rec->elements = FALSE;
	isom_rec->stabs = NULL;
	isom_rec->auts = 0;
	isom_rec->aut_gens = NULL;
	isom_rec->epimorphism = NULL;
	hom_rec = isom_rec;

	initialized = FALSE;
	
	nmin = GMINGEN;

	a_out = stdout;

	if ( is_pcgroup ) {
		minimal = TRUE;
		if ( ((PCGRPDESC *)h_group)->min_gen != g_desc->min_gen )
			iso = FALSE;
	}
	else {
		minimal = h2_desc->is_minimal; 
		if ( minimal ) {
			if ( h2_desc->num_gen != g_desc->min_gen )
				iso = FALSE;
		}
		else {
			if ( h2_desc->num_gen < g_desc->min_gen )
				iso =  FALSE;
		}
	}

	do_compute_centre = TRUE;
	
	if ( iso ) {
		isom_rec->only_normal_auts = only_normal_auts;
		isom_rec->with_inner = TRUE;
	if ( only_normal_auts ) {
		if ( !is_pcgroup )
			h2_desc->pc_pres = g_desc;
		isom_rec->epimorphism = CALLOCATE ( NUMGEN * GNUMGEN );
		for ( j = 0; j < NUMGEN; j++ )
			isom_rec->epimorphism[j*GNUMGEN+j] = 1;
		isom_rec->aut_gens_dim = CALLOCATE ( (group_desc->exp_p_class+1) * sizeof ( int ) );
		isom_rec->out_gens_dim = CALLOCATE ( (group_desc->exp_p_class+1) * sizeof ( int ) );
		comp_aut ( TRUE, FALSE );
	}
	else
	if ( comp_aut ( minimal, TRUE ) ) {
		if ( !is_pcgroup )
			h2_desc->pc_pres = g_desc;
		isom_rec->epimorphism = ALLOCATE ( NUMGEN * GNUMGEN );
		for ( j = 0; j < NUMGEN; j++ )
			copy_vector ( rho[j], isom_rec->epimorphism+j*GNUMGEN, GNUMGEN );
		
		if ( group_desc->defs )
			h2_desc = change_presentation ( rho );
		else
			h2_desc = conv_rel ( g_desc );
		set_h_group ( h2_desc );
/*		show_grpdsc ( h2_desc ); */

/*		org_exp_p_lcs = EXP_P_LCS;
		org_exp_p_class = EXP_P_CLASS;
		EXP_P_CLASS = GNUMGEN - EXP_P_LCS[1].i_dim + 1;
		EXP_P_LCS = ARRAY ( EXP_P_CLASS+1, FILT );
		EXP_P_LCS[1].i_start = 0;
		EXP_P_LCS[1].i_end = org_exp_p_lcs[1].i_end;
		EXP_P_LCS[1].i_dim = org_exp_p_lcs[1].i_dim;
		for ( j = 2; j <= EXP_P_CLASS; j++ ) {
			EXP_P_LCS[j].i_start = EXP_P_LCS[j-1].i_end+1;
			EXP_P_LCS[j].i_end = EXP_P_LCS[j].i_start;
			EXP_P_LCS[j].i_dim = 1;
		} */
	
		isom_rec->aut_gens_dim = CALLOCATE ( (group_desc->exp_p_class+1) * sizeof ( int ) );
		isom_rec->out_gens_dim = CALLOCATE ( (group_desc->exp_p_class+1) * sizeof ( int ) );

		do_compute_centre = FALSE;
		comp_aut ( TRUE, FALSE );
		
/*		EXP_P_LCS = org_exp_p_lcs;
		EXP_P_CLASS = org_exp_p_class; */
	}
	}
		
	
	set_main_group ( old_pc_group );
	set_h_group ( old_p_group );
	return ( isom_rec );
}

int is_isomorphic ( PCGRPDESC *g1_desc, void *g2_desc, int is_pcgroup, int quotient )
{
	PCGRPDESC *old_pc_group;
	GRPDSC *old_p_group;
	GRPDSC *h2_desc;
	int minimal = FALSE;
	int iso;
	
	old_pc_group = group_desc;
	old_p_group = h_desc;
	
	initialized = FALSE;
	
	if ( is_pcgroup ) {
		if ( ((PCGRPDESC *)g2_desc)->min_gen != g1_desc->min_gen )
			return ( FALSE );
		else {
			minimal = TRUE;
			h2_desc = conv_rel ( (PCGRPDESC *)g2_desc );
		}
	}
	else {
		h2_desc = (GRPDSC *)g2_desc;
		minimal = h2_desc->is_minimal;
		if ( minimal ) {
			if ( h2_desc->num_gen != g1_desc->min_gen )
				return ( FALSE );
		}
		else {
			if ( h2_desc->num_gen < g1_desc->min_gen )
			return ( FALSE );
		}
	}

	if ( quotient > 0 && quotient <= g1_desc->exp_p_class )
		set_main_group ( p_quotient ( g1_desc, quotient ) );
	else
		set_main_group ( g1_desc );
	set_h_group ( h2_desc );

	nmin = GMINGEN;

	do_compute_centre = TRUE;
	iso = comp_aut ( minimal, TRUE );		
	
	set_main_group ( old_pc_group );
	set_h_group ( old_p_group );
	return ( iso );
}

void change_leaf ( node p )
{
	if ( p->left != NULL ) {
		if ( p->left->nodetype == GGEN ) 
			p->left = h_image[p->left->value];
		else
			change_leaf ( p->left );
	}
	if ( p->right != NULL ) {
		if ( p->right->nodetype == GGEN ) 
			p->right = h_image[p->right->value];
		else
			change_leaf ( p->right );
	}
}

GRPDSC *change_presentation ( VEC iso[] )
{
	GRPDSC *new_h;
	int i;
	
	new_h = ALLOCATE ( sizeof ( GRPDSC ) );
	copy_group ( h_desc, new_h, FALSE );
	new_h->num_gen = group_desc->min_gen;
	new_h->is_minimal = TRUE;
	h_image = ARRAY ( NUMGEN, rel_node );
	for ( i = 0; i < NUMGEN; i++ )
		h_image[i] = word_to_node ( iso[i], group_desc->num_gen );
	for ( i = 0; i < new_h->num_rel; i++ )
		change_leaf ( new_h->rel_list[i] );
	return ( new_h );
}

/* routines needed for lifting procedure */

int handle_grp_aut ( VEC rho[], int begin )
{
	int ydim = begin;
	register int i, j, nr, offset;
	VEC rho_vec, rhohom, help;
	
	rho_vec = ALLOCATE ( new_xdim );
	rhohom = CALLOCATE ( h_out.old_end );
	
	i = 0;
	while ( (nr = dgroup_auts->stabs[new_cut-1][i]) != -1 ) {
		offset = new_xdim;
		for ( j = NUMGEN; j--; ) {
			offset -= h_out.old_dim;
			copy_vector ( rho[j], rhohom, h_out.old_start );
			help = n_apply ( nr, rhohom, new_cut );
			copy_vector ( help+h_out.old_start, rho_vec+offset,
					  h_out.old_dim );
		}
		if ( !iszero ( rho_vec, new_xdim ) )
			copy_vector ( rho_vec, matrix[(long)ydim++], new_xdim );
		i++;
	}
	return ( ydim );
}

VEC c_apply (int aut_no, VEC cvec)
{
	VEC image = CALLOCATE ( GCARD );
	int *autv;
	register int i = GCARD;
	register char val;
	
	PUSH_STACK();
	autv = hom_to_image ( dgroup_auts->aut_gens[1][aut_no] );
	for ( ;i--; )
		if ( (val = cvec[i]) != 0 ) image[autv[i]] = val;
	POP_STACK();
	return ( image );
}

VEC n_apply (int aut_no, VEC nvec, int cut)
{
	register int fend = FILTRATION[cut].i_start;
	VEC image = CALLOCATE ( fend );
	VEC help;
	
	PUSH_STACK();
	help = n_c_trans ( nvec, cut );
	help = c_apply ( aut_no, help );
	copy_vector ( c_n_trans ( help, cut ), image, fend );
	POP_STACK();
	return ( image );
}

void ostabilizer ( HOM *maps )
{
	register int fend;
	int i, j;
	int mod_id = maps->g->max_id;
	int invariant;
	int count;
	int autord;
	VEC image;
	
	maps->stabs = ARRAY ( mod_id+1, int* );
	autord = maps->aut_gens_dim[1];
	do {
		maps->stabs[mod_id] = (int *)CALLOCATE ( (autord+1)*s_int );
		count = 0;
		fend = FILTRATION[mod_id].i_start;
		for ( i = autord; i--; ) {
			PUSH_STACK();
			invariant = TRUE;
			for ( j = 0; j < GMINGEN; j++ ) {
				image = n_apply ( i, NGEN_VEC[j], mod_id );
				SUBB_VECTOR ( NGEN_VEC[j], image, fend );
				if ( !(invariant &= iszero ( image, fend ) ) )
					break;
			}
			if ( invariant ) maps->stabs[mod_id][count++] = i;
			POP_STACK();
		}
/* 		printf ( "stabs[%d] : ", mod_id ); */
/* 		for ( j = 0; j < count; j++ ) */
/* 		    printf ( " %d", maps->stabs[mod_id][j] ); */
/* 		printf ( "\n" ); */
		maps->stabs[mod_id][count] = -1;
	} while ( --mod_id > 1 );
}

int get_ideal ( int s )
{
    register int i = 1;

    while ( FILTRATION[i].i_end < s ) i++;
    return ( i > MAX_ID ? MAX_ID : i );
}

void stabilizer ( HOM *maps )
{
	register int fend;
	int i, j, k, nz;
	int mod_id = maps->g->max_id;
	int *count;
	int autord;
	VEC image;
	
	maps->stabs = ARRAY ( mod_id+1, int* );
	autord = maps->aut_gens_dim[1];
	count = ARRAY ( mod_id+1, int );
	for ( i = mod_id; i > 1; i-- )  {
	    maps->stabs[i] = (int *)CALLOCATE ( (autord+1)*s_int );
	    count[i] = 0;
	}

	fend = FILTRATION[mod_id].i_start;
	for ( i = autord; i--; ) {
	    PUSH_STACK();
	    nz = GCARD;
	    for ( j = 0; j < GMINGEN; j++ ) {
		   image = n_apply ( i, NGEN_VEC[j], mod_id );
		   SUBB_VECTOR ( NGEN_VEC[j], image, fend );
		   for ( k = 0; k < fend; k++ )
			  if ( image[k] != 0 ) break;
		   if ( k < nz ) 
			  nz = k;
	    }

/*	    for ( k = get_ideal ( nz ); k > 1; k-- )
	    maps->stabs[k][count[k]++] = i;  */ /* new version !!! */
	    k = get_ideal ( nz );
	    if ( k > 1 )
		   maps->stabs[k][count[k]++] = i;
	    POP_STACK();
	}
 	for ( k = mod_id; k > 1; k-- ) {
/* 	    printf ( "stabs[%d] : ", k ); */
/* 	    for ( i = 0; i < count[k]; i++ ) */
/* 		   printf ( " %d", maps->stabs[k][i] ); */
/* 	    printf ( "\n" ); */
 	    maps->stabs[k][count[k]] = -1;
 	}
}

int prepare_aut ( PCGRPDESC *g_desc )
{
	
	if ( g_desc->autg == NULL ) {
		save_memory_stack();
		use_permanent_stack();
		dgroup_auts = automorphisms ( g_desc, 0 );
		liftings_mod2 ( dgroup_auts->aut_gens[1], dgroup_auts->aut_gens_dim[1], GMINGEN, GPRIME );
		restore_memory_stack();
	}
	else
		dgroup_auts = g_desc->autg;
	if ( dgroup_auts->elements == FALSE ) {
		save_memory_stack();
		use_permanent_stack();
		dgroup_auts = generate_automorphism_group ( dgroup_auts, TRUE );
		restore_memory_stack();
	}
	if ( dgroup_auts->stabs == NULL ) {
		save_memory_stack();
		use_permanent_stack();
		stabilizer ( dgroup_auts );
		restore_memory_stack();
	}
	return ( TRUE);
}

PCELEM image ( VEC rhov, PCELEM el )
{
	PCELEM im = IDENTITY;
	PCELEM zwres, ima;
	int j, pot;

	PUSH_STACK();
	ima = IDENTITY;
	for ( j = 0; j < GNUMGEN; j++ ) {
		if ( (pot = el[j]) != 0 ) {
			zwres = g_expo ( image_of_generator (  rhov, j ), pot );
			ima = monom_mul ( ima, zwres );
		}
	}
	POP_STACK();
	copy_vector ( ima, im, bperelem );
	return ( im );
}

int *hom_to_image ( VEC rhov )
{
	int *imagevec;
	PCELEM el, image, zwres;
	int j, k, pot;
	
	imagevec = CALLOCATE ( GCARD * sizeof ( int ) );
	
	PUSH_STACK();
	el = IDENTITY;
	k = 0;
	do {
		PUSH_STACK();
		image = IDENTITY;
		for ( j = 0; j < GNUMGEN; j++ ) {
			if ( (pot = el[j]) != 0 ) {
				zwres = g_expo ( image_of_generator (  rhov, j ), pot );
				image = monom_mul ( image, zwres );
			}
		}
		imagevec[k++] = IND ( image );
		POP_STACK();
	} while ( inc_el ( el ) );
	POP_STACK();
	return ( imagevec );
}

void show_single_hom ( VEC rhov, int num_of_images )
{
	int j;
	int *permvec;

	if ( aut_pres_style == IMAGES ) {
		printf (  "%c", displaystyle == GAP ? '[' : '(' );
		for ( j = 0; j < num_of_images; j++ ) {
			word_write ( displaystyle == GAP ?
				image_of_generator ( rhov, group_desc->image[j] ) :
				image_of_generator ( rhov, j ) );
			if ( j < num_of_images-1 )
				printf ( ", " );
			else
				printf ( "%c", displaystyle == GAP ? ']' : ')' );
		}
	}
	if ( aut_pres_style == PERMUTATIONS ) {
		printf ( "(0" );
		permvec = hom_to_image ( rhov );
		for ( j = 1; j < GCARD; j++ )
			printf ( ",%d", permvec[j] );
		printf ( ")\n" );
	}
	
	if ( aut_pres_style == CYCLES ) {
		permvec = hom_to_image ( rhov );
		print_cycle ( permvec );
	}
}

void aut_show_hom ( SHOM *aut )
{
    PCGRPDESC *old_pc_group;

    old_pc_group = group_desc;
    set_main_group ( aut->g );

    if ( displaystyle == GAP )
	   printf ( "SISYPHOS.SISISO := " );
    show_single_hom ( aut->image_list, displaystyle == GAP ? GNUMGEN : aut->num_images );
    if ( displaystyle == GAP )
	   printf ( ";\n" );
    else
	   printf ( "\n" );
    set_main_group ( old_pc_group );
}

void show_hom ( HOM *hom, char *recdesc )
{
	int i, j, k;
	unsigned long ha, hb;
	PCGRPDESC *old_pc_group;
	int aut_num = 1;
	int numgen;
	int num_of_images;
	int last_class;
	int agens;
	int identitygroup;
	int gens_a, a_cnt;
	int normal_flag, inner_flag;
	VEC rhov;
	char *noniso_prefix;
	char *struc_prefx;
	char *item_prefx;
	char *rec_prefix;
	char *rec_postfx;
	char *assign_sym;
	char lpar;
	char *rpar;

	/* save flags */
	normal_flag = only_normal_auts;
	inner_flag = with_inner;
	with_inner = aut_pres_all;
	only_normal_auts = hom->only_normal_auts;
	
	if ( displaystyle == GAP )
		noniso_prefix = "#I ";
	else
		noniso_prefix = "";

	if ( hom->auts == 0 && !hom->elements ) {
		printf ( "%sgroups are not isomorphic!\n", noniso_prefix );
		if ( displaystyle == GAP )
			printf ( "SISYPHOS.SISISO := false;\n" );
		/* restore flags */
		with_inner = inner_flag;
		only_normal_auts = normal_flag;
		return;
	}

	old_pc_group = group_desc;
	set_main_group ( hom->g );

	PUSH_STACK();
	rec_prefix = CALLOCATE ( 35 );
	if ( displaystyle == GAP ) {
		sprintf ( rec_prefix, "SISYPHOS.SISISO%s := rec (\n", recdesc );
		struc_prefx = "generators := [\n";
		item_prefx = "     ";
		rec_postfx = "] );\n";
		assign_sym = ":=";
		lpar = '[';
		rpar = "]";
		num_of_images = GNUMGEN;
	}
	else {
		struc_prefx = "";
		rec_prefix[0] = '\0';
		if ( hom->elements == TRUE )
			item_prefx = "element no.";
		else
			item_prefx = "generator no.";
		rec_postfx = "\n";
		assign_sym = ":";
		lpar = '(';
		rpar = ")";
		num_of_images = GMINGEN;
	}
	
	if ( hom->elements == TRUE )
		last_class = 1;
	else
		last_class = hom->g->exp_p_class;
	numgen = hom->h == NULL ? hom->g->num_gen : hom->h->num_gen;

	printf ( "%s", rec_prefix );
	
	if ( (alog2(hom->auts)+(hom->out_log+hom->inn_log)*alog2(hom->g->prime)) > 31 ) {
          printf ( "sizeOutG %s %d*%1d^%d,\n", assign_sym, hom->auts, hom->g->prime, hom->out_log );
          printf ( "sizeInnG %s %1d^%d,\n",    assign_sym, hom->g->prime, hom->inn_log );                              
          printf ( "sizeAutG %s %d*%1d^%d,\n", assign_sym, hom->auts, hom->g->prime , hom->out_log + hom->inn_log );
	}
	else {
		for ( i = 0, ha = 1; i < hom->out_log; i++, ha *= hom->g->prime );
          printf ( "sizeOutG %s %ld,\n", assign_sym, hom->auts*ha );
		for ( i = 0, hb = 1; i < hom->inn_log; i++, hb *= hom->g->prime );
          printf ( "sizeInnG %s %ld,\n", assign_sym, hb );
          printf ( "sizeAutG %s %ld,\n", assign_sym, hom->auts*ha*hb );
	}

	if ( hom->epimorphism != NULL ) {
		printf ( "epimorphism %s %c", assign_sym, lpar );
		for ( j = 0; j < numgen; j++ ) {
			word_write (hom->epimorphism+j*GNUMGEN );
			if ( j < numgen-1 )
				printf ( ", " );
			else
				printf ( "%s", rpar );
		}
		printf ( ",\n" );
	}

	if ( !hom->elements ) {
		gens_a = with_inner == TRUE ? hom->out_log+hom->inn_log : hom->out_log;
		if ( !only_normal_auts )
			gens_a += hom->class1_generators;
	}
	else
		gens_a = hom->aut_gens_dim[1];
	a_cnt = 0;
	
	identitygroup = (gens_a == 0);
	
	if ( (aut_pres_style != NONE) ) {
		printf ( "%s", struc_prefx );
		for ( i = 1; i <= last_class; i++ ) {
			agens = with_inner == TRUE ? hom->aut_gens_dim[i] : hom->out_gens_dim[i];
			if ( i == 1 && identitygroup )
				agens = 1;
			for ( k = 0; k < agens; k++ ) {
				PUSH_STACK();
				if ( identitygroup ) {
					identitygroup = FALSE;
					rhov = CALLOCATE ( numgen * GNUMGEN );
					for ( j = 0; j < numgen; j++ )
						rhov[j*GNUMGEN+j] = 1;
				}
				else
					rhov = hom->aut_gens[i][k];
						
				a_cnt++;
				printf ( "%s ", item_prefx );
				if ( displaystyle != GAP )
					printf ( "%4d : ", aut_num++ );

				show_single_hom ( rhov, num_of_images );
				
				if ( a_cnt < gens_a )
					printf ( ",\n" );
				POP_STACK();
			}
		}
		printf ( "%s", rec_postfx );	
	}

/*	show_aut_pres ( hom ); */

	set_main_group ( old_pc_group );
	
	/* restore flags */
	with_inner = inner_flag;
	only_normal_auts = normal_flag;
	POP_STACK();
}

VEC straighten_hom ( VEC hrho, int class )
{
	VEC res, h;
	int i, j;
	int isid;
	int s = EXP_P_LCS[class].i_start;
	int e = EXP_P_LCS[class].i_end;
	
	res = ALLOCATE ( g_gens * bperelem );
	h = hrho;
	PUSH_STACK();

	isid = TRUE;
	for ( j = 0; j < g_gens; j++ ) {
		for ( i = s; i <= e; i++ ) {
			if ( h[j*bperelem+i] != 0 )
				isid = FALSE;
		}
	}
	if ( !isid )
		h = exp_concatenate_aut ( h, GPRIME );
	
	copy_vector ( h, res, g_gens * bperelem );
	POP_STACK();
	return ( res );
}

int maps_to_liftable ( int sclass, int eclass )
{
	VEC r;
	int i, j, c;
	int yds, xds;
	VEC as;
	int mtl = TRUE;
	int d, s;
	
	g_gens = GMINGEN;
	
	PUSH_STACK();
	r = ALLOCATE ( g_gens * bperelem );
	for ( i = 0; i < g_gens; i++ )
		copy_vector ( rho[i], r+i*bperelem, bperelem );

	for ( c = sclass+1; c <= eclass; c++ )
		r = straighten_hom ( r, c-1 );
	c = eclass;
	d = EXP_P_LCS[c].i_dim;
	s = EXP_P_LCS[c].i_start;
	yds = y_dim;
	xds = x_dim;
	as = absolut;
	y_dim = id_gens_dim[c]+1;
	x_dim = g_gens * d;
	absolut = CALLOCATE ( y_dim );
	for ( i = 0; i < id_gens_dim[c]; i++ )
		copy_vector ( id_gens[c][i], matrix[(long)i], x_dim );
	for ( j = 0; j < g_gens; j++ )
		copy_vector ( r+j*bperelem+s, matrix[(long)i]+j*d, d );
/*	for ( j = 0; j < x_dim; j++ )
		printf ( "%1d", matrix[(long)i][j] );
	printf ( "\n" ); */
	use_static_matrix();
	GAUSS_ELIMINATE();
	mtl = iszero ( matrix[(long)i], x_dim );
	y_dim = yds;
	x_dim = xds;
	absolut = as;
	POP_STACK();
	return ( mtl );
}

/* end of module automorphism group */
