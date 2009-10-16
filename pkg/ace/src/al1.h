
/**************************************************************************

        al1.h
        Colin Ramsay (cram@csee.uq.edu.au)
        6 Dec 00

        ADVANCED COSET ENUMERATOR, Version 3.001

        Copyright 2000
        Centre for Discrete Mathematics and Computing,
        Department of Mathematics and 
          Department of Computer Science & Electrical Engineering,
        The University of Queensland, QLD 4072.
        (http://www.csee.uq.edu.au/~havas/cdmc.html)

This is the header file for Level 1 of ACE; that is, a set of basic
wrapper routines round the core enumerator.  This can also be thought of as
a simple interface between application programmes (eg, ACE Level 2) and the
clever bits.

**************************************************************************/

#include "al0.h"

#define LLL 75                  /* Approx limit on output line length */

	/******************************************************************
        The memory for the coset table is currently allocated as one
        contiguous block.  This is done by the user; Level 1 expects to be 
	`handed' the workspace for the table, pointed to by costable.  
	DEFWORK should be used as the default number of words (i.e., 
	entries) in toto.  The size is indicated via a size/multiplier 
	combination (workspace/workmult).  The usual K/M/G multipliers are 
	used, with a choice of meanings to suit computer scientists, or 
	engineers, or mathematicians.  The default (under pressure) is to
	use powers of 10.  While coset numbers are limited to 2G, table 
	sizes can exceed the 32-bit limit.  tabsiz indicates the maximum 
	number of rows which can (safely) be fitted into the allocated 
	space (depends on ncol); if this works out to less than 2, the
	_start() function will complain.
	******************************************************************/

#define DEFWORK  1000000

#ifdef AL1_BINARY
#  define KILO  1024
#  define MEGA  1048576
#  define GIGA  1073741824
#else
#  define KILO  1000
#  define MEGA  1000000
#  define GIGA  1000000000
#endif

extern int workspace, workmult, *costable;
extern int tabsiz;

	/******************************************************************
	The group relations and subgroup generators are stored as linked
	lists.  Each item on the list consists of an array of generators 
        (i.e., the word), along with its total length, its exponent &
	whether or not it was enter as x^2 (ie, as an involn).  In the
	words, -ve numbers represent inverses.  The word starts at word[1].
	Each list has a header containing the list's length and head/tail 
	pointers.
	******************************************************************/

typedef struct Wlelt
  {
  int *word;			/* array of generators */
  int len, exp;			/* total length, and exponent */
  Logic invol;			/* ?entered as an involution */
  struct Wlelt *next;		/* next in list */
  }
Wlelt;				/* word list element */

typedef struct
  {
  int len;			/* list length */
  Wlelt *first, *last;		/* head & tail of list */
  }
Wlist;				/* word list */

	/******************************************************************
        We find coset rep's by backtracing the table.  currrep is the
	currently active rep've, repsiz is its size & repsp is the space
	allocated to currrep.  Note that the rep is in terms of columns!
	******************************************************************/

extern int *currrep, repsiz, repsp;

	/******************************************************************
        Logic control variables for current enumeration.
	******************************************************************/

extern Logic asis;              /* TRUE: use presentation as given.  FALSE:
                                reduce/reorder relations/generators. */

	/******************************************************************
        Group stuff: 
	******************************************************************/

extern char *grpname;		/* Enumeration (i.e., group) name */
extern Wlist *rellst;		/* The group's relator list */
extern int trellen;		/* Total list length */

extern int ndgen;		/* Number of group generators */
extern Logic *geninv;		/* Are generators involutions? */
extern int *gencol;		/* Translates +/- gen'r nos to columns */
extern int *colgen;		/* col nos to +/- gen'r nos */

extern Logic galpha;		/* True if the generators are letters */
extern char algen[28];		/* Translate generator number (1..ndgen, in
			its order of entry) to its letter (ie, 'a'...'z').
			A printable string, hence 1+26+1=28 posns! */
extern int genal[27];		/* Translate generator letter (where a=1,
				etc) to its order of entry (ie, number). */

	/******************************************************************
        Subgroup stuff: 
	******************************************************************/

extern char *subgrpname;	/* Subgroup name */
extern Wlist *genlst;		/* The subgroup's renerator list */
extern int tgenlen;		/* Total list length */

	/******************************************************************
        Many of the Level 0 parameters can be set directly.  However, some
	of them have slightly different meanings at Level 1 (eg, a special 
	value can be used to indicate a `default'), or can effect a 
	continuing enumeration.  All of the following variables are 
	`aliases' for Level 0 parameters, and it is up to the _start() 
	function to decide when & how they should be transferred to their 
	Level 0 namesakes.
	******************************************************************/

extern int rfactor1, cfactor1;
extern int pdsiz1, dedsiz1;
extern int maxrow1, ffactor1, nrinsgp1;

	/******************************************************************
        Externally visible functions defined in util1.c
	******************************************************************/

void   al1_init(void);
void   al1_dump(Logic);
void   al1_prtdetails(int);
void   al1_rslt(int);
Wlist *al1_newwl(void);
Wlelt *al1_newelt(void);
void   al1_addwl(Wlist*, Wlelt*);
void   al1_concatwl(Wlist*, Wlist*);
void   al1_emptywl(Wlist*);
void   al1_prtwl(Wlist*, int);
Logic  al1_addrep(int);
Logic  al1_bldrep(int);
int    al1_trrep(int);
int    al1_ordrep(void);
void   al1_prtct(int, int, int, Logic, Logic);

	/******************************************************************
        Externally visible functions defined in control.c
	******************************************************************/

int al1_start(int);

