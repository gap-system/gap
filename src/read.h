/****************************************************************************
**
*W  read.h                      GAP source                   Martin Schoenert
**
*H  @(#)$Id: read.h,v 4.18 2008/01/10 17:24:49 sal Exp $
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This module declares the functions to read  expressions  and  statements.
*/
#ifdef  INCLUDE_DECLARATION_PART
const char * Revision_read_h =
   "@(#)$Id: read.h,v 4.18 2008/01/10 17:24:49 sal Exp $";
#endif


/****************************************************************************
**

*F  READ_ERROR()  . . . . . . . . . . . . . . . . . . . reader found an error
**
**  'READ_ERROR' returns a non-zero value if the reader found an error, or if
**  the interpretation of  an expression  or  statement lead to an  error (in
**  which case 'ReadEvalError' jumps back to 'READ_ERROR' via 'longjmp').
*/
/* TL: extern jmp_buf ReadJmpError; */

#ifndef DEBUG_READ_ERROR

#define READ_ERROR()    (TLS->nrError || (TLS->nrError+=setjmp(TLS->readJmpError)))

#else

#define READ_ERROR()                                                     \
    ( TLS->nrError ||                                                         \
      ( ( TLS->nrError += setjmp(TLS->readJmpError) ) ?                            \
        Pr( "READ_ERROR( %s, %d )\n", (Int)__FILE__, __LINE__ ),0 : 0 ), \
      TLS->nrError )

#endif


/****************************************************************************
**

*F * * * * * * * * * * * * read and evaluate symbols  * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  ReadEvalResult  . . . . . . . . result of reading one command immediately
*/
/* TL: extern Obj ReadEvalResult; */


/****************************************************************************
**
*F  ReadEvalCommand() . . . . . . . . . . . . . . . . . . .  read one command
**
**  'ReadEvalCommand' reads one command and interprets it immediately.
**
**  It does not expect the  first symbol of its input  already read and  wont
**  read the  first symbol of the  next  input.
**
*/
extern UInt ReadEvalCommand ( Obj context );


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
extern UInt ReadEvalFile ( void );


/****************************************************************************
**
*F  ReadEvalError() . . . . . . . . . . . . . . . . . .  return with an error
*/
extern void ReadEvalError ( void );

/* extern ExecStatus ReadEvalDebug ( void ); */

/****************************************************************************
**
*V  StackNams, CountNames . . . . . .stack of lists of local variable names
**
**  This is exported to support a rather nasty hack in intrprtr.c todo with
**  while loops and the break loop
*/

/* TL: extern Obj StackNams; */
/* TL: extern UInt CountNams; */


extern void PushGlobalForLoopVariable( UInt var);

extern void PopGlobalForLoopVariable( void );

extern UInt GlobalComesFromEnclosingForLoop (UInt var);


/****************************************************************************
**
*F  Call0ArgsInNewReader(Obj f)  . . . . . . . . . . . . call a GAP function
**
**  The current reader context is saved and a new one is started.
*/
Obj Call0ArgsInNewReader(Obj f);

/****************************************************************************
**
*F  Call1ArgsInNewReader(Obj f,Obj a) . . . . . . . . . . call a GAP function
**
**  The current reader context is saved and a new one is started.
*/
Obj Call1ArgsInNewReader(Obj f,Obj a);


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoRead()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoRead ( void );


/****************************************************************************
**

*E  read.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
