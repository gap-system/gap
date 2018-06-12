/****************************************************************************
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002-2018 The GAP Group
**
**  This file declares functions and variables related to memory management,
**  for use by GASMAN.
**
*/

#ifndef GAP_SYSMEM_H
#define GAP_SYSMEM_H

#include "system.h"


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
extern Int SyStorOverrun;

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
*/
extern UInt SyAllocPool;


/****************************************************************************
**
*F * * * * * * * * * * * * * * gasman interface * * * * * * * * * * * * * * *
*/

#ifdef GAP_MEM_CHECK
UInt   GetMembufCount(void);
void * GetMembuf(UInt i);
UInt GetMembufSize(void);
#endif

/****************************************************************************
**
*F  SyMsgsBags( <full>, <phase>, <nr> ) . . . . . . . display Gasman messages
**
**  'SyMsgsBags' is the function that is used by Gasman to  display  messages
**  during garbage collections.
*/
extern void SyMsgsBags (
            UInt                full,
            UInt                phase,
            Int                 nr );


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
extern void SyMAdviseFree ( void );

/****************************************************************************
**
*F  SyAllocBags( <size>, <need> ) . . . allocate memory block of <size> kilobytes
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
**  <size> may also be negative in which case 'SyAllocBags' should return the
**  storage to the operating system.  In this case  <need>  will always be 0.
**  'SyAllocBags' can either accept this reduction and  return 1  and  return
**  the storage to the operating system or refuse the reduction and return 0.
**
**  If the operating system does not support dynamic memory management, simply
**  give 'SyAllocBags' a static buffer, from where it returns the blocks.
*/
extern UInt * * * SyAllocBags (
            Int                 size,
            UInt                need );


#endif // GAP_SYSMEM_H
