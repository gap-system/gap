/*****************************************************************************
**
**    nq.h                            NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

/*
**    This include file contains the declarations of data structures that
**    build a polycyclic presentation.
*/

#include <stdio.h>
#include <string.h>

#include "config.h"
#include "system.h"

/*
**    This variable indicates whether GAP output should be produced.
*/
extern	int	Gap;

/*
**    This variable indicates whether the relation matrix for each factor
**    of the lower central series is to be written to file.
*/
extern  int     AbelianInv;

/*
**    This variable switches the verbose mode on.
*/
extern	int	Verbose;

/*
**    The input file name. Used in some routines to build a file name for
**    outpout.
*/
extern  char    *InputFile;

#include "mem.h"
#include "genexp.h"
#include "pc.h"
#include "pcarith.h"
#include "collect.h"
#include "macro.h"

extern int	*Dimension;

extern word	*Generators;

/*
**    The data structures used for the integer triagonalization.
*/
extern	long     NrRows;
extern	long     NrCols;
extern	long	*Heads;

/*
**    Functions manipulating words.
**    Defined in word.c.
*/
extern	word	getWord();
extern	int	cmpWords();
extern	void	printWord();

/*
**    Functions manipulating exponent vectors
*/
extern	expvec	expVector();

/*
**    Functions manipulating the pc-presentation,
**    defined in pc.c.
*/
extern	void	initPcPres();
extern	void	readPcPres();
extern	void	calcCommute();
extern	void	completePcPres();

/*
**    Some useful functions defined in system.c.
*/
extern	long	RunTime();

/*
**    Early stoppping criterion.
*/
extern int      EarlyStop;

/*
**    Print functions.
*/
extern	void	printList();
extern	void	printExpVec();

/*
**    The consistency check.
*/
extern	void	consistency();

extern	void	NqRelations();
