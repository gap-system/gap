/********************************************************************/
/*                                                                  */
/*  Module        : Scan support                                    */
/*                                                                  */
/*  Description :                                                   */
/*     Supporting utilities used by scanner and readline.           */
/*                                                                  */
/********************************************************************/

/* 	$Id: scansup.c,v 1.1 2000/10/23 17:05:03 gap Exp $	 */
/* 	$Log: scansup.c,v $
/* 	Revision 1.1  2000/10/23 17:05:03  gap
/* 	initial checkin of the original version,
/* 	before changing the GAP 3 interface in a few src files
/* 	to a GAP 4 interface
/* 	
/* 	    TB
/* 	
 * 	Revision 3.3  1995/08/30 12:58:40  pluto
 * 	Corrected wrong name for 'trivialmodule' function.
 *
 * 	Revision 3.2  1995/08/10 14:46:41  pluto
 * 	Updated command list.
 *
 * 	Revision 3.1  1995/06/27 12:21:48  pluto
 * 	Added check for comments and lines consisting entirely of
 * 	white space.
 *
 * 	Revision 3.0  1995/06/23 09:57:21  pluto
 * 	New revision corresponding to sisyphos 0.8.
 *
 * Revision 1.4  1995/04/05  12:51:03  pluto
 * Corrected typo in list of keywords.
 *
 *
 * Revision 1.2  1995/03/20  09:46:36  pluto
 * Initial revision under RCS. Contains support functions for GNU
 * readline, especially for command completion.
 *	 */

#ifndef lint
static char vcid[] = "$Id: scansup.c,v 1.1 2000/10/23 17:05:03 gap Exp $";
#endif /* lint */

#include  "config.h"
#include	"aglobals.h"
#include	<stdlib.h>
#include	"error.h"
#ifdef HAVE_LIBREADLINE
#include  <readline/readline.h>
#include  <readline/history.h>
#endif

int use_prompt1 = TRUE;
char prompt1[20] = "COMMAND> ";
char prompt2[20] = "> ";
extern int quiet;

#ifdef HAVE_LIBREADLINE
char *cmd_completion _(( char *text, int state ));

/* A static variable for holding the line. */
static char *line_read = (char *)NULL;

static char *commands[] = {
"actual",
"address",
"aggroup",
"all",
"annihilator",
"asauto",
"ascii",
"auto",
"automorphisms",
"autspan",
"batch",
"binary",
"cayley",
"centralizer",
"centre",
"closure",
"code",
"cohomology",
"comm",
"complement",
"cut",
"cycles",
"decompose",
"displaystyle",
"dual",
"echelon",
"echo",
"elements",
"end",
"execute",
"extension",
"extorbit",
"fetch",
"flags",
"fpgroup",
"full",
"fundamental",
"gap",
"gmodule",
"grauto",
"griso",
"group",
"grouphom",
"groupring",
"grpautos",
"help",
"homomorphism",
"ideal",
"image",
"images",
"inner",
"interactive",
"isconjugate",
"isomorphic",
"isomorphisms",
"jennings",
"join",
"jseries",
"left",
"length",
"lieideal",
"lieseries",
"lift",
"list",
"load",
"lookahead",
"makecode",
"maximal",
"meet",
"memory",
"minimal",
"modulo",
"multiplication",
"nobase",
"nogrpautos",
"none",
"obstructions",
"off",
"on",
"order",
"outer",
"pcgroup",
"permutations",
"powspace",
"pquotient",
"presentation",
"prime",
"print",
"printgap",
"printrels",
"prompt",
"psi",
"pvmlift",
"quit",
"raise",
"readaggroup",
"readgroup",
"readpcgroup",
"relations",
"reset",
"rho",
"right",
"save",
"set",
"setdomain",
"sgautos",
"show",
"single",
"sisyphos",
"small",
"sorted",
"space",
"span",
"special",
"splitextension",
"standard",
"sublift",
"symbols",
"text",
"trivialmodule",
"twoside",
"unitgroup",
"use",
"verbosity",
"verify",
"version",
"weights",
NULL					
};

int check_line ( void )
{
    char *phash;
    char *nw;

    if ( *line_read ) {
	  phash = strchr ( line_read, '#' );
	  if ( phash != NULL )
		 *phash = '\0';
	  /* only whitespace ? */
	  nw = strpbrk ( line_read,
	       "abcdefghijklmnopqrstuvwxyz,()[]1234567890=\"" );
	  return ( nw != NULL );
    }
    else
	   return ( FALSE );
}

char *do_gets ( char *buf, int max_size  )
{
    char *p;
    size_t l;

    /* If the buffer has already been allocated, return the memory
	  to the free pool. */
    if (line_read != (char *)NULL)
	   {
		  free (line_read);
		  line_read = (char *)NULL;
	   }
    
    /* Get a line from the user. */
    if ( use_prompt1 ) {
	   line_read = readline ( quiet ? "" : prompt1 );
	   use_prompt1 = FALSE;
    }
    else
	   line_read = readline ( quiet ? "" : prompt2 );
    
    /* If the line has any text in it, save it on the history. */
    if (line_read )
	   if ( check_line() ) {
		  l = strlen ( line_read );
		  if ( line_read[l-1] != ' ' ) {
			 line_read = realloc ( line_read, l + 2 );
			 p = strchr ( line_read, '\0' );
			 *p = ' ';
			 *(++p) = '\0';
		  }
		  add_history (line_read);
		  strncpy ( buf, line_read, max_size );
	   }
	   else {
		  buf[0] = '\n';
		  buf[1] = '\0';
		  use_prompt1 = TRUE;
	   }
    else		    
	   buf = NULL;

    return (buf);
}

void initialize_readline ( void )
{
    rl_readline_name = "Sisyphos";
    rl_completion_entry_function = (Function *)cmd_completion;
}

char *dupstr ( char *s )
{
    char *r;

    r = malloc ( strlen(s) + 1 );
    strcpy ( r, s );
    return ( r );
}

char *cmd_completion ( char *text, int state )
{
    static int list_index, len;
    char *name;

    if ( !state ) {
	   list_index = 0;
	   len = strlen ( text );
    }
    
    while ( (name = commands[list_index]) ) {
	   list_index++;
	   if ( strncmp ( name, text, len ) == 0 )
		  return ( dupstr ( name ) );
    }
    return ( NULL );
}
#else
void show_prompt ( void )
{
    if ( !quiet )
	   if ( use_prompt1 ) {
		  fprintf ( stdout, "%s", prompt1 );
		  use_prompt1 = FALSE;
	   }
	   else
		  fprintf ( stdout, "%s", prompt2 );
}
#endif




