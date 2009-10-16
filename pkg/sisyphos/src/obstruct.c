/********************************************************************/
/*                                                                  */
/*  Module        : Obstruction                                     */
/*                                                                  */
/*  Description :                                                   */
/*     This module is used to compute the matrices describing the g */
/*     - operation on 1+I^n/1+I^2n.                                 */
/*                                                                  */
/********************************************************************/

/* 	$Id: obstruct.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: obstruct.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:04:10  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: obstruct.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include	"pc.h"
#include	"hgroup.h"
#include	"grpring.h"
#include	"storage.h"
#include "solve.h"

VEC gr_invers 				_(( VEC elem, int mod_id ));

static VEC *rho;

typedef struct {
	VEC rho;
	VEC *x_mat;
} tilde_expr;

typedef tilde_expr *TEP;

#define IDMAT		l_matrix[0]

#define NEW_TE(t)	{t = ALLOCATE ( sizeof ( tilde_expr ) );\
				t->rho = CALLOCATE ( fend );\
				t->x_mat = ALLOCATE ( NUMGEN * sizeof ( VEC ) );\
				for ( i = 0; i < NUMGEN; i++ )\
					t->x_mat[i] = CALLOCATE ( dquad );}
				
#define COPY_TE(t1, t2)	{copy_vector ( t1->rho, t2->rho, fend );\
					for ( i = 0; i < NUMGEN; i++ )\
						copy_vector ( t1->x_mat[i],t2->x_mat[i], dquad );}

#define SUB_TE(t1, t2)	{SUBA_VECTOR ( t1->rho, t2->rho, fend );\
					for ( i = 0; i < NUMGEN; i++ )\
						SUBA_VECTOR ( t1->x_mat[i], t2->x_mat[i], dquad );}

extern PCGRPDESC *group_desc;
extern GRPDSC *h_desc;
extern int start, fend, cut;
extern int dim, dquad, rho_dim;

extern VEC svec;

VEC ideal;

VEC *l_matrix, *r_matrix; 	/* operation of base element
						   Gi on I^n/I^m piece */

void calc_matrix ( VEC rho, VEC l_mat, VEC r_mat )
/* compute one l_matrix/ */
/* r_matrix pair		 */
{
	register int j, k;
	register int off1, off2;
	char *old_top;
	VEC res_l, res_r;
	
	old_top = GET_TOP();
	for ( j = fend; j-- > start; ) {
		off2 = j - start;
		zero_vector ( ideal, fend );
		ideal[j] = 1;
		res_l = GROUP_MUL ( rho, ideal, cut );
		res_r = GROUP_MUL ( ideal, rho, cut );
		off1 = dquad;
		for ( k = dim; k--; ) {
			off1 -= dim;
			l_mat[off1+off2] = res_l[k+start];
			r_mat[off1+off2] = res_r[k+start];
		}
	}
	SET_TOP(old_top);
}

void get_op_mats (void)
/* get all l_matrix/     */
/* r_matrix pairs		*/
{
	VEC rho;
	register int i;
	char *old_top;
	
	old_top = GET_TOP();
	rho = ALLOCATE ( fend );
	ideal = ALLOCATE ( fend );
	for ( i = rho_dim; i--; ) {
		zero_vector ( rho, fend );
		rho[i] = 1;
		calc_matrix ( rho, l_matrix[i], r_matrix[i] );
	}
	SET_TOP ( old_top );
}

void get_rho_mat ( VEC rho, VEC *r_mat, int left )
/* get matrix representing operation of rho on I^n/I^m */
/* from the left/right side (left = TRUE/FALSE)        */
{
	int j;
	register char val;
		
	*r_mat = CALLOCATE ( dquad );		
	for ( j = rho_dim; j--; ) {
		if ( ( val = rho[j] ) != 0 )
			if ( left )
				ADD_MULT ( val, l_matrix[j], *r_mat, dquad );
			else
				ADD_MULT ( val, r_matrix[j], *r_mat, dquad );
	}
}


TEP invers_te ( TEP t )
{
	int i;
	TEP inv;
	VEC i_rho, zw1, zw2;
	VEC l_rho_mat, r_rho_mat;
	
	NEW_TE ( inv );
	PUSH_STACK();
	i_rho = gr_invers ( t->rho, cut );
	get_rho_mat ( i_rho, &l_rho_mat, TRUE );
	get_rho_mat ( i_rho, &r_rho_mat, FALSE );
	copy_vector ( i_rho, inv->rho, fend );
	for ( i = 0; i < NUMGEN; i++ ) {
		zw1 = MATRIX_MUL ( l_rho_mat, t->x_mat[i] );
		zw2 = MATRIX_MUL ( r_rho_mat, zw1 );
		SMUL_VECTOR ( GPRIME-1, zw2, dquad );
		copy_vector ( zw2, inv->x_mat[i], dquad );
	}
	POP_STACK();
	return ( inv );
}
				
TEP mul_te ( TEP t1, TEP t2 )
{
	int i;
	TEP res;
	VEC zw1, zw2;
	VEC l_rho_mat, r_rho_mat;
	
	NEW_TE ( res );
	PUSH_STACK();
	copy_vector ( GROUP_MUL ( t1->rho, t2->rho, cut ), res->rho, fend );
	get_rho_mat ( t1->rho, &l_rho_mat, TRUE );
	get_rho_mat ( t2->rho, &r_rho_mat, FALSE );
	for ( i = 0; i < NUMGEN; i++ ) {
		zw1 = MATRIX_MUL ( l_rho_mat, t2->x_mat[i] );
		zw2 = MATRIX_MUL ( r_rho_mat, t1->x_mat[i] );
		ADD_VECTOR ( zw2, zw1, dquad );
		copy_vector ( zw1, res->x_mat[i], dquad );
	}
	POP_STACK();
	return ( res );
}

TEP exp_te ( TEP t, int pow )
{
	register int i;
	TEP res;
	TEP h;
	
	NEW_TE ( res );
	PUSH_STACK();
	h = res;
	COPY_TE ( t, h );
	i = 4096;
	while ( !(pow & i ) ) i >>= 1;
	while ( (i >>= 1) != 0 ) {
		h = mul_te ( h, h );
		if ( pow & i )
			h = mul_te ( h, t );
	}
	COPY_TE ( h, res );
	POP_STACK();
	return ( res );

}

TEP setup_obs ( node p )
{
	register TEP l1, l, r;
	register TEP obs;
	int i;
	
	NEW_TE ( obs );
	PUSH_STACK();

	switch ( p->nodetype ) {
		case GGEN:
				copy_vector ( rho[p->value], obs->rho, fend );
				copy_vector ( IDMAT, obs->x_mat[p->value], dquad );
				break;
		case EQ  :
				if ( p->right != NULL ) {
					r = setup_obs ( p->right );
					COPY_TE ( r, obs );
				}
				l = setup_obs ( p->left );
				SUB_TE ( l, obs );						
				break;
		case COMM:
				l = setup_obs ( p->left );
				r = setup_obs ( p->right );
				l1 = mul_te ( invers_te ( l ), invers_te ( r ) );
				l1 = mul_te ( l1, mul_te ( l, r ) );
				COPY_TE ( l1, obs );
				break;
		case EXP :
				l = setup_obs ( p->left );
				l = exp_te ( l, (p->value > 0) ? p->value : -p->value );
				if ( p->value < 0 )
					l = invers_te ( l );
				COPY_TE ( l, obs );
				break;
		case MULT:
				l =  mul_te ( setup_obs ( p->left ), setup_obs ( p->right ) );
				COPY_TE ( l, obs );
				break;
		default:
				puts ( "(setup_obs) Error in relation" );
	}
	POP_STACK();
	return ( obs );
}

VEC obstruct ( node p, VEC rho[] )
{
	register VEC l1, l, r;
	register VEC obs;
	
	obs = CALLOCATE ( fend );
	PUSH_STACK();

	switch ( p->nodetype ) {
		case GGEN:
				copy_vector ( rho[p->value], obs, fend );
				break;
		case EQ  :
				if ( p->right != NULL ) {
					copy_vector ( obstruct ( p->right, rho ), obs, fend );
				}
				SUBB_VECTOR ( obstruct ( p->left, rho ), obs, fend );
				break;
		case COMM:
				l = obstruct ( p->left, rho );
				r = obstruct ( p->right, rho );
				l1 = GROUP_MUL ( gr_invers ( l, cut ), gr_invers ( r, cut ), cut );
				l1 = GROUP_MUL ( l1, GROUP_MUL ( l, r, cut ), cut );
				copy_vector ( l1, obs, fend );
				break;
		case EXP :
				l = obstruct ( p->left, rho );
				l = GROUP_EXP ( l, (p->value > 0) ? p->value : -p->value, cut );
				if ( p->value < 0 )
					l = gr_invers ( l, cut );
				copy_vector ( l, obs, fend );
				break;
		case MULT:
				l =  GROUP_MUL ( obstruct ( p->left, rho ), obstruct ( p->right, rho ), cut );
				copy_vector ( l, obs, fend );
				break;
		default:
				puts ( "(obstruct) Error in relation" );
	}
	POP_STACK();
	return ( obs );
}

void z1_mat ( VEC args[], char **M, VEC Abs )
{
	int i, j, k;
	int jdim;
	int y_offset = dim * NUMREL;
	int x_offset;
	TEP obs;
	
	rho = args;
	for ( i = NUMREL; i--;  ) {
		y_offset -= dim;
		PUSH_STACK();
		obs = setup_obs ( RELATION[i] );
		copy_vector ( obs->rho+start, Abs+y_offset, dim );
		for ( j = 0; j < NUMGEN; j++ ) {
			x_offset = j * dim;
			jdim = dquad;
			for ( k = dim; k--; ) {
				jdim -= dim;
				copy_vector ( obs->x_mat[j]+jdim, M[(long)(y_offset+k)]
					+(long)x_offset, dim );
			}
		}
		POP_STACK();
	}
	SMUL_VECTOR ( GPRIME-1, Abs, dim * NUMREL );
}

/* end of module h1 matrix */
