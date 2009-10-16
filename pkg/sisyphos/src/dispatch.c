/********************************************************************/
/*                                                                  */
/*  Module        : Dispatcher                                      */
/*                                                                  */
/*  Description :                                                   */
/*     Dispatches function calls, contains wrapper functions.       */
/*                                                                  */
/********************************************************************/
/* 	$Id: dispatch.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: dispatch.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 1.6  1995/08/16 14:07:19  pluto
 * 	Added 'return' to 'wr_setdomain' if arguments are not valid.
 *
 * 	Revision 1.5  1995/08/10 16:02:32  pluto
 * 	Added additional parameters to 'printgap'.
 *
 * 	Revision 1.4  1995/08/10 11:56:46  pluto
 * 	New routine 'span' and changes in 'space'.
 *
 * 	Revision 1.3  1995/07/28 09:07:29  pluto
 * 	Added 'autspan' routine, added code to check if a domain is
 * 	defined in 'griso' and 'grauto'.
 *
 * 	Revision 1.2  1995/06/23 16:44:48  pluto
 * 	Initial revision corresponding to sisyphos 0.8.
 *	 */

#ifndef lint
static char vcid[] = "$Id: dispatch.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#include "hash.h"
#include "graut.h"
#include "aut.h"
#include "dispatch.h"
#include "parsesup.h"
#include "grpring.h"
#include "pc.h"
#include "hgroup.h"
#include "storage.h"
#include "symtab.h"
#include "error.h"
#include "gmodule.h"
#include "cohomol.h"

#define P1( p )        (p)
#define P2( p )        (p->next)
#define P3( p )        (p->next->next)
#define P4( p )        (p->next->next->next)
#define P5( p )        (p->next->next->next->next)
#define P6( p )        (p->next->next->next->next->next)
#define P7( p )        (p->next->next->next->next->next->next)
#define P8( p )        (p->next->next->next->next->next->next->next)
#define PVAL1( p )     (p->value.gv)
#define PVAL2( p )     (p->next->value.gv)
#define PVAL3( p )     (p->next->next->value.gv)
#define PVAL4( p )     (p->next->next->next->value.gv)
#define PVAL5( p )     (p->next->next->next->next->value.gv)
#define PVAL6( p )     (p->next->next->next->next->next->value.gv)
#define PVAL7( p )     (p->next->next->next->next->next->next->value.gv)
#define PVAL8( p )     (p->next->next->next->next->next->next->next->value.gv)
#define IVAL1( p )     (*(int *)p->value.gv)
#define IVAL2( p )     (*(int *)p->next->value.gv)
#define IVAL3( p )     (*(int *)p->next->next->value.gv)
#define IVAL4( p )     (*(int *)p->next->next->next->value.gv)
#define IVAL5( p )     (*(int *)p->next->next->next->next->value.gv)
#define IVAL6( p )     (*(int *)p->next->next->next->next->next->value.gv)
#define IVAL7( p )     (*(int *)p->next->next->next->next->next->next->value.gv)
#define IVAL8( p )     (*(int *)p->next->next->next->next->next->next->next->value.gv)

int psi                _(( int n, int m, int k ));
void gr_decompose      _(( VEC elem, int mod_id, char *gname ));
void fspecial          _(( int no ));
void init_act_table    _((void));
void get_j_series	   _(( void ));
void show_pres 	   _(( int mod_id, char *name, int def_gens,
					  char *file_n ));
void show_version      _((void));
void show_group_rels   _(( GRPDSC *h, char *name ));
void sg_automorphisms  _(( AGGRPDESC *ag_group ));
SPACE *span_space      _(( DYNLIST vl, int len_vl ));
void small_grpring	   _(( VEC mask ));
VEC sn_group_mul       _(( VEC vec1, VEC vec2, int cut ));
VEC sngroup_exp        _(( VEC vector, int power, int cut ));

extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern GRPDSC *h_desc;
extern DSTYLE displaystyle;
extern char *boolean_prefix;
extern char *boolean_postfix;
extern int cut, fend, prime;
extern int have_ls, have_li, have_js;
extern int lie_ser_len, lie_id_len, j_ser_len;
extern SPACE *lie_series[MAXLIE];
extern SPACE *lie_ideal[MAXLIE];
extern SPACE *j_series[MAXLIE];

/* algorithm flags */				/* default values */	
extern int aut_pres_all;				/* FALSE */
#define MAXFLAGS 					10
extern int use_filtration;			/* TRUE */
extern int use_max_elab_sections;		/* FALSE */
extern int only_normal_auts;			/* FALSE */
extern int use_fail_list;			/* TRUE */
extern int with_inner;				/* FALSE */
extern OPTION display_basis;			/* NONE */
extern OPTION aut_pres_style;			/* NONE */
extern int jennings_la;
extern int elim_grp_aut;
extern DSTYLE displaystyle;
extern int flags[MAXFLAGS];			
extern char prompt1[];
extern char prompt2[];
extern int verbose;
extern int rt;

int flags[MAXFLAGS];			

MULTIPD variant_table[] =
{
    {0, {NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,
	    NOTYPE,SHOMREC,SGRHOMREC,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE}},
    {0, {NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,
	    NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE}},
    {1, {NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,GRELEMENT,VECTORSPACE,
	    NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE,NOTYPE}}
};

FUNCDSC func_desc[] =
{
    {1, wr_verify, NOTYPE, {MULTIP,NOTYPE},NULL},
    {2, wr_printrels, NOTYPE, {GROUP,NSTRING,NOTYPE},NULL},
    {3, wr_obstructions, DLIST, {GROUP,DLIST,OPTIONAL,NOTYPE},NULL},
    {2, wr_presentation, NOTYPE, {HOMREC,INT,NOTYPE},NULL},
    {4, wr_printgap, NOTYPE, {PCGROUP,NSTRING,INT,OPTIONAL,NOTYPE},NULL},
    {3, wr_fetch, MULTIP, {MULTIP,INT,INT,NOTYPE},variant_table},
    {1, wr_code, MULTIP, {DLIST,NOTYPE},variant_table+1},
    {1, wr_makecode, NOTYPE, {MULTIP,NOTYPE},NULL},
    {2, wr_image, MULTIP, {SGRHOMREC,MULTIP,NOTYPE},variant_table+2},
    {3, wr_homomorphism, SGRHOMREC, {GROUP,DLIST,INT,NOTYPE},NULL},
    {3, wr_grouphom, SHOMREC, {PCGROUP,DLIST,OPTIONAL,NOTYPE},NULL},
    {2, wr_pquotient, PCGROUP, {PCGROUP,INT,NOTYPE},NULL},
    {2, wr_gmodule, GMODREC, {PCGROUP,DLIST,NOTYPE},NULL},
    {1, wr_echelon, NOTYPE, {GMODREC,NOTYPE},NULL},
    {2, wr_trivmodule, GMODREC, {PCGROUP,INT,NOTYPE},NULL},
    {1, wr_dual, GMODREC, {GMODREC,NOTYPE},NULL},
    {2, wr_cohomology, COHOMOLREC, {GMODREC,INT, NOTYPE},NULL},
    {3, wr_extension, PCGROUP, {COHOMOLREC,DLIST,OPTIONAL,NOTYPE},NULL},
    {2, wr_splitextension, PCGROUP, {GMODREC,OPTIONAL,NOTYPE},NULL},
    {1, wr_extorbit, NOTYPE, {PCGROUP, NOTYPE},NULL},
    {1, wr_star, GRELEMENT, {GRELEMENT, NOTYPE}, NULL},
    {2, wr_decompose, NOTYPE, {GRELEMENT, OPTIONAL,NOTYPE},NULL},
    {1, wr_order, INT, {GRELEMENT, NOTYPE},NULL},
    {1, wr_lieseries, VECTORSPACE, {INT, NOTYPE},NULL},
    {1, wr_lieideal, VECTORSPACE, {INT, NOTYPE},NULL},
    {1, wr_jseries, VECTORSPACE, {INT, NOTYPE},NULL},
    {1, wr_complement, VECTORSPACE, {VECTORSPACE, NOTYPE},NULL},
    {2, wr_space, VECTORSPACE, {INT, OPTIONAL, NOTYPE},NULL},
    {1, wr_span, VECTORSPACE, {DLIST, NOTYPE},NULL},
    {2, wr_closure, VECTORSPACE, {VECTORSPACE, INT, NOTYPE},NULL},
    {2, wr_annihilator, VECTORSPACE, {VECTORSPACE, INT, NOTYPE},NULL},
    {3, wr_ideal, VECTORSPACE, {GRELEMENT, INT, INT, NOTYPE},NULL},
    {2, wr_powspace, VECTORSPACE, {VECTORSPACE, INT, NOTYPE},NULL},
    {1, wr_centre, VECTORSPACE, {INT, NOTYPE},NULL}, 
    {2, wr_centralizer, VECTORSPACE, {GRELEMENT, INT, NOTYPE},NULL}, 
    {1, wr_groupring, GROUPRING, {PCGROUP, NOTYPE},NULL},
    {1, wr_smallgrpring, NOTYPE, {GRELEMENT, NOTYPE},NULL},
    {2, wr_setdomain, NOTYPE, {MULTIP, OPTIONAL, NOTYPE},NULL},
    {2, wr_use, NOTYPE, {INT, OPTIONAL, NOTYPE},NULL}, 
    {2, wr_set, NOTYPE, {INT, MULTIP, NOTYPE},NULL},
    {1, wr_show, NOTYPE, {INT, NOTYPE},NULL},
    {2, wr_weights, NOTYPE, {PCGROUP, DLIST, NOTYPE},NULL},
    {1, wr_special, NOTYPE, {INT, NOTYPE},NULL},
    {0, wr_reset, NOTYPE, {NOTYPE},NULL},
    {4, wr_unitgroup, NOTYPE, {INT, NSTRING, INT, OPTIONAL, NOTYPE},NULL},
    {3, wr_psi, NOTYPE, {INT, INT, INT, NOTYPE},NULL},
    {2, wr_automorphisms, HOMREC, {PCGROUP, OPTIONAL, NOTYPE},NULL}, 
    {3, wr_isomorphisms, HOMREC, {PCGROUP, MULTIP, OPTIONAL, NOTYPE},NULL},
    {3, wr_isomorphic, NOTYPE, {PCGROUP, MULTIP, OPTIONAL},NULL},
    {2, wr_elements, HOMREC, {HOMREC, INT, NOTYPE},NULL},
    {1, wr_autspan, HOMREC, {DLIST, NOTYPE},NULL},
    {1, wr_sgautos, NOTYPE, {AGGROUP,NOTYPE},NULL},
    {2, wr_print, NOTYPE, {MULTIP, OPTIONAL, NOTYPE},NULL},
    {1, wr_address, NOTYPE, {MULTIP, NOTYPE},NULL},
    {5, wr_grauto, GRHOMREC, {GROUP, INT, INT, INT, OPTIONAL, NOTYPE},NULL},
    {6, wr_griso, GRHOMREC, {GROUP, GROUP, INT, INT, INT, OPTIONAL, NOTYPE},NULL},
    {1, wr_fpgroup, GROUP, {PCGROUP, NOTYPE},NULL},
    {2, wr_asauto, SHOMREC, {DLIST,DLIST,NOTYPE},NULL},
    {1, wr_echo, NOTYPE, {NSTRING, NOTYPE},NULL}
};

char *func_names[] =
{
    "verify",
    "printrels",
    "obstructions",
    "presentation",
    "printgap",
    "fetch",
    "code",
    "makecode",
    "image",
    "homomorphism",
    "grouphom",
    "pquotient",
    "gmodule",
    "echelon",
    "trivialmodule",
    "dual",
    "cohomology",
    "extension",
    "splitextension",
    "extorbit",
    "star",
    "decompose",
    "order",
    "lieseries",
    "lieideal",
    "jseries",
    "complement",
    "space",
    "span",
    "closure",
    "annihilator",
    "ideal",
    "powspace",
    "centre",
    "centralizer",
    "groupring",
    "smallgrpring",
    "setdomain",
    "use",
    "set",
    "show",
    "weights",
    "special",
    "reset",
    "unitgroup",
    "psi",
    "automorphisms",
    "isomorphisms",
    "isomorphic",
    "elements",
    "autspan",
    "sgautos",
    "print",
    "address",
    "grauto",
    "griso",
    "fpgroup",
    "asauto",
    "echo",
    "dummy"
};

char *type_str[] =
{
    "'no type'",
    "'integer'",
    "'group'",
    "'pcgroup'",
    "'aggroup'",
    "'group ring'",
    "'element of groupring'",
    "'vectorspace'",
    "'list'",
    "'group homomorphisms'",
    "'group algebra homomorphisms'",
    "'group algebra homomorphism'",
    "'element of group'",
    "'multi pointer'",
    "'optional'",
    "'string'",
    "'group homomorphism'",
    "'G-module'",
    "'cohomology structure'"
};

void print_usage ( FUNCDSC *func )
/* print usage information for function described by <func> */
{
    TYPE *tl = func->args_type;
    int i;

    fprintf ( stderr, "usage: " );
    if ( func->ret_type != NOTYPE )
	   fprintf ( stderr, "<%s> = ", type_str[func->ret_type] );
    fprintf ( stderr, "func ( " );
    for ( i = 0; i < func->num_args; i++ ) {
	   fprintf ( stderr, "<%s>", type_str[tl[i]] );
	   if ( i < func->num_args-1 )
		  fprintf ( stderr, "," );
    }
    fprintf ( stderr, ")\n" );
}

int do_check_args ( FUNCDSC *func, LISTP *args, int chk_retval )
/* this routine checks the validity of the argument list
   <args> for function <func> 
   */
{
    DYNLIST p;
    TYPE *tl = func->args_type;
    int argc = 0;
    int rt;

    /* is this a function or procedure? */
    if ( chk_retval && (func->ret_type == NOTYPE) ) {
	   fprintf ( stderr, "ERROR: function does not return anything\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( -1 );
    }
    
    /* check if this function has arguments if so, check the types */
    if ( func->num_args > 0 ) 
	   if ( args != NULL )
		  for ( p = args->first, argc = 0; p != NULL; p = p->next, argc++ ) {
			 /* don't handle multi-type arguments */
			 if ( tl[argc] != MULTIP )
				if ( tl[argc] != OPTIONAL ) {
				    if ( p->type != tl[argc] ) {
					   fprintf ( stderr, "ERROR: argument %d is not of type %s\n",
							   argc+1, type_str[tl[argc]] );
					   print_usage ( func );
					   set_error ( SPECIAL_ERROR );
					   return ( -1 );
				    }
				}
			 if ( p->value.gv == NULL ) {
				fprintf ( stderr, "ERROR: argument %d is undefined\n",
						argc+1 );
				set_error ( SPECIAL_ERROR );
				return ( -1 );
			 }
		  }
	   else {
		  fprintf ( stderr, "ERROR: no arguments given\n" );
		  print_usage ( func );
		  return ( -1 );
	   }
    if ( argc < func->num_args ) {
	   /* check if optional args are allowed */
	   for ( ; argc < func->num_args; argc++ )
		  if ( tl[argc] != OPTIONAL ) {
			 fprintf ( stderr, "ERROR: wrong number of arguments\n" );
			 print_usage ( func );
			 set_error ( SPECIAL_ERROR );
			 return ( -1 );
		  }
    }
    if ( argc > func->num_args )
	   fprintf ( stderr, "WARNING: additional arguments are ignored\n" );

    /* return type, if MULTIP then lookup */
    if ( func->ret_type == MULTIP ) {
	   argc = func->variants->decisive_arg;
	   p = args->first;
	   for ( argc = 0; argc != func->variants->decisive_arg; argc++ )
		  p = p->next;
	   rt = func->variants->type_map[p->type];
    }
    else
	   rt = func->ret_type;
    return ( rt );
}

/* wrapper functions */

void *wr_verify ( LISTP *args )
{
    DYNLIST p = args->first;
    
    if ( p->type == SGRHOMREC )
	   do_single_verify ( (SGRHOM *)PVAL1(p) );
    else if ( p->type == SHOMREC ) {
	   if ( group_hom_verify ( (SHOM *)PVAL1(p) ) )
		  printf ( "true\n" );
	   else
		  printf ( "false\n" );
    }
    else
	   set_error ( WRONG_TYPE );
    return ( NULL );
}

void *wr_printrels ( LISTP *args )
{
    DYNLIST p = args->first;
    
    show_group_rels ( (GRPDSC *)PVAL1(p), (char *)PVAL2(p) );
    return ( NULL );
}

void *wr_obstructions ( LISTP *args )
{
    DYNLIST p = args->first;
    int i;
    LISTP *obs;
    GRPDSC *h;
    VEC *l;
    DYNLIST q;
    VEC *r;

    if ( !is_homogeneous_list ( (LISTP *)PVAL2(p), GRELEMENT ) ) {
	   fprintf ( stderr, "ERROR: list 2 contains elements which"
			   "are not of type %s\n", type_str[GRELEMENT] );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    h = (GRPDSC *)PVAL1(p);
    if ( length_list ( (LISTP *)PVAL2(p) ) < h->num_gen ) {
	   fprintf ( stderr, "ERROR: too few images\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }

    r = ARRAY ( h->num_gen, VEC );
    for ( i = 0,q=((LISTP *)PVAL2(p))->first; i < h->num_gen; i++,q=q->next )
	   r[i] = (VEC)q->value.gv;
    obs = ALLOCATE ( sizeof ( LISTP ) );
    q = obs->first = obs->last = ALLOCATE ( sizeof ( dynlistitem ) );
    q->type = GRELEMENT;
    q->next = NULL;
    for ( i = 1; i < h->num_rel; i++ ) {
	   obs->last = ALLOCATE ( sizeof ( dynlistitem ) );
	   obs->last->type = GRELEMENT;
	   obs->last->next = NULL;
	   q->next = obs->last;
	   q = q->next;
    }
    
    l = gr_get_obstructs ( h, r, P3(p) != NULL ? IVAL3(p) : 0 );
    for ( q=obs->first,i=0; i < h->num_rel; i++,q=q->next )
	   q->value.gv = l[i];
    return ( obs );
}

void *wr_presentation ( LISTP *args )
{
    DYNLIST p = args->first;

    show_aut_pres ( (HOM *)PVAL1(p), !IVAL2(p) );
    return ( NULL );
}

void *wr_printgap ( LISTP *args )
{
    DYNLIST p = args->first;

    if ( (P4(p ) != NULL) && (P4(p)->type != NSTRING) ) {
	   set_error ( STRING_EXPECTED );
	   return ( NULL );
    }
    pcgroup_to_gap ( (PCGRPDESC *)PVAL1(p), (char *)PVAL2(p), IVAL3(p),
				 P4(p) != NULL ? (char *)PVAL4(p) : NULL );
    return ( NULL );
}

void *wr_fetch ( LISTP *args )
{
    DYNLIST p = args->first;

    if ( p->type == GRHOMREC )
	   return ( gr_homom_fetch ( (GRHOM *)PVAL1(p), IVAL2(p), IVAL3(p) ) );
    else if ( p->type == HOMREC )
	   return ( aut_homom_fetch ( (HOM *)PVAL1(p), IVAL2(p), IVAL3(p) ) );
    else {
	   fprintf ( stderr, "ERROR: argument 2 is not of type %s or %s\n",
			   type_str[GRHOMREC], type_str[HOMREC] );
	   return ( NULL );
    }
}

void *wr_homomorphism ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( gr_get_homom ( (GRPDSC *)PVAL1(p), (LISTP *)PVAL2(p), IVAL3(p) ) ); 
}

void *wr_grouphom ( LISTP *args )
{
    DYNLIST p = args->first;

    if ( P3(p) != NULL )
	   if ( P3(p)->type != GROUP ) {
		  fprintf ( stderr, "ERROR: argument 3 is not of type %s\n",
				  type_str[GROUP] );
		  set_error ( SPECIAL_ERROR );
		  return ( NULL );
	   }
    return ( get_group_homom ( (PCGRPDESC *)PVAL1(p), (LISTP *)PVAL2(p),
		   P3(p) != NULL ? (GRPDSC *)PVAL3(p) : NULL ) ); 
}

void *wr_image ( LISTP *args )
{
    DYNLIST p = args->first;
    
    if ( p->next->type == GRELEMENT )
	   return ( gr_get_image ( (SGRHOM *)PVAL1(p), (VEC)PVAL2(p) ) ); 
    else if ( p->next->type == VECTORSPACE )
	   return ( gr_vs_image ( (SGRHOM *)PVAL1(p), (SPACE *)PVAL2(p) ) );
    else {
	   fprintf ( stderr, "ERROR: argument 2 is not of type %s or %s\n",
			   type_str[GRELEMENT], type_str[VECTORSPACE] );
	   return ( NULL );
    }
}

void *wr_code ( LISTP *args )
{
    GENVAL *gv;
    
    gv = code_to_expr ( (LISTP *)args->first->value.gv );
    rt = gv->exptype;
    return ( gv->pval );
}

void *wr_automorphisms ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( automorphisms ( (PCGRPDESC *)PVAL1(p), 
					    P2(p) != NULL ? IVAL2(p) : 0 ) );
}

void *wr_isomorphisms ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( isomorphisms ( (PCGRPDESC *)PVAL1(p), PVAL2(p), 
					   p->next->type == GROUP ? FALSE : TRUE,
					   P3(p) != NULL ? IVAL3(p) : 0 ) );
}

void *wr_isomorphic ( LISTP *args )
{
    DYNLIST p = args->first;
    int iso;

    iso = is_isomorphic ( (PCGRPDESC *)PVAL1(p), PVAL2(p),
					    p->next->type == GROUP ? FALSE : TRUE,
					    P3(p) != NULL ? IVAL3(p) : 0 );
    if ( displaystyle == GAP ) {
	   boolean_prefix = "SISYPHOS.SISBOOL := ";
	   boolean_postfix = ";";
    }
    else {
	   boolean_prefix = "";
	   boolean_postfix = "";
    }
    if ( iso )
	   printf ( "%strue%s\n", boolean_prefix, boolean_postfix );
    else
	   printf ( "%sfalse%s\n", boolean_prefix, boolean_postfix );
    
    return ( NULL );
}
    
void *wr_gmodule ( LISTP *args )
{
    DYNLIST p = args->first;
    LISTP *m;
    int len_m, rows, cols, dq;
    PCGRPDESC *g;
    LISTP *q;
    GMODULE *gm; 
    VEC m1;
    int i;

    g = (PCGRPDESC *)PVAL1(p);
    if ( !is_homogeneous_list ( (LISTP *)PVAL2(p), DLIST ) ) {
	   fprintf ( stderr, "ERROR: list contains elements which"
			   "are not of matrix type \n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    
    m = (LISTP *)PVAL2(p);
    len_m = length_list ( m );
    if ( len_m < g->num_gen ) {
	   fprintf ( stderr, "ERROR: need %d matrices\n", g->num_gen );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    q = (LISTP *)m->first->value.gv;
    m1 = get_matrix ( q, &rows, &cols );
    if ( (m1 == NULL) || (rows != cols) ) {
	   fprintf ( stderr, "ERROR: matrix 1 is invalid\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    dq = rows * rows;
    gm = ALLOCATE ( sizeof ( GMODULE ) );
    gm->g = g;
    gm->dim = rows;
    gm->echelon = NULL;
    gm->T = gm->TI = NULL;
    gm->m = ARRAY ( g->num_gen, VEC );
    gm->m[0] = m1;
    for ( p = m->first->next, i = 1; p != NULL; p = p->next,i++ ) {
	   q = (LISTP *)p->value.gv;
	   m1 = get_matrix ( q, &rows, &cols );
	   if ( (m1 == NULL) || (rows != gm->dim) || (cols != gm->dim) ) {
		  fprintf ( stderr, "ERROR: matrix %d is invalid\n", i+1 );
		  set_error ( SPECIAL_ERROR );
		  return ( NULL );
	   }
	   gm->m[i] = m1;
    }
    return ( gm );
}

void *wr_echelon ( LISTP *args )
{
    DYNLIST p = args->first;
    
    echelonize_module ( (GMODULE *)PVAL1(p) );
    return ( NULL );
}

void *wr_trivmodule ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( triv_mod ( IVAL2(p), (PCGRPDESC *)PVAL1(p) ) );
}

void *wr_dual ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( gm_dual ( (GMODULE *)PVAL1(p) ) );
}

void *wr_cohomology ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( cohomology ( (GMODULE *)PVAL1(p), IVAL2(p) ) );
}

void *wr_extension ( LISTP *args )
{
    DYNLIST p = args->first;
    COHOMOLOGY *cohomol;
    VEC select;
    char *gname = "m";
    DYNLIST q;
    int i;

    if ( (P3(p) != NULL) && (P3(p)->type == NSTRING) )
	   gname = (char *)PVAL3(p);
    cohomol = (COHOMOLOGY *)PVAL1(p);
    if ( !is_homogeneous_list ( (LISTP *)PVAL2(p), INT ) ) {
	   fprintf ( stderr, "ERROR: list contains elements which"
			   "are not of type %s\n", type_str[INT] );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    
    if ( length_list ( (LISTP *)PVAL2(p) ) != cohomol->dim ) {
	   fprintf ( stderr, "ERROR: list is not of length %d\n", cohomol->dim );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }

    if ( cohomol->degree != 2 ) {
	   fprintf ( stderr, "ERROR: need second cohomology\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
	   
    select = ALLOCATE ( cohomol->dim );
    for ( q = ((LISTP *)PVAL2(p))->first, i=0; q != NULL; q = q->next,i++ )
	   select[i] = (char)(*(int *)q->value.gv);

    
    return ( group_extension ( cohomol, select, gname ) );
}

void *wr_splitextension ( LISTP *args )
{
    DYNLIST p = args->first;
    GMODULE *gm;
    char *gname = "m";

    if ( (P2(p) != NULL) && (P2(p)->type == NSTRING) )
	   gname = (char *)PVAL2(p);
    gm = (GMODULE *)PVAL1(p);

    return ( split_extension ( gm, gname ) );
}

void *wr_extorbit ( LISTP *args )
{
    DYNLIST p = args->first;

    calc_extorbit ( (PCGRPDESC *)PVAL1(p) );
    return ( NULL );
}

void *wr_star ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( gr_star ( (VEC)PVAL1(p), cut ) );
}

void *wr_decompose ( LISTP *args )
{
    DYNLIST p = args->first;

    if ( ((VEC)PVAL1(p))[0] == 0 )
	   set_error ( IS_NOT_UNIT );
    else
	   gr_decompose ( (VEC)PVAL1(p), cut, 
				   P2(p) != NULL ? (char *)PVAL2(p): NULL );
    return ( NULL );
}

void *wr_weights ( LISTP *args )
{
    DYNLIST p = args->first;
    PCGRPDESC *g;
    DYNLIST q;
    int i = 0;

    g = (PCGRPDESC *)PVAL1(p);
    
    if ( !is_homogeneous_list ( (LISTP *)PVAL2(p), INT ) ) {
	   fprintf ( stderr, "ERROR: list 2 contains elements which"
			   "are not of type %s\n", type_str[INT] );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    
    if ( length_list ( (LISTP *)PVAL2(p) ) != g->num_gen ) {
	   fprintf ( stderr, "ERROR: length of list 2 is not"

			   "equal to %d\n", g->num_gen );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
	   
    for ( q = ((LISTP *)PVAL2(p))->first; (q != NULL) && (i < g->num_gen); 
								  q = q->next )
	   g->g_ideal[i++] = *(int *)q->value.gv;
    return ( NULL );
}

void *wr_smallgrpring ( LISTP *args )
{
    DYNLIST p = args->first;
    group_mul = sn_group_mul;
    group_exp = sngroup_exp;
    small_grpring ( PVAL1(p) );
    return ( NULL );
}

void *wr_setdomain ( LISTP *args )
{
    DYNLIST p = args->first;
    symbol *sym;
    GENVAL gv;
    GRPRING *gr = NULL;
    int limit = 0;

    if ( P1(p)->type == PCGROUP ) {
	   limit = -1;
	   gr = set_groupring ( (PCGRPDESC *)PVAL1(p) );
    }
    else if ( P1(p)->type == GROUPRING ) {
	   gr = (GRPRING *)PVAL1(p);
	   limit = P2(p) == NULL ? -1 : IVAL2(p);
    }
    else {
	   fprintf ( stderr, "ERROR: argument 1 is neither of type" 
			   " %s nor of type %s\n",
			   type_str[PCGROUP], type_str[GROUPRING] );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
	   
    if ( (sym = find_symbol ( "_$GRACTUAL" ) ) == NULL ) {
	   sym = new_symbol ( "_$GRACTUAL", 0 );
	   sym = add_symbol ( sym );
	   gv.exptype = GROUPRING;
	   gv.pval = gr;
	   sym->type = GROUPRING;
	   assign_symbol ( &sym->object, &gv );
    }
    else
	   copy_grpring ( gr, sym->object, TRUE );
    set_domain ( (GRPRING *)sym->object, limit );
    
    if ( (sym = find_symbol ( "_$PCGACTUAL" ) ) == NULL ) {
	   gv.exptype = PCGROUP;
	   gv.pval = gr->g;
	   sym = new_symbol ( "_$PCGACTUAL", 0 );
	   sym = add_symbol ( sym );
	   sym->type = PCGROUP;
	   assign_symbol ( &sym->object, &gv );
    }
    else
	   copy_pcgroup ( gr->g, (PCGRPDESC *)sym->object, 
				   TRUE, NULL ); 
    
    if ( (P1(p)->type == PCGROUP) && (P2(p) == NULL) ) {
	   use_permanent_stack();
	   group_ring->mul_table = multiplication_table();
	   cgroup_mul = tc_group_mul;
	   use_temporary_stack();
    }
  
    return ( NULL );
}

void *wr_psi ( LISTP *args )
{
    DYNLIST p = args->first;

    printf ( "dim of kernel Psi(%d,%d,%d) : %d\n", 
		   IVAL1(p), IVAL2(p), IVAL3(p),
		   psi ( IVAL1(p), IVAL2(p), IVAL3(p) ) );
    return ( NULL );
}

void *wr_special ( LISTP *args )
{
    fspecial ( *(int *)args->first->value.gv );
    return ( NULL );
}

void *wr_reset ( LISTP *args )
{
    clear();
    clear_t();
    init_memory_stack();
    init_sym_tab();
    group_mul = n_group_mul;
    cgroup_mul = c_group_mul;
    group_exp = ngroup_exp;
    
    /* init dispatcher */
    use_permanent_stack();
    init_act_table();
    use_temporary_stack();
    return ( NULL );
}

void *wr_makecode ( LISTP *args )
{
    DYNLIST p = args->first;
    GENVAL gv;

    gv.exptype = p->type;
    gv.pval = PVAL1(p);
    expr_to_code ( &gv );
    return ( NULL );
}

void *wr_address ( LISTP *args )
{
    printf ( "%ld\n", (long)args->first->value.gv );
    return ( NULL );
}

void *wr_pquotient ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( p_quotient ( (PCGRPDESC *)PVAL1(p), IVAL2(p) ) );
}

void *wr_order ( LISTP *args )
{
    DYNLIST p = args->first;
    int *order = ALLOCATE ( sizeof ( int ) );
    
    *order = get_order ( (VEC)PVAL1(p), cut );
    return ( order );
}

void *wr_lieseries ( LISTP *args )
{
    DYNLIST p = args->first;
    int term;
    
    use_permanent_stack();
    if ( !have_ls )
	   get_lie_series();
    use_temporary_stack();
    term = IVAL1(p);
    if ( term <= lie_ser_len )
	   return ( lie_series[term] );
    else
	   return ( lie_series[lie_ser_len] );
}

void *wr_lieideal ( LISTP *args )
{
    DYNLIST p = args->first;
    int term;
    
    use_permanent_stack();
    if ( !have_li )
	   get_lie_ideal();
    use_temporary_stack();
    term = IVAL1(p);
    if ( term <= lie_id_len )
	   return ( lie_ideal[term] );
    else
	   return ( lie_ideal[lie_id_len] );

}

void *wr_jseries ( LISTP *args )
{
    DYNLIST p = args->first;
    int term;
    
    use_permanent_stack();
    if ( !have_js )
	   get_j_series();
    use_temporary_stack();
    term = IVAL1(p);
    if ( term <= j_ser_len )
	   return ( j_series[term] );
    else
	   return ( j_series[j_ser_len] );
}

void *wr_complement ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( compl_space ( (SPACE *)PVAL1(p) ) );
}

void *wr_space ( LISTP *args )
{
    DYNLIST p = args->first;
    int limit;

    limit = MAX_ID;
    if ( P2(p) != NULL )
	   if ( P2(p)->type == INT )
		  limit = IVAL2(p);

    return ( conv_I_space ( IVAL1(p), limit ) );
}

void *wr_span ( LISTP *args )
{
    DYNLIST p = args->first;
    int len;

    if ( (len=length_list ( (LISTP *)PVAL1(p) ) ) <= 0 ) { 
	   fprintf ( stderr, "ERROR: empty list\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    if ( !is_homogeneous_list ( (LISTP *)PVAL1(p), GRELEMENT ) ) {
	   fprintf ( stderr, "ERROR: list contains elements which"
			   "are not of type %s\n", type_str[GRELEMENT] );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }

    return ( span_space ( ((LISTP *)PVAL1(p))->first, len ) );
}

void *wr_closure ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( ideal_closure ( (SPACE *)PVAL1(p), IVAL2(p) ) );
}

void *wr_annihilator ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( annihilator ( IVAL2(p), (SPACE *)PVAL1(p) ) );
}

void *wr_ideal ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( principal_ideal ( (VEC)PVAL1(p), IVAL3(p), IVAL2(p) ) );
}

void *wr_powspace ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( pot_space ( (SPACE *)PVAL1(p), IVAL2(p) ) );
}

void *wr_centre ( LISTP *args )
{
    DYNLIST p = args->first;
 
    return ( e_centralizer ( NGEN_VEC, GMINGEN, 
					    IVAL1(p) == 0 ? MAX_ID : IVAL1(p) ) );
}

void *wr_centralizer ( LISTP *args )
{
    DYNLIST p = args->first;
    VEC v_list[3];
    
    v_list[0] = (VEC)PVAL1(p);
    return ( e_centralizer ( v_list, 1, 
					    IVAL2(p) == 0 ? MAX_ID : IVAL2(p) ) );
}

void *wr_groupring ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( set_groupring ( (PCGRPDESC *)PVAL1(p) ) );
}

void *wr_use ( LISTP *args )
{
    DYNLIST p = args->first;
    
    switch ( IVAL1(p) ) {
    case MTABLE:
	   use_permanent_stack();
	   group_ring->mul_table = multiplication_table();
	   cgroup_mul = tc_group_mul;
	   use_temporary_stack();
	   break;
    case JTABLE:
	   use_permanent_stack();
	   jennings_la = P2(p) != NULL ? IVAL2(p) : 0;
	   group_ring->jenn_table =
		  jennings_table ( jennings_la );
	   group_mul = t_group_mul;
	   group_exp = tgroup_exp;
	   use_temporary_stack();
	   break;
    default:
	   set_error ( SYNTAX_ERROR );
    }
    return ( NULL );
}

void *wr_set ( LISTP *args )
{
    DYNLIST p = args->first;
    DYNLIST q;
    int i;

    switch ( IVAL1(p) ) {
    case PROMPT:
	   if ( (P2(p ) != NULL) && (P2(p)->type == NSTRING) )
		  strcpy ( prompt1, (char *)PVAL2(p) );
	   else
		  set_error ( STRING_EXPECTED );
	   break;
    case VERBOSE:
	   if ( (P2(p ) != NULL) && (P2(p)->type == INT) )
		  verbose = IVAL2(p);
	   break;
    case DISSTYLE:
	   if ( (P2(p ) != NULL) && (P2(p)->type == INT) )
		 displaystyle = IVAL2(p);
	   break;
    case FLAGS:
	   if ( (P2(p ) != NULL) && (P2(p)->type == DLIST) ) {
		  for ( q = ((LISTP *)PVAL2(p))->first, i=0; q != NULL; q = q->next )
			 flags[i++] = *(int *)q->value.gv;
		  use_filtration = flags[0];
		  use_max_elab_sections = flags[1];
		  only_normal_auts = flags[2];
		  use_fail_list = flags[3];
		  with_inner = aut_pres_all = flags[4];
	   }
	   break;
    default:
	   set_error ( SYNTAX_ERROR );
    }
	   
    return ( NULL );
}

void *wr_show ( LISTP *args )
{
    DYNLIST p = args->first;

    switch ( IVAL1(p) ) {
    case MEMORY:
	   show_memory_info();
	   break;
    case PRIME:
	   printf ( "%d\n", prime );
	   break;
    case CUT:
	   printf ( "%d\n", cut );
	   break;
    case END:
	   printf ( "%d\n", fend );
	   break;
    case SYMBOLS:
	   show_symbols();
	   break;
    case VERSION:
	   show_version();
	   break;
    case FLAGS:
	   printf ( "     use_filtration:        %s\n", 
			  flags[0] == 1 ? "true" : "false" );
	   printf ( "     use_max_elab_sections: %s\n", 
			  flags[1] == 1 ? "true" : "false" );
	   printf ( "     only_normal_auts:      %s\n", 
			  flags[2] == 1 ? "true" : "false" );
	   printf ( "     use_fail_list:         %s\n", 
			  flags[3] == 1 ? "true" : "false" );
	   printf ( "     with_inner:            %s\n", 
			  flags[4] == 1 ? "true" : "false" );
	   break;
    default:
	   set_error ( SYNTAX_ERROR );
    }
    return ( NULL );
}

void *wr_unitgroup ( LISTP *args )
{
    DYNLIST p = args->first;

    if ( (P4(p ) != NULL) && (P4(p)->type != NSTRING) ) {
	   set_error ( STRING_EXPECTED );
	   return ( NULL );
    }
    show_pres ( IVAL1(p), (char *)PVAL2(p), IVAL3(p), P4(p) != NULL ? 
			 (char *)PVAL4(p) : NULL );
    return ( NULL );
}

void *wr_elements ( LISTP *args )
{
    DYNLIST p = args->first;

    return ( generate_automorphism_group ( (HOM *)PVAL1(p), !IVAL2(p) ) );
}

void *wr_autspan ( LISTP *args )
{
    DYNLIST p = args->first;
    HOM *autl;

    int len;
    
    len=length_list ( (LISTP *)PVAL1(p) );
    if ( len < 1 ) {
	   fprintf ( stderr, "ERROR: list is empty\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }

    if ( !is_homogeneous_list ( (LISTP *)PVAL1(p), SHOMREC ) ) {
	   fprintf ( stderr, "ERROR: list contains elements which"
			   "are not of type %s\n", type_str[SHOMREC] );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    
    autl = conv_to_hom ( (LISTP *)PVAL1(p), TRUE );
    return ( generate_automorphism_group ( autl, FALSE ) );
}

void *wr_sgautos ( LISTP *args )
{
    DYNLIST p = args->first;

    sg_automorphisms ( (AGGRPDESC *)PVAL1(p)  );
    return ( NULL );
}

void *wr_print ( LISTP *args )
{
    DYNLIST p = args->first;
    GENVAL gv;
    
    gv.exptype = p->type;
    gv.pval = PVAL1(p);
    if ( (P2(p) != 0) && (P2(p)->type == INT ) )
	   switch ( IVAL2(p) ) {
	   case SBASE:
		  display_basis = STANDARD_BASIS;
		  break;
	   case IMAGES:
	   case PERMUTATIONS:
	   case BINARYP:
	   case CYCLES:
	   case NONE:
		  aut_pres_style = IVAL2(p);
		  break;
	   default:
		  aut_pres_style = NONE;
		  display_basis = NONE;
	   }
    else {
		  aut_pres_style = NONE;
		  display_basis = NONE;
    }
	   
    print_expr ( &gv );
    return ( NULL );
}

void *wr_grauto ( LISTP *args )
{
    DYNLIST p = args->first;

    if ( (group_desc == NULL) || (group_ring == NULL) ) {
	   fprintf ( stderr, "ERROR: no domain specified\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }

    elim_grp_aut = IVAL3(p);
    if ( elim_grp_aut && !prepare_aut ( group_desc ) )
	   return ( NULL );
    
    return ( gr_lift_control ( (GRPDSC *)PVAL1(p), (GRPDSC *)PVAL1(p),
						 IVAL2(p), FALSE, IVAL4(p), FALSE,
						 P5(p) != NULL ? TRUE : FALSE ) );
}

void *wr_griso ( LISTP *args )
{
    DYNLIST p = args->first;

    if ( (group_desc == NULL) || (group_ring == NULL) ) {
	   fprintf ( stderr, "ERROR: no domain specified\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }

    elim_grp_aut = IVAL4(p);
    if ( elim_grp_aut && !prepare_aut ( group_desc ) )
	   return ( NULL );

    return ( gr_lift_control ( (GRPDSC *)PVAL1(p), (GRPDSC *)PVAL2(p),
						 IVAL3(p), TRUE, IVAL5(p), FALSE,
						 P6(p) != NULL ? TRUE : FALSE ) );
}

void *wr_asauto ( LISTP *args )
{
    DYNLIST p = args->first;
    int len;
    
    if ( (len=length_list ( (LISTP *)PVAL1(p) ) ) != 
	    length_list ( (LISTP *)PVAL2(p) ) ) {
	   fprintf ( stderr, "ERROR: lists have different lengths\n" );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    if ( !is_homogeneous_list ( (LISTP *)PVAL1(p), SHOMREC ) ) {
	   fprintf ( stderr, "ERROR: list 1 contains elements which"
			   "are not of type %s\n", type_str[SHOMREC] );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    if ( !is_homogeneous_list ( (LISTP *)PVAL2(p), INT ) ) {
	   fprintf ( stderr, "ERROR: list 2 contains elements which"
			   "are not of type %s\n", type_str[INT] );
	   set_error ( SPECIAL_ERROR );
	   return ( NULL );
    }
    
    return ( evaluate_aut ( (LISTP *)PVAL1(p), (LISTP *)PVAL2(p), len ) );
}

void *wr_fpgroup ( LISTP *args )
{
    DYNLIST p = args->first;
    
    return ( conv_rel ( (PCGRPDESC *)PVAL1(p) ) );
}

void *wr_echo ( LISTP *args )
{
    DYNLIST p = args->first;

    printf ( "%s\n", (char *)PVAL1(p) );
    return ( NULL );
}
