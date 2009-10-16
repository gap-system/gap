/* 	$Id: symtab.h,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: symtab.h,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/08/10 12:05:13  pluto
 * 	Several new wrapper functions.
 *
 * 	Revision 3.0  1995/06/23 16:58:05  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:31:37  pluto
 * Initial version under RCS control.
 *	 */

typedef void *(*GENFUNC)(LISTP *);

typedef struct multip_desc {
    int decisive_arg;
    TYPE type_map[MAXTYPES];
} MULTIPD;

typedef struct func_entry {
    int num_args;
    GENFUNC wrapper_func;
    TYPE ret_type;
    TYPE args_type[8];
    MULTIPD *variants;
} FUNCDSC;


/* prototypes of wrapper functions */
void *wr_verify                 _(( LISTP *args ));
void *wr_printrels              _(( LISTP *args ));
void *wr_obstructions           _(( LISTP *args ));
void *wr_presentation           _(( LISTP *args ));
void *wr_printgap               _(( LISTP *args ));
void *wr_fetch                  _(( LISTP *args ));
void *wr_code                   _(( LISTP *args ));
void *wr_makecode               _(( LISTP *args ));
void *wr_image                  _(( LISTP *args ));
void *wr_homomorphism           _(( LISTP *args ));
void *wr_grouphom               _(( LISTP *args ));
void *wr_pquotient              _(( LISTP *args ));
void *wr_gmodule                _(( LISTP *args ));
void *wr_echelon                _(( LISTP *args ));
void *wr_trivmodule             _(( LISTP *args ));
void *wr_dual                   _(( LISTP *args ));
void *wr_cohomology             _(( LISTP *args ));
void *wr_extension              _(( LISTP *args ));
void *wr_splitextension         _(( LISTP *args ));
void *wr_extorbit               _(( LISTP *args ));
void *wr_star                   _(( LISTP *args ));
void *wr_decompose              _(( LISTP *args ));
void *wr_order                  _(( LISTP *args ));
void *wr_lieseries              _(( LISTP *args ));
void *wr_lieideal               _(( LISTP *args ));
void *wr_jseries                _(( LISTP *args ));
void *wr_complement             _(( LISTP *args ));
void *wr_space                  _(( LISTP *args ));
void *wr_span                   _(( LISTP *args ));
void *wr_closure                _(( LISTP *args ));
void *wr_annihilator            _(( LISTP *args ));
void *wr_ideal                  _(( LISTP *args ));
void *wr_powspace               _(( LISTP *args ));
void *wr_centre                 _(( LISTP *args ));
void *wr_centralizer            _(( LISTP *args ));
void *wr_groupring              _(( LISTP *args ));
void *wr_smallgrpring           _(( LISTP *args ));
void *wr_setdomain              _(( LISTP *args ));
void *wr_use                    _(( LISTP *args ));
void *wr_set                    _(( LISTP *args ));
void *wr_show                   _(( LISTP *args ));
void *wr_weights                _(( LISTP *args ));
void *wr_special                _(( LISTP *args ));
void *wr_reset                  _(( LISTP *args ));
void *wr_unitgroup              _(( LISTP *args ));
void *wr_psi                    _(( LISTP *args ));
void *wr_automorphisms          _(( LISTP *args ));
void *wr_isomorphisms           _(( LISTP *args ));
void *wr_isomorphic             _(( LISTP *args ));
void *wr_elements               _(( LISTP *args ));
void *wr_autspan                _(( LISTP *args ));
void *wr_sgautos                _(( LISTP *args ));
void *wr_print                  _(( LISTP *args ));
void *wr_address                _(( LISTP *args ));
void *wr_griso                  _(( LISTP *args ));
void *wr_grauto                 _(( LISTP *args ));
void *wr_fpgroup                _(( LISTP *args ));
void *wr_asauto                 _(( LISTP *args ));
void *wr_echo                   _(( LISTP *args ));

int cmp 					_(( symbol *sym1, symbol *sym2 ));
void init_sym_tab 			_(( void ));
symbol *new_symbol 			_(( char *name, int scope ));
symbol *add_symbol 			_(( symbol *sym ));
symbol *find_symbol 		_(( char *symname ));
void symprint 				_(( symbol *sym, FILE *stream ));
void show_symbols 			_(( void ));




