/****************************************************************************
**
*W  intfuncs.h                   GAP source                   Martin Schönert
**                                                           & Alice Niemeyer
**                                                           & Werner  Nickel
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares some representation nonspecific integer functions
*/

#ifndef GAP_INTFUNCS_H
#define GAP_INTFUNCS_H

#include <src/system.h>

/* link between Mersenne Twister randim numbers and
   representation specific large integer codes */

extern UInt4 nextrandMT_int32(UInt4* mt);

/* High quality and speed hash functions -- not currently used 
   elsewhere in the kernel but might be a good idea */

extern void MurmurHash3_x86_32 ( const void * key, int len,
                          UInt4 seed, void * out );

extern void MurmurHash3_x64_128 ( const void * key, const int len,
                           const UInt4 seed, void * out );

// These three functions provide an wrappers around MurmurHash3
// for common use cases.
// In particular, they deal with taking the output of MurmurHash3,
// and transforming it into an Int which fits into a GAP
// immediate integer.
// The 'seed' parameter sets the initial seed of the hash, different
// values (should) produce different hash values.

// Hash a block of memory
Int HASHKEY_MEM_NC (const void* ptr, UInt4 seed, Int read);

// Hash an entire bag
Int HASHKEY_WHOLE_BAG_NC (Obj obj, UInt4 seed);

// Hash a bag starting at position 'skip', reading 'read' bytes.
// Does NOT perform bounds checking
Int HASHKEY_BAG_NC (Obj obj, UInt4 seed, Int skip, int read);

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**                                              \
                                                \

*F  InitInfoInt() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoIntFuncs ( void );


#endif // GAP_INTFUNCS_H
