/****************************************************************************
**
*W  streams.h                   GAP source                       Frank Celler
*W                                                  & Burkhard Hoefling (MAC)
**
*H  @(#)$Id: streams.h,v 4.10 2002/04/15 10:03:58 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the  various read-eval-print loops and streams related
**  stuff.  The system depend part is in "sysfiles.c".
*/
#ifdef INCLUDE_DECLARATION_PART
const char * Revision_streams_h =
   "@(#)$Id: streams.h,v 4.10 2002/04/15 10:03:58 sal Exp $";
#endif


/****************************************************************************
**

*F * * * * * * * * * streams and files related functions  * * * * * * * * * *
*/


/****************************************************************************
**

*F  READ()  . . . . . . . . . . . . . . . . . . . . . . .  read current input
**
**  Read the current input and close the input stream.
*/
extern Int READ ( void );


/****************************************************************************
**
*F  READ_AS_FUNC()  . . . . . . . . . . . . .  read current input as function
**
**  Read the current input as function and close the input stream.
*/
extern Obj READ_AS_FUNC ( void );


/****************************************************************************
**
*F  READ_TEST() . . . . . . . . . . . . . . . . .  read current input as test
**
**  Read the current input as test and close the input stream.
*/
extern Int READ_TEST ( void );


/****************************************************************************
**
*F  READ_GAP_ROOT( <filename> ) . . .  read from gap root, dyn-load or static
**
**  'READ_GAP_ROOT' tries to find  a file under  the root directory,  it will
**  search all   directories given   in 'SyGapRootPaths',  check  dynamically
**  loadable modules and statically linked modules.
*/
extern Int READ_GAP_ROOT ( Char * filename );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoStreams() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoStreams ( void );


/****************************************************************************
**

*E  streams.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


