
/**************************************************************************

        al2.h
        Colin Ramsay (cram@csee.uq.edu.au)
        25 Feb 00

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
	  Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
        (http://www.csee.uq.edu.au/~havas/cdmc.html)

This is the header file for Level 2 of ACE; that is, a demonstration
application in the form of a stand alone, interactive interface.

**************************************************************************/

#include "al1.h"

#include <setjmp.h>	/* Needed for setjmp/longjmp jmp_buf type */

extern jmp_buf env;	/* Environment for error-recovery jump */

	/******************************************************************
	To ensure that any index reported by the enumerator is correct, we
	must take care that we do not call al0_enum() in an invalid mode.
	If the okstart (okcont, okredo) flag is set, then it is permissible
	to call Level 1/0 in start (continue, redo) mode; although other
	things may have to be checked as well.  Actions of the parser are 
	monitored, and will set/clear the appropriate flags.  All three 
	flags start out FALSE (remember, P^3)!
	******************************************************************/

extern Logic okstart, okcont, okredo;

	/******************************************************************
	In order that we do not do anything `silly' during postprocessing,
	we maintain various status regarding the current state of the 
	table.  lresult is the result of the last call to al1_start().  If
	tabindex is T, then we have a (valid) index.  If tabinfo is T, then
	the table contains valid information; in particular, the SG phase
	has been successfully completed.
	******************************************************************/

extern Logic tabinfo, tabindex;
extern int lresult;

	/******************************************************************
        echo defaults to FALSE, and should be left that way for interactive
        use.  If output is redirected to a file, we might want to set this 
        so that the commands are also logged.  If skipnl is set, then '\n'
	is treated as whitespace (eg, as part of a multiline relator list).
	currip is the current input character, currkey is the current
	command (ie, keyword), and currname is the current name (ie, string
	argument).  currword is the word (group relator/subgroup generator)
	currently being processed, and currsiz is the size of the array
	allocated to currword (_not_ the size of the stored word).  currexp
	is the (most recent) exponent explicitly entered for currword (for 
	tracking involutions).
	******************************************************************/

extern Logic echo, skipnl;
extern int currip;
extern char currkey[64], currname[128];
extern int *currword, currsiz, currexp;

	/******************************************************************
        Various parameters to Level 2 are lists of integers.  We store them
	& their number in these.
	******************************************************************/

extern int intcnt, intarr[32];

	/******************************************************************
        Externally visible functions defined in util2.c
	******************************************************************/

void  al2_init(void);
char *al2_strdup(char*);
int   al2_outlen(int);
void  al2_continue(char*);
void  al2_restart(char*);
void  al2_abort(char*);

void al2_aip(char*);
void al2_aop(char*);

void al2_dump(Logic);
void al2_opt(void);
void al2_help(void);

void al2_nextip(void);
void al2_skipws(void);
void al2_nextnw(void);

	/******************************************************************
        Externally visible functions defined in parser.c
	******************************************************************/

void al2_cmdloop(void);

	/******************************************************************
        Externally visible functions defined in postproc.c
	******************************************************************/

void al2_oo(int);
void al2_sc(int);
void al2_cycles(void);
void al2_normcl(Logic);
void al2_cc(int);
void al2_rc(int,int);
void al2_dw(Wlist*);
void al2_rep(int, int);
void al2_aep(int);

