
/**************************************************************************

	enum01.c
	Colin Ramsay (cram@csee.uq.edu.au)
        18 Oct 00

	ADVANCED COSET ENUMERATOR, Version 3.001

	Copyright 2000
	Centre for Discrete Mathematics and Computing,
	Department of Mathematics and 
	  Department of Computer Science & Electrical Engineering,
	The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

This is the code for the al0_rpefn() routine; i.e., R*-style.  In concept,
it's closest to C-style; except that the defns are done using relator
application, instead of via fill-factor/next hole.  It could also be viewed
as R-style with all dedns stacked & processed.  We `borrow' heavily from
the _cdefn()/_rdefn() routines; see the comments therein for a less terse
code run-through.  Note that we use the _cdefn()/_rdefn() stats package 
variables; since statistics are accumulated on a `per call to _enum()' 
basis, there's no possibility of confusion.

Originally, termination was judged only on knr.  However, for a (big)
collapse this required what was effectively an RA phase to count knr up
from the collapse point to nextdf.  This is expensive if mendel is on (it's
switched off in a genuine RA phase).  Since there is no way in advance of
detecting this state, we elect to keep track of knh (ie, holes) also.  We
can terminate on either; the final check phase may invoke either an RA or
an UH phase (or neither), depending on circumstances.  Since we have to do 
some work anyway to terminate/check the result, this seems to be the 
fastest way; the only `unnecessary' work is counting up knh.

The orignial version of this routine processed deductions on a row by row 
basis.  The current version processes deductions on a scan by scan basis; 
ie, much more frequently.  It is closer in spirit to Felsch mode, and tends
to have smaller max/tot statistics (esp. if there are any very long 
relators).

**************************************************************************/

static int al0_rpefn(int cnt, Logic fill)
  {
  int icol, rcol, irow, ires, col;
  int first, last, i, ii, j, ifront, iback, k, l, m, mi, n;
  int *beg, *end, *fwd, *bwd;

  INCR(xrdefn);

#include "enum02.c"		/* `empty' deduction stack */

  /* Count up knh to its `correct' value; its current value may be 
  redundant and/or we may already have a complete (hole-free) table.  Ditto
  knr; its current value may be redundant and/or we may already have 
  scanned all non-redundant cosets. */

  for ( ; knh < nextdf; knh++) 
    {
    if (COL1(knh) >= 0) 
      {
      for (icol = 1; icol <= ncol; icol++)
        {
        if (CT(knh, icol) == 0) 
          { goto hfill1; }
        }
      }
    }
  return(nalive);

  hfill1:

  while (knr < nextdf && COL1(knr) < 0)
    { knr++; } 
  if (knr == nextdf)
    { return(nalive); }

  /* The main loop.  Provided cnt is non-zero, each pass through this scans
  and closes one row. */

  while (cnt != 0)
    {
    /* Scan through all relators for this coset.  The code here is 
    essentially the same as that in al0_apply.  We inline for speed (and 
    flexibility; the code's not _exactly_ the same). */

    for (ii = 1; ii <= ndrel; ii++)
      {
      j = (mendel ? rellen[ii]/relexp[ii] : 1);
      for (k = 0; k < j; k++)
        {

  /* <-- cancel indent */

  /* Setup start & stop positions for scan, and the coset at the current
  scan positions. */

  beg = &(relators[relind[ii]+k]);
  end = beg-1 + rellen[ii];
  ifront = iback = knr;

  /* Forward scan, leaving ifront set to coset at left of leftmost hole in
  relator or to the last coset in the relator if no hole. */

  for (fwd = beg; fwd <= end; fwd++) 
    { 
    if ((l = CT(ifront, *fwd)) > 0) 
      { ifront = l; }
    else 
      { break; }
    }

  /* If the scan completed, then l = ifront & iback = cos, and we'll fall
  right through and check for a coincidence (i.e., has ifront cycled back
  to cos or not?).  Else, there's a hole & a backward scan is required. */

  if (l == 0)
    {
    for (bwd = end; bwd >= fwd; bwd--) 
      {
      m  = *bwd; 
      mi =  invcol[m]; 

      if ((l = CT(iback, mi)) > 0) 
        { iback = l; }
      else                              /* Scan stalled */
        {
        if (bwd == fwd)
          {
          /* The backward scan has only one gap, so note the deduction to
          complete the cycle & prime for coincidence check. */

          CT(iback, mi) = ifront; 
          SAVED(iback, mi);

          if (CT(ifront, m) > 0)
            { ifront = CT(ifront, m); }
          else
            {
            CT(ifront, m) = iback;
            ifront = iback;
            }

          INCR(rddedn);
          }
        else                            /* Need to define a new coset  */
          {
          /* Note that, if m is an involution, and occurs next to itself,
          then after the first defn, the remainder of the string of m's
          will close.  Note that if m^2 = 1 & m is _not_ being treated as
          an involution, then `removing' it is a Tietze transformation, not
          a free reduction! */

          if (nextdf > maxrow)          /* Overflow */
            { return(0); }

          NEXTC(n);                     /* Making a definition ... */

          CT(iback,mi) = n;
          CT(n,m) = iback;
          SAVED(iback,mi);

          iback = n;                    /* Advance to next spot */

          INCR(rddefn);

          if (msgctrl && --msgnext == 0)
            {
            msgnext = msgincr;
            ETINT;
            fprintf(fop, "RD: a=%d r=%d h=%d n=%d;",
                         nalive, knr, knh, nextdf);
            MSGMID;
            fprintf(fop, " m=%d t=%d\n", maxcos, totcos);
            BTINT;
            }
          }
        }
      }
    }

  /* If we get here, the scan has been completed.  Check to see if we've
  found a pair of coincident cosets.  Recall that _coinc (if it does not
  return >0) is guaranteed _not_ to change knc/knh, although it may render
  them redundant. */
 
  if (ifront != iback)
    {
    INCR(rdcoinc);
    if ((l = al0_coinc(ifront,iback,TRUE)) > 0)
      { return(l); } 
    if (COL1(knr) < 0)
      { goto do_next; }                 /* knr now redundant */
    }

  /* --> restore indent */

#include "enum02.c"			/* `empty' deduction stack */

        if (COL1(knr) < 0)
          { goto do_next; }  		/* knr now redundant */
        }
      }

    /* All relators close at this coset, any row-filling to do?  Only 
    (formally) necessary if some g/G does _not_ appear in any relator,
    but it's usually a good thing to do.  Also, don't bother if the row
    is guaranteed hole-free. */

    if (fill && knr >= knh)
      {
      for (i = 1; i <= ncol; i++)
        {
        if (CT(knr,i) == 0)
          {
          if (nextdf > maxrow)          /* Overflow */
            { return(0); }

          NEXTC(k);                     /* Make definition */
          CT(knr,i) = k;
          CT(k,invcol[i]) = knr;
          SAVED(knr,i);

          INCR(rdfill);

          if (msgctrl && --msgnext == 0)
            {
            msgnext = msgincr;
            ETINT;
            fprintf(fop, "RF: a=%d r=%d h=%d n=%d;",
                         nalive, knr, knh, nextdf);
            MSGMID;
            fprintf(fop, " m=%d t=%d\n", maxcos, totcos);
            BTINT;
            }
          }
        }
#include "enum02.c"		/* `empty' deduction stack */
      }

    /* Row knr is fully scanned (or redundant), so we adjust knr up, 
    jumping over any redundancies & checking to see if we've finished.  We
    have also used up one of our allowed rows, if there's a limit.  We also
    check to see if the table if complete. */

    do_next:	/* from al0_coinc() or dedn processing: knr redundant */

    do
      { knr++; }
    while (knr < nextdf && COL1(knr) < 0);

    if (knr == nextdf)
      { return(nalive); }

    if (cnt > 0)
      { cnt--; }

    for ( ; knh < nextdf; knh++) 
      {
      if (COL1(knh) >= 0) 
        {
        for (icol = 1; icol <= ncol; icol++)
          {
          if (CT(knh, icol) == 0) 
            { goto hfill2; }
          }
        }
      }
    return(nalive);

    hfill2:
      ;
    }           		/* end of "while(cnt!=0)" */

  return(-1);			/* `normal' return */
  }

