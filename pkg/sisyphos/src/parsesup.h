/* 	$Id: parsesup.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: parsesup.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/08/10 11:55:27  pluto
 * 	Added routines to deal with gmodule and cohomology structures.
 *
 * 	Revision 3.0  1995/06/23 16:56:33  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:30:25  pluto
 * Initial version under RCS control.
 *	 */


int findcgen 				_(( char *name, int len ));

void *g_mul_gre 			_(( void *el1, void *el2 ));
void *g_exp_gre 			_(( void *el1, void *el2 ));
void *g_add_gre 			_(( void *el1, void *el2 ));
void *g_sub_gre 			_(( void *el1, void *el2 ));
void *g_div_gre 			_(( void *el1, void *el2 ));
void *g_umi_gre 			_(( void *el1, void *el2 ));
void *g_lie_gre 			_(( void *el1, void *el2 ));

void *g_s_mula_gre 			_(( void *el1, void *el2 ));
void *g_s_mulb_gre 			_(( void *el1, void *el2 ));
void *g_s_diva_gre 			_(( void *el1, void *el2 ));
void *g_s_divb_gre 			_(( void *el1, void *el2 ));
void *g_s_adda_gre 			_(( void *el1, void *el2 ));
void *g_s_addb_gre 			_(( void *el1, void *el2 ));
void *g_s_suba_gre 			_(( void *el1, void *el2 ));
void *g_s_subb_gre 			_(( void *el1, void *el2 ));
void *g_s_lie_gre  			_(( void *el1, void *el2 ));

void *g_mul_gel 			_(( void *el1, void *el2 ));
void *g_exp_gel 			_(( void *el1, void *el2 ));

void *g_mul_graut 			_(( void *el1, void *el2 ));
void *g_exp_graut 			_(( void *el1, void *el2 ));
void *g_mul_aut 			_(( void *el1, void *el2 ));
void *g_exp_aut 			_(( void *el1, void *el2 ));
void *g_add_module 			_(( void *el1, void *el2 ));
void *g_mul_module			_(( void *el1, void *el2 ));

void *g_mul_int 			_(( void *el1, void *el2 ));
void *g_exp_int 			_(( void *el1, void *el2 ));
void *g_add_int 			_(( void *el1, void *el2 ));
void *g_sub_int 			_(( void *el1, void *el2 ));
void *g_div_int 			_(( void *el1, void *el2 ));
void *g_umi_int 			_(( void *el1, void *el2 ));
void *g_lie_int 			_(( void *el1, void *el2 ));

void *g_mul_vs 			_(( void *el1, void *el2 ));
void *g_add_vs 			_(( void *el1, void *el2 ));
void *g_exp_vs 			_(( void *el1, void *el2 ));
void *g_lie_vs 			_(( void *el1, void *el2 ));

typedef enum {O_ADD,O_SUB,O_MUL,O_DIV,O_UMI,O_EXP,O_LIE} OPTYPE;

GENVAL *galloc 			_(( TYPE of_type ));
GENVAL *gpermalloc 			_(( TYPE of_type ));
GENVAL *do_op 				_(( GENVAL *expr1, GENVAL *expr2, OPTYPE operand ));
void assign_symbol 			_(( void **p, GENVAL *expr ));
void print_expr 			_(( GENVAL *expr ));
void copy_space 			_(( SPACE *src, SPACE *dest, int perm ));
void copy_group 			_(( GRPDSC *src, GRPDSC *dest, int perm ));
void copy_pcgroup 			_(( PCGRPDESC *src, PCGRPDESC *dest, int perm, HOM *autos ));
void copy_aggroup 			_(( AGGRPDESC *src, AGGRPDESC *dest, int perm, HOM *autos ));
void copy_grpring 			_(( GRPRING *src, GRPRING *dest, int perm ));
void copy_hom 				_(( HOM *src, HOM *dest, int perm, PCGRPDESC *g ));
void copy_grhom 			_(( GRHOM *src, GRHOM *dest, int perm ));
void copy_sgrhom              _(( SGRHOM *src, SGRHOM *dest, int perm ));
void copy_shom                _(( SHOM *src, SHOM *dest, int perm ));
GENVAL *code_to_expr 		_(( LISTP* intlist ));
void expr_to_code 			_(( GENVAL *expr ));
node node_cpy 				_(( node s, int perm ));
void *get_list_item           _(( LISTP *l, int lindex, int *ret_type ));
void *get_record_field        _(( GENVAL *expr, int nfield, int *ret_type ));
void insert_list_item         _(( LISTP *l, int lindex, GENVAL *expr ));
int length_list               _(( LISTP *l ));
int is_homogeneous_list       _(( LISTP *l, TYPE t ));
VEC get_matrix                _(( LISTP *l, int *rows, int *cols ));











