/********************************************************************/
/*                                                                  */
/*  Module        : Grammar                                         */
/*                                                                  */
/*  Description :                                                   */
/*     Specifies grammar of SISYPHOS for bison/yacc                 */
/*                                                                  */
/********************************************************************/

/*	$Id: sisgram.y,v 1.1 2000/10/23 17:05:03 gap Exp $	*/
/*	$Log: sisgram.y,v $
/*	Revision 1.1  2000/10/23 17:05:03  gap
/*	initial checkin of the original version,
/*	before changing the GAP 3 interface in a few src files
/*	to a GAP 4 interface
/*	
/*	    TB
/*	
 *	Revision 3.3  1995/08/10 12:04:44  pluto
 *	Added error message for unknown procedures.
 *
 *	Revision 3.2  1995/06/28 11:25:25  pluto
 *	Displaystyle 'gap' now changes prompts to '# '.
 *	Return value 'rt' is now public.
 *
 *	Revision 3.1  1995/06/26 16:30:17  pluto
 *	Names of p-groups are copied to corresponding records.
 *
 *	Revision 3.0  1995/06/23 16:46:58  pluto
 *	New revision corresponding to sisyphos 0.8.
 *	Removed function and procedure calls.
 *
 * Revision 1.7  1995/03/20  09:44:10  pluto
 * Added support for GNU readline.
 *
 * Revision 1.6  1995/02/14  12:33:56  pluto
 * Added argument to call to 'jennings_table'.
 *
 * Revision 1.5  1995/01/11  15:58:42  pluto
 * Added new functions griso and grauto.
 *
 * Revision 1.4  1995/01/09  11:50:19  pluto
 * Added support for new lifting routine.
 *
 * Revision 1.3  1995/01/07  17:26:57  pluto
 * Corrected comment syntax.
 *
 * Revision 1.2  1995/01/05  17:33:39  pluto
 * Initial version under RCS control.
 *	*/

%{
#include "config.h"
#include <ctype.h>
#include "aglobals.h"
#include "fdecla.h"
#include "pc.h"
#include  "graut.h"
#include	"aggroup.h"
#include	"grpring.h"
#include	"hgroup.h"
#include	"symtab.h"
#include	"aut.h"
#include	"parsesup.h"
#include	"storage.h"
#include	"error.h"
#include	"solve.h"

#define TAMOUNT 100000L

#ifdef SUN3
#include <strings.h>
#else
#include <string.h>
#endif

#ifndef ANSI
extern void exit();
#else
#ifndef SUN3
#include <stdlib.h>
#endif
#endif

#ifdef HAVE_LIBGPVM3
#define DO_PVM(h,f,t,l,s,n)  do_pvm(h,f,t,l,s,n)
#else
#define DO_PVM(h,f,t,l,s,n)  /* empty */
#endif 

typedef unsigned long ULONG;
#ifndef __GNUC__
#define alloca malloc
#endif
#define IS_VALID( expr )		((expr) != 0)

void show_logo				_(( void ));
void set_paths				_(( void ));
static int find_gen 		_(( char *name ));
HOM *aut_read                 _(( char file_n[], PCGRPDESC *g_desc ));
int getopt				_(( int argc, char *const *argv, 
						    const char *optstring ));
VEC mult_comm				_(( VEC u1, VEC u2, int mod_id ));
void init_mem_stats			_(( void ));
void init_act_table			_(( void ));
void memory_usage			_(( void ));
int yyparse 				_(( void ));
int yyerror				_(( char *s ));
int yylex					_(( void ));
void do_pvm	 	    		_(( GRPDSC *h, int from, int to, int lahead, 
						    int smallgrpring, int npr ));
void initialize_readline      _(( void ));
int do_check_args             _(( FUNCDSC *func, LISTP *args, int chk_retval ));

extern int cut, fend, bperelem;
extern PCGRPDESC *group_desc;
extern GRPRING *group_ring;
extern int prime;
extern GRPDSC *h_desc;
extern char *optarg;
extern char root_path[256];
extern int pcgroup_num, group_num;
extern char prompt1[], prompt2[];
extern int use_prompt1;

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
extern int flags[];

char *mem_bottom;
char out_n[32];
char in_n[32];
char proto_n[32];
char *proto_p;
FILE *out_f, *in_f;
FILE *proto = NULL;
int verbose = FALSE;
int p_abort = FALSE;
int banner = TRUE;
int quiet = FALSE;
int use_pvm = FALSE;
DSTYLE displaystyle = SISYPHOS;
char *boolean_prefix;
char *boolean_postfix;
long amount;
long tamount;
FILE *out_hdl;
int mon_per_line;
int read_group_el = FALSE;
char pvm_in_n[80];
char pvm_out_n[80];
char pcgroup_lib[256];
char group_lib[256];
int pcgroup_num, group_num;

static DYNLIST p;
static symbol *yysym;
static GENVAL *yyhval;
static FUNCDSC *yyfunc;
static size_t node_size = sizeof ( rel_node );
static GRPDSC *g_desc;
static int i;
static int use_proto = FALSE;
int rt;

%}
%union {
	int ival;
	GENVAL *gval;
	}

%token <ival> NUMBER
%token <ival> NGEN
%token <ival> CGEN
%token <ival> GRGEN
%token QUIT MOD IDEAL DEFGRP DEFPCGRP DEFAGGRP
%token <gval> STRING
%token <gval> IDENTIFIER
%token <ival> NUM
%token RELS SEQ MATRIX
%token <gval> GEN
%token ID
%token READAUTGRP
%token READGRP
%token READPCGRP
%token READAGGRP
%token MINIMAL
%token ACTUAL
%token GENS
%token WEIGHTS
%token BATCH
%token COMMUT
%type <gval> rel, lword, rword, rside, gens, rels
%type <ival> sign, min
%type  <gval> expr
%type  <gval> numlist, wdecl, litems, litemsp, matrix, rowlist, row
%type  <gval> exprlist, exprlistp
%start cmdlist

%left MOD
%left '+' '-'
%left '*' '/'
%left UMINUS
%right '^'
%left '[' '.'

%%
cmdlist	:	/* empty */
		|	cmdlist stat ';'
			{ proc_error();
                 use_prompt1 = TRUE;
			  aut_pres_style = NONE; }
		|	cmdlist error ';'
			{  yyerrok; }
		;
stat		:	/* empty */
		|	assign
	     |    IDENTIFIER
			{ if ( (yysym = find_symbol ( $1->pval ) ) != NULL ) {
                    if ( yysym->type == NOTYPE ) {
				   yyfunc = (FUNCDSC *)yysym->object;
				   if ( do_check_args ( yyfunc, NULL, FALSE ) != -1 )
				       yyfunc->wrapper_func ( NULL );
				 }
			   }
			  else
				 set_error ( NO_SUCH_PROC );
			}
          |    IDENTIFIER '(' exprlist ')'
			{ 
			    if ( (yysym = find_symbol ( $1->pval ) ) != NULL ) {
				   if ( yysym->type == NOTYPE )
					  if ( IS_VALID ( $3 ) ) {
						 yyfunc = (FUNCDSC *)yysym->object;
						 if ( do_check_args ( yyfunc, (LISTP *)$3->pval,
										  FALSE ) != -1 )
							yyfunc->wrapper_func ( (LISTP *)$3->pval );
					  }
					  else
						 set_error ( UNDEFINED_EXPRESSION );
			    }
			    else
				   set_error ( NO_SUCH_PROC );
			}
          |	BATCH '(' STRING ')'
		|	QUIT
			{ YYACCEPT; }
		;

matrix    :    MATRIX '(' '[' rowlist ']' ')'
               { $$ = $4;}
          ;
rowlist   :    row
			{ if ( IS_VALID ( $1 ) ) { 
	          $$ = galloc ( DLIST );
			((LISTP *)$$->pval)->first = ((LISTP *)$$->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->first->value.gv = $1->pval;
			((LISTP *)$$->pval)->first->type = $1->exptype;
			((LISTP *)$$->pval)->first->next = NULL; 
	          }
			else 
                  $$ = NULL;
               }
          |    rowlist ',' row
			{ if ( IS_VALID ( $3 ) ) {
               $$ = $1;
			((LISTP *)$$->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->last = ((LISTP *)$$->pval)->last->next;
			((LISTP *)$$->pval)->last->value.gv = $3->pval;
			((LISTP *)$$->pval)->last->type = $3->exptype;
			((LISTP *)$$->pval)->last->next = NULL;
			}
               else
			   $$ = $1;
               }
          ;
row       :    '[' exprlist ']'
               { $$ = $2; }
          ;
exprlist	:	/* empty */
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = NULL; }
		|	exprlistp
			{ $$ = $1; }
		;
exprlistp	:	expr
			{ if ( IS_VALID ( $1 ) ) { 
	          $$ = galloc ( DLIST );
			((LISTP *)$$->pval)->first = ((LISTP *)$$->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->first->value.gv = $1->pval;
			((LISTP *)$$->pval)->first->type = $1->exptype;
			((LISTP *)$$->pval)->first->next = NULL; 
	          }
			else 
                  $$ = NULL;
               }
		|	exprlistp ',' expr
			{ if ( IS_VALID ( $3 ) ) {
               $$ = $1;
			((LISTP *)$$->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->last = ((LISTP *)$$->pval)->last->next;
			((LISTP *)$$->pval)->last->value.gv = $3->pval;
			((LISTP *)$$->pval)->last->type = $3->exptype;
			((LISTP *)$$->pval)->last->next = NULL;
			}
               else
			   $$ = $1;
               }
		;
numlist	:	'[' litems ']'
			{ $$ = $2;}
		;
litems	:	/* empty */
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = NULL; }
		|	litemsp
			{ $$ = $1; }
		;
litemsp	:	sign NUMBER
			{ $$ = galloc ( DLIST );
			((LISTP *)$$->pval)->first = ((LISTP *)$$->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->first->value.intv = $1*$2;
			((LISTP *)$$->pval)->first->type = INT;
			((LISTP *)$$->pval)->first->next = NULL; }
		|	litemsp ',' sign NUMBER
			{ $$ = $1;
			((LISTP *)$$->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->last = ((LISTP *)$$->pval)->last->next;
			((LISTP *)$$->pval)->last->value.intv = $3*$4;
			((LISTP *)$$->pval)->last->type = INT;
			((LISTP *)$$->pval)->last->next = NULL; }
		;

min		:	/* empty */
			{ $$ = 0;
			g_desc->is_minimal = FALSE; }
		|	MINIMAL ','
			{ $$ = 1;
			g_desc->is_minimal = TRUE; }
		;
gendecl	:	GENS '(' gens ')'
			{ i = 0;
			for ( p = ((LISTP *)$3->pval)->first; p != NULL; p = p->next ) i++;
			g_desc->num_gen = i;
			g_desc->gen = ALLOCATE ( i * sizeof ( char * ) );
			i = 0;
			for ( p = ((LISTP *)$3->pval)->first; p != NULL; p = p->next ) {
				g_desc->gen[i] = ALLOCATE ( strlen ( (char *)p->value.gv )+1 );
				strcpy ( g_desc->gen[i++], (char *)p->value.gv );
			} }
		;
gens		:	GEN
			{ $$ = galloc ( DLIST );
			((LISTP *)$$->pval)->first = ((LISTP *)$$->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->first->value.gv = $1->pval;
			((LISTP *)$$->pval)->first->next = NULL; }
		|	gens ','  GEN
			{ $$ = $1;
			((LISTP *)$$->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->last = ((LISTP *)$$->pval)->last->next;
			((LISTP *)$$->pval)->last->value.gv = $3->pval;
			((LISTP *)$$->pval)->last->next = NULL; }
		|	gens error
			{ yyclearin; }
		;
reldecl	:	RELS '(' rels ')'
			{ i = 0;
			for ( p = ((LISTP *)$3->pval)->first; p != NULL; p = p->next ) i++;
			g_desc->num_rel = i;
			g_desc->rel_list = (node *)ALLOCATE ( i * sizeof ( node ) );
			i = 0;
			for ( p = ((LISTP *)$3->pval)->first; p != NULL; p = p->next )
				g_desc->rel_list[i++] = p->value.nodev; }
		;
rels		:	rel
			{ $$ = galloc ( DLIST );
			((LISTP *)$$->pval)->first = ((LISTP *)$$->pval)->last = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->first->value.nodev = $1->pval;
			((LISTP *)$$->pval)->first->next = NULL; }
		|	rels ','  rel
			{ $$ = $1;
			((LISTP *)$$->pval)->last->next = ALLOCATE ( sizeof ( dynlistitem ) );
			((LISTP *)$$->pval)->last = ((LISTP *)$$->pval)->last->next;
			((LISTP *)$$->pval)->last->value.nodev = $3->pval;
			((LISTP *)$$->pval)->last->next = NULL; }
		|	rels error
			{ yyclearin; }
		;
rel		:	lword rside
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = ALLOCATE ( node_size );
			  ((node)$$->pval)->nodetype = EQ;
			  ((node)$$->pval)->value = 0;
			  ((node)$$->pval)->left = $1->pval;
			  ((node)$$->pval)->right = $2->pval; }
		;
rside	:	/* empty */
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = NULL; }
		|	'=' rword
			{ $$ = $2; }
		;
rword	:	lword
			{ $$ = $1; }
		|	ID
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = NULL; }
		;
lword	:	'(' lword ')'
			{ $$ = $2; }
		|	lword '*' lword
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = ALLOCATE ( node_size );
			  ((node)$$->pval)->nodetype = MULT;
			  ((node)$$->pval)->value = 0;
			  ((node)$$->pval)->left = $1->pval;
			  ((node)$$->pval)->right = $3->pval; }
		|	lword '^' sign NUM
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = ALLOCATE ( node_size );
			  ((node)$$->pval)->nodetype = EXP;
			  ((node)$$->pval)->value = $3*$4;
			  ((node)$$->pval)->left = $1->pval;
			  ((node)$$->pval)->right = NULL; }
		|	'[' lword ',' lword ']'
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = ALLOCATE ( node_size );
			  ((node)$$->pval)->nodetype = COMM;
			  ((node)$$->pval)->value = 0;
			  ((node)$$->pval)->left = $2->pval;
			  ((node)$$->pval)->right = $4->pval; }
		|	GEN
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = ALLOCATE ( node_size );
			  ((node)$$->pval)->nodetype = GGEN;
			  if ( (((node)$$->pval)->value = find_gen ( $1->pval )) == -1 ) {
			  	set_error ( INVALID_GENERATOR );
			  }
			  ((node)$$->pval)->left = NULL;
			  ((node)$$->pval)->right = NULL;
			}
		;
sign		:	/* empty */
			{ $$ = 1; }
		|	'-'
			{ $$ = -1; }
		;

assign	:	IDENTIFIER '=' { tpush_stack(); } expr
			{ if ( IS_VALID ( $4 ) && ( error_no == NO_ERROR ) ) {
				if ( (yysym = find_symbol ( $1->pval ) ) == NULL ) {
					yysym = new_symbol ( $1->pval, 0 );
					yysym = add_symbol ( yysym );
				}
				yysym->type = $4->exptype;
				assign_symbol ( (void **)&yysym->object, $4 );
				if ( yysym->type == GROUP )
				    strncpy ( ((GRPDSC *)yysym->object)->group_name,
						    yysym->name, NAME_MAX+1 );
				if ( yysym->type == PCGROUP )
				    strncpy ( ((PCGRPDESC *)yysym->object)->group_name,
						    yysym->name, NAME_MAX+1 );
				tpop_stack();
			} }
     	|	IDENTIFIER '[' expr ']' '=' expr
			{ if ( (yysym = find_symbol ( $1->pval ) ) == NULL ) {
				 set_error ( UNDEF_IDENTIFIER );
			  }
			  else {
				 if ( yysym->type == DLIST )
					if ( (IS_VALID ( $3 )) && (IS_VALID ( $6 )) )
					    if ( $3->exptype == INT ) {
						   insert_list_item ( (LISTP *)yysym->object,
								*(int *)$3->pval-1, $6 ); 
					    }
					    else
						   set_error ( IS_NOT_TYPE_INT );
					else
					    set_error ( UNDEFINED_EXPRESSION );
				 else
					set_error ( IS_NOT_TYPE_DLIST );

			  }
			} 
		|	CGEN '=' { tpush_stack(); } expr
			{ set_error ( GEN_MAY_NOT_BE_REASSIGNED );
			  tpop_stack(); }
		|	NGEN '=' { tpush_stack(); } expr
			{ set_error ( GEN_MAY_NOT_BE_REASSIGNED );
			  tpop_stack(); }
		;
expr		:	'(' expr ')'
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->exptype = $2->exptype;
			  $$->pval = $2->pval; }
          |    IDENTIFIER '(' exprlist ')'
			{ $$ = NULL;
			  if ( (yysym = find_symbol ( $1->pval ) ) != NULL ) {
                    if ( yysym->type == NOTYPE ) {
				    yyfunc = (FUNCDSC *)yysym->object;
				    if ( (rt = do_check_args ( yyfunc, 
						  (LISTP *)$3->pval, TRUE )) != -1 ) {
                           $$ = ALLOCATE ( sizeof ( GENVAL ) );
				       $$->pval = yyfunc->wrapper_func ( (LISTP *)$3->pval );
					  $$->exptype = rt;
				    }
			     }
				else
				    set_error ( NO_SUCH_PROC );
			  }
			  else 
				 set_error ( NO_SUCH_PROC );
	          }
		|	expr '+' expr
			{ if ( (IS_VALID ( $1 )) && (IS_VALID ( $3 )) )
				$$ = do_op ( $1, $3, O_ADD );
			  else
			  	$$ = NULL; }
		|	expr '-' expr
			{ if ( (IS_VALID ( $1 )) && (IS_VALID ( $3 )) )
				$$ = do_op ( $1, $3, O_SUB );
			  else
			  	$$ = NULL; }
		|	expr '*' expr
			{ if ( (IS_VALID ( $1 )) && (IS_VALID ( $3 )) )
				$$ = do_op ( $1, $3, O_MUL );
			  else
			  	$$ = NULL; }
		|	expr '/' expr
			{ if ( (IS_VALID ( $1 )) && (IS_VALID ( $3 )) )
				$$ = do_op ( $1, $3, O_DIV );
			  else
			  	$$ = NULL; }
		|	'-' expr	%prec UMINUS
			{ if ( IS_VALID ( $2 ) )
				$$ = do_op ( $2, NULL, O_UMI );
			  else
			  	$$ = NULL; }
		|	expr '^' expr
			{ if ( (IS_VALID ( $1 )) && (IS_VALID ( $3 )) )
				$$ = do_op ( $1, $3, O_EXP );
			  else
			  	$$ = NULL; }
		|	'[' expr ',' expr ']'
			{ if ( (IS_VALID ( $2 )) && (IS_VALID ( $4 )) )
				$$ = do_op ( $2, $4, O_LIE );
			  else
			  	$$ = NULL; }
		|	COMMUT '(' expr ',' expr ')'
			{ if ( (IS_VALID ( $3 )) && (IS_VALID ( $5 )) )
				if ( ($3->exptype == GRELEMENT) && ($3->exptype == GRELEMENT) ) {
					$$ = galloc ( GRELEMENT );
					$$->pval = mult_comm ( (VEC)$3->pval, (VEC)$5->pval, cut );
					if ( $$->pval == NULL )
						$$ = NULL;
				}
			  else
			  	$$ = NULL; }
          |    expr MOD IDEAL '^' expr
			{ $$ = NULL;
			if ( (IS_VALID ( $1 )) && ($1->exptype == GRELEMENT) )
			    if ( (IS_VALID ( $5 )) && ($5->exptype == INT) ) {
				   $$ = galloc ( GRELEMENT );
				   copy_vector ( $1->pval, $$->pval, 
							  FILTRATION[*(int *)$5->pval].i_start );
			    }
			}
		|	IDENTIFIER
			{ $$ = NULL; 
			if ( (yysym = find_symbol ( $1->pval ) ) != NULL ) {
				$$ = ALLOCATE ( sizeof ( GENVAL ) );
				$$->exptype = yysym->type;
				$$->pval = yysym->object;
			} 
			else
			    set_error ( UNDEF_IDENTIFIER );
			}
		|	NGEN
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->exptype = GRELEMENT;
			  $$->pval = NGEN_VEC[$1];
			}
		|	CGEN
			{ $$ = galloc ( GRELEMENT );
			  copy_vector ( NGEN_VEC[$1], (char *)$$->pval, fend );
			  ((VEC)$$->pval)[0] = 1; }
		|	GRGEN
			{ $$ = galloc ( GROUPEL );
			  copy_vector ( group_desc->nom[$1], (PCELEM)$$->pval, bperelem );
			}
		|	NUMBER
			{ $$ = galloc ( INT );
			  *((int *)$$->pval) = $1; }
		|	STRING
			{ $$ = galloc ( NSTRING );
			  $$->pval = $1->pval; }
		|	SEQ '(' exprlist ')'
			{ $$ = $3; }
		|	matrix
			{ $$ = $1; }
          |    expr '.' expr
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
                 $$->pval = NULL;
	            if ( IS_VALID ( $1 ) )
                    if ( IS_VALID ( $3 ) )
                       if ( $3->exptype == INT ) {
	                     $$->pval = get_record_field ( $1, *(int *)$3->pval-1,
                                                        &rt );
			           $$->exptype = rt;
                       }
                       else
                          set_error ( IS_NOT_TYPE_INT );
                    else
                       set_error ( UNDEFINED_EXPRESSION );
                 else
                    set_error ( UNDEFINED_EXPRESSION );
               }
	     |    expr '[' expr ']'
               { $$ = ALLOCATE ( sizeof ( GENVAL ) );
			  $$->pval = NULL;
                 if ( IS_VALID ( $1 ) )
                    if ( $1->exptype == DLIST )
				   if ( IS_VALID ( $3 ) )
				      if ( $3->exptype == INT ) {
					    $$->pval = get_list_item ( (LISTP *)$1->pval, 
                                          *(int *)$3->pval-1, &rt ); 
					    $$->exptype = rt;
                          }
				      else
				         set_error ( IS_NOT_TYPE_INT );
                        else
                           set_error ( UNDEFINED_EXPRESSION );
                     else
                        set_error ( IS_NOT_TYPE_DLIST );
                  else
                     set_error ( UNDEFINED_EXPRESSION );
                }

/* p-group expressions */

		|	DEFGRP
			{ yyhval = galloc ( GROUP ); 
			g_desc = (GRPDSC *)yyhval->pval }
			'(' min NUMBER ',' gendecl ',' reldecl ')'
			{ g_desc->prime = $5;
			  $$ = yyhval; }
		|	READGRP '(' NUMBER ',' STRING ')'
			{ yyhval = galloc ( GROUP ); 
			  g_desc = (GRPDSC *)yyhval->pval }
			  min NUMBER ',' gendecl ',' reldecl
			{ g_desc->prime = $9;
			  $$ = yyhval; }
		|	READGRP '(' NUMBER ',' STRING '$'
			{ $$ = NULL; }
		|	ACTUAL
			{ $$ = ALLOCATE ( sizeof ( GENVAL ) );
			$$->exptype = GROUP;
			$$->pval = h_desc; }

/* pc-group expressions */

		|	DEFPCGRP
			{ g_desc = ALLOCATE ( sizeof ( GRPDSC ) ); }
			'(' NUMBER ',' gendecl ',' reldecl wdecl ')'
			{ g_desc->prime = $4;
			$$ = ALLOCATE ( sizeof ( GENVAL ) );
			$$->exptype = PCGROUP;
			$$->pval = grp_to_pcgrp ( g_desc );
			if ( $9 != NULL ) {
				i = 0;
				for ( p = ((LISTP *)$9->pval)->first; p != NULL; p = p->next )
				((PCGRPDESC *)$$->pval)->g_ideal[i++] = p->value.intv;
			}
			}
		|	READPCGRP '(' NUMBER ',' STRING ')' 
			{ g_desc = ALLOCATE ( sizeof ( GRPDSC ) ); }
			  NUMBER ',' gendecl ',' reldecl wdecl
			{ g_desc->prime = $8;
			$$ = ALLOCATE ( sizeof ( GENVAL ) );
			$$->exptype = PCGROUP;
			$$->pval = grp_to_pcgrp ( g_desc );
			if ( $13 != NULL ) {
				i = 0;
				for ( p = ((LISTP *)$13->pval)->first; p != NULL; p = p->next )
				((PCGRPDESC *)$$->pval)->g_ideal[i++] = p->value.intv;
			} }
		|	READPCGRP '(' NUMBER ',' STRING '$'
			{ $$ = NULL; }

/* ag-group expressions */

		|	DEFAGGRP
			{ g_desc = ALLOCATE ( sizeof ( GRPDSC ) ); }
			'(' gendecl ',' reldecl ')'
			{ 
			$$ = ALLOCATE ( sizeof ( GENVAL ) );
			$$->exptype = AGGROUP;
			$$->pval = grp_to_aggrp ( g_desc );
			}
		|	READAGGRP '(' NUMBER ',' STRING ')' 
			{ g_desc = ALLOCATE ( sizeof ( GRPDSC ) ); }
			  gendecl ',' reldecl
			{
			$$ = ALLOCATE ( sizeof ( GENVAL ) );
			$$->exptype = AGGROUP;
			$$->pval = grp_to_aggrp ( g_desc );
			}

/* automorphism group expressions */

		|	READAUTGRP '(' expr ',' STRING ')'
			{ if ( (IS_VALID ( $3 )) && (IS_VALID ( $5 )) )
				if ( $3->exptype == PCGROUP ) {
					$$ = ALLOCATE ( sizeof ( GENVAL ) );
					$$->exptype = HOMREC;
					$$->pval = aut_read ( (char *)$5->pval, (PCGRPDESC *)$3->pval );
			  	}
			  	else
			  		set_error ( IS_NOT_TYPE_PCGROUP );
			  else
			  	set_error ( UNDEFINED_EXPRESSION );
			}
		;

wdecl	:	/* empty */
			{ $$ = NULL; }
		|	WEIGHTS '(' numlist ')'
			{ $$ = $3; }
		;


%%

int yyerror ( s )
char *s;
{
	if ( (strcmp ( s, "parse error")) == 0 ) {
		set_error ( SYNTAX_ERROR );
		proc_error();
	}
	else
		fprintf ( stderr, "Unexpected error: %s\n", s );
	return 0;
}

static int find_gen ( char *name )
{
	int i;
	
	for ( i = 0; i < g_desc->num_gen; i++ )
		if ( !strcmp ( g_desc->gen[i], name ) )
			return ( i );
	return ( -1 );
}

void sys_init ( void )
{
	/* get dynamic storage */
	if ( ( mem_bottom = get_memblock ( amount ) ) == NULL ) {
		puts ( "amount not available !!!!!" );
		exit(-1);
	}

	if ( ( mem_bottom = tget_memblock ( tamount ) ) == NULL ) {
		puts ( "temporary amount not available !!!!!" );
		exit(-1);
	}

	init_mem_stats();
	/* set output to stdout */
	out_hdl = stdout;

	/* init dispatcher */
	use_permanent_stack();
	init_act_table();
	use_temporary_stack();
	
	/* set initial value for prime and setup arithmetic for GF(2) */
	prime = 2;
	swap_arith ( 2 );
	
	/* initialize matrix */
	init_matrix();
	
	/* initialize paths */
	set_paths();
	
	/* initialize algorithm flags */
	flags[0] = use_filtration;
	flags[1] = use_max_elab_sections;
	flags[2] = only_normal_auts;
	flags[3] = use_fail_list;
	flags[4] = with_inner;

	/* initialize group ring multiplication routines */
	group_mul = n_group_mul;
	cgroup_mul = c_group_mul;
	group_exp = ngroup_exp;
	
	mon_per_line = 16;
	if ( banner ) {
		show_logo();
		show_settings();
	}

	if ( use_proto ) {
		proto_p = add_path ( "PROTO", proto_n );
		if ( (proto = fopen ( proto_p, "w" ) ) == 0 )
			printf ( "ERROR : couldn't open logfile !!!\n" );
	}
}

int main ( int argc, char *argv[] )
{
	int c;
	
#ifdef YYDEBUG
	yydebug = 1;
#endif

	amount  = 100000L;
	tamount = 300000L;
	root_path[0] = '\0';
	strcpy ( proto_n, "LOGFILE0.dat" );
	strcpy ( in_n, "ideal000.lif" );
	strcpy ( out_n, "ideal000.lif" );
	while ( (c = getopt ( argc, argv, "m:t:l:p:d:s:e:f:u:w:bq" )) != -1 )
		switch ( c ) {
		case 'm':
		    amount = atol ( optarg );
		    break;
		case 't':
		    tamount = atol ( optarg );
		    break;
		case 'l':
		    strcpy ( root_path, optarg );
		    break;
		case 'p':
		    strcpy ( proto_n, optarg );
		    use_proto = TRUE;
		    break;
		case 'd':
		    strcpy ( in_n, optarg );
		    strcpy ( out_n, optarg );
		    break;
		case 's':
		    if ( strcmp ( "gap", optarg ) == 0 ) {
			   displaystyle = GAP;					
			   strcpy ( prompt1, "# " );
			   strcpy ( prompt2, "# " );
		    }
		    break;
		case 'e':
		    strcpy ( pcgroup_lib, optarg );
		    break;
		case 'f':
		    strcpy ( group_lib, optarg );
		    break;
		case 'u':
		    pcgroup_num = atoi ( optarg );
		    break;
		case 'w':
		    group_num = atoi ( optarg );
		    break;
		case 'b':
		    banner = FALSE;
		    break;
		case 'q':
		    quiet = TRUE;
		    break;
		case '?':
		    exit (-1);
		    break;
		}
	
	init_memory_stack();
	sys_init();
	init_sym_tab();

#ifdef HAVE_LIBREADLINE
	initialize_readline();
#endif

	yyparse();
	if ( !quiet && (displaystyle != GAP) )
		memory_usage();
	return 0;
}


