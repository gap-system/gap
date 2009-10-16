
/**************************************************************************

        util1.c
        Colin Ramsay (cram@csee.uq.edu.au)
        22 Dec 00

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
          Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

These are the utilities for Level 1 of ACE.

**************************************************************************/

#include "al1.h"

#include <ctype.h>

	/******************************************************************
        void al1_init(void)

        One-off initialisation of the Level 1 stuff, and all lower levels.
	Note that there is no need to initialise, for example, genal[].
	******************************************************************/

void al1_init(void)
  {
  al0_init();

  workspace = DEFWORK;
  workmult  = 1;
  costable  = NULL;
  tabsiz    = 0;

  currrep = NULL;
  repsiz  = repsp = 0;

  asis = FALSE;

  grpname = NULL;
  rellst  = NULL;
  trellen = 0;

  ndgen    = 0;
  geninv   = NULL;
  gencol   = colgen   = NULL;
  galpha   = FALSE;
  algen[0] = algen[1] = '\0';		/* &algen[1] is printable string */

  subgrpname = NULL;
  genlst     = NULL;
  tgenlen    = 0;

  rfactor1 = cfactor1 = 0;
  pdsiz1   = dedsiz1  = 0;
  maxrow1  = ffactor1 = 0;
  nrinsgp1 = -1;
  }

        /******************************************************************
        void al1_dump(Logic allofit)

        Dump out the internals of Level 1 of ACE, working through al1.h
        more or less in order.
        ******************************************************************/

void al1_dump(Logic allofit)
  {
  int i;
  Wlelt *p;

  fprintf(fop, "  #---- %s: Level 1 Dump ----\n", ACE_VER);

	/* workspace, workmult, costable, tabsiz; */
  fprintf(fop, "workspace=%d workmult=%d", workspace, workmult);
  if (costable == NULL)
    { fprintf(fop, " costable=NULL"); }
  else
    { fprintf(fop, " costable=non-NULL"); }
  fprintf(fop, " tabsiz=%d\n", tabsiz);

	/* currrep, repsiz, repsp; */
  if (currrep == NULL)
    { fprintf(fop, "currrep=NULL"); }
  else
    { fprintf(fop, "currrep=non-NULL"); }
  fprintf(fop, " repsiz=%d repsp=%d\n", repsiz, repsp);

	/* LLL, asis */
  fprintf(fop, "LLL=%d, asis=%d\n", LLL, asis);

	/* group: name, generators, geninv */
  if (grpname == NULL)
    { fprintf(fop, "grpname=NULL\n"); }
  else
    { fprintf(fop, "grpname=%s\n", grpname); }

  if (ndgen == 0)
    { fprintf(fop, "ndgen=%d\n", ndgen); }
  else if (galpha)
    {
    fprintf(fop, "ndgen=%d galpha=%d algen[]=", ndgen, galpha);
    for (i = 1; i <= ndgen; i++)
      { fprintf(fop, "%c", algen[i]); } 
    fprintf(fop, "\n");

    if (allofit)
      {
      fprintf(fop, "  genal[]=");
      for (i = 1; i <= 26; i++)
        { fprintf(fop, "%d ", genal[i]); }
      fprintf(fop, "\n");
      }
    }
  else
    { fprintf(fop, "ndgen=%d galpha=%d\n", ndgen, galpha); }

  if (geninv == NULL)
    { fprintf(fop, "geninv=NULL\n"); }
  else
    {
    fprintf(fop, "geninv[]=");
    for (i = 1; i <= ndgen; i++)
      { fprintf(fop, "%d ", geninv[i]); } 
    fprintf(fop, "\n");
    }

	/* gencol, colgen */
  if (gencol == NULL)
    { fprintf(fop, "gencol=NULL\n"); }
  else
    {
    fprintf(fop, "gencol[]=");
    for (i = -ndgen; i <= -1; i++)
      { fprintf(fop, "%d ", gencol[ndgen+i]); } 
    fprintf(fop, "x ");
    for (i = 1; i <= ndgen; i++)
      { fprintf(fop, "%d ", gencol[ndgen+i]); } 
    fprintf(fop, "\n");
    }
  if (colgen == NULL)
    { fprintf(fop, "colgen=NULL\n"); }
  else
    {
    fprintf(fop, "colgen[]=");
    for (i = 1; i <= ncol; i++)
      { fprintf(fop, "%d ", colgen[i]); } 
    fprintf(fop, "\n");
    }

	/* group relators + trellen */
  if (rellst == NULL)
    { fprintf(fop, "rellst=NULL trellen=%d\n", trellen); }
  else if (rellst->len == 0)
    { fprintf(fop, "rellst->len=0 trellen=%d\n", trellen); }
  else
    {
    fprintf(fop, "rellst->len=%d trellen=%d\n", rellst->len, trellen);
    if (allofit)
      {
      fprintf(fop, "  len    exp    inv    word\n");
      for (p = rellst->first;  ; p = p->next)
        { 
        fprintf(fop, "  %3d    %3d    %3d    ", p->len, p->exp, p->invol);
        for (i = 1; i <= p->len; i++)
          { fprintf(fop, "%d ", p->word[i]); }
        fprintf(fop, "\n");

        if (p == rellst->last)
          { break; }
        }
      }
    }

	/* subgroup: name */
  if (subgrpname == NULL)
    { fprintf(fop, "subgrpname=NULL\n"); }
  else
    { fprintf(fop, "subgrpname=%s\n", subgrpname); }

	/* subgroup generators + tgenlen */
  if (genlst == NULL)
    { fprintf(fop, "genlst=NULL tgenlen=%d\n", tgenlen); }
  else if (genlst->len == 0)
    { fprintf(fop, "genlst->len=0 tgenlen=%d\n", tgenlen); }
  else
    {
    fprintf(fop, "genlst->len=%d tgenlen=%d\n", genlst->len, tgenlen);
    if (allofit)
      {
      fprintf(fop, "  len    exp    inv    word\n");
      for (p = genlst->first;  ; p = p->next)
        { 
        fprintf(fop, "  %3d    %3d    %3d    ", p->len, p->exp, p->invol);
        for (i = 1; i <= p->len; i++)
          { fprintf(fop, "%d ", p->word[i]); }
        fprintf(fop, "\n");

        if (p == genlst->last)
          { break; }
        }
      }
    }

	/* rfactor1, cfactor1 */
  fprintf(fop, "rfactor1=%d cfactor1=%d\n", rfactor1, cfactor1);

	/* pdsiz1, dedsiz1 */
  fprintf(fop, "pdsiz1=%d dedsiz1=%d\n", pdsiz1, dedsiz1);

	/* maxrow1, ffactor1, nrinsgp1 */
  fprintf(fop, "maxrow1=%d ffactor1=%d nrinsgp1=%d\n", 
                maxrow1,   ffactor1,   nrinsgp1);

  fprintf(fop, "  #---------------------------------\n");
  }

	/******************************************************************
	void al1_prtdetails(int bits)

	This prints out details of the Level 0 & 1 settings, in a form 
	suitable for reading in by applications using the core enumerator 
	plus its wrapper (eg, ACE Level 2).  If bits is 0, then enum, rel,
	subg & gen are printed.  If 1 then *all* of the presentation and
	the enumerator control settings (this allows the run to be 
	duplicated at a later date).  If bits is 2-5, then only enum, rel,
	subg & gen, respectively, are printed.  This routine is really 
	intended for the ACE Level 2 interface, where some items cannot be 
	examined by invoking them with an empty argument.  However it is 
	put here (at Level 1), since it is a useful utility for any 
	application.

	If messaging in on, this routine (with bits 1) is called by 
	al1_start() after all the setup & just before the call to 
	al0_enum().  So it shows what the parameters actually were.  They
	may not match what you thought they were, since the Level 1 wrapper
	(which interfaces between applications (ie, ACE's Level 2 
	interactive interface) and the Level 0 enumerator) trys to prevent 
	errors, and may occasionally ignore or change something.  If you
	call this after changing parameters, but before calling _start(), 
	the values do *not* reflect the new values.  If you want to see
	what the Level 2 parameters are (as opposed to the current Level 0
	parameters), use the `empty argument' form of the commands, or the 
	"sr;" Level 2 command (which invokes this function with bits 
	false.

	To *exactly* duplicate a run, you may need to duplicate the entire 
	sequence of commands since ACE was started, the execution 
	environment, and use the same executable; but that's a project for 
	some rainy Sunday afternoon sometime in the future.  However do
	note that the allocation of generators to columns may have upset 
	your intended handling of involutions and/or the ordering of the
	generators; do a (full) Level 0/1 dump to check this, if you care!
	In particular, the value of asis is the *current* value, which may
	not match that when the call to _start() which allocated columns &
	determined which generators will be involutions was made.
	******************************************************************/

void al1_prtdetails(int bits)
  {
  if (bits < 2)
    { fprintf(fop, "  #--- %s: Run Parameters ---\n", ACE_VER); }

  if (bits == 0 || bits == 1 || bits == 2)
    {
    if (grpname != NULL)
      { fprintf(fop, "Group Name: %s;\n", grpname); }
    else
      { fprintf(fop, "Group Name:  ;\n"); }
    }

  if (bits == 1)
    {
    if (ndgen > 0)
      {
      fprintf(fop, "Group Generators: ");
      if (!galpha) 
        { fprintf(fop, "%d", ndgen); }
      else 
        { fprintf(fop, "%s", &algen[1]); }
      fprintf(fop, ";\n");
      }
    }

  if (bits == 0 || bits == 1 || bits == 3)
    {
    if (rellst != NULL)
      { 
      fprintf(fop, "Group Relators: ");
      al1_prtwl(rellst, 16);
      fprintf(fop, ";\n");
      }
    else
      { fprintf(fop, "Group Relators: ;\n"); }
    }

  if (bits == 0 || bits == 1 || bits == 4)
    {
    if (subgrpname != NULL)
      { fprintf(fop, "Subgroup Name: %s;\n", subgrpname); }
    else
      { fprintf(fop, "Subgroup Name: ;\n"); }
    }

  if (bits == 0 || bits == 1 || bits == 5)
    {
    if (genlst != NULL)
      { 
      fprintf(fop, "Subgroup Generators: ");
      al1_prtwl(genlst, 21);
      fprintf(fop, ";\n");
      }
    else
      { fprintf(fop, "Subgroup Generators: ;\n"); }
    }

  if (bits == 1)
    {
    switch (workmult)
      {
      case 1:
        fprintf(fop, "Wo:%d;", workspace);
        break;
      case KILO:
        fprintf(fop, "Wo:%dK;", workspace);
        break;
      case MEGA:
        fprintf(fop, "Wo:%dM;", workspace);
        break;
      case GIGA:
        fprintf(fop, "Wo:%dG;", workspace);
        break;
      }
    fprintf(fop, " Max:%d;", maxrow);
    if (msgctrl)
      {
      if (msghol)
        { fprintf(fop, " Mess:-%d;", msgincr); }
      else
        { fprintf(fop, " Mess:%d;", msgincr); }
      }
    else
      { fprintf(fop, " Mess:0;"); }
    fprintf(fop, " Ti:%d; Ho:%d; Loop:%d;\n", tlimit, hlimit, llimit);

    if (asis)
      { fprintf(fop, "As:1;"); }
    else
      { fprintf(fop, "As:0;"); }
    if (pcomp)
      { fprintf(fop, " Path:1;"); }
    else
      { fprintf(fop, " Path:0;"); }
    if (rfill)
      { fprintf(fop, " Row:1;"); }
    else
      { fprintf(fop, " Row:0;"); }
    if (mendel)
      { fprintf(fop, " Mend:1;"); }
    else
      { fprintf(fop, " Mend:0;"); }
    fprintf(fop, " No:%d; Look:%d; Com:%d;\n", nrinsgp, lahead, comppc);

    /* Note that we printout using the aliases, since we want to know (or,
    at least, be able to deduce) what style was used.  Note that, although
    ffactor is a float, the Level 1 (& Level 2) interfaces use ffactor1,
    which is an int.  So we need to convert for printout, to maintain the
    ability to read the output back in. */

    fprintf(fop, "C:%d; R:%d; Fi:%d;", cfactor1, rfactor1, (int)ffactor);
    fprintf(fop, " PMod:%d; PSiz:%d; DMod:%d;", pdefn, pdsiz, dedmode);
    fprintf(fop, " DSiz:%d;\n", dedsiz);
    }

  if (bits < 2)
    { fprintf(fop, "  #---------------------------------\n"); }
  }

	/******************************************************************
        void al1_rslt(int rslt)

        Pretty-print the result of a run of al1_start().  If there were no
	problems at Level 1, this will just be the result of the call to
	al0_enum(), printed via al0_rslt().
	******************************************************************/

void al1_rslt(int rslt)
  {
  if (rslt > -8192)
    { al0_rslt(rslt); }
  else
    {
    switch(rslt)
      {
      case -8194:  fprintf(fop, "TABLE TOO SMALL\n");           break;
      case -8193:  fprintf(fop, "MEMORY PROBLEM\n");            break;
      case -8192:  fprintf(fop, "INVALID MODE\n");              break;
         default:  fprintf(fop, "UNKNOWN ERROR (%d)\n", rslt);  break;
      }  
    }
  }

/**************************************************************************
These are the utilities for the simple list manipulation package used to
handle the group's relators & the subgroup's generators.  Note that it is
up to the caller to catch any errors (flagged by the return values).
**************************************************************************/

	/******************************************************************
        Wlist *al1_newwl(void)

        Creates a new (empty) word list.  Returns NULL on failure.
	******************************************************************/

Wlist *al1_newwl(void)
  {
  Wlist *p = (Wlist *)malloc(sizeof(Wlist));

  if (p != NULL)
    {
    p->len   = 0;
    p->first = p->last = NULL;
    }

  return(p);
  }

	/******************************************************************
        Wlelt *al1_newelt(void)

        Creates a new (empty) word-list element.  Returns NULL on failure.
	******************************************************************/

Wlelt *al1_newelt(void)
  {
  Wlelt *p = (Wlelt *)malloc(sizeof(Wlelt));

  if (p != NULL)
    {
    p->word  = NULL;
    p->len   = p->exp = 0;
    p->invol = FALSE;
    p->next  = NULL;
    }

  return(p);
  }

	/******************************************************************
        void al1_addwl(Wlist *l, Wlelt *w)

        Adds a word (if it's non-null & non-empty) to a word list. l must
	be non-null, but may be empty.
	******************************************************************/

void al1_addwl(Wlist *l, Wlelt *w)
  {
  if (w == NULL || w->len == 0)		/* ignore null/empty words */
    { return; }

  if (l->len == 0)
    { l->first = w; }			/* add word to start of list */
  else
    { l->last->next = w; }		/* add word to end of list */

  l->last = w;
  l->len++;
  }

	/******************************************************************
	void al1_concatwl(Wlist *l, Wlist *m);

	Concatenate m's list to l's, and delete m's header node.  Note that
	l is guaranteed non-null, but may be empty.  m may be null, empty,
	or contain data. 
	******************************************************************/

void al1_concatwl(Wlist *l, Wlist *m)
  {
  if (m == NULL)
    { return; }
  else if (m->len == 0)
    {
    free(m);
    return;
    }

  /* If we get here, m contains data */

  if (l->len == 0)		/* l is empty */
    {
    l->len   = m->len;
    l->first = m->first;
    l->last  = m->last;
    }
  else				/* l is non-empty */
    {
    l->len       += m->len;
    l->last->next = m->first;
    l->last       = m->last;
    }

  free(m);
  }

	/******************************************************************
	void al1_emptywl(Wlist *l)

	Delete the list of words in l, leaving l as an empty list.  Does
	*not* delete the storage for l.
	******************************************************************/

void al1_emptywl(Wlist *l)
  {
  Wlelt *p, *q;

  if (l == NULL || l->len == 0)
    { return; }

  for (p = l->first; p != NULL; )
    {
    q = p->next;

    if (p->word != NULL)
      { free(p->word); }
    free(p);

    p = q;
    }

  l->len   = 0;
  l->first = l->last = NULL;
  }

	/******************************************************************
	void al1_prtwl(Wlist *l, int n)
        
	Attempt to pretty-print a list of group relators or subgroup
        generators within the allowed (i.e., LLL) number of columns.  n is 
        the current output column.  (Not quite sure how this would cope
        with a really nasty presentation!)  Note that this prints out words
        in exp form.  If no enumeration has yet been run, exp is at its
        default of 1, so a printout will not be `exponentiated'.  Note that
	relators of the form xx are *always* printed out in the form (x)^2
	*if* they were entered thus; in all other cases they are printed as
	xx.  This is to preserve the ability to specify whether or not a
	generator should be treated as an involution when asis is true.

	Warning: if the list contains any empty words superfluous commas
	may be introduced, rendering the list `invalid' to the Level 2 
	input parser!  If _start() has been called in start/redo mode, then
	the relator & generator lists are guaranteed to be free of empty
	word (although they may contain duplicates). 
	******************************************************************/

void al1_prtwl(Wlist *l, int n)
  {
  Wlelt *e;
  int elen, eexp;
  int i, len;
  char c;

  if (l == NULL || l->len == 0)
    { return; }

  for (e = l->first; e != NULL; e = e->next) 
    {
    elen = e->len;			/* Alias e->len & e->exp ... */
    eexp = e->exp;

    if (elen == 2 && e->word[1] == e->word[2])
      {					/* ... adjust them if involn */
      if (e->invol)
        { eexp = 2; }
      else
        { eexp = 1; }
      }

    len = elen/eexp;

    if (!galpha) 
      {						/* numeric generators */
      if (eexp == 1) 
        { 
        n += 2 + len*2;				/* +2 for \ , *2 for \ n */
        if (n > LLL) 
          { 
          fprintf(fop, "\n  "); 
          n = 2+2 + len*2; 
          } 
        }
      else 
        {
        n += 2+4 + len*2; 			/* 4 for ()^e */ 
        if (n > LLL) 
          { 
          fprintf(fop, "\n  "); 
          n = 4+4 + len*2; 
          } 
        fprintf(fop, "(");  
        }

      for (i = 1; i <= len; i++) 
        { fprintf(fop, "%d ", e->word[i]); }

      if (eexp != 1) 
        { fprintf(fop, ")^%d", eexp); }
      if (e->next != NULL && len != 0)		/* len = 0 not poss? */
        { fprintf(fop, ", "); }
      }
    else 
      {              				/* alphabetic generators */
      if (eexp == 1) 
        { 
        n += 2 + len;
        if (n > LLL) 
          { 
          fprintf(fop, "\n  "); 
          n = 2+1 + len; 
          } 
        }
      else 
        {
        n += 2+4 + len;          		/* 4 for ()^x */ 
        if (n > LLL) 
          { 
          fprintf(fop, "\n  "); 
          n = 3+4 + len; 
          } 
        fprintf(fop, "(");  
        }

      for (i = 1; i <= len; i++) 
        { 
        c = (e->word[i] > 0) ? algen[e->word[i]] 
                                 : toupper(algen[-e->word[i]]);
        fprintf(fop, "%c", c);
        }

      if (eexp != 1) 
        { fprintf(fop, ")^%d", eexp); }
      if (e->next != NULL && len !=0) 
        { fprintf(fop, ", "); }
      }
    }
  }

/**************************************************************************
These are the utilities for handling coset representatives.
**************************************************************************/

	/******************************************************************
	Logic al1_addrep(int col)

	Add #col to the current rep've, possibly extending its storage.
	Fails if we can't allocate memory.
	******************************************************************/

Logic al1_addrep(int col)
  {
  if (currrep == NULL)
    {
    repsp = 8;
    if ((currrep = (int*)malloc(repsp*sizeof(int))) == NULL)
      {
      repsiz = repsp = 0;
      return(FALSE);
      }
    }
  else if (repsiz == repsp)	/* current entries are 0..repsiz-1 */
    {
    repsp *= 2;
    if ((currrep = (int*)realloc(currrep, repsp*sizeof(int))) == NULL)
      {
      repsiz = repsp = 0;
      return(FALSE);
      }
    }

  currrep[repsiz++] = col;
  return(TRUE);
  }

	/******************************************************************
	Logic al1_bldrep(int cos)

	Traces back through the table, building up a rep've of #cos in
	currrep.  The rep've is in terms of column numbers, and is 
	guaranteed to be the `canonic' rep've (ie, first in `length + col 
	order' order) in terms of the *current* table.  The table may or 
	may not be compact/standard.  If the table is compact & standard,
	then the rep've is guaranteed to be `really' canonic, independant 
	of the details of the enumeration.  Fails if _addrep() fails.

	The order of the columns is *not* constrained in any way (apart
	from the col 1/2 stuff), so we have to be careful to pick up the
	1st col (ie, scol) in order (*after* they have been inverted) if 
	more than one entry in a row is minimal.

	Note that our ability to backtrace is predicated on the fact that 
	the first definition of a coset is always in terms of a lower-
	numbered coset, and during coinc processing we keep the lower-
	numbered coset & move data from the higher to the lower.  So each
	coset's row, apart from #1, *must* contain a lower-numbered entry.
	In this routine we *assume* that this property of the table has not
	been compromised in any way; if it has, then the behaviour is 
	undefined.
	******************************************************************/

Logic al1_bldrep(int cos)
  {
  int low, slow, col, scol, i;

  repsiz = 0;
  if (cos <= 1 || cos >= nextdf || COL1(cos) < 0)
    { return(TRUE); }

  low = slow = cos;
  while (low > 1)
    {
    scol = 0;
    for (col = 1; col <= ncol; col++)
      {
      if ((i = CT(low,col)) > 0)
        {
        if (i < slow)				/* Lower row number found */
          {
          slow = i;
          scol = col;
          }
        else if (i == slow && scol != 0)	/* Same row & slow < low */
          {					/* ... earlier column? */
          if (invcol[col] < invcol[scol])
            { scol = col; }
          }
        }
      }

    /* Add it (increases repsiz); note the column inversion!  Failure sets 
    repsiz to 0 */

    if (!al1_addrep(invcol[scol]))
      { return(FALSE); }

    low = slow;
    }

  /* Reverse representative (note: inversion already done) */

  for (i = 1; i <= repsiz/2; i++) 
    {
    col  = currrep[i-1]; 
    scol = currrep[repsiz-i];

    currrep[i-1]      = scol; 
    currrep[repsiz-i] = col;
    }

  return(TRUE);
  }

	/******************************************************************
	int al1_trrep(int cos)

	Traces currrep, starting at #cos.  Returns 0 on redundant cosets, 
	on empty slot, or if there's no rep've.
	******************************************************************/

int al1_trrep(int cos)
  {
  int i;

  if (repsiz == 0)
    { return(0); }

  for (i = 0; i < repsiz; i++)
    {
    if ((COL1(cos) < 0) || ((cos = CT(cos,currrep[i])) == 0))
      { return(0); }
    }

  return(cos);
  }

	/******************************************************************
	int al1_ordrep(void)

	Traces currrep repeatedly until we arrive back at #1, or an empty
	slot.  The number of times round the loop is the order; return 0 if
	the tracing doesn't complete or the rep is empty.  Note that
	termination is guaranteed, since the table is finite!
	******************************************************************/

int al1_ordrep(void)
  {
  int i,j;

  if (repsiz == 0)
    { return(0); }

  for (i = j = 1;  ; j++)
    {
    if ((i = al1_trrep(i)) == 1)
      { return(j); }
    else if (i == 0)
      { return(0); }
    }

  return(0);		/* Can't get here; prevent compiler whinging */
  }

	/******************************************************************
	void al1_prtct(int f, int l, int s, Logic c, Logic or)

	This is a general-purpose coset table printer.  It prints rows from
	f[irst] to l[ast] inclusive, in steps of s.  On a bad value, we try
	to do the `right' thing.  If c[oinc] is true then the print-out 
	includes coincident rows, else not; we skip the appropriate number 
	of rows whatever the c flag is.  If or is true then the order and 
	a representative are printed.  The rep've is found via a backtrace 
	of the table; if the table is in standard form, this rep will be 
	minimal & the `first' in `order' (length + *column* order).  Note 
	that the table may or may not have been compacted and/or 
	standardised.

	Warnings/Notes:
	i) If you print entries >999999, then the neatly aligned columns
	will be lost, although the entries *will* be spaced.
	ii) _bldrep() can fail.  Most probably due to a lack of memory, but
	also if the table is `corrupt' or it is called `inappropriately'.
	In this situation we should perhaps alert the user, but we choose
	simply to print `?'s instead!
	******************************************************************/

void al1_prtct(int f, int l, int s, Logic c, Logic or)
  {
  int i, j, row;

  if (f < 1)
    { f = 1; }
  if (l > nextdf-1)
    { l = nextdf-1; }
  if (s < 1)
    { s = 1; }

  fprintf(fop, " coset |");		/* above coset number */
  if (!galpha)
    {
    for (i = 1; i <= ncol; i++) 
      { fprintf(fop, " %6d", colgen[i]); }
    }
  else
    {
    for (i = 1; i <= ncol; i++) 
      { fprintf(fop, "      %c", (colgen[i] > 0) 
                        ? algen[colgen[i]] : toupper(algen[-colgen[i]])); }
    }
  if (or) 
    { fprintf(fop,"   order   rep've"); }
  fprintf(fop, "\n");

  fprintf(fop, "-------+");
  for (i = 1; i <= ncol; i++) 
    { fprintf(fop, "-------"); }
  if (or) 
    { fprintf(fop,"-----------------"); }
  fprintf(fop, "\n");

  row = f;
  if (!c)
    {
    while (row < nextdf && COL1(row) < 0)
      { row++; }
    }
  while (row <= l)
    {
    fprintf(fop, "%6d |", row);
    for (i = 1; i <= ncol; i++) 
      { fprintf(fop, " %6d", CT(row,i)); }
    if (or && row != 1)
      {
      if (COL1(row) < 0)
        { fprintf(fop, "       -   -"); }
      else
        {
        if (al1_bldrep(row))
          {
          fprintf(fop, " %7d   ", al1_ordrep());
          for (i = 0; i < repsiz; i++)
            {
            j = colgen[currrep[i]];		/* generator number */
            if (!galpha)
              { fprintf(fop, "%d ", j); }
            else
              { fprintf(fop, "%c", 
                             (j > 0) ? algen[j] : toupper(algen[-j])); }
            }
          }
        else
          { fprintf(fop, "       ?   ?"); }
        }
      }
    fprintf(fop, "\n");

    /* If we're printing *all* rows, we can just incr row by s.  If not, we
    have to jump over non-redundant rows. */

    if (c)
      { row += s; }
    else
      {
      for (i = 1; i <= s; i++)
        {
        row++;
        while (row < nextdf && COL1(row) < 0)
          { row++; }
        if (row == nextdf)
          { break; }
        }
      }
    }
  }

