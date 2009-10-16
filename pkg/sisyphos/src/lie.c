/********************************************************************/
/*                                                                  */
/*  Module        : Lie algebra                                     */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies the routines to compute Lie algebra invariants      */
/*                                                                  */
/********************************************************************/

/* 	$Id: lie.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: lie.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.3  1995/02/27  13:42:41  pluto
 * Added "use_static_matrix" to direct call of GAUSS_ELIMINATE.
 *
 * Revision 1.2  1995/01/05  17:15:04  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: lie.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include "grpring.h"
#include	"pc.h"
#include <ctype.h>
#include	"storage.h"
#include	"error.h"
#include	"solve.h"

extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern FILE *proto;

int have_ls = FALSE;
int have_li = FALSE;
int have_js = FALSE;
SPACE *lie_series[MAXLIE];
SPACE *lie_ideal[MAXLIE];
SPACE *j_series[MAXLIE];
int lie_ser_len = 0;
int lie_id_len = 0;
int j_ser_len = 0;

int get_I_power (int dimension)
{
	register int i = MAX_ID;
	
	while ( ( dimension != FILTRATION[i].i_start ) && ( i > 0 ) ) i--;
	return ( i );
}

SPACE *s_lie_prod (SPACE *v1, SPACE *v2)
{
	register int i, j;
	register int v1_d = v1->dimension;
	register int v2_d = v2->dimension;
	char *old_top;
	int cut;
	long mem_offset;
	VEC help1, help2;
	SPACE *v_lie = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	VEC p;
	VEC b1, b2;

	if ( (v1->b_flag != v2->b_flag) || ( v1->b_flag != UPPER) ||
		(v1->total_dim != v2->total_dim) ) {
			set_error ( INCOMPATIBLE_SPACES );
			return ( (SPACE *)NIL );
	}

	x_dim = v1->total_dim;
	y_dim = v1_d * v2_d;
	old_top = GET_TOP();
	p = ALLOCATE ( (long)y_dim * x_dim );
	v_lie->total_dim = x_dim;
	v_lie->b_flag = v1->b_flag;
	v_lie->basis = p;
	
	cut = get_I_power ( x_dim );
	y_dim = 0;
	b1 = v1->basis;
	for ( i = 0; i < v1_d; i++ ) {
		b2 = v2->basis;
		for ( j = 0; j < v2_d; j++ ) {
			PUSH_STACK();
			help1 = GROUP_MUL ( b1, b2, cut );
			help2 = GROUP_MUL ( b2, b1, cut );
			SUBA_VECTOR ( help1, help2, x_dim );
			if ( !iszero ( help2, x_dim ) ) {
				if ( y_dim == YMAX )
					s_compress();
				copy_vector ( help2, matrix[(long)y_dim++], x_dim );
			}
			POP_STACK();
			b2 += x_dim;
		}
		b1 += x_dim;
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
	v_lie->dimension = j;
	mem_offset = j * x_dim;
	mem_offset = ALIGN4 ( mem_offset );
	SET_TOP ( old_top + mem_offset );

	return ( v_lie );
}
	
SPACE *conv_I_space (int I_power, int modI_power)
{
	register int i;
	register int v_t = FILTRATION[modI_power].i_start;
	register int v_d;
	SPACE *v_I = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
	VEC p;
	VEC b;
	
	if ( I_power == 0 ) {
		i = 0;
		v_d = v_t;
	}
	else {
	 	i = FILTRATION[I_power].i_start;
		v_d = v_t - i;
	}
	p = ALLOCATE ( (long)v_d * v_t );
	v_I->total_dim = v_t;
	v_I->dimension = v_d;
	v_I->b_flag = UPPER;
	b = v_I->basis = p;
	
	
	for (  ; i < v_t; i++ ) {
		zero_vector ( b, v_t );
		b[i] = 1;
		b += v_t;
	}
	
	return ( v_I );
}

void get_lie_series(void)
{
	register int i = 0;
	int zero_flag = FALSE;
	
	lie_series[0] = conv_I_space ( 0, MAX_ID );
	while ( !zero_flag ) {
		i++;
		lie_series[i] = s_lie_prod ( lie_series[i-1], lie_series[0] );
		zero_flag = (lie_series[i]->dimension == 0 );
		if ( zero_flag ) lie_ser_len = i;
	}
	have_ls = TRUE;
}

void get_lie_ideal(void)
{
	register int i = 0;
	
	if ( !have_ls )
		get_lie_series();
	for ( ; i <= lie_ser_len; i++ ) {
		lie_ideal[i] = ideal_closure ( lie_series[i], 1 );
/*		printf ( "done %d\n", i ); */
	}
	lie_id_len = lie_ser_len;
	have_li = TRUE;
}

void get_j_series(void)
{
	register int i = 1;
	int zero_flag = FALSE;
	int p_index;
	int card = GCARD;
	char *old_top;
	long mem_offset;
	VEC p;
	SPACE *comm_sp, *pot_sp, *v_space;
	
	j_series[0] = conv_I_space ( 0, MAX_ID );
	j_series[1] = conv_I_space ( 1, MAX_ID );
	while ( !zero_flag ) {
		j_series[++i] = (SPACE *)ALLOCATE ( (int)sizeof ( SPACE ) );
		p = old_top = ALLOCATE ( card );
		j_series[i]->basis = p;
		j_series[i]->b_flag = UPPER;
		j_series[i]->total_dim = card;
		comm_sp = s_lie_prod ( j_series[i-1], j_series[0] );
		p_index = i / GPRIME;
		if ( p_index * GPRIME < i ) p_index++;
		pot_sp  = pot_space ( j_series[p_index], GPRIME );
		v_space = join_space ( comm_sp, pot_sp );
		v_space = ideal_closure ( v_space, 1 );
		j_series[i]->dimension = v_space->dimension;
		printf ( "dimension of jseries[%1d] : %d\n", i, v_space->dimension );
		mem_offset = v_space->dimension * card;
		mem_offset = ALIGN4 ( mem_offset );
		copy_vector ( v_space->basis, p, mem_offset );
		SET_TOP ( old_top + mem_offset );
		zero_flag = (j_series[i]->dimension == 0 );
		if ( zero_flag ) j_ser_len = i;
	}
	have_js = TRUE;
}

/* end of module lie algebra */
