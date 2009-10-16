
/**************************************************************************

        al0.h
        Colin Ramsay (cram@csee.uq.edu.au)
        20 Dec 00

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000 
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
          Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
	(http://www.csee.uq.edu.au/~havas/cdmc.html)

This is the header file for Level 0 of ACE; that is, the core enumerator
routines.

**************************************************************************/

#define ACE_VER  "ACE 3.001"

        /******************************************************************
        Stdio.h and stdlib.h will be included in all the source files,
        since all of them include this file.
        ******************************************************************/

#include <stdio.h>
#include <stdlib.h>

	/******************************************************************
	At some time in the future, we may have to be careful as to the 
	types we use.  For the moment we only typedef logical variables, 
	and stick with standard C types for the rest.  The `default' 
	environment is 32-bit Unix, although there are a couple of places 
	where the code is 64-bit `compliant' to enable the 4G memory 
	barrier to be breached.  (Any possible `problem' areas are 
	commented upon.)  We also assume that we are in the C locale, and
	that we're using the ACSII character set.
	******************************************************************/

typedef int Logic;
#define TRUE   1
#define FALSE  0

	/******************************************************************
	Is it worth having this as a separate macro?  Replace swapp by a 
	global temp?
	******************************************************************/

#define SWAP(i,j)  { int swapp;  swapp=i;  i=j;  j=swapp; }

	/******************************************************************
	Macro for access to coset table.  i is coset, j is generator (as
	column number).  colptr[j] stores the start address of the block of
	memory for column j.  CT(i,j), with j = 1...ncol, indicates the
	action of the associated generator (or inverse) of column j on 
	coset i.  It contains the coset number if known, otherwise 0 (in
	column 1, -ve numbers indicate coincidences).  Coset #1 is the 
	subgroup.  Note the special macros for cols 1/2 to maximise speed 
	(and improve clarity), since these cols handle coincs & are heavily
	used.

	Depending on the address/data memory model, how address arithmetic 
	is performed, the size of an int, the number of columns, and how
	much (physical) memory is available, there will be some limit on 
	how many rows the table can have.  The table size, in bytes, can
	exceed 4G.  However, since ints are (currently) used throughout,
	the number of rows is at most 2147483647 (ie, 2^31-1).  In 
	practice, arithmetic overflow problems, rounding effects, and guard
	bands will limit the number of cosets to less than this.  We try, 
	as far as possible, to postpone this point by performing some
	potentially troublesome calculations using floats.
	******************************************************************/

#define CT(i,j)  (*(colptr[(j)] + (i)))
#define COL1(i)  (*(col1ptr + (i)))
#define COL2(i)  (*(col2ptr + (i)))

extern FILE *fop, *fip;		/* All i/o goes through these */

extern double begintime;        /* clock() at start of current interval */
extern double endtime;          /* clock() at end of current interval */
extern double deltatime;	/* duration of current interval */
extern double totaltime;        /* cumulative clock() time, current call */

	/******************************************************************
	The ETINT macro is used end the current timing interval.  It 
	updates the cumulative time for this run & the time of the current
	interval (ie, since the last begintime).  It must be paired with
	the BTINT macro to set the start the next interval.  The new
	begintime is the old endtime, so our timings will _include_ the
	time between the ETINT & the BTINT (this can be significant if, for
	example, hole monitoring is on)!
	******************************************************************/

#define ETINT  \
  endtime    = al0_clock();                 \
  deltatime  = al0_diff(begintime,endtime); \
  totaltime += deltatime;

#define BTINT  \
  begintime = endtime;

	/******************************************************************
	Variables to control the (progress-based) messaging feature.  Such
	messages are enabled if msgctrl is set, and are printed every 
	msgincr `actions'; where an action is a definition, a coincidence
	(possibly) or a stacked deduction (possibly).  msgnext keeps track
	of how far away we are from the next message.  Values of 1 for 
	msgctrl are ok, if you want to see everything that happens.  
	However, _lots_ of output can be produced for such small values. 
	If msghol is set, messages include hole information; this feature 
	is independant of the hlimit flag, and is time expensive.
	******************************************************************/

extern Logic msgctrl, msghol;
extern int msgincr, msgnext;

	/******************************************************************
	If messaging is triggered & holes are required, print out the 
	current hole %'age as part of the progress message.
	******************************************************************/

#define MSGMID  \
  if (msghol)   \
    { fprintf(fop, " h=%4.2f%%", al0_nholes()); }   \
  fprintf(fop, " l=%d c=+%4.2f;", lcount, deltatime);

	/******************************************************************
	Logic control variables for current enumeration
	******************************************************************/

extern Logic mendel;		/* If true, in R-style scan (& close) each 
				relator at each cyclic position for each 
				coset, instead of just from 1st position */
extern Logic rfill;		/* If true, fill rows after scanning */
extern Logic pcomp;		/* If true, compress coinc paths */

	/******************************************************************
	The major user-settable parameters
	******************************************************************/

extern int maxrow;		/* Max number of cosets permitted.  May be 
			less than the actual physical table size allocated,
			but not more.  Should be at least 2! */
extern int rfactor;		/* R-style `blocking factor' */
extern int cfactor;		/* C-style `blocking factor' */
extern int comppc;		/* As new cosets are required, they are 
			defined sequentially until the table is exhausted, 
			when compaction may be done.  Comppc sets the 
			percentage of dead cosets in the table before 
			compaction is allowed. */
extern int nrinsgp;             /* No. of relators `in' subgroup, for
                                C-style enumerations. */
extern int lahead;		/* If 0, don't do lookahead. If 1 (or 3), 
				allow (cheap, R-style) lookahead from 
	current position (or over entire table).  If 2 (or 4), allow 
	(expensive, C-style) lookahead over the entire table, a la ACE2 
	(or from current position).  Note that, if mendel set, then cheap 
	is expensive!  Lookahead is 1-level, ie, we don't look at
	consequences of consequences or stack deductions. */

	/******************************************************************
	If tlimit >= 0 then the total elapsed time is checked at the end of
	each pass through the enumerator's main loop, and if it's more than
	tlimit (in seconds) the run is stopped.  Note that tlimit=0 does
	precisely one pass through the main loop, since 0 >= 0.  If there 
	is, e.g., a big collapse (so that the time round a loop becomes 
	very long), then the run may run over tlimit by a large amount.  
	However, we must ensure that when we exit due to too little time, 
	the table is left in a consistent state, so early bail-out is not
	always possible.  Another example is the CL phase, which can take
	considerable time.

	If hlimit >= 0 then ditto for the % of unfilled holes in the coset
	table.  The % of holes is calculated by going thro the table, so 
	this can be a time-expensive option; we check on each pass thro the
	loop.  The impact is minimised if rfactor/cfactor blocking factors 
	are `large'.  Note that the utility of this is under review, since
	the % of holes tends to be static or to drift down.
	******************************************************************/

extern int tlimit, hlimit;

	/******************************************************************
	Level 0 keeps track of the number of passes through the state-
	machine's main loop in lcount.  If llimit > 0, then the enumerator
	will exit after (at most) llimit passes.  You need to use this in
	conjunction with the machine's flow chart, else the results might
	surprise (annoy, frustrate) you!
	******************************************************************/

extern int llimit, lcount;

	/******************************************************************
	The numbers of: current active cosets; maximum number of cosets 
	active at any time; total number of cosets defined.
	******************************************************************/

extern int nalive, maxcos, totcos;

	/******************************************************************
	ctail (chead) is the tail (head) of the coincidence queue; we add
	at tail & remove at head.  During coincidence processing CT(high,2)
	(aka COL2(high)) is used to link the coincidence queue together.
	CT(high,1) (aka COL1(high)) contains minus the equivalent (lower 
	numbered) coset (the minus sign flags a `redundant' coset).  The 
	queue is empty if chead = 0.  Primary coincidence are always 
	processed immediately, and processing continues until _all_ 
	secondary coincidences have been resolved.  We _may_ discard 
	deductions in coincidence processing, but never coincidences.  The
	only place where coincidences could be `discarded' is in table
	compaction; however, this is never called when the queue is non-
	empty, ie, during coincidence processing.
	******************************************************************/

extern int chead, ctail;

	/******************************************************************
	If pdefn>0, then gaps of length 1 found during relator scans in 
	C-style are preferentially filled (subject to the fill-factor,
	discussed below).  If pdefn=1, they are filled immediately, and if
	pdefn=2, the deduction is also made (of course, these are also put 
	on the deduction stack too).  If pdefn=3, then the gaps are noted 
	in the preferred definition list (pdq).  Provided a live such gap 
	survives (and no coincidence occurs, which causes the pdq to be 
	discarded) the next coset will be defined to fill the oldest gap of
	length 1.
 
	On certain examples, e.g., F(2,7), this can cause infinite looping 
	unless CT filling is guaranteed.  This can be ensured by insisting 
	that at least some constant proportion of the coset table is always
	kept filled & `tested'.  This is done using ffactor.  Before 
	defining a coset to fill a gap of length 1, the enumerator checks 
	whether ffactor*knh is at least nextdf and, if not, fills rows in 
	standard order.  A good default value for ffactor (set by Level 1)
	is int((5(ncol+2))/4).  Warning: using a ffactor with a large 
	absolute value can cause infinite looping.  However, in general, a 
	`large' positive value for ffactor works well.  Note: we'd 
	`normally' expect that nextdf/knh ~ ncol+1 (ignoring coincidences,
	which confuse things), so the default value of ffactor `encourages'
	this ratio to grow a little.

	Note: tests indicate that the effects of the various pdefn/ffactor
	combinations vary widely.  It is not clear which values are good 
	general defaults or, indeed, whether any of the combinations is 
	_always_ `not too bad'.
	******************************************************************/

extern int pdefn;
extern float ffactor;
 
	/******************************************************************
        The preferred definition queue (pdq) is implemented as a ring,
	dropping earliest entries (see Havas, "Coset enumeration 
	strategies", ISSAC'91).  It's size _must_ be a power of 2, so that
	the NEXTPD macro can be fast (masking the ring index with 1...1 to 
	cycle from pdsiz-1 back to 0).  The row/col arrays store the coset 
	number/generator values.  Entries are added at botpd and removed 
	at toppd.  The list is empty if botpd = toppd; so, in fact, the
	list can store only pdsiz-1 values!
        ******************************************************************/

extern int pdsiz;
#define NEXTPD(i)  ((++i) & (pdsiz-1))

extern int *pdqcol, *pdqrow;
extern int toppd, botpd;

	/******************************************************************
        The deduction list is organised as a stack.  Deductions may be 
	discarded, and discards are flagged by disded, as they may impact
	the validity of a finite index.  (If deductions are not processed,
	under some circumstances the result may be a multiple of the 
	actual index.)  We only `log' discards if we try to stack them & 
	can't (ie, stack full) or if they're `potentially' meaningful (eg,
	if we _know_ the table has collapsed, and index=1, then stacked 
	deductions are _not_ meaningful).  The stack is empty if topded=-1,
	and dedsiz is the available stack space.

	Note that if we define N.g = M, and thus M.G = N, we only stack
	N/g.  When we unstack, we test both N/g (picking up M) & M/G.  We
	ignore cosets that have become redundant, but we do nothing (too 
	expensive) about duplicates (either direct or inverted); these will
	scan fast however, since `nothing' happens.

	We test various stack-handling options by the dedmode parameter.  0
	means do nothing (except discard individually if no space), 1 means
	purge redundancies off the top (on exiting _coinc()), 2 means 
	compact out all redundancies (on exiting _coinc()), and 3 means 
	throw away the entire stack if it overflows.  Mode 4 is a fancy 
	mode; every time the stack overflows we call a function to
	`process' it, on the basis that we're prepared to work _very_ hard
	not to throw anything away.  The particular function used is
	subject to review; currently, we expand the space available for the
	stack and move the old stack, compressing it as it's moved by
	removing redundancies.  In practice this works very well, and is
	the default dedn handling method; it means that we always process 
	all deductions.  In the presence of collapses, a judicious choice
	of dedsize & the use of Mode 0 will often be faster however.

	Discussion: dedsiz is usually some `small' value, as the active 
	stack is normally small and shrinks back to empty rapidly.  Since 
	the enumerator is `clever' enough to `notice' dropped/unprocessed 
	deductions & take appropriate action when checking a finite result,
	it makes sense in some circumstances to drop excessive deductions.
 	In particular, if we have a lot of coincidences in al0_coinc, and 
	thus a big stack (esp. one that doesn't shrink quickly), it is much
	faster to ignore these and tidy up at the end (since most of the 
	stack is redundant, duplicate or yields no info).  This is somewhat
	similar to the adaptive flag of ACE1/2.  (An alternative option
	would be to do a C-lookahead at the top of _cdefn() if ever dedns 
	have been discarded, but this could be very expensive.)
	******************************************************************/

extern int   dedsiz;
extern int  *dedrow, *dedcol;
extern int   topded, dedmode;
extern Logic disded;

	/******************************************************************
	Macro to save a deduction on the stack.  Note the function call in
	mode 4, if the stack overflows; this can be v. expensive if the 
	stack overflows repeatedly (ie, a big collapse).  It's a question 
	of which is faster; trying hard _not_ to discard deductions, or 
	discarding them & having to run a checking phase at the end of an 
	enumeration.  In practice, _dedn() doubles the stack space at each
	call, so it's not actually called very often!
        ******************************************************************/

#ifdef AL0_STAT
# define SAVED00          \
    if (topded >= sdmax)  \
      { sdmax = topded+1; }
#else
# define SAVED00
#endif

#define SAVED(cos,gen)      \
  INCR(xsaved);             \
  if (topded >= dedsiz-1)   \
    {                       \
    INCR(sdoflow);          \
    switch(dedmode)         \
      {                     \
      case 3:               \
        disded = TRUE;      \
        topded = -1;        \
        break;              \
      case 4:               \
        al0_dedn(cos,gen);  \
        break;              \
      default:              \
        disded = TRUE;      \
        break;              \
      }                     \
    }                       \
  else                      \
    {                       \
    dedrow[++topded] = cos; \
    dedcol[topded] = gen;   \
    }                       \
  SAVED00;

	/******************************************************************
	We note where generators occur in bases of relators, so that 
	definitions can be applied at all essentially different positions 
	(edp) in C-style definitions or in C-style lookahead.  edpbeg[g] 
	indexes array edp[], giving the first of the edps in all 
	(noninvolutory) relators for that generator.  The edp array stores 
	pairs: the index in array relators where this generator occurs; the
	length of the relator.  edpend[g] indexes the last edp pair for 
	generator g.  If there are no such positions edpbeg[g] < 0.  
	Generators are in terms of column numbers, so noninvolutory 
	generators have two sets of entries.  Generators which are to be 
	_treated_ as involutions have only one column & one set of entries.
	The edp of a relator xx (or x^2, or XX, or X^2) where x is to be 
	treated as an involution is _not_ stored, since it yields no 
	information in a C-style scan.
	******************************************************************/

extern int *edp, *edpbeg, *edpend;

	/******************************************************************
	Group generators (aka coset table columns): 
	******************************************************************/

extern int ncol;		/* Number of columns in CT. Involutions 
				(usually) use only 1 column, noninvolutary
				generators 2. */
extern int **colptr;		/* Array of pointers to CT columns */
extern int *col1ptr, *col2ptr;	/* Special pointers for cols 1 & 2 */
extern int *invcol;		/* Table mapping columns to their inverse 
				columns, length ncol+1. */

	/******************************************************************
	Group relators: 
	******************************************************************/

extern int ndrel;		/* Number of relators */
extern int *relind;		/* relind[i] is the start position of ith 
				relator in array relators[] */
extern int *relexp;   		/* relexp[i] is exponent (ith rel'r) */
extern int *rellen;   		/* rellen[i] is total length (ith rel'r) */
extern int *relators; 		/* The relators, fully expanded and 
				duplicated for efficient scanning */

	/******************************************************************
	Subgroup generators: 
	******************************************************************/

extern int nsgpg;		/* Number of subgroup generators */
extern int *subggen;        	/* All the subgroup generators */
extern int *subgindex;		/* Start index of each generator */
extern int *subglength;		/* Length of each generator */

extern Logic sgdone;		/* ?have they been applied to coset #1 */

	/******************************************************************
	knr is the coset at which an R-style scanning against relators is 
	to commence; all previous (active) cosets trace complete cycles at 
	all relators.  If knr == nextdf _and_ the table in hole-free, then
	a valid index has been obtained.  knh is the coset at which a 
	search for an undefined coset table entry is to begin; all previous
	cosets have all entries in their row defined.  If C-style
	definitions are being (or will be) made, all previous cosets have 
	all entries in their row defined, and all consequences traced or 
	definitions stacked.  (In fact, _all_ non-zero entries in the table
	have been traced or stacked.)  If knh == nextdf _and_ _all_ 
	definitions have had their consequences processed, then a valid 
	index has been obtained.  Note that currently knh is only changed 
	in C-style, since it is important that the property referred to
	above is preserved.  This effectively overloads the meaning of knh;
	it should be replaced by separately maintained knh & knc variables.
	This would make R-style & C-style symmetric; much nicer!  It would
	also allow us to differentiate between the definition strategy,
	the scanning strategy, and the termination condition.

	nextdf is the next sequentially available coset.  Normally 1 <= knr
	< nextdf and 1 <= knh < nextdf; the value of knr vis-a-vis knh is 
	not fixed.  If knr/knh hit nextdf, then we're done (modulo some 
	other conditions).  Note that 1 <= nalive < nextdf <= maxrow+1. If
	nextdf = maxrow+1 and we want to define a new coset, then we've
	overflowed; we lookahead/compact/abort.
	******************************************************************/

extern int knr, knh, nextdf;

	/******************************************************************
	Externally visible functions defined in enum.c.  Note that it is
	not strictly necessary to make _apply() visible across files, since
	it's only called from within enum.c, but we do anyway, since a
	smart-arse Level 0 user might like to use it.
	******************************************************************/

int al0_apply(int, int*, int*, Logic, Logic);
int al0_enum(int, int);

	/******************************************************************
	Externally visible functions defined in coinc.c
	******************************************************************/

int al0_coinc(int, int, Logic);

	/******************************************************************
	Externally visible functions defined in util0.c
	******************************************************************/

char  *al0_date(void);
double al0_clock(void);
double al0_diff(double, double);
void   al0_init(void);
Logic  al0_compact(void);
Logic  al0_stdct(void);
double al0_nholes(void);
void   al0_upknh(void);
void   al0_dedn(int, int);
void   al0_dump(Logic);
void   al0_rslt(int);

	/******************************************************************
	During code development/testing and when experimenting with an
	enumeration's parameters, it is often helpful to monitor how many 
	times a particular situation occurs.  If the AL0_STAT (ie, 
	statistics) flag is defined, a statistics gathering & processing 
	package is compiled into the code.  If the flag is not defined, 
	none of the macros generate any code, and so there is no overhead. 
	To add an item of interest, you have to add an "extern int x;" 
	declaration below, add an "int x;" definition in enum.c, add 
	"INCR(x);" statements where appropriate (or whatever other 
	processing statements are required), and add "x" to the _statinit()
	& _statdump() functions.
	******************************************************************/

#ifdef AL0_STAT

extern int cdcoinc, rdcoinc, apcoinc, rlcoinc, clcoinc,
  xcoinc, xcols12, qcoinc;
extern int xsave12, s12dup, s12new;
extern int xcrep, crepred, crepwrk;
extern int xcomp, compwrk;
extern int xsaved, sdmax, sdoflow;
extern int xapply, apdedn, apdefn;
extern int rldedn, cldedn;
extern int xrdefn, rddedn, rddefn, rdfill;

extern int xcdefn, cddproc, cdddedn, cddedn, cdgap, cdidefn,
  cdidedn, cdpdl, cdpof, cdpdead, cdpdefn, cddefn;

void al0_statinit(void);
#define STATINIT  al0_statinit()

void al0_statdump(void);
#define STATDUMP  al0_statdump()

#define INCR(x)  x++

#else

#define STATINIT
#define STATDUMP

#define INCR(x)

#endif

