
/**************************************************************************

        parser.c
        Colin Ramsay (cram@csee.uq.edu.au)
	2 Mar 01

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
          Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

Parser and dispatcher code for stand-alone ACE.  We try to ensure that we
only change things in response to a command if the entire command is ok.
This means that the state is always consistent, and we can usually just
continue.

Note: the al2_continue() routine is intended for cases where an `error'
does not effect the ability to continue, while al2_restart() is intended
for errors which (may) mean that continuing is not possible, so we have to
(re)start an enumeration.  I'm not sure that I'm always careful in calling 
the `right' one; we may have to tinker with this in the light of 
experience.

**************************************************************************/

#include "al2.h"

#include <ctype.h>
#include <string.h>

int al2_pwrd(int);	/* Forward declaration (parser is recursive) */

	/******************************************************************
        void al2_readkey(void)

        Read a keyword into currkey[], converting it to LC.  This removes 
	all leading WS, compresses middle WS to single ' ', and removes
        trailing WS.  It checks for bad characters and too short/long key,
        and advances position to argument (if necessary).  Note that
	currkey has 64 posns (0..63), and we have to reserve one for the 
	string terminating '\0' character.
	******************************************************************/

void al2_readkey(void)
  {
  int i = 0;

  /* Copy the keyword into currkey[] */
  while ( currip != ':' && currip != ';' && currip != '\n' 
            && currip != '\r' && currip != EOF ) 
    {
    if (islower(currip)) 
     {
     if (i > 62)
       { al2_continue("keyword too long"); }
     currkey[i++] = currip; 
     }
    else if (isupper(currip)) 
      { 
      if (i > 62)
        { al2_continue("keyword too long"); }
      currkey[i++] = tolower(currip); 
      }
    else if (currip == ' ' || currip == '\t') 
      { 
      if (i > 0 && currkey[i-1] != ' ')	/* leading/multiple spaces? */
        { 		
        if (i > 63)          	/* may be removable trailing space */
          { al2_continue("keyword too long"); }
        currkey[i++] = ' '; 
        }
      }
    else 
      { al2_continue("keywords must only contain letters"); }
    al2_nextip();
    }

  if (i > 0 && currkey[i-1] == ' ')	/* remove trailing space */
    { i--; }	
  currkey[i] = '\0';              	/* string terminator */

  if (i == 0)
    { al2_continue("empty keyword"); }

  if (currip == ':')            	/* skip any following ':' & WS */
    { al2_nextnw(); }
  }

	/******************************************************************
        void al2_readname(void)

        Read a `name' (ie, command argument).  Used for group/subgroup 
	names/descriptions, I/O filenames, and system calls.  There is only
	one of these (a fixed length <128 global), so we may need to take a
	copy if it'll be required later.  Note that currip has been setup
	to point to a non-blank char (ie, either the first char of the 
	string or an end-of-command char).  Note that we strip trailing
	spaces & tabs from the name, for `neatness'.  We assume ASCII.
	******************************************************************/

void al2_readname(void)
  {
  int i = 0;

  while ( currip != ';' && currip != '\n' && currip != '\r' && 
          currip != EOF ) 
    { 
    if (!((currip >= ' ' && currip <= '~') || (currip == '\t')))
      { al2_continue("string contains invalid character"); } 
    if (i > 126)                        /* 0..126 is data, 127 is '\0' */
      { al2_continue("string too long"); }

    currname[i++] = currip; 
    al2_nextip();
    }

  while (i > 0 && (currname[i-1] == ' ' || currname[i-1] == '\t'))
    { i--; }
  currname[i] = '\0'; 
  }

	/******************************************************************
	int al2_readmult(void)

	Reads the multiplier for the workspace size, if we recognise it.
	******************************************************************/

int al2_readmult(void)
  {
  int u = 1;				/* Default is x1 */

  if (currip == 'k' || currip == 'K')
    { 
    u = KILO;
    al2_nextnw();
    }
  else if (currip == 'm' || currip == 'M')
    { 
    u = MEGA; 
    al2_nextnw();
    }
  else if (currip == 'g' || currip == 'G')
    { 
    u = GIGA; 
    al2_nextnw();
    }

  return u;
  }

	/******************************************************************
	int al2_readgen(void)

	Reads in a (possibly comma separated) list of generator letters.
	These are stored (in lower case) in the order they're read in the
	currname array.  Duplicates are verboten and the number of 
	generators read is returned.  Currip is guaranteed to be a letter, 
	so j > 0 on return is certain (in the absence of errors).
	******************************************************************/

int al2_readgen(void)
  {
  int i, j = 0;

  while ( currip != ';' && currip != '\n' && currip != '\r' && 
          currip != EOF ) 
    {
    if (islower(currip))
      {
      for (i = 1; i <= j; i++)
        {
        if (currname[i] == currip)
          { al2_continue("duplicated generator"); }
        }
      currname[++j] = currip;
      }
    else
      { al2_continue("generators are letters between 'a' & 'z'"); }

    al2_nextnw();
    if (currip == ',')
      { al2_nextnw(); }
    }

  return(j);
  }

	/******************************************************************
	Logic al2_match(char *pattern)

	Test whether currkey can be matched to pattern.
	******************************************************************/

Logic al2_match(char *pattern)
  {
  int i;

  /* first try to match the required part */
  for (i = 0; pattern[i] != '\0' && pattern[i] != '['; i++) 
    { 
    if (pattern[i] != currkey[i]) 
      { return FALSE; } 
    }

  /* if the rest is optional, try to match it */
  if (pattern[i] == '[') 
    {
    for ( ; pattern[i+1] != '\0' && pattern[i+1] != ']'; i++) 
      {
      if (pattern[i+1] != currkey[i]) 
        { return (currkey[i] == '\0'); } 
      }
    }

  /* everything matched, but the keyword should not be longer */
  return (currkey[i] == '\0');
  }

	/******************************************************************
        void al2_endcmd(void)

	To terminate a command, we must see a ';' or a newline.
	******************************************************************/

void al2_endcmd(void)
  {
  if (currip != ';' && currip != '\n' && currip != '\r' && currip != EOF) 
    { al2_continue("command must be terminated by ';' or <newline>"); }
  }

	/******************************************************************
        int al2_readuint(void)

	Read in an unsigned integer
	******************************************************************/

int al2_readuint(void)
  {
  int u = 0;

  if (isdigit(currip)) 
    {
    while (isdigit(currip)) 
      { 
      u = 10*u + (currip - '0'); 
      al2_nextip();
      }
    al2_skipws();
    }
  else 
    { al2_continue("number must begin with digit"); }

  return(u);
  }

	/******************************************************************
        int al2_readint(void)

	Read in a (possibly signed) integer
	******************************************************************/

int al2_readint(void)
  {
  if (isdigit(currip)) 
    { return(al2_readuint()); }
  else if (currip == '+') 
    { 
    al2_nextnw(); 
    return(al2_readuint()); 
    }
  else if (currip == '-') 
    { 
    al2_nextnw(); 
    return(-al2_readuint());
    }
  else 
    { al2_continue("number must begin with digit or '+' or '-'"); }

  return(-1);		/* Stops compiler warning; never get here! */
  }

	/******************************************************************
        void al2_readia(void)

	Read comma-separated list of <= 32 integers into the integer array.
	******************************************************************/

void al2_readia(void)
  {
  intcnt = 0;

  if ( !(isdigit(currip) || currip == '+' || currip == '-') )
    { return; }					/* list is empty */

  intarr[intcnt++] = al2_readint();
  while (currip == ',') 
    {
    if (intcnt == 32)
      { al2_continue("too many integers in sequence"); }

    al2_nextnw(); 
    intarr[intcnt++] = al2_readint();
    }
  }

/**************************************************************************
The functions from hereon, until al2_cmdloop(), are responsible for
implementing the recursive-descent parser.  The current word is built-up in
currword, and when this has been done successfully it is added to a temp
list of words.  If an error occurs, then this list will be `valid'; it will
contain all words up to, but not including, the one in error.  Currently 
this list is accessed via a pointer in the `top-level' function _rdwl() or
_rdrl().  This pointer should really be made a global, so that we could
attempt error-recovery or free up the space it uses (currently, errors may
cause memory leakage).  A successful call to either of the top-level
functions returns a new list, which should be used to replace the current 
list of either group relators or subgroup generators.  It is the caller's 
(of the parser) responsibility to deallocate any replaced list.
**************************************************************************/

	/******************************************************************
	void al2_addgen(int pos, int gen)

	Add a generator to the current word, growing the word as necessary.
	******************************************************************/

void al2_addgen(int pos, int gen)
  {
  if (currword == NULL)
    {
    currsiz = 16;
    if ((currword = (int *)malloc(currsiz*sizeof(int))) == NULL)
      { al2_continue("out of memory (initial word)"); }
    }
  else if (pos >= currsiz)	/* valid entries are [0] .. [currsiz-1] */
    {
    currsiz *= 2;
    if ((currword = (int *)realloc(currword, currsiz*sizeof(int))) == NULL)
      { al2_continue("out of memory (adding generator)"); }
    }

  currword[pos] = gen;
  }

	/******************************************************************
	void al2_addwrd(int dst, int src, int len)

	Add a word to the current word.  Note that this is used to copy
	from currword to itself, so either dst <= src or dst >= src+len.
	******************************************************************/

void al2_addwrd(int dst, int src, int len)
  {
  int i;

  for (i = 0; i < len; i++)
    { al2_addgen(dst+i, currword[src+i]); }
  }

	/******************************************************************
	void al2_invwrd(int pos, int len)

	Sneakily invert a subword of the current word.  Note that we have
	to reverse the order _and_ invert all entries.  So we have to touch
	all posns; hence some of the apparently unnecessary work.
	******************************************************************/

void al2_invwrd(int pos, int len)
  {
  int i, gen1, gen2;

  for (i = 1; i <= (len+1)/2; i++) 
    {
    gen1 = currword[pos + i-1]; 
    gen2 = currword[pos + len-i];

    currword[pos + i-1]   = -gen2; 
    currword[pos + len-i] = -gen1;
    }
  }

	/******************************************************************
	Wlelt *al2_newwrd(int len)

	Make a new word-list element, and copy the first len values from
	currword into it.  Note that currword is indexed from 0, while data
	in the list is indexed from 1!  At this stage all words are fully
	expanded, and have exponent 1.  However, we need to flag those
	words which were _entered_ as involutions (ie, as x^2, not xx).
	******************************************************************/

Wlelt *al2_newwrd(int len)
  {
  Wlelt *p;
  int i;

  if ((p = al1_newelt()) == NULL)
    { al2_restart("no memory for new word-list element"); }
  if ((p->word = (int *)malloc((len+1)*sizeof(int))) == NULL)
    { al2_restart("no memory for word-list element data"); }

  for (i = 1; i <= len; i++)
    { p->word[i] = currword[i-1]; }
  p->len = len;
  p->exp = 1;

  if (len == 2 && currword[0] == currword[1] && currexp == 2)
    { p->invol = TRUE; }
  else
    { p->invol = FALSE; }

  return(p);
  }

	/******************************************************************
	int al2_pelt(int beg)

	Parses an element into currword, beginning at position beg, and 
	returns the length of the parsed element.  The BNF for an element:

		<element> = <generator> ["'"]
			  | "(" <word> { "," <word> } ")" ["'"]
			  | "[" <word> { "," <word> } "]" ["'"]

	Note that (a,b) is parsed as [a,b], but (ab) as ab.  Also, [a,b,c]
	is parsed as [[a,b],c].
	******************************************************************/

int al2_pelt(int beg)
  {
  int len, len2, gen, sign;
  char ch;

  if (isalpha(currip))		/* we have 'a'..'z' or 'A'..'Z' */
    {
    if (!galpha)
      { al2_restart("you specified numeric generators"); }

    if (islower(currip)) 
      { 
      ch = currip; 
      sign = 1;
      }
    else
      { 
      ch = tolower(currip); 
      sign = -1;
      }
    al2_nextnw();

    gen = genal[ch-'a'+1];
    if (gen == 0) 
      { al2_restart("<letter> must be one of the generator letters"); }
    al2_addgen(beg, sign*gen);
    len = 1;
    }
  else if (isdigit(currip) || currip == '+' || currip == '-') 
    {				/* parse a numeric generator */
    if (galpha)
      { al2_restart("you specified alphabetic generators"); }

    sign = 1;
    if (currip == '+') 
      {
      al2_nextnw();
      if (!isdigit(currip)) 
        { al2_restart("'+' must be followed by generator number"); }
      }
    else if (currip == '-')
      {
      al2_nextnw();
      if (!isdigit(currip)) 
        { al2_restart("'-' must be followed by generator number"); }
      sign = -1;
      }

    gen = al2_readuint();
    if (gen == 0 || gen > ndgen) 
      { al2_restart("<number> must be one of the generator numbers"); }
    al2_addgen(beg, sign*gen);
    len = 1;
    }
  else if (currip == '(' || currip == '[') 
    { 				/* parse parenthesised word / commutator */
    ch = currip;
    al2_nextnw();
    len = al2_pwrd(beg);

    while (currip == ',') 
      {
      al2_nextnw();
      len2 = al2_pwrd(beg+len);
      al2_addwrd(beg+len+len2, beg, len+len2);
      al2_invwrd(beg, len);
      al2_invwrd(beg+len, len2);
      len = 2*(len + len2);
      }

    if (ch == '(' && currip != ')') 
      { al2_restart("'(' must have a matching ')'"); }
    if (ch == '[' && currip != ']') 
      { al2_restart("'[' must have a matching ']'"); }
    al2_nextnw();
    }
  else				/* otherwise this is an error */
    { 
    al2_restart("<word> must begin with a <generator>, a '(' or a '['");
    }

  /* A "'" inverts the current element.  "''" is not allowed. */

  if (currip == '\'') 
    { 
    al2_invwrd(beg, len); 
    al2_nextnw();
    }

  return len;                   /* return the length */
  }

	/******************************************************************
	int al2_pfact(int beg)

	Parses a factor into currword, beginning at position beg, and 
	returns the length of the parsed factor.  The BNF for a factor:

		<factor> = <element> [ ["^"] <integer> | "^" <element> ]

	Note that if alphabetic generators are used then the exponentiation
	"^" can be dropped (but not the conjugation "^"), and the exponent
	"-1" can be abbreviated to "-".  So "a^-1 b" can be written as 
	"a^-1b", "a-1b", "a^-b", or "a-b".

	******************************************************************/

int al2_pfact(int beg)
  {
  int len, len2, i;

  len = al2_pelt(beg);			/* parse (first) element */

  if ( currip == '^' ||
       (galpha && (isdigit(currip) || currip == '+' || currip == '-')) ) 
    {
    if (currip == '^')			/* strip away the '^' */
      { al2_nextnw(); }

    if (isdigit(currip) || currip == '-' || currip == '+') 
      {
      if (currip == '+') 
        {
        al2_nextnw();
        if (!galpha && !isdigit(currip)) 
          { al2_restart("'+' must be followed by exponent number"); }
        }                
      else if (currip == '-') 
        {
        al2_invwrd(beg, len);
        al2_nextnw();
        if (!galpha && !isdigit(currip)) 
          { al2_restart("'-' must be followed by exponent number"); }
        }

      /* If we're using alphabetic generators & dropping the "^", then
      "a^-1" can be coded as "a-", so we might not have a digit here. 
      We'll fall through, using the element as already parsed! */

      if (isdigit(currip)) 
        {
        currexp = al2_readuint();
        for (i = 2; i <= currexp; i++) 
          { al2_addwrd(beg + (i-1)*len, beg, len); }
        len = len*currexp;
        }
      }
    else if (isalpha(currip) || currip == '(' || currip == '[') 
      {
      /* This is sneaky! */

      len2 = al2_pelt(beg+len);
      al2_addwrd(beg+len+len2, beg+len, len2);
      al2_invwrd(beg, len);
      al2_invwrd(beg, len+len2);
      len = len2 + len + len2;
      }
    else 
      { al2_restart("'^' must be followed by exponent or element"); }
    }

  return len;
  }

	/******************************************************************
	int al2_pwrd(int beg)

	Parses a word into currword starting at position beg.  Words are 
	defined by the following BNF:

		<word> = <factor> { "*" | "/" <factor> }

	The "*" can be dropped everywhere; but of course two numeric 
	generators, or a numeric exponent and a numeric generator, must be 
	separated by a whitespace.  

	We use currexp to help detect when a relator/generator of the form
	x^2/X^2 (or one of its variants) has been entered.  At the _start_
	of every word we prime it to 1.
	******************************************************************/

int al2_pwrd(int beg)
  {
  int len, len2;
  char ch;

  if (beg == 0)
    { currexp = 1; }

  len = al2_pfact(beg);

  while ( currip == '*'   || currip == '/' || isalpha(currip) || 
          isdigit(currip) || currip == '+' || currip == '-'   || 
          currip == '('   || currip == '[' ) 
    {
    if (currip == '*') 
      { 
      ch = '*'; 
      al2_nextnw();
      }
    else if (currip == '/') 
      { 
      ch = '/'; 
      al2_nextnw();
      }
    else                  
      { ch = '*'; }

    len2 = al2_pfact(beg+len);
    if (ch == '/') 
      { al2_invwrd(beg+len, len2); }
    len += len2;
    }

  return len;
  }

	/******************************************************************
	Wlelt *al2_rdwrd(void)

	This parses a word into currword, copies it into a properly setup
	new word-list element, and returns a pointer to it.
	******************************************************************/

Wlelt *al2_rdwrd(void)
  { return(al2_newwrd(al2_pwrd(0))); }

	/******************************************************************
	void al2_pawrd(Wlist *p)

	Parse a word and add it to the list of words.
	******************************************************************/

void al2_pawrd(Wlist *p)
  { al1_addwl(p, al2_rdwrd()); }

	/******************************************************************
	Wlist *al2_rdwl(void)

	Reads and returns a list of words.
	******************************************************************/

Wlist *al2_rdwl(void)
  {
  Wlist *p;

  if ((p = al1_newwl()) == NULL)	/* allocate a new list of words */
    { al2_continue("unable to create new word-list"); }

  if (currip != ';')			/* parse a sequence of words */ 
    {
    al2_pawrd(p);
    while (currip == ',') 
      { 
      al2_nextnw(); 
      al2_pawrd(p); 
      }
    }

  return(p);                     	/* return the list of words */
  }

	/******************************************************************
	void al2_parel(Wlist *l)

	Note that W1 = W2 = W3 becomes W1W2' & W1W3'!
	******************************************************************/

void al2_parel(Wlist *l)
  {
  int len1, len2;

  len1 = al2_pwrd(0);			/* parse left hand side word */

  len2 = 0;
  while (currip == '=')		/* parse a sequence of right-hand sides */ 
    {
    al2_nextnw();
    len2 = al2_pwrd(len1);
    al2_invwrd(len1, len2);
    al1_addwl(l, al2_newwrd(len1+len2));
    }

  if (len2 == 0) 		/* no RH side, take LH side as relator */
    { al1_addwl(l, al2_newwrd(len1)); }
  }

	/******************************************************************
	Wlist *al2_rdrl(void)

	Reads and returns a list of relators.  Note that this is _not_ the
	same as a list of words (ie, subgroup generators) since we're
	allowed things like W1 = W2.  So we have to invoke the parser via
	the parse relator function _parel().
	******************************************************************/

Wlist *al2_rdrl(void)
  {
  Wlist *p;

  if ((p = al1_newwl()) == NULL)	/* allocate a new list of words */
    { al2_continue("unable to create new word-list"); }
 
  if (currip != ';')
    {
    al2_parel(p);
    while (currip == ',') 
      {
      al2_nextnw();
      al2_parel(p);
      }
    }

  return(p);
  }

	/******************************************************************
        void al2_cmdloop(void)
	******************************************************************/

void al2_cmdloop(void)
  {
  int i,j,k;
  Wlist *p;
  Logic f, li, lj;

  while (TRUE)
    {
    /* Do the necessary for the next command (or end-of-file).  Note that
    the next command may follow on the same line, or we may have to skip
    over a '\n' to the next line.  (Not sure if this is bomb-proof under 
    all (error) conditions.) */

    al2_nextnw();
    skipnl = TRUE;
    al2_skipws();
    skipnl = FALSE;

    if (currip == EOF)
      { break; }

    al2_readkey();

    /* The work-horse; just plow through until the first match, do it,
    and then skip to the end of the while(). */

    if (al2_match("add gen[erators]") || al2_match("sg"))
      {
      if (ndgen < 1)
        { al2_continue("there are no generators as yet"); }

      skipnl = TRUE;
      al2_skipws();

      p = al2_rdwl();
      al2_endcmd();

      if (genlst == NULL)
        { genlst = p; }
      else
        { al1_concatwl(genlst,p); }

      nsgpg = genlst->len;

      okcont  = FALSE;
      tabinfo = tabindex = FALSE;

      continue;
      }

    if (al2_match("add rel[ators]") || al2_match("rl"))
      {
      if (ndgen < 1)
        { al2_continue("there are no generators as yet"); }

      skipnl = TRUE;
      al2_skipws();

      p = al2_rdrl();
      al2_endcmd();

      if (rellst == NULL)
        { rellst = p; }
      else
        { al1_concatwl(rellst,p); }

      ndrel = rellst->len;

      okcont   = FALSE;
      tabindex = FALSE;

      continue;
      }

    /* All Equivalent Presentations */

    if (al2_match("aep"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt != 1)
        { al2_continue("bad number of parameters"); }
      if (intarr[0] < 1 || intarr[0] > 7)
        { al2_continue("invalid first argument"); }

      if (!okstart)
        { al2_continue("can't start (no generators/workspace)"); }
      if (rellst == NULL || rellst->len == 0)
        { al2_continue("can't start (no relators)"); }

      al2_aep(intarr[0]);

      continue;
      }

    if (al2_match("ai") || al2_match("alter i[nput]"))
      {
      al2_readname();
      al2_endcmd();

      if (strlen(currname) == 0)
        { strcpy(currname, "stdin"); }
      al2_aip(currname);

      continue;
      }

    if (al2_match("ao") || al2_match("alter o[utput]"))
      {
      al2_readname();
      al2_endcmd();

      if (strlen(currname) == 0)
        { strcpy(currname, "stdout"); }
      al2_aop(currname);

      continue;
      }

    /* What to do with asis in continue/redo?  It's (current) value in a
    printout may not match that actually used at the start of a run, when
    the involutary generators are picked up & the columns allocated, and
    these settings are frozen until the next start/begin/end!  */

    if (al2_match("as[is]")) 
      { 
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 1)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "asis = %s\n", asis ? "true" : "false"); }
      else
        { asis = (intarr[0] == 1); }

      continue;
      }

    if (al2_match("beg[in]") || al2_match("end") || al2_match("start"))
      {
      al2_endcmd();

      if (!okstart)
        { al2_continue("can't start (no generators?)"); }

      al1_rslt(lresult = al1_start(0));

      /* If something `sensible' happened, then it'll be ok to continue or
      redo this run.  If not, then we make sure that we must begin a new
      run.  Note that here (& in continue/redo) we play it safe by
      enforcing a new run, even if there may be no need to.  Note that the
      SG phase is 1st in start mode, so should _always_ be done. */

      if (lresult > 0 && sgdone)		/* finite index */
        {
        okcont  = okredo   = TRUE;
        tabinfo = tabindex = TRUE;
        }
      else if (lresult >= -259 && sgdone)	/* holey/overflow/limit */
        { 
        okcont   = okredo = TRUE;
        tabinfo  = TRUE;
        tabindex = FALSE;
        }
      else					/* SG overflow/`error' */
        {
        okcont  = okredo   = FALSE;
        tabinfo = tabindex = FALSE;
        }

      continue;
      }

    if (al2_match("bye") || al2_match("exit") || al2_match("q[uit]"))
      {
      al2_endcmd();

      break;
      }

    if (al2_match("cc") || al2_match("coset coinc[idence]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt != 1)
        { al2_continue("bad number of parameters"); }
      if (!tabinfo)
        { al2_continue("there is no table information"); }
      if (intarr[0] < 2 || intarr[0] >= nextdf || COL1(intarr[0]) < 0)
        { al2_continue("invalid/redundant coset number"); }

      al2_cc(intarr[0]);

      continue;
      }

    if (al2_match("c[factor]") || al2_match("ct[ factor]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt > 1)
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "ct factor = %d\n", cfactor1); }
      else
        { cfactor1 = intarr[0]; }

      continue;
      }

    /* See comments for "begin". */

    if (al2_match("check") || al2_match("redo"))
      {
      al2_endcmd();

      if (!okredo)
        { al2_continue("can't redo (different presentation?)"); }

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

      continue;
      }

    if (al2_match("com[paction]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 100)) || 
            intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "compaction = %d\n", comppc); }
      else
        { comppc = intarr[0]; }

      continue;
      }

    /* See comments for "begin". */

    if (al2_match("con[tinue]"))
      {
      al2_endcmd();

      if (!okcont)
        { al2_continue("can't continue (altered presentation?)"); }

      al1_rslt(lresult = al1_start(1));

      if (lresult > 0 && sgdone)
        { tabinfo = tabindex = TRUE; }
      else if (lresult >= -259 && sgdone)
        {
        tabinfo  = TRUE;
        tabindex = FALSE;
        }
      else
        {
        okcont  = FALSE;
        tabinfo = tabindex = FALSE;
        }

      continue;
      }

    if (al2_match("cy[cles]"))
      {
      al2_endcmd();

      if (!tabindex)
        { al2_continue("there is no completed table"); }

      begintime = al0_clock();
      li = al0_compact();
      endtime = al0_clock();
      if (li)
        { fprintf(fop, "CO"); }
      else
        { fprintf(fop, "co"); }
      fprintf(fop, ": a=%d r=%d h=%d n=%d; c=+%4.2f\n", 
                   nalive, knr, knh, nextdf, al0_diff(begintime,endtime));

      al2_cycles();

      continue;
      }

    if (al2_match("ded mo[de]") || al2_match("dmod[e]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt == 0)
        { fprintf(fop, "deduction mode = %d\n", dedmode); }
      else if (intcnt == 1)
        {
        if (intarr[0] < 0 || intarr[0] > 4)
          { al2_continue("bad mode parameter"); }
        dedmode = intarr[0];
        }
      else
        { al2_continue("bad parameter count"); }

      continue;
      }

    if (al2_match("ded si[ze]") || al2_match("dsiz[e]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && intarr[0] < 0) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "deduction stack = %d\n", dedsiz1); }
      else
        { dedsiz1 = intarr[0]; }

      continue;
      }

    if (al2_match("def[ault]"))
      {
      al2_endcmd();

      cfactor1 = 0;
      comppc   = 10;
      dedmode  = 4;
      dedsiz1  = 1000;
      ffactor1 = 0;
      lahead   = 0;
      mendel   = FALSE;
      nrinsgp1 = -1;
      pdefn    = 3;
      pdsiz1   = 256;
      rfactor1 = 0;
      rfill    = TRUE;
      pcomp    = FALSE;

      continue;
      }

    if (al2_match("del gen[erators]") || al2_match("ds"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt < 1 || genlst == NULL || genlst->len < 1)
        { al2_continue("empty argument list / generator list"); }
      al2_dw(genlst);
      nsgpg = genlst->len;

      okcont  = okredo   = FALSE;
      tabinfo = tabindex = FALSE;

      continue;
      }

    if (al2_match("del rel[ators]") || al2_match("dr"))
      {
      al2_readia();
      al2_endcmd();
 
      if (intcnt < 1 || rellst == NULL || rellst->len < 1)
        { al2_continue("empty argument list / relator list"); }
      al2_dw(rellst);
      ndrel = rellst->len;

      okcont  = okredo   = FALSE;
      tabinfo = tabindex = FALSE;

      continue;
      }

    if (al2_match("d[ump]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 2)) ||
           (intcnt > 1 && (intarr[1] < 0 || intarr[1] > 1)) ||
            intcnt > 2 )
        { al2_continue("bad parameters"); }
      else if (intcnt == 0)
        { al0_dump(FALSE); }
      else if (intcnt == 1)
        {
        if (intarr[0] == 0)
          { al0_dump(FALSE); }
        else if (intarr[0] == 1)
          { al1_dump(FALSE); }
        else
          { al2_dump(FALSE); }
        }
      else
        {
        if (intarr[0] == 0)
          { al0_dump(intarr[1] == 1); }
        else if (intarr[0] == 1)
          { al1_dump(intarr[1] == 1); }
        else
          { al2_dump(intarr[1] == 1); }
        }

      continue;
      }

    if (al2_match("easy"))
      {
      al2_endcmd();

      cfactor1 = 0;
      comppc   = 100;
      dedmode  = 0;
      dedsiz1  = 1000;
      ffactor1 = 1;
      lahead   = 0;
      mendel   = FALSE;
      nrinsgp1 = 0;
      pdefn    = 0;
      pdsiz1   = 256;
      rfactor1 = 1000;
      rfill    = TRUE;
      pcomp    = FALSE;

      continue;
      }

    if (al2_match("echo")) 
      { 
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 1)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "echo = %s\n", echo ? "true" : "false"); }
      else
        { echo = (intarr[0] == 1); }

      continue;
      }

    /* Note that it is ok to set the name to "".  If the call to _strdup()
    fails, then _continue() will be invoked.  This could leave grpname 
    still pointing to freed storage, hence the explicit setting to NULL. */

    if (al2_match("enum[eration]") || al2_match("group name"))
      {
      al2_readname();
      al2_endcmd();

      if (grpname != NULL)
        { free(grpname); }
      grpname = NULL;
      grpname = al2_strdup(currname);

      continue;
      }

    if (al2_match("fel[sch]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 1)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      
      if (intcnt == 1 && intarr[0] == 1)	/* `Enhanced' Felsch */
        {
        ffactor1 = 0;
        nrinsgp1 = -1;
        pdefn    = 3;
        }
      else					/* Felsch (~ Pure C) */
        {
        ffactor1 = 1;
        nrinsgp1 = 0;
        pdefn    = 0;
        }

      cfactor1 = 1000;
      comppc   = 10;
      dedmode  = 4;
      dedsiz1  = 1000;
      lahead   = 0;
      mendel   = FALSE;
      pdsiz1   = 256;
      rfactor1 = 0;
      rfill    = FALSE;
      pcomp    = FALSE;

      continue;
      }

    /* If you set this to 0, Level 1 will set ffactor to a `sensible'
    default (eg, 5(ncol+2)/4). */

    if (al2_match("f[factor]") || al2_match("fi[ll factor]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && intarr[0] < 0) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "fill factor = %d\n", ffactor1); }
      else
        { ffactor1 = intarr[0]; }

      continue;
      }

    if (al2_match("gen[erators]") || al2_match("subgroup gen[erators]"))
      {
      if (ndgen < 1)
        { al2_continue("there are no generators as yet"); }

      skipnl = TRUE;
      al2_skipws();

      p = al2_rdwl();
      al2_endcmd();

      if (genlst != NULL)
        { al1_emptywl(genlst);  free(genlst); }
      genlst = p;
      nsgpg  = p->len;

      okcont  = okredo   = FALSE;
      tabinfo = tabindex = FALSE;

      continue;
      }

    if (al2_match("gr[oup generators]"))
      {
      if (isdigit(currip) || currip == '+' || currip == '-')
        {
        i = al2_readint();
        al2_endcmd();
        if (i < 1)
          { al2_continue("bad parameter"); }

        ndgen  = i;
        galpha = FALSE;

        okstart = (costable != NULL);
        okcont  = okredo   = FALSE;
        tabinfo = tabindex = FALSE;

        /* The current relator & generator lists are now invalid */

        if (rellst != NULL)
          { al1_emptywl(rellst);  free(rellst); }
        rellst = NULL;
        ndrel  = 0;
        if (genlst != NULL)
          { al1_emptywl(genlst);  free(genlst); }
        genlst = NULL;
        nsgpg  = 0;
        }
      else if (isalpha(currip))
        {
        i = al2_readgen();
        al2_endcmd();

        ndgen  = i;
        galpha = TRUE;
        for (j = 1; j <= ndgen; j++)
          { algen[j] = currname[j]; }
        algen[ndgen+1] = '\0';		/* &algen[1] is printable string */

        for (j = 1; j <= 26; j++)
          { genal[j] = 0;}
        for (j = 1; j <= ndgen; j++)
          { genal[algen[j]-'a'+1] = j;  }

        okstart = (costable != NULL);
        okcont  = okredo   = FALSE;
        tabinfo = tabindex = FALSE;

        if (rellst != NULL)
          { al1_emptywl(rellst);  free(rellst); }
        rellst = NULL;
        ndrel  = 0;
        if (genlst != NULL)
          { al1_emptywl(genlst);  free(genlst); }
        genlst = NULL;
        nsgpg  = 0;
        }
      else
        {
        al2_endcmd();

        fprintf(fop, "group generators = ");
        if (ndgen < 1)
          { fprintf(fop, "none\n"); }
        else if (galpha)
          {
          for (i = 1; i <= ndgen; i++)
            { fprintf(fop, "%c", algen[i]); } 
          fprintf(fop, "\n");
          }
        else
          { fprintf(fop, "1..%d\n", ndgen); }
        }

      continue;
      }

    if (al2_match("group relators") || al2_match("rel[ators]"))
      {
      if (ndgen < 1)
        { al2_continue("there are no generators as yet"); }

      skipnl = TRUE;
      al2_skipws();

      p = al2_rdrl();
      al2_endcmd();

      if (rellst != NULL)
        { al1_emptywl(rellst);  free(rellst); }
      rellst = p;
      ndrel  = p->len;

      okcont  = okredo   = FALSE;
      tabinfo = tabindex = FALSE;

      continue;
      }

    if (al2_match("hard"))
      {
      al2_endcmd();

      cfactor1 = 1000;
      comppc   = 10;
      dedmode  = 4;
      dedsiz1  = 1000;
      ffactor1 = 0;
      lahead   = 0;
      mendel   = FALSE;
      nrinsgp1 = -1;
      pdefn    = 3;
      pdsiz1   = 256;
      rfactor1 = 1;
      rfill    = TRUE;
      pcomp    = FALSE;

      continue;
      }

    if (al2_match("h[elp]"))
      {
      al2_endcmd();
      al2_help();

      continue;
      }

    if (al2_match("hlt"))
      {
      al2_endcmd();

      cfactor1 = 0;
      comppc   = 10;
      dedmode  = 0;
      dedsiz1  = 1000;
      ffactor1 = 1;
      lahead   = 1;
      mendel   = FALSE;
      nrinsgp1 = 0;
      pdefn    = 0;
      pdsiz1   = 256;
      rfactor1 = 1000;
      rfill    = TRUE;
      pcomp    = FALSE;

      continue;
      }

    if (al2_match("ho[le limit]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < -1 || intarr[0] > 100)) || 
           intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "hole limit = %d\n", hlimit); }
      else
        { hlimit = intarr[0]; }

      continue;
      }

    if (al2_match("look[ahead]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 4)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "lookahead = %d\n", lahead); }
      else
        { lahead = intarr[0]; }

      continue;
      }

    if (al2_match("loop[ limit]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && intarr[0] < 0) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "loop limit = %d\n", llimit); }
      else
        { llimit = intarr[0]; }

      continue;
      }

    if (al2_match("max[ cosets]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] == 1)) || 
           intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "max cosets = %d\n", maxrow1); }
      else
        { maxrow1 = intarr[0]; }

      continue;
      }

    if (al2_match("mess[ages]") || al2_match("mon[itor]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt > 1)
        { al2_continue("too many parameters"); }
      else if (intcnt == 0)
        {
        if (msgctrl)
          { 
          if (msghol)
            { fprintf(fop, "messages = %d (+ holes)\n", msgincr); }
          else
            { fprintf(fop, "messages = %d (- holes)\n", msgincr); }
          }
        else
          { fprintf(fop, "messages = off\n"); }   
        }
      else if (intarr[0] == 0)
        {
        msgctrl = FALSE;
        msghol  = FALSE;
        msgincr = 0;
        }
      else if (intarr[0] < 0)
        {
        msgctrl = TRUE;
        msghol  = TRUE;
        msgincr = -intarr[0];
        }
      else
        {
        msgctrl = TRUE;
        msghol  = FALSE;
        msgincr = intarr[0];
        }

      continue;
      }

    if (al2_match("mend[elsohn]")) 
      { 
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 1)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "mendelsohn = %s\n", mendel ? "true" : "false"); }
      else
        { mendel = (intarr[0] == 1); }

      continue;
      }

    if (al2_match("mo[de]"))
      {
      al2_endcmd();

      if (okstart)
        { fprintf(fop, "start = yes,"); }
      else
        { fprintf(fop, "start = no,"); }
      if (okcont)
        { fprintf(fop, " continue = yes,"); }
      else
        { fprintf(fop, " continue = no,"); }
      if (okredo)
        { fprintf(fop, " redo = yes\n"); }
      else
        { fprintf(fop, " redo = no\n"); }

      continue;
      }

    if (al2_match("nc") || al2_match("normal[ closure]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 1)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      if (!tabinfo)
        { al2_continue("there is no table information"); }

      begintime = al0_clock();
      li = al0_compact();
      endtime = al0_clock();
      if (li)
        { fprintf(fop, "CO"); }
      else
        { fprintf(fop, "co"); }
      fprintf(fop, ": a=%d r=%d h=%d n=%d; c=+%4.2f\n", 
                   nalive, knr, knh, nextdf, al0_diff(begintime,endtime));

      if (intcnt == 0)
        { al2_normcl(FALSE); }
      else
        { al2_normcl(intarr[0] == 1); }

      continue;
      }

    if (al2_match("no[ relators in subgroup]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && intarr[0] < -1) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "no. rels in subgr = %d\n", nrinsgp1); }
      else
        { nrinsgp1 = intarr[0]; }

      continue;
      }

    if (al2_match("oo") || al2_match("order[ option]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt != 1)
        { al2_continue("missing argument / too many arguments"); }
      if (!tabinfo)
        { al2_continue("no information in table"); }

      al2_oo(intarr[0]);

      continue;
      }

    if (al2_match("opt[ions]"))
      {
      al2_endcmd();
      al2_opt();

      continue;
      }

    /* an old command, which we quietly ignore */

    if (al2_match("par[ameters]"))
      { 
      al2_endcmd();
      continue;
      }

    if (al2_match("path[ compression]")) 
      { 
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 1)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "path compression = %s\n", pcomp ? "on" : "off"); }
      else
        { pcomp = (intarr[0] == 1); }

      continue;
      }

    if (al2_match("pd mo[de]") || al2_match("pmod[e]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 3)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "pref. definition mode = %d\n", pdefn); }
      else
        { pdefn = intarr[0]; }

      continue;
      }

    if (al2_match("pd si[ze]") || al2_match("psiz[e]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && intarr[0] < 0) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "pref. definition list = %d\n", pdsiz1); }
      else if (intarr[0] == 0)
        { pdsiz1 = intarr[0]; }			/* use default value */
      else if (intarr[0]%2 == 1)
        { al2_continue("bad parameter"); }	/* odd (incl. 1) */
      else
        {					/* even parameter, >= 2 */
        i = intarr[0];
        while (i%2 == 0)
          { i /= 2; }
        if (i == 1)
          { pdsiz1 = intarr[0]; }
        else
          { al2_continue("bad parameter"); }	/* not power of 2 */
        }

      continue;
      }

    if (al2_match("print det[ails]") || al2_match("sr"))
      {
      al2_readia();
      al2_endcmd();

      if ((intcnt > 0 && (intarr[0] < 0 || intarr[0] > 5)) || intcnt > 1)
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { al1_prtdetails(0); }
      else
        { al1_prtdetails(intarr[0]); }

      continue;
      }

    /* Negative first parameter means include order/rep, else don't.  No 
    parameters means all the table, one parameter "x" means (1,x,1), two
    parameters "x,y" means (x,y,1), and three parameters "x,y,z" means
    (x,y,z).  Note the compulsory compaction, to prevent utterly confusing 
    the user!  (This may cause disded to become true.) */

    if (al2_match("pr[int table]"))
      {
      al2_readia();
      al2_endcmd();

      if (!tabinfo)
        { al2_continue("no information in table"); }

      if (intcnt == 0)
        {
        f = FALSE;
        intarr[0] = 1;
        intarr[1] = nextdf-1;
        intarr[2] = 1;
        }
      else if (intcnt <= 3)
        {
        if (intarr[0] < 0)
          {
          f = TRUE;
          intarr[0] = -intarr[0];
          }
        else
          { f = FALSE; }
        }
      else
        { al2_continue("too many parameters"); }

      if (intcnt == 1)
        {
        intarr[1] = intarr[0];
        intarr[0] = intarr[2] = 1;
        }
      else if (intcnt == 2)
        { intarr[2] = 1; }

      if (intarr[0] >= nextdf)
        { intarr[0] = nextdf-1; }
      if (intarr[1] >= nextdf)
        { intarr[1] = nextdf-1; }

      if (intarr[0] < 1 || intarr[1] < intarr[0] || intarr[2] < 1 )
        { al2_continue("bad parameters"); }

      begintime = al0_clock();
      li = al0_compact();
      endtime = al0_clock();
      if (li)
        { fprintf(fop, "CO"); }
      else
        { fprintf(fop, "co"); }
      fprintf(fop, ": a=%d r=%d h=%d n=%d; c=+%4.2f\n", 
                   nalive, knr, knh, nextdf, al0_diff(begintime,endtime));

      al1_prtct(intarr[0], intarr[1], intarr[2], FALSE, f);

      continue;
      }

    if (al2_match("pure c[t]"))
      {
      al2_endcmd();

      cfactor1 = 1000;
      comppc   = 100;
      dedmode  = 4;
      dedsiz1  = 1000;
      ffactor1 = 1;
      lahead   = 0;
      mendel   = FALSE;
      nrinsgp1 = 0;
      pdefn    = 0;
      pdsiz1   = 256;
      rfactor1 = 0;
      rfill    = FALSE;
      pcomp    = FALSE;

      continue;
      }

    if (al2_match("pure r[t]"))
      {
      al2_endcmd();

      cfactor1 = 0;
      comppc   = 100;
      dedmode  = 0;
      dedsiz1  = 1000;
      ffactor1 = 1;
      lahead   = 0;
      mendel   = FALSE;
      nrinsgp1 = 0;
      pdefn    = 0;
      pdsiz1   = 256;
      rfactor1 = 1000;
      rfill    = FALSE;
      pcomp    = FALSE;

      continue;
      }

    /* This is a `dangerous' option, since it can go wrong, or `corrupt'
    the status, in so many ways.  We try to minimise problems by being
    very strict as to when we allow it to be called.  How much of this is
    necessary/desirable is moot. */

    if (al2_match("rc") || al2_match("random coinc[idences]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt < 1 || intcnt > 2)
        { al2_continue("bad number of parameters"); }
      if (intarr[0] < 0)
        { al2_continue("invalid first argument"); }
      if (intcnt == 2 && intarr[1] < 1)
        { al2_continue("invalid second argument"); }

      if (!tabinfo)
        { al2_continue("there is no table information"); }
      if (!okredo)
        { al2_continue("can't redo (different presentation?)"); }

      if (lresult == 1)
        { al2_continue("trivial finite index already exists"); }

      if (intarr[0] == 0)
        {
        if (lresult > 0)
          { al2_continue("non-trivial finite index already present"); }
        }
      else
        {
        if (lresult > 0 && lresult < intarr[0])
          { al2_continue("finite index already < argument"); }
        if (lresult > 0 && lresult%intarr[0] == 0)
          { al2_continue("finite index already multiple of argument"); }
        }

      if (intarr[0] >= nalive)
        { al2_continue("not enough active cosets available"); }

      if (intcnt == 1)			/* Try 8 times, by default */
        { al2_rc(intarr[0],8); }
      else
        { al2_rc(intarr[0],intarr[1]); }

      continue;
      }

    if (al2_match("rec[over]") || al2_match("contig[uous]"))
      {
      if (!tabinfo)
        { al2_continue("there is no table information"); }

      begintime = al0_clock();
      li = al0_compact();
      endtime = al0_clock();
      if (li)
        { fprintf(fop, "CO"); }
      else
        { fprintf(fop, "co"); }
      fprintf(fop, ": a=%d r=%d h=%d n=%d; c=+%4.2f\n", 
                   nalive, knr, knh, nextdf, al0_diff(begintime,endtime));

      continue;
      }

    /* Random Equivalent Presentations */

    if (al2_match("rep"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt < 1 || intcnt > 2)
        { al2_continue("bad number of parameters"); }
      if (intarr[0] < 1 || intarr[0] > 7)
        { al2_continue("invalid first argument"); }
      if (intcnt == 2 && intarr[1] < 1)
        { al2_continue("invalid second argument"); }

      if (!okstart)
        { al2_continue("can't start (no generators/workspace)"); }
      if (rellst == NULL || rellst->len == 0)
        { al2_continue("can't start (no relators)"); }

      if (intcnt == 1)
        { al2_rep(intarr[0], 8); }
      else
        { al2_rep(intarr[0], intarr[1]); }

      continue;
      }

    /* an old command, which we quietly ignore */

    if (al2_match("restart"))
      { 
      al2_endcmd();
      continue;
      }

    if (al2_match("r[factor]") || al2_match("rt[ factor]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt > 1)
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "rt factor = %d\n", rfactor1); }
      else
        { rfactor1 = intarr[0]; }

      continue;
      }

    if (al2_match("row[ filling]")) 
      { 
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && (intarr[0] < 0 || intarr[0] > 1)) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "row fill = %s\n", rfill ? "on" : "off"); }
      else
        { rfill = (intarr[0] == 1); }

      continue;
      }

    if (al2_match("sc") || al2_match("stabil[ising cosets]"))
      {
      al2_readia();
      al2_endcmd();

      if (intcnt != 1)
        { al2_continue("missing argument / too many arguments"); }
      if (!tabinfo)
        { al2_continue("no information in table"); }

      al2_sc(intarr[0]);

      continue;
      }

    /* We emulate, as best we can, the odd-numbered enumeration strategies
    given in Table 5.5.1 (p. 245) of C.C. Sims' book.  The even-numbered 
    ones involve `standardise-as-you-go', which we don't do; however we can
    standardise the table once we're done, or we can pause an enumeration
    at any time, standardise, and then continue.  (This last is not as daft
    as it seems and does, in fact, sometimes prove beneficial.)  The
    strategies are: 1) HLT, no save; 3) HLT, save; 5) CHLT, no save; 7) 
    CHLT, save; 9) Felsch (save). */

    if (al2_match("sims"))
      {
      al2_readia();
      al2_endcmd();

      if ( intcnt != 1 || 
           intarr[0] < 1 || intarr[0] > 9 || intarr[0]%2 == 0 )
        { al2_continue("bad parameter"); }

      switch(intarr[0])
        {
        case 1:			/* cf. "pure r" + row-fill */
          cfactor1 = 0;
          dedmode  = 0;
          mendel   = FALSE;
          rfactor1 = 1000;
          rfill    = TRUE;
         break;
        case 3:
          cfactor1 = 0;
          dedmode  = 4;
          mendel   = FALSE;
          rfactor1 = -1000;
          rfill    = TRUE;
          break;
        case 5:
          cfactor1 = 0;
          dedmode  = 0;
          mendel   = TRUE;
          rfactor1 = 1000;
          rfill    = TRUE;
          break;
        case 7:
          cfactor1 = 0;
          dedmode  = 4;
          mendel   = TRUE;
          rfactor1 = -1000;
          rfill    = TRUE;
          break;
        case 9:			/* cf. "pure c" / "Felsch" */
          cfactor1 = 1000;
          dedmode  = 4;
          mendel   = FALSE;
          rfactor1 = 0;
          rfill    = FALSE;
          break;
        }

      /* These parameters are common to all modes. */

      comppc   = 10;		/* compaction always allowed */
      dedsiz1  = 1000;		/* default (starting) size */
      ffactor1 = 1;		/* fill-factor not active */
      lahead   = 0;		/* never lookahead */
      nrinsgp1 = 0;		/* no (active) RS phase */
      pdefn    = 0;		/* no preferred/immediate defns ... */
      pdsiz1   = 256;
      pcomp    = FALSE;

      continue;
      }

    if (al2_match("st[andard table]"))
      {
      al2_endcmd();

      if (!tabinfo)
        { al2_continue("no information in table"); }

      begintime = al0_clock();
      li = al0_compact();
      lj = al0_stdct();
      endtime = al0_clock();
      if (li)
        { fprintf(fop, "CO"); }
      else
        { fprintf(fop, "co"); }
      if (lj)
        { fprintf(fop, "/ST"); }
      else
        { fprintf(fop, "/st"); }
      fprintf(fop, ": a=%d r=%d h=%d n=%d; c=+%4.2f\n", 
                   nalive, knr, knh, nextdf, al0_diff(begintime,endtime));

      continue;
      }

    /* this stuff is done if the statistics package is included */

#ifdef AL0_STAT
    if (al2_match("stat[istics]") || al2_match("stats"))
      {
      al2_endcmd();
      STATDUMP;

      continue;
      }
#endif

    if (al2_match("style"))
      {
      al2_endcmd();

      if (rfactor1 < 0)
        {
        if (cfactor1 < 0)
          { fprintf(fop, "style = R/C\n"); }
        else if (cfactor1 == 0)
          { fprintf(fop, "style = R*\n"); }
        else
          { fprintf(fop, "style = Cr\n"); }
        }
      else if (rfactor1 == 0)
        {
        if (cfactor1 < 0)
          { fprintf(fop, "style = C* (aka C-style)\n"); }
        else if (cfactor1 == 0)
          { fprintf(fop, "style = R/C (Rt & Ct values defaulted)\n"); }
        else
          { fprintf(fop, "style = C\n"); }
        }
      else
        {
        if (cfactor1 < 0)
          { fprintf(fop, "style = Rc\n"); }
        else if (cfactor1 == 0)
          { fprintf(fop, "style = R\n"); }
        else
          { fprintf(fop, "style = CR\n"); }
        }

      continue;
      }

    /* see comment for "enum[eration]" */

    if (al2_match("subg[roup name]"))
      {
      al2_readname();
      al2_endcmd();

      if (subgrpname != NULL)
        { free(subgrpname); }
      subgrpname = NULL;
      subgrpname = al2_strdup(currname);

      continue;
      }

    /* Allows access to the system; ie, fires up a shell & passes it the
    (non-empty) argument.  Use with caution, of course!  The argument must
    consist of one line of printable characters (plus '\t'), excluding ';'.
    Trailing WS is removed.  We do _no_ error checking on the call. */
 
    if (al2_match("sys[tem]"))
      {
      al2_readname();
      al2_endcmd();

      if (strlen(currname) == 0)
        { al2_continue("empty argument"); }
      else
        { system(currname); }

      continue;
      }

    if (al2_match("text"))
      {
      al2_readname();
      al2_endcmd();
      fprintf(fop, "%s\n", currname);

      continue;
      }

    if (al2_match("ti[me limit]"))
      {
      al2_readia();
      al2_endcmd();

      if ( (intcnt > 0 && intarr[0] < -1) || intcnt > 1 )
        { al2_continue("bad parameter"); }
      else if (intcnt == 0)
        { fprintf(fop, "time limit = %d\n", tlimit); }
      else
        { tlimit = intarr[0]; }

      continue;
      }

    /* The trace word command takes as arguments a coset number & a word.
    Unlike ACE2, we do not allow a multi-line word. */

    if (al2_match("tw") || al2_match("trace[ word]"))
      {
      i = al2_readint();
      if (currip != ',')
        { al2_continue("missing argument"); }
      al2_nextnw();
      if ((j = al2_pwrd(0)) == 0)
        { al2_continue("empty argument"); }
      al2_endcmd();

      if (!tabinfo)
        { al2_continue("table d.n.e. or has no information"); }
      if (i < 1 || i >= nextdf || COL1(i) < 0)
        { al2_continue("invalid/redundant coset number"); }

      /* Now copy currword (gen'r nos) to currrep (col nos) */
      repsiz = 0;
      for (k = 0; k < j; k++)
        { 
        if ( !al1_addrep( gencol[ndgen+currword[k]] ) )
          { al2_continue("unable to build coset rep've"); }
        }

      if ((k = al1_trrep(i)) == 0)
        { fprintf(fop, "* Trace does not complete\n"); }
      else
        { fprintf(fop, "%d * word = %d\n", i, k); }

      continue;
      }

    /* Negative workspace sizes are errors, zero size selects DEFWORK, and
    values <1K are rounded up to 1K. */

    if (al2_match("wo[rkspace]"))
      {
      if ( !(isdigit(currip) || currip == '+' || currip == '-') )
        {
        al2_endcmd();		/* Error if currip not ';' or '\n'! */ 
        fprintf(fop, "workspace = %d x %d\n", workspace, workmult);
        }
      else
        {
        i = al2_readint();
        j = al2_readmult();
        al2_endcmd();

        if (i < 0)
          { al2_continue("argument must be non-negative"); }
        else if (i == 0)		/* Use default value */
          { 
          i = DEFWORK;
          j = 1;
          }
        else if (j == 1 && i < KILO)	/* Minimum allowed is 1xKILO */
          { i = KILO; }

        workspace = i;
        workmult  = j;

        /* The casts to long are to allow 64-bit systems (ie, IP27/R10000)
        to break the 4G physical memory barrier. */

        if (costable != NULL) 
          { free(costable); }
        costable = 
          (int *)malloc((long)workspace*(long)workmult*(long)sizeof(int));
        if (costable == NULL) 
          {
          okstart = okcont   = okredo = FALSE;	/* Problem, no table! */
          tabinfo = tabindex = FALSE;
          al2_restart("unable to resize workspace (will try default)");
          }

        okstart = (ndgen > 0);			/* New table ... */
        okcont  = okredo   = FALSE;
        tabinfo = tabindex = FALSE;
        }

      continue;
      }

    /* ... no match; signal an error */

    al2_continue("there is no such keyword");
    }
  }

