/****************************************************************************
**
*W  compiler.h                  GAP source                   Ferencz Rakowczi
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions of the GAP to C compiler.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_compiler_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F  CompileFunc(<output>,<func>,<name>,<magic1>,<magic2>) . . . . . . compile
*/
extern Int CompileFunc (
            Char *              output,
            Obj                 func,
            Char *              name,
            UInt4               magic1,
            Char *              magic2 );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  SetupCompiler() . . . . . . . . . . . . . . . . . initialize the compiler
*/
extern void SetupCompiler ( void );


/****************************************************************************
**
*F  InitCompiler()  . . . . . . . . . . . . . . . . . initialize the compiler
*/
extern void InitCompiler ( void );


/****************************************************************************
**
*F  CheckCompiler() . . . . . . . .  check the initialisation of the compiler
*/
extern void CheckCompiler ( void );


/****************************************************************************
**

*E  compiler.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



