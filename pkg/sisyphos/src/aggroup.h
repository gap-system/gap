/* 	$Id: aggroup.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: aggroup.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * Revision 1.2  1995/01/05  17:32:07  pluto
 * Initial version under RCS control.
 *	 */

AGGRPDESC *grp_to_aggrp  		_(( GRPDSC *g_desc ));


#define AIDENTITY			(*gcallocate)( aggroup->num_gen )
#define POWERS				aggroup->powers
#define POTS				aggroup->p_list
#define CONJUGATES			aggroup->conjugates
#define AVEC				aggroup->avec
#define ANUMGEN			aggroup->num_gen
#define ACARD				aggroup->group_card
#define ABPERELEM			aggroup->num_gen
#define ANOM				aggroup->nom
#define A_GEN				aggroup->gen
#define AMINGEN			aggroup->min_gen
#define ADEF_LIST			aggroup->def_list
#define ELAB_SERIES			aggroup->elab_series
#define ELAB_LENGTH			aggroup->elab_length

AGGRPDESC *set_ag_group 		_(( AGGRPDESC *ag_group ));
PCELEM agcollect 			_(( PCELEM li, PCELEM r ));
PCELEM ag_invers 			_(( register PCELEM el ));
PCELEM ag_comm 			_(( PCELEM li, PCELEM re ));
PCELEM ag_expo				_(( register PCELEM el, register int power ));
