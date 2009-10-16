
/**************************************************************************

        postproc.c
        Colin Ramsay (cram@csee.uq.edu.au)
        2 Mar 01

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
          Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

This is the post (enumeration) processing stuff for stand-alone ACE.  Note
that many of the routines here could be considered as Level 0 or Level 1
functions, since they perform general-purpose table manipulations; however,
some of them use Level 2's error-handler, so they couldn't be moved as they
stand to a lower level.  They have been written to be as versatile and as 
`robust' as possible, although Level 2 may not take full advantage of this.

**************************************************************************/

#include "al2.h"

#include <ctype.h>

	/******************************************************************
	void al2_oo(int arg)

	Find cosets with order a multiple of |arg|, modulo the subgroup.
	If arg=0, print all orders.  Otherwise, print the first (arg>0) or
	all (arg<0) coset numbers with order a multiple of |arg|, along
	with their reps.
	******************************************************************/

void al2_oo(int arg)
  {
  int i,j,k, aarg, ord;
  Logic found;

  if (arg < 0)
    { aarg = -arg; }
  else
    { aarg = arg; }

  found = FALSE;
  for (i = 2; i < nextdf; i++)
    {
    if (COL1(i) >= 0)
      {
      if (al1_bldrep(i))
        { 
        if ((ord = al1_ordrep()) == 0)
          { continue; }
        if ((arg == 0) || (ord%aarg == 0))
          {
          if (!found)
            {
            found = TRUE;
            fprintf(fop, "  coset |  order  rep\n");
            fprintf(fop, "--------+------------\n");
            }

          fprintf(fop, "%7d | %6d  ", i, ord);
          for (j = 0; j < repsiz; j++)
            {
            k = colgen[currrep[j]];             /* generator number */
            if (!galpha)
              { fprintf(fop, "%d ", k); }
            else
              { fprintf(fop, "%c", 
                             (k > 0) ? algen[k] : toupper(algen[-k])); }
            }
          fprintf(fop, "\n");

          if ((arg > 0) && (ord%aarg == 0))
            { break; }
          }
        }
      else
        { al2_continue("unable to build coset rep've"); }
      }
    }

  if (!found)
    { fprintf(fop, "* Nothing found\n"); }
  }

	/******************************************************************
	Logic al2_normal(int cos)

	Coset cos is normalising if for the subgroup H = <w_1,...,w_s>,
	then cos*w_j = cos (for all j=1...s).  Return T if this is the
	case, else F (incl. out-of-range/redundant).

	Warning: this routine traces thro the subgrp gens, using the
	enumerator's data structure.  Thus, it can only be used if the
	al1_start() routine has been called & nsgpg has *not* been altered.
	Similar remarks apply to al2_normcl().
	******************************************************************/

Logic al2_normal(int cos)
  {
  int s, *beg, *end, *pi, next;

  if (cos < 1 || cos >= nextdf || COL1(cos) < 0)
    { return(FALSE); }

  for (s = 1; s <= nsgpg; s++)
    {
    beg = &(subggen[subgindex[s]]);
    end = beg-1 + subglength[s];

    next = cos;
    for (pi = beg; pi <= end; pi++)
      {
      if ((next = CT(next,*pi)) == 0 || COL1(next) < 0)
        { return(FALSE); }
      }
    if (next != cos)
      { return(FALSE); }
    }

  return(TRUE);
  }

	/******************************************************************
	void al2_sc(int arg)

	Print the stabilising cosets of the subgrp.  arg>0 prints the first
	arg of them, arg<0 prints the first |arg| + reps, and arg=0 prints
	all of them + reps.
	******************************************************************/

void al2_sc(int arg)
  {
  int i,j,k, aarg;
  Logic found;

  if (arg < 0)
    { aarg = -arg; }
  else
    { aarg = arg; }

  found = FALSE;
  for (i = 2; i < nextdf; i++)
    {
    if (COL1(i) >= 0)
      {
      if (al2_normal(i))
        {
        if (!found)
          {
          found = TRUE;
          if (arg <= 0)
            { fprintf(fop, "Stabilising cosets (+ reps):\n"); }
          else
            { fprintf(fop, "Stabilising cosets:\n"); }
          }

        fprintf(fop, "%7d", i);
        if (arg <= 0)
          {
          if (!al1_bldrep(i))
            { al2_continue("unable to build coset rep've"); }
          fprintf(fop, "  ");
          for (j = 0; j < repsiz; j++)
            {
            k = colgen[currrep[j]];
            if (!galpha)
              { fprintf(fop, "%d ", k); }
            else
              { fprintf(fop, "%c", 
                             (k > 0) ? algen[k] : toupper(algen[-k])); }
            }
          }
        fprintf(fop, "\n");

        if ((aarg != 0) && (--aarg == 0))
          { break; }
        }
      }
    }

  if (!found)
    { fprintf(fop, "* Nothing found\n"); }
  }

	/******************************************************************
	void al2_cycles(void)

	Print out the coset table in cycles (permutation representation).
	This *must* only be called when a completed *and* compacted coset 
	table is present; ie, when a finite index has been computed & a
	(final) CO phase has been run.  The dispatcher code in parser.c 
	enforces this.  Note the use of the sign bit to track processed 
	cosets for each generator.

	ToDo: what about faithfulness?!
	******************************************************************/

void al2_cycles(void)
  {
  int i, j, k, kn, t, length;
  Logic id;

  for (j = 1; j <= ndgen; j++) 
    {
    k = gencol[ndgen+j];	/* find the column k for generator j */
    id = TRUE;        		/* assume action is the identity */

    if (!galpha)		/* print lhs & record its length */
      { 
      fprintf(fop, "%d = ", j);
      length = al2_outlen(j) + 3;
      } 
    else 
      { 
      fprintf(fop, "%c = ", algen[j]);
      length = 4;
      }

    for (i = 1; i <= nalive; i++) 
      {
      if (CT(i, k) == i)	/* skip if i is a one-cycle */
        { 
        CT(i, k) = -i; 
        continue; 
        }

      /* have we used coset i in previous cycle?  */

      if (CT((kn = i), k) < 0) 
        { continue; } 

      id = FALSE;   		/* action of generator not identity */

      /* no, trace out this cycle  */

      length += al2_outlen(kn) + 1;
      if (length < LLL) 
        { fprintf(fop, "(%d", kn); }
      else
        {
        fprintf(fop, "\n  (%d", kn); 
        length = al2_outlen(kn) + 3;
        }

      t = CT(kn, k);
      CT(kn, k) = -t;   	/* mark this coset as used */
      kn = t;

      while (CT(kn,k) > 0) 
        {
        length += al2_outlen(kn) + 1;
        if (length < LLL) 
          { fprintf(fop, ",%d", kn); }
        else 
          { 
          fprintf(fop, ",\n  %d", kn); 
          length = al2_outlen(kn) + 2;
          } 

        t = CT(kn, k);
        CT(kn, k) = -t;
        kn = t;
        }

      /* we have reached the end of the cycle */

      fprintf(fop, ")"); 
      length++;
      }

    if (id) 
      { fprintf(fop, "identity\n"); } 
    else 
      { fprintf(fop, "\n"); }

    /* change all the (negative) values in this column back to positive */

    for (i = 1; i <= nalive; i++) 
      { CT(i, k) = -CT(i, k); }
    }
  }

	/******************************************************************
	void al2_normcl(Logic build)

	Check normal closure.  Trace g^-1 * w * g and g * w * g^-1 for all 
	group generators g and all subgroup generator words w, noting 
	whether we get back to coset 1 or not.  Note that 1.w^g = 1 iff
        1.Gwg = 1 iff 1.Gw = 1.G (hence the apparent switch in the sense of
        first when we set it).  If build is T, then the conjugates of subgroup
        generators by group generators that cannot be traced to the subgroup
	are added to the list of subgroup generators; the *user* has to rerun
        the enumeration.  Note that coset #1 is never redundant; however, 
        others may be, and the table may be incomplete.

        Note: if g has a finite order, say n, then G=g^{n-1}.  So either 
        both or neither of gwG and Gwg are in the subgroup (ie, we need 
        check only one). However, g may have infinite/unknown order so, 
        in general, we have to check both.

	Remark: we choose to ignore those g/w pairs where the trace does
	not complete.  It could be argued that we should include them in 
	the list of added conjugates (as ACE2 did).  If we did, this would 
        require definitions to be made during the rerun of the SG phase.  
        By including only those pairs which do trace, but not to 1, we 
        effectively introduce coincidences.
	******************************************************************/

void al2_normcl(Logic build)
  {
  int col, first, next, s, *beg, *end, *pi, j,k,l;
  Logic found;
  Wlist *list;
  Wlelt *lelt;

  found = FALSE;
  list  = NULL;

  for (col = 1; col <= ncol; col++)	/* all `significant' gen'rs */
    {
    if ((first = CT(1,invcol[col])) == 0 || COL1(first) < 0)
      { continue; }			/* trace incomplete, next col */

    for (s = 1; s <= nsgpg; s++)	/* all (original) subgrp gens */
      {
      beg = &subggen[subgindex[s]];
      end = beg-1 + subglength[s];

      next = first;
      for (pi = beg; pi <= end; pi++)
        {
        if ((next = CT(next,*pi)) == 0 || COL1(next) < 0)
          { goto next_s; }		/* trace incomplete, next gen */
        }
      if (next == first)
        { continue; }			/* closes, next gen */

      /* At this point, we know that the trace of s^col completes but does
      not get back to 1.  So we have a conjugate that's not in the subgrp. */

      found = TRUE; 			/* at least 1 conjugate not in sgp */

      k = colgen[col];			/* (signed) generator number */
      if (!galpha) 
        { 
        fprintf(fop, "Conjugate by grp gen'r \"%d\" of", k); 
        fprintf(fop, " subgrp gen'r \"");
        for (pi = beg; pi <= end; pi++)
          { fprintf(fop, " %d", colgen[*pi]); }
        }
      else 
        { 
        fprintf(fop, "Conjugate by grp gen'r \"%c\" of",
                     (k > 0) ? algen[k] : toupper(algen[-k]));
        fprintf(fop, " subgrp gen'r \"");
        for (pi = beg; pi <= end; pi++)
          {
          if ((l = colgen[*pi]) > 0)
            { fprintf(fop, "%c", algen[l]); }
          else
            { fprintf(fop, "%c", toupper(algen[-l])); }
          }
        }
      fprintf(fop, "\" not in subgrp\n");

      if (build)
        {
        if (list == NULL)
          {
          if ((list = al1_newwl()) == NULL)
            { al2_continue("unable to create new subgrp gen'r list"); }
          }

        if ((lelt = al1_newelt()) == NULL)
          {
          al1_emptywl(list);
          free(list);
          al2_continue("unable to create subgrp gen'r list elt"); 
          }

        lelt->len = subglength[s] + 2;		/* gen'r + col/col^-1 */
        if ((lelt->word = (int*)malloc((lelt->len+1)*sizeof(int))) == NULL)
          {
          al1_emptywl(list);
          free(list);
          free(lelt);
          al2_continue("unable to create subgrp gen'r list elt word"); 
          }
        lelt->exp = 1;

        lelt->word[1] = -k;
        for (pi = beg, j = 2; pi <= end; pi++, j++)
          { lelt->word[j] = colgen[*pi]; }
        lelt->word[lelt->len] = k;

        al1_addwl(list,lelt);
        }

      next_s:
        ;
      }
    }

  if (!found)
    { fprintf(fop, "* All (traceable) conjugates in subgroup\n"); }

  /* If list != NULL then we must have created a list with at least one new
  subgrp gen'r; so found is T & genlst is non-NULL/non-empty!  Append the
  list of new gen'rs & update the enumeration status. */

  if (list != NULL)
    {
    al1_concatwl(genlst,list);

    nsgpg = genlst->len;

    okcont  = FALSE;
    tabinfo = tabindex = FALSE;

    fprintf(fop, "* Subgroup generators have been augmented\n");
    }
  }

	/******************************************************************
	void al2_cc(int cos)

	cos is guaranteed (by the caller) to be a non-redundant coset in 
	the range 2..nextdf-1.  Get its rep & add it to the subgroup gens.
	******************************************************************/

void al2_cc(int cos)
  {
  int i,j;
  Wlelt *lelt;

  /* Build & printout the representative */

  if (!al1_bldrep(cos))
    { al2_continue("unable to build rep've"); }

  fprintf(fop, "Coset #%d: ", cos);
  for (i = 0; i < repsiz; i++)
    {
    j = colgen[currrep[i]];
    if (!galpha)
      { fprintf(fop, "%d ", j); }
    else
      { fprintf(fop, "%c", (j > 0) ? algen[j] : toupper(algen[-j])); }
    }
  fprintf(fop, "\n");

  /* Add the rep to the subgroup generators */

  if ((lelt = al1_newelt()) == NULL)
    { al2_continue("unable to create new subgrp gen'r"); }

  lelt->len = repsiz;
  if ((lelt->word = (int*)malloc((lelt->len+1)*sizeof(int))) == NULL)
    {
    free(lelt);
    al2_continue("unable to create subgrp gen'r word"); 
    }
  lelt->exp = 1;

  for (i = 0; i < repsiz; i++)
    { lelt->word[i+1] = colgen[currrep[i]]; }

  /* Add the new element to the (possibly non-existent) gen list */

  if (genlst == NULL)
    {
    if ((genlst = al1_newwl()) == NULL)
      {
      free(lelt->word);
      free(lelt);
      al2_continue("unable to create subgrp gen'r list"); 
      }
    }
  al1_addwl(genlst,lelt);
  nsgpg++;

  /* Reset enumeration status & `remind' the user */

  okcont  = FALSE;
  tabinfo = tabindex = FALSE;

  fprintf(fop, "* Subgroup generators have been augmented\n");
  }

	/******************************************************************
	void al2_rc(int desire, int count)

	Try to find a nontrival subgroup with index a multiple of a desired
        index `desire' by repeatedly putting randomly chosen cosets 
	coincident with coset 1 and seeing what happens.  The special value
	desire=0 accepts *any* non-trivial finite index, while desire=1
	accepts *any* finite index.  We use the (not very good, but ok for 
	our purposes) random number generator rand(), which returns numbers
	in the range 0..32767 (ie, lower 15 bits).  We take care to ensure 
	that we generate a `valid' coset to set coincident with #1.  If an 
	attempt fails, we restore the original subgrp gens, rerun the 
	original enumeration, and try again (making up to count attempts in
	all).  We use the asis flag to prevent subgroup generator 
	reordering, so that we can easily blow away the added generators.

	Notes:
	(i) This routine presupposes that an enumeration has already been
	performed (this may or may not have yielded a finite index).  The
	presentation and all the control parameters (apart from asis) are 
	frozen at their current values during this call; only the subgroup
	generator list is altered.  Any redo (or start) calls to the
	enumerator use the current settings, including any messaging.
	(ii) This routine can take a *long* time.
	(iii) On success, the presentation/table reflects the discovered
	subgroup.  On failure, it reflects the original status.
	(iv) We try hard to ensure that the system is always left in a
	consistent state, and that all errors are picked up.  However, it
	is *strongly* recommended that a positive result is checked (by 
	doing a complete enumeration), and that nothing is assumed about 
	the presentation/table on a negative result or on an error (note
	that the call to al2_cc() could cause an error return).
	(v) Note that the value of cos, before it is reduced modulo nextdf,
	is limited to 30 bits (ie, 0..1073741823).
	******************************************************************/

void al2_rc(int desire, int count)
  {
  int r1, r2, cos, old, i, cnt;
  Logic tmp;
  Wlelt *p, *q;

  /* Record current status; asis flag & subgrp gen list */

  tmp  = asis;
  asis = TRUE;
  old  = nsgpg;

  for (cnt = 1; cnt <= count; cnt++)	/* Try up to count times */
    {
    fprintf(fop, "* Attempt %d ...\n", cnt);

    while (TRUE)			/* Try until success / too small */
      {
      do
        {
        r1 = rand();
        r2 = rand();
        cos = ((r1 << 15) + r2)%nextdf;
        }
      while (cos < 2 || COL1(cos) < 0);

      al2_cc(cos);

      /* This chunk of code, for redo, is pinched from the parser */

      al1_rslt(lresult = al1_start(2));

      if (lresult > 0 && sgdone)
        {
        okcont  = TRUE;
        tabinfo = tabindex = TRUE;
        }
      else if (lresult >= -259 && sgdone)
        { 
        okcont   = TRUE;
        tabinfo  = TRUE;
        tabindex = FALSE;
        }
      else
        { 
        okcont  = FALSE;
        tabinfo = tabindex = FALSE;
        }
      if (lresult < -260)
        { okredo = FALSE; }

      /* Try and sort out what happened! */

      if (!(okcont && okredo && tabinfo))
        {
        asis = tmp;
        al2_restart("* An unknown problem has occurred");
        }

      if (desire == 0)
        {
        if (tabindex && lresult > 1)
          {
          fprintf(fop, "* An appropriate subgroup has been found\n");
          asis = tmp;
          return;
          }
        if (tabindex && lresult == 1)
          { goto restore; }
        }
      else
        {
        if (tabindex && lresult%desire == 0)
          {
          fprintf(fop, "* An appropriate subgroup has been found\n");
          asis = tmp;
          return;
          }
        if (tabindex && lresult < desire)
          { goto restore; }
        }
      };

    /* Setup for another attempt */

    restore:

    fprintf(fop, "* Recalculating original table\n");

    /* Remove added subgroup generators (of which there is at least 1) */

    if (old == 0)
      {
      al1_emptywl(genlst);
      nsgpg = 0;
      }
    else
      {
      for (i = 1, p = genlst->first; i < old; i++, p = p->next)
        { ; }

      q = p->next;		/* Points to first added generator */

      genlst->last        = p;
      genlst->last->next  = NULL;
      genlst->len = nsgpg = old;

      for (p = q; p != NULL; )
        {
        q = p->next;

        if (p->word != NULL)
          { free(p->word); }
        free(p);
    
        p = q;
        }
      }

    /* Rerun the (original) enumeration (using code pinched from the
    parser), and then try to sort out what happened. */

    al1_rslt(lresult = al1_start(0));

    if (lresult > 0 && sgdone)
      {
      okcont  = okredo   = TRUE;
      tabinfo = tabindex = TRUE;
      }
    else if (lresult >= -259 && sgdone)
      { 
      okcont   = okredo = TRUE;
      tabinfo  = TRUE;
      tabindex = FALSE;
      }
    else
      {
      okcont  = okredo   = FALSE;
      tabinfo = tabindex = FALSE;
      }

    if (!(okcont && okredo && tabinfo))
      {
      asis = tmp;
      al2_restart("* An unknown problem has occurred");
      }

    if (desire == 0)
      {
      if (tabindex && lresult > 1)
        {
        fprintf(fop, "* The original subgroup is appropriate!\n");
        asis = tmp;
        return;
        }
      }
    else
      {
      if (tabindex && lresult%desire == 0)
        {
        fprintf(fop, "* The original subgroup is appropriate!\n");
        asis = tmp;
        return;
        }
      }

    if (tabindex && lresult == 1)
      {
      asis = tmp;
      al2_restart("* Unable to restore original status");
      }
    if (desire >= nalive)
      {
      asis = tmp;
      al2_restart("* Unable to restore original status");
      }
    };

  /* Our efforts failed.  The last time through the outer loop restored the
  original subgrp gens & table, so just restore asis & print a message. */

  fprintf(fop, "* No success; original status restored\n");
  asis = tmp;
  }

	/******************************************************************
	void al2_dw(Wlist *p)

	Delete the list of words given by intarr[] from the word list p.
	Both intarr[] & *p are guaranteed to be non-empty.
	******************************************************************/

void al2_dw(Wlist *p)
  {
  int i,j;
  Wlelt *old, *tmp; 

  /* Check the 1st value, and then ensure that (any) others are strictly 
  increasing and don't exceed the list length. */

  if (intarr[0] < 1 || intarr[0] > p->len)
    { al2_continue("first argument out of range"); }
  for (i = 1; i < intcnt; i++)
    {
    if (intarr[i] <= intarr[i-1] || intarr[i] > p->len)
      { al2_continue("bad argument list"); }
    }

  /* Trace through the list, `moving' the required words & dropping those
  not required (freeing their space). */

  old = p->first;		/* Start at front of old list ... */
  i   = 0;

  j = 0;			/* First deletion is position intarr[0] */

  p->first = p->last = NULL;	/* Clear `new' list ... */
  p->len   = 0;

  while (old != NULL)
    {
    tmp = old;			/* `Chop' head of old list off */
    old = old->next;
    i++;			/* Current position */

    if (i == intarr[j])		/* Delete this one */
      {
      if (tmp->word != NULL)
        { free(tmp->word); }
      free(tmp);

      j++;
      }
    else			/* Keep this one */
      {
      if (p->first == NULL)
        { p->first = tmp; }
      else
        { p->last->next = tmp; }
      tmp->next = NULL;
      p->last   = tmp;
      p->len++;
      }
    }
  }

/**************************************************************************
The stuff under here is all concerned with testing various equivalent
presentations; either doing a random selection thereof, or all of them.  It
is guaranteed that the (top-level) routines are only called if the relator
list is non-empty.  The code here is all very naive, but there is little
point in trying to be clever/efficient.  Note that, no matter how we
cycle/invert/permute the relators, the data attached to each word (ie, its
length & exponent, and how it was entered) remains valid.
**************************************************************************/

	/******************************************************************
	void al2_inv_rel(Wlelt *p)

	Formally invert the word pointed to by p.
	******************************************************************/

void al2_inv_rel(Wlelt *p)
  {
  int j,k, len;

  len = p->len;

  for (j = 1; j <= len/2; j++)
    {
    k                =  p->word[j];
    p->word[j]       = -p->word[len+1-j];
    p->word[len+1-j] = -k;
    }
  if (len%2 == 1)
    { p->word[1 + len/2] = -p->word[1 + len/2]; }
  }

	/******************************************************************
	void al2_cyc_rel(Wlelt *p)

	Cycle the word pointed to by p by 1 position.
	******************************************************************/

void al2_cyc_rel(Wlelt *p)
  {
  int j,k;

  k = p->word[1];
  for (j = 1; j <= p->len-1; j++)
    { p->word[j] = p->word[j+1]; }
  p->word[p->len] = k;
  }

	/******************************************************************
	void al2_per_rel(void)

	Randomly pick a position in the relator list, and move it to the
	front of the list.  The list is guaranteed to contain at least 2 
	elements.
	******************************************************************/

void al2_per_rel(void)
  {
  Wlelt *p, *pp;
  int c,i;

  c = 1 + rand()%rellst->len;		/* 1 <= c <= rellst->len */
  if (c == 1)
    { return; }				/* do nothing */

  pp = rellst->first;
  p  = pp->next;
  i  = 2;
  for ( ; i < c; i++)
    { pp = p;  p = p->next; }

  if (rellst->last == p)
    {
    pp->next     = NULL;
    rellst->last = pp;
    }
  else
    { pp->next = p->next; }

  p->next       = rellst->first;
  rellst->first = p;
  }

	/******************************************************************
	void al2_munge_cyc(void)
	void al2_munge_inv(void)
	void al2_munge_per(void)

	These 3 routines implement random cyclings, inversions & 
	permutations of the relators respectively.  Note that we have to 
	take a `guess' as to how many relator list element moves are needed
	to `randomly' reorder the relators.  The permutation becomes 
	progressively `better' the more runs we do.
	******************************************************************/

void al2_munge_cyc(void)
  {
  Wlelt *p;
  int c;

  for (p = rellst->first; p != NULL; p = p->next)
    {
    if ((c = rand()%p->len) > 0)
      { 
      while (c-- > 0)
        { al2_cyc_rel(p); }
      }
    }
  }

void al2_munge_inv(void)
  {
  Wlelt *p;

  for (p = rellst->first; p != NULL; p = p->next)
    {
    if (rand()%2 == 1)
      { al2_inv_rel(p); }
    }
  }

void al2_munge_per(void)
  {
  int len = rellst->len;

  while ((len /= 2) >= 1)
    { al2_per_rel(); }
  }

	/******************************************************************
	void al2_rep(int cntrl, int cnt)

	Do cnt enumerations using random equivalent presentations.  The 3
	lsbs of cntrl control cycling, inverting & permuting respectively.
	We turn messaging off, dump the relators *after* each run (ie, 
	after al1_start() processes them, so that we see what they actually
	were for the run), and use asis to prevent al1_start() from 
	messing up the relator ordering.
	******************************************************************/

void al2_rep(int cntrl, int cnt)
  {
  Logic tmpa, tmpm;

  tmpa    = asis;
  asis    = TRUE;
  tmpm    = msgctrl;
  msgctrl = FALSE;

  while (cnt-- > 0)
    {
    if ((cntrl & 0x1) != 0)
      { al2_munge_cyc(); }
    if ((cntrl & 0x2) != 0)
      { al2_munge_inv(); }
    if ((cntrl & 0x4) != 0)
      { al2_munge_per(); }

    /* (Re)run the enumeration, and then try to sort out what happened. */

    lresult = al1_start(0);
    fprintf(fop, "Group Relators: ");
    al1_prtwl(rellst, 16);
    fprintf(fop, ";\n");
    al1_rslt(lresult);

    if (lresult > 0 && sgdone)
      {
      okcont  = okredo   = TRUE;
      tabinfo = tabindex = TRUE;
      }
    else if (lresult >= -259 && sgdone)
      { 
      okcont   = okredo = TRUE;
      tabinfo  = TRUE;
      tabindex = FALSE;
      }
    else
      {
      okcont  = okredo   = FALSE;
      tabinfo = tabindex = FALSE;
      }

    if (!(okcont && okredo && tabinfo))
      {
      asis    = tmpa;
      msgctrl = tmpm;
      al2_restart("* An unknown problem has occurred");
      }
    }

  asis    = tmpa;
  msgctrl = tmpm;
  }

	/******************************************************************
	void al2_aep2(Wlelt *p, int *d)

	For this permutation, recursively do all cycles/inversions.
	******************************************************************/

void al2_aep2(Wlelt *p, int *d)
  {
  Logic flg;
  int i,blen;

  if (p == NULL)			/* End of list, run enumerator */
    {
    /* Run the enumeration, and then try to sort out what happened. */

    d[2]++;
    lresult = al1_start(0);

    if (lresult > 0 && sgdone)
      {
      okcont  = okredo   = TRUE;
      tabinfo = tabindex = TRUE;
      }
    else if (lresult >= -259 && sgdone)
      { 
      okcont   = okredo = TRUE;
      tabinfo  = TRUE;
      tabindex = FALSE;
      }
    else
      {
      okcont  = okredo   = FALSE;
      tabinfo = tabindex = FALSE;
      }

    if (!(okcont && okredo && tabinfo))
      {
      asis    = (Logic)d[0];
      msgctrl = (Logic)d[1];
      al2_restart("* An unknown problem has occurred");
      }

    /* Did we get an index?  Any new best/worst values? */

    if (tabindex)
      {
      d[8]++;

      flg = FALSE;
      if (maxcos < d[3])
        {
        d[3] = maxcos;
        flg = TRUE;
        }
      if (maxcos > d[4])
        { 
        d[4] = maxcos;
        flg = TRUE;
        }
      if (totcos < d[5])
        {
        d[5] = totcos; 
        flg = TRUE;
        }
      if (totcos > d[6])
        { 
        d[6] = totcos;
        flg = TRUE;
        }
      if (flg)
        {
        fprintf(fop, "Group Relators: ");
        al1_prtwl(rellst, 16);
        fprintf(fop, ";\n");
        al1_rslt(lresult);
        }

      /* DTT code: dump *all* totcos values */
      /*
      fprintf(fop, "DTT: totcos=%d\n", totcos);
      */
      }
    }

  /* Cycle and/or invert this word, and then recurse.  Note the care to 
  ensure that we always do just what is required; in particular, we must 
  ensure we restore a word to its original form.  Note that we correctly
  cope with cycling in the presence of non-1 exponents.  We *cannot* 
  suppress inverting (x)^n, if x is an involution, since the geninv[]
  array is recalculated by al1_start() & may change since we're
  manipulating asis.  To implement this, we'd need to duplicate the code in
  the al1_chkinvol() function.  In fact, there's no end to this, since
  inverting (ab)^n, if a & b are involutions, is equivalent to cycling it, 
  and doing *both* is wasteful! */

  else
    {
    blen = p->len/p->exp;		/* Baselength of word */

    if ((d[7] & 0x3) == 0)		/* Do nothing */
      { al2_aep2(p->next, d); }
    else if ((d[7] & 0x3) == 1)		/* Cycle only */
      {
      for (i = 0; i < blen; i++)
        {
        al2_cyc_rel(p);
        al2_aep2(p->next, d);
        }
      }
    else if ((d[7] & 0x3) == 2)		/* Invert only */
      {
      al2_aep2(p->next, d);
      al2_inv_rel(p);
      al2_aep2(p->next, d);
      al2_inv_rel(p);
      }
    else				/* Cycle & invert */
      {
      for (i = 0; i < blen; i++)
        {
        al2_cyc_rel(p);
        al2_aep2(p->next, d);
        }
      al2_inv_rel(p);
      for (i = 0; i < blen; i++)
        {
        al2_cyc_rel(p);
        al2_aep2(p->next, d);
        }
      al2_inv_rel(p);
      }
    }
  }

	/******************************************************************
	void al2_aep1(int *d, Wlelt *p)

	Recursively generate the permutations, calling al2_aep2() for each
	one.  p is a pointer to parent node of the unprocessed `tail' of 
	rellst.  rellst contains >1 elts & p is (initially) the 1st elt.
	The node pointed to by the parent node is put in all positions, and
	then we recurse.  So 123 yields 321, 231, 213, 312, 132, 123.
	******************************************************************/

void al2_aep1(int *d, Wlelt *p)
  {
  Wlelt *t0, *t1;

  if (p->next == NULL)
    { al2_aep2(rellst->first, d); }
  else
    {
    /* Move the head of the unprocessed tail to all possible positions. */

    t0 = p->next;			/* Node being moved */
    p->next = t0->next;			/* Slice it out ... */
    if (rellst->last == t0)
      { rellst->last = p; }
    
    /* The head ... */

    t0->next = rellst->first;
    rellst->first = t0;

    al2_aep1(d, p);

    rellst->first = t0->next;

    /* The middle ... */

    for (t1 = rellst->first; t1 != p; t1 = t1->next)
      {
      t0->next = t1->next;
      t1->next = t0;

      al2_aep1(d, p);

      t1->next = t0->next;
      }

    /* The tail (where it started) ... */

    t0->next = p->next;
    p->next = t0;
    if (rellst->last == p)
      { rellst->last = t0; }

    al2_aep1(d, p->next);
    }
  }

	/******************************************************************
	void al2_aep(int cntrl)

	Do all enumerations using equivalent presentations; see comments
	for al2_rep().  To prevent having lots of global data floating
	around, we pass a pointer to the datum array, which contains:
		[0]	original asis
		[1]	original msgctrl
		[2]	number of runs
		[3]	min maxcos
		[4]	max maxcos
		[5]	min totcos
		[6]	max totcos
		[7]	cntrl
		[8]	number of successes
	******************************************************************/

void al2_aep(int cntrl)
  {
  int datum[9];

  /* Temporary code, until we split al1_start() and do the presentation
  altering in the middle.  We need to ensure that the current presentation
  has been processed so that the word exponents are correctly set.  We do
  this run using whatever the current setup is, *before* we set asis &
  turn messaging off.  After this run, the exponents will be fixed.
  However, setting asis may screw up involutions (ie, whether or not we'd
  need to invert some relators, if requested).  Note that this also sets
  maxrow to a valid U.B. for maxcos/totcos. */

  fprintf(fop, "* Priming run ...\n");
  al1_rslt(lresult = al1_start(0));

  if (lresult > 0 && sgdone)
    {
    okcont  = okredo   = TRUE;
    tabinfo = tabindex = TRUE;
    }
  else if (lresult >= -259 && sgdone)
    { 
    okcont   = okredo = TRUE;
    tabinfo  = TRUE;
    tabindex = FALSE;
    }
  else
    {
    okcont  = okredo   = FALSE;
    tabinfo = tabindex = FALSE;
    }

  if (!(okcont && okredo && tabinfo))
    { al2_restart("* An unknown problem has occurred"); }

  /* Start of the `proper' code. */

  datum[0] = (int)asis;
  asis     = TRUE;
  datum[1] = (int)msgctrl;
  msgctrl  = FALSE;
  datum[2] = 0;
  datum[3] = maxrow+1;
  datum[4] = 0;
  datum[5] = maxrow+1;
  datum[6] = 0;
  datum[7] = cntrl;
  datum[8] = 0;

  fprintf(fop, "* Equivalent runs ...\n");
  if ((cntrl & 0x4) == 0 || rellst->len < 2)	/* No permutations */
    { al2_aep2(rellst->first, datum); }
  else
    { al2_aep1(datum, rellst->first); }

  if (datum[8] == 0)
    { fprintf(fop, "* There were no successes in %d runs\n", datum[2]); }
  else
    {
    fprintf(fop, "* There were %d successes in %d runs:\n", 
                 datum[8], datum[2]);
    fprintf(fop, "*   maxcos=%d..%d, totcos=%d..%d\n", 
                 datum[3], datum[4], datum[5], datum[6]); 
    }

  asis    = (Logic)datum[0];
  msgctrl = (Logic)datum[1];
  }

