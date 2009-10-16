/********************************************************************/
/*                                                                  */
/*  Module        : Error                                           */
/*                                                                  */
/*  Description :                                                   */
/*     Handles errors                                               */
/*                                                                  */
/********************************************************************/

/* 	$Id: error.c,v 1.1 2000/10/23 17:05:02 gap Exp $	 */
/* 	$Log: error.c,v $
/* 	Revision 1.1  2000/10/23 17:05:02  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.0  1995/06/23 16:45:25  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.2  1995/01/05  17:12:53  pluto
 * Initial version under RCS control.
 *	 */

#ifndef lint
static char vcid[] = "$Id: error.c,v 1.1 2000/10/23 17:05:02 gap Exp $";
#endif /* lint */

#include "aglobals.h"
#define ALLOC
# include	"error.h"

extern DSTYLE displaystyle;
extern int use_prompt1;

static char *error_msg[] = {
	"no error",
	"undefined expression",
	"expression is not of type 'group'",
	"expression is not of type 'pcgroup'",
	"expression is not of type 'groupring'",
	"expression is not of type 'group element'",
	"expression is not of type 'integer'",
	"expression is not of type 'element of groupring'",
	"expression is not of type 'vectorspace'",
	"expression is not of type 'list'",
	"expression is not of type 'group homomorphisms'",
	"expression is not of type 'group algebra homomorphisms'",
	"expression is not of type 'group algebra homomorphism'",
	"no such homomorphism",
	"incompatible types",
	"incompatible spaces",
	"invalid relation - wrong generator",
	"invalid relation - unexpected character",
	"no generator declaration",
	"no relation declaration",
	"mising '('",
	"invalid generator",
	"invalid separator",
	"invalid relation",
	"invalid pc relation",
	"memory exhausted",
	"temporary memory exhausted",
	"no automorphisms for group",
	"string expected",
	"wrong type",
	"couldn't open file",
	"syntax error",
	"generator may not be reassigned",
	"element is not a unit",
	"division by zero",
	"no jennings weights for group",
	"no inner automorphisms available",
	"identifier is undefined",
	"no such procedure or function",
	"special error: this should not happen"
};
	
void proc_error (void)
{
	char *error_prefix;
	char *warning_prefix;
	
	error_prefix = displaystyle == GAP ? "#E " : "";
	warning_prefix = displaystyle == GAP ? "#W " : "";
	
	if ( error_no != NO_ERROR ) {
	    if ( error_no != SPECIAL_ERROR )
		   fprintf ( stderr, "%sERROR: %s\n", error_prefix, error_msg[error_no] );
		error_no = NO_ERROR;
		use_prompt1 = TRUE;
	}
	else {
		if ( warning_no != NO_ERROR ) {
			fprintf ( stderr, "%sWARNING: %s\n", warning_prefix, error_msg[warning_no] );
			warning_no = NO_ERROR;
		}
	}
}

void set_error ( ERR_MSG error_num  )
{
	if ( error_no == NO_ERROR )
		error_no = error_num;
}

void set_warning ( ERR_MSG error_num )
{
	if ( warning_no == NO_ERROR )
		warning_no = error_num;
}

/* end of module error */

