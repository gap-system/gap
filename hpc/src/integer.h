/****************************************************************************
**
*W  integer.h                   GAP source                   Martin Schönert
**                                                           & Alice Niemeyer
**                                                           & Werner  Nickel
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file is kept for backwards compatibility, the non-GMP code has been
**  removed.
*/

#ifndef GAP_INTEGER_H
#define GAP_INTEGER_H

#if !defined(USE_GMP) && !defined(USE_PRECOMPILED)
 #error "GAP integer code has been removed."
#else
 #include "gmpints.h"
#endif

#endif
