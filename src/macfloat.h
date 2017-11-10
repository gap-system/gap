/****************************************************************************
**
*W  macfloat.h                      GAP source                  Steve Linton
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions for the macfloat package
*/

#ifndef GAP_MACFLOAT_H
#define GAP_MACFLOAT_H

#include <src/objects.h>

#ifdef VERY_LONG_DOUBLES
typedef long double /* __float128 */ Double;
#define TOPRINTFFORMAT long double
#define PRINTFDIGITS 20
#define PRINTFFORMAT "Lg"
#define STRTOD strtold
#define MATH(name) name##l
#else
typedef double Double;
#define TOPRINTFFORMAT double
#define PRINTFDIGITS 16
#define PRINTFFORMAT "g"
#define STRTOD strtod
#define MATH(name) name
#endif

static inline Double VAL_MACFLOAT(Obj obj)
{
    Double val;
    memcpy(&val, CONST_ADDR_OBJ(obj), sizeof(Double));
    return val;
}

static inline void SET_VAL_MACFLOAT(Obj obj, Double val)
{
    memcpy(ADDR_OBJ(obj), &val, sizeof(Double));
}

static inline BOOL IS_MACFLOAT(Obj obj)
{
    return TNUM_OBJ(obj) == T_MACFLOAT;
}

extern Obj NEW_MACFLOAT(Double val);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoMacfloat() . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoMacfloat(void);


#endif    // GAP_MACFLOAT_H
