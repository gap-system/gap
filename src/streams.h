/****************************************************************************
**
*W  streams.h                   GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the  various read-eval-print loops and streams related
**  stuff.  The system depend part is in "sysfiles.c".
*/
#ifdef INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_streams_h =
   "@(#)$Id$";
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

*F  SetupStreams(). . . . . . . . . . . . . . . intialize the streams package
*/
extern void SetupStreams ( void );


/****************************************************************************
**
*F  InitStreams() . . . . . . . . . . . . . . . intialize the streams package
*/
extern void InitStreams ( void );


/****************************************************************************
**
*F  CheckStreams()  . . . . . check the initialisation of the streams package
*/
extern void CheckStreams ( void );


/****************************************************************************
**

*E  streams.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/


