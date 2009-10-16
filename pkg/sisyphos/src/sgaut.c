/********************************************************************/
/*                                                                  */
/*  Module        : Obstruction                                     */
/*                                                                  */
/*  Description :                                                   */
/*     This module is used to compute the matrices describing the g */
/*     - operation on 1+I^n/1+I^2n.                                 */
/*                                                                  */
/********************************************************************/

/* 	$Id: sgaut.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: sgaut.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.3  1995/12/15 10:07:47  pluto
 * 	Changed order of arguments in call to 'strcpy' in 'ag_conv_rel'.
 *
 * 	Revision 3.2  1995/12/12 17:14:34  pluto
 * 	Corrected copying of generator names in 'ag_conv_rel'.
 *
 * 	Revision 3.1  1995/08/10 11:46:46  pluto
 * 	Minor changes.
 *
 * 	Revision 3.0  1995/06/23 16:50:05  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	Corrected start value of for-llop in 'scalc-matrix'.
 *
 * Revision 1.2  1995/01/05  17:20:52  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: sgaut.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#include <ctype.h>
#include "aglobals.h"
#include "pc.h"
#include	"aggroup.h"
#include	"hgroup.h"
#include "fdecla.h"
#include	"storage.h"
#include	"error.h"
#include	"solve.h"
#include	"aut.h"

#define POWERS					aggroup->powers
#define POTS					aggroup->p_list
#define CONJUGATES				aggroup->conjugates
#define AVEC					aggroup->avec

void ag_centre                     _(( AGGRPDESC *ag_group ));
void ag_word_write 				_(( PCELEM elem ));
PCGRPDESC *ag_max_p_quotient  	_(( AGGRPDESC *g_desc ));
VEC *conj_list 				_(( PCELEM *rho, int s, int *l ));

typedef struct {
	PCELEM rho;
	VEC *x_mat;
} stilde_expr;

typedef stilde_expr *ATEP;

#define ANEW_TE(t)	{t = ALLOCATE ( sizeof ( stilde_expr ) );\
				t->rho = CALLOCATE ( bperelem );\
				t->x_mat = ALLOCATE ( ANUMGEN * sizeof ( VEC ) );\
				for ( i = 0; i < ANUMGEN; i++ )\
					t->x_mat[i] = CALLOCATE ( dquad );}
				
#define ACOPY_TE(t1, t2)	{copy_vector ( t1->rho, t2->rho, bperelem );\
					for ( i = 0; i < ANUMGEN; i++ )\
						copy_vector ( t1->x_mat[i],t2->x_mat[i], dquad );}

#define ASUB_TE(t1, t2)	{SUBA_VECTOR ( t1->rho, t2->rho, bperelem );\
					for ( i = 0; i < ANUMGEN; i++ )\
						SUBA_VECTOR ( t1->x_mat[i], t2->x_mat[i], dquad );}


VEC Idmat 			_(( void ));
PCELEM g_comm 			_(( PCELEM el, PCELEM er ));
static int check_iso 	_(( int s, int c2_dim ));
int max_elab_section 	_(( int start ));
int get_section 		_(( int ind ));
int set_group_quotient          _(( int class ));
void set_number_of_relations    _(( int class ));

extern int (*get_gl_element)	_(( void ));
extern void (*add_to_list)	_(( void ));
#define GET_GL_ELEMENT (*get_gl_element)
#define ADD_TO_LIST (*add_to_list)

extern AGGRPDESC *aggroup;
extern GRPDSC *h_desc;
extern int start, bperelem;
extern int dim, dquad;
int sadim, sadquad;
PCELEM *sgrho;
extern VEC mat;
extern int prime;

static int numrel;
static LISTP list_auts;
static int section = 0;
static long aut_num = 0L;

PCELEM sideal;

VEC *sopmatrix;			 	/* operation of base element
						   Gi on I^n/I^m piece */

void scalc_matrix ( PCELEM rho, VEC mat )
/* compute one l_matrix/ */
/* r_matrix pair		 */
{
	register int j;
	register int off2;
	char *old_top;
	PCELEM res;
	
	old_top = GET_TOP();
	for ( j = start+dim; j-- > start; ) {
		off2 = j - start;
		zero_vector ( sideal, bperelem );
		sideal[j] = 1;
		res = agcollect ( ag_invers ( rho ), sideal );
		res = agcollect ( res, rho );
		copy_vector ( res+start, mat+off2*dim, dim );
	}
	SET_TOP(old_top);
}

void sget_op_mats ( int start )
/* get all l_matrix/     */
/* r_matrix pairs		*/
{
	PCELEM rho;
	register int i;
	char *old_top;
	
	old_top = GET_TOP();
	rho = ALLOCATE ( bperelem );
	sideal = ALLOCATE ( bperelem );
	for ( i = start; i--; ) {
		zero_vector ( rho, bperelem );
		rho[i] = 1;
		scalc_matrix ( rho, sopmatrix[i] );
	}
	SET_TOP ( old_top );
}

void sget_rho_mat ( PCELEM rho, VEC *r_mat )
/* get matrix representing operation of rho on I^n/I^m */
/* from the left/right side (left = TRUE/FALSE)        */
{
	int j;
	register char val;
	VEC res, zw;
		
	*r_mat = res = Idmat();
	PUSH_STACK();
	for ( j = start; j--; ) {
		if ( ( val = rho[j] ) != 0 ) {
			zw = matrix_exp ( sopmatrix[j], val );
			res = MATRIX_MUL ( zw, res );
		}
	}
	copy_vector ( res, *r_mat, dquad );
	POP_STACK();
}


ATEP sinvers_te ( ATEP t )
{
	int i;
	ATEP inv;
	PCELEM i_rho;
	VEC zw, l_rho_mat;
	
	ANEW_TE ( inv );
	PUSH_STACK();
	i_rho = ag_invers ( t->rho );
	sget_rho_mat ( i_rho, &l_rho_mat );
	copy_vector ( i_rho, inv->rho, bperelem );
	for ( i = 0; i < ANUMGEN; i++ ) {
		zw = MATRIX_MUL ( t->x_mat[i], l_rho_mat  );
		SMUL_VECTOR ( prime-1, zw, dquad );
		copy_vector ( zw, inv->x_mat[i], dquad );
	}
	POP_STACK();
	return ( inv );
}
				
ATEP smul_te ( ATEP t1, ATEP t2 )
{
	int i;
	ATEP res;
	VEC zw;
	VEC r_rho_mat;
	
	ANEW_TE ( res );
	PUSH_STACK();
	copy_vector ( agcollect ( t1->rho, t2->rho ), res->rho, bperelem );
	sget_rho_mat ( t2->rho, &r_rho_mat );
	for ( i = 0; i < ANUMGEN; i++ ) {
		zw = MATRIX_MUL ( t1->x_mat[i], r_rho_mat );
		copy_vector ( t2->x_mat[i], res->x_mat[i], dquad );
		ADD_VECTOR ( zw, res->x_mat[i], dquad );
	}
	POP_STACK();
	return ( res );
}

ATEP scomm_te ( ATEP t1, ATEP t2 )
{
	int i;
	ATEP res;
	VEC zw;
	VEC l_rho_mat, r_rho_mat, m_rho_mat;
	PCELEM r, r1;
	
	ANEW_TE ( res );
	PUSH_STACK();
	r = ag_comm ( t1->rho, t2->rho );
	r1 = agcollect ( t1->rho, r );
	copy_vector ( r, res->rho, bperelem );
	sget_rho_mat ( r, &l_rho_mat );
	sget_rho_mat ( r1, &m_rho_mat );
	sget_rho_mat ( t2->rho, &r_rho_mat );
	for ( i = 0; i < ANUMGEN; i++ ) {
		copy_vector ( t2->x_mat[i], res->x_mat[i], dquad );

		zw = MATRIX_MUL ( t1->x_mat[i], l_rho_mat );
		SMUL_VECTOR ( prime-1, zw, dquad );
		ADD_VECTOR ( zw, res->x_mat[i], dquad );
		
		zw = MATRIX_MUL ( t2->x_mat[i], m_rho_mat );
		SMUL_VECTOR ( prime-1, zw, dquad );
		ADD_VECTOR ( zw, res->x_mat[i], dquad );
		
		zw = MATRIX_MUL ( t1->x_mat[i], r_rho_mat );
		ADD_VECTOR ( zw, res->x_mat[i], dquad );
	}
	POP_STACK();
	return ( res );
}

ATEP sexp_te ( ATEP t, int pow )
{
	register int i;
	ATEP res;
	ATEP h;
	
	ANEW_TE ( res );
	PUSH_STACK();
	h = res;
	ACOPY_TE ( t, h );
	i = 4096;
	while ( !(pow & i ) ) i >>= 1;
	while ( (i >>= 1) != 0 ) {
		h = smul_te ( h, h );
		if ( pow & i )
			h = smul_te ( h, t );
	}
	ACOPY_TE ( h, res );
	POP_STACK();
	return ( res );

}

ATEP ssetup_obs ( node p )
{
	register ATEP l, r;
	register ATEP obs;
	int i;
	
	ANEW_TE ( obs );
	PUSH_STACK();

	switch ( p->nodetype ) {
		case GGEN:
				copy_vector ( sgrho[p->value], obs->rho, bperelem );
				copy_vector ( Idmat(), obs->x_mat[p->value], dquad );
				break;
		case EQ  :
				if ( p->right != NULL ) {
					r = ssetup_obs ( p->right );
					ACOPY_TE ( r, obs );
				}
				l = ssetup_obs ( p->left );
				ASUB_TE ( l, obs );						
				break;
		case COMM:

/*				l = ssetup_obs ( p->left );
				r = ssetup_obs ( p->right );
				l1 = smul_te ( sinvers_te ( l ), sinvers_te ( r ) );
				l1 = smul_te ( l1,  smul_te ( l, r ) );
				ACOPY_TE ( l1, obs );
*/
				l = scomm_te ( ssetup_obs ( p->left ), ssetup_obs ( p->right ) );
				ACOPY_TE ( l, obs );
				break;
		case EXP :
				l = ssetup_obs ( p->left );
				l = sexp_te ( l, (p->value > 0) ? p->value : -p->value );
				if ( p->value < 0 )
					l = sinvers_te ( l );
				ACOPY_TE ( l, obs );
				break;
		case MULT:
				l =  smul_te ( ssetup_obs ( p->left ), ssetup_obs ( p->right ) );
				ACOPY_TE ( l, obs );
				break;
		default:
				puts ( "Error in relation" );
	}
	POP_STACK();
	return ( obs );
}

void sz1_mat (void)
/* setup system of linear equations */
{
	int i, j, k, l;
	int y_offset = sadim * numrel;
	int x_offset;
	int sdim, sdquad;
	ATEP obs;
	
	/* save old values of dim and dquad */
	sdim = dim;
	sdquad = dquad;
	dim = sadim;
	dquad = sadquad;

	for ( i = numrel; i--;  ) {
		y_offset -= dim;
		PUSH_STACK();
		obs = ssetup_obs ( RELATION[i] );
		copy_vector ( obs->rho+start, absolut+y_offset, dim );
		for ( j = 0; j < ANUMGEN; j++ ) {
			x_offset = j * dim;
			for ( k = dim; k--; ) {
				for ( l = dim; l--; )
					matrix[(long)(y_offset+l)][(long)(x_offset+k)] =
						obs->x_mat[j][k*dim+l];
			}
		}
		POP_STACK();
	}

/*	puts ( "absolut1" );
	for ( i = 0; i < dim*numrel; i++ )
	  printf ( "%1d", absolut[i] );
	printf ( "\n" ); 
*/

	SMUL_VECTOR ( prime-1, absolut, dim * numrel );

/*	puts ( "matrix" );
	for ( i = 0; i < dim*numrel; i++ ) { 
	  for ( j = 0; j < dim*ANUMGEN; j++ )
	    printf ( "%1d", matrix[i][j] );
	  printf ( "\n" );
	 }
puts ( "absolut2" );
	for ( i = 0; i < dim*numrel; i++ )
	  printf ( "%1d", absolut[i] );
	printf ( "\n" );
*/	

	/* restore old values of dim and dquad */
	dim = sdim;
	dquad = sdquad;
}

int ag_setup_section ( int class, VEC **h, VEC *s )
/* compute largerst i with P_class/P_i elementary abelian and setup
   operating matrices for G/P_class operating on P_class/P_i.
   Setup and solve system of linear equations.
*/
{
	int i, j, k;
	int sdim, sdquad;
	int xd, yd;
	int e_end;
	VEC *h1;
	
	
	start = ELAB_SERIES[class].i_start;
	e_end = ELAB_SERIES[class].i_end;
	
	swap_arith ( POWERS[start] );

	/* save old values of dim and dquad */
	sdim = dim;
	sdquad = dquad;
	dim = sadim = e_end - start + 1;
	dquad = sadquad = sadim * sadim;
	*s = ALLOCATE ( ANUMGEN * sadim );

	PUSH_STACK();
	/* compute operating matrices for identity */
	sopmatrix = ARRAY ( start, VEC );
	for ( j = start; j--; ) {
		sopmatrix[j] = ALLOCATE ( sadquad );
	}

	sget_op_mats ( start );

/*	for ( j = 0; j < start; j++ ) {
		printf ( "\nmat. no, %d\n", j );
		show_mat ( sopmatrix[j] );
	}
*/
	xd = ANUMGEN * sadim;
	yd = numrel * sadim;
	absolut = ALLOCATE ( yd );
	inhom = ALLOCATE ( xd );
	sz1_mat();
	solve_equations ( xd, yd );
	
	k = 0;
	for ( i = xd; i--; ) {
		if ( fsolution[i] ) {
			for ( j = 0; j < ANUMGEN; j++ )	
				copy_vector ( fsolution[i], matrix[(long)k], xd );
			k++;
		}
	}
	copy_vector ( inhom, *s, xd );


	POP_STACK();

	h1 = ARRAY ( k, VEC );

	j = 0;
	for ( i = 0; i < k; i++ ) {
		h1[j] = ALLOCATE ( xd );
		copy_vector ( matrix[(long)i], h1[j++], xd );
	}
			
	/* restore old values of dim and dquad */
	dim = sdim;
	dquad = sdquad;

	
	*h = h1;
	return ( j );
}

GRPDSC *ag_conv_rel ( AGGRPDESC *g_desc )
{
	int i, j, k, c;
	node no, no1, no2, no3, no4, no5;
	GRPDSC *h_desc = ALLOCATE ( sizeof ( GRPDSC ) );
  
	h_desc->prime = 0;
	h_desc->num_gen = g_desc->num_gen;
	h_desc->num_rel = CN ( g_desc->num_gen, 0 ) + g_desc->num_gen;
	h_desc->gen = ALLOCATE ( g_desc->num_gen * sizeof ( char * ) );
	for ( i = 0; i < g_desc->num_gen; i++ )
		h_desc->gen[i] = ALLOCATE ( strlen ( g_desc->gen[i] )+1 );
	for ( i = 0; i < g_desc->num_gen; i++ )
		strcpy ( h_desc->gen[i], g_desc->gen[i] );
	h_desc->is_minimal = FALSE;
	h_desc->pc_pres = NULL;
	h_desc->isog = NULL;
	
	h_desc->rel_list = ALLOCATE ( h_desc->num_rel * sizeof ( node ) );
	
	/* power relations */
	for ( i = 0; i < h_desc->num_gen; i++ ) {
		G_NODE ( no1, i );
		E_NODE ( no2, no1, g_desc->powers[i] );
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

static void handle_ag_aut (void)
{
	register int j;
	VEC sr;
	int gens;
	
	gens = ANUMGEN;
	
	PUSH_STACK();
	aut_num++;
/*	use_permanent_stack(); */
	/* save rho in dynamic list */
/*	if ( list_auts.last == NULL ) {
		list_auts.last = list_auts.first = ALLOCATE ( sizeof ( dynlistitem ) );
	}
	else {
		list_auts.last->next = ALLOCATE ( sizeof ( dynlistitem ) );
		list_auts.last = list_auts.last->next;
	}
	sr = list_auts.last->value.gv = ALLOCATE ( gens * ANUMGEN );
	for ( j = 0; j < gens; j++ )
		copy_vector ( rho[j], sr + j*ANUMGEN, ANUMGEN );
	list_auts.last->next = NULL; */
	
/*	if ( aut_num++ % 1000 == 0 ) { */
	sr = ALLOCATE ( gens * ANUMGEN );
	for ( j = 0; j < gens; j++ )
		copy_vector ( sgrho[j], sr + j*ANUMGEN, ANUMGEN );
		
		printf ( "%6ld : (", aut_num ); 
		for ( j = 0; j < ANUMGEN; j++ ) {
			ag_word_write ( sr+j*ANUMGEN );
			if ( j < ANUMGEN-1 )
				printf ( ", " );
			else
				printf ( "%c\n",  ')' );
		} /* } */
	POP_STACK();
/*	for ( i = 0; i < ANUMGEN; i++ ) {
		for ( j = 0; j < ANUMGEN; j++ )
			printf ( "%1d", rho[i][j] );
		printf ( "\n" );
	}
	printf ( "\n" );
	use_temporary_stack(); */
}

static int check_iso ( int s, int dim )
{
	int ret = FALSE;
	register int i;
	int ysave, xsave;
	VEC a_save;
	
	PUSH_STACK();
	for ( i = 0; i < dim; i++ )
		copy_vector ( sgrho[s+i]+s, matrix[(long)i], dim );

	ysave = y_dim;
	xsave = x_dim;
	y_dim = x_dim = dim;
	a_save = absolut;
	absolut = CALLOCATE ( y_dim );
	use_static_matrix();
	if ( GAUSS_ELIMINATE() == dim )
		ret = TRUE;
	y_dim = ysave;
	x_dim = xsave;
	absolut = a_save;
	POP_STACK();
	return ( ret );
}

static int l_modlist = 0;
static VEC *modlist;

int isinlist ( VEC mod, int s )
{
	int i;
	
	for ( i = 0; i < l_modlist; i++ ) {
		if ( !memcmp ( modlist[i], mod, s ) )
			return ( TRUE );
	}
	return ( FALSE );
}

void app_list ( VEC ih, int s, int section )
{
	int i, l;
	VEC *cm;
	
	cm = conj_list ( sgrho, section, &l );
	for ( i = 0; i < l; i++ ) {
		modlist[l_modlist] = cm[i];
		SUBB_VECTOR ( ih, modlist[l_modlist++], s);
	}
	
}

void lift_rho ( int curr_sec )
{
	int i;
	VEC *h1;
	VEC ih;
	VEC ind_vec;
	char *h1_mod;
	char *ih_save;
	int h1_dim;
	int d, s, x;
	char val;
	char *old_top;
	int sprime, oprime;
	VEC *smodlist;
	int n;
	int sl_modlist;
	
	section = curr_sec;
	if ( section == ELAB_LENGTH + 1 ) {
		handle_ag_aut();
		return;

	}

	s = ELAB_SERIES[section].i_start;
	
	if ( section > 1 ) {
		for ( i = ANUMGEN; i--; )
			zero_vector ( sgrho[i]+s, ANUMGEN-s );
	}
	
	old_top = GET_TOP();
	
	d = ELAB_SERIES[section].i_dim;
	
	oprime = prime;
	h1_dim = ag_setup_section ( section, &h1, &ih );
	sprime = prime;
	
	if ( h1_dim != -1 ) {
		x = d * ANUMGEN;
		ih_save = ALLOCATE ( x );
		copy_vector ( ih, ih_save, x );
		
		ind_vec = CALLOCATE ( h1_dim );

/*		if ( curr_sec == 1 )
			ind_vec[h1_dim-1] = 1;  */

		h1_mod = ALLOCATE ( x );

		for ( i = ANUMGEN; i--; )
			copy_vector ( ih_save+i*d, sgrho[i]+s, d  );
				
		n = 1;
		for ( i = 0; i < h1_dim; i++ )
			n *= prime;
		l_modlist = 0;
		modlist = ARRAY ( n, VEC );
		
		do {
			sl_modlist = l_modlist;
			smodlist = modlist;
			zero_vector ( h1_mod, x );
			for ( i = h1_dim; i--; ) {
				if ( ( val = ind_vec[i] ) != 0 ) {
					ADD_MULT ( val, h1[i], h1_mod, x );
				}
			}
			if ( !isinlist ( h1_mod, d*(s+d) ) ) {
			for ( i = ANUMGEN; i--; ) {
				copy_vector ( ih_save+i*d, sgrho[i]+s, d  );
				ADD_VECTOR ( h1_mod+i*d, sgrho[i]+s, d );
			}
			/* check if sgrho is an epimorphism, this is only
			   neccessary if the prime changes */
			if ( check_iso ( s, d ) )
				lift_rho ( curr_sec+1 );
			swap_arith ( sprime );
			l_modlist = sl_modlist;
			modlist = smodlist;
			app_list ( ih_save, d*(s+d), curr_sec );
			}
		} while ( inc_count ( ind_vec, h1_dim ) );
	}

	SET_TOP ( old_top );
}

void ag_word_write ( PCELEM elem )
/* print monom of standard basis as word 
   (including '*' signs)                 */
{
	register int i;
	int isfirst = TRUE;
	FILE *out_hdl = stdout;
	
	if ( iszero ( elem, ANUMGEN ) )
		fprintf ( out_hdl, "1" );
	else {
		for ( i = 0; i < ANUMGEN; i++ ) {
			if ( elem[i] != 0 ) {
				if ( isfirst )
					isfirst = FALSE;
				else
					fprintf ( out_hdl, "*" );
				fprintf ( out_hdl, "%s", A_GEN[i] );
				if ( elem[i] > 1 ) 
					fprintf ( out_hdl, "^%1d", elem[i] );
			}
		}
	}
}

static PCELEM *wmat = NULL;
static int yc, bs, es;
static int *lindex;

void ag_col_eliminate ( int row, int col )
{
	register int i;
	register char v;
	PCELEM h1, h2;
	
	for ( i = 0; i < yc; i++ ) {
		if ( i != row ) {
			if ( (v = wmat[i][col]) != 0 ) {
				PUSH_STACK();
				h1 = ag_invers ( wmat[row] );
				h1 = ag_expo ( h1, v );
				h2 = agcollect ( wmat[i], h1 );
				copy_vector ( h2, wmat[i], bperelem );
				POP_STACK();
			}
		}
	}
}

int ag_eliminate ( int rank  )
{
	int ix, iy;
	PCELEM h;
	char value = '\0';

	swap_arith ( POWERS[bs] );
	for ( iy = 0; iy < yc; iy++ ) {
		if ( !iszero ( wmat[iy], bs ) || iszero ( wmat[iy]+bs, es-bs+1 ) )
			continue;
		rank++;
		for ( ix = bs; ix <= es; ix++ )
			if ( (value=wmat[iy][ix]) != 0 )
				break;
		lindex[ix] = iy;
		value = fp_inv ( value );
		PUSH_STACK();
		h = ag_expo ( wmat[iy], value );
		copy_vector ( h, wmat[iy], bperelem );
		POP_STACK();
		ag_col_eliminate ( iy, ix );
	}
	return ( rank );
}	

int ag_gauss ( PCELEM *words, int nw  )
{
	int y;
	int i, j, s, rank, srank, cnr;
	int n_nontriv_rels = 0;
	int done;
	VEC rels;
		
	PUSH_STACK();
	
	/* rels indicates nontrivial relations */
	rels = CALLOCATE ( ANUMGEN + (((ANUMGEN-1)*ANUMGEN)>>1) );
	for ( i = 0; i < ANUMGEN; i++ )
		if ( aggroup->p_len[i] > 0 ) {
			rels[i] = 1;
			n_nontriv_rels++;
		}
			
	for ( i = 0; i < ((ANUMGEN*(ANUMGEN-1))>>1); i++ )
		if ( aggroup->c_len[i] > 0 ) {
			rels[ANUMGEN+i] = 1;
			n_nontriv_rels++;
		}
		
	y = nw + n_nontriv_rels;
	
	wmat = ARRAY ( y, PCELEM );
	for ( i = 0; i < nw; i++ ) {
		wmat[i] = AIDENTITY;
		copy_vector ( words[i], wmat[i], bperelem );
	}
	lindex = ALLOCATE ( bperelem * sizeof ( int )  );
	for ( i = 0; i < bperelem; i++ ) lindex[i] = -1;
	
	yc = nw;
	rank = 0;
	for ( s = 1; s <= aggroup->elab_length; s++ ) {
		es = ELAB_SERIES[s].i_end;
		bs = ELAB_SERIES[s].i_start;
		
		srank = rank;
		rank = ag_eliminate ( srank );
			
		do {
			done = TRUE;
				
			/* add right sides of non trivial relations */
			/* powers */
			for ( i = bs; i <= es; i++ ) {
				if ( rels[i] == 1 ) {
					if ( (lindex[i] >= 0) ) {
						wmat[yc++] = ag_expo ( wmat[lindex[i]], POWERS[i] );
						rels[i] = 0;
					}
					else 
						done = FALSE;
				}
			}
			
			/* commutators */
			for ( i = bs; i <= es; i++ ) {
				for ( j = 0; j < i; j++ ) {
					cnr = CN( i, j );
					if ( rels[ANUMGEN+cnr] == 1 ) {
						if ( (lindex[i] >= 0) && (lindex[j] >= 0) ) {
							wmat[yc++] = ag_comm ( wmat[lindex[i]], wmat[lindex[j]] );
							rels[ANUMGEN+cnr] = 0;
						}
						else 
							done = FALSE;
					}
				}
			}
			
			rank = ag_eliminate ( srank );
		
		} while ( !done );
		
		if ( rank < es+1 ) {
			POP_STACK();
			return ( FALSE );
		}
	}
	POP_STACK();
	return ( TRUE );
}

void show_ag_homs (void)
{
	int i, j;
	VEC sr;
	DYNLIST p;

	p = list_auts.first;
	for ( i = 0; i < aut_num; i++ ) {
		sr = p->value.gv;
		printf ( "%4d : (", i ); 
		for ( j = 0; j < ANUMGEN; j++ ) {
			ag_word_write ( sr+j*ANUMGEN );
			if ( j < ANUMGEN-1 )
				printf ( ", " );
			else
				printf ( "%c\n",  ')' );
		}
		p = p->next;
	}
}

void sg_automorphisms ( AGGRPDESC *ag_group )
{
	int i, nmin;
	int sc, j;
	VEC c2_vector;
	AGGRPDESC *old_ag_group;
	GRPDSC *old_fp_group;
	PCGRPDESC *gg;
	HOM *pgroup_auts;
	int auts;
	
	old_ag_group = set_ag_group ( ag_group );
	old_fp_group = h_desc;

	ag_centre ( ag_group );
	set_h_group (  ag_conv_rel ( ag_group ) );

	numrel = ANUMGEN + ( (ANUMGEN * (ANUMGEN -1)) >> 1 );
	
	aut_num = 0;
	list_auts.first = list_auts.last = NULL;

	swap_arith ( POWERS[0] );
	nmin = ELAB_SERIES[1].i_dim;
	dim = nmin;
	dquad = nmin * nmin;
/*	init_gl ( nmin ); */
	
	c2_vector = CALLOCATE ( dquad );
	c2_vector[dquad-1] = 1;
	
	gg = ag_max_p_quotient ( ag_group );
	gg->defs = FALSE;
	pgroup_auts = automorphisms ( gg, 0 );
	pgroup_auts = generate_automorphism_group ( pgroup_auts, TRUE );
	auts = pgroup_auts->aut_gens_dim[1];

	sgrho = ARRAY ( ANUMGEN, PCELEM );
	
	for ( i = 0; i < ANUMGEN; i++ ) {
		sgrho[i] = AIDENTITY;
		sgrho[i][i] = 1;
	}

	bperelem = aggroup->num_gen;
	sc = gg->exp_p_class + 1;
	swap_arith ( POWERS[ELAB_SERIES[sc].i_start] );
	for ( i = 0; i < auts; i++ ) {
		for ( j = 0; j < gg->num_gen; j++ ) {
			copy_vector ( pgroup_auts->aut_gens[1][i]+j*gg->num_gen, sgrho[j], gg->num_gen );
			zero_vector ( sgrho[j]+gg->num_gen, ANUMGEN - gg->num_gen );
		}
		lift_rho ( sc );
		swap_arith ( POWERS[ELAB_SERIES[sc].i_start] );
	}


/*	do {
		for ( i = 0; i < nmin; i++ ) {
			copy_vector ( c2_vector+i*nmin, rho[i], nmin );
			zero_vector ( rho[i]+nmin, ANUMGEN - nmin );
		}
		
		if ( check_iso ( 0, dim ) ) {
			for ( i = nmin; i < ANUMGEN; i++ )
				zero_vector ( rho[i], ANUMGEN );
			
			lift_rho ( 2 );
			swap_arith ( POWERS[0] );
		}
	} while ( inc_count ( c2_vector, dquad ) ); */

	
	printf ( "number of homomorphisms: %ld\n", aut_num );

/*	show_ag_homs(); */
	
	set_ag_group ( old_ag_group );
	set_h_group ( old_fp_group );
}


/* end of module h1 matrix */
