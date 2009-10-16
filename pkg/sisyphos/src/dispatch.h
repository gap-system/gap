/* 	$Id: dispatch.h,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: dispatch.h,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.1  1995/08/10 12:00:42  pluto
 * 	Removed definition of some constants.
 *
 * 	Revision 3.0  1995/06/23 16:54:27  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *	 */

#define ALL       1
#define OUTER     0

/* arguments for 'use' function */
#define MTABLE    1
#define JTABLE    2

/* arguments for 'show' function */
#define MEMORY    1
#define PRIME     2
#define CUT       3
#define END       4
#define SYMBOLS   5
#define VERSION   6
#define FLAGS     7
#define VERBOSE   8
#define DISSTYLE  9
#define PROMPT    10

/* switches */
#define GRPAUTOS   1
#define NOGRPAUTOS 0
#define ON         1
#define OFF        0

#define FULL       0
#define SMALL      1

/* styles */
#define SBASE      91


