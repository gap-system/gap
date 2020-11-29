/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares functions and variables related to memory management,
**  for use by GASMAN.
**
*/

#ifndef GAP_SYSMEM_H
#define GAP_SYSMEM_H

#include "common.h"

#ifndef USE_GASMAN
#error This file must only be included if GASMAN is used
#endif


/****************************************************************************
**
*V  SyStorMax . . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorMax' is the maximal size of the workspace allocated by Gasman
**  in kilobytes.
**
**  This is per default 1G in 32-bit mode and 2G in 64-bit mode, which
**  is often a reasonable value. It is usually changed with the '-o'
**  option in the script that starts GAP.
**
**  This is used in the function 'SyAllocBags' below.
*/
extern Int SyStorMax;

// SyStorOverrun tracks whether an allocation exceeding the memory limit
// specified by SyStorMax is exceeded. Several places in the GAP code base
// check its values and will take appropriate actions if it is set to a
// value different from SY_STOR_OVERRUN_CLEAR.
typedef enum {
    SY_STOR_OVERRUN_CLEAR,
    SY_STOR_OVERRUN_TO_REPORT,
    SY_STOR_OVERRUN_REPORTED
} SyStorEnum;
extern SyStorEnum SyStorOverrun;

/****************************************************************************
**
*V  SyStorKill . . . . . . . . . . . . . . . . . . maximal size of workspace
**
**  'SyStorKill' is really the maximal size of the workspace allocated by
**  Gasman in kilobytes. GAP exits before trying to allocate more than this
**  amount of memory.
**
**  This is per default disabled (i.e. = 0).
**  Can be changed with the '-K' option in the script that starts GAP.
**
**  This is used in the function 'SyAllocBags' below.
*/
extern Int SyStorKill;

/****************************************************************************
**
*V  SyStorMin . . . . . . . . . . . . . .  default size for initial workspace
**
**  'SyStorMin' is the size of the initial workspace allocated by Gasman
**  in kilobytes.
**
**  This is per default  24 Megabyte,  which  is  often  a  reasonable  value.
**  It is usually changed with the '-m' option in the script that starts GAP.
**
**  This value is used in the function 'SyAllocBags' below.
*/
extern Int SyStorMin;

/****************************************************************************
**
*V  SyAllocPool
**
**  'SyAllocPool' is the size of the OS memory block which Gasman is using
**  to store its workspace.
**
**  Gasman's workspace must be a single continuous block, and can only be
**  extended. Extending this memory block after GAP has been running for a
**  while requires the OS does not allocate any memory immediately after the
**  current location of the workspace. On 64-bit systems using mmap this is
**  usually possible as GAP's workspace starts at memory location 16TB. On
**  32-bit systems it may not be possible to extend so this acts as the
**  maximum workspace size. The main reason extending the workspace on 32-bit
**  fails is if code calls malloc (or new in C++), which many packages do.
**
**  This option can be changed with -s.
*/
extern UInt SyAllocPool;

/****************************************************************************
**
*V  SyMsgsFlagBags  . . . . . . . . . . . . . . . . .  enable gasman messages
**
**  'SyMsgsFlagBags' determines whether garbage collections are reported  or
**  not.
**
**  Per default it is false, i.e. Gasman is silent about garbage collections.
**  It can be changed by using the  '-g'  option  on the  GAP  command  line.
**
**  This is used in the function 'SyMsgsBags' below.
**
**  Put in this package because the command line processing takes place here.
*/
extern UInt SyMsgsFlagBags;

/****************************************************************************
**
*F * * * * * * * * * * * * * * gasman interface * * * * * * * * * * * * * * *
*/
#if defined(GAP_MEM_CHECK)
UInt   GetMembufCount(void);
void * GetMembuf(UInt i);
UInt   GetMembufSize(void);
#endif

/****************************************************************************
**
*F  SyMsgsBags( <full>, <phase>, <nr> ) . . . . . . . display Gasman messages
**
**  'SyMsgsBags' is the function that is used by Gasman to  display  messages
**  during garbage collections.
**
**  If <full> is 1, the current garbage collection is a full one.  If <phase>
**  is 0, the garbage collection has just started and  <nr> should be ignored
**  in this case.  If <phase> is 1 respectively 2, the garbage collection has
**  completed the mark phase  and <nr> is  the total number  respectively the
**  total  size of live bags.   If <phase> is  3  respectively 4, the garbage
**  collection  has completed  the  sweep  phase,   and <nr>  is   the number
**  respectively the total size of bags that died since the last full garbage
**  collection.  If <phase> is  5 respectively 6,  the garbage collection has
**  completed the check phase   and <nr> is    the size of the free   storage
**  respectively the size of the workspace.  All sizes are measured in KByte.
**
**  If  <full> is 0,  the current garbage  collection  is a  partial one.  If
**  <phase> is 0, the garbage collection has just  started and <nr> should be
**  ignored  in  this  case.  If  <phase>  is 1  respectively 2,  the garbage
**  collection  has   completed the  mark   phase  and  <nr>   is the  number
**  respectively the  total size  of bags allocated  since  the last  garbage
**  collection that  are still  live.   If <phase> is  3 respectively  4, the
**  garbage collection has completed  the sweep phase and  <nr> is the number
**  respectively the   total size of   bags allocated since  the last garbage
**  collection that are already dead (thus the sum of the values from phase 1
**  and 3  is the  total number of   bags  allocated since the  last  garbage
**  collection).  If <phase> is 5 respectively 6,  the garbage collection has
**  completed the  check phase  and <nr>  is   the size of  the  free storage
**  respectively the size of the workspace.  All sizes are measured in KByte.
**
**  The message  function  should display   the information  for each   phase
**  immediatly, i.e.,  by calling 'flush' if the  output device is a file, so
**  that the user has some indication how much time each phase used.
**
**  For example {\GAP} displays messages for  full garbage collections in the
**  following form{\:}
**
**    #G  FULL  47601/ 2341KB live  70111/ 5361KB dead   1376/ 4096KB free
**
**  where 47601 is the total number of bags surviving the garbage collection,
**  using 2341 KByte, 70111 is  the total number  of bags that died since the
**  last full garbage  collection, using 5361  KByte, 1376 KByte are free and
**  the total size of the workspace is 4096 KByte.
**
**  And partial garbage collections are displayed in  {\GAP} in the following
**  form{\:}
**
**    #G  PART     34/   41KB+live   3016/  978KB+dead   1281/ 4096KB free
**
**  where  34 is the  number of young bags that  were live after this garbage
**  collection, all the old bags survived it  anyhow, using 41 KByte, 3016 is
**  the number of young bags that died since  the last garbage collection, so
**  34+3016 is the  number  of bags allocated  between  the last two  garbage
**  collections, using 978 KByte and the other two numbers are as above.
*/
void SyMsgsBags(UInt full, UInt phase, Int nr);

extern Int SyGasmanNumbers[2][9];

/****************************************************************************
**
*F  SyMAdviseFree( )  . . . . . . . . . . . . . inform os about unused memory
**
**  'SyMAdviseFree' is the function that informs the operating system that
**  the memory range after the current work space end is not needed by GAP. 
**  This call is purely advisory and does not actually free pages, but
**  only affects paging behavior.
**  This function is called by GASMAN after each successfully completed
**  garbage collection.
*/
void SyMAdviseFree(void);


/****************************************************************************
**
*F  SyAllocBags( <size>, <need> ) . allocate memory block of <size> kilobytes
**
**  'SyAllocBags' is called from Gasman to get new storage from the operating
**  system. <size> is the needed amount in kilobytes (it is always a multiple
**  of 512 KByte), and <need> tells 'SyAllocBags' whether Gasman really needs
**  the storage or only wants it to have a reasonable amount of free storage.
**
**  Currently  Gasman  expects this function to return  immediately  adjacent
**  areas on subsequent calls.  So 'sbrk' will  work  on  most  systems,  but
**  'malloc' will not.
**
**  If <need> is 0, 'SyAllocBags' must return 0 if it cannot or does not want
**  to extend the workspace,  and a pointer to the allocated area to indicate
**  success.   If <need> is 1  and 'SyAllocBags' cannot extend the workspace,
**  'SyAllocBags' must abort,  because GAP assumes that  'NewBag'  will never
**  fail.
**
**  If the operating system does not support dynamic memory management, simply
**  give 'SyAllocBags' a static buffer, from where it returns the blocks.
*/
UInt *** SyAllocBags(Int size, UInt need);


/****************************************************************************
**
*F  SyFreeBags( <size> ) . . . . . . . . . return <size> kilobytes to the OS
**
**  'SyFreeBags' should return the last <size> kilobytes of storage to the
**  operating system. 'SyFreeBags' can either accept this reduction and
**  return 1 and return the storage to the operating system or refuse the
**  reduction and return 0.
*/
Int SyFreeBags(Int size);


/****************************************************************************
**
*F  SyFreeAllBags( ) . . . . . . . . . . . . . .  return all memory to the OS
**
**  'SyFreeAllBags' returns all memory allocated by 'SyAllocBags' to the OS.
*/
void SyFreeAllBags(void);


#endif // GAP_SYSMEM_H
