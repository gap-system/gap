
/**************************************************************************

	coinc.c
	Colin Ramsay (cram@csee.uq.edu.au)
        11 Dec 00

	ADVANCED COSET ENUMERATOR, Version 3.001

	Copyright 2000 
	Centre for Discrete Mathematics and Computing,
	Department of Mathematics and 
	  Department of Computer Science & Electrical Engineering,
	The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

This is the coincidence handling for the coset enumerator.  Conceptually,
this is straightforward, but in practice the details can be a trifle
intimidating (mood-altering chemicals help).  The current strategy is
simple; we process a (primary) coincidence, and any consequent (secondary)
coincidences, immediately & completely.  (We may, or may not, stack
deductions, depending on the saved flag.)  Thus, outside the coincidence 
handling routines, the coincidence queue is empty.  We never `defer' 
processing primary coincidences and we never discard them.  Processing
coincidences can cause a table collapse (index=1), or can result in the
enumeration completing (finite index).  We detect the first of these
(returning 1), but not the second (since it would involve `speculative'
computation).

It would be nice to decouple queueing a primary coincidence from processing
it.  However, since the queue is stored in the table, queueing a coinc
means altering the table & (maybe) generating more coincidences.  Further,
a table with queued coincidences is inconsistent, in the sense that entries
in the rows of non-redundant cosets can refer to redundant cosets.  It 
would be quite feasible to have a (small, fixed size) auxiliary queue where
we could store (some) primary coincs as they are discovered without 
processing them immediately; but this would probably not be beneficial.

Note that *during* coincidence handling, as noted above, the table is
inconsistent.  So we have to continue processing until there are no more 
coincs queued to ensure that the table will be consistent when we exit.  
Thus we can't bail out early, with processing outstanding, except under 
very special circumstances (eg, collapse to index=1).  Even if we detect a
big collapse, and want to bail out (abandoning any stored deductions (we
could also stop queueing *new* coincidences!)), we need to process all 
coincs before we can exit.  Similarly, if all the cosets between knr or knh
& nextdf become redundant, then we know (if we choose to detect this state)
that we *will* finish.  However, we need to continue to `fix up' the table 
and to determine what the final index is (it could be *less* than the value
of nalive when guaranteed finishing was noted).

Note that the coinc handling routines are predicated on the fact that the
table has at least two columns, and that the first two of these are an a &
A pair or an a/A & b/B pair.  This ensures that, eg, if N.a = M, then the 
entry for M.A = N is also within the first two columns.  Note also that the
arguments to the various coincidence processing routines must be valid 
coset numbers (ie, 1 <= x < nextdf).  If not, all bets are off!

**************************************************************************/

#include "al0.h"

	/******************************************************************
	During the special coincidence processing of columns 1 & 2, at most
	two further coincidences can be pending at any one time.  These are
	stored in low1s/high1s & low2s/high2s.  This macro saves a (new)
	coincidence in a free slot.  Note that clo & chi are >0, and that
	low1s/low2s =0 indicate an empty slot.
	******************************************************************/

#define	SAVE12(clo,chi)                     \
  INCR(xsave12);                            \
  if (clo != chi)                           \
    {                                       \
    if (clo > chi)                          \
      { SWAP(clo, chi); }                   \
    if (low1s == clo && high1s == chi)      \
      { INCR(s12dup); }                     \
    else if (low2s == clo && high2s == chi) \
      { INCR(s12dup); }                     \
    else                                    \
      {                                     \
      INCR(s12new);                         \
      if (low1s == 0)                       \
        { low1s = clo;  high1s = chi; }     \
      else                                  \
        { low2s = clo;  high2s = chi; }     \
      }                                     \
    }	

	/******************************************************************
	CREP(path,rep) traces back through coincidence queue, starting at
	path, to find which coset path is ultimately equal to; rep is set 
	to this value (we can have rep=path).  COMPRESS(path,rep) resets 
	all cosets along path's path to point to rep, to speed up future 
	processing (we hope; cf. Union Find problem).  We always have to
	find reps during coincidence processing (so that we put information
	in the correct place & move it as infrequently as possible), but
	whether or not compressing the paths as stored in the coinc list is
	beneficial is a moot point.  Continually trying to compress paths
	which are already `essentially' compressed may waste more time than
	it saves!  The pcomp flag allows compression to be turned off.  At 
	a guess, if the enumeration is `large' and the number of secondary
	coincs per primary coinc is `large', then compression is 
	beneficial; otherwise, it wastes more time than it saves.

	Note that these do *not* trace through, or disturb in any way, the 
	coincidence queue (which is stored in column 2), but merely 
	trace/reset the coset pointed to (in column 1) by those members of
	the queue with which path is coincident.

	Note that, if we want to find path's current rep *and* compress its
	path down to this, then it is more efficient to combine the 
	routines into one, as was done in ACE2.  However, in _cols12() we 
	have to find both reps first, and then compress (if compression on)
	both of them down to the smaller, so we couldn't use the combined 
	routine there.
	******************************************************************/

#define CREP(path,rep)         \
  INCR(xcrep);                 \
  if ((i = COL1(path)) < 0)    \
    {                          \
    INCR(crepred);             \
    while ((j = COL1(-i)) < 0) \
      {                        \
      INCR(crepwrk);           \
      i = j;                   \
      }                        \
    rep = -i;                  \
    }                          \
  else                         \
    { rep = path; }

#define COMPRESS(path,rep)  \
  INCR(xcomp);              \
  l = path;                 \
  while ((j = COL1(l)) < 0) \
    {                       \
    INCR(compwrk);          \
    COL1(l) = -rep;         \
    l = -j;                 \
    }

	/******************************************************************
	static Logic al0_chk1(void)

	This routine is called only by al0_cols12, and only when nalive=1
	and CT(1,1) & CT(1,2) are defined.  al0_coinc() has already
	collapsed all information in positions 1/2 (destroying the entries 
	there in the process); thus, if all other entries in coset 1's row 
	are defined (or are coincident with defined entries), then the 
	index must be 1; i.e., *all* the cosets are coincident and *all*
	entries in row 1 are defined (as 1, or synonyms thereof).

	Note that this routine does not (and, indeed, cannot (simply,
	anyway)) distinguish between coincidences consequent on the current
	primary coincidence and those from a previous primary coincidence.
	However, *provided* that all previous coincidences (that were
	processed) were fully processed then any data (in any col>2) in any
	row of the table is either valid or has been copied to a valid row.
	So, any non-zero entry means that the corresponding col in row 1
	*will* be non-zero.
	******************************************************************/

static Logic al0_chk1(void)
  {
  int i, j;

  for (j = 3; j <= ncol; j++) 
    { 
    if (CT(1,j) != 0) 
      { continue; }

    /* If CT(1,j)==0, look down column j for *any* non-zero entry. */

    for (i = 2; i < nextdf; i++) 
      { 
      if (CT(i,j) != 0) 
        { goto conti; }
      }
    return(FALSE); 		/* column j has no defined entry */

    conti:			/* continue, to next column */
      ;				/* prevent non-ANSI warning ! */
    }

  /* Index *is* 1: set all entries in first row to 1 and bump knr/knh up to
  nextdf (& nextdf down to 2). */

  for (i = 1; i <= ncol; i++) 
    { CT(1,i) = 1; }
  knr = knh = nextdf = 2;

  /* Wipe out the coincidence list and any outstanding pd's.  Empty the 
  dedn stack & say there were no discards.  The SG phase is unnecessary. */

  chead  = ctail  = 0;
  toppd  = botpd  = 0;
  topded = -1;
  disded = FALSE;
  sgdone = TRUE;

  return(TRUE);
  }

	/******************************************************************
	static Logic al0_cols12(int low, int high, Logic saved)

	Process cols 1 and 2 of cosets low = high and their consequences.
	While handling the coincidences coming from the processing of the 
	first 2 columns and the possible coincidences arising from them, we
	have at most 2 more unprocessed coincidences which we need to save
	somewhere to have their columns 1 and 2 processed later.  Thus we 
	set aside 4 locations (low1s, high1s; low2s, high2s) to store such 
	coincident cosets as may arise.  Note that a total collapse (ie, 
	index=1) may occur, in which case we return TRUE (if not, FALSE).
	This routine is only called from al0_coinc, as part of our strategy
	of fully processing all coincidences immediately. 

	Note that on the first pass thro the loop, low & high are the input
	arguments.  On subsequent passes (if any) they are consequences of
	the data in cols 1/2 of an earlier pass.  When we queue & process
	coincidences, we always copy data from high nos to low nos and mark
	the high nos as redundant & pointing to the low on the queue.

	In general, we enter our main loop with only one save slot (the one
	we've just removed to process) empty.  It may appear that 
	processing this can generate *two* more coincidences to be saved.
	However, this is only true on the *first* pass through the loop, 
	when both slots are empty.  On subsequent passes, the coincidence 
	being processed was generated by an earlier coincidence, and 
	processing this has removed an entry from it (via processing an 
	inverse entry).  So at most *one* new coincidence can be generated.
	******************************************************************/

static Logic al0_cols12(int low, int high, Logic saved)
  {
  int i, j, l;				/* for CREP()/COMPRESS() macros */
  int low1s, low2s, high1s, high2s;	/* consequent coincidences */
  int inv1, inv2;			/* column inverses */
  int rlow, rhigh;			/* reps of low/high */
  int src, dst;				/* source & dest'n for info move */
  int low1, low2, high1, high2;		/* original data from cols 1/2 */
  int lowi;				/* temp */

  INCR(xcols12);

  if (low == high)			/* Paranoia prevents problems */
    { return(FALSE); }

  low1s = low2s = 0;

  inv1 = invcol[1];			/* Make these globals ? */
  inv2 = invcol[2];

  while (TRUE) 
    {
    CREP(low,rlow); 
    CREP(high,rhigh);
    if (rlow <= rhigh)
      { src = rhigh;  dst = rlow; }
    else
      { src = rlow;  dst = rhigh; }

    /* If the two reps are equal there's nothing to do (ie, no info to
    move) & we jump over this if().  If not, we're in one of four states,
    depending as low (high) is (is not) redundant.  In any event, both src
    & dst are *not* redundant, and data from cols 1/2 has to be moved from
    src to dst (since queueing src as coincident overwrites this data).  
    Since a coset is queued (made redundant) as its data is processed, all
    relevant data is processed once only & is moved to the smallest coset
    currently known to be equivalent.  If dst later becomes redundant this
    is ok, since it will be queued, and later dequeued, *after* src. */

    if (src != dst)
      {
      /* Mark src coincident with dst and queue the coincidence, recording
      the values of CT(src,1) & CT(src,2) before we destroy them! */

      high1 = COL1(src);
      high2 = COL2(src);

      COL1(src) = -dst; 
      if (chead == 0) 
        { chead = src; }
      else 
        { COL2(ctail) = src; }
      ctail = src; 
      COL2(src) = 0;

      INCR(qcoinc);

      /* To check that the following is correct, you have to check the
      cases where cols 1 & 2 are a/A & b/B or a & A separately.  For each
      of these, you have to consider all possible patterns of entries in 
      rows scr & dst (0, src, dst, X, Y), and check that the right thing is
      always done.  Note that we are guaranteed that at least one, but not
      necessarily both, of low1s/high1s & low2s/high2s are free at this 
      point.  This code could be rewritten to be *much* clearer; it would
      be a lot longer, but whether or not it would be faster is moot.

      Note that at this point, CT(src,1) & CT(src,2) contain coinc queue
      info and must *not* be altered; so we have to take care in the
      handling of inverse entries and/or if any of low1s/high1s or
      low2s/high2s equal src. */

      /* Look at the consequences of column 1 of rows src & dst. */

      if (high1 != 0) 
        { 
        /* Delete ct(high1, inv1) at this stage rather than replace by dst
        to avoid having two occurrences of dst in the one column. */

        if (high1 != src) 
          { CT(high1,inv1) = 0; }
        else 
          { high1 = dst; }

        if ((low1 = COL1(dst)) != 0)	/* note the coincidence */ 
          { SAVE12(low1, high1); } 
        else 				/* note the deduction */
          { 
          COL1(dst) = high1;
          if (saved)
            { SAVED(dst,1); }
          }
 
        if ((lowi = COL1(dst)) != 0 && CT(lowi,inv1) == 0 && lowi != src) 
          { CT(lowi,inv1) = dst; }
        }

      /* Look at the consequences of column 2 of rows src & dst. */

      if (high2 != 0) 
        { 
        /* Delete ct(high2, inv2) at this stage rather than replace by dst
        to avoid having two occurrences of dst in the one column. */

        if (high2 != src) 
          { CT(high2,inv2) = 0; }
        else 
          { high2 = dst; }
 
        if ((low2 = COL2(dst)) != 0)	/* note the coincidence */ 
          { SAVE12(low2,high2); } 
        else 				/* note the deduction */
          { 
          COL2(dst) = high2;
          if (saved)
            { SAVED(dst,2); }
          }
 
        if ((lowi = COL2(dst)) != 0 && CT(lowi,inv2) == 0 && lowi != src) 
          { CT(lowi,inv2) = dst; }
        }

      /* Adjust nalive & check to see if we've hit the jackpot.  Also see
      if we have to fire up a message. */

      if (--nalive == 1 && COL1(1) != 0 && COL2(1) != 0) 
        { 
        if (al0_chk1())   
          { return(TRUE); }
        }

#ifdef AL0_CC
      if (msgctrl && --msgnext == 0)
        {
        msgnext = msgincr;
        ETINT;
        fprintf(fop, "CC: a=%d r=%d h=%d n=%d;", nalive, knr, knh, nextdf);
        MSGMID;
        fprintf(fop, " d=%d\n", topded+1);
        BTINT;
        }
#endif
      }

    /* Now compress both paths down to dst, if required.  This *may*
    speed up future calls to CREP (on ave).  Also, if CREP is *not* used 
    in al0_coinc, it can dramatically decrease the amount of information 
    moved & deductions stacked when processing cols >=3 (ie, cded's).  Of
    course, lots of these stacked ded'ns will be redundant, but still. */

    if (pcomp)
      {
      COMPRESS(high,dst);
      COMPRESS(low,dst);
      }

    /* After processing high (=rhigh) = low (=rlow) ==> dst, we can remove
   this, and any coincidences rendered redundant, from the stored pair.
   Note that we must preserve the pair's order here, so that SAVE12 works 
   ok.  Is it necessary to check *all* these cases? */

    if (low1s != 0)
      {
      if (low1s == high || low1s == low || low1s == src)
        { low1s = dst; }
      if (high1s == high || high1s == low || high1s == src)
        { high1s  = dst; }

      if (low1s == high1s)
        { low1s = 0; }
      else if (low1s > high1s)
        { SWAP(low1s, high1s); }
      }

    if (low2s != 0)
      {
      if (low2s == high || low2s == low || low2s == src)
        { low2s = dst; }
      if (high2s == high || high2s == low || high2s == src)
        { high2s = dst; }

      if (low2s == high2s)
        { low2s = 0; }
      else if (low2s > high2s)
        { SWAP(low2s, high2s); }
      }

    /* Find the next coincident pair to process. */

    if (low1s != 0)
      {
      low = low1s;
      low1s = 0;
      high = high1s;
      }
    else if (low2s != 0)
      {
      low = low2s;
      low2s = 0;
      high = high2s;
      }
    else			/* nothing left to do */
      { return(FALSE); }
    }
  }

	/******************************************************************
	int al0_coinc(int low, int high, Logic saved)

	Process the primary coincidence low = high and its consequences.
	This routine (well, al0_cols12 actually) uses the idea described by
	Beetham ("Space saving in coset enumeration", Durham Proceedings 
	(Academic Press, 1984)) but not the data structure.  It uses the 
	data structure used in CDHW ("Implementation and analysis of the 
	Todd-Coxeter algorithm", Mathematics of Computation, 1973), with 
	some modifications.

	If saved is TRUE, we save any deductions on the stack.  (In the old
	adaptive stategy we were free not to do this, or to detect a `big'
	collapse `early' and stop recording deductions (& new coincs?) & 
	throw away any existing ones.)  If we have a collapse to 1 in 
	al0_cols12, we return 1, having adjusted knr/knh/nextdf.  We choose
	*not* to do any speculative checking as to whether or not knr/knh 
	bumps into nextdf, which would imply a finite index (although not
	necessarily =nalive), since this would not give an early result
	frequently enough to justify its cost.  So, apart from the collapse
	to 1 case, we return -1 and do not change knr/knh/nextdf.  However,
	the cosets pointed to by knr/knh *can* become redundant, and it is 
	the caller's responsibility to check for this and take apporpriate
	action.

	Since we fully process all primary coincidences as they occur, the
	coincidence queue is guaranteed empty at entry and when we return.
	We throw away any outstanding p.d.'s, since they're (probably)
	invalid & it's too much trouble to sort it all out.  We may exit
	this routine with a large deduction stack, so we try to cull 
	redundant entries from this (if permitted by dedmode).  However, we
	can do little regarding duplicate entries, or entries of a 
	deduction & it's inverse.
	******************************************************************/

int al0_coinc(int low, int high, Logic saved)
  { 
  int i, j;				/* Temps / for macros */
  int lowi, highi;
  int chigh, clow, crep;		/* current high, low & rep */

  /* The xcoinc statistic counts the number of calls to this function.  We
  drop out immediately if we're called `needlessly'. */

  INCR(xcoinc);

  if (low == high) 
    { return(-1); }

  /* Process columns 1 and 2 of the primary coincidence. */

  if (al0_cols12(low,high,saved))  
    { return(1); }

  /* While there are coincidences on the queue, process columns 3 to ncol 
  of the coincidence chigh=clow.  Note that crep <= clow < chigh is 
  guaranteed.  When chigh = clow was queued, clow was non-redundant and
  the rep of chigh.  This may no longer be true, so we could pick up the
  current rep of clow (chigh *must* be left alone).  Formally, there is no
  problem if we do not do this, since if clow is now redundant it was
  queued *after* chigh.  So all we'd do is move info to clow, and then move
  it again when clow is processed.

  The (optional) path compression code in 3.000 has been removed. */

  while (chead != 0) 
    { 
    chigh = chead;
    crep  = clow = -COL1(chigh);
    chead = COL2(chead);		/* dequeue coinc being processed */

    for (i = 3; i <= ncol; i++) 
      {	
      /* highi - column i entry of coset chigh */
      if ((highi = CT(chigh, i)) == 0) 
        { continue; }
      j = invcol[i];

      /* Delete CT(highi,j) at this stage rather than replace by crep to
      avoid having two occurrences of crep in the one column. */

      if (highi != chigh) 
        { CT(highi,j) = 0; }
      else 
        { highi = crep; }

      /* lowi - column i entry for coset crep */
      if ((lowi = CT(crep,i)) != 0) 
        {
        if (lowi == chigh) 
          { lowi = crep; }

        /* We have found a (possibly new) coincidence highi=lowi. */

        if (al0_cols12(lowi,highi,saved)) 
          { return(1); }
        } 
      else 
        {			/* Mark new ded'n for later processing? */
        CT(crep,i) = highi;
        if (saved)
          { SAVED(crep,i); }
        }

      if ((lowi = CT(crep, i)) != 0 && CT(lowi, j) == 0)  
        { CT(lowi, j) = crep; }
      }
    }

  chead = ctail = 0; 		/* guaranteed empty coincidence list */
  toppd = botpd = 0;		/* pd's no longer valid */

  /* At this stage we may or may not have a `large' stack, and it may or
  may not contain redundancies/duplicates/inverses.  We have a choice of 
  many things to do with it ...  At some point we might want to add some
  special tracing code to find out just what's in the stack! */

  switch(dedmode)
    {
    case 1:
    while(topded >= 0 && COL1(dedrow[topded]) < 0)
      { topded--; }
    break;

    case 2:
    /* Delete all entries referencing dead cosets from the list of
    deductions, by `compacting' the stack.  We make no attempt to cull
    duplicate or `inverse' entries. */

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
      }
    topded = j;
    break;
    }

  return(-1);
  }

