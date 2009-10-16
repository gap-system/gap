
/**************************************************************************

        ace.c
        Colin Ramsay (cram@csee.uq.edu.au)
        25 Feb 00

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000 
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
          Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

This is the top level stuff for Level 2 of ACE; that is, the standalone,
interactive `demonstration application'.

Historical fact: the first run of ACE's Level 2 interactive interface which
included an actual enumeration (as opposed to just sitting in the main loop
twiddling its thumbs) lasted from 10:56:57am to 10:59:03am on Tues 29th Dec
1998, and took place in the Dept of CS & EE at The Univ of Qld.  The group 
was A_5, over the trivial subgroup, and the correct answer (ie, 60) was 
obtained!

**************************************************************************/

#include "al2.h"

	/******************************************************************
        Stuff declared in al2.h
	******************************************************************/

jmp_buf env;
Logic   okstart, okcont, okredo;
Logic   tabinfo, tabindex;
int     lresult;
Logic   echo, skipnl;
int     currip;
char    currkey[64], currname[128];
int    *currword, currsiz, currexp;
int     intcnt, intarr[32];

	/******************************************************************
        int main(void)

	ACE takes no arguments, and normally returns 0; something -ve will
	be returned on an `error'.  By default, all input is from stdin & 
	all output is to stdout, via the fip/fop Level 0 parameters.
	******************************************************************/

int main(void)
  {
  al2_init();		/* Initialise Levels 2, 1 & 0 (incl. fop/fop) */

  fprintf(fop, "%s        %s", ACE_VER, al0_date());
  fprintf(fop, "=========================================\n");

  /* If we're working on a `normal' Unix box, "uname -n" returns the name 
  of the host, which we print out neatly at the start of a run.  (Of 
  course, we could also access this using the "sys:...;" ACE command.)  If 
  required, define AL2_HINFO in the make file.  We assume that the system()
  call's output will go to fop!  This code could be expanded to print out 
  any other information regarding the current host that is required. */

#ifdef AL2_HINFO
  fprintf(fop, "Host information:\n");
  fflush(fop);
  system("echo \"  name = `uname -n`\"");
#endif

  switch(setjmp(env))
    {
    case 0:			/* First time through */

      /* Level 0 stuff, set to "Default" mode */

      pdefn    = 3;		/* Default is to use the pdl ... */
      ffactor1 = 0;		/* ... with fill factor of ~5(ncol+2)/4 */
      pdsiz1   = 256;		/* ... and a 256 byte list       */

      lahead = 0;		/* We do a CL, not a lookahead */

      dedmode = 4;		/* Process all deductions ... */
      dedsiz1 = 1000;

      /* Level 1 stuff */

      grpname    = al2_strdup("G");		/* Default group name */
      subgrpname = al2_strdup("H");		/* Default subgroup name */

      /* Level 2 stuff */

      break;

    case 1:			/* Non-fatal error (continuable) */

      break;

    case 2:			/* Non-fatal error (restartable) */

      okstart = ((costable != NULL) && (ndgen > 0));
      okcont  = okredo = FALSE;

      tabinfo = tabindex = FALSE;

      break;

    case 3:			/* Fatal error (aborts) */

      fprintf(fop, "=========================================\n");
      fprintf(fop, "%s        %s", ACE_VER, al0_date());

      exit(-1);
      break;

    default:			/* Reality failure */

      fprintf(fop, "** INTERNAL ERROR\n");
      fprintf(fop, "   unknown jump to error handler\n");
      fprintf(fop, "=========================================\n");
      fprintf(fop, "%s        %s", ACE_VER, al0_date());

      exit(-2);
      break;
    }

  /* If costable is NULL at this point, then either this is the first time
  through, or an attempt to allocate the requested workspace has failed.
  In either case, we attempt to allocate the default amount of workspace.
  If this fails, then we terminate extremely prejudicially. */

  if (costable == NULL)
    {
    if ((costable = (int *)malloc(DEFWORK*sizeof(int))) == NULL)
      {
      fprintf(fop, "** MEMORY PROBLEM\n");
      fprintf(fop, "   unable to allocate default workspace\n");
      fprintf(fop, "=========================================\n");
      fprintf(fop, "%s        %s", ACE_VER, al0_date());

      exit(-3);
      }

    workspace = DEFWORK;
    workmult  = 1;

    /* We have a newly allocated table, so start is (maybe) possible.
    Continuing & redoing are not.  The table has no information. */

    okstart = (ndgen > 0);
    okcont  = okredo = FALSE;

    tabinfo = tabindex = FALSE;
    }

  al2_cmdloop();		/* Where it all happens! */

  fprintf(fop, "=========================================\n");
  fprintf(fop, "%s        %s", ACE_VER, al0_date());

  return(0);
  }

