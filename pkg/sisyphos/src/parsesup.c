/********************************************************************/
/*  Module        : Parsing supplementary routines                  */
/*                                                                  */
/*  Description :                                                   */
/*     Supplies routines needed during parsing.                     */
/*                                                                  */
/********************************************************************/

/* 	$Id: parsesup.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: parsesup.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.5  1996/03/19 12:57:42  pluto
 * 	Changed 'g_s_mula_gre' and 'g_s_mulb_gre' to handle multiplication
 * 	with zero correctly.
 *
 * 	Revision 3.3  1995/08/23 09:57:57  pluto
 * 	'.' operator now returns monoms of Jennings basis when applied to
 * 	elements of type 'group ring'.
 *
 * 	Revision 3.2  1995/08/10 11:54:48  pluto
 * 	Added routines to deal with gmodule and cohomology structures.
 *
 * 	Revision 3.1  1995/06/29 09:53:39  pluto
 * 	Moved 'code' routines to 'siscode.c'.
 * 	Corrected bug in 'copy_list' concerning group elements.
 *
 * 	Revision 3.0  1995/06/23 10:00:01  pluto
 * 	New revision corresponding to sisyphos 0.8.
 * 	Added support functions for new data types.
 *
 * Revision 1.2  1995/01/05  16:59:40  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: parsesup.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include <ctype.h>
#include "aglobals.h"
#include "fdecla.h"
#include "graut.h"
#include "aut.h"
#include "pc.h"
#include "parsesup.h"
#include "grpring.h"
#include "gmodule.h"
#include "cohomol.h"
#include "storage.h"
#include "siscode.h"
#include "error.h"

typedef struct action {
	TYPE type;
	void (*(*rout)(void*,void*));
} ACTION;

extern int cut, fend, prime;
extern PCGRPDESC *group_desc;
extern int bperelem;
extern FILE *out_hdl;
extern DSTYLE displaystyle;

VEC gr_invers				_(( VEC elem, int mod_id ));
void copy_list 			_(( LISTP *src, LISTP *dest, int perm ));
void copy_gmodule             _(( GMODULE *src, GMODULE *dest, int perm ));
void copy_cohomology          _(( COHOMOLOGY *src, COHOMOLOGY *dest,
						    int perm ));
void show_aggrpdesc			_(( AGGRPDESC *g ));
OPTION display_basis = STANDARD_BASIS;
static ACTION ***act_table;

void init_act_table (void)
{
	int i, j, k;
	
	/* create empty table */
	act_table = ARRAY ( MAXOPERANDS, ACTION** );
	for ( i = 0; i < MAXOPERANDS; i++ ) {
		act_table[i] = ARRAY ( MAXTYPES, ACTION* );
		for ( j = 0; j < MAXTYPES; j++ ) {
			act_table[i][j] = ARRAY ( MAXTYPES, ACTION );
			for ( k = 0; k < MAXTYPES; k++ ) {
				act_table[i][j][k].type = NOTYPE;
				act_table[i][j][k].rout = NULL;
			}
		}
	}
	
	/* initialize */
	act_table[O_ADD][INT][INT].type = INT;
	act_table[O_ADD][INT][INT].rout = g_add_int;
	act_table[O_ADD][INT][GRELEMENT].type = GRELEMENT;
	act_table[O_ADD][INT][GRELEMENT].rout = g_s_adda_gre;
	act_table[O_ADD][GRELEMENT][INT].type = GRELEMENT;
	act_table[O_ADD][GRELEMENT][INT].rout = g_s_addb_gre;
	act_table[O_ADD][GRELEMENT][GRELEMENT].type = GRELEMENT;
	act_table[O_ADD][GRELEMENT][GRELEMENT].rout = g_add_gre;
	act_table[O_ADD][VECTORSPACE][VECTORSPACE].type = VECTORSPACE;
	act_table[O_ADD][VECTORSPACE][VECTORSPACE].rout = g_add_vs;
	act_table[O_ADD][GMODREC][GMODREC].type = GMODREC;
	act_table[O_ADD][GMODREC][GMODREC].rout = g_add_module;

	act_table[O_SUB][INT][INT].type = INT;
	act_table[O_SUB][INT][INT].rout = g_sub_int;
	act_table[O_SUB][INT][GRELEMENT].type = GRELEMENT;
	act_table[O_SUB][INT][GRELEMENT].rout = g_s_suba_gre;
	act_table[O_SUB][GRELEMENT][INT].type = GRELEMENT;
	act_table[O_SUB][GRELEMENT][INT].rout = g_s_subb_gre;
	act_table[O_SUB][GRELEMENT][GRELEMENT].type = GRELEMENT;
	act_table[O_SUB][GRELEMENT][GRELEMENT].rout = g_sub_gre;

	act_table[O_MUL][INT][INT].type = INT;
	act_table[O_MUL][INT][INT].rout = g_mul_int;
	act_table[O_MUL][INT][GRELEMENT].type = GRELEMENT;
	act_table[O_MUL][INT][GRELEMENT].rout = g_s_mula_gre;
	act_table[O_MUL][GRELEMENT][INT].type = GRELEMENT;
	act_table[O_MUL][GRELEMENT][INT].rout = g_s_mulb_gre;
	act_table[O_MUL][GRELEMENT][GRELEMENT].type = GRELEMENT;
	act_table[O_MUL][GRELEMENT][GRELEMENT].rout = g_mul_gre;
	act_table[O_MUL][VECTORSPACE][VECTORSPACE].type = VECTORSPACE;
	act_table[O_MUL][VECTORSPACE][VECTORSPACE].rout = g_mul_vs;
	act_table[O_MUL][GROUPEL][GROUPEL].type = GROUPEL;
	act_table[O_MUL][GROUPEL][GROUPEL].rout = g_mul_gel;
	act_table[O_MUL][SGRHOMREC][SGRHOMREC].type = SGRHOMREC;
	act_table[O_MUL][SGRHOMREC][SGRHOMREC].rout = g_mul_graut;
	act_table[O_MUL][SHOMREC][SHOMREC].type = SHOMREC;
	act_table[O_MUL][SHOMREC][SHOMREC].rout = g_mul_aut;
	act_table[O_MUL][GMODREC][GMODREC].type = GMODREC;
	act_table[O_MUL][GMODREC][GMODREC].rout = g_mul_module;

	act_table[O_DIV][INT][INT].type = INT;
	act_table[O_DIV][INT][INT].rout = g_div_int;
	act_table[O_DIV][INT][GRELEMENT].type = GRELEMENT;
	act_table[O_DIV][INT][GRELEMENT].rout = g_s_diva_gre;
	act_table[O_DIV][GRELEMENT][INT].type = GRELEMENT;
	act_table[O_DIV][GRELEMENT][INT].rout = g_s_divb_gre;
	act_table[O_DIV][GRELEMENT][GRELEMENT].type = GRELEMENT;
	act_table[O_DIV][GRELEMENT][GRELEMENT].rout = g_div_gre;

	act_table[O_UMI][INT][INT].type = INT;
	act_table[O_UMI][INT][INT].rout = g_umi_int;
	act_table[O_UMI][GRELEMENT][INT].type = GRELEMENT;
	act_table[O_UMI][GRELEMENT][INT].rout = g_umi_gre;
	
	act_table[O_EXP][INT][INT].type = INT;
	act_table[O_EXP][INT][INT].rout = g_exp_int;
	act_table[O_EXP][GRELEMENT][INT].type = GRELEMENT;
	act_table[O_EXP][GRELEMENT][INT].rout = g_exp_gre;
	act_table[O_EXP][VECTORSPACE][INT].type = VECTORSPACE;
	act_table[O_EXP][VECTORSPACE][INT].rout = g_exp_vs;
	act_table[O_EXP][GROUPEL][INT].type = GROUPEL;
	act_table[O_EXP][GROUPEL][INT].rout = g_exp_gel;
	act_table[O_EXP][SGRHOMREC][INT].type = SGRHOMREC;
	act_table[O_EXP][SGRHOMREC][INT].rout = g_exp_graut;
	act_table[O_EXP][SHOMREC][INT].type = SHOMREC;
	act_table[O_EXP][SHOMREC][INT].rout = g_exp_aut;

	act_table[O_LIE][INT][INT].type = INT;
	act_table[O_LIE][INT][INT].rout = g_lie_int;
	act_table[O_LIE][INT][GRELEMENT].type = GRELEMENT;
	act_table[O_LIE][INT][GRELEMENT].rout = g_s_lie_gre;
	act_table[O_LIE][GRELEMENT][INT].type = GRELEMENT;
	act_table[O_LIE][GRELEMENT][INT].rout = g_s_lie_gre;
	act_table[O_LIE][GRELEMENT][GRELEMENT].type = GRELEMENT;
	act_table[O_LIE][GRELEMENT][GRELEMENT].rout = g_lie_gre;
	act_table[O_LIE][VECTORSPACE][VECTORSPACE].type = VECTORSPACE;
	act_table[O_LIE][VECTORSPACE][VECTORSPACE].rout = g_lie_vs;
	
}

int findcgen ( char *name, int len )
{
	char *new_name = ALLOCATE ( len+1 );
	int i;
	
	if ( group_desc != NULL ) {
		strncpy ( new_name, name, len );
		new_name[len] = '\0';
		for ( i = 0; i < len; i++ )
			if ( isupper ( new_name[i] ) )
				new_name[i] = tolower ( new_name[i] );
	
		for ( i = 0; i < group_desc->num_gen; i++ )
			if ( !strcmp ( group_desc->gen[i], new_name ) )
				return ( i );
	}
	return ( -1 );
}

void *g_mul_gre ( void *el1, void *el2 )
{
    return (void *)GROUP_MUL ( (VEC)el1, (VEC)el2, cut );
}

void *g_mul_graut ( void *el1, void *el2 )
{
    return (void *)gr_concatenate ( (SGRHOM *)el1, (SGRHOM *)el2 );
}

void *g_mul_aut ( void *el1, void *el2 )
{
    return (void *)aut_concatenate ( (SHOM *)el1, (SHOM *)el2 );
}

void *g_add_module ( void *el1, void *el2 )
{
    return (void *)gm_sum ( (GMODULE *)el1, (GMODULE *)el2 );
}

void *g_mul_module ( void *el1, void *el2 )
{
    return (void *)tensor_prod ( (GMODULE *)el1, (GMODULE *)el2, FALSE );
}

void *g_exp_gre ( void *el1, void *el2 )
{
	int *pot = (int *)el2;
	VEC res;
	
	if ( *pot < 0 ) {
		res = group_exp ( (VEC)el1, -*pot, cut );
		res = gr_invers ( res, cut );
	}
	else 
		res = group_exp ( (VEC)el1, *pot, cut );
	return (void *)res;
}

void *g_exp_graut ( void *el1, void *el2 )
{
	int *pot = (int *)el2;
	SGRHOM *res;
	
	if ( *pot < 0 ) {
		res = gr_exp_concatenate ( (SGRHOM *)el1, -*pot );
		res = gr_inv_concatenate ( res );
	}
	else 
		res = gr_exp_concatenate ( (SGRHOM *)el1, *pot );
	return (void *)res;
}

void *g_exp_aut ( void *el1, void *el2 )
{
	int *pot = (int *)el2;
	SHOM *res;
	
	if ( *pot < 0 ) {
		res = aut_exp_concatenate ( (SHOM *)el1, -*pot );
		res = aut_inv_concatenate ( res );
	}
	else 
		res = aut_exp_concatenate ( (SHOM *)el1, *pot );
	return (void *)res;
}

void *g_add_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	
	copy_vector ( (VEC)el2, res, fend );
	ADD_VECTOR ( (VEC)el1, res, fend );
	return (void *)res;
}

void *g_sub_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	
	copy_vector ( (VEC)el2, res, fend );
	SUBA_VECTOR ( (VEC)el1, res, fend );
	return (void *)res;
}

void *g_div_gre ( void *el1, void *el2 )
{
	VEC help = (VEC)el2;
	
	help = gr_invers ( help, cut );
	if ( help == NULL )
		return ( NULL );
	return (void *)GROUP_MUL ( (VEC)el1, help, cut );
}

void *g_umi_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	
	copy_vector ( (VEC)el1, res, fend );
	SMUL_VECTOR ( prime-1, res, fend );
	return (void *)res;
}

void *g_lie_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	VEC help;
	
	help = GROUP_MUL ( (VEC)el1, (VEC)el2, cut );
	copy_vector ( help, res, fend );
	help = GROUP_MUL ( (VEC)el2, (VEC)el1, cut );
	SUBB_VECTOR ( help, res, fend );
	return (void *)res;
}

void *g_s_mula_gre ( void *el1, void *el2 )
{
	VEC res = CALLOCATE ( fend );
	int *val = (int *)el1;
	
	if ( (*val) != 0 ) {
		copy_vector ( (VEC)el2, res, fend );
		SMUL_VECTOR ( (*val) % prime, res, fend );
	}
	return (void *)res;
}

void *g_s_mulb_gre ( void *el1, void *el2 )
{
	VEC res = CALLOCATE ( fend );
	int *val = (int *)el2;
	
	if ( (*val) != 0 ) {
		copy_vector ( (VEC)el1, res, fend );
		SMUL_VECTOR ( (*val) % prime, res, fend );
	}
	return (void *)res;
}

void *g_s_diva_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	int *val = (int *)el1;
	
	copy_vector ( (VEC)el2, res, fend );
	*val = fp_inv ( (*val) % prime );
	SMUL_VECTOR ( *val, res, fend );
	return (void *)res;
}

void *g_s_divb_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	int *val = (int *)el2;
	
	copy_vector ( (VEC)el1, res, fend );
	*val = fp_inv ( (*val) % prime );
	SMUL_VECTOR ( *val, res, fend );
	return (void *)res;
}

void *g_s_adda_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	int *val = (int *)el1;
	
	copy_vector ( (VEC)el2, res, fend );
	res[0] = fp_add ( res[0], (*val) % prime );
	return (void *)res;
}

void *g_s_addb_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	int *val = (int *)el2;
	
	copy_vector ( (VEC)el1, res, fend );
	res[0] = fp_add ( res[0], (*val) % prime );
	return (void *)res;
}

void *g_s_suba_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	int *val = (int *)el1;
	
	copy_vector ( (VEC)el2, res, fend );
	SMUL_VECTOR ( prime-1, res, fend );
	res[0] = fp_add ( res[0], (*val) % prime );
	return (void *)res;
}

void *g_s_subb_gre ( void *el1, void *el2 )
{
	VEC res = ALLOCATE ( fend );
	int *val = (int *)el2;
	
	copy_vector ( (VEC)el1, res, fend );
	*val = *val % prime;
	res[0] = fp_add ( res[0], prime - (*val) );
	return (void *)res;
}

void *g_s_lie_gre ( void *el1, void *el2 )
{
	return (void *)CALLOCATE ( fend );
}

void *g_mul_gel ( void *el1, void *el2 )
{
	return (void *)ge_mul ( (GE *)el1, (GE *)el2 );
}

void *g_exp_gel ( void *el1, void *el2 )
{
	int *pot = (int *)el2;
	GE *res;
	
	res = ge_exp ( (GE *)el1, *pot );
	return (void *)res;
}

void *g_mul_int ( void *el1, void *el2 )
{
	int *res = ALLOCATE ( sizeof ( int ) );
	int *v1 = (int *)el1;
	int *v2 = (int *)el2;
	
	*res = (*v1)*(*v2);
	return (void *)res;
}

void *g_exp_int ( void *el1, void *el2 )
{
	int *res = ALLOCATE ( sizeof ( int ) );
	int *v1 = (int *)el1;
	int *v2 = (int *)el2;
	int pow = (*v2) > 0 ? *v2 : -(*v2);
	int i;
	
	*res = 1;
	for ( i = 0; i < pow; i++ )
		*res *= (*v1);
	if ( (*v2) < 0 ) {
		if ( (*res) == 0 ) {
			set_error ( DIVISION_BY_ZERO );
			return ( NULL );
		}
		*res = 1 / (*res);
	}
	return (void *)res;
}

void *g_add_int ( void *el1, void *el2 )
{
	int *res = ALLOCATE ( sizeof ( int ) );
	int *v1 = (int *)el1;
	int *v2 = (int *)el2;
	
	*res = (*v1)+(*v2);
	return (void *)res;
}

void *g_sub_int ( void *el1, void *el2 )
{
	int *res = ALLOCATE ( sizeof ( int ) );
	int *v1 = (int *)el1;
	int *v2 = (int *)el2;
	
	*res = (*v1)-(*v2);
	return (void *)res;
}

void *g_div_int ( void *el1, void *el2 )
{
	int *res = ALLOCATE ( sizeof ( int ) );
	int *v1 = (int *)el1;
	int *v2 = (int *)el2;
	
	if ( (*v2) == 0 ) {
		set_error ( DIVISION_BY_ZERO );
		return NULL;
	}
	*res = (*v1)/(*v2);
	return (void *)res;
}


void *g_umi_int ( void *el1, void *el2 )
{
	int *res = ALLOCATE ( sizeof ( int ) );
	int *v1 = (int *)el1;
	
	*res = -(*v1);
	return (void *)res;
}

void *g_lie_int ( void *el1, void *el2 )
{
	return (void *)CALLOCATE ( sizeof ( int ) );
}

void *g_mul_vs ( void *el1, void *el2 )
{
	return (void *)meet_space ( (SPACE *)el1, (SPACE *)el2 );
}

void *g_add_vs ( void *el1, void *el2 )
{
	return (void *)join_space ( (SPACE *)el1, (SPACE *)el2 );
}

void *g_exp_vs ( void *el1, void *el2 )
{
	return NULL;
}

void *g_lie_vs ( void *el1, void *el2 )
{
	return (void *)s_lie_prod ( (SPACE *)el1, (SPACE *)el2 );
}

GENVAL *galloc ( TYPE of_type )
{
	GENVAL *newexpr;
	
	newexpr = (GENVAL *)tallocate ( sizeof ( GENVAL ) );
	
	switch ( newexpr->exptype = of_type ) {
		case INT :
				newexpr->pval = tcallocate ( sizeof(int) );
				break;
		case GROUP :
				newexpr->pval = tcallocate ( sizeof(GRPDSC) );
				break;
		case PCGROUP :
				newexpr->pval = tcallocate ( sizeof(PCGRPDESC) );
				break;
		case AGGROUP :
				newexpr->pval = tcallocate ( sizeof(AGGRPDESC) );
				break;
		case GROUPRING:
				newexpr->pval = tcallocate ( sizeof(GRPRING) );
				break;
		case GRELEMENT:
				newexpr->pval = tcallocate ( fend );
				break;
		case GROUPEL:
				newexpr->pval = tcallocate ( sizeof ( GE ) );
				break;
		case VECTORSPACE:
				newexpr->pval = tcallocate ( sizeof(SPACE) );
				break;
		case DLIST:
				newexpr->pval = tcallocate ( sizeof(LISTP) );
				break;
		case HOMREC:
				newexpr->pval = tcallocate ( sizeof(HOM) );
				break;
		case GRHOMREC:
				newexpr->pval = tcallocate ( sizeof(GRHOM) );
				break;
		case SGRHOMREC:
				newexpr->pval = tcallocate ( sizeof(SGRHOM) );
				break;
		case SHOMREC:
				newexpr->pval = tcallocate ( sizeof(SHOM) );
				break;
		case GMODREC:
				newexpr->pval = tcallocate ( sizeof(GMODULE) );
				break;
		case COHOMOLREC:
				newexpr->pval = tcallocate ( sizeof(COHOMOLOGY) );
				break;
		case NSTRING:
				newexpr->pval = NULL;
				break;
		default :
				newexpr->pval = NULL;
	}
	return ( newexpr );
}

GENVAL *gpermalloc ( TYPE of_type )
{
	GENVAL *newexpr;
	
	newexpr = (GENVAL *)allocate ( sizeof ( GENVAL ) );
	
	switch ( newexpr->exptype = of_type ) {
		case INT :
				newexpr->pval = callocate ( sizeof(int) );
				break;
		case GROUP :
				newexpr->pval = callocate ( sizeof(GRPDSC) );
				break;
		case PCGROUP :
				newexpr->pval = callocate ( sizeof(PCGRPDESC) );
				break;
		case AGGROUP :
				newexpr->pval = callocate ( sizeof(AGGRPDESC) );
				break;
		case GROUPRING:
				newexpr->pval = callocate ( sizeof(GRPRING) );
				break;
		case GRELEMENT:
				newexpr->pval = callocate ( fend );
				break;
		case GROUPEL:
				newexpr->pval = callocate ( sizeof ( GE ) );
				break;
		case VECTORSPACE :
				newexpr->pval = callocate ( sizeof(SPACE) );
				break;
		case DLIST:
				newexpr->pval = callocate ( sizeof(LISTP) );
				break;
		case HOMREC:
				newexpr->pval = callocate ( sizeof(HOM) );
				break;
		case GRHOMREC:
				newexpr->pval = callocate ( sizeof(GRHOM) );
				break;
		case SGRHOMREC:
				newexpr->pval = callocate ( sizeof(SGRHOM) );
				break;
		case SHOMREC:
				newexpr->pval = callocate ( sizeof(SHOM) );
				break;
		case GMODREC:
				newexpr->pval = callocate ( sizeof(GMODULE) );
				break;
		case COHOMOLREC:
				newexpr->pval = callocate ( sizeof(COHOMOLOGY) );
				break;
		case NSTRING:
				newexpr->pval = NULL;
				break;
		default :
				newexpr->pval = NULL;
	}
	return ( newexpr );
}


GENVAL *do_op ( GENVAL *expr1, GENVAL *expr2, OPTYPE operand )
{
	GENVAL *rexpr;
	TYPE ctype, op2type;

	if ( expr2 == NULL )
		op2type = INT;
	else
		op2type = expr2->exptype;
	if ( (ctype = act_table[operand][expr1->exptype][op2type].type) != NOTYPE ) {
		rexpr = tallocate ( sizeof ( GENVAL ) );
		rexpr->exptype = ctype;
		rexpr->pval = (*act_table[operand][expr1->exptype][op2type].rout)
			( expr1->pval, (expr2 == NULL) ? NULL : expr2->pval );
		return ( (rexpr->pval == NULL) ? NULL : rexpr  );
	}
	return ( NULL );
}

GENVAL *code_to_expr ( LISTP* intlist )
{
	GENVAL *rexpr;
	DYNLIST p;
	
	if ( intlist == NULL )
		return ( NULL );
	
	p = intlist->first;
	rexpr = tallocate ( sizeof ( GENVAL ) );
	rexpr->exptype = *(int *)p->value.gv;
	switch ( rexpr->exptype ) {
		case PCGROUP:
			rexpr->pval = code_to_pcgroup ( p->next );
			break;
		case HOMREC:
			rexpr->pval = code_to_hom ( p->next );
			break;
		case GRHOMREC:
			rexpr->pval = code_to_grhom ( p->next );
			break;
		case GMODREC:
			rexpr->pval = code_to_gmodule ( p->next );
			break;
		case COHOMOLREC:
			rexpr->pval = code_to_cohomology ( p->next );
			break;
		default:
			set_error ( WRONG_TYPE );
	}
	return ( rexpr );
}

void expr_to_code ( GENVAL *expr )
{
	switch ( expr->exptype ) {
		case PCGROUP:
			pcgroup_to_code ( (PCGRPDESC *)expr->pval, TRUE );
			break;
		case HOMREC:
			hom_to_code ( (HOM *)expr->pval );
			break;
		case GRHOMREC:
			grhom_to_code ( (GRHOM *)expr->pval );
			break;
		case GMODREC:
			gmodule_to_code ( (GMODULE *)expr->pval, TRUE );
			break;
		case COHOMOLREC:
			cohomology_to_code ( (COHOMOLOGY *)expr->pval );
			break;
		default:
			set_error ( WRONG_TYPE );
	}
}

void assign_symbol ( void **p, GENVAL *expr )
{
	GE *gs, *gd;

	*p = gpermalloc ( expr->exptype );

	switch ( expr->exptype ) {
		case INT:
			*((int *)(*p)) = *((int *)expr->pval);
			break;
		case GROUP:
			copy_group ( (GRPDSC *)expr->pval, (GRPDSC *)(*p), TRUE );
			break;
		case PCGROUP:
			copy_pcgroup ( (PCGRPDESC *)expr->pval, (PCGRPDESC *)(*p), TRUE, NULL );
			break;
		case AGGROUP:
			copy_aggroup ( (AGGRPDESC *)expr->pval, (AGGRPDESC *)(*p), TRUE, NULL );
			break;
		case GROUPRING:
			copy_grpring ( (GRPRING *)expr->pval, (GRPRING *)(*p), TRUE );
			break;
		case GRELEMENT:
			copy_vector ( (VEC)expr->pval, (VEC)(*p), fend );			
			break;
		case GROUPEL:
		     gd = (GE *)(*p); 
			gs = (GE *)expr->pval;
			gd->g = gs->g;
			gd->el = allocate ( gs->g->num_gen );
			copy_vector ( gs->el, gd->el, gs->g->num_gen );			
			break;
		case VECTORSPACE:
			copy_space ( (SPACE *)expr->pval, (SPACE *)(*p), TRUE );
			break;
		case DLIST:
			copy_list ( (LISTP *)expr->pval, (LISTP *)(*p), TRUE );			
			break;
		case HOMREC:
			copy_hom ( (HOM *)expr->pval, (HOM *)(*p), TRUE, NULL );			
			break;
		case GRHOMREC:
			copy_grhom ( (GRHOM *)expr->pval, (GRHOM *)(*p), TRUE );			
			break;
		case SGRHOMREC:
			copy_sgrhom ( (SGRHOM *)expr->pval, (SGRHOM *)(*p), TRUE );			
			break;
		case SHOMREC:
			copy_shom ( (SHOM *)expr->pval, (SHOM *)(*p), TRUE );			
			break;
		case GMODREC:
			copy_gmodule ( (GMODULE *)expr->pval, (GMODULE *)(*p), TRUE );			
			break;
		case COHOMOLREC:
			copy_cohomology ( (COHOMOLOGY *)expr->pval, (COHOMOLOGY *)(*p),
						   TRUE );			
			break;
	     case NSTRING:
		     (*p) = allocate ( strlen ( (char *)expr->pval ) + 1 );
			strcpy ( (char *)(*p), (char *)expr->pval );
			break;
		default:
			set_error ( WRONG_TYPE );
	}
}

void show_dlist ( LISTP *list )
{
	DYNLIST p;
	GENVAL gv;
	
	printf ( "[" );
	for ( p = list->first; p != NULL; p = p->next ) {
	    if ( p->type == INT )
		   printf ( "%d", *((int *)p->value.gv) );
	    else {
		   gv.exptype = p->type;
		   gv.pval = p->value.gv;
		   print_expr ( &gv );
	    }
	    if ( (p != list->last) && (p->type == INT) )
		   printf ( "," );
	}
	printf ( "]\n" );
}

void show_ge ( GE *ge )
{
    PCGRPDESC *old_pc_group;

    old_pc_group = group_desc;
    set_main_group ( ge->g );
    word_write ( ge->el );
    fprintf ( out_hdl, "\n" );
    set_main_group ( old_pc_group );
}

void *get_list_item ( LISTP *l, int lindex, int *ret_type )
{
    DYNLIST p;
    int i;

    for ( i=0, p = l->first; p != NULL; p=p->next, i++ )
	   if ( i == lindex ) {
		  *ret_type = p->type;
		  return ( p->value.gv );
	   }
    fprintf ( stderr, "ERROR: no element with index %d\n", lindex );
    set_error ( SPECIAL_ERROR );
    *ret_type = NOTYPE;
    return ( NULL );
}

void insert_list_item ( LISTP *l, int lindex, GENVAL *expr )
{
    DYNLIST p;
    int i;

    for ( i=0, p = l->first; p != NULL; p=p->next, i++ )
	   if ( i == lindex ) {
		  assign_symbol ( (void **)&p->value.gv, expr );
		  return;
	   }
    fprintf ( stderr, "ERROR: no element with index %d\n", lindex );
    set_error ( SPECIAL_ERROR );
}

void *get_record_field ( GENVAL *expr, int nfield, int *ret_type )
{
    int valid = TRUE;
    void *field = NULL;
    PCGRPDESC *g;
    GRPRING *gr;
    SHOM *hom;
    SGRHOM *grhom;
    SPACE *vs;

    switch ( expr->exptype ) {
    case PCGROUP:
	   g = (PCGRPDESC *)expr->pval;
	   if ( (g->num_gen <= nfield) || (nfield < -1) )
		  valid = FALSE;
	   else {
		  field = ALLOCATE ( sizeof ( GE ) );
		  ((GE *)field)->g = g;
		  ((GE *)field)->el = CALLOCATE ( g->num_gen );
		  if ( nfield != -1 )
			 copy_vector ( g->nom[nfield], ((GE *)field)->el, g->num_gen );
		  *ret_type = GROUPEL;
	   }
	   break;
    case GROUPRING:
	   gr = (GRPRING *)expr->pval;
	   g = gr->g;
	   if ( (g->group_card <= nfield) || (nfield < 0) )
		  valid = FALSE;
	   else {
		  field = CALLOCATE ( g->group_card );
		  ((VEC)field)[nfield] = 1;
		  *ret_type = GRELEMENT;
	   }
	   break;
    case SHOMREC:
	   hom = (SHOM *)expr->pval;
	   if ( hom->num_images <= nfield )
		  valid = FALSE;
	   else {
		  field = ALLOCATE ( sizeof ( GE ) );
		  ((GE *)field)->el = ALLOCATE ( hom->g->num_gen );
		  ((GE *)field)->g = hom->g;
		  copy_vector ( hom->image_list+nfield*hom->g->num_gen,
					 ((GE *)field)->el, hom->g->num_gen );
		  *ret_type = GROUPEL;
	   }
	   break;
    case SGRHOMREC:
	   grhom = (SGRHOM *)expr->pval;
	   if ( grhom->h->num_gen <= nfield )
		  valid = FALSE;
	   else {
		  field = ALLOCATE ( group_desc->group_card );
		  copy_vector ( grhom->image_list+nfield * group_desc->group_card,
					 (VEC)field, group_desc->group_card );
		  *ret_type = GRELEMENT;
	   }
	   break;
    case VECTORSPACE:
	   vs = (SPACE *)expr->pval;
	   if ( vs->dimension <= nfield )
		  valid = FALSE;
	   else {
		  field = CALLOCATE ( group_desc->group_card );
		  copy_vector ( vs->basis+nfield * vs->total_dim,
					 (VEC)field, vs->total_dim );
		  *ret_type = GRELEMENT;
	   }
	   break;
    default:
	   fprintf ( stderr, "ERROR: expression is not a record\n" );
	   set_error ( SPECIAL_ERROR );
    }
    if ( !valid ) {
	   *ret_type = NOTYPE;
	   return ( NULL );
    }
    return ( field );
}

VEC get_matrix ( LISTP *l, int *rows, int *cols )
{
    VEC m;
    DYNLIST p, q;
    LISTP *z;
    int i, j;
    char *old_top;
    
    if  ( !is_homogeneous_list ( l, DLIST ) )
	   return ( NULL );
    *rows = length_list ( l );
    if ( *rows == 0 )
	   return ( NULL );
    z = (LISTP *)l->first->value.gv;
    *cols = length_list ( z );
    old_top = GET_TOP();
    m = ALLOCATE ( (*rows) * (*cols) );
    for ( p = l->first,i=0; p != NULL; p = p->next,i++ ) {
	   z = (LISTP *)p->value.gv;
	   if ( length_list ( z ) != *cols ) {
		  SET_TOP ( old_top );
		  return ( NULL );
	   }
	   for ( q=z->first,j=0; q != NULL; q=q->next,j++ )
		  m[(*rows)*i+j] = (char)(*(int *)q->value.gv);
    }
    return ( m );
}
    
void print_expr ( GENVAL *expr )
{
	switch ( expr->exptype ) {
		case INT:
			printf ( "%d\n", *((int *)expr->pval) );
			break;
		case GROUP:
			show_grpdsc ( (GRPDSC *)expr->pval );
			break;
		case PCGROUP:
			show_pcgrpdesc ( (PCGRPDESC *)expr->pval );
			break;
		case AGGROUP:
			show_aggrpdesc ( (AGGRPDESC *)expr->pval );
			break;
		case GROUPRING:
			show_grpring ( (GRPRING *)expr->pval );
			break;
		case GRELEMENT:
			if ( display_basis == STANDARD_BASIS ) {
				PUSH_STACK();
				cgroup_write ( n_c_trans ( (VEC)expr->pval, cut ) );
				POP_STACK();
			}
			else
				n_group_write ( (VEC)expr->pval, cut );
			break;
		case GROUPEL:
		     show_ge ( (GE *)expr->pval );
			break;
		case VECTORSPACE:
			show_space ( (SPACE *)expr->pval );
			break;
		case DLIST:
			show_dlist ( (LISTP *)expr->pval );
			break;
		case HOMREC:
			show_hom ( (HOM *)expr->pval, "" );
			break;
		case GRHOMREC:
			gr_show_hom ( (GRHOM *)expr->pval );
			break;
		case SGRHOMREC:
			gr_show_shom ( (SGRHOM *)expr->pval );
			break;
		case SHOMREC:
			aut_show_hom ( (SHOM *)expr->pval );
			break;
		case GMODREC:
			show_gmodule ( (GMODULE *)expr->pval );
			break;
		case COHOMOLREC:
			show_cohomology ( (COHOMOLOGY *)expr->pval );
			break;
		case NSTRING:
			printf ( "%s\n", (char *)expr->pval );
			break;
		default:
			set_error ( WRONG_TYPE );
	}
}

void copy_space ( SPACE *src, SPACE *dest, int perm )
{
	int i;
	
	dest->total_dim = src->total_dim;
	dest->dimension = src->dimension;
	dest->b_flag = src->b_flag;
	i = src->total_dim * src->dimension;
	if ( perm )
		dest->basis = allocate ( i );
	else
		dest->basis = tallocate ( i );
	copy_vector ( src->basis, dest->basis, i );
}

int length_list ( LISTP *l )
{
    int len;
    DYNLIST p;

    for ( p = l->first, len=0; p != NULL; p = p->next,len++  );
    return ( len );
}
    
int is_homogeneous_list ( LISTP *l, TYPE t )
{
    DYNLIST p;

    for ( p = l->first; p != NULL; p = p->next )
	   if ( p->type != t )
		  return ( FALSE );
    return ( TRUE );
}
    
void copy_list ( LISTP *src, LISTP *dest, int perm )
{
	DYNLIST p, r;
	DYNLIST q = NULL;
	void (*(*usealloc)(long));
	GE *gs, *gd;

	r = NULL;
	for ( p = src->first; p != NULL; p = p->next ) {
		if ( perm )
		    usealloc = allocate;
		else
		    usealloc = tallocate;
		q = (*usealloc) ( sizeof ( dynlistitem ) );
		q->type = p->type;

		switch ( p->type ) {
		case INT:
		    q->value.gv = (*usealloc)( sizeof ( int ) ); 
		    *((int *)q->value.gv) = *((int *)p->value.gv);
		    break;
		case GROUP:
		    q->value.gv = (*usealloc)( sizeof ( GRPDSC ) ); 
		    copy_group ( (GRPDSC *)p->value.gv,
					  (GRPDSC *)q->value.gv, perm );
		    break;
		case PCGROUP:
		    q->value.gv = (*usealloc)( sizeof ( PCGRPDESC ) ); 
		    copy_pcgroup ( (PCGRPDESC *)p->value.gv, 
					    (PCGRPDESC *)q->value.gv, perm, NULL );
		    break;
		case AGGROUP:
		    q->value.gv = (*usealloc)( sizeof ( AGGRPDESC ) );
		    copy_aggroup ( (AGGRPDESC *)p->value.gv, 
					    (AGGRPDESC *)q->value.gv, perm, NULL );
		    break;
		case GROUPRING:
		    q->value.gv = (*usealloc)( sizeof ( GRPRING ) );
		    copy_grpring ( (GRPRING *)p->value.gv,
					    (GRPRING *)q->value.gv, perm );
		    break;
		case GRELEMENT:
		    q->value.gv = (*usealloc)( fend );
		    copy_vector ( (VEC)p->value.gv, (VEC)q->value.gv, fend );
		    break;
		case GROUPEL:
		    q->value.gv = (*usealloc)( sizeof(GE) );
		    gs = (GE *)p->value.gv; 
		    gd = (GE *)q->value.gv;
		    gd->g = gs->g;
		    gd->el = (*usealloc)( gs->g->num_gen );
		    copy_vector ( gs->el, gd->el, gs->g->num_gen );			
		    break;
		case VECTORSPACE:
		    q->value.gv = (*usealloc)( sizeof ( SPACE ) );
		    copy_space ( (SPACE *)p->value.gv, (SPACE *)q->value.gv, perm );
		    break;
		case DLIST:
		    q->value.gv = (*usealloc)( sizeof ( LISTP ) );
		    copy_list ( (LISTP *)p->value.gv, (LISTP *)q->value.gv, perm );
		    break;
		case HOMREC:
		    q->value.gv = (*usealloc)( sizeof ( HOM ) );
		    copy_hom ( (HOM *)p->value.gv, (HOM *)q->value.gv, perm, NULL );
		    break;
		case GRHOMREC:
		    q->value.gv = (*usealloc)( sizeof ( GRHOM ) );
		    copy_grhom ( (GRHOM *)p->value.gv, (GRHOM *)q->value.gv, perm );
		    break;
		case SGRHOMREC:
		    q->value.gv = (*usealloc)( sizeof ( SGRHOM ) );
		    copy_sgrhom ( (SGRHOM *)p->value.gv, 
					   (SGRHOM *)q->value.gv, perm );			
		    break;
		case SHOMREC:
		    q->value.gv = (*usealloc)( sizeof ( SHOM ) );
		    copy_shom ( (SHOM *)p->value.gv, (SHOM *)q->value.gv, perm );
		    break;
		case GMODREC:
		    q->value.gv = (*usealloc)( sizeof ( GMODULE ) );
		    copy_gmodule ( (GMODULE *)p->value.gv, (GMODULE *)q->value.gv, perm );
		    break;
		case COHOMOLREC:
		    q->value.gv = (*usealloc)( sizeof ( COHOMOLOGY ) );
		    copy_cohomology ( (COHOMOLOGY *)p->value.gv, (COHOMOLOGY *)q->value.gv, perm );
		    break;
	     case NSTRING:
		    q->value.gv = (*usealloc)( strlen ( (char *)p->value.gv ) + 1 );
		    strcpy ( (char *)q->value.gv, (char *)p->value.gv );
		    break;
		default:
		    set_error ( WRONG_TYPE );
		}

		if ( r == NULL )
			dest->first = r = q;
		else {
			r->next = q;
			r = q;
		}
	}
	dest->last = q;
}

node node_cpy ( node s, int perm )
{
	node d;
	
	if ( s == NULL ) 
		d = NULL;
	else {
		if ( perm )
			d = allocate ( sizeof ( rel_node ) );
		else
			d = tallocate ( sizeof ( rel_node ) );
		d->nodetype = s->nodetype;
		d->value = s->value;
		d->left = node_cpy ( s->left, perm );
		d->right = node_cpy ( s->right, perm ); 
	}
	return d;
}

void copy_group ( GRPDSC *src, GRPDSC *dest, int perm )
{
	int i;
	
	memcpy ( dest, src, sizeof ( GRPDSC ) );
	
	if ( perm ) {
		dest->rel_list = allocate ( dest->num_rel * sizeof ( node ) );
		dest->gen = allocate ( src->num_gen * sizeof ( char * ) );
		for ( i = 0; i < src->num_gen; i++ )
			dest->gen[i] = allocate ( strlen ( src->gen[i] )+1 );
		if ( src->pc_pres != NULL )
			dest->pc_pres = allocate ( sizeof ( PCGRPDESC ) );
		if ( src->isog != NULL )
			dest->isog = allocate ( sizeof ( HOM ) );
	}
	else {
		dest->rel_list = tallocate ( dest->num_rel * sizeof ( node ) );
		dest->gen = tallocate ( src->num_gen * sizeof ( char * ) );
		for ( i = 0; i < src->num_gen; i++ )
			dest->gen[i] = tallocate ( strlen ( src->gen[i] )+1 );
		if ( src->pc_pres != NULL )
			dest->pc_pres = tallocate ( sizeof ( PCGRPDESC ) );
		if ( src->isog != NULL )
			dest->isog = tallocate ( sizeof ( HOM ) );
	}
	for ( i = 0; i < dest->num_rel; i++ )
		dest->rel_list[i] = node_cpy ( src->rel_list[i], perm );
	for ( i = 0; i < src->num_gen; i++ )
		strcpy ( dest->gen[i], src->gen[i] );
	if ( src->pc_pres != NULL )
		copy_pcgroup ( src->pc_pres, dest->pc_pres, perm, NULL );
	if ( src->isog != NULL )
		if ( dest->pc_pres != NULL )
			copy_hom ( src->isog, dest->isog, perm, dest->pc_pres );
		else	
			copy_hom ( src->isog, dest->isog, perm, NULL );
}

void copy_pcgroup ( PCGRPDESC *src, PCGRPDESC *dest, int perm, HOM *autos )
{
	int i, cnr;

	memcpy ( dest, src, sizeof ( PCGRPDESC ) );
	
	cnr = ( src->num_gen * ( src->num_gen -1 ) ) >> 1;
	if ( perm ) {
		dest->gen = allocate ( src->num_gen * sizeof ( char * ) );
		dest->g_max = callocate ( src->num_gen * sizeof ( int ) );
		dest->g_ideal = callocate ( src->num_gen * sizeof ( int ) );
		dest->image = callocate ( src->num_gen * sizeof ( int ) );
		dest->pimage = callocate ( src->num_gen * sizeof ( int ) );
		dest->nom = callocate ( src->num_gen * sizeof ( PCELEM ) );
		dest->p_list = (ge_pair **)allocate ( src->num_gen * sizeof ( ge_pair *) );
		dest->p_len = (int *)allocate ( src->num_gen * sizeof ( int ) );
		dest->c_list = (ge_pair **)allocate ( cnr * sizeof ( ge_pair * ) );
		dest->c_len = (int *)allocate ( cnr * sizeof ( int ) );
		dest->pc_weight = allocate ( src->num_gen * sizeof ( int ) );
		dest->exp_p_lcs = allocate ( (src->exp_p_class+1) * sizeof ( FILT ) );
		dest->def_list = allocate ( src->num_gen * sizeof ( node ) );
		for ( i = 0; i < src->num_gen; i++ )
			dest->gen[i] = allocate ( strlen ( src->gen[i] )+1 );
	}
	else {
		dest->gen = tcallocate ( src->num_gen * sizeof ( char * ) );
		dest->g_max = tcallocate ( src->num_gen * sizeof ( int ) );
		dest->g_ideal = tcallocate ( src->num_gen * sizeof ( int ) );
		dest->image = tcallocate ( src->num_gen * sizeof ( int ) );
		dest->pimage = tcallocate ( src->num_gen * sizeof ( int ) );
		dest->nom = tcallocate ( src->num_gen * sizeof ( PCELEM ) );
		dest->p_list = (ge_pair **)tallocate ( src->num_gen * sizeof ( ge_pair *) );
		dest->p_len = (int *)tallocate ( src->num_gen * sizeof ( int ) );
		dest->c_list = (ge_pair **)tallocate ( cnr * sizeof ( ge_pair * ) );
		dest->c_len = (int *)tallocate ( cnr * sizeof ( int ) );
		dest->pc_weight = tallocate ( src->num_gen * sizeof ( int ) );
		dest->exp_p_lcs = tallocate ( (src->exp_p_class+1) * sizeof ( FILT ) );
		dest->def_list = tallocate ( src->num_gen * sizeof ( node ) );
		for ( i = 0; i < src->num_gen; i++ )
			dest->gen[i] = tallocate ( strlen ( src->gen[i] )+1 );
	}

	for ( i = 0; i < src->num_gen; i++ )
		dest->def_list[i] = node_cpy ( src->def_list[i], perm );

	/* zero_vector ( dest->group_name, 50 ); */
	for ( i = 0; i < src->num_gen; i++ )
		strcpy ( dest->gen[i], src->gen[i] );

	memcpy ( dest->g_max, src->g_max, src->num_gen * sizeof ( int ) );
	memcpy ( dest->g_ideal, src->g_ideal, src->num_gen * sizeof ( int ) );
	memcpy ( dest->image, src->image, src->num_gen * sizeof ( int ) );
	memcpy ( dest->pimage, src->pimage, src->num_gen * sizeof ( int ) );
	memcpy ( dest->p_len, src->p_len, src->num_gen * sizeof ( int ) );
	memcpy ( dest->c_len, src->c_len, cnr * sizeof ( int ) );
	memcpy ( dest->pc_weight, src->pc_weight, src->num_gen * sizeof ( int ) );
	memcpy ( dest->exp_p_lcs, src->exp_p_lcs, (src->exp_p_class+1) * sizeof ( FILT ) );

	for ( i = 0; i < dest->num_gen; i++ ) {
		if ( src->p_list[i] == NULL )
			dest->p_list[i] = NULL;
		else {
			if ( perm )
				dest->p_list[i] = allocate ( (dest->p_len[i]+1) * sizeof ( ge_pair ) );
			else
				dest->p_list[i] = tallocate ( (dest->p_len[i]+1) * sizeof ( ge_pair ) );
			memcpy ( dest->p_list[i], src->p_list[i], (dest->p_len[i]+1) * sizeof ( ge_pair ) );
		}
	}
	for ( i = 0; i < cnr; i++ ) {
		if ( src->c_list[i] == NULL )
			dest->c_list[i] = NULL;
		else {
			if ( perm )
				dest->c_list[i] = allocate ( (dest->c_len[i]+1) * sizeof ( ge_pair ) );
			else
				dest->c_list[i] = tallocate ( (dest->c_len[i]+1) * sizeof ( ge_pair ) );
			memcpy ( dest->c_list[i], src->c_list[i], (dest->c_len[i]+1) * sizeof ( ge_pair ) );
		}
	}
	for ( i = 0; i < dest->num_gen; i++ ) {
		if ( perm )
			dest->nom[i] = allocate ( dest->num_gen );
		else
			dest->nom[i] = tallocate ( dest->num_gen );
		memcpy ( dest->nom[i], src->nom[i], dest->num_gen );
	}
	if ( src->autg != NULL ) {
		if ( autos != NULL )
			dest->autg = autos;
		else {
			if ( perm ) 
				dest->autg = allocate ( sizeof ( HOM ) );
			else
				dest->autg = tallocate ( sizeof ( HOM ) );
			copy_hom ( src->autg, dest->autg, perm, dest );
		}
	}
}

int gep_len ( ge_pair *gep )
{
	int i;
	
	for ( i = 0; ;i++ )
		if ( gep[i].g == -1 )
			break;
	return ( i+1 );
}	
	
void copy_aggroup ( AGGRPDESC *src, AGGRPDESC *dest, int perm, HOM *autos )
{
	int i, cnr, len;

	memcpy ( dest, src, sizeof ( AGGRPDESC ) );
	
	cnr = ( src->num_gen * ( src->num_gen -1 ) ) >> 1;
	if ( perm ) {
		dest->gen = allocate ( src->num_gen * sizeof ( char * ) );
		dest->powers = callocate ( src->num_gen * sizeof ( int ) );
		dest->nom = callocate ( src->num_gen * sizeof ( PCELEM ) );
		dest->p_list = (ge_pair **)allocate ( src->num_gen * sizeof ( ge_pair *) );
		dest->p_len = (int *)allocate ( src->num_gen * sizeof ( int ) );
		dest->c_list = (ge_pair **)allocate ( cnr * sizeof ( ge_pair * ) );
		dest->c_len = (int *)allocate ( cnr * sizeof ( int ) );
		dest->conjugates = allocate ( cnr * sizeof ( ge_pair * ) );
		dest->avec = allocate ( src->num_gen * sizeof ( int ) );
		dest->elab_series = allocate ( (src->elab_length+1) * sizeof ( FILT ) );
		dest->def_list = allocate ( src->num_gen * sizeof ( GENDEF ) );
		for ( i = 0; i < src->num_gen; i++ )
			dest->gen[i] = allocate ( strlen ( src->gen[i] ) );
		if ( src->autg != NULL )
			dest->autg = allocate ( sizeof ( HOM ) );
	}
	else {
		dest->gen = tcallocate ( src->num_gen * sizeof ( char * ) );
		dest->powers = tcallocate ( src->num_gen * sizeof ( int ) );
		dest->nom = tcallocate ( src->num_gen * sizeof ( PCELEM ) );
		dest->p_list = (ge_pair **)tallocate ( src->num_gen * sizeof ( ge_pair *) );
		dest->p_len = (int *)tallocate ( src->num_gen * sizeof ( int ) );
		dest->c_list = (ge_pair **)tallocate ( cnr * sizeof ( ge_pair * ) );
		dest->c_len = (int *)tallocate ( cnr * sizeof ( int ) );
		dest->conjugates = tallocate ( cnr * sizeof ( ge_pair * ) );
		dest->avec = tallocate ( src->num_gen * sizeof ( int ) );
		dest->elab_series = tallocate ( (src->elab_length+1) * sizeof ( FILT ) );
		dest->def_list = tallocate ( src->num_gen * sizeof ( GENDEF ) );
		for ( i = 0; i < src->num_gen; i++ )
			dest->gen[i] = tallocate ( strlen ( src->gen[i] ) );
		if ( src->autg != NULL )
			dest->autg = tallocate ( sizeof ( HOM ) );
	}
	
	for ( i = 0; i < src->num_gen; i++ )
		strcpy ( dest->gen[i], src->gen[i] );

	memcpy ( dest->powers, src->powers, src->num_gen * sizeof ( int ) );
	memcpy ( dest->p_len, src->p_len, src->num_gen * sizeof ( int ) );
	memcpy ( dest->c_len, src->c_len, cnr * sizeof ( int ) );
	memcpy ( dest->avec, src->avec, src->num_gen * sizeof ( int ) );
	memcpy ( dest->elab_series, src->elab_series, (src->elab_length+1) * sizeof ( FILT ) );
	memcpy ( dest->def_list, src->def_list, src->num_gen * sizeof ( GENDEF ) );

	for ( i = 0; i < dest->num_gen; i++ ) {
		if ( src->p_list[i] == NULL )
			dest->p_list[i] = NULL;
		else {
			if ( perm )
				dest->p_list[i] = allocate ( (dest->p_len[i]+1) * sizeof ( ge_pair ) );
			else
				dest->p_list[i] = tallocate ( (dest->p_len[i]+1) * sizeof ( ge_pair ) );
			memcpy ( dest->p_list[i], src->p_list[i], (dest->p_len[i]+1) * sizeof ( ge_pair ) );
		}
	}
	for ( i = 0; i < cnr; i++ ) {
		if ( src->c_list[i] == NULL )
			dest->c_list[i] = NULL;
		else {
			if ( perm )
				dest->c_list[i] = allocate ( (dest->c_len[i]+1) * sizeof ( ge_pair ) );
			else
				dest->c_list[i] = tallocate ( (dest->c_len[i]+1) * sizeof ( ge_pair ) );
			memcpy ( dest->c_list[i], src->c_list[i], (dest->c_len[i]+1) * sizeof ( ge_pair ) );
		}

		len = gep_len ( src->conjugates[i] );
		if ( perm )
			dest->conjugates[i] = allocate ( len * sizeof ( ge_pair ) );
		else
			dest->conjugates[i] = tallocate ( len * sizeof ( ge_pair ) );
		memcpy ( dest->conjugates[i], src->conjugates[i], len * sizeof ( ge_pair ) );
	}
	for ( i = 0; i < dest->num_gen; i++ ) {
		if ( perm )
			dest->nom[i] = allocate ( dest->num_gen );
		else
			dest->nom[i] = tallocate ( dest->num_gen );
		memcpy ( dest->nom[i], src->nom[i], dest->num_gen );
	}
	if ( autos != NULL )
		printf ( "automorphisms found !\n" );
	dest->autg = NULL;
}

void copy_grpring ( GRPRING *src, GRPRING *dest, int perm )
{
	int i;

	memcpy ( dest, src, sizeof ( GRPRING ) );
	
	
	if ( perm ) {
		dest->filtration = allocate ( (src->g->max_id + 1) * sizeof ( FILT ) );
		dest->c_monom = allocate ( src->g->group_card * sizeof ( PCELEM ) );
		dest->n_monom = allocate ( src->g->group_card * sizeof ( VEC ) );
		dest->ngen_vec = allocate ( src->g->num_gen * sizeof ( VEC ) );
		dest->el_num = allocate ( src->g->group_card * sizeof ( int ) );
		for ( i = 0; i < src->g->group_card; i++ ) {
			dest->c_monom[i] = allocate ( src->g->num_gen );
			dest->n_monom[i] = allocate ( src->g->num_gen );
		}
		for ( i = 0; i  < src->g->num_gen; i++ ) 
			dest->ngen_vec[i] = callocate ( src->g->group_card );
		dest->g = allocate ( sizeof ( PCGRPDESC ) );
	}
	else {
		dest->filtration = tallocate ( (src->g->max_id + 1) * sizeof ( FILT ) );
		dest->c_monom = tallocate ( src->g->group_card * sizeof ( PCELEM ) );
		dest->n_monom = tallocate ( src->g->group_card * sizeof ( VEC ) );
		dest->ngen_vec = tallocate ( src->g->num_gen * sizeof ( VEC ) );
		dest->el_num = tallocate ( src->g->group_card * sizeof ( int ) );
		for ( i = 0; i < src->g->group_card; i++ ) {
			dest->c_monom[i] = tallocate ( src->g->num_gen );
			dest->n_monom[i] = tallocate ( src->g->num_gen );
		}
		for ( i = 0; i  < src->g->num_gen; i++ ) 
			dest->ngen_vec[i] = tcallocate ( src->g->group_card );
		dest->g = tallocate ( sizeof ( PCGRPDESC ) );
	}
	
	memcpy ( dest->filtration, src->filtration, (src->g->max_id + 1) * sizeof ( FILT ) );
	memcpy ( dest->el_num, src->el_num, src->g->group_card * sizeof ( int ) );
	copy_pcgroup ( src->g, dest->g, perm, NULL );
	for ( i = 0; i < src->g->group_card; i++ ) {
		memcpy ( dest->c_monom[i], src->c_monom[i], src->g->num_gen );
		memcpy ( dest->n_monom[i], src->n_monom[i], src->g->num_gen );
	}
	for ( i = 0; i  < dest->g->num_gen; i++ ) 
		memcpy ( dest->ngen_vec[i], src->ngen_vec[i], src->g->group_card );

	dest->mul_table = src->mul_table;
	dest->jenn_table = src->jenn_table;
}

void copy_hom ( HOM *src, HOM *dest, int perm, PCGRPDESC *g )
{
	int i, j;
	int numgen;
	int hgens;
	
	memcpy ( dest, src, sizeof ( HOM ) );
	if ( src->auts == 0 && !src->elements )
		return;
	
	if ( g != NULL )
		dest->g = g;
	else {
		if ( perm )
			dest->g = allocate ( sizeof ( PCGRPDESC ) );
		else
			dest->g = tallocate ( sizeof ( PCGRPDESC ) );
		copy_pcgroup ( src->g, dest->g, perm, dest );
	}
	
	numgen = src->g->defs ? src->g->min_gen : src->g->num_gen;
	hgens = src->h == NULL ? numgen : src->h->num_gen;
	if ( perm ) {
		dest->aut_gens_dim = allocate ( (src->g->exp_p_class+1) * sizeof ( int ) );
		dest->out_gens_dim = allocate ( (src->g->exp_p_class+1) * sizeof ( int ) );
		dest->aut_gens = allocate ( (src->g->exp_p_class+1) * sizeof ( VEC* ) );
		if ( src->epimorphism != NULL )
			dest->epimorphism = allocate ( hgens * src->g->num_gen );
		for ( i = 1; i <= src->g->exp_p_class; i++ ) {
			dest->aut_gens[i] = allocate ( src->aut_gens_dim[i] * sizeof ( VEC ) );
			for ( j = 0; j < src->aut_gens_dim[i]; j++ )
				dest->aut_gens[i][j] = allocate ( src->g->num_gen * numgen );
		}
		if ( src->stabs != NULL ) {
			dest->stabs = allocate ( (src->g->max_id+1) * sizeof ( int* ) );
			for ( i = src->g->max_id; i > 1; i-- )
				dest->stabs[i] = callocate ( (src->aut_gens_dim[1]+1)*sizeof ( int ) );
		}
	}
	else {
		dest->aut_gens_dim = tallocate ( (src->g->exp_p_class+1) * sizeof ( int ) );
		dest->out_gens_dim = tallocate ( (src->g->exp_p_class+1) * sizeof ( int ) );
		dest->aut_gens = tallocate ( (src->g->exp_p_class+1) * sizeof ( VEC* ) );
		if ( src->epimorphism != NULL )
			dest->epimorphism = tallocate ( hgens * src->g->num_gen );
		for ( i = 1; i <= src->g->exp_p_class; i++ ) {
			dest->aut_gens[i] = tallocate ( src->aut_gens_dim[i] * sizeof ( VEC ) );
			for ( j = 0; j < src->aut_gens_dim[i]; j++ )
				dest->aut_gens[i][j] = tallocate ( src->g->num_gen * numgen);
		}	
		if ( src->stabs != NULL ) {
			dest->stabs = tallocate ( (src->g->max_id+1) * sizeof ( int* ) );
			for ( i = src->g->max_id; i > 1; i-- ) 
				dest->stabs[i] = tcallocate ( (src->aut_gens_dim[1]+1)*sizeof ( int ) );
		}
	}
	memcpy ( dest->aut_gens_dim, src->aut_gens_dim, (src->g->exp_p_class+1) * sizeof ( int ) );
	memcpy ( dest->out_gens_dim, src->out_gens_dim, (src->g->exp_p_class+1) * sizeof ( int ) );
	if ( src->epimorphism != NULL )
		memcpy ( dest->epimorphism, src->epimorphism,  hgens * src->g->num_gen );

	for ( i = 1; i <= src->g->exp_p_class; i++ ) {
		for ( j = 0; j < src->aut_gens_dim[i]; j++ )
			memcpy ( dest->aut_gens[i][j], src->aut_gens[i][j], src->g->num_gen * numgen);
	}
	if ( src->stabs != NULL )
		for ( i = src->g->max_id; i > 1; i-- )
			memcpy ( dest->stabs[i], src->stabs[i], (src->aut_gens_dim[1]+1)*sizeof ( int ) );
}

void copy_grhom ( GRHOM *src, GRHOM *dest, int perm )
{
	int i, j;
	int numgen, limit;
	int hgens;
	
	memcpy ( dest, src, sizeof ( GRHOM ) );
	if ( src->auts == 0  )
		return;
	limit = src->lift_limit;
	numgen = src->g->defs ? src->g->min_gen : src->g->num_gen;
	hgens = src->h == NULL ? numgen : src->h->num_gen;
	if ( perm ) {
		dest->aut_gens_dim = allocate ( limit * sizeof ( int ) );
		dest->out_gens_dim = allocate ( limit * sizeof ( int ) );
		dest->mod_grauts_gens_dim = allocate ( limit * sizeof ( int ) );
		dest->aut_gens = allocate ( limit * sizeof ( VEC* ) );
		
		if ( src->epimorphism != NULL )
			dest->epimorphism = allocate ( hgens * src->g->group_card );
		for ( i = 1; i < limit; i++ ) {
			dest->aut_gens[i] = allocate ( src->aut_gens_dim[i] * 
									 sizeof ( VEC ) );
			for ( j = 0; j < src->aut_gens_dim[i]; j++ )
				dest->aut_gens[i][j] = allocate ( src->g->group_card * 
										    numgen );
		}
	}
	else {
		dest->aut_gens_dim = tallocate ( limit * sizeof ( int ) );
		dest->out_gens_dim = tallocate ( limit * sizeof ( int ) );
		dest->mod_grauts_gens_dim = tallocate ( limit * sizeof ( int ) );
		dest->aut_gens = tallocate ( limit * sizeof ( VEC* ) );
		
		if ( src->epimorphism != NULL )
			dest->epimorphism = tallocate ( hgens * src->g->group_card );
		for ( i = 1; i < limit; i++ ) {
			dest->aut_gens[i] = tallocate ( src->aut_gens_dim[i] * 
									 sizeof ( VEC ) );
			for ( j = 0; j < src->aut_gens_dim[i]; j++ )
				dest->aut_gens[i][j] = tallocate ( src->g->group_card * 
										    numgen );
		}
	}
	memcpy ( dest->aut_gens_dim, src->aut_gens_dim, limit * sizeof ( int ) );
	memcpy ( dest->out_gens_dim, src->out_gens_dim, limit * sizeof ( int ) );
	memcpy ( dest->mod_grauts_gens_dim, src->mod_grauts_gens_dim,
		    limit * sizeof ( int ) );
	if ( src->epimorphism != NULL )
		memcpy ( dest->epimorphism, src->epimorphism,  hgens * src->g->group_card );

	for ( i = 1; i < limit; i++ ) {
		for ( j = 0; j < src->aut_gens_dim[i]; j++ )
			memcpy ( dest->aut_gens[i][j], src->aut_gens[i][j], src->g->group_card * numgen);
	}
}

void copy_sgrhom ( SGRHOM *src, SGRHOM *dest, int perm )
{
	int numgen;
	
	memcpy ( dest, src, sizeof ( SGRHOM ) );

	numgen = src->h->num_gen;

	if ( perm )
		dest->image_list = allocate ( numgen * group_desc->group_card );
	else 
		dest->image_list = tallocate ( numgen * group_desc->group_card );
	memcpy ( dest->image_list, src->image_list, numgen * group_desc->group_card  );
}

void copy_shom ( SHOM *src, SHOM *dest, int perm )
{
	int numgen, gnumgen;
	
	memcpy ( dest, src, sizeof ( SHOM ) );

	numgen = src->num_images;
	gnumgen = src->g->num_gen;

	if ( perm )
		dest->image_list = allocate ( numgen * gnumgen );
	else 
		dest->image_list = tallocate ( numgen * gnumgen );
	memcpy ( dest->image_list, src->image_list, numgen * gnumgen );
}

void copy_gmodule ( GMODULE *src, GMODULE *dest, int perm )
{
	int numgen;
	int dq, i;
	
	memcpy ( dest, src, sizeof ( GMODULE ) );

	numgen = src->g->num_gen;
	dq = src->dim * src->dim;

	if ( perm ) {
	    if ( !is_permanent ( src->g ) ) {
		   dest->g = allocate ( sizeof ( PCGRPDESC ) );
		   copy_pcgroup ( src->g, dest->g, perm, NULL );
	    }
	    dest->m = allocate ( numgen * sizeof ( VEC ) );
	    for ( i = 0; i < numgen; i++ )
		   dest->m[i] = allocate ( dq );
	}
	else {
	    dest->m = tallocate ( numgen * sizeof ( VEC ) );
	    for ( i = 0; i < numgen; i++ )
		   dest->m[i] = tallocate ( dq );
	}
	if ( src->echelon != NULL )
	    if ( perm ) {
		   dest->T = allocate ( dq );
		   dest->TI = allocate ( dq );
		   dest->echelon = allocate ( numgen * sizeof ( VEC ) );
		   for ( i = 0; i < numgen; i++ )
			  dest->echelon[i] = allocate ( dq );
	    }
	    else {
		   dest->T = tallocate ( dq );
		   dest->TI = tallocate ( dq );
		   dest->echelon = tallocate ( numgen * sizeof ( VEC ) );
		   for ( i = 0; i < numgen; i++ )
			  dest->echelon[i] = tallocate ( dq );
	    }

	for ( i = 0; i < numgen; i++ ) 
	    memcpy ( dest->m[i], src->m[i], dq  );
	if ( src->echelon != NULL ) {
	    for ( i = 0; i < numgen; i++ ) 
		   memcpy ( dest->echelon[i], src->echelon[i], dq  );
	    memcpy ( dest->T, src->T, dq );
	    memcpy ( dest->TI, src->TI, dq );
	}
}

void copy_cohomology ( COHOMOLOGY *src, COHOMOLOGY *dest, int perm )
{
	int len, i, numgen;
	
	memcpy ( dest, src, sizeof ( COHOMOLOGY ) );

	len = src->module_dim;
	numgen = src->gm->g->num_gen;

	if ( perm ) {
	    if ( !is_permanent ( src->gm ) ) {
		   dest->gm = allocate ( sizeof ( GMODULE ) );
		   copy_gmodule ( src->gm, dest->gm, perm );
	    }
	    dest->basis = allocate ( src->dim * sizeof ( VEC ) );
	    for ( i = 0; i < src->dim; i++ )
		   dest->basis[i] = allocate ( len*numgen );
	}
	else {
	    dest->basis = tallocate ( src->dim * sizeof ( VEC ) );
	    for ( i = 0; i < src->dim; i++ )
		   dest->basis[i] = tallocate ( len*numgen );
	}
	for ( i = 0; i < src->dim; i++ ) 
	    memcpy ( dest->basis[i], src->basis[i], len*numgen  );
}
