#ifndef GAP_GASMAN_INTERN_H
#define GAP_GASMAN_INTERN_H

#include "gasman.h"

#ifndef USE_GASMAN
#error This file must only be included if GASMAN is used
#endif


/****************************************************************************
**
*F  MarkBagWeakly(<bag>) . . . . . . . . . . . . .  mark a bag as weakly live
**
**  'MarkBagWeakly' is an alternative to MarkBag, intended to be used by the
**  marking functions  of weak pointer objects.  A  bag which is  marked both
**  weakly and strongly  is treated as strongly marked.   A bag which is only
**  weakly marked will be recovered by garbage collection, but its identifier
**  remains, marked      in   a    way    which   can     be   detected    by
**  "IsWeakDeadBag". Which should  always be   checked before copying   or
**  using such an identifier.
*/
extern void MarkBagWeakly( Bag bag );

/****************************************************************************
**
*F  IsWeakDeadBag(<bag>) . . . . . . . . check if <bag> is a weak dead bag
**
**  'IsWeakDeadBag' checks if <bag> is a master pointer which refers to
**  an object which was freed as the only references to it were weak.
**  This is used for implement weak pointer references.
*/
extern Int IsWeakDeadBag(Bag bag);

/****************************************************************************
**
*/
extern  Bag *                   MptrBags;
extern  Bag *                   MptrEndBags;
extern  Bag *                   AllocBags;


/****************************************************************************
**
*F  InitSweepFuncBags(<type>,<sweep-func>)  . . . . install sweeping function
**
**  'InitSweepFuncBags( <type>, <sweep-func> )'
**
**  'InitSweepFuncBags' installs the function <sweep-func> as sweeping
**  function for bags of type <type>.
**
**  A sweeping function is a function that takes two arguments src and dst of
**  type Bag *, and  a third, length of type  UInt, and returns nothing. When
**  it  is called, src points to  the start of the data  area of one bag, and
**  dst to another. The function should copy the  data from the source bag to
**  the destination, making any appropriate changes.
**
**  Those functions are applied during  the garbage collection to each marked
**  bag, i.e., bags that are assumed  to be still live  to move them to their
**  new  position. The  intended  use is  for  weak  pointer bags, which must
**  remove references to identifiers of  any half-dead objects.
**
**  If no function  is installed for a TNum,  then the data is  simply copied
**  unchanged and this is done particularly quickly.
*/

typedef void            (* TNumSweepFuncBags ) (
            Bag  *               src,
            Bag *                dst,
            UInt                 length);

extern  void            InitSweepFuncBags (
            UInt                tnum,
            TNumSweepFuncBags    sweep_func );


/****************************************************************************
**
*V  GlobalBags  . . . . . . . . . . . . . . . . . . . . . list of global bags
*/
#ifndef NR_GLOBAL_BAGS
#define NR_GLOBAL_BAGS  20000L
#endif


typedef struct {
    Bag *                   addr [NR_GLOBAL_BAGS];
    const Char *            cookie [NR_GLOBAL_BAGS];
    UInt                    nr;
} TNumGlobalBags;

extern TNumGlobalBags GlobalBags;



extern void SortGlobals( UInt byWhat );

extern Bag * GlobalByCookie(
            const Char *        cookie );


extern void StartRestoringBags( UInt nBags, UInt maxSize);


extern Bag NextBagRestoring( UInt type, UInt flags, UInt size );


extern void FinishedRestoringBags( void );


/****************************************************************************
**
*F  CheckMasterPointers() . . . . . . . . . . . .  do some consistency checks
**
**  'CheckMasterPointers' tests for masterpointers which are not one of the
**  following:
**
**  0                       denoting the end of the free chain
**  NewWeakDeadBagMarker    denoting the relic of a bag that was weakly
**  OldWeakDeadBagMarker    but not strongly linked at the last garbage
**                          collection
**  a pointer into the masterpointer area   a link on the free chain
**  a pointer into the bags area            a real object
**
*/
extern void CheckMasterPointers( void );


/****************************************************************************
**
*F  CallbackForAllBags( <func> ) call a C function on all non-zero mptrs
**
**  This calls a   C  function on every   bag, including ones  that  are  not
**  reachable from    the root, and   will  be deleted  at the   next garbage
**  collection, by simply  walking the masterpointer area. Not terribly safe.
**
*/
extern void CallbackForAllBags( void (*func)(Bag) );


#endif
