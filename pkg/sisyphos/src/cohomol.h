/* 	$Id: cohomol.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: cohomol.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:54:01  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *	 */


typedef struct cohomol_rec {
    GMODULE *gm;
    int degree;
    int dim;
    int z_dim;
    int module_dim;
    VEC *basis;
} COHOMOLOGY;

void calc_cohomology              _(( int n, PCGRPDESC *g ));
void calc_extorbit                _(( PCGRPDESC *g ));
COHOMOLOGY *cohomology            _(( GMODULE *gm, int n ));
void show_cohomology              _(( COHOMOLOGY *cohomol ));
PCGRPDESC *group_extension        _(( COHOMOLOGY *cohomol, VEC select,
							   char *gname ));
PCGRPDESC *split_extension        _(( GMODULE *gm, char *gname ));


