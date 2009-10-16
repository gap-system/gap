/* version numbers */

/* 	$Id: version.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: version.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 1.3  1995/08/03 14:46:02  pluto
 * 	New version printing routine.
 *
 * 	Revision 1.2  1995/01/05 17:17:18  pluto
 * 	Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: version.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#include <stdio.h>
#include <stddef.h>
#include <time.h>
#include "patchlev.h"
#include "compdate.h"

typedef struct {
	char *module_name;
	char *version_number;
} VERSION;

VERSION version_list[] = {
	{"aut.c","7.6"},
	{"pc.c","3.0"},
	{"conju.c","2.8"},
	{"error.c","4.8"},
	{"farith.c","1.6"},
	{"gl.c","2.0"},
	{"grpring.c","2.0"},
	{"hgroup.c","1.0"},
	{"inout.c","3.7"},
	{"lcontrol.c","6.8"},
	{"lie.c","1.9"},
	{"matrix.c","1.8"},
	{"obslif.c","5.3"},
	{"obstruct.c","3.5"},
	{"parsesup.c","2.4"},
	{"sisgram.y","5.3"},
	{"sisscan.l","3.5"},
	{"solve.c","3.5"},
	{"space.c","2.1"},
	{"storage.c","3.9"},
	{"lex.yy.c","3.5"},
	{"aobstruc.c","3.5"},
};

void old_show_version (void)
{
	size_t num_moduls, i;
	
	num_moduls = sizeof version_list / sizeof ( VERSION );
	
	for ( i = 0; i < num_moduls; i++ )
		printf ( "module %13s : %5s\n", version_list[i].module_name,
			version_list[i].version_number );
	printf ( "\nglobal version number : %s\n", global_version );
}

void show_version ( void )
{
    printf ( "\nVersion:  %s\n", global_version );
    printf ( "Compiled: %s\n\n", date_string );
}
 
/* end of module version */
