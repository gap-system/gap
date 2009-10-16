
/**************************************************************************

        util0.c
        Colin Ramsay (cram@csee.uq.edu.au)
        20 Dec 00

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
          Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

These are some utilities for Level 0 of ACE.

**************************************************************************/

#include "al0.h"

	/******************************************************************
	We seem to need sys/types.h & time.h (for the system call time()).
	On other flavours of Unix, we might need sys/time.h.
	******************************************************************/

#include <sys/types.h>
#include <time.h>

	/******************************************************************
	char *al0_date(void)

	Gets the system date/time, and converts it to ASCII string.  Note
	that this includes a trailing '\n'.
	******************************************************************/

char *al0_date(void)
  {
  time_t t = time(NULL);
  return ctime(&t);
  }

	/******************************************************************
	double al0_clock(void)

	clock() returns the actual cpu time used, in seconds, since this
	process started.  It's equivalent to the `user' time in the `time' 
	system command.  Type clock_t is usually defined as a (signed) 
	long, but seems to actually be a 32-bit unsigned - we try our best 
	to preserve all information over a variety of machines!  Note that 
	64-bit machines may sign extend, hence the truncation.  
	CLOCKS_PER_SEC (usually 1000000, but may be 100 on a PC) converts 
	clock() to seconds.  Note that, even if CLOCKS_PER_SECOND > 100, 
	resolution may only be 10mS (i.e., 100Hz system clock).
	******************************************************************/

double al0_clock(void)
  {
  unsigned long ulc = 0xffffffffUL & (unsigned long)clock();

  return (double)ulc/(double)CLOCKS_PER_SEC;
  }

	/******************************************************************
	double al0_diff(double c1, double c2)

	We assume that c1/c2 are values from al0_clock().  This routine 
	finds the difference between two times, by assuming that either 0 
	or 1 `overflow' has taken place.  double's are used for all timing
	to allow (long) times to be properly processed.  Provided that the 
	run is `short' (w.r.t. to the normal rollover interval of 71m35s) 
	or that progress messages are output `frequently', then the
	difference will be correct.  On long runs with few messages, then 
	the difference may be incorrect.
	******************************************************************/


double al0_diff(double c1, double c2)
  {
  double clkroll = ((double)65536*(double)65536)/(double)CLOCKS_PER_SEC;

  if (c2 >= c1)
    { return (c2-c1); }
  else
    { return (clkroll - c1 + c2); }
  }

	/******************************************************************
	void al0_init(void)

	One-off initialisation of the Level 0 stuff.  Ensures a valid
	initial state, and sets defaults (default setting is roughly 
	equivalent to the "def" option of Level 2).  Does _not_ allocate /
	free memory, so it's up to the user (in practice, usually the Level
	1 wrapper routines) to make sure memory's allocated and to properly
	free it to prevent memory leakage.  It's not really necessary to 
	set _everything_ here, but we do anyway, since we adhere to the 
	P^3 Principle (ie, paranoia prevents problems)!
	******************************************************************/

void al0_init(void)
  {
  fop = stdout;
  fip = stdin;
  setvbuf(stdout, NULL, _IOLBF, 0);		/* line buffer o/p */

  begintime = endtime = deltatime = totaltime = 0.0;
  msgctrl   = msghol  = FALSE;
  msgincr   = msgnext = -1;

  mendel = FALSE;
  rfill  = TRUE;
  pcomp  = FALSE;

  maxrow  = 0;
  rfactor = 200;
  cfactor = 1000;
  comppc  = 10;
  nrinsgp = 0;
  lahead  = 1;

  tlimit = -1;
  hlimit = -1;
  llimit = lcount = 0;

  nalive = maxcos = totcos = 1;

  chead = ctail = 0;

  pdefn   = pdsiz  = 0;
  ffactor = 0.0;
  pdqcol  = pdqrow  = NULL;
  toppd   = botpd   = 0;

  dedsiz  = 0;
  dedrow  = dedcol = NULL;
  topded  = -1;
  dedmode = 0;
  disded  = FALSE;

  edp = edpbeg = edpend = NULL;

  ncol    = 0;
  colptr  = NULL;
  col1ptr = col2ptr = NULL;
  invcol  = NULL;

  ndrel  = 0;
  relind = relexp = rellen = relators = NULL;

  nsgpg   = 0;
  subggen = subgindex = subglength = NULL;
  sgdone  = FALSE;

  knr    = knh = 1;
  nextdf = 2;
  }

	/******************************************************************
	Logic al0_compact(void)

	Remove unused rows from the coset table, by closing up all used
	rows to the front.  (This is _not_ the same as putting the table
	into its canonic form!)  To maintain data-structure consistency,
	the pdq is cleared & any stored deductions/coincidences should be
	discarded.  The pdq entries don't matter, but throwing away
	unprocessed deductions or coincidences is _not_ a good thing.  It 
	is the _caller's_ responsibility to ensure that this routine isn't 
	called when there are outstanding deductions/coincidences or, if
	it is, that `appropriate' action is taken.  We return TRUE if we
	actually did any compaction, else FALSE.

	In fact, we fully process all coincidences immediately.  So,
	outside of the coincidence processing routine, the coinc queue is 
	always empty.  Since al0_compact isn't called during coincidence
	handling, we're ok there.  As for deductions, we _could_ work thro
	the queue repeatedly as we compact, resetting the stored coset 
	numbers to their adjusted values, but we don't (v. expensive).  We 
	just throw any outstanding deductions away, noting this in disded.
	We worry later (if we get a finite result) about whether or not we
	have to do any extra work to check whether this cavalier attitude 
	was `justified'.

	Note that this routine is called `on-the-fly' by some of the Level
	2 options.  It can also be called directly by the rec[over] option.
	******************************************************************/

Logic al0_compact(void)
  {
  int i, j, irow, col;
  int knra, knha;

  /* Table is already compact, do nothing. */
  if (nalive == nextdf-1) 
    { return(FALSE); }

  /* Clear any preferred definitions on their queue. */
  toppd = botpd = 0;

  /* Throw away (after logging) any outstanding deductions. */
  if (topded >= 0) 
    { 
    disded = TRUE;
    topded = -1;
    }

  /* Zero the counters for knr/knh adjustment.  Note that we can't adjust
  these as we go, since it's their _original_ values which are relevant. */

  knra = knha = 0;

  /* Set irow to the lowest redundant coset (which is _never_ #1). */

  for (irow = 2; irow < nextdf; irow++) 
    { 
    if (COL1(irow) < 0) 
      { break; }
    }

  /* Compact the coset table. */

  for (i = irow; i < nextdf; i++)
    {
    if (COL1(i) < 0) 
      { 
      if (i <= knr) 
        { knra++; }
      if (i <= knh) 
        { knha++; }  
      }
    else 
      {				/* Convert row i to row irow. */
      for (col = 1; col <= ncol; col++) 
        {
        if ((j = CT(i, col)) != 0) 
          {
          if (j == i)  
            { j = irow; }
          else 
            { CT(j, invcol[col]) = irow; }
          }
        CT(irow, col) = j;
        }
      irow++;
      }
    }

  knr -= knra;			/* Adjust counters */
  knh -= knha; 
 
  nextdf = irow;		/* 1st unused row */

  return(TRUE);
  }

        /******************************************************************
        Logic al0_stdct(void)

	This companion programme to _compact() puts the table into standard
	form.  This form is based on the order of the generators in the 
	table, but is otherwise fixed for a given group/subgroup; it's
	independant of the details of an enumeration.  It allows canonic 
	rep'ves to be picked off by back-tracing (see al1_bldrep()).  We 
	chose _not_ to combine _stdct() & _compact() into one routine, 
	since the core enumerator may compact (more than once) & we don't 
	want to impact it's speed with `unnecessary' work.  After an 
	enumeration completes, a single call of _compact() & then of 
	_stdct() gives a hole-free, standardised table.  We can standardise
	holey-tables, but the result is only unique up to the set of coset
	labels in use. 

	Similar remarks to those in _compact() regarding pdefns, dedns,
	coincs, etc., etc. apply here.  We return true if we actually
	change anything, else false.  We do the work in two stages, since
	we want to avoid (possibly) throwing away dedns if we can avoid it.
	Note that we have to do some work even if the table is already 
	standardised, since there is no quick way to check this.  However,
	the termination condition is next=nextdf, and this occurs generally
	before we scan up to row=nextdf, 
        ******************************************************************/

Logic al0_stdct(void)
  {
  int row, col, cos, next, icol, iicol, c1, c2, c3, c4;

  /* Init next to 1st non-redundant coset > 1 */

  next = 1;
  do
    { next++; }
  while (next < nextdf && COL1(next) < 0);

  if (next == nextdf)
    { return(FALSE); }			/* table is in standard form */

  /* Find 1st non-std entry, if it exists */

  for (row = 1; row < nextdf; row++)
    {
    if (COL1(row) >= 0)
      {
      for (col = 1; col <= ncol; col++)
        {
        if ((cos = CT(row,col)) > 0)
          {
          if (cos < next)
            { ; }			/* ok */
          else if (cos == next)
            { 				/* new next value; maybe finish */
            do
              { next++; }
            while (next < nextdf && COL1(next) < 0);
            if (next == nextdf)
              { return(FALSE); }
            }
          else
            { goto non_std; }		/* table is non-std */
          }
        }
      }
    }

  return(FALSE);		/* Table is standard.  Never get here ?! */

  non_std:

  /* Table is non-std, so we'll be changing it.  Clear the preferred 
  definition queue, and throw away (after logging) any outstanding 
  deductions. */

  toppd = botpd = 0;

  if (topded >= 0) 
    { 
    disded = TRUE;
    topded = -1;
    }

  /* Now work through the table, standardising it.  For simplicity, we 
  `continue' the loops used above, restarting the inner (column) loop. */

  for ( ; row < nextdf; row++)
    {
    if (COL1(row) >= 0)
      {
      for (col = 1; col <= ncol; col++)
        {
        if ((cos = CT(row,col)) > 0)
          {
          if (cos < next)
            { ; }
          else if (cos == next)
            { 
            do
              { next++; }
            while (next < nextdf && COL1(next) < 0);
            if (next == nextdf)
              { return(TRUE); }
            }
          else
            { 
            /* At this point, cos > next and we have to swap these rows.
            Note that all entries in rows <row are <next, and will not be
            effected.  We process x/X pairs in one hit (to prevent any
            nasties), so we skip over any 2nd (in order) occurrence of a 
            generator.  Warning: trying to understand this code can cause 
            wetware malfunction! */

            for (icol = 1; icol <= ncol; icol++)
              {
              iicol = invcol[icol];

              if (icol < iicol)
                {
                c1 = CT(next,icol);
                if (c1 == next)
                  { c1 = cos; }
                else if (c1 == cos)
                  { c1 = next; }

                c2 = CT(cos,icol);
                if (c2 == next)
                  { c2 = cos; }
                else if (c2 == cos)
                  { c2 = next; }

                c3 = CT(next,iicol);
                if (c3 == next)
                  { c3 = cos; }
                else if (c3 == cos)
                  { c3 = next; }

                c4 = CT(cos,iicol);
                if (c4 == next)
                  { c4 = cos; }
                else if (c4 == cos)
                  { c4 = next; }

                CT(next,icol) = c2;
                if (c2 != 0)
                  { CT(c2,iicol) = next; }

                CT(cos,icol) = c1;
                if (c1 != 0)
                  { CT(c1,iicol) = cos; }

                CT(next,iicol) = c4;
                if (c4 != 0)
                  { CT(c4,icol) = next; }

                CT(cos,iicol) = c3;
                if (c3 != 0)
                  { CT(c3,icol) = cos; }
                }
              else if (icol == iicol)
                {
                c1 = CT(next,icol);
                if (c1 == next)
                  { c1 = cos; }
                else if (c1 == cos)
                  { c1 = next; }

                c2 = CT(cos,icol);
                if (c2 == next)
                  { c2 = cos; }
                else if (c2 == cos)
                  { c2 = next; }

                CT(next,icol) = c2;
                if (c2 != 0)
                  { CT(c2,icol) = next; }

                CT(cos,icol) = c1;
                if (c1 != 0)
                  { CT(c1,icol) = cos; }
                }
              }

            do
              { next++; }
            while (next < nextdf && COL1(next) < 0);
            if (next == nextdf)
              { return(TRUE); }
            }
          }
        }
      }
    }

  return(TRUE);
  }

	/******************************************************************
	double al0_nholes(void)

	On flute, this processes `active' rows at ~ 5.10^6 entries/sec.
	Note the use of knh to cut down the amount of work as much as
	possible.  Can be called by the TBA option of Level 2?  Worst-case
	complexity, in terms of the number of table accesses, is r(c+1);
	where r/c are the number of rows/cols in the table.

	Warning: possible int overflow of k for large tables.
	******************************************************************/

double al0_nholes(void)
  {
  int i,j,k;

  k = 0;
  for (i = knh; i < nextdf; i++)
    {
    if (COL1(i) >= 0)
      {
      for (j = 1; j <= ncol; j++)
        {
        if (CT(i,j) == 0)
          { k++; }
        }
      }
    }

  return( (100.0*(double)k) / ((double)ncol*(double)nalive) );
  }

	/******************************************************************
	void al0_upknh(void)

	Counts knh up to the next incomplete row, skipping redundants.  We
	either bail out at an empty table slot, or reach nextdf.  During an
	enumeration knh is maintained by C-style, due to its overloaded
	meaning (ie, knh & knc).  If we can't guarantee that the table is
	hole-free in an R-style finite result, we have to run this check to
	make sure.  Worst-case complexity is r(c+1).

	Note: this should not be called carelessly during an enumeration, 
	since it is important that knh-based C-style hole filling & 
	deduction stacking / processing are done together, due to the
	overloading of knh's meaning & the fact that it triggers a finite 
	result if it hits nextdf.  This should really only be called when 
	we _know_ we have a finite result (to check whether the table is 
	hole-free), or when we _know_ that all definitions have been 
	applied (perhaps in a C-style lookahead).
	******************************************************************/

void al0_upknh(void)
  {
  int col;

  for ( ; knh < nextdf; knh++)
    {
    if (COL1(knh) >= 0)
      {
      for (col = 1; col <= ncol; col++)
        {
        if (CT(knh,col) == 0)
          { return; }
        }
      }
    }
  }

	/******************************************************************
	void al0_dedn(int cos, int gen)

	Handling the deduction stack is a pain.  The best option, in many
	cases, seems to be to throw deductions away if we get too many at 
	any one time (where `too many' can be quite `small', eg, <1000), 
	and run an "RA:" or a "CL:" check.  However, dedmode #4 (which is 
	the default) allows a special stack-handling function to be called
	if we try to stack a deduction & can't. 

	Currently, in this mode our aim is _never_ to lose any deductions, 
	so we expand the stack space to accomodate the new element.  We 
	take the opportunity to eliminate redundancies from the stack.  The
	code is essentially that used in dedmod #2 in _coinc() (which 
	emulates ACE2).

	Note the messaging code, since we're interested in what the stack
	actually `looks' like when it overflows!  Some ad hoc tests show 
	that redundancies are common (in collapses).  Duplicates (incl. 
	`inverted' duplicates) are not, and it's expensive to process 
	these, so we don't bother trying to track them.

	Warning: this is the _only_ place in the core enumerator where we
	make a system call (apart from o/p & date calls; if these fail 
	we've got real problems), and it's one which could fail.  There is
	_no_ mechanism in ACE Level 0 for handling these sorts of errors,
	so we do the best we can to recover.  Note also that there is no 
	cap on the amount of space which we'll (try to) allocate; so this 
	could all come crashing down in a heap!
	******************************************************************/

void al0_dedn(int cos, int gen)
  {
  int i,j;
  int dead = 0;

  dedsiz *= 2;			/* Best way to go? */
  if ( (dedrow = (int *)realloc(dedrow, dedsiz*sizeof(int))) == NULL ||
       (dedcol = (int *)realloc(dedcol, dedsiz*sizeof(int))) == NULL )
    {
    /* Our attempt to allocate more space failed, and we lost the existing
    stack.  Print out a nasty message (if messaging is on), and tidy up.
    Note that the enumerator works correctly with dedsiz=0, but discards
    _all_ deductions (& does so forever, since 2*0 = 0!). */

    if (dedrow != NULL)
      { free(dedrow); }
    if (dedcol != NULL)
      { free(dedcol); }
    dedsiz = 0;
    topded = -1;
    disded = TRUE;

    if (msgctrl)
      { fprintf(fop, "DS: Unable to grow, all deductions discarded\n"); }

    return;
    }

  /* Is is actually _worth_ doing this?  In a big collapse, the proportion
  of coinc dedns can be high; but these are skipped over when encountered 
  in _cdefn(), so why go to the expense of a (linear) pass & data move.  It
  might keep the stack size down and prevent one doubling, so we have a 
  time vs mempry trade-off (maybe).  We could also be cleverer, and move
  non-redundants from the top to redundant slots at the bottom, cutting the
  number of data moves. */

  j = -1;
  i = 0;
  while (i <= topded && COL1(dedrow[i]) >= 0)
    { j++;  i++; }
  for ( ; i <= topded; i++)
    {
    if (COL1(dedrow[i]) >= 0)
      {
      dedrow[++j] = dedrow[i];
      dedcol[j]   = dedcol[i];
      }
    else
      { dead++; }               /* Track no. redundancies discarded. */
    }
  topded = j;

  /* Now add the original cause of the problem.  There's no need to check
  for an overflow, since we're guaranteed to have enough space at this
  point.  Note however that we do need to take care to update sdmax 
  correctly if the stats package is on. */

  dedrow[++topded] = cos;
  dedcol[topded]   = gen;
#ifdef AL0_STAT
  if (topded >= sdmax)
    { sdmax = topded+1; }
#endif

  if (msgctrl)
    {
    msgnext = msgincr;
    ETINT;
    fprintf(fop, "DS: a=%d r=%d h=%d n=%d;", nalive, knr, knh, nextdf);
    MSGMID;
    fprintf(fop, " s=%d d=%d c=%d\n", dedsiz, topded+1, dead);
    BTINT;
    }
  }

	/******************************************************************
	void al0_dump(Logic allofit)

	Dump out the internals of Level 0 of ACE, working through al0.h
	more or less in order.  We could do more here in terms of pretty-
	printing the data; or we could introduce further arguments
	controlling the level of detail; or we could incorporate checks for
	consistency; or ensure that this is only called when there's valid 
	data; or ...  These are left as exercises for the reader; the 
	output is intended for debugging, and obscurity & information
	overload are part of the game!
	******************************************************************/

void al0_dump(Logic allofit)
  {
  int i,j;

  fprintf(fop, "  #---- %s: Level 0 Dump ----\n", ACE_VER);

	/* FILE *fop, *fip; */
  if (allofit)
    {
    if (fop == NULL)
      { fprintf(fop, "fop=NULL"); }
    else if (fop == stdout)
      { fprintf(fop, "fop=stdout"); }
    else if (fop == stderr)
      { fprintf(fop, "fop=stderr"); }
    else
      { fprintf(fop, "fop=(something)"); }
    if (fip == NULL)
      { fprintf(fop, " fip=NULL\n"); }
    else if (fip == stdin)
      { fprintf(fop, " fip=stdin\n"); }
    else
      { fprintf(fop, " fop=(something)\n"); }
    }

  	/* double begintime, endtime, deltatime, totaltime; */
  if (allofit)
    {
    fprintf(fop, 
        "begintime=%4.2f endtime=%4.2f deltatime=%4.2f totaltime=%4.2f\n",
        begintime, endtime, deltatime, totaltime);
    }

	/* msgctrl, msghol, msgincr, msgnext; */
    fprintf(fop, "msgctrl=%d msghol=%d msgincr=%d msgnext=%d\n", 
            msgctrl, msghol, msgincr, msgnext);

  	/* Logic mendel, rfill, pcomp; */
  fprintf(fop, "mendel=%d rfill=%d pcomp=%d\n", mendel, rfill, pcomp);

  	/* int maxrow, rfactor, cfactor, comppc, nrinspg, lahead; */
  fprintf(fop, "maxrow=%d rfactor=%d cfactor=%d\n", 
          maxrow, rfactor, cfactor);
  fprintf(fop, "comppc=%d nrinsgp=%d lahead=%d\n", 
          comppc, nrinsgp, lahead);

	/* int tlimit, hlimit, llimit, lcount */
  fprintf(fop, "tlimit=%d hlimit=%d llimit=%d lcount=%d\n", 
          tlimit, hlimit, llimit, lcount);

  	/* int nalive, maxcos, totcos; */
  fprintf(fop, "nalive=%d maxcos=%d totcos=%d\n", nalive, maxcos, totcos);

  	/* int chead, ctail; + coincidence queue */
  fprintf(fop, "chead=%d ctail=%d", chead, ctail);
  if (chead == 0)
    { fprintf(fop, " (empty)\n"); }
  else if (chead == ctail)
    { fprintf(fop, " (%d->%d (+%d))\n", 
              chead, -COL1(chead), COL2(chead)); }
  else
    { fprintf(fop, " (%d->%d (+%d) ... %d->%d (+%d))\n", chead, 
        -COL1(chead), COL2(chead), ctail, -COL1(ctail), COL2(ctail)); }

	/* int pdefn, ffactor, pdsiz; */
  fprintf(fop, "pdefn=%d ffactor=%3.1f pdsiz=%d\n", pdefn, ffactor, pdsiz);

  	/* int toppd, botpd; + int pdqcol[], pdqrow[]; */
  fprintf(fop, "toppd=%d botpd=%d", toppd, botpd);
  if (toppd == botpd)
    { fprintf(fop, " (empty)\n"); }
  else
    { fprintf(fop, " (pdqrow/col=%d.%d ...)\n", 
              pdqrow[toppd], pdqcol[toppd]); }

	/* int dedsiz, topded, disded, dedmode; + int *dedrow, *dedcol; */
  fprintf(fop, "dedmode=%d dedsiz=%d disded=%d topded=%d", 
          dedmode, dedsiz, disded, topded);
  if (topded < 0)
    { fprintf(fop, " (empty)\n"); }
  else
    { fprintf(fop, " (... dedrow/col=%d.%d)\n", 
              dedrow[topded], dedcol[topded]); }

	/* int *edp, *edpbeg, *edpend; */
  if (allofit)
    {
    if (edp == NULL)
      { fprintf(fop, "edp=NULL\n"); }
    else
      {
      fprintf(fop, "edpbeg edpend edp[]\n");
      for (i = 1; i <= ncol; i++)
        {
        if (edpbeg[i] >= 0)
          {
          fprintf(fop, "%5d  %5d  ", edpbeg[i], edpend[i]);
          for (j = edpbeg[i]; j <= edpend[i]; j++, j++)
            { fprintf(fop, " %d(%d)", edp[j], edp[j+1]); }
          }
        else
          { fprintf(fop, "%5d  %5d   -", edpbeg[i], edpend[i]);}
        fprintf(fop, "\n");
        }
      }
    }

  	/* int ncol, **colptr (+ col1ptr/col2ptr ?), *invcol; */
  if (allofit)
    {
    fprintf(fop, "ncol=%d\n", ncol);
    if (colptr == NULL)
      { fprintf(fop, "colptr=NULL\n"); }
    else
      {
      fprintf(fop, " invcol[]    ");
      for (i = 1; i <= ncol; i++)
        { fprintf(fop, " %4d", invcol[i]); }
      fprintf(fop, "\n");

      fprintf(fop, " colptr[][1] ");
      for (i = 1; i <= ncol; i++)
        { fprintf(fop, " %4d", colptr[i][1]); }
      fprintf(fop, "\n");

      fprintf(fop, " CT(2,)      ");
      for (i = 1; i <= ncol; i++)
        { fprintf(fop, " %4d", CT(2,i)); }
      fprintf(fop, "\n");
      }
    }
  else
    { fprintf(fop, "ncol=%d", ncol); }

  	/* int ndrel, *relind, *relexp, *rellen, *relators; */
  if (allofit)
    {
    fprintf(fop, "ndrel=%d\n", ndrel);
    if (relators == NULL)
      { fprintf(fop, "relators=NULL\n"); }
    else
      {
      fprintf(fop, " rellen relexp relind relators[]\n");
      for (i = 1; i <= ndrel; i++)
        {
        fprintf(fop, " %5d  %5d  %5d  ", rellen[i], relexp[i], relind[i]);
        for (j = relind[i]; j < relind[i]+rellen[i]; j++)
          { fprintf(fop, " %d", relators[j]); }
        fprintf(fop, "  ");
        for ( ; j < relind[i]+2*rellen[i]; j++)
          { fprintf(fop, " %d", relators[j]); }
        fprintf(fop, "\n");
        }
      }
    }
  else
    { fprintf(fop, " ndrel=%d", ndrel); }

  	/* int nsgpg, *subggen, *subgindex, *subglength, sgdone;  */
  if (allofit)
    {
    fprintf(fop, "nsgpg=%d sgdone=%d\n", nsgpg, sgdone);
    if (subggen == NULL)
      { fprintf(fop, "subggen=NULL\n"); }
    else
      {
      fprintf(fop, " subglength subgindex subggen[]\n"); 
      for (i = 1; i <= nsgpg; i++)
        {
        fprintf(fop, " %8d   %7d   ", subglength[i], subgindex[i]);
        for (j = subgindex[i]; j < subgindex[i]+subglength[i]; j++)
          { fprintf(fop, " %d", subggen[j]); }
        fprintf(fop, "\n");
        }
      }
    }
  else
    { fprintf(fop, " nsgpg=%d sgdone=%d\n", nsgpg, sgdone); }

  /* int knr, knh, nextdf; */
  fprintf(fop, "knr=%d knh=%d nextdf=%d\n",
          knr, knh, nextdf);

  fprintf(fop, "  #---------------------------------\n");
 }

	/******************************************************************
	void al0_rslt(int rslt)

	Pretty-print the result of a run, and some gross statistics.
	******************************************************************/

void al0_rslt(int rslt)
  {
  if (rslt >= 1)
    {
    fprintf(fop, "INDEX = %d", rslt);
    fprintf(fop, " (a=%d r=%d h=%d n=%d; l=%d c=%4.2f; m=%d t=%d)\n",
            nalive, knr, knh, nextdf, lcount, totaltime, maxcos, totcos);
    }
  else
    {
    switch(rslt)
      {
      case -4097:  fprintf(fop, "BAD FINITE RESULT");   break;
      case -4096:  fprintf(fop, "BAD MACHINE STATE");   break;
      case  -514:  fprintf(fop, "INVALID MODE/STYLE");  break;
      case  -513:  fprintf(fop, "INVALID STYLE");       break;
      case  -512:  fprintf(fop, "INVALID MODE");        break;
      case  -260:  fprintf(fop, "SG PHASE OVERFLOW");   break;
      case  -259:  fprintf(fop, "ITERATION LIMIT");     break;
      case  -258:  fprintf(fop, "TIME LIMT");           break;
      case  -257:  fprintf(fop, "HOLE LIMIT");          break;
      case  -256:  fprintf(fop, "INCOMPLETE TABLE");    break;
      case     0:  fprintf(fop, "OVERFLOW");            break;
         default:  fprintf(fop, "UNKNOWN ERROR (%d)", rslt);  break;
      }

    if (rslt <= -512)
      { fprintf(fop, "\n"); }
    else
      {
      fprintf(fop, " (a=%d r=%d h=%d n=%d;", nalive, knr, knh, nextdf);
      if (msghol)
        { fprintf(fop, " h=%4.2f%%", al0_nholes()); } 
      fprintf(fop, " l=%d c=%4.2f;", lcount, totaltime);
      fprintf(fop, " m=%d t=%d)\n", maxcos, totcos);
      }
    }
  }

#ifdef AL0_STAT

	/******************************************************************
	void al0_statinit(void)

	Initialise the stats package for this call to al0_enum().
	******************************************************************/

void al0_statinit(void)
  {
  cdcoinc = rdcoinc = apcoinc = rlcoinc = clcoinc = 0;
  xcols12 = xcoinc  = qcoinc  = 0;
  xsave12 = s12dup  = s12new  = 0;
  xcrep   = crepred = crepwrk = 0;
  xcomp   = compwrk = 0;
  xsaved  = sdmax   = sdoflow = 0;
  xapply  = apdedn  = apdefn  = 0;
  rldedn  = cldedn  = 0;
  xrdefn  = rddedn  = rddefn  = rdfill  = 0;
  xcdefn  = cddproc = cdddedn = cddedn  = cdgap   = cdidefn = 0;
  cdidedn = cdpdl   = cdpof   = cdpdead = cdpdefn = cddefn  = 0;
  }

	/******************************************************************
	void al0_statdump(void)

	Dump the stats for latest call to al0_enum().
	******************************************************************/

void al0_statdump(void)
  {
  fprintf(fop, "  #- %s: Level 0 Statistics -\n", ACE_VER);

  fprintf(fop, "cdcoinc=%d rdcoinc=%d apcoinc=%d rlcoinc=%d clcoinc=%d\n", 
                cdcoinc,   rdcoinc,   apcoinc,   rlcoinc,   clcoinc);
  fprintf(fop, "  xcoinc=%d xcols12=%d qcoinc=%d\n", 
                  xcoinc,   xcols12,   qcoinc);
  fprintf(fop, "  xsave12=%d s12dup=%d s12new=%d\n",  
                  xsave12,   s12dup,   s12new);
  fprintf(fop, "  xcrep=%d crepred=%d crepwrk=%d xcomp=%d compwrk=%d\n", 
                  xcrep,   crepred,   crepwrk,   xcomp,   compwrk);
  fprintf(fop, "xsaved=%d sdmax=%d sdoflow=%d\n", xsaved, sdmax, sdoflow);
  fprintf(fop, "xapply=%d apdedn=%d apdefn=%d\n", xapply, apdedn, apdefn);
  fprintf(fop, "rldedn=%d cldedn=%d\n", rldedn, cldedn);
  fprintf(fop, "xrdefn=%d rddedn=%d rddefn=%d rdfill=%d\n", 
                xrdefn,   rddedn,   rddefn,   rdfill);
  fprintf(fop, "xcdefn=%d cddproc=%d cdddedn=%d cddedn=%d\n", 
                xcdefn,   cddproc,   cdddedn,   cddedn);
  fprintf(fop, "  cdgap=%d cdidefn=%d cdidedn=%d cdpdl=%d cdpof=%d\n", 
                  cdgap,   cdidefn,   cdidedn,   cdpdl,   cdpof);
  fprintf(fop, "  cdpdead=%d cdpdefn=%d cddefn=%d\n", 
                  cdpdead,   cdpdefn,   cddefn);

  fprintf(fop, "  #---------------------------------\n");
  }

#endif

