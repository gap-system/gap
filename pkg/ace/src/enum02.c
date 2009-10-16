
/**************************************************************************

	enum02.c
	Colin Ramsay (cram@csee.uq.edu.au)
        25 Feb 00

	ADVANCED COSET ENUMERATOR, Version 3.001

	Copyright 2000
	Centre for Discrete Mathematics and Computing,
	Department of Mathematics and 
	  Department of Computer Science & Electrical Engineering,
	The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

To fully process all deductions properly we need to invoke the stack 
clearing routine several times in _rpefn().  The following code allow us 
to do this; it's equivalent to the `standard' code, but the loops have been
unrolled & jumps removed.  This allows multiple copies to be included 
without problems, although we still have to be careful about the variable 
names used.  The (local) variables used are: irow, icol, ires, rcol, first,
last, i, beg, end, ifront, iback, fwd, l, bwd, m, mi.

**************************************************************************/

while (topded >= 0)
  {
  INCR(cddproc);

  irow = dedrow[topded];
  icol = dedcol[topded--];
  if (COL1(irow) < 0)
    { 
    INCR(cdddedn);
    continue;
    }
  else
    {
    ires = CT(irow,icol);
    rcol = invcol[icol];
    }

  if ((first = edpbeg[icol]) >= 0)
    {
    last = edpend[icol];
    for (i = first; i <= last; i += 2)
      {
      beg = &(relators[edp[i]]);
      end = beg + edp[i+1]-1;

      ifront = l = ires;
      iback  = irow;

      for (fwd = beg+1; fwd <= end; fwd++) 
        { 
        if ((l = CT(ifront, *fwd)) > 0) 
          { ifront = l; }
        else 
          { break; }
        }

      if (l == 0)
        {
        for (bwd = end; bwd >= fwd; bwd--)
          {
          m  = *bwd; 
          mi =  invcol[m];

          if ((l = CT(iback, mi)) > 0) 
            { iback = l; }
          else if (bwd == fwd)
            {
            CT(iback, mi) = ifront; 
            CT(ifront, m) = iback;

            SAVED(iback, mi);
            INCR(cddedn); 
            iback = ifront;
            }
           else
            {
            iback = ifront;
            break;
            }
          }
        }

      if (iback != ifront)
        {
        INCR(cdcoinc);

        if ((l = al0_coinc(ifront,iback,TRUE)) > 0)
          { return(l); }
        if (COL1(irow) < 0 || COL1(ires) < 0)
          { break; }
        }
      }
    }

  if (COL1(irow) >= 0 && COL1(ires) >= 0 && (irow != ires || icol != rcol))
    {
    if ((first = edpbeg[rcol]) >= 0)
      {
      last = edpend[rcol];
      for (i = first; i <= last; i += 2)
        {
        beg = &(relators[edp[i]]);
        end = beg + edp[i+1]-1;

        ifront = l = irow;
        iback  = ires;

        for (fwd = beg+1; fwd <= end; fwd++) 
          { 
          if ((l = CT(ifront, *fwd)) > 0) 
            { ifront = l; }
          else 
            { break; }
          }

        if (l == 0)
          {
          for (bwd = end; bwd >= fwd; bwd--)
            {
            m  = *bwd; 
            mi =  invcol[m];

            if ((l = CT(iback, mi)) > 0) 
              { iback = l; }
            else if (bwd == fwd)
              {
              CT(iback, mi) = ifront; 
              CT(ifront, m) = iback;

              SAVED(iback, mi);
              INCR(cddedn); 
              iback = ifront;
              }
             else
              {
              iback = ifront;
              break;
              }
            }
          }

        if (iback != ifront)
          {
          INCR(cdcoinc);

          if ((l = al0_coinc(ifront,iback,TRUE)) > 0)
            { return(l); }
          if (COL1(irow) < 0 || COL1(ires) < 0)
            { break; }
          }
        }
      }
    }

#ifdef AL0_DD
  if (msgctrl && --msgnext == 0)
    {
    msgnext = msgincr;
    ETINT;
    fprintf(fop, "DD: a=%d r=%d h=%d n=%d;", nalive, knr, knh, nextdf);
    MSGMID;
    fprintf(fop, " d=%d\n", topded+1);
    BTINT;
    }
#endif
  }

