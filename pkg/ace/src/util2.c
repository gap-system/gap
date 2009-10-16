
/**************************************************************************

        util2.c
        Colin Ramsay (cram@csee.uq.edu.au)
        6 Dec 00

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
          Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

These are the utilities for Level 2 of ACE.

**************************************************************************/

#include "al2.h"

#include <string.h>
#include <ctype.h>
#include <sys/types.h>
#include <time.h>

        /******************************************************************
        void al2_init(void)

        One-off initialisation of the Level 2 stuff, and all lower levels.
	Note that there is no need to initialise, for example, intarr[].
        ******************************************************************/

void al2_init(void)
  {
  al1_init();

  okstart = okcont   = okredo = FALSE;
  tabinfo = tabindex = FALSE;
  lresult = -8192;			/* invalid mode ! */

  echo   = FALSE;
  skipnl = TRUE;

  currip = currkey[0] = currname[0] = '\0';

  currword = NULL;
  currsiz  = currexp = 0;

  intcnt = 0;

  srand((unsigned int)time(NULL));	/* Seed rand() with time */
  }

	/******************************************************************
        char *al2_strdup(char *s)

        strdup() is not ANSI C, so this is our version.  Should we regard
	an error as fatal, and abort?
	******************************************************************/

char *al2_strdup(char *s)
  {
  char *t;

  if ((t = malloc(strlen(s)+1)) == NULL)
    { al2_continue("out of memory in al2_strdup()"); }

  return(strcpy(t,s));
  }

	/******************************************************************
        int al2_outlen(int i)

	Returns the print-length of an integer i (i.e., ~ $\log_{10}i$).
	The int i is assumed to satisfy i >= 0.
	******************************************************************/

int al2_outlen(int i)
  {
  int len = 1;

  while ((i /= 10) != 0)
    { len++; }

  return(len);
  }

/**************************************************************************
All Level 2 errors are filtered by one of the following three handlers. 
These take the appropriate action, and then jump back to the top-level
main() routine; ie, the outermost level of Level 2.  We swallow the 
remainder of any input line (possibly losing some commands); so multi-line 
commands in error may not be properly tidied-up. The question of what
exactly to do if fip/fop are not stdin/stdout is put in the `too hard' 
basket; we simply switch them both back to their defaults.  Note that, 
although the code for _continue() & _restart() is the same, they return to 
different points (& do different things) in main().

Warning: The error-handling is fairly basic, since it's not our intent to
develop a fully-fledged interactive interface.  We simply tidy-up the best
we can and carry on.
**************************************************************************/

	/******************************************************************
	void al2_continue(char *msg)

	An error has occurred, but it doesn't affected the ok... flags, or
	the table's validity.
        ******************************************************************/

void al2_continue(char *msg)
  {
  if (fop != stdout)
    {
    if (fop != NULL)
      { fclose(fop); }
    fop = stdout;
    }
  if (fip != stdin)
    {
    if (fip != NULL)
      { fclose(fip); }
    fip = stdin;
    currip = '\0';
    }

  fflush(fop);
  fprintf(fop, "** ERROR (continuing with next line)\n");
  fprintf(fop, "   %s\n", msg);

  while ( !(currip == '\n' || currip == '\r' || currip == EOF) )
    { al2_nextip(); }

  longjmp(env,1);
  }

	/******************************************************************
	void al2_restart(char *msg)

	Something nasty has happened & we'll be disallowing continue/redo.
        ******************************************************************/

void al2_restart(char *msg)
  {
  if (fop != stdout)
    {
    if (fop != NULL)
      { fclose(fop); }
    fop = stdout;
    }
  if (fip != stdin)
    {
    if (fip != NULL)
      { fclose(fip); }
    fip = stdin;
    currip = '\0';
    }

  fflush(fop);
  fprintf(fop, "** ERROR (restarting with next line)\n");
  fprintf(fop, "   %s\n", msg);

  while ( !(currip == '\n' || currip == '\r' || currip == EOF) )
    { al2_nextip(); }

  longjmp(env,2);
  }

	/******************************************************************
	void al2_abort(char *msg)

	No point in being clever here, we're going to stop.
        ******************************************************************/

void al2_abort(char *msg)
  {
  if (fop != stdout)
    {
    if (fop != NULL)
      { fclose(fop); }
    fop = stdout;
    }
  if (fip != stdin)
    {
    if (fip != NULL)
      { fclose(fip); }
    fip = stdin;
    currip = '\0';
    }

  fflush(fop);
  fprintf(fop, "** ERROR (aborting)\n");
  fprintf(fop, "   %s\n", msg);

  longjmp(env,3);
  }

        /******************************************************************
	void al2_aip(char *name)

	Switch to a new input file.  We abort via _restart() if this is not
	possible, and that call will reset fip/fop properly.
        ******************************************************************/

void al2_aip(char *name)
  {
  /* Close the current input file (unless it is 'stdin'). */

  if (fip != stdin && fip != NULL)  
    { fclose(fip); }
  fip = NULL;

  /* Try to open the new input file (unless it is 'stdin'). */

  if (strcmp(name, "stdin") != 0)  
    { 
    if ((fip = fopen(name, "r")) == NULL)
      { al2_restart("can't open new input, using 'stdin'"); }
    }
  else
    { fip = stdin; }

  currip = '\0'; 			/* Initialise current i/p char. */
  }

        /******************************************************************
	void al2_aop(char *name)

	Switch to a new output file.  We abort via _restart() if this is 
	not possible, and that call will reset fip/fop properly.  Note
	that there is no need to run setvbuf() on stdout, since this was 
	done in the call to al0_init().
        ******************************************************************/

void al2_aop(char *name)
  {
  /* Close the current output file (unless it is 'stdout'). */

  if (fop != stdout && fop != NULL)  
    { fclose(fop); }
  fop = NULL;

  /* Try to open the new output file (unless it is 'stdout'). */

  if (strcmp(name, "stdout") != 0)  
    { 
    if ((fop = fopen(name, "w")) == NULL)
      { fprintf(fop, "can't open new output, using 'stdout'"); }
    else
      { setvbuf(fop, NULL, _IOLBF, 0); }	/* line buffered o/p */
    }
  else
    { fop = stdout; }
  }

        /******************************************************************
        void al2_dump(Logic allofit)

        Dump out the internals of Level 2 of ACE, working through al2.h
        more or less in order.
        ******************************************************************/

void al2_dump(Logic allofit)
  {
  int i;

  fprintf(fop, "  #---- %s: Level 2 Dump ----\n", ACE_VER);

	/* env; - nothing (meaningful) we can do here! */

	/* okstart, okcont, okredo; */
  fprintf(fop, "okstart=%d okcont=%d okredo=%d\n", 
                okstart,   okcont,   okredo);

	/* tabinfo, tabindex, lresult */
  fprintf(fop, "tabinfo=%d tabindex=%d lresult=%d\n", 
                tabinfo,   tabindex,   lresult);

	/* echo, skipnl, currip, currkey, currname; */
  fprintf(fop, "echo=%d skipnl=%d currip=%d", echo, skipnl, currip);
  if (isprint(currip))
    { fprintf(fop, "(%c)\n", currip); }
  else
    { fprintf(fop, "\n"); }
  fprintf(fop, "currkey=%s\n", currkey);
  fprintf(fop, "currname=%s\n", currname);

	/* *currword, currsiz, currexp; */
  fprintf(fop, "currsize=%d currexp=%d currword=", currsiz, currexp);
  if (currword == NULL)
    { fprintf(fop, "NULL"); }
  else
    {
    if (allofit)
      {
      for (i = 0; i < currsiz; i++)
        { fprintf(fop, "%d ", currword[i]); }
      }
    else
      { fprintf(fop, "non-NULL"); }
    }
  fprintf(fop, "\n");

	/* intcnt, intarr[32]; */
  if (intcnt == 0)
    { fprintf(fop, "intcnt=0 (empty)\n"); }
  else
    {
    fprintf(fop, "intcnt=%d intarr[]=", intcnt);
    for (i = 0; i < intcnt; i++)
      { fprintf(fop, "%d ", intarr[i]); }
    fprintf(fop, "\n");
    }

  fprintf(fop, "  #---------------------------------\n");
  }

        /******************************************************************
	void al2_opt(void)

	Pretty-print the date of compilation and all the various options
	included in this build.
        ******************************************************************/

void al2_opt(void)
  {
#ifdef DATE
  fprintf(fop, "%s executable built:\n  %s\n", ACE_VER, DATE);
#else
  fprintf(fop, "%s executable built: ??\n", ACE_VER);
#endif

  fprintf(fop, "Level 0 options:\n");
#ifdef AL0_STAT
  fprintf(fop, "  statistics package = on\n");
#else
  fprintf(fop, "  statistics package = off\n");
#endif
#ifdef AL0_CC
  fprintf(fop, "  coinc processing messages = on\n");
#else
  fprintf(fop, "  coinc processing messages = off\n");
#endif
#ifdef AL0_DD
  fprintf(fop, "  dedn processing messages = on\n");
#else
  fprintf(fop, "  dedn processing messages = off\n");
#endif

  fprintf(fop, "Level 1 options:\n");
#ifdef AL1_BINARY
  fprintf(fop, "  workspace multipliers = binary\n");
#else
  fprintf(fop, "  workspace multipliers = decimal\n");
#endif

  fprintf(fop, "Level 2 options:\n");
#ifdef AL2_HINFO
  fprintf(fop, "  host info = on\n");
#else
  fprintf(fop, "  host info = off\n");
#endif
  }

        /******************************************************************
	void al2_help(void)
        ******************************************************************/

void al2_help(void)
  {
  fprintf(fop, "  #---- %s: Level 2 Help ----\n", ACE_VER);
  fprintf(fop, "add gen[erators] / sg : <word list> ;\n");
  fprintf(fop, "add rel[ators] / rl : <relation list> ;\n");
  fprintf(fop, "aep : 1..7 ;\n");
  fprintf(fop, "ai / alter i[nput] : [<filename>] ;\n");
  fprintf(fop, "ao / alter o[utput] : [<filename>] ;\n");
  fprintf(fop, "as[is] : [0/1] ;\n");
  fprintf(fop, "beg[in] / end / start ;\n");
  fprintf(fop, "bye / exit / q[uit] ;\n");
  fprintf(fop, "cc / coset coinc[idence] : int ;\n");
  fprintf(fop, "c[factor] / ct[ factor] : [int] ;\n");
  fprintf(fop, "check / redo ;\n");
  fprintf(fop, "com[paction] : [0..100] ;\n");
  fprintf(fop, "cont[inue] ;\n");
  fprintf(fop, "cy[cles] ;\n");
  fprintf(fop, "ded mo[de] / dmod[e] : [0..4] ;\n");
  fprintf(fop, "ded si[ze] / dsiz[e] : [0/1..] ;\n");
  fprintf(fop, "def[ault] ;\n");
  fprintf(fop, "del gen[erators] / ds : <int list> ;\n");
  fprintf(fop, "del rel[ators] / dr : <int list> ;\n");
  fprintf(fop, "d[ump] : [0/1/2[,0/1]] ;\n");
  fprintf(fop, "easy ;\n");
  fprintf(fop, "echo : [0/1] ;\n");
  fprintf(fop, "enum[eration] / group name : <string> ;\n");
  fprintf(fop, "fel[sch] : [0/1] ;\n");
  fprintf(fop, "f[factor] / fi[ll factor] : [0/1..] ;\n");
  fprintf(fop, "gen[erators] / subgroup gen[erators] : <word list> ;\n");
  fprintf(fop, "gr[oup generators]: [<letter list> / int] ;\n");
  fprintf(fop, "group relators / rel[ators] : <relation list> ;\n");
  fprintf(fop, "hard ;\n");
  fprintf(fop, "h[elp] ;\n");
  fprintf(fop, "hlt ;\n");
  fprintf(fop, "ho[le limit] : [-1/0..100] ;\n");
  fprintf(fop, "look[ahead] : [0/1..4] ;\n");
  fprintf(fop, "loop[ limit] : [0/1..] ;\n");
  fprintf(fop, "max[ cosets] : [0/2..] ;\n");
  fprintf(fop, "mend[elsohn] : [0/1] ;\n");
  fprintf(fop, "mess[ages] / mon[itor] : [int] ;\n");
  fprintf(fop, "mo[de] ;\n");
  fprintf(fop, "nc / normal[ closure] : [0/1] ;\n");
  fprintf(fop, "no[ relators in subgroup] : [-1/0/1..] ;\n");
  fprintf(fop, "oo / order[ option] : int ;\n");
  fprintf(fop, "opt[ions] ;\n");
  fprintf(fop, "par[ameters] ; - old option (ignored)\n");
  fprintf(fop, "path[ compression] : [0/1] ;\n");
  fprintf(fop, "pd mo[de] / pmod[e] : [0/1..3] ;\n");
  fprintf(fop, "pd si[ze] / psiz[e] : [0/2/4/8/...] ;\n");
  fprintf(fop, "print det[ails] / sr : [int] ;\n");
  fprintf(fop, "pr[int table] : [[-]int[,int[,int]]] ;\n");
  fprintf(fop, "pure c[t] ;\n");
  fprintf(fop, "pure r[t] ;\n");
  fprintf(fop, "rc / random coinc[idences]: int[,int] ;\n");
  fprintf(fop, "rec[over] / contig[uous] ;\n");
  fprintf(fop, "rep : 1..7[,int] ;\n");
  fprintf(fop, "restart ; - old option (ignored)\n");
  fprintf(fop, "r[factor] / rt[ factor] : [int] ;\n");
  fprintf(fop, "row[ filling] : [0/1] ;\n");
  fprintf(fop, "sc / stabil[ising cosets] : int ;\n");
  fprintf(fop, "sims : 1/3/5/7/9 ;\n");
  fprintf(fop, "st[andard table] ;\n");
#ifdef AL0_STAT
  fprintf(fop, "stat[istics] / stats ;\n");
#endif
  fprintf(fop, "style ;\n");
  fprintf(fop, "subg[roup name] : <string> ;\n");
  fprintf(fop, "sys[tem] : <string> ;\n");
  fprintf(fop, "text : <string> ;\n");
  fprintf(fop, "ti[me limit] : [-1/0/1..] ;\n");
  fprintf(fop, "tw / trace[ word] : int,<word> ;\n");
  fprintf(fop, "wo[rkspace] : [int[k/m/g]] ;\n");
  fprintf(fop, "# ... <newline> - a comment (ignored)\n");
  fprintf(fop, "  #---------------------------------\n");
  }

        /******************************************************************
	void al2_nextip(void)

	Primes currip with the next character from fip, if we're not at the
	end-of-file.  Echoes the character if echo is on.
        ******************************************************************/

void al2_nextip(void)
  {
  if (currip != EOF) 
    { 
    currip = fgetc(fip); 

    if (echo && currip != EOF) 
      { fputc(currip, fop); }
    }
  }

        /******************************************************************
	void al2_skipws(void)

	Skip all whitespace characters.
        ******************************************************************/

void al2_skipws(void)
  {
  Logic comment = (currip == '#');

  while ( currip == ' ' || currip == '\t' || comment || 
          (skipnl && (currip == '\n' || currip == '\r')) ) 
    {
    al2_nextip();
    comment = (currip == '#' || 
           (comment && currip != '\n' && currip != '\r' && currip != EOF));
    }
  }

        /******************************************************************
	void al2_nextnw(void)

	Skip to the next non-whitespace character.
        ******************************************************************/

void al2_nextnw(void)
  {
  al2_nextip();
  al2_skipws();
  }


