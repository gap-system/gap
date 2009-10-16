/* 	$Id: pc.h,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: pc.h,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.2  1995/08/10 16:03:45  pluto
 * 	Added additional parameters to 'pcgroup_to_gap'.
 *
 * 	Revision 3.1  1995/08/10 12:03:23  pluto
 * 	Added declaration for 'pcgroup_to_gap'.
 *
 * 	Revision 3.0  1995/06/23 16:56:56  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:26:14  pluto
 * Initial version under RCS control.
 *	 */

#define get_el( el, n )		((el)[(n)])
#define set_el(el, n, v)		((el)[(n)]=(v))
#define dec_el(el, n)		((el)[(n)]--)

#define IDENTITY			(*gcallocate)( group_desc->num_gen )
#define GRZERO                (*gcallocate)( group_desc->group_card )
#define GRIDENTITY(p)         {p = (*gcallocate)( group_desc->group_card );\
                               p[0] = 1;}
#define IDEL( gd )			(*gcallocate)( gd->num_gen )
#define clear_el( el )		zero_vector ( (el), bperelem )

#define PC_WEIGHT(i)		g_desc->pc_weight[i]
#define EXP_P_LCS			group_desc->exp_p_lcs
#define EXP_P_CLASS			group_desc->exp_p_class

/* index of commutator [g_i,g_j] */
#define CN(i,j)			((( i * ( i - 1 ) ) >> 1)+j)

#define EL(i)				group_ring->c_monom[i]
#define IND(e)				nr ( e )
#define TP(i,j)			group_ring->mul_table[(long)i][(long)j]
#define JT(i,j)			group_ring->jenn_table[(long)i][(long)j]

#define GNUMGEN			group_desc->num_gen
#define GPRIME				group_desc->prime
#define GCARD				group_desc->group_card
#define BPERELEM			group_desc->num_gen
#define MAX_ID				group_desc->max_id
#define LAST_ID               (group_desc->max_id-1)
#define G_MAX				group_desc->g_max
#define G_IDEAL			group_desc->g_ideal
#define GNOM				group_desc->nom
#define G_GEN				group_desc->gen
#define MUL_TABLE			group_ring->mul_table
#define FILTRATION			group_ring->filtration
#define C_MONOM			group_ring->c_monom
#define N_MONOM			group_ring->n_monom
#define EL_NUM				group_ring->el_num
#define NGEN_VEC			group_ring->ngen_vec
#define GMINGEN			group_desc->min_gen
#define DEF_LIST			group_desc->def_list

#define E_NODE( n, l, p ) 		{n = ALLOCATE ( sizeof ( rel_node ) );\
							n->nodetype = EXP;\
							n->value = p;\
							n->left = l;\
							n->right = NULL;}
#define M_NODE( n, l, r )		{n = ALLOCATE ( sizeof ( rel_node ) );\
							n->nodetype = MULT;\
							n->value = 0;\
							n->left = l;\
							n->right = r;}
#define G_NODE( n, g )			{n = ALLOCATE ( sizeof ( rel_node ) );\
							n->nodetype = GGEN;\
							n->value = g;\
							n->left = NULL;\
							n->right = NULL;}
#define C_NODE( n, l, r )		{n = ALLOCATE ( sizeof ( rel_node ) );\
							n->nodetype = COMM;\
							n->value = 0;\
							n->left = l;\
							n->right = r;}
#define R_NODE( n, l, r )		{n = ALLOCATE ( sizeof ( rel_node ) );\
							n->nodetype = EQ;\
							n->value = 0;\
							n->left = l;\
							n->right = r;}

#define SGEP( h, i, exp )		{ h = ALLOCATE ( sizeof ( ge_pair ) * 2 );\
							h[0].g = i;\
							h[0].e = exp;\
							h[1].g = h[1].e = -1;}
typedef ge_pair *GEP;

typedef struct group_el {
    PCGRPDESC* g;
    PCELEM el;
} GE;

node gen_to_node 				_(( int g ));
node word_to_node 				_(( VEC word, int len ));
PCELEM image_of_generator 		_(( VEC r, int g ));
ge_pair *exp_vec_to_ge_pair 		_(( PCELEM el, int *size ));
void collect 					_(( PCELEM li, GEP r ));
PCGRPDESC *p_quotient              _(( PCGRPDESC *g_desc, int class ));
void pcgroup_to_gap                _(( PCGRPDESC *g, char *name, int def_gens,
							    char *file_n ));

GE *ge_mul                         _(( GE *l, GE *r ));
GE *ge_exp                         _(( GE *l, int power ));
GE *ge_inv                         _(( GE *l ));
GE *ge_comm                        _(( GE *l, GE *r ));










