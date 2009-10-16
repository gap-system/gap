/********************************************************************/
/*  Module        : Group ring                                      */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies the routines needed to compute in modular group     */
/*     algebras.                                                    */
/*                                                                  */
/********************************************************************/

/* 	$Id: grpring.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: grpring.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.2  1996/03/19 08:17:01  pluto
 * 	New 'translation' routine that does not use group ring multiplication.
 * 	Modified small group ring functions to handle odd primes correctly.
 *
 * 	Revision 3.1  1995/12/14 15:21:20  pluto
 * 	Took loop invariants out of inner loop in 'tc_group_mul' and
 * 	't_group_mul'.
 *
 * 	Revision 3.0  1995/06/23 09:42:47  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.3  1995/02/14  15:14:33  pluto
 * Changed routine 'jennings_table'.
 *
 * Revision 1.2  1995/01/05  17:07:25  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: grpring.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "fdecla.h"
#include "pc.h"
#include <ctype.h>
# include	"storage.h"
# include	"error.h"

GRPRING *group_ring = NULL;
PCGRPDESC *group_desc = NULL;
extern FILE *out_hdl;
extern int mon_per_line;
extern DSTYLE displaystyle;
extern int prime;
extern int bperelem;
extern VEC svec;
int cut, fend, card;

static VEC *n_gen;				/* G_i := g_i - 1 in standard basis */

VEC *can_to_new;
VEC *new_to_can;

VEC (*group_mul)	_(( VEC vec1, VEC vec2, int cut ));
VEC (*cgroup_mul)	_(( VEC vec1, VEC vec2 ));
VEC (*group_exp)	_(( VEC vec, int power, int cut ));

char *add_path 				_(( char *env_var, char *filename ));
void pc_f_read_in 				_(( FILE *in_file, int pos, PCGRPDESC *g_desc ));
void get_pc_weights 			_(( PCGRPDESC *g_desc ));
void	print_gr_relations 			_(( PCGRPDESC *g_desc ));

int iszero ( VEC vec, int max )
{
	register int i = max;
	
	while ( i-- )
		if ( vec[i] != 0 )
			return ( FALSE );
	return ( TRUE );
}

int nr ( VEC vector )
/* compute lexical number of monom */
{
	int k = vector[0];
	int i;
	for ( i = 1; i < bperelem; i++ ) {
		k *= G_MAX[i];
		k += vector[i];
	}
	return ( k );
}

VEC c_group_mul ( VEC vec1, VEC vec2 )
/* group ring multiplication using standard basis
   and collecting */
{
	register int i, j;
	VEC result;
	PCELEM res;
	
	result = CALLOCATE ( card );
	 
	for ( i = 0; i < card; i++ ) {
		for ( j = 0; j < card; j++ ) {
			if ( vec1[i] && vec2[j] ) {
				res = monom_mul ( EL(i), EL(j) );
				result[IND(res)] = ADD ( MUL ( vec1[i], vec2[j] ),
						result[IND(res)] );
			}
		}
	} 
	return ( result );
}

VEC tc_group_mul ( VEC vec1, VEC vec2 )
/* group ring multiplication using standard basis
   and multiplication table */
{
	register char v1, v2;
	register int k, i, j;
	VEC result;
	
	result = CALLOCATE ( card );
	
	for ( i = 0; i < card; i++ ) {
		if ( (v1=vec1[i]) !=0 ) {
			for ( j = 0; j < card; j++ ) {
				if ( (v2=vec2[j]) !=0 ) {
					k = TP ( i, j );
					result[k] = ADD ( MUL ( v1, v2 ),
								   result[k] );
				}
			}
		}
	}
	return ( result );
}

VEC cgroup_exp ( VEC vector, register int power )
/* group ring exponentiation using standard basis */
{
	register int i = 4096;
	VEC v_save, result;
	char *old_top;

	v_save = ALLOCATE ( card );
	old_top = GET_TOP();
	result = vector;
	while ( !( power & i ) ) i >>= 1;
	while ( (i >>= 1) != 0 ) {
		result = C_GROUP_MUL ( result, result );
		if ( power & i )
			result = C_GROUP_MUL ( result, vector );
	}
	copy_vector ( result, v_save, card );
	SET_TOP ( old_top );
	return ( v_save );
}

VEC n_group_mul ( VEC vec1, VEC vec2, int cut )
/* group ring multiplication using alternate basis,
   conversion tables and group ring multiplication for
   standard basis */
{
	register int i, fend;
	register char val;
	VEC vhelp, result, c_vec1, c_vec2;
	char *old_top;

	fend = FILTRATION[cut].i_start;
	result = CALLOCATE ( fend );
	old_top = GET_TOP();

	c_vec1 = CALLOCATE ( card );
	c_vec2 = CALLOCATE ( card );
	
	/* convert arguments to canonical basis */
	for ( i = fend; i--; ) {
		if ( ( val = vec1[i] ) != 0 )
			ADD_MULT ( val, new_to_can[i], c_vec1, card );
		if ( ( val = vec2[i] ) != 0 )
			ADD_MULT ( val, new_to_can[i], c_vec2, card );
	}

	/* multiply and convert back */
	vhelp = C_GROUP_MUL ( c_vec1, c_vec2 );
	for ( i = card; i--; ) {
		if ( ( val = vhelp[i] ) != 0 )
			ADD_MULT ( val, can_to_new[i], result, fend );
	}
	SET_TOP ( old_top );
	return ( result );
}

VEC ngroup_exp ( VEC vector, int power, int cut )
/* group ring exponentiation using alternate basis,
   conversion tables and group ring exponentation for
   standard basis */
{
	register int i, fend;
	register char val;
	VEC vhelp, result, c_vec1;
	char *old_top;

	fend = FILTRATION[cut].i_start;
	result = CALLOCATE ( fend );
	old_top = GET_TOP();
	
	c_vec1 = CALLOCATE ( card );
	
/*	convert argument to canonical basis */
	for ( i = fend; i--; ) {
		if ( ( val = vector[i] ) != 0 )
			ADD_MULT ( val, new_to_can[i], c_vec1, card );
	}
	
/*	multiply and convert back */
	vhelp = cgroup_exp ( c_vec1, power );
	for ( i = card; i--; ) {
		if ( ( val = vhelp[i] ) != 0 )
			ADD_MULT ( val, can_to_new[i], result, fend );
	}
	SET_TOP ( old_top );
	return ( result );
}

VEC sn_group_mul ( VEC vec1, VEC vec2, int cut )
/* small group ring multiplication using alternate basis,
   conversion tables and group ring multiplication for
   standard basis */
{
	register int i, fend;
	register char val;
	VEC vhelp, result, c_vec1, c_vec2;
	char *old_top;

	fend = FILTRATION[cut].i_start;
	result = CALLOCATE ( fend );
	old_top = GET_TOP();

	c_vec1 = CALLOCATE ( card );
	c_vec2 = CALLOCATE ( card );
	
	/* convert arguments to canonical basis */
	for ( i = fend; i--; ) {
		if ( ( val = vec1[i] ) != 0 )
			ADD_MULT ( val, new_to_can[i], c_vec1, card );
		if ( ( val = vec2[i] ) != 0 )
			ADD_MULT ( val, new_to_can[i], c_vec2, card );
	}

	/* multiply and convert back */
	vhelp = C_GROUP_MUL ( c_vec1, c_vec2 );
	for ( i = card; i--; ) {
		if ( ( val = vhelp[i] ) != 0 )
			ADD_MULT ( val, can_to_new[i], result, fend );
	}
	/* small group ring */
	for ( i = 0; i < fend; i++ )
		result[i] *= svec[i];

	SET_TOP ( old_top );
	return ( result );
}

VEC sngroup_exp ( VEC vector, int power, int cut )
/* small group ring exponentiation using alternate basis,
   conversion tables and group ring exponentation for
   standard basis */
{
	register int i, fend;
	register char val;
	VEC vhelp, result, c_vec1;
	char *old_top;

	fend = FILTRATION[cut].i_start;
	result = CALLOCATE ( fend );
	old_top = GET_TOP();
	
	c_vec1 = CALLOCATE ( card );
	
/*	convert argument to canonical basis */
	for ( i = fend; i--; ) {
		if ( ( val = vector[i] ) != 0 )
			ADD_MULT ( val, new_to_can[i], c_vec1, card );
	}
	
/*	multiply and convert back */
	vhelp = cgroup_exp ( c_vec1, power );
	for ( i = card; i--; ) {
		if ( ( val = vhelp[i] ) != 0 )
			ADD_MULT ( val, can_to_new[i], result, fend );
	}
	/* small group ring */
	for ( i = 0; i < fend; i++ )
		result[i] *= svec[i];
	SET_TOP ( old_top );
	return ( result );
}

VEC t_group_mul ( VEC vec1, VEC vec2, int cut )
/* group ring multiplication using alternate basis
   and multiplication table for alternate basis */
{
	register char v1, v2;
	register char val;
	register int i, j;
	register VEC prod;
	int fend = FILTRATION[cut].i_start;
	VEC result;
	
	result = CALLOCATE ( fend );
	
	for ( i = 0; i < fend; i++ ) {
		if ( (v1=vec1[i]) !=0 ) {
			for ( j = 0; j < fend; j++ ) {
				if ( (prod = JT(i,j)) != NULL ) {
					if ( (v2=vec2[j]) !=0 ) {
						val = MUL ( v1, v2 );
						ADD_MULT ( val, prod, result, fend );
					}
				}
			}
		}
	}
	return ( result );
}

VEC tgroup_exp ( VEC vector, register int power, int cut )
/* group ring exponentiation using alternate basis
   and multiplication table for alternate basis */
{
	register int i = 4096;
	int fend = FILTRATION[cut].i_start;
	VEC v_save, result;
	char *old_top;

	v_save = ALLOCATE ( fend );
	old_top = GET_TOP();
	result = vector;
	while ( !( power & i ) ) i >>= 1;
	while ( (i >>= 1) != 0 ) {
		result = t_group_mul ( result, result, cut );
		if ( power & i )
			result = t_group_mul ( result, vector, cut );
	}
	copy_vector ( result, v_save, fend );
	SET_TOP ( old_top );
	return ( v_save );
}

int get_order ( VEC vector, int cut )
{
	int i = 1;
	int fend = FILTRATION[cut].i_start;
	VEC help;
	
	if ( vector[0] == 0 ) {
		set_error ( IS_NOT_UNIT );
		return ( 0 );
	}
	PUSH_STACK();
	help = ALLOCATE ( fend );
	copy_vector ( vector, help, fend );
	while ( !iszero ( help+1, fend-1 ) ) {
		help = GROUP_MUL ( help, vector, cut );
		i++;
	}
	POP_STACK();
	return ( i );
}

VEC gr_invers ( VEC elem, int mod_id )
{
	VEC ipart, help, inv;
	register int len = FILTRATION[mod_id].i_start;
	
	if ( elem[0] == 0 ) {
		set_error ( IS_NOT_UNIT );
		return ( NULL );
	}

	inv = CALLOCATE ( len );
	inv[0] = 1;
	
	PUSH_STACK();
	ipart = ALLOCATE ( len );
	help = ALLOCATE ( len );
	copy_vector ( elem, ipart, len );
	ipart[0] = 0;
	SMUL_VECTOR ( prime-1, ipart, len );
	copy_vector ( ipart, help, len );
	while ( !iszero ( help, len ) ) {
	ADD_VECTOR ( help, inv, len );
		help = GROUP_MUL ( help, ipart, mod_id );
	}
	POP_STACK();
	return ( inv );
}

VEC mult_comm ( VEC u1, VEC u2, int mod_id )
{
	VEC comm, help;
	register int len = FILTRATION[mod_id].i_start;
	
	if ( (u1[0] == 0) || (u2[0] == 0) ) {
		set_error ( IS_NOT_UNIT );
		return ( NULL );
	}

	comm = ALLOCATE ( len );
	PUSH_STACK();
	help = GROUP_MUL ( gr_invers ( u1, mod_id ), gr_invers ( u2, mod_id ), mod_id );
	help = GROUP_MUL ( help, u1, mod_id );
	help = GROUP_MUL ( help, u2, mod_id );
	copy_vector ( help, comm, len );
	POP_STACK();
	return ( comm );
}

VEC gr_star ( VEC vec, int cut )
/* computes vec* */
{
	register int i, fend;
	register char val;
	VEC result, c_vec1, c_vec2;
	char *old_top;

	fend = FILTRATION[cut].i_start;
	result = CALLOCATE ( fend );
	old_top = GET_TOP();

	c_vec1 = CALLOCATE ( card );
	c_vec2 = CALLOCATE ( card );
	
	/* convert arguments to canonical basis */
	for ( i = fend; i--; ) {
		if ( ( val = vec[i] ) != 0 )
			ADD_MULT ( val, new_to_can[i], c_vec1, card );
	}

	for ( i = 0; i < card ; i++ )
		if ( (val=c_vec1[i]) != 0 )
			c_vec2[nr ( g_invers ( C_MONOM[i] ) )] = val;

	/* multiply and convert back */
	for ( i = card; i--; ) {
		if ( ( val = c_vec2[i] ) != 0 )
			ADD_MULT ( val, can_to_new[i], result, fend );
	}
	SET_TOP ( old_top );
	return ( result );
}

void c_monom_write ( PCELEM elem )
/* print monom of standard basis */
{
	register int i;
	
	if ( iszero ( elem, BPERELEM ) )
		fprintf ( out_hdl, "1" );
	else {
		for ( i = 0; i < GNUMGEN; i++ ) {
			if ( elem[i] == 1 )
				fprintf ( out_hdl, "%s", G_GEN[i] );
			else if ( elem[i] > 1 ) 
				fprintf ( out_hdl, "%s^%1d", G_GEN[i], elem[i] );
		}
	}
}

void word_write ( PCELEM elem )
/* print monom of standard basis as word 
   (including '*' signs)                 */
{
	register int i;
	int isfirst = TRUE;
	
	if ( iszero ( elem, BPERELEM ) )
		fprintf ( out_hdl, "1" );
	else {
		for ( i = 0; i < GNUMGEN; i++ ) {
			if ( elem[i] != 0 ) {
				if ( isfirst )
					isfirst = FALSE;
				else
					fprintf ( out_hdl, "*" );
				if ( displaystyle == GAP )
					fprintf ( out_hdl, "Igs(%s)[%1d]", group_desc->group_name, group_desc->pimage[i]+1 );
				else
					fprintf ( out_hdl, "%s", G_GEN[i] );
				if ( elem[i] > 1 ) 
					fprintf ( out_hdl, "^%1d", elem[i] );
			}
		}
	}
}

void fc_monom_write ( PCELEM elem, FILE *handle )
/* print monom of standard basis to specific file */
{
	register int i;
	
	if ( iszero ( elem, BPERELEM ) )
		fprintf ( handle, "1" );
	else {
		for ( i = 0; i < GNUMGEN; i++ ) {
			if ( elem[i] == 1 )
				fprintf ( handle, "%s", G_GEN[i] );
			else if ( elem[i] > 1 ) 
				fprintf ( handle, "%s^%1d", G_GEN[i], elem[i] );
		}
	}
}

void cgroup_write ( VEC vector )
/* print group ring element in standard basis */
{
	register int i;
	register char val;
	int count = 0;
	char sign;
	char nonz = FALSE;

	for ( i = 0; i < GCARD; i++ ) {
		if ( ( val = vector[i] ) != 0 ) {
			count++;
			sign = val == 1 ? '+' : '-';
			if ( nonz || val != 1 )
				fprintf ( out_hdl, "%c", sign );
			nonz = TRUE;
			c_monom_write ( C_MONOM[i] );
			if ( count == 21 ) {
				count = 0;
				fputs ( "\n", out_hdl );
			}
		}
	}
	if ( !nonz )
		fprintf ( out_hdl, "0" );
	fputs ( "\n", out_hdl );
}

static char *ToUpper ( char *name )
{
	char *new_name = ALLOCATE ( strlen ( name ) );
	int i;
	
	strcpy ( new_name, name );
	for ( i = 0; i < strlen ( name ); i++ )
		if ( islower ( new_name[i] ) )
			new_name[i] = toupper ( new_name[i] );
	return ( new_name );
}
	
void n_monom_write ( int nr )
/* print monom of alternate basis */
{
	VEC elem = N_MONOM[nr];
	register int i;
	
	if ( nr == 0 )
		fprintf ( out_hdl, "1" );
	else {
		for ( i = 0; i < GNUMGEN; i++ ) {
			if ( elem[i] == 1 )
				fprintf ( out_hdl, "%s", ToUpper ( G_GEN[i] ) );
			else if ( elem[i] > 1 ) 
				fprintf ( out_hdl, "%s^%1d", ToUpper ( G_GEN[i] ), elem[i] );
		}
	}
}

void n_group_write ( VEC vector, int cut )
/* print group ring element in alternate basis */
{
	register int i;
	register char val;
	int count = 0;
	char sign;
	int fend = FILTRATION[cut].i_start;
	char nonz = FALSE;

	for ( i = 0; i < fend; i++ ) {
		if ( ( val = vector[i] ) != 0 ) {
			count++;
			if ( prime <= 3 ) {
				sign = val == 1 ? '+' : '-';
				if ( nonz || val != 1 )
					fprintf ( out_hdl, " %c ", sign );
			}
			else {
				if ( nonz )
					fprintf ( out_hdl, " + " );
				if ( val != 1 )
					fprintf ( out_hdl, "%d", val );
			}
			nonz = TRUE;
			n_monom_write ( i );
			if ( count == mon_per_line ) {
				count = 0;
				fputs ( "\n", out_hdl );
			}
		}
	}
	if ( !nonz )
		fprintf ( out_hdl, "0" );
	fputs ( "\n", out_hdl );
}

void monom_write ( int nr, FILE *handle )
/* print monom of alternate basis to given file */
{
	VEC elem = N_MONOM[nr];
	register int i;
	
	if ( nr == 0 )
		fprintf ( handle, "1" );
	else {
		for ( i = 0; i < GNUMGEN; i++ ) {
			if ( elem[i] == 1 )
				fprintf ( handle, "%s", ToUpper ( G_GEN[i] ) );
			else if ( elem[i] > 1 ) 
				fprintf ( handle, "%s^%1d", ToUpper ( G_GEN[i] ), elem[i] );
		}
	}
}

void group_write ( VEC vector, int cut, FILE *handle )
/* print group ring element in alternate basis to given file */
{
	register int i;
	register char val;
	int count = 0;
	char sign;
	int fend = FILTRATION[cut].i_start;
	char nonz = FALSE;

	for ( i = 0; i < fend; i++ ) {
		if ( ( val = vector[i] ) != 0 ) {
			count++;
			if ( prime <= 3 ) {
				sign = val == 1 ? '+' : '-';
				if ( nonz || val != 1 )
					fprintf ( handle, " %c ", sign );
			}
			else {
				if ( nonz )
					fprintf ( handle, " + " );
				if ( val != 1 )
					fprintf ( handle, "%d", val );
			}
			nonz = TRUE;
			monom_write ( i, handle );
			if ( count == mon_per_line ) {
				count = 0;
				fputs ( "\n", handle );
			}
		}
	}
	if ( !nonz )
		fprintf ( handle, "0" );
	fputs ( "\n", handle );
}

VEC re_order ( VEC vector )
/* canonical order -> new order */
{
	VEC new_vec;
	register int i = card;
	register char val;
	char *old_top;
	
	old_top = GET_TOP();
	new_vec = CALLOCATE ( card );
	while ( i-- ) {
		if ( ( val = vector[i] ) != 0 )
			new_vec[EL_NUM[i]] = val;
	}
	copy_vector ( new_vec, vector, card );
	SET_TOP ( old_top );
	return ( vector );
}

VEC do_conv ( int num )
/* convert monoms */
{
	char *old_top;
	register int i;
	register char val;
	VEC phelp, help, result;
	
	result = ALLOCATE ( card );
	
	old_top = GET_TOP();
	help = CALLOCATE ( card );
	i = GNUMGEN;
	help[0] = 1;
	while ( i-- ) {
		if ( ( val = C_MONOM[num][i] ) != 0 ) {
			phelp = cgroup_exp ( n_gen[i], val );
			help = C_GROUP_MUL ( phelp, help );
		}
	}
	copy_vector ( help, result, card );
	SET_TOP ( old_top );
	return ( result );
}

VEC shift_mul ( VEC v, int d, int len )
{
	VEC res;
	int i;

	res = CALLOCATE ( len );
	for ( i = 0; i + d < len; i++ )
		if ( v[i] != 0 ) 
			res[i+d] = v[i];
	return ( res );
}

void translation (void)
/* tables for basis transformation */
{
	int i, f, l, n0;
	VEC list, zw;
	int *offlist;
	VEC *can_new;
	
	/* reserve the required space on the permanent stack */
	use_permanent_stack();
	can_to_new = ARRAY ( GCARD, VEC );
	new_to_can = ARRAY ( GCARD, VEC );
	for ( i = 0; i < card; i++ ) {
		can_to_new[i] = CALLOCATE ( fend );
		new_to_can[i] = CALLOCATE ( card );
	}
	use_temporary_stack();
	
	/* 1 maps to 1 */
	can_to_new[0][0] = new_to_can[0][0] = 1;

	PUSH_STACK();

	/* get temporary storage for can_to_new */
	can_new = ARRAY ( GCARD, VEC );
	for ( i = 0; i < card; i++ ) {
		can_new[i] = CALLOCATE ( card );
	}

	
	list = ALLOCATE ( GNUMGEN );

	/* list of offsets */
	offlist = ARRAY ( GNUMGEN, int );
	for ( i = GNUMGEN, n0 = 1; i--; n0 *= GPRIME )
		offlist[i] = n0;

	for ( i = 1; i < card; i++ ) {
		for ( f = 0; f < GNUMGEN; f++ )
			if ( C_MONOM[i][f] != 0 ) break;
		for ( l = GNUMGEN; l--; )
			if ( C_MONOM[i][l] != 0 ) break;
		if ( (l == f) && (C_MONOM[i][l] == 1 ) ) {
			new_to_can[EL_NUM[i]][offlist[l]] = 1;
			new_to_can[EL_NUM[i]][0] = GPRIME - 1;
			can_new[i][offlist[l]] = 1;
			can_new[i][0] = 1;
		}
		else {
			PUSH_STACK();
			zero_vector ( list, GNUMGEN );
			copy_vector ( C_MONOM[i], list, l+1 );
			list[l] -= 1;
			n0 = nr ( list );
			ADD_MULT ( GPRIME - 1, new_to_can[EL_NUM[n0]],
					 new_to_can[EL_NUM[i]], card );
			zw = shift_mul ( new_to_can[EL_NUM[n0]], offlist[l], card  );
			ADD_VECTOR ( zw, new_to_can[EL_NUM[i]], card );
			copy_vector ( can_new[n0], can_new[i], card );
			zw = shift_mul ( can_new[n0], offlist[l], card );
			ADD_VECTOR ( zw, can_new[i], card );
			POP_STACK();
		}
	}
	for ( i = card; --i; ) {
		can_new[i] = re_order ( can_new[i] );
		copy_vector ( can_new[i], can_to_new[i], fend );
	}

	POP_STACK();
}

void otranslation (void)
/* tables for basis transformation */
{
	int i;
	VEC list;
	
	use_permanent_stack();
	can_to_new = ARRAY ( GCARD, VEC );
	new_to_can = ARRAY ( GCARD, VEC );
	
	/* generate G_i := g_i - 1 */
	n_gen = ARRAY ( GNUMGEN, VEC );
	list = ALLOCATE ( GNUMGEN );
	for ( i = GNUMGEN; i--; ) {
		n_gen[i] = CALLOCATE ( card );
		n_gen[i][0] = GPRIME - 1;
		zero_vector ( list, GNUMGEN );
		list[i] = 1;
		n_gen[i][nr ( list )] = 1;
	}

	/* 1 maps to 1 */
	can_to_new[0] = CALLOCATE ( card );
	can_to_new[0][0] = 1;
	new_to_can[0] = ALLOCATE ( card );
	copy_vector ( can_to_new[0], new_to_can[0], card );

	for ( i = card; --i; ) {
		new_to_can[EL_NUM[i]] = do_conv ( i );
	}
	for ( i = GNUMGEN; i--; )
		n_gen[i][0] = 1;
	for ( i = card; --i; ) {
		can_to_new[i] = re_order ( do_conv ( i ) );
	}
	use_temporary_stack();
}

void get_gr_structs ( PCGRPDESC *g_desc, GRPRING *gr_desc )
{
	int i, ideal, nrm, e_num;
	VEC count;

	count = CALLOCATE ( g_desc->num_gen );

	/* compute max_id, i.e. I^max_id = 0 */
	g_desc->max_id = 1;
	for ( i = g_desc->num_gen; i--; )
		g_desc->max_id += g_desc->g_ideal[i] * ( g_desc->g_max[i] - 1 );

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */
	card = g_desc->group_card;
/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */

	gr_desc->filtration = ARRAY ( g_desc->max_id + 1, FILT );
	gr_desc->n_monom = ARRAY ( card, VEC );
	gr_desc->c_monom = ARRAY ( card, PCELEM );
	gr_desc->el_num = ARRAY ( card, int );
		
	/* compute dimension of I^n, order monoms of new basis according
	   to power of I */

	for ( i = g_desc->max_id; i--; )
		gr_desc->filtration[i].i_dim = 0;

	gr_desc->n_monom[0] = CALLOCATE ( g_desc->num_gen );
	gr_desc->c_monom[0] = CALLOCATE ( g_desc->num_gen );
	gr_desc->el_num[0] = 0;
	e_num = 0;
	while ( inc_count ( count, g_desc->num_gen ) ) {
		gr_desc->c_monom[++e_num] = ALLOCATE ( g_desc->num_gen );
		copy_vector ( count, gr_desc->c_monom[e_num], g_desc->num_gen );
		ideal = 0;
		for ( i = g_desc->num_gen; i--; ) 
			ideal += g_desc->g_ideal[i] * count[i];
		gr_desc->filtration[ideal].i_dim++;
		nrm = 0;
		for ( i = ideal; i > 0; i-- )
			nrm += gr_desc->filtration[i].i_dim;
		for ( i = g_desc->group_card; --i > nrm; )
			gr_desc->n_monom[i] = gr_desc->n_monom[i-1];
		gr_desc->n_monom[nrm] = ALLOCATE ( g_desc->num_gen );
		copy_vector ( count, gr_desc->n_monom[nrm], g_desc->num_gen );
	}
	
	/* translation table for gr_desc->n_monom numbers :
	   e_num : lexical number
	   nrm   : new number				 */
	   
	for ( nrm = 1; nrm < g_desc->group_card; nrm++ ) {
		e_num = gr_desc->n_monom[nrm][0];
		for ( i = 1; i < g_desc->num_gen; i++ ) {
			e_num *= g_desc->g_max[i];
			e_num += gr_desc->n_monom[nrm][i];
		}
		gr_desc->el_num[e_num] = nrm;
	}

	/* start and end of I^n pieces */
	gr_desc->filtration[0].i_start = gr_desc->filtration[0].i_end = 0;
	for ( i = 1; i < g_desc->max_id; i++ ) {
		gr_desc->filtration[i].i_start = gr_desc->filtration[i-1].i_end + 1;
		gr_desc->filtration[i].i_end   = gr_desc->filtration[i-1].i_end + 
			gr_desc->filtration[i].i_dim;
	}
	gr_desc->filtration[g_desc->max_id].i_start = g_desc->group_card;
	gr_desc->filtration[g_desc->max_id].i_end = gr_desc->filtration[g_desc->max_id].i_dim = 0;

	
	/* create vector for each generator A,B,C,D,... */
	gr_desc->ngen_vec = ARRAY ( g_desc->num_gen, VEC );
	nrm = 1;
	for ( i = g_desc->num_gen; i--; ) {
		gr_desc->ngen_vec[i] = CALLOCATE ( card );
		gr_desc->ngen_vec[i][gr_desc->el_num[nrm]] = 1;
		nrm *= g_desc->prime;
	}
	gr_desc->mul_table = NULL;	
	gr_desc->jenn_table = NULL;
}

int **multiplication_table (void)
{
	long i, j;
	int **mul_table;
	
	mul_table = allocate ( GCARD * sizeof ( int* ) );
	for ( i = GCARD; i--; ) {
		mul_table[i] = allocate ( GCARD * sizeof ( int ) );
		for ( j = GCARD; j--; ) {
			PUSH_STACK();
			mul_table[i][j] =  IND ( monom_mul ( EL(i), EL(j) ) );
			POP_STACK();
		}
	}
	return ( mul_table );
}


VEC **jennings_table ( int cut )
/* compute multiplication table for alternate basis */
{
	int sec_card = FILTRATION[cut == 0 ? MAX_ID : cut].i_start;
	VEC left = ALLOCATE ( sec_card );
	VEC right = ALLOCATE ( sec_card );
	VEC res;
	int i, j, k, l;
	int count = 0;
	int flag;
	VEC q = NULL;
	VEC **mtab;
	char *old_top;

	if ( cut == 0 ) cut = MAX_ID;
	mtab = ARRAY ( sec_card, VEC* );
	for ( i = 0; i < sec_card; i++ )
		mtab[i] = ARRAY ( sec_card, VEC );
	for ( i = 0; i < sec_card; i++ ) {
	    /* printf ( ">>>>>>>>>> row no, %d\n", i ); */
	    zero_vector ( left, sec_card );
	    left[i] = 1;
	    for ( j = 0; j < sec_card; j++ ) {
		   zero_vector ( right, sec_card );
		   right[j] = 1;
		   old_top = GET_TOP();
		   res = n_group_mul ( left, right, cut );
		   if ( iszero ( res, sec_card ) ) {
			  mtab[i][j] = NULL;
			  SET_TOP ( old_top );
		   } 
		   else {
			  flag = FALSE;
			  for ( k = 0; k <= i; k++ ) {
				 for ( l = 0; l < j; l++ ) { 
					if ( (q = mtab[k][l]) != NULL )
					    if ( (flag = ( memcmp ( res, q, sec_card ) 
								    == 0 ) ) != 0 )
						   break;
				 }
				 if ( flag != 0 )
					break;
			  }
			  if ( !flag ) {
				 mtab[i][j] = res;
				 count++;
				 /* if ( (count % 100) == 0 )
					printf ( "count = %d\n", count ); */
			  }
			  else {
				 mtab[i][j] = q;
				 SET_TOP ( old_top );
			  }
		   }
	    }
	}
	printf ( "dimension: %d, different entries: %d, amount: %d\n",
		    sec_card, count, count*sec_card ); 
	return ( mtab );
}

GRPRING *set_groupring ( PCGRPDESC *g_desc )
{
	int scard = card;
	GRPRING *gr_desc;
	
	gr_desc = ALLOCATE ( sizeof ( GRPRING ) ); 
     /* g_desc is now actual group */
	
	card = g_desc->group_card;
		
	/* calculate specific structures of group ring */
	get_gr_structs ( g_desc, gr_desc );
	
	gr_desc->g = g_desc;
	card = scard;
	return ( gr_desc );
}

void set_domain ( GRPRING *gr_desc, int modulo )
{
	if ( gr_desc->g->g_ideal[0] == 0 ) {
		set_error ( NO_WEIGHTS );
		return;
	}
	
	group_ring = gr_desc;
	set_main_group ( gr_desc->g );
	cgroup_mul = c_group_mul;
	card = GCARD;

	if ( (modulo == -1) || (modulo < -1) || (modulo > MAX_ID) )
		modulo = MAX_ID;
	cut = modulo;
	fend = FILTRATION[cut].i_start;

	/* translation tables */
	translation();
}

void show_pcgrpdesc ( PCGRPDESC *g )
{
	int i;
	
	printf ( "prime        : %4d\n", g->prime );
	printf ( "num_gen      : %4d\n", g->num_gen );
	printf ( "group_card   : %4d\n", g->group_card );
	printf ( "max_id       : %4d\n", g->max_id );
	printf ( "min_gen      : %4d\n", g->min_gen );
	if ( g->group_name[0] != '\0' )
		printf ( "group name   : %s\n",  g->group_name );
	for ( i = 0; i < g->num_gen; i++ )
		printf ( "g_max[%1d] : %4d, g_ideal[%1d] : %4d \n",
			i, g->g_max[i], i, g->g_ideal[i] );
	printf ( "gen	     : [" );
	for ( i = 0; i < g->num_gen; i++ ) {
		printf ( "%s", g->gen[i] );
		if ( i != g->num_gen-1 )
			printf ( "," );
		else
			printf ( "]\n" );
	}
	printf ( "\n" );
	for ( i = 0; i < g->num_gen; i++ )
		printf ( "pc_weight[%1d]  : %3d\n", i, g->pc_weight[i] );
	printf ( "exp_p_class    : %4d\n", g->exp_p_class );
	print_gr_relations ( g );
}

void show_grpring ( GRPRING *gr )
{
	int i;
	
	puts ( "\nfiltration :" );
	for ( i = 0; i <= gr->g->max_id; i++ ) {
		printf ( "     filtration[%1d].i_start : %4d\n", i, gr->filtration[i].i_start );
		printf ( "     filtration[%1d].i_end : %4d\n", i, gr->filtration[i].i_end );
		printf ( "     filtration[%1d].i_dim : %4d\n", i, gr->filtration[i].i_dim );
	}
/*	puts ( "\nn_monoms:" );
	for ( i = 0; i < gr->g->group_card; i++ ) {
		printf ( "n_monom[%1d] : ", i );
		n_monom_write ( i );
		printf ( "\n" );
	}
	puts ( "\nc_monoms:" );
	for ( i = 0; i < gr->g->group_card; i++ ) {
		printf ( "c_monom[%1d] : ", i );
		c_monom_write ( C_MONOM[i] );
		printf ( "\n" );
	}
	puts ( "\nel_nums:" );
	for ( i = 0; i < gr->g->group_card; i++ )
		printf ( "el_num[%1d] : %3d\n", i, gr->el_num[i] );
	puts ( "\nngen_vecs:" );
	for ( i = 0; i < gr->g->num_gen; i++ ) {
		printf ( "ngen_vec[%1d] :", i );
		n_group_write ( gr->ngen_vec[i], gr->g->max_id );
	}
	for ( i = 0; i < gr->g->group_card; i++ ) {
		for ( j = 0; j < gr->g->group_card; j++ )
			printf ( "%3d", gr->[i][j] );
		printf ( "\n" );
	} */
}

/* end of module grpring  */

