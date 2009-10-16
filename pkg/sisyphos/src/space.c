/********************************************************************/
/*                                                                  */
/*  Module        : Vector space                                    */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies the routines to handle vector spaces                */
/*                                                                  */
/********************************************************************/

/* 	$Id: space.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: space.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 1.4  1995/07/28 14:49:38  pluto
 * 	Added new function 'span_space'.
 *
 * 	Revision 1.3  1995/02/27 13:48:28  pluto
 * 	Added "use_static_matrix" to direct call of GAUSS_ELIMINATE.
 *
 * Revision 1.2  1995/01/05  17:15:36  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: space.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include "grpring.h"
#include	"pc.h"
#include <ctype.h>
#include	"storage.h"
#include	"solve.h"

extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern FILE *proto;

void show_space (SPACE *v_space)
{
	VEC base = v_space->basis;
	int dim = v_space->dimension;
	int offset = v_space->total_dim;
	int cut = 0;
	
	printf ( "dimension of total space : %d\n", offset );
	printf ( "dimension of this  space : %d\n", dim );
	printf ( "Basis flag               : %d\n", v_space->b_flag );
	printf ( "\nBasis:\n\n" );
	if ( v_space->b_flag == UPPER )
		cut = get_I_power ( offset );
	for ( ;dim--; ) {
		switch ( v_space->b_flag ) {
			case LOWER:
				cgroup_write ( base );
				break;
			case UPPER:
				n_group_write ( base, cut );
				break; 
			default:
				write_vector ( base, offset );
		}
		base += offset;
	}
}

SPACE *meet_space (SPACE *v1, SPACE *v2)
{
	register int i, j;
	register int v1_d = v1->dimension;
	register int v2_d = v2->dimension;
	char *old_top;
	register char val;
	long mem_offset;
	VEC help;
	SPACE *v_meet = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	VEC p;
	VEC b;
	
	y_dim = v1->total_dim;
	x_dim = v1_d + v2_d;
	old_top = GET_TOP();
	if ( v2_d < v1_d )
		p = ALLOCATE ( (long)v2_d * y_dim );
	else
		p = ALLOCATE ( (long)v1_d * y_dim );
	absolut = CALLOCATE ( y_dim );
	inhom = ALLOCATE ( x_dim );
	help = ALLOCATE ( y_dim );
	v_meet->total_dim = y_dim;
	v_meet->b_flag = v1->b_flag;
	v_meet->basis = p;
	
	b = v1->basis;
	for ( i = 0; i < v1_d; i++ ) {
		j = y_dim;
		for ( ;j--; )
			matrix[(long)j][(long)i] = *(b+j);
		b += y_dim;
	}
	b = v2->basis;
	for ( i = v1_d; i < x_dim; i++ ) {
		j = y_dim;
		for ( ;j--; )
			matrix[(long)j][(long)i] = *(b+j);
		b += y_dim;
	}
	i = v_meet->dimension = x_dim - solve_equations ( x_dim, y_dim );
	mem_offset = i * y_dim;
	mem_offset = ALIGN4 ( mem_offset );
	SET_TOP ( old_top + mem_offset );
	for ( j = 0; j < x_dim; j++ ) {
		if ( fsolution[j] ) {
			zero_vector ( help, y_dim );
			for ( i = 0; i < v1_d; i++ ) {
				if ( (val = fsolution[j][i]) != 0 ) 
					ADD_MULT ( val, v1->basis+i*y_dim, help, y_dim );
			}
			copy_vector ( help, p, y_dim );
			p += y_dim;
		}
	}
	return ( v_meet );
}

SPACE *join_space (SPACE *v1, SPACE *v2)
{
	register int i, j;
	register int v1_d = v1->dimension;
	register int v2_d = v2->dimension;
	char *old_top;
	long mem_offset;
	SPACE *v_join = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	VEC p;
	VEC b;
	
	y_dim = v1_d + v2_d;
	x_dim = v1->total_dim;
	old_top = GET_TOP();
	p = ALLOCATE ( (long)y_dim * x_dim );

	absolut = CALLOCATE ( y_dim );
	v_join->total_dim = x_dim;
	v_join->b_flag = v1->b_flag;
	v_join->basis = p;
	
	b = v1->basis;
	for ( i = 0; i < v1_d; i++ ) {
		copy_vector ( b, matrix[(long)i], x_dim );
		b += x_dim;
	}
	b = v2->basis;
	for ( i = v1_d; i < y_dim; i++ ) {
		copy_vector ( b, matrix[(long)i], x_dim );
		b += x_dim;
	}

	use_static_matrix();
	GAUSS_ELIMINATE();
	j = 0;
	for ( i = 0; i < y_dim; i++ ) {
		if ( !iszero ( matrix[(long)i], x_dim ) ) {
			j++;
			copy_vector ( matrix[(long)i], p, x_dim );
			p += x_dim;
		}
	}
	v_join->dimension = j;
	mem_offset = j * x_dim;
	mem_offset = ALIGN4 ( mem_offset );
	SET_TOP ( old_top + mem_offset );
	return ( v_join );
}

SPACE *span_space ( DYNLIST vl, int len_vl )
{
	register int i, j;
	char *old_top;
	long mem_offset;
	SPACE *v_span = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	VEC p;
	DYNLIST q;
	
	y_dim = len_vl;
	x_dim = FILTRATION[MAX_ID].i_start;
	old_top = GET_TOP();
	p = ALLOCATE ( y_dim * x_dim );

	absolut = CALLOCATE ( y_dim );
	v_span->total_dim = x_dim;
	v_span->b_flag = UPPER;
	v_span->basis = p;
	
	for ( i = 0, q = vl; i < len_vl; i++,q = q->next ) {
	    copy_vector ( (VEC)q->value.gv, matrix[i], x_dim );
	}

	use_static_matrix();
	GAUSS_ELIMINATE();
	j = 0;
	for ( i = 0; i < y_dim; i++ ) {
		if ( !iszero ( matrix[(long)i], x_dim ) ) {
			j++;
			copy_vector ( matrix[i], p, x_dim );
			p += x_dim;
		}
	}
	v_span->dimension = j;
	mem_offset = j * x_dim;
	mem_offset = ALIGN4 ( mem_offset );
	SET_TOP ( old_top + mem_offset );
	return ( v_span );
}

SPACE *compl_space (SPACE *v_space)
{
	register int i, j;
	register int v_d = v_space->dimension;
	int cydim, cxdim;
	SPACE *v_compl = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	VEC p;
	VEC b;
	
	cxdim = v_space->total_dim;
	cydim = v_d + cxdim;
	j = v_compl->dimension = cxdim - v_d;
	p = ALLOCATE ( (long)cxdim * j );
	PUSH_STACK();
	v_compl->total_dim = cxdim;
	v_compl->b_flag = v_space->b_flag;
	v_compl->basis = p;
	
	b = v_space->basis;
	for ( i = 0; i < v_d; i++ ) {
		copy_vector ( b, matrix[(long)i], cxdim );
		b += cxdim;
	}
	for ( i = v_d; i < cydim; i++ ) {
		zero_vector ( matrix[(long)i], cxdim );
		matrix[(long)i][(long)(i-v_d)] = 1;
	}
	complement ( v_d, cxdim, cydim );
	for ( ;j--; ) {
		copy_vector ( fsolution[j], p, cxdim );
		p += cxdim;
	}
	POP_STACK();
	return ( v_compl );
}

void s_compress (void)
{
	VEC p;
	VEC b;
	register int j = 0;
	register int i;
		
	PUSH_STACK();
	b = p = ALLOCATE ( (long)x_dim * y_dim );
	absolut = CALLOCATE ( y_dim );
	use_static_matrix();
	GAUSS_ELIMINATE();
	for ( i = 0; i < y_dim; i++ ) {
		if ( !iszero ( matrix[(long)i], x_dim ) ) {
			j++;
			copy_vector ( matrix[(long)i], p, x_dim );
			p += x_dim;
		}
	}
	y_dim = j;
	p = b;
	for ( i = 0; i < y_dim; i++ ) {
		copy_vector ( p, matrix[(long)i], x_dim );
		p += x_dim;
	}
	POP_STACK();
}

SPACE *ideal_closure ( SPACE *v_space, int side_flag )
{
	VEC help, help1, help2, help3;
	int v_d = v_space->dimension;
	int i, j, l, cut;
	long mem_offset;
	SPACE *v_ideal = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	char *p, *old_top;
	VEC b;
	
	x_dim = v_ideal->total_dim = v_space->total_dim;
	p = old_top = ALLOCATE ( x_dim );
	cut = get_I_power ( x_dim );
	v_ideal->basis = p;
	v_ideal->b_flag = UPPER;
	y_dim = 0;
	b = v_space->basis;
	help1 = ALLOCATE ( x_dim );
	for ( l = 0; l < v_d; l++ ) {
		PUSH_STACK();
		if ( v_space->b_flag == LOWER )
			help = c_n_trans ( b, cut );
		else
			help = b;
		b += x_dim;
		help1 = ALLOCATE ( x_dim );
		help2 = ALLOCATE ( x_dim );
		for ( i = 0; i < x_dim; i++ ) {
			PUSH_STACK();
			zero_vector ( help1, x_dim );
			help1[i] = 1;
			if ( side_flag > 0 ) /* left or twoside */
				help3 = GROUP_MUL ( help1, help, cut );
			else				 /* right */
				help3 = GROUP_MUL ( help, help1, cut );
			if ( side_flag == 2 ) {
				for ( j = 0; j < x_dim; j++ ) {
					zero_vector ( help2, x_dim );
					help2[j] = 1;
					help  = GROUP_MUL ( help3, help2, cut );
					if ( !iszero ( help, x_dim ) ) {
						if ( y_dim == YMAX )
							s_compress();
						copy_vector ( help, matrix[(long)y_dim++], x_dim );
					}
				}
			}
			else {
				if ( !iszero ( help3, x_dim ) ) {
					if ( y_dim == YMAX )
						s_compress();
					copy_vector ( help3, matrix[(long)y_dim++], x_dim );
				}
			}
			POP_STACK();
		}
		POP_STACK();
	}
	absolut = CALLOCATE ( y_dim );
	use_static_matrix();
	GAUSS_ELIMINATE();
	j = 0;
	for ( i = 0; i < y_dim; i++ ) {
		if ( !iszero ( matrix[(long)i], x_dim ) ) {
			j++;
			copy_vector ( matrix[(long)i], p, x_dim );
			p += x_dim;
		}
	}
	v_ideal->dimension = j;
	mem_offset = j * x_dim;
	mem_offset = ALIGN4 ( mem_offset );
	SET_TOP ( old_top + mem_offset );
	return ( v_ideal );
}

SPACE *annihilator ( int side, SPACE *v_space )
{
	VEC help, help1, help2;
	int v_d = v_space->dimension;
	int i, j, k, cut;
	long mem_offset;
	SPACE *v_annil = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	char *p, *old_top;
	VEC b;
	
	x_dim = v_annil->total_dim = v_space->total_dim;
	p = old_top = ALLOCATE ( x_dim );
	cut = get_I_power ( x_dim );
	v_annil->basis = p;
	v_annil->b_flag = UPPER;
	y_dim = 0;
	b = v_space->basis;
	help1 = ALLOCATE ( x_dim );
	for ( i = 0; i < v_d; i++ ) {
		PUSH_STACK();
		if ( v_space->b_flag == LOWER )
			help = c_n_trans ( b, cut );
		else
			help = b;
		b += x_dim;
		for ( j = 0; j < x_dim; j++ ) {
			zero_vector ( help1, x_dim );
			help1[j] = 1;
			if ( side == 1 )
				help2 = GROUP_MUL ( help1, help, cut );
			else
				help2 = GROUP_MUL ( help, help1, cut );
			for ( k = x_dim; k--; )
				matrix[(long)(y_dim+k)][(long)j] = help2[k];
		}
		POP_STACK();
		y_dim += x_dim;
		s_compress();
	}
	absolut = CALLOCATE ( y_dim );
	inhom = ALLOCATE ( x_dim ),
	solve_equations ( x_dim, y_dim );
	j = 0;
	for ( i = 0; i < x_dim; i++ ) {
		if ( fsolution[i] ) {
			j++;
			copy_vector ( fsolution[i], p, x_dim );
			p += x_dim;
		}
	}
	v_annil->dimension = j;
	mem_offset = j * x_dim;
	mem_offset = ALIGN4 ( mem_offset );
	SET_TOP ( old_top + mem_offset );
	return ( v_annil );
}

SPACE *pot_space ( SPACE *v1, int power )
{
	register int i, j;
	register int v_d = v1->dimension;
	int cut;
	VEC help, help1;
	char *old_top;
	long mem_offset;
	SPACE *v_pot = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	VEC p;
	VEC b;
	
	y_dim = v_d;
	x_dim = v1->total_dim;
	cut = get_I_power ( x_dim );
	old_top = GET_TOP();
	p = ALLOCATE ( (long)y_dim );

	absolut = CALLOCATE ( y_dim );
	v_pot->total_dim = x_dim;
	v_pot->b_flag = v1->b_flag;
	v_pot->basis = p;
	
	b = v1->basis;
	for ( i = 0; i < v_d; i++ ) {
		PUSH_STACK();
		if ( v1->b_flag == LOWER )
			help = c_n_trans ( b, cut );
		else
			help = b;
		help1 = GROUP_EXP ( help, power, cut );
		copy_vector ( help1, matrix[(long)i], x_dim );
		POP_STACK();
		b += x_dim;
	}
	use_static_matrix();
	GAUSS_ELIMINATE();
	j = 0;
	for ( i = 0; i < y_dim; i++ ) {
		if ( !iszero ( matrix[(long)i], x_dim ) ) {
			j++;
			copy_vector ( matrix[(long)i], p, x_dim );
			p += x_dim;
		}
	}
	v_pot->dimension = j;
	mem_offset = j * x_dim;
	mem_offset = ALIGN4 ( mem_offset );
	SET_TOP ( old_top + mem_offset );
	return ( v_pot );
}

SPACE *principal_ideal ( VEC v, int cut, int side_flag )
{
	VEC help, help1, help2, help3;
	int i, j;
	long mem_offset;
	SPACE *v_ideal = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	char *p, *old_top;
	
	x_dim = v_ideal->total_dim = FILTRATION[cut].i_start;
	p = old_top = ALLOCATE ( x_dim );
	v_ideal->basis = p;
	v_ideal->b_flag = UPPER;
	y_dim = 0;
	help1 = ALLOCATE ( x_dim );
	help2 = ALLOCATE ( x_dim );
	for ( i = 0; i < x_dim; i++ ) {
		PUSH_STACK();
		zero_vector ( help1, x_dim );
		help1[i] = 1;
		if ( side_flag > 0 ) /* left or twoside */
			help3 = GROUP_MUL ( help1, v, cut );
		else				 /* right */
			help3 = GROUP_MUL ( v, help1, cut );
		if ( side_flag == 2 ) {
			for ( j = 0; j < x_dim; j++ ) {
				zero_vector ( help2, x_dim );
				help2[j] = 1;
				help  = GROUP_MUL ( help3, help2, cut );
				if ( !iszero ( help, x_dim ) ) {
					if ( y_dim == YMAX )
						s_compress();
					copy_vector ( help, matrix[(long)y_dim++], x_dim );
				}
			}
		}
		else {
			if ( !iszero ( help3, x_dim ) ) {
				if ( y_dim == YMAX )
					s_compress();
				copy_vector ( help3, matrix[(long)y_dim++], x_dim );
			}
		}
		POP_STACK();
	}
	absolut = CALLOCATE ( y_dim );
	use_static_matrix();
	GAUSS_ELIMINATE();
	j = 0;
	for ( i = 0; i < y_dim; i++ ) {
		if ( !iszero ( matrix[(long)i], x_dim ) ) {
			j++;
			copy_vector ( matrix[(long)i], p, x_dim );
			p += x_dim;
		}
	}
	v_ideal->dimension = j;
	mem_offset = j * x_dim;
	mem_offset = ALIGN4 ( mem_offset );
	SET_TOP ( old_top + mem_offset );
	return ( v_ideal );
}

/* end of module vector space */
