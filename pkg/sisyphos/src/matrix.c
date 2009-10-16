/********************************************************************/
/*                                                                  */
/*  Module		: Matrix calculus                               */
/*                                                                  */
/*  Description :                                                   */
/*	 Module for matrix multiplication and matrix exponentiation.   */
/*                                                                  */
/********************************************************************/

/* 	$Id: matrix.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: matrix.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 10:00:50  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	New function 'matrix_inv'.
 *
 * Revision 1.2  1995/01/05  17:02:32  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: matrix.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include "storage.h"
#include "solve.h"

extern int dim, dquad;

VEC matrix2_mul (VEC mat1, VEC mat2)
{
	register int i, j, d, dq;
	register VEC p, q, r;
	VEC p_mat;
	
	j = d = dim;
	dq = dquad;
	p_mat = CALLOCATE ( dq );
	p = mat1 + dq;
	r = p_mat + dq;
	while ( j-- ) {
		p -= d;
		r -= d;
		q = mat2 + dq;
		i = d;
		while ( i-- ) {
			q -= d;
			if ( *(p+i) )
				add2_vector ( q, r, d );
		}
	}
	return ( p_mat );
}
 
VEC matrixp_mul (VEC mat1, VEC mat2)
{
	register int i, j, d, dq;
	register VEC p, q, r;
	register char val;
	VEC p_mat;
	
	j = d = dim;
	dq = dquad;
	p_mat = CALLOCATE ( dq );
	PUSH_STACK();
	p = mat1 + dq;
	r = p_mat + dq;
	while ( j-- ) {
		p -= d;
		r -= d;
		q = mat2 + dq;
		i = d;
		while ( i-- ) {
			q -= d;
			if ( ( val = *(p+i) ) != 0 )
				ADD_MULT ( val, q, r, d );
		}
	}
	POP_STACK();
	return ( p_mat );
}
 
VEC matrix_exp (VEC mat, int power)
{
	register int i = 128;
	VEC v_save, result;
	
	v_save = ALLOCATE ( dquad );
	PUSH_STACK();
	result = mat;
	while ( !(power & i ) ) i >>= 1;
	while ( (i >>= 1) != 0 ) {
		result = MATRIX_MUL ( result, result );
		if ( power & i )
			result = MATRIX_MUL ( result, mat );
	}
	copy_vector ( result, v_save, dquad );
	POP_STACK();
	return ( v_save );
}

VEC matrix_inv ( VEC mat )
{
	int i, j;
	VEC imat;
	
	imat = ALLOCATE ( dquad );
	for ( i = 0; i < dim; i++ ) {
		copy_vector ( mat+i*dim, matrix[i], dim );
	}
	gauss_p_eliminate ( dim, dim );
	for ( i = 0; i < dim; i++ )
		for ( j = 0; j < dim; j++ )
			if ( matrix[i][j] != 0 ) {
				copy_vector ( matrix[i]+dim, imat+j*dim, dim );
				break;
			}
	return ( imat );
}

void show_mat (VEC mat)
{
	register int i, j;
	for ( i = 0; i < dim; i++ ) {
		for ( j = 0; j < dim; j++ )
			printf ( "%1d", mat[i*dim+j] );
		printf ( "\n" );
	}
}

/* end of module matrix calculus */
