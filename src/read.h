/****************************************************************************
**
*A  read.h                      GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This module declares the functions to read  expressions  and  statements.
*/
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_read_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**
*V  ReadEvalResult  . . . . . . . . result of reading one command immediately
*/
extern  Obj             ReadEvalResult;


/****************************************************************************
**
*F  ReadEvalCommand() . . . . . . . . . . . . . . . . . . .  read one command
**
**  'ReadEvalCommand' reads one command and interprets it immediately.
**
**  It does not expect the  first symbol of its input  already read and  wont
**  read the  first symbol of the  next  input.
*/
extern  UInt            ReadEvalCommand ( void );


/****************************************************************************
**
*F  ReadEvalFile()  . . . . . . . . . . . . . . . . . . . . . . . read a file
**
**  'ReadEvalFile' reads an entire file and returns (in 'ReadEvalResult') the
**  entire file as thunk, i.e., as function of no argument.
**
**  It does not expect the  first symbol of its input  already read and  wont
**  reads to the end of the input (unless an error happens).
*/
extern  UInt            ReadEvalFile ( void );


/****************************************************************************
**
*F  ReadEvalError() . . . . . . . . . . . . . . . . . .  return with an error
*/
extern  void            ReadEvalError ( void );


/****************************************************************************
**
*F  InitRead()  . . . . . . . . . . . . . . . . . . . . initialize the reader
**
**  'InitRead' initializes the reader.
*/
extern  void            InitRead ( void );



