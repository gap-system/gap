/****************************************************************************
**
*W  weakptr.h                   GAP source                       Steve Linton
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions that deal with weak pointer objects
**       it has to interwork somewhat closely with GASMAN.
**
**  A  weak pointer looks like a plain list, except that it does not cause
**  its entries to remain alive through a garbage collection, with the consequent
**  side effect, that its entries may vanish at any time.
**
**
*/

#ifndef GAP_WEAKPTR_H
#define GAP_WEAKPTR_H

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoWeakPtr() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoWeakPtr ( void );

#ifdef BOEHM_GC
void RegisterWeakReference(Bag *bag);
void UnregisterWeakReference(Bag *bag);
#endif


#endif // GAP_WEAKPTR_H

/****************************************************************************
**
*E  weakptr.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
