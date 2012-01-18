/*****************************************************************************
**
**    pc.h                            NQ                       Werner Nickel
**                                         nickel@mathematik.tu-darmstadt.de
*/

#ifndef PC_H
#define PC_H

#include <stdio.h>
#include "genexp.h"

/*
**    This variable switches the Debug mode on.
*/
extern  int     Debug;

/*
**    A polycyclic presentation has several components which are defined
**    in pc.c.
**
**    NrPcGens: This variable contains the number of generators in the
**            pc-presentation minus the number of central generators,
**            that were defined in the last step.
**    Commute: This seems to be the most difficult data structure because
**            its entries are difficult to compute. `Commute[i]' is the
**            first generator for which the collector from the left has
**            to do something when the i-th generator is moved to its
**            correct place. In other words, the collector starts at
**            `Commute[i]' in the exponent vector when the i-th generator
**            is moved to its place. The length of `Commute' is `NrPcGens'+1.
**    CommuteList: This array holds a list of different versions of
**            Commute[].  They are used for fast evaluation of iterated
**            commutators, as for example Engel conditions.  CommuteList[c]
**            is Commute[] as if the current group had class c.
**    Exponent: This array containes the exponents for the power relation
**            of each generator. If the generator i does not have a power
**            relation, `Exponents[i]' is zero. The length of `Exponents'
**            is `NrPcGens'+1.
**    Power: This array contains the right hand sides of the power
**            relation. If a generator does not have a power relation, the
**            corresponding entry in `Powers' is a null pointer.
**    Conjugate: This 2-dimensional array contains the right hand sides
**            of the conjugate relations for each pair (j,i) of generators
**            with j > i.
*/
extern int      NrPcGens;
extern int      NrCenGens;
extern int      IsFinite;
extern int      IsWeighted;
extern int      Class;

extern gen      *Commute;
extern gen      *Commute2;
extern gen      **CommuteList;
extern gen      **Commute2List;
extern int      *NrPcGensList;

extern expo     *Exponent;
extern word     *Power;
extern word     **Conjugate;
extern char     **PcGenName;

extern int      *Weight;
#define Wt(x)   Weight[(x)]

/*
**    Some generators have definitions in terms of earlier generators.
**    If a generator is defined by a commutator of two earlier generators
**    g and h, then the two components of its definition contain these two
**    generators.
**    If a generator is defined by a power of a generator h,
**    then the first component of its definition contains this generator
**    and the second component is zero.
**    If a generator is defined as an image of a generator of the original
**    finite presentation, the first component is the negative of the
**    number of that generator and the second component is zero.
*/
struct  def {
	gen     h;
	gen     g;
};
typedef struct def  def;

extern def      *Definition;


extern void InitPcPres(void);
extern void ExtPcPres(void);
extern void PrintPcPres(void);
extern void PrintDefs(void);


#endif
