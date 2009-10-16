/* 	$Id: graut.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: graut.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:55:35  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/04/18  14:59:44  pluto
 * Initial revison under RCS control.
 *	 */

typedef struct sgr_homom {
    struct grpdsc *h;
    int lift_limit;
    VEC image_list;
} SGRHOM;

typedef struct gr_homom {
    struct grpdsc *h;
    struct grpdsc *gg;
    struct pcgrpdesc *g;
    int max_id;
    int lift_limit;
    int max_lift;
    int isomorphic;
    int auts;
    int class1_generators;
    int inn_log;
    int out_log;
    int graut_num;
    int only_normal_auts;
    int with_inner;
    int with_grautos;
    int *aut_gens_dim;
    int *out_gens_dim;
    int *mod_grauts_gens_dim;
    VEC **aut_gens;
    VEC epimorphism;
    int elements;
} GRHOM;

void get_centralizer 		_(( int ncut ));
void get_all_op_mats 		_(( int ncut ));
int do_single_verify          _(( SGRHOM *rho_rec ));
void gr_show_hom              _(( GRHOM *auts ));
void gr_show_shom             _(( SGRHOM *rho_rec ));
SGRHOM *gr_homom_fetch        _(( GRHOM *auts, int class, int no ));
SGRHOM *gr_get_homom          _(( GRPDSC *h, LISTP *imlist, int limit ));
GRHOM *gr_lift_control		_(( GRPDSC *h, GRPDSC *k, int limit, 
						    int test_iso, int lookahead, int sublift,
						    int smallgrpring ));
VEC gr_get_image              _(( SGRHOM *rho_rec, VEC el ));
SPACE *gr_vs_image            _(( SGRHOM *rho_rec, SPACE *vs ));
SGRHOM *gr_concatenate        _(( SGRHOM *l, SGRHOM *r ));
SGRHOM *gr_exp_concatenate    _(( SGRHOM *l, int power ));
SGRHOM *gr_inv_concatenate    _(( SGRHOM *l ));
VEC *gr_get_obstructs         _(( GRPDSC *h, VEC rho[], int limit ));







