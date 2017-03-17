/****************************************************************************
**
*W  string.h                    GAP source                   Markus Pfeiffer
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file is a header added for backwards compatibility with packages
**  that use the include "string.h". The name string.h clashes with the POSIX
**  system include file string.h and was hence renamed to stringobj.h
**
**/

#if !defined(GAP_STRING_H)
#define GAP_STRING_H

#include <src/stringobj.h>

// stringobj.h has #include <string.h>
#include <string.h>

#endif
