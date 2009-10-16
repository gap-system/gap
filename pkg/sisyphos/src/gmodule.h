/* 	$Id: gmodule.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: gmodule.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/08/10 12:02:02  pluto
 * 	New routines 'gm_sum' and 'gm_dual'.
 *
 * 	Revision 3.0  1995/06/23 16:55:10  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *	 */


typedef struct g_module {
    PCGRPDESC *g;
    int dim;
    VEC *m;
    VEC *echelon;
    VEC T;
    VEC TI;
} GMODULE;

GMODULE *triv_mod                _(( int dim, PCGRPDESC *g ));
GMODULE *tensor_prod             _(( GMODULE *m1, GMODULE *m2,
							  int transpose ));
GMODULE *gm_sum                  _(( GMODULE *m1, GMODULE *m2 ));
GMODULE *ig_op                   _(( PCGRPDESC *g ));
GMODULE *gm_dual                 _(( GMODULE *m ));
void show_gmodule                _(( GMODULE *gm ));
VEC g_op_mat                     _(( GMODULE *gm, PCELEM el,
							  int use_echelon ));
VEC operation_image              _(( GMODULE *gm, VEC v, PCELEM el,
							  int use_echelon ));
void echelonize_module           _(( GMODULE *gm ));






