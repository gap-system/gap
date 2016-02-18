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
**  This file declares the functions handling arbitrary size integers.
*/

#ifndef GAP_INTEGER_H
#define GAP_INTEGER_H

#ifdef USE_GMP /* then use the gmp version of the header file */
 #include "gmpints.h"
#else
 #error "GAP integer code has been removed."
#endif

#endif
