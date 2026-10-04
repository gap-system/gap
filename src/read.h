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

#include "common.h"

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
**  It does not expect the first symbol of its input already read and won't
**  read the first symbol of the next input.
**
**  If 'dualSemicolon' is a non-zero pointer, then the integer it points to
**  will be set to 1 if the command was followed by a double semicolon, else
**  it is set to 0. If 'dualSemicolon' is zero then it is ignored.
*/
ExecStatus ReadEvalCommand(Obj            context,
                           TypInputFile * input,
                           Obj *          evalResult,
                           BOOL *         dualSemicolon);


/****************************************************************************
**
*F  ReadCheckCommand()  . . . . . . . parse one command, but do not execute it
**
**  'ReadCheckCommand' parses one command from <input> without executing any
**  of it and without printing anything. It returns 'STATUS_END' if a
**  complete command was parsed, 'STATUS_EOF' if the input was exhausted
**  before the first symbol of a command, and 'STATUS_ERROR' on a syntax
**  error.
**
**  Diagnostics are appended to <syntaxErrors> (a plist) if it is non-zero.
**  On 'STATUS_ERROR', if <errorAtEOF> is non-zero, the value it points to is
**  set to TRUE iff the first syntax error was caused by the input ending,
**  i.e., the input is a truncated prefix of potentially valid input.
*/
ExecStatus
ReadCheckCommand(TypInputFile * input, Obj syntaxErrors, BOOL * errorAtEOF);


/****************************************************************************
**
*F  ReadEvalFile()  . . . . . . . . . . . . . . . . . . . . . . . read a file
**
**  'ReadEvalFile' reads an entire file and returns (in 'evalResult') the
**  entire file as thunk, i.e., as function of no argument.
**
**  It does not expect the first symbol of its input already read and reads
**  to the end of the input (unless an error happens).
*/
ExecStatus ReadEvalFile(TypInputFile * input, Obj * evalResult);


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
