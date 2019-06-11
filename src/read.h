/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This module declares the functions to read  expressions  and  statements.
*/

#ifndef GAP_READ_H
#define GAP_READ_H

#include "system.h"

/****************************************************************************
**
*F  TRY_IF_NO_ERROR / CATCH_ERROR
**
**  To deal with errors found by the reader, we implement a kind of exception
**  handling using setjmp, with the help of two macros.
**
**  To use these constructs, write code like this:
**    TRY_IF_NO_ERROR {
**       ... code which might trigger reader error ...
**    }
**  or
**    TRY_IF_NO_ERROR {
**       ... code which might trigger reader error ...
**    }
**    CATCH_ERROR {
**       ... error handler ...
**    }
**
**  Then, if the reader encounters an error, or if the interpretation of an
**  expression or statement leads to an error, 'ReadEvalError' is invoked,
**  which in turn calls 'longjmp' to return to right after the block
**  following TRY_IF_NO_ERROR.
**
**  A second effect of 'TRY_IF_NO_ERROR' is that it prevents the execution of the
**  code it wraps if 'STATE(NrError)' is non-zero, i.e. if any errors
**  occurred. This is key for enabling graceful error recovery in the reader,
**  and for this reason it is crucial that all calls from the reader into
**  the interpreter are wrapped into 'TRY_IF_NO_ERROR' blocks.
**
**  Note that while you can in principle nest TRY_IF_NO_ERROR constructs, to do this
**  correctly, you must backup ReadJmpError before TRY_IF_NO_ERROR, and restore it
**  in a matching CATCH_ERROR block.
*/
/* TL: extern syJmp_buf ReadJmpError; */

#define TRY_IF_NO_ERROR \
    if (!STATE(NrError)) { \
        volatile Int recursionDepth = GetRecursionDepth();  \
        if (sySetjmp(STATE(ReadJmpError))) { \
            SetRecursionDepth(recursionDepth);  \
            STATE(NrError)++; \
        }\
    }\
    if (!STATE(NrError))

#define CATCH_ERROR \
    else


/****************************************************************************
**
*F * * * * * * * * * * * * read and evaluate symbols  * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  ReadEvalCommand() . . . . . . . . . . . . . . . . . . .  read one command
**
**  'ReadEvalCommand' reads one command and interprets it immediately.
**
**  It does not expect the  first symbol of its input  already read and  wont
**  read the  first symbol of the  next  input.
**
**  The if pointer dualSemicolon is non-zero, then the integer it
**  it points to will be set to 1 if the command was followed by
**  a double semi-colon, otherwise it is set to 0. It is safe to
**  pass 0 for dualSemicolon, in this case it is ignore.
**
*/
UInt ReadEvalCommand(Obj context, Obj * evalResult, UInt * dualSemicolon);


/****************************************************************************
**
*F  ReadEvalFile()  . . . . . . . . . . . . . . . . . . . . . . . read a file
**
**  'ReadEvalFile' reads an entire file and returns (in 'evalResult') the
**  entire file as thunk, i.e., as function of no argument.
**
**  It does not expect the  first symbol of its input  already read and  wont
**  reads to the end of the input (unless an error happens).
*/
UInt ReadEvalFile(Obj * evalResult);


/****************************************************************************
**
*F  ReadEvalError() . . . . . . . . . . . . . . . . . .  return with an error
*/
void ReadEvalError(void) NORETURN;


/****************************************************************************
**
*/
void StartFakeFuncExpr(Int startLine);
void FinishAndCallFakeFuncExpr(void);


/****************************************************************************
**
*/
void PushGlobalForLoopVariable(UInt var);

void PopGlobalForLoopVariable(void);


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
Obj Call1ArgsInNewReader(Obj f, Obj a);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoRead()  . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoRead ( void );


#endif // GAP_READ_H
