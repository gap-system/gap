/****************************************************************************
**
*W  compiler.h                  GAP source                   Ferencz Rakowczi
*W                                                         & Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
**
**  This file declares the functions of the GAP to C compiler.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_compiler_h =
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

*F  InitInfoCompiler() . . . . . . . . . . . . . . .  table of init functions
*/
StructInitInfo * InitInfoCompiler ( void );


/****************************************************************************
**

*E  compiler.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



