/********************************************************************/
/*                                                                  */
/*  Module        : Obstruction                                     */
/*                                                                  */
/*  Description :                                                   */
/*     This module is used to compute the matrices describing the g */
/*     - operation on 1+I^n/1+I^2n.                                 */
/*                                                                  */
/********************************************************************/

/* 	$Id: aobstruc.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: aobstruc.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/07/17 15:21:50  pluto
 * 	Switched to dynamic version of 'az1_mat'.
 *
 * 	Revision 3.0  1995/06/23 16:52:29  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	New function 'at1_mat_new' replacing 'az1_mat'.
 *
 * Revision 1.2  1995/01/05  17:18:43  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: aobstruc.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include	"pc.h"
#include	"hgroup.h"
#include	"grpring.h"
#include	"storage.h"
#include	"solve.h"

typedef struct {
	PCELEM rho;
	VEC *x_mat;
} atilde_expr;

typedef atilde_expr *ATEP;

#define ANEW_TE(t)	{t = ALLOCATE ( sizeof ( atilde_expr ) );\
				t->rho = CALLOCATE ( bperelem );\
				t->x_mat = ALLOCATE ( NUMGEN * sizeof ( VEC ) );\
				for ( i = 0; i < NUMGEN; i++ )\
					t->x_mat[i] = CALLOCATE ( dquad );}
				
#define ACOPY_TE(t1, t2)	{copy_vector ( t1->rho, t2->rho, bperelem );\
					for ( i = 0; i < NUMGEN; i++ )\
						copy_vector ( t1->x_mat[i],t2->x_mat[i], dquad );}

#define ASUB_TE(t1, t2)	{SUBA_VECTOR ( t1->rho, t2->rho, bperelem );\
					for ( i = 0; i < NUMGEN; i++ )\
						SUBA_VECTOR ( t1->x_mat[i], t2->x_mat[i], dquad );}


VEC Idmat 			_(( void ));
PCELEM g_comm 			_(( PCELEM el, PCELEM er ));
int max_elab_section 	_(( int start ));
int get_section 		_(( int ind ));
int set_group_quotient          _(( int class ));
void set_number_of_relations    _(( int class ));

extern PCGRPDESC *group_desc;
extern GRPDSC *h_desc;
extern int start, bperelem;
extern int dim, dquad;
int adim, adquad;
extern PCELEM *rho;

PCELEM aideal;

VEC *opmatrix;			 	/* operation of base element
						   Gi on I^n/I^m piece */

void acalc_matrix ( PCELEM rho, VEC mat )
/* compute one l_matrix/ */
/* r_matrix pair		 */
{
	register int j;
	register int off2;
	char *old_top;
	PCELEM res;
	
	old_top = GET_TOP();
	for ( j = bperelem; j-- > start; ) {
		off2 = j - start;
		zero_vector ( aideal, bperelem );
		aideal[j] = 1;
		res = monom_mul ( g_invers ( rho ), aideal );
		res = monom_mul ( res, rho );
		copy_vector ( res+start, mat+off2*dim, dim );
	}
	SET_TOP(old_top);
}

void aget_op_mats ( int start )
/* get all l_matrix/     */
/* r_matrix pairs		*/
{
	PCELEM rho;
	register int i;
	char *old_top;
	
	old_top = GET_TOP();
	rho = ALLOCATE ( bperelem );
	aideal = ALLOCATE ( bperelem );
	for ( i = start; i--; ) {
		zero_vector ( rho, bperelem );
		rho[i] = 1;
		acalc_matrix ( rho, opmatrix[i] );
	}
	SET_TOP ( old_top );
}

void aget_rho_mat ( PCELEM rho, VEC *r_mat )
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
			zw = matrix_exp ( opmatrix[j], val );
			res = MATRIX_MUL ( zw, res );
		}
	}
	copy_vector ( res, *r_mat, dquad );
	POP_STACK();
}


ATEP ainvers_te ( ATEP t )
{
	int i;
	ATEP inv;
	PCELEM i_rho;
	VEC zw, l_rho_mat;
	
	ANEW_TE ( inv );
	PUSH_STACK();
	i_rho = g_invers ( t->rho );
	aget_rho_mat ( i_rho, &l_rho_mat );
	copy_vector ( i_rho, inv->rho, bperelem );
	for ( i = 0; i < NUMGEN; i++ ) {
		zw = MATRIX_MUL ( t->x_mat[i], l_rho_mat  );
		SMUL_VECTOR ( GPRIME-1, zw, dquad );
		copy_vector ( zw, inv->x_mat[i], dquad );
	}
	POP_STACK();
	return ( inv );
}
				
ATEP amul_te ( ATEP t1, ATEP t2 )
{
	int i;
	ATEP res;
	VEC zw;
	VEC r_rho_mat;
	
	ANEW_TE ( res );
	PUSH_STACK();
	copy_vector ( monom_mul ( t1->rho, t2->rho ), res->rho, bperelem );
	aget_rho_mat ( t2->rho, &r_rho_mat );
	for ( i = 0; i < NUMGEN; i++ ) {
		zw = MATRIX_MUL ( t1->x_mat[i], r_rho_mat );
		copy_vector ( t2->x_mat[i], res->x_mat[i], dquad );
		ADD_VECTOR ( zw, res->x_mat[i], dquad );
	}
	POP_STACK();
	return ( res );
}

ATEP acomm_te ( ATEP t1, ATEP t2 )
{
	int i;
	ATEP res;
	VEC zw;
	VEC l_rho_mat, r_rho_mat, m_rho_mat;
	PCELEM r, r1;
	
	ANEW_TE ( res );
	PUSH_STACK();
	r = g_comm ( t1->rho, t2->rho );
	r1 = monom_mul ( t1->rho, r );
	copy_vector ( r, res->rho, bperelem );
	aget_rho_mat ( r, &l_rho_mat );
	aget_rho_mat ( r1, &m_rho_mat );
	aget_rho_mat ( t2->rho, &r_rho_mat );
	for ( i = 0; i < NUMGEN; i++ ) {
		copy_vector ( t2->x_mat[i], res->x_mat[i], dquad );

		zw = MATRIX_MUL ( t1->x_mat[i], l_rho_mat );
		SMUL_VECTOR ( GPRIME-1, zw, dquad );
		ADD_VECTOR ( zw, res->x_mat[i], dquad );
		
		zw = MATRIX_MUL ( t2->x_mat[i], m_rho_mat );
		SMUL_VECTOR ( GPRIME-1, zw, dquad );
		ADD_VECTOR ( zw, res->x_mat[i], dquad );
		
		zw = MATRIX_MUL ( t1->x_mat[i], r_rho_mat );
		ADD_VECTOR ( zw, res->x_mat[i], dquad );
	}
	POP_STACK();
	return ( res );
}

ATEP aexp_te ( ATEP t, int pow )
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
		h = amul_te ( h, h );
		if ( pow & i )
			h = amul_te ( h, t );
	}
	ACOPY_TE ( h, res );
	POP_STACK();
	return ( res );

}

ATEP asetup_obs ( node p )
{
	register ATEP l, r;
	register ATEP obs;
	int i;
	
	ANEW_TE ( obs );
	PUSH_STACK();

	switch ( p->nodetype ) {
		case GGEN:
				copy_vector ( rho[p->value], obs->rho, bperelem );
				copy_vector ( Idmat(), obs->x_mat[p->value], dquad );
				break;
		case EQ  :
				if ( p->right != NULL ) {
					r = asetup_obs ( p->right );
					ACOPY_TE ( r, obs );
				}
				l = asetup_obs ( p->left );
				ASUB_TE ( l, obs );						
				break;
		case COMM:

/*				l = asetup_obs ( p->left );
				r = asetup_obs ( p->right );
				l1 = amul_te ( ainvers_te ( l ), ainvers_te ( r ) );
				l1 = amul_te ( l1,  amul_te ( l, r ) );
				ACOPY_TE ( l1, obs );
*/
				l = acomm_te ( asetup_obs ( p->left ), asetup_obs ( p->right ) );
				ACOPY_TE ( l, obs );
				break;
		case EXP :
				l = asetup_obs ( p->left );
				l = aexp_te ( l, (p->value > 0) ? p->value : -p->value );
				if ( p->value < 0 )
					l = ainvers_te ( l );
				ACOPY_TE ( l, obs );
				break;
		case MULT:
				l =  amul_te ( asetup_obs ( p->left ), asetup_obs ( p->right ) );
				ACOPY_TE ( l, obs );
				break;
		default:
				puts ( "Error in relation" );
	}
	POP_STACK();
	return ( obs );
}

void az1_mat_old ( int homogeneous )
/* setup system of linear equations */
{
	int i, j, k, l;
	int y_offset = adim * NUMREL;
	int x_offset;
	int sdim, sdquad;
	ATEP obs;
	
	/* save old values of dim and dquad */
	sdim = dim;
	sdquad = dquad;
	dim = adim;
	dquad = adquad;

	for ( i = NUMREL; i--;  ) {
		y_offset -= dim;
		PUSH_STACK();
		obs = asetup_obs ( RELATION[i] );
		if ( !homogeneous )
			copy_vector ( obs->rho+start, absolut+y_offset, dim );
		for ( j = 0; j < NUMGEN; j++ ) {
			x_offset = j * dim;
			for ( k = dim; k--; ) {
				for ( l = dim; l--; )
					matrix[(long)(y_offset+l)][(long)(x_offset+k)] =
						obs->x_mat[j][k*dim+l];
			}
		}
		POP_STACK();
	}

	if ( homogeneous )
		zero_vector ( absolut, dim*NUMREL );
/*	
	puts ( "absolut1" );
	for ( i = 0; i < dim*NUMREL; i++ )
	  printf ( "%1d", absolut[i] );
	printf ( "\n" ); 
*/

	SMUL_VECTOR ( GPRIME-1, absolut, dim * NUMREL );

/*	puts ( "matrix" );
	for ( i = 0; i < dim*NUMREL; i++ ) { 
	  for ( j = 0; j < dim*NUMGEN; j++ )
	    printf ( "%1d", matrix[i][j] );
	  printf ( "\n" );
	 }
	puts ( "absolut2" );
	for ( i = 0; i < dim*NUMREL; i++ )
	  printf ( "%1d", absolut[i] );
	printf ( "\n" );
*/	

	/* restore old values of dim and dquad */
	dim = sdim;
	dquad = sdquad;
}

void az1_mat ( int homogeneous, char **M, VEC abs, int dimension )
/* setup system of linear equations */
{
	int i, j, k, l;
	int y_offset = dimension * NUMREL;
	int x_offset;
	int sdim, sdquad;
	ATEP obs;
	
	/* save old values of dim and dquad */
	sdim = dim;
	sdquad = dquad;
	dim = dimension;
	dquad = adquad;

	for ( i = NUMREL; i--;  ) {
		y_offset -= dim;
		PUSH_STACK();
		obs = asetup_obs ( RELATION[i] );
		if ( !homogeneous )
			copy_vector ( obs->rho+start, abs+y_offset, dim );
		for ( j = 0; j < NUMGEN; j++ ) {
			x_offset = j * dim;
			for ( k = dim; k--; ) {
				for ( l = dim; l--; )
					M[y_offset+l][x_offset+k] =
						obs->x_mat[j][k*dim+l];
			}
		}
		POP_STACK();
	}

	if ( homogeneous )
		zero_vector ( abs, dim*NUMREL );
	SMUL_VECTOR ( GPRIME-1, abs, dim * NUMREL );

	/* restore old values of dim and dquad */
	dim = sdim;
	dquad = sdquad;
}

int setup_section ( int class, VEC **h )
/* compute largerst i with P_class/P_i elementary abelian and setup
   operating matrices for G/P_class operating on P_class/P_i.
   Setup and solve system of linear equations.
*/
{
	int i, j, k;
	int sdim, sdquad, old_class;
	int xs, ys, xd, yd;
	int d;
	int e_end, e_class;
	VEC *h1;
	
	
	start = group_desc->exp_p_lcs[class].i_start;
	e_end = max_elab_section ( start );
	e_class = get_section ( e_end );

	PUSH_STACK();
	
	/* save old values of dim and dquad */
	sdim = dim;
	sdquad = dquad;
	dim = adim = e_end - start + 1;
	dquad = adquad = adim * adim;
	d = group_desc->exp_p_lcs[class].i_dim;

	old_class = set_group_quotient ( e_class );
	set_number_of_relations ( e_class );

	/* compute operating matrices for identity */
	opmatrix = ARRAY ( start, VEC );
	for ( j = start; j--; ) {
		opmatrix[j] = ALLOCATE ( adquad );
	}

	aget_op_mats ( start );

/*	for ( j = 0; j < start; j++ ) {
		printf ( "\nmat. no, %d\n", j );
		show_mat ( opmatrix[j] );
	}
*/
	az1_mat_old ( FALSE );
	xd = NUMGEN * adim;
	yd = NUMREL * adim;
	solve_equations ( xd, yd );
	
	k = 0;
	for ( i = xd; i--; ) {
		if ( fsolution[i] ) {
			for ( j = 0; j < NUMGEN; j++ )	
				copy_vector ( fsolution[i]+j*adim, matrix[(long)k]+j*d, d );
			k++;
		}
	}
	POP_STACK();

	xs = x_dim;
	ys = y_dim;
	x_dim = xd = d * NUMGEN;
	y_dim = k;
	GAUSS_ELIMINATE();

	h1 = ARRAY ( k, VEC );
	j = 0;
	for ( i = 0; i < k; i++ ) {
		if ( !iszero ( matrix[(long)i], xd ) ) {
			h1[j] = ALLOCATE ( xd );
			copy_vector ( matrix[(long)i], h1[j++], xd );
		}
	}
			
	/* restore old values of dim and dquad */
	dim = sdim;
	dquad = sdquad;

	x_dim = xs;
	y_dim = ys;
	
	set_group_quotient ( old_class );
	set_number_of_relations ( old_class );
	
	*h = h1;
	return ( j );
}

int get_elab_sockle (void)
/* compute elementary abelian sockle of G, i.e least i with P_i */
{
	int generators, i, j, c;
	int elab;
	
	i = generators = group_desc->num_gen;
	elab = TRUE;
	do {
		i--;
		for ( j = i+1; j < generators; j++ ) {
			c = CN(j,i);
			if ( group_desc->c_list[c] != NULL ) {
				elab = FALSE;
				break;
			}
		}
		if ( group_desc->p_list[i] != NULL )
			elab = FALSE;
	} while ( elab );
	c = group_desc->exp_p_class;
	while ( group_desc->exp_p_lcs[c].i_start > i ) c--;
	return ( c+1 );
}
	
int setup_elab_sockle ( int class, VEC **h )
/* compute smallest i with P_i elementary abelian and setup
   operating matrices for G/P_i operating on P_class/P_i.
   Setup and solve system of linear equations.
*/
{
	int i, j, k;
	int sdim, sdquad, old_class;
	int xd, yd;
	VEC *h1;
	
	
	start = group_desc->exp_p_lcs[class].i_start;

	PUSH_STACK();
	
	/* save old values of dim and dquad */
	sdim = dim;
	sdquad = dquad;
	dim = adim = GNUMGEN - start;
	dquad = adquad = adim * adim;

	old_class = set_group_quotient ( EXP_P_CLASS );
	set_number_of_relations ( EXP_P_CLASS );

	/* compute operating matrices for identity */
	opmatrix = ARRAY ( start, VEC );
	for ( j = start; j--; ) {
		opmatrix[j] = ALLOCATE ( adquad );
	}

	aget_op_mats ( start );

	az1_mat_old ( FALSE );
	xd = NUMGEN * adim;
	yd = NUMREL * adim;
	k = xd - solve_equations ( xd, yd );
	
	h1 = ARRAY ( k, VEC );
	j = 0;
	for ( i = xd; i--;  ) {
		if ( fsolution[i] ) {
			h1[j] = ALLOCATE ( xd );
			copy_vector ( fsolution[i], h1[j++], xd );
		}
	}
			
	/* restore old values of dim and dquad */
	dim = sdim;
	dquad = sdquad;

	set_group_quotient ( old_class );
	set_number_of_relations ( old_class );
	
	*h = h1;
	return ( j );
}

int extract_section ( int class, int crit_class, VEC **h, VEC **ch, int h1d )
{
	int i, j, k, start, dd;
	int xd;
	int d;
	int ad, as, ae, delta;
	char val;
	VEC *cstabs, *newh, *nh;
	VEC modif2;
	VEC *h1 = *h;
	VEC *cuth;
	
	
	start = group_desc->exp_p_lcs[class].i_start;
	as = group_desc->exp_p_lcs[crit_class].i_start;
	delta = start - as;
	d = group_desc->exp_p_lcs[class].i_dim;
	ad = GNUMGEN - as;
	ae = ad * NUMGEN;

	newh = ARRAY ( h1d, VEC );
	cuth = ARRAY ( h1d, VEC );
	for ( i = 0; i < h1d; i++ ) {
		newh[i] = CALLOCATE ( ae );
		cuth[i] = CALLOCATE ( d * NUMGEN );
	}

	PUSH_STACK();
	
	for ( i = 0; i < h1d; i++ )
		for ( j = 0; j < NUMGEN; j++ )
			for ( k = 0; k < delta; k++ )
				matrix[(long)(j*delta+k)][(long)i] = h1[i][j*ad+k];
	
	zero_vector ( absolut, delta * NUMGEN );
	
	dd = h1d - solve_equations ( h1d, delta * NUMGEN );
	
	cstabs = ARRAY ( dd, VEC );
	j = 0;
	for ( i = h1d; i--; )
		if ( fsolution[i] )
			cstabs[j++] = fsolution[i];
	
	nh = ARRAY ( dd, VEC );
	xd = d * NUMGEN;
	k = 0;
	modif2 = ALLOCATE ( xd );

	for ( ;dd--; ) {

		nh[k] = CALLOCATE ( ae );
		
		zero_vector ( modif2, xd );
		for ( i = h1d; i--; ) {
			if ( ( val = cstabs[dd][i] ) != 0 ) {
				ADD_MULT ( val, h1[i], nh[k], ae );
				for ( j = 0; j < NUMGEN; j++ )
					ADD_MULT ( val, h1[i]+j*ad+delta, modif2+j*d, d );
			}
		}
		
		copy_vector ( modif2, matrix[(long)k], xd );
		k++;
	}
	
	gauss_p_eliminate ( xd, k );
	
	dd = 0;
	for ( i = 0; i < k; i++ ) {
		if ( !iszero ( matrix[(long)i], xd ) ) {
			for ( j = k; j--; ) {
				if ( ( val = matrix[(long)i][(long)(xd+j)] ) != 0 )
					ADD_MULT ( val, nh[j], newh[dd], ae );
			}
			for ( j = NUMGEN; j--; )
				copy_vector ( newh[dd]+j*ad+delta, cuth[dd]+j*d, d );
			dd++;
		}
	}
	
	POP_STACK();
	
	*h = newh;
	*ch = cuth;
	return ( dd );
}

/* end of module h1 matrix */
