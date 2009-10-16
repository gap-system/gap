/* 	$Id: aut.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: aut.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/08/10 11:59:04  pluto
 * 	Moved several routines dealing with automorphism groups to 'autgroup'.
 *
 * 	Revision 3.0  1995/06/23 16:53:38  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:27:53  pluto
 * Initial version under RCS control.
 *	 */

typedef struct s_homom {
    struct grpdsc *h;
    struct pcgrpdesc *g;
    int num_images;
    int lift_limit;
    VEC image_list;
} SHOM;

typedef struct {
	PCELEM g;
	PCELEM i_g;
} COUPLE;

int *hom_to_image 				_(( VEC rhov ));
HOM *generate_automorphism_group 	_(( HOM *hom, int only_outer ));
PCELEM image 					_(( VEC rhov, PCELEM el ));
void show_hom 					_(( HOM *hom, char *recdesc ));
void show_aut_pres 			     _(( HOM *hom, int only_outer ));
int prepare_aut 				_(( PCGRPDESC *g_desc ));
VEC c_apply 					_(( int aut_no, VEC cvec ));
VEC n_apply 					_(( int aut_no, VEC nvec, int cut ));
int handle_grp_aut 				_(( VEC rho[], int begin ));
int is_isomorphic 				_(( PCGRPDESC *g1_desc, void *g2_desc, int is_pcgroup, int quotient ));
HOM *isomorphisms 				_(( PCGRPDESC *g_desc, void *h_group, int is_pcgroup, int quotient ));
HOM *automorphisms 				_(( PCGRPDESC *g_desc, int quotient ));
HOM *conv_to_hom                   _(( LISTP *autgens, int list_only ));
SHOM *evaluate_aut                 _(( LISTP *homlist, LISTP *expl, int len ));
SHOM *aut_concatenate              _(( SHOM *l, SHOM *r ));
SHOM *aut_exp_concatenate          _(( SHOM *l, int power ));
SHOM *aut_inv_concatenate          _(( SHOM *l ));
SHOM *aut_homom_fetch              _(( HOM *auts, int class, int no ));
SHOM *get_group_homom              _(( PCGRPDESC *g, LISTP *imlist, GRPDSC *h ));
void aut_show_hom                  _(( SHOM *aut ));
int group_hom_verify               _(( SHOM *f ));







