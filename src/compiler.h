/****************************************************************************
**
*W  compiler.h                  GAP source                   Ferenc Ràkòczi
*W                                                         & Martin Schönert
**
*H  @(#)$Id: compiler.h,v 4.11 2010/02/23 15:13:40 gap Exp $
**
*Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the GAP to C compiler.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_compiler_h =
   "@(#)$Id: compiler.h,v 4.11 2010/02/23 15:13:40 gap Exp $";
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
*F  SetCompileOpts( <string> ) . . parse the compiler options from <string>
**                                 and set the appropriate variables
**                                 unrecognised options are ignored for now
*/

extern void SetCompileOpts( Char *opts );


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



