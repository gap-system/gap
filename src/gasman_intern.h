/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_GASMAN_INTERN_H
#define GAP_GASMAN_INTERN_H

#include "gasman.h"

#ifndef USE_GASMAN
#error This file must only be included if GASMAN is used
#endif


/****************************************************************************
**
*V  NrAllBags . . . . . . . . . . . . . . . . .  number of all bags allocated
*V  SizeAllBags . . . . . . . . . . . . . .  total size of all bags allocated
*V  NrLiveBags  . . . . . . . . . .  number of bags that survived the last gc
*V  SizeLiveBags  . . . . . . .  total size of bags that survived the last gc
*V  NrDeadBags  . . . . . . . number of bags that died since the last full gc
*V  SizeDeadBags  . . . . total size of bags that died since the last full gc
**
**  'NrAllBags'
**
**  'NrAllBags' is the number of bags allocated since Gasman was initialized.
**  It is incremented for each 'NewBag' call.
**
**  'NrLiveBags'
**
**  'NrLiveBags' is the number of bags that were  live after the last garbage
**  collection.  So after a full  garbage collection it is simply  the number
**  of bags that have been found to be still live by this garbage collection.
**  After a partial garbage collection it is the sum of the previous value of
**  'NrLiveBags', which is the number  of live old  bags, and  the number  of
**  bags that  have been found to  be still live  by this garbage collection,
**  which is  the number of live   young  bags.   This  value  is used in the
**  information messages,  and to find  out  how  many  free  identifiers are
**  available.
**
**  'SizeLiveBags'
**
**  'SizeLiveBags' is  the total size of bags  that were  live after the last
**  garbage collection.  So after a full garbage  collection it is simply the
**  total size of bags that have been found to  be still live by this garbage
**  collection.  After  a partial  garbage  collection it  is the sum  of the
**  previous value of  'SizeLiveBags', which is the total   size of live  old
**  bags, and the total size of bags that have been found to be still live by
**  this garbage  collection,  which is  the  total size of  live young bags.
**  This value is used in the information messages.
**
**  'NrDeadBags'
**
**  'NrDeadBags' is  the number of bags that died since the last full garbage
**  collection.   So after a  full garbage  collection this is zero.  After a
**  partial  garbage  collection it  is  the  sum  of the  previous value  of
**  'NrDeadBags' and the  number of bags that  have been found to be dead  by
**  this garbage collection.  This value is used in the information messages.
**
**  'SizeDeadBags'
**
**  'SizeDeadBags' is  the total size  of bags that  died since the last full
**  garbage collection.  So  after a full   garbage collection this  is zero.
**  After a partial garbage collection it is the sum of the previous value of
**  'SizeDeadBags' and the total size of bags that have been found to be dead
**  by  this garbage  collection.   This  value  is used  in the  information
**  message.
**
**  'NrHalfDeadBags'
**
**  'NrHalfDeadBags'  is  the number of  bags  that  have  been  found to  be
**  reachable only by way of weak pointers since the last garbage collection.
**  The bodies of these bags are deleted, but their identifiers are marked so
**  that weak pointer objects can recognize this situation.
*/

extern  UInt                    NrAllBags;
extern  UInt                    NrLiveBags;
extern  UInt                    SizeLiveBags;
extern  UInt                    NrDeadBags;
extern  UInt8                   SizeDeadBags;
extern  UInt                    NrHalfDeadBags;


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
