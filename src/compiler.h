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
char *          Revision_compiler_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**
*F  CompileFunc(<output>,<func>,<name>,<magic1>,<magic2>) . . . . . . compile
*/
extern  Int             CompileFunc (
            Char *              output,
            Obj                 func,
            Char *              name,
            Int                 magic1,
            Int                 magic2 );


/****************************************************************************
**
*F  InitCompiler()  . . . . . . . . . . . . . . . . . initialize the compiler
*/
extern  void            InitCompiler ( void );


/****************************************************************************
**
*E  compiler.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



