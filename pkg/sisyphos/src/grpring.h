/* 	$Id: grpring.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: grpring.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:56:14  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:27:23  pluto
 * Initial version under RCS control.
 *	 */

extern VEC (*group_mul)	_(( VEC vec1, VEC vec2, int cut ));
extern VEC (*cgroup_mul)	_(( VEC vec1, VEC vec2 ));
extern VEC (*group_exp)	_(( VEC vec, int power, int cut ));

void word_write 		_(( PCELEM elem ));
GRPRING *set_groupring 	_(( PCGRPDESC *g_desc ));
VEC *gr_star             _(( VEC vec, int cut ));
