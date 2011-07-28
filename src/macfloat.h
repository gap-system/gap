/****************************************************************************
**
*W  macfloat.h                      GAP source                  Steve Linton
**
*H  @(#)$Id: macfloat.h,v 4.7 2011/05/23 10:58:39 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions for the macfloating point package
*/
#ifdef INCLUDE_DECLARATION_PART
const char * Revision_macfloat_h =
   "@(#)$Id: macfloat.h,v 4.7 2011/05/23 10:58:39 sal Exp $";
#endif


#ifdef VERY_LONG_DOUBLES
typedef long double /* __float128 */ Double;
#define TOPRINTFFORMAT long double
#define PRINTFDIGITS 20
#define PRINTFFORMAT "Lg"
#define STRTOD strtold
#define MATH(name) name ## l
#else
typedef double Double;
#define TOPRINTFFORMAT double
#define PRINTFDIGITS 16
#define PRINTFFORMAT "g"
#define STRTOD strtod
#define MATH(name) name
#endif

/*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * **/

/****************************************************************************
**

*F  InitInfoMacfloat()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoMacfloat ( void );


/****************************************************************************
**
*E  macfloat.h  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/




