/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This module contains the functions to read expressions and statements.
*/

#include "read.h"

#include "bool.h"
#include "calls.h"
#include "code.h"
#include "funcs.h"
#include "gapstate.h"
#include "gvars.h"
#include "intrprtr.h"
#include "io.h"
#include "modules.h"
#include "plist.h"
#include "records.h"
#include "scanner.h"
#include "stats.h"
#include "stringobj.h"
#include "sysopt.h"
#include "sysstr.h"
#include "trycatch.h"
#include "vars.h"

#ifdef HPCGAP
#include "hpc/thread.h"
#endif


/****************************************************************************
**
*S  TRY_IF_NO_ERROR
**
**  To deal with errors found by the reader, we implement a kind of exception
**  handling using setjmp, with the help of this macro. See also
**  GAP_TRY and GAP_CATCH in trycatch.h for two closely related macros.
**
**  To use this construct, write code like this:
**    TRY_IF_NO_ERROR {
**       ... code which might trigger reader error ...
**    }
**
**  Then, if the reader encounters an error, or if the interpretation of an
**  expression or statement leads to an error, 'GAP_THROW' is invoked,
**  which in turn calls 'longjmp' to return to right after the block
**  following TRY_IF_NO_ERROR.
**
**  A second effect of 'TRY_IF_NO_ERROR' is that it prevents the execution of
**  the code it wraps if 'rs->s.NrError' is non-zero, i.e. if any errors
**  occurred. This is key for enabling graceful error recovery in the reader,
**  and for this reason it is crucial that all calls from the reader into
**  the interpreter are wrapped into 'TRY_IF_NO_ERROR' blocks.
**
**  The above is the first major difference between 'TRY_IF_NO_ERROR' and the
**  related GAP_TRY macro. The second is that unlike GAP_TRY / GAP_CATCH,
**  the TRY_IF_NO_ERROR macro does not save and restore the jump buffer.
**  Rather this is only done at the top level in 'ReadEvalCommand', for
**  performance reasons (saving and restoring a jump buffer is expensive)
**
**  As a result, it is not safe to nest TRY_IF_NO_ERROR constructs without
**  extra precautions. So in general it is best to not invoke any code
**  which again uses TRY_IF_NO_ERROR from inside a TRY_IF_NO_ERROR block.
**  This is automatically ensured if one just calls interpreter functions,
**  as the interpreter does not use TRY_IF_NO_ERROR.
*/
/* TL: extern jmp_buf ReadJmpError; */


#define TRY_IF_NO_ERROR                                                      \
    if (!rs->s.NrError) {                                                    \
        volatile Int recursionDepth = GetRecursionDepth();                   \
        if (_setjmp(STATE(ReadJmpError))) {                                  \
            SetRecursionDepth(recursionDepth);                               \
            rs->s.NrError++;                                                 \
        }                                                                    \
    }                                                                        \
    if (!rs->s.NrError)


struct ReaderState {

ScannerState s;

IntrState intr;

/****************************************************************************
**
*V  StackNams . . . . . . . . . . . . .  stack of local variables names lists
**
**  'StackNams' is a stack of local variables  names lists.  A new names list
**  is pushed onto this stack when the  reader begins to  read a new function
**  expression  (after  reading the argument   list  and the local  variables
**  list), and popped again when the reader has finished reading the function
**  expression (after reading the 'end').
*/
Obj  StackNams;

/****************************************************************************
**
*V  ReadTop . . . . . . . . . . . . . . . . . . . . . .  top level expression
*V  ReadTilde . . . . . . . . . . . . . . . . . . . . . . . . . .  tilde read
**
**  'ReadTop' is 0 if the reader is currently not reading a list or record
**  expression. 'ReadTop' is 1 if the reader is currently reading an outmost
**  list or record expression. 'ReadTop' is larger than 1 if the reader is
**  currently reading a nested list or record expression.
**
**  'ReadTilde' is 1 if the reader has read a reference to a '~' symbol
**  within the current outmost list or record expression.
*/
UInt ReadTop;
UInt ReadTilde;

/****************************************************************************
**
*V  CurrLHSGVar . . . . . . . . . . . .  current left hand side of assignment
**
**  'CurrLHSGVar' is the current left hand side of an assignment.  It is used
**  to prevent undefined global variable  warnings, when reading a  recursive
**  function.
*/
UInt CurrLHSGVar;


UInt CurrentGlobalForLoopVariables[100];
UInt CurrentGlobalForLoopDepth;

UInt LoopNesting;

};

typedef struct ReaderState ReaderState;


/****************************************************************************
**
**  The constructs <Expr> and <Statements> may have themselves as subpart,
**  e.g., '<Var>( <Expr> )' is <Expr> and 'if <Expr> then <Statements> fi;'
**  is <Statements>. The functions 'ReadExpr' and 'ReadStats' must therefore
**  be declared forward.
*/
static void ReadExpr(ReaderState * rs, TypSymbolSet follow, Char mode);

static UInt ReadStats(ReaderState * rs, TypSymbolSet follow);

static void ReadFuncExprAbbrevSingle(ReaderState * rs, TypSymbolSet follow);

static void ReadAtom(ReaderState * rs, TypSymbolSet follow, Char mode);

static void PushGlobalForLoopVariable(ReaderState * rs, UInt var)
{
    if (rs->CurrentGlobalForLoopDepth <
        ARRAY_SIZE(rs->CurrentGlobalForLoopVariables))
        rs->CurrentGlobalForLoopVariables[rs->CurrentGlobalForLoopDepth] = var;
    rs->CurrentGlobalForLoopDepth++;
}

static void PopGlobalForLoopVariable(ReaderState * rs)
{
    GAP_ASSERT(rs->CurrentGlobalForLoopDepth);
    rs->CurrentGlobalForLoopDepth--;
}

static UInt GlobalComesFromEnclosingForLoop(ReaderState * rs, UInt var)
{
    for (UInt i = 0; i < rs->CurrentGlobalForLoopDepth; i++) {
        if (i == ARRAY_SIZE(rs->CurrentGlobalForLoopVariables))
            return 0;
        if (rs->CurrentGlobalForLoopVariables[i] == var)
            return 1;
    }
    return 0;
}

// `Match_` is a thin wrapper around the scanner's Match() function, in which
// we can track the start line of each interpreter "instruction". This
// information is then used for profiling.
static void Match_(ReaderState * rs,
           UInt           symbol,
           const Char *   msg,
           TypSymbolSet   skipto)
{
    if (rs->intr.startLine == 0 && symbol != S_ILLEGAL) {
        rs->intr.startLine = rs->s.SymbolStartLine[0];
    }

    Match(&rs->s, symbol, msg, skipto);
}


// match either a semicolon or a dual semicolon
static void MatchSemicolon(ReaderState * rs, TypSymbolSet skipto)
{
    Match_(rs, rs->s.Symbol == S_DUALSEMICOLON ? S_DUALSEMICOLON : S_SEMICOLON,
          ";", skipto);
}

// Search the plist 'nams' for a string equal to 'value' between and
// including index 'start' and 'end' and return its index; return 0 if not
// found.
static UInt findValueInNams(Obj nams, const Char * val, UInt start, UInt end)
{
    GAP_ASSERT(LEN_PLIST(nams) < MAX_FUNC_LVARS);
    for (UInt i = start; i <= end; i++) {
        if (streq(CONST_CSTR_STRING(ELM_PLIST(nams, i)), val)) {
            return i;
        }
    }
    // not found
    return 0;
}

/****************************************************************************
**
*F * * * * * * * * * * read symbols and call interpreter  * * * * * * * * * *
*/


/* This function reads the options part at the end of a function call
   The syntax is

   <options> := <option> [, <options> ]
   <option>  := <Ident> | '(' <Expr> ')' [ ':=' <Expr> ]

   empty options lists are handled further up
*/
static void ReadFuncCallOption(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt rnam; // record component name
    if (rs->s.Symbol == S_IDENT) {
        rnam = RNamName(rs->s.Value);
        Match_(rs, S_IDENT, "identifier", S_COMMA | follow);
        TRY_IF_NO_ERROR { IntrFuncCallOptionsBeginElmName(&rs->intr, rnam); }
    }
    else if (rs->s.Symbol == S_LPAREN) {
        Match_(rs, S_LPAREN, "(", S_COMMA | follow);
        ReadExpr(rs, follow, 'r');
        Match_(rs, S_RPAREN, ")", S_COMMA | follow);
        TRY_IF_NO_ERROR { IntrFuncCallOptionsBeginElmExpr(&rs->intr); }
    }
    else {
        SyntaxError(&rs->s, "Identifier expected");
    }
    if (rs->s.Symbol == S_ASSIGN) {
        Match_(rs, S_ASSIGN, ":=", S_COMMA | follow);
        ReadExpr(rs, S_COMMA | S_RPAREN | follow, 'r');
        TRY_IF_NO_ERROR { IntrFuncCallOptionsEndElm(&rs->intr); }
    }
    else {
        TRY_IF_NO_ERROR { IntrFuncCallOptionsEndElmEmpty(&rs->intr); }
    }
}

static void ReadFuncCallOptions(ReaderState * rs, TypSymbolSet follow)
{
  volatile UInt nr;
  TRY_IF_NO_ERROR { IntrFuncCallOptionsBegin(&rs->intr); }
  ReadFuncCallOption(rs, follow);
  nr = 1;
  while (rs->s.Symbol == S_COMMA) {
      Match_(rs, S_COMMA, ",", follow);
      ReadFuncCallOption(rs, follow);
      nr++;
    }
  TRY_IF_NO_ERROR {
    IntrFuncCallOptionsEnd(&rs->intr,  nr );
  }
}

static Obj GAPInfo;

static UInt WarnOnUnboundGlobalsRNam;

/****************************************************************************
**
**  type must be one of the following:
**
**  R_LVAR:             local var with id <var>
**  R_HVAR:             high var with id <var>
**  R_DVAR:             debug var with id <var>, at nesting level <nest0>
**  R_GVAR:             global var with id <var>
**  R_ELM_LIST:         list access l[idx], uses <narg>, <level>
**  R_ELMS_LIST:        list access l{indices}, uses <level>
**  R_ELM_POSOBJ:       pos obj access obj![idx]
**  R_ELM_REC_NAME:     record access r.<rnam>
**  R_ELM_REC_EXPR      record access r.(expr)
**  R_ELM_COMOBJ_NAME:  com obj access obj.<rnam>
**  R_ELM_COMOBJ_EXPR:  com obj access obj.(expr)
**  R_FUNCCALL          function call without options & with <narg> arguments
**  R_FUNCCALL_OPTS     function call with options and with <narg> arguments
*/
enum REFTYPE {
    R_INVALID,
    R_LVAR,
    R_HVAR,
    R_DVAR,
    R_GVAR,
    R_ELM_LIST,
    R_ELMS_LIST,
    R_ELM_POSOBJ,
    R_ELM_REC_NAME,
    R_ELM_REC_EXPR,
    R_ELM_COMOBJ_NAME,
    R_ELM_COMOBJ_EXPR,
    R_FUNCCALL,
    R_FUNCCALL_OPTS,
};

typedef struct {
    UInt1 type;
    UInt1 _padding;
    union {
        UInt2 nest0;
        UInt2 level;
    };
    union {
        UInt4 var;
        UInt4 narg;
        UInt4 rnam;
    };
} LHSRef;

GAP_STATIC_ASSERT(sizeof(LHSRef) <= 8, "LHSRef is too big");

/****************************************************************************
**
*/
static UInt EvalRef(ReaderState * rs, const LHSRef ref, Int needExpr)
{
    TRY_IF_NO_ERROR
    {
        switch (ref.type) {
        case R_LVAR:
            IntrRefLVar(&rs->intr, ref.var);
            break;
        case R_HVAR:
            IntrRefHVar(&rs->intr, ref.var);
            break;
        case R_DVAR:
            IntrRefDVar(&rs->intr, ref.var, ref.nest0);
            break;
        case R_GVAR:
            IntrRefGVar(&rs->intr, ref.var);
            break;
        case R_ELM_LIST:
            if (ref.level == 0)
                IntrElmList(&rs->intr, ref.narg);
            else
                IntrElmListLevel(&rs->intr, ref.narg, ref.level);
            return ref.level;
        case R_ELMS_LIST:
            if (ref.level == 0)
                IntrElmsList(&rs->intr);
            else
                IntrElmsListLevel(&rs->intr, ref.level);
            return ref.level + 1;
        case R_ELM_POSOBJ:
            IntrElmPosObj(&rs->intr);
            break;
        case R_ELM_REC_NAME:
            IntrElmRecName(&rs->intr, ref.rnam);
            break;
        case R_ELM_REC_EXPR:
            IntrElmRecExpr(&rs->intr);
            break;
        case R_ELM_COMOBJ_NAME:
            IntrElmComObjName(&rs->intr, ref.rnam);
            break;
        case R_ELM_COMOBJ_EXPR:
            IntrElmComObjExpr(&rs->intr);
            break;
        case R_FUNCCALL:
            IntrFuncCallEnd(&rs->intr, needExpr, 0, ref.narg);
            break;
        case R_FUNCCALL_OPTS:
            IntrFuncCallEnd(&rs->intr, needExpr, 1, ref.narg);
            break;
        case R_INVALID:
        default:
            // This should never be reached
            Panic("Parse error in EvalRef");
        }
    }
    return 0;
}

static void AssignRef(ReaderState * rs, const LHSRef ref)
{
    TRY_IF_NO_ERROR
    {
        switch (ref.type) {
        case R_LVAR:
            IntrAssLVar(&rs->intr, ref.var);
            break;
        case R_HVAR:
            IntrAssHVar(&rs->intr, ref.var);
            break;
        case R_DVAR:
            IntrAssDVar(&rs->intr, ref.var, ref.nest0);
            break;
        case R_GVAR:
            IntrAssGVar(&rs->intr, ref.var);
            break;
        case R_ELM_LIST:
            if (ref.level == 0)
                IntrAssList(&rs->intr, ref.narg);
            else
                IntrAssListLevel(&rs->intr, ref.narg, ref.level);
            break;
        case R_ELMS_LIST:
            if (ref.level == 0)
                IntrAsssList(&rs->intr);
            else
                IntrAsssListLevel(&rs->intr, ref.level);
            break;
        case R_ELM_POSOBJ:
            IntrAssPosObj(&rs->intr);
            break;
        case R_ELM_REC_NAME:
            IntrAssRecName(&rs->intr, ref.rnam);
            break;
        case R_ELM_REC_EXPR:
            IntrAssRecExpr(&rs->intr);
            break;
        case R_ELM_COMOBJ_NAME:
            IntrAssComObjName(&rs->intr, ref.rnam);
            break;
        case R_ELM_COMOBJ_EXPR:
            IntrAssComObjExpr(&rs->intr);
            break;
        case R_INVALID:
        case R_FUNCCALL:
        case R_FUNCCALL_OPTS:
        default:
            // This should never be reached
            Panic("Parse error in AssignRef");
        }
    }
}

static void UnbindRef(ReaderState * rs, const LHSRef ref)
{
    TRY_IF_NO_ERROR
    {
        switch (ref.type) {
        case R_LVAR:
            IntrUnbLVar(&rs->intr, ref.var);
            break;
        case R_HVAR:
            IntrUnbHVar(&rs->intr, ref.var);
            break;
        case R_DVAR:
            IntrUnbDVar(&rs->intr, ref.var, ref.nest0);
            break;
        case R_GVAR:
            IntrUnbGVar(&rs->intr, ref.var);
            break;
        case R_ELM_LIST:
            IntrUnbList(&rs->intr, ref.narg);
            break;
        case R_ELM_POSOBJ:
            IntrUnbPosObj(&rs->intr);
            break;
        case R_ELM_REC_NAME:
            IntrUnbRecName(&rs->intr, ref.rnam);
            break;
        case R_ELM_REC_EXPR:
            IntrUnbRecExpr(&rs->intr);
            break;
        case R_ELM_COMOBJ_NAME:
            IntrUnbComObjName(&rs->intr, ref.rnam);
            break;
        case R_ELM_COMOBJ_EXPR:
            IntrUnbComObjExpr(&rs->intr);
            break;
        case R_INVALID:
        case R_ELMS_LIST:
        case R_FUNCCALL:
        case R_FUNCCALL_OPTS:
        default:
            SyntaxError(&rs->s, "Illegal operand for 'Unbind'");
        }
    }
}

static void IsBoundRef(ReaderState * rs, const LHSRef ref)
{
    TRY_IF_NO_ERROR
    {
        switch (ref.type) {
        case R_LVAR:
            IntrIsbLVar(&rs->intr, ref.var);
            break;
        case R_HVAR:
            IntrIsbHVar(&rs->intr, ref.var);
            break;
        case R_DVAR:
            IntrIsbDVar(&rs->intr, ref.var, ref.nest0);
            break;
        case R_GVAR:
            IntrIsbGVar(&rs->intr, ref.var);
            break;
        case R_ELM_LIST:
            IntrIsbList(&rs->intr, ref.narg);
            break;
        case R_ELM_POSOBJ:
            IntrIsbPosObj(&rs->intr);
            break;
        case R_ELM_REC_NAME:
            IntrIsbRecName(&rs->intr, ref.rnam);
            break;
        case R_ELM_REC_EXPR:
            IntrIsbRecExpr(&rs->intr);
            break;
        case R_ELM_COMOBJ_NAME:
            IntrIsbComObjName(&rs->intr, ref.rnam);
            break;
        case R_ELM_COMOBJ_EXPR:
            IntrIsbComObjExpr(&rs->intr);
            break;
        case R_INVALID:
        case R_ELMS_LIST:
        case R_FUNCCALL:
        case R_FUNCCALL_OPTS:
        default:
            SyntaxError(&rs->s, "Illegal operand for 'IsBound'");
        }
    }
}


/****************************************************************************
**
*/
static LHSRef ReadSelector(ReaderState * rs, TypSymbolSet follow, UInt level)
{
    volatile LHSRef ref;

    ref.type = R_INVALID;

    // <Var> '[' <Expr> ']'  list selector
    if (rs->s.Symbol == S_LBRACK) {
        Match_(rs, S_LBRACK, "[", follow);
        ReadExpr(rs, S_COMMA | S_RBRACK | follow, 'r');
        ref.narg = 1;
        while (rs->s.Symbol == S_COMMA) {
            Match_(rs, S_COMMA, ",", follow | S_RBRACK);
            ReadExpr(rs, S_COMMA | S_RBRACK | follow, 'r');
            ref.narg++;
        }
        if (ref.narg > 2) {
            SyntaxError(&rs->s, "'[]' only supports 1 or 2 indices");
        }
        Match_(rs, S_RBRACK, "]", follow);
        ref.type = R_ELM_LIST;
        ref.level = level;
    }

    // <Var> '{' <Expr> '}'  sublist selector
    else if (rs->s.Symbol == S_LBRACE) {
        Match_(rs, S_LBRACE, "{", follow);
        ReadExpr(rs, S_RBRACE | follow, 'r');
        Match_(rs, S_RBRACE, "}", follow);
        ref.type = R_ELMS_LIST;
        ref.level = level;
    }

    // <Var> '![' <Expr> ']'  list selector
    else if (rs->s.Symbol == S_BLBRACK) {
        Match_(rs, S_BLBRACK, "![", follow);
        ReadExpr(rs, S_RBRACK | follow, 'r');
        Match_(rs, S_RBRACK, "]", follow);
        ref.type = R_ELM_POSOBJ;
    }

    // <Var> '.' <Ident>  record selector
    else if (rs->s.Symbol == S_DOT) {
        Match_(rs, S_DOT, ".", follow);
        if (rs->s.Symbol == S_IDENT || rs->s.Symbol == S_INT) {
            ref.rnam = RNamName(rs->s.Value);
            Match_(rs, rs->s.Symbol, "identifier", follow);
            ref.type = R_ELM_REC_NAME;
        }
        else if (rs->s.Symbol == S_LPAREN) {
            Match_(rs, S_LPAREN, "(", follow);
            ReadExpr(rs, S_RPAREN | follow, 'r');
            Match_(rs, S_RPAREN, ")", follow);
            ref.type = R_ELM_REC_EXPR;
        }
        else {
            SyntaxError(&rs->s, "Record component name expected");
        }
    }

    // <Var> '!.' <Ident>  record selector
    else if (rs->s.Symbol == S_BDOT) {
        Match_(rs, S_BDOT, "!.", follow);
        if (rs->s.Symbol == S_IDENT || rs->s.Symbol == S_INT) {
            ref.rnam = RNamName(rs->s.Value);
            Match_(rs, rs->s.Symbol, "identifier", follow);
            ref.type = R_ELM_COMOBJ_NAME;
        }
        else if (rs->s.Symbol == S_LPAREN) {
            Match_(rs, S_LPAREN, "(", follow);
            ReadExpr(rs, S_RPAREN | follow, 'r');
            Match_(rs, S_RPAREN, ")", follow);
            ref.type = R_ELM_COMOBJ_EXPR;
        }
        else {
            SyntaxError(&rs->s, "Record component name expected");
        }
    }

    // <Var> '(' [ <Expr> { ',' <Expr> } ] ')'  function call
    else if (rs->s.Symbol == S_LPAREN) {
        Match_(rs, S_LPAREN, "(", follow);
        TRY_IF_NO_ERROR
        {
            IntrFuncCallBegin(&rs->intr);
        }
        ref.narg = 0;
        if (rs->s.Symbol != S_RPAREN && rs->s.Symbol != S_COLON) {
            ReadExpr(rs, S_RPAREN | follow, 'r');
            ref.narg++;
        }
        while (rs->s.Symbol == S_COMMA) {
            Match_(rs, S_COMMA, ",", follow);
            ReadExpr(rs, S_RPAREN | follow, 'r');
            ref.narg++;
        }
        ref.type = R_FUNCCALL;
        if (rs->s.Symbol == S_COLON) {
            Match_(rs, S_COLON, ":", follow);
            if (rs->s.Symbol != S_RPAREN) {    // save work for empty options
                ReadFuncCallOptions(rs, S_RPAREN | follow);
                ref.type = R_FUNCCALL_OPTS;
            }
        }
        Match_(rs, S_RPAREN, ")", follow);
    }

    return ref;
}

static void ReadReferenceModifiers(ReaderState * rs, TypSymbolSet follow)
{
    UInt level = 0;

    // read one or more selectors
    while (IS_IN(rs->s.Symbol, S_LPAREN | S_LBRACK | S_LBRACE | S_DOT)) {
        LHSRef ref = ReadSelector(rs, follow, level);
        level = EvalRef(rs, ref, 1);
    }
}

/****************************************************************************
**
*F  ReadVar( <follow>, <mode> )  . . . . . . . . . . . read a variable
**
**  'ReadVar' reads a variable identifier. In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**  <Ident> :=  a|b|..|z|A|B|..|Z { a|b|..|z|A|B|..|Z|0|..|9|_ }
*/
static LHSRef ReadVar(ReaderState * rs, TypSymbolSet follow)
{
    LHSRef ref = { R_INVALID, 0, {0}, {0} };

    Obj  nams;                      // list of names of local vars.
    Obj  lvars;                     // environment
    UInt nest;                      // nesting level of a higher var.
    Obj  lvars0;                    // environment
    UInt nest0;                     // nesting level of a higher var.
    UInt indx;                      // index of a local variable
    Char varname[MAX_VALUE_LEN];    // copy of variable name

    /* all variables must begin with an identifier                         */
    if (rs->s.Symbol != S_IDENT) {
        SyntaxError(&rs->s, "Identifier expected");
        return ref;
    }

    // try to look up the variable on the stack of local variables
    const UInt countNams = LEN_PLIST(rs->StackNams);
    for (nest = 0; nest < countNams; nest++) {
        if (nest >= MAX_FUNC_EXPR_NESTING) {
            Pr("Warning: abandoning search for %s at %dth higher frame\n",
               (Int)rs->s.Value, MAX_FUNC_EXPR_NESTING);
            break;
        }
        nams = ELM_PLIST(rs->StackNams, countNams - nest);
        indx = findValueInNams(nams, rs->s.Value, 1, LEN_PLIST(nams));
        if (indx != 0) {
            ref.type = (nest == 0) ? R_LVAR : R_HVAR;
            ref.var = (nest << MAX_FUNC_LVARS_BITS) + indx;
            break;
        }
    }

    // try to look up the variable on the error stack;
    // the outer loop runs up the calling stack, while the inner loop runs
    // up the static definition stack for each call function
    lvars0 = STATE(ErrorLVars);
    nest0 = 0;
    while (ref.type == R_INVALID && lvars0 != 0 && !IsBottomLVars(lvars0)) {
        lvars = lvars0;
        nest = 0;
        while (ref.type == R_INVALID && lvars != 0 && !IsBottomLVars(lvars)) {
            nams = NAMS_FUNC(FUNC_LVARS(lvars));
            if (nams != 0) {
                indx = findValueInNams(nams, rs->s.Value, 1, LEN_PLIST(nams));
                if (indx) {
                    ref.type = R_DVAR;
                    ref.var = (nest << MAX_FUNC_LVARS_BITS) + indx;
                    ref.nest0 = nest0;
                    break;
                }
            }
            lvars = ENVI_FUNC(FUNC_LVARS(lvars));
            nest++;
            if (nest >= MAX_FUNC_EXPR_NESTING) {
                Pr("Warning: abandoning search for %s at %dth higher "
                   "frame\n",
                   (Int)rs->s.Value, MAX_FUNC_EXPR_NESTING);
                break;
            }
        }
        lvars0 = PARENT_LVARS(lvars0);
        nest0++;
    }

    // get the variable as a global variable
    if (ref.type == R_INVALID) {
        ref.type = R_GVAR;
        // we do not want to call GVarName on this value until after we
        // have checked if this is the argument to a lambda function
        gap_strlcpy(varname, rs->s.Value, sizeof(varname));
    }

    // match away the identifier, now that we know the variable
    Match_(rs, S_IDENT, "identifier", follow);

    // If this isn't a lambda function, look up the name
    if (rs->s.Symbol != S_MAPTO && ref.type == R_GVAR) {
        ref.var = GVarName(varname);
    }

    return ref;
}

// Helper function to be called after `ReadVar`, before any further tokens
// have been consumed via calls to `Match`.
static void CheckUnboundGlobal(ReaderState * rs, LHSRef ref)
{
    // only warn if we are accessing a global variable
    if (ref.type != R_GVAR)
        return;

    // only warn if inside a function
    if (LEN_PLIST(rs->StackNams) == 0)
        return;

    // allow use in left hand side (LHS) of an assignment
    if (ref.var == rs->CurrLHSGVar)
        return;

    // only warn if the global variable does not exist ...
    if (ValGVar(ref.var) != 0)
        return;

    // ... and isn't an auto var ...
    if (ExprGVar(ref.var) != 0)
        return;

    // ... and was not "declared" via DeclareGlobalName
    if (IsDeclaredGVar(ref.var))
        return;

    // don't warn if we are skipping/ignoring code
    if (rs->intr.ignoring)
        return;

    // if the global was used as loop variable in an enclosing for loop, that
    // means it will be assigned before execution gets here, so don't warn.
    if (GlobalComesFromEnclosingForLoop(rs, ref.var))
        return;

    // check if the user disabled this warning
    if (WarnOnUnboundGlobalsRNam == 0)
        WarnOnUnboundGlobalsRNam = RNamName("WarnOnUnboundGlobals");
    if (GAPInfo && IS_REC(GAPInfo) &&
        ISB_REC(GAPInfo, WarnOnUnboundGlobalsRNam) &&
        ELM_REC(GAPInfo, WarnOnUnboundGlobalsRNam) == False)
        return;

    // don't warn if we are compiling code
    if (SyCompilePlease)
        return;

    // Need to pass an offset, because we have already parsed more tokens
    SyntaxWarningWithOffset(&rs->s, "Unbound global variable", 2);
}

/****************************************************************************
**
*F  ReadCallVarAss( <follow>, <mode> )  . . . . . . . . . . . read a variable
**
**  'ReadCallVarAss' reads  a variable.  In  case  of an  error it skips  all
**  symbols up to one contained in  <follow>.  The <mode>  must be one of the
**  following:
**
**  'i':        check if variable, record component, list entry is bound
**  'r':        reference to a variable
**  's':        assignment via ':='
**  'u':        unbind a variable
**  'x':        either 'r' or 's' depending on <Symbol>
**
**  <Ident> :=  a|b|..|z|A|B|..|Z { a|b|..|z|A|B|..|Z|0|..|9|_ }
**
**  <Var> := <Ident>
**        |  <Var> '[' <Expr> [,<Expr>]* ']'
**        |  <Var> '{' <Expr> '}'
**        |  <Var> '.' <Ident>
**        |  <Var> '(' [ <Expr> { ',' <Expr> } ] [':' [ <options> ]] ')'
*/
static void ReadCallVarAss(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    volatile LHSRef ref = ReadVar(rs, follow);
    if (ref.type == R_INVALID)
        return;

    // if this was actually the beginning of a function literal, then we are
    // in the wrong function
    if (rs->s.Symbol == S_MAPTO) {
        if (mode == 'r' || mode == 'x')
            ReadFuncExprAbbrevSingle(rs, follow);
        else
            SyntaxError(&rs->s, "Function literal in impossible context");
        return;
    }

    // Check if the variable is a constant
    if (ref.type == R_GVAR && IsConstantGVar(ref.var) && ValGVar(ref.var)) {
        // deal with references
        if (mode == 'r' || (mode == 'x' && rs->s.Symbol != S_ASSIGN)) {
            Obj val = ValAutoGVar(ref.var);
            TRY_IF_NO_ERROR {
                if (val == True) {
                    IntrTrueExpr(&rs->intr);
                    return;
                }
                else if (val == False) {
                    IntrFalseExpr(&rs->intr);
                    return;
                }
                else if (IS_INTOBJ(val)) {
                    IntrIntObjExpr(&rs->intr, val);
                    return;
                }
            }
        }
    }


    /* check whether this is an unbound global variable                    */
    if (mode != 'i')    // Not inside 'IsBound'
        CheckUnboundGlobal(rs, ref);

    /* followed by one or more selectors                                   */
    while (IS_IN(rs->s.Symbol, S_LPAREN | S_LBRACK | S_LBRACE | S_DOT)) {

        /* so the prefix was a reference                                   */
        UInt level = EvalRef(rs, ref, 1);
        ref = ReadSelector(rs, follow, level);
    }

    /* if we need a reference                                              */
    if (mode == 'r' || (mode == 'x' && rs->s.Symbol != S_ASSIGN)) {
        Int needExpr = mode == 'r' || !IS_IN(rs->s.Symbol, S_SEMICOLON);
        EvalRef(rs, ref, needExpr);
    }

    /* if we need a statement                                              */
    else if (mode == 's' || (mode == 'x' && rs->s.Symbol == S_ASSIGN)) {
        if (ref.type == R_FUNCCALL || ref.type == R_FUNCCALL_OPTS) {
            TRY_IF_NO_ERROR {
                IntrFuncCallEnd(&rs->intr, 0, ref.type == R_FUNCCALL_OPTS, ref.narg);
            }
        }
        else {
            Match_(rs, S_ASSIGN, "found an expression when a statement was", follow);
            UInt currLHSGVar = rs->CurrLHSGVar;
            if ( LEN_PLIST(rs->StackNams) == 0 || !rs->intr.coding ) {
                rs->CurrLHSGVar = (ref.type == R_GVAR ? ref.var : 0);
            }
            ReadExpr(rs, follow, 'r');
            AssignRef(rs, ref);
            rs->CurrLHSGVar = currLHSGVar;
        }
    }

    /*  if we need an unbind                                               */
    else if ( mode == 'u' ) {
        if (rs->s.Symbol != S_RPAREN) {
            SyntaxError(&rs->s, "'Unbind': argument should be followed by ')'");
        }
        UnbindRef(rs, ref);
    }


    /* if we need an isbound                                               */
    else /* if ( mode == 'i' ) */ {
        IsBoundRef(rs, ref);
    }

}


/****************************************************************************
**
*F  ReadIsBound( <follow> ) . . . . . . . . . . .  read an isbound expression
**
**  'ReadIsBound' reads an isbound expression.  In  case of an error it skips
**  all symbols up to one contained in <follow>.
**
**  <Atom> := 'IsBound' '(' <Var> ')'
*/
static void ReadIsBound(ReaderState * rs, TypSymbolSet follow)
{
    Match_(rs, S_ISBOUND, "IsBound", follow);
    Match_(rs, S_LPAREN, "(", follow);
    ReadCallVarAss(rs, S_RPAREN|follow, 'i');
    Match_(rs, S_RPAREN, ")", follow);
}


/****************************************************************************
**
*F  ReadPerm( <follow> )  . . . . . . . . . . . . . . . .  read a permutation
**
**  'ReadPerm' reads a permutation.  In case of an error it skips all symbols
**  up to one contained in <follow>.
**
**  Note that the first expression has already been read.  The reason is that
**  until the first  expression has been  read and a  comma is found it could
**  also be a parenthesized expression.
**
**  <Perm> :=  ( <Expr> {, <Expr>} ) { ( <Expr> {, <Expr>} ) }
**
*/
static void ReadPerm(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt       nrc;            /* number of cycles                */
    volatile UInt       nrx;            /* number of expressions in cycle  */

    /* read the first cycle (first expression has already been read)       */
    nrx = 1;
    while (rs->s.Symbol == S_COMMA) {
        Match_(rs, S_COMMA, ",", follow);
        ReadExpr(rs, S_COMMA|S_RPAREN|follow, 'r');
        nrx++;
    }
    Match_(rs, S_RPAREN, ")", follow);
    nrc = 1;
    TRY_IF_NO_ERROR { IntrPermCycle(&rs->intr,  nrx, nrc ); }

    /* read the remaining cycles                                           */
    while (rs->s.Symbol == S_LPAREN) {
        Match_(rs, S_LPAREN, "(", follow);
        ReadExpr(rs, S_COMMA|S_RPAREN|follow, 'r');
        nrx = 1;
        while (rs->s.Symbol == S_COMMA) {
            Match_(rs, S_COMMA, ",", follow);
            ReadExpr(rs, S_COMMA|S_RPAREN|follow, 'r');
            nrx++;
        }
        Match_(rs, S_RPAREN, ")", follow);
        nrc++;
        TRY_IF_NO_ERROR { IntrPermCycle(&rs->intr,  nrx, nrc ); }
    }

    /* that was the permutation                                            */
    TRY_IF_NO_ERROR { IntrPerm(&rs->intr,  nrc ); }
}

/****************************************************************************
**
*F  ReadListExpr( <follow> )  . . . . . . . . . . . . . . . . . . read a list
**
**  'ReadListExpr'  reads a list literal expression.   In case of an error it
**  skips all symbols up to one contained in <follow>.
**
**  <List> := '[' [ <Expr> ] {',' [ <Expr> ] } ']'
**         |  '[' <Expr> [',' <Expr>] '..' <Expr> ']'
*/
static void ReadListExpr(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt       pos;            /* actual position of element      */
    volatile UInt       nr;             /* number of elements              */
    volatile UInt       range;          /* is the list expression a range  */

    /* '['                                                                 */
    Match_(rs, S_LBRACK, "[", follow);
    rs->ReadTop++;
    if (rs->ReadTop == 1) {
        rs->ReadTilde = 0;
        STATE(Tilde) = 0;
    }
    TRY_IF_NO_ERROR { IntrListExprBegin(&rs->intr,  (rs->ReadTop == 1) ); }
    pos   = 1;
    nr    = 0;
    range = 0;

    /* [ <Expr> ]                                                          */
    if (rs->s.Symbol != S_COMMA && rs->s.Symbol != S_RBRACK) {
        TRY_IF_NO_ERROR { IntrListExprBeginElm(&rs->intr,  pos ); }
        ReadExpr(rs, S_RBRACK|follow, 'r');
        TRY_IF_NO_ERROR { IntrListExprEndElm(&rs->intr); }
        nr++;
    }

    /* {',' [ <Expr> ] }                                                   */
    while (rs->s.Symbol == S_COMMA) {
        Match_(rs, S_COMMA, ",", follow);
        pos++;
        if (rs->s.Symbol != S_COMMA && rs->s.Symbol != S_RBRACK) {
            TRY_IF_NO_ERROR { IntrListExprBeginElm(&rs->intr,  pos ); }
            ReadExpr(rs, S_RBRACK|follow, 'r');
            TRY_IF_NO_ERROR { IntrListExprEndElm(&rs->intr); }
            nr++;
        }
    }

    /* incorrect place for three dots                                      */
    if (rs->s.Symbol == S_DOTDOTDOT) {
        SyntaxError(&rs->s, "Only two dots in a range");
    }

    /* '..' <Expr> ']'                                                     */
    if (rs->s.Symbol == S_DOTDOT) {
        if ( pos != nr ) {
            SyntaxError(&rs->s, "Must have no unbound entries in range");
        }
        if ( 2 < nr ) {
            SyntaxError(&rs->s, "Must have at most 2 entries before '..'");
        }
        range = 1;
        Match_(rs, S_DOTDOT, "..", follow);
        pos++;
        TRY_IF_NO_ERROR { IntrListExprBeginElm(&rs->intr,  pos ); }
        ReadExpr(rs, S_RBRACK|follow, 'r');
        TRY_IF_NO_ERROR { IntrListExprEndElm(&rs->intr); }
        nr++;
        if (rs->ReadTop == 1 && rs->ReadTilde == 1) {
            SyntaxError(&rs->s, "Sorry, '~' not allowed in range");
        }
    }

    /* ']'                                                                 */
    Match_(rs, S_RBRACK, "]", follow);
    TRY_IF_NO_ERROR {
        IntrListExprEnd(&rs->intr,  nr, range, (rs->ReadTop == 1), (rs->ReadTilde == 1) );
    }
    if (rs->ReadTop == 1) {
        rs->ReadTilde = 0;
        STATE(Tilde) = 0;
    }
    rs->ReadTop--;
}


/****************************************************************************
**
*F  ReadRecExpr( <follow> ) . . . . . . . . . . . . . . . . . . read a record
**
**  'ReadRecExpr' reads a record literal expression.  In  case of an error it
**  skips all symbols up to one contained in <follow>.
**
**  <Record> := 'rec( [ <Ident>:=<Expr> {, <Ident>:=<Expr> } ] )'
*/
static void ReadRecExpr(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt       rnam;           /* record component name           */
    volatile UInt       nr;             /* number of components            */

    /* 'rec('                                                              */
    Match_(rs, S_REC, "rec", follow);
    Match_(rs, S_LPAREN, "(", follow|S_RPAREN|S_COMMA);
    rs->ReadTop++;
    if ( rs->ReadTop == 1 ) {
        rs->ReadTilde = 0;
        STATE(Tilde) = 0;
    }
    TRY_IF_NO_ERROR { IntrRecExprBegin(&rs->intr,  (rs->ReadTop == 1) ); }
    nr = 0;

    /* [ <Ident> | '(' <Expr> ')' ':=' <Expr>                              */
    do {
      if (nr || rs->s.Symbol == S_COMMA) {
        Match_(rs, S_COMMA, ",", follow);
      }
      if ( rs->s.Symbol != S_RPAREN ) {
        if ( rs->s.Symbol == S_INT ) {
          rnam = RNamName( rs->s.Value );
          Match_(rs, S_INT, "integer", follow);
          TRY_IF_NO_ERROR { IntrRecExprBeginElmName(&rs->intr,  rnam ); }
        }
        else if ( rs->s.Symbol == S_IDENT ) {
          rnam = RNamName( rs->s.Value );
          Match_(rs, S_IDENT, "identifier", follow);
          TRY_IF_NO_ERROR { IntrRecExprBeginElmName(&rs->intr,  rnam ); }
        }
        else if ( rs->s.Symbol == S_LPAREN ) {
          Match_(rs, S_LPAREN, "(", follow);
          ReadExpr(rs, follow, 'r');
          Match_(rs, S_RPAREN, ")", follow);
          TRY_IF_NO_ERROR { IntrRecExprBeginElmExpr(&rs->intr); }
        }
        else {
          SyntaxError(&rs->s, "Identifier expected");
        }
        Match_(rs, S_ASSIGN, ":=", follow);
        ReadExpr(rs, S_RPAREN|follow, 'r');
        TRY_IF_NO_ERROR { IntrRecExprEndElm(&rs->intr); }
        nr++;
      }

    } while (rs->s.Symbol == S_COMMA);

    /* ')'                                                                 */
    Match_(rs, S_RPAREN, ")", follow);
    TRY_IF_NO_ERROR {
        IntrRecExprEnd(&rs->intr,  nr, (rs->ReadTop == 1), (rs->ReadTilde == 1) );
    }
    if (rs->ReadTop == 1) {
        rs->ReadTilde = 0;
        STATE(Tilde) = 0;
    }
    rs->ReadTop--;
}

/****************************************************************************
**
**  ArgList represents the return value of ReadFuncArgList
*/
typedef struct {
    Int        narg;           /* number of arguments             */
    Obj        nams;           /* list of local variables names   */
    BOOL       isvarg;         /* does function have varargs?     */
#ifdef HPCGAP
    Obj        locks;          /* locks of the function (HPC-GAP) */
#endif
} ArgList;

/****************************************************************************
**
*F  ReadFuncArgList(<follow>, <is_atomic>, <symbol>, <symbolstr>)
**  . . . . . . . . . .  read a function argument list.
**
**  'ReadFuncArgList' reads the argument list of a function. In case of an
**  error it skips all symbols up to one contained in <follow>.
**
**  <ArgList> :=    ('readwrite'|'readonly') <Ident>
**                   {',' ('readwrite'|'readonly') <Ident> } ( '...' )
**
**  is_atomic: Is this an atomic function?
**  symbol: The end symbol of the arglist (usually S_RPAREN, but S_RBRACE
**          for lambda functions).
**  symbolstr: symbol as an ascii string
**
**  This function assumes the opening parenthesis or brace is already read,
**  and is responsible for reading the closing parenthesis or brace.
*/

static ArgList ReadFuncArgList(ReaderState * rs,
                               TypSymbolSet   follow,
                               Int            is_atomic,
                               UInt           symbol,
                               const Char *   symbolstr)
{
    Int        narg;           /* number of arguments             */
    Obj        nams;           /* list of local variables names   */
#ifdef HPCGAP
    LockQual   lockqual;
    Bag        locks = 0;      /* locks of the function */
#endif
    BOOL       isvarg = FALSE; // does function have varargs?

#ifdef HPCGAP
    if (is_atomic)
        locks = NEW_STRING(4);
#endif

    /* make and push the new local variables list (args and locals)        */
    narg = 0;
    nams = NEW_PLIST(T_PLIST, 0);
    if (rs->s.Symbol != symbol) {
        goto start;
    }

    while (rs->s.Symbol == S_COMMA) {
        if (isvarg) {
            SyntaxError(&rs->s, "Only final argument can be variadic");
        }

        Match_(rs, S_COMMA, ",", follow);
    start:
#ifdef HPCGAP
        lockqual = LOCK_QUAL_NONE;
#endif
        if (rs->s.Symbol == S_READWRITE) {
            if (!is_atomic) {
                SyntaxError(&rs->s, "'readwrite' argument of non-atomic function");
            }
#ifdef HPCGAP
            else {
                lockqual = LOCK_QUAL_READWRITE;
            }
#endif
            Match_(rs, S_READWRITE, "readwrite", follow);
        }
        else if (rs->s.Symbol == S_READONLY) {
            if (!is_atomic) {
                SyntaxError(&rs->s, "'readonly' argument of non-atomic function");
            }
#ifdef HPCGAP
            else {
                lockqual = LOCK_QUAL_READONLY;
            }
#endif
            Match_(rs, S_READONLY, "readonly", follow);
        }
        if (rs->s.Symbol == S_IDENT && findValueInNams(nams, rs->s.Value, 1, narg)) {
            SyntaxError(&rs->s, "Name used for two arguments");
        }
        narg += 1;
        PushPlist(nams, MakeImmString(rs->s.Value));
#ifdef HPCGAP
        if (is_atomic) {
            GrowString(locks, narg);
            SET_LEN_STRING(locks, narg);
            CHARS_STRING(locks)[narg - 1] = lockqual;
        }
#endif
        if (LEN_PLIST(nams) >= MAX_FUNC_LVARS) {
            SyntaxError(&rs->s, "Too many function arguments");
        }
        Match_(rs, S_IDENT,"identifier",symbol|S_LOCAL|STATBEGIN|S_END|follow);
        if (rs->s.Symbol == S_DOTDOT) {
            SyntaxError(&rs->s, "Three dots required for variadic argument list");
        }
        if (rs->s.Symbol == S_DOTDOTDOT) {
            isvarg = TRUE;
            Match_(rs, S_DOTDOTDOT, "...", follow);
        }
    }
    Match_(rs, symbol, symbolstr, S_LOCAL|STATBEGIN|S_END|follow);

    // Special case for function(arg)
    if (narg == 1 && streq("arg", CONST_CSTR_STRING(ELM_PLIST(nams, narg)))) {
        isvarg = TRUE;
    }

    ArgList args;
    args.narg = narg;
    args.nams = nams;
    args.isvarg = isvarg;
#ifdef HPCGAP
    args.locks = locks;
    if (locks)
        MakeImmutable(args.locks);
#endif
    return args;
}


static void ReadFuncExprBody(ReaderState * rs,
                             TypSymbolSet   follow,
                             Int            isAbbrev,
                             Int            nloc,
                             ArgList        args,
                             Int            startLine)
{
    volatile UInt nr;           // number of statements

    // push the new local variables list
    PushPlist(rs->StackNams, args.nams);

    // begin interpreting the function expression
    TRY_IF_NO_ERROR {
        IntrFuncExprBegin(&rs->intr, args.isvarg ? -args.narg : args.narg, nloc,
                          args.nams, startLine);
    }

    if (isAbbrev) {
        // read the expression and turn it into a return-statement
        ReadExpr(rs, follow, 'r');
        TRY_IF_NO_ERROR {
            IntrReturnObj(&rs->intr);
        }
        nr = 1;
    }
    else {
#ifdef HPCGAP
        if (rs->s.NrError == 0)
            SET_LCKS_FUNC(CURR_FUNC(), args.locks);
#endif
        // <Statements>
        UInt oldLoopNesting = rs->LoopNesting;
        rs->LoopNesting = 0;
        nr = ReadStats(rs, S_END | follow);
        rs->LoopNesting = oldLoopNesting;
    }


    // end interpreting the function expression
    TRY_IF_NO_ERROR {
        IntrFuncExprEnd(&rs->intr, nr);
    }

    // pop the new local variables list
    PopPlist(rs->StackNams);
}


/****************************************************************************
**
*F  ReadLocals( <follow> )
*/
static UInt ReadLocals(ReaderState * rs, TypSymbolSet follow, Obj nams)
{
    UInt narg = LEN_PLIST(nams);
    UInt nloc = 0;

    Match_(rs, S_LOCAL, "local", follow);

    while (1) {
        if (rs->s.Symbol == S_IDENT) {
            if (findValueInNams(nams, rs->s.Value, narg + 1, narg + nloc)) {
                SyntaxError(&rs->s, "Name used for two locals");
            }
            if (findValueInNams(nams, rs->s.Value, 1, narg)) {
                SyntaxError(&rs->s, "Name used for argument and local");
            }
            nloc += 1;
            PushPlist(nams, MakeImmString(rs->s.Value));
            if (LEN_PLIST(nams) >= MAX_FUNC_LVARS) {
                SyntaxError(&rs->s, "Too many function arguments and locals");
            }
        }
        Match_(rs, S_IDENT, "identifier", STATBEGIN | S_END | follow);

        if (rs->s.Symbol != S_COMMA)
            break;

        // init to avoid strange message in case of empty string
        rs->s.Value[0] = '\0';
        Match_(rs, S_COMMA, ",", follow);
    }
    MatchSemicolon(rs, STATBEGIN | S_END | follow);

    return nloc;
}

/****************************************************************************
**
*F  ReadFuncExpr( <follow> )  . . . . . . . . . .  read a function definition
**
**  'ReadFuncExpr' reads a function literal expression.  In  case of an error
**  it skips all symbols up to one contained in <follow>.
**
**  <Function> := 'function (' <ArgList> ')'
**                             [ 'local'  <Ident> {',' <Ident>} ';' ]
**                             <Statements>
**                'end'
*/
static void ReadFuncExpr(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    Int     startLine;        // line number of function keyword
    int     is_atomic = 0;    // is this an atomic function?
    UInt    nloc = 0;         // number of locals
    ArgList args;

    /* begin the function               */
    startLine = GetInputLineNumber(rs->s.input);
    if (rs->s.Symbol == S_ATOMIC) {
        Match_(rs, S_ATOMIC, "atomic", follow);
        is_atomic = 1;
    } else if (mode == 'a') {
        // in this case the atomic keyword was matched away by ReadAtomic
        // before we realised we were reading an atomic function
        is_atomic = 1;
    }
    Match_(rs, S_FUNCTION, "function", follow);
    Match_(rs, S_LPAREN, "(", S_IDENT|S_RPAREN|S_LOCAL|STATBEGIN|S_END|follow);

    args = ReadFuncArgList(rs, follow, is_atomic, S_RPAREN, ")");

    if (rs->s.Symbol == S_LOCAL) {
        nloc = ReadLocals(rs, follow, args.nams);
    }

    ReadFuncExprBody(rs, follow, 0, nloc, args, startLine);

    /* 'end'                                                               */
    Match_(rs, S_END, "while parsing a function: statement or 'end'", follow);
}


/****************************************************************************
**
*F  ReadFuncExprAbbrevMulti(<follow>) . .  read multi-arg abbrev. func. expr.
**
**  'ReadFuncExprAbbrevMulti' reads a multi-argument abbreviated function
**  literal expression. In case of an error it skips all symbols up to one
**  contained in <follow>.
**
**      <Function>      := '{' <ArgList> '}' '->' <Expr>
*/
static void ReadFuncExprAbbrevMulti(ReaderState * rs, TypSymbolSet follow)
{
    Match_(rs, S_LBRACE, "{", follow);

    ArgList args = ReadFuncArgList(rs, follow, 0, S_RBRACE, "}");

    /* match away the '->'                                                 */
    Match_(rs, S_MAPTO, "->", follow);

    ReadFuncExprBody(rs, follow, 1, 0, args, GetInputLineNumber(rs->s.input));
}

/****************************************************************************
**
*F  ReadFuncExprAbbrevSingle(<follow>) .  read single-arg abbrev. func. expr.
**
**  'ReadFuncExprAbbrevSingle' reads a single-argument abbreviated function
**  literal expression. In case of an error it skips all symbols up to one
**  contained in <follow>.
**
**      <Function>      := <Var> '->' <Expr>
*/
static void ReadFuncExprAbbrevSingle(ReaderState * rs, TypSymbolSet follow)
{
    /* make and push the new local variables list                          */
    Obj nams = NEW_PLIST(T_PLIST, 1);
    PushPlist(nams, MakeImmString(rs->s.Value));

    ArgList args;
    args.narg = 1;
    args.nams = nams;
    args.isvarg = FALSE;
#ifdef HPCGAP
    args.locks = 0;
#endif

    /* match away the '->'                                                 */
    Match_(rs, S_MAPTO, "->", follow);

    ReadFuncExprBody(rs, follow, 1, 0, args, GetInputLineNumber(rs->s.input));
}

/****************************************************************************
**
*F  ReadLiteral( <follow>, <mode> ) . . . . . . . . . . . . . .  read an atom
**
**  'ReadLiteral' reads a  literal expression.  In  case of an error it skips
**  all symbols up to one contained in <follow>.
**
**  <Literal> := <Int>
**            |  <Float>
**            |  'true'
**            |  'false'
**            |  '~'
**            |  <Char>
**            |  <Perm>
**            |  <String>
**            |  <List>
**            |  <Record>
**            |  <Function>
**
**  <Int>     := 0|1|..|9 { 0|1|..|9 }
**
**  <Char>    := ' <any character> '
**
**  <String>  := " { <any character> } "
*/
static void ReadLiteral(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    if (rs->s.Symbol == S_DOT) {
        // HACK: The only way a dot could turn up here is in a floating point
        // literal that starts with '.'. Call back to the scanner to deal
        // with this.
        ScanForFloatAfterDotHACK(&rs->s);
    }

    switch (rs->s.Symbol) {

    /* <Int>                                                               */
    case S_INT:
        TRY_IF_NO_ERROR { IntrIntExpr(&rs->intr, rs->s.ValueObj, rs->s.Value); }
        Match_(rs, S_INT, "integer", follow);
        break;

    /* <Float> */
    case S_FLOAT:
        TRY_IF_NO_ERROR { IntrFloatExpr(&rs->intr, rs->s.ValueObj, rs->s.Value); }
        Match_(rs, S_FLOAT, "float", follow);
        break;

    /* 'true'                                                              */
    case S_TRUE:
        Match_(rs, S_TRUE, "true", follow);
        IntrTrueExpr(&rs->intr);
        break;

    /* 'false'                                                             */
    case S_FALSE:
        Match_(rs, S_FALSE, "false", follow);
        IntrFalseExpr(&rs->intr);
        break;

    /* '~'                                                                 */
    case S_TILDE:
        if (rs->ReadTop == 0) {
            SyntaxError(&rs->s, "'~' not allowed here");
        }
        rs->ReadTilde = 1;
        TRY_IF_NO_ERROR { IntrTildeExpr(&rs->intr); }
        Match_(rs, S_TILDE, "~", follow);
        break;

    /* <Char>                                                              */
    case S_CHAR:
        TRY_IF_NO_ERROR { IntrCharExpr(&rs->intr,  rs->s.Value[0] ); }
        Match_(rs, S_CHAR, "character", follow);
        break;

    /* <String>                                                            */
    case S_STRING:
        GAP_ASSERT(rs->s.ValueObj != 0);
        TRY_IF_NO_ERROR { IntrStringExpr(&rs->intr, rs->s.ValueObj); }
        Match_(rs, S_STRING, "", follow);
        rs->s.ValueObj = 0;
        break;

    /* <List>                                                              */
    case S_LBRACK:
        ReadListExpr(rs, follow);
        break;

    /* <Record>                                                            */
    case S_REC:
        ReadRecExpr(rs, follow);
        break;

    /* <Function>                                                          */
    case S_FUNCTION:
    case S_ATOMIC:
        ReadFuncExpr(rs, follow, mode);
        break;

    case S_LBRACE:
        ReadFuncExprAbbrevMulti(rs, follow);
        break;

    /* signal an error, we want to see a literal                           */
    default:
        Match_(rs, S_INT, "literal", follow);
    }
}


/****************************************************************************
**
*F  ReadAtom( <follow>, <mode> )  . . . . . . . . . . . . . . .  read an atom
**
**  'ReadAtom' reads an atom. In case of an error it skips all symbols up to
**  one contained in <follow>.
**
**   <Atom> := <Var>
**          |  'IsBound' '(' <Var> ')'
**          |  <Literal>
**          |  '(' <Expr> ')'
*/
static const UInt LiteralExprStateMask =
                          S_INT|S_TRUE|S_FALSE|S_CHAR|S_STRING|S_LBRACK|
                          S_TILDE|S_REC|S_FUNCTION|
                          S_ATOMIC|S_FLOAT|S_DOT|S_MAPTO;

static void ReadAtom(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    /* read a variable                                                     */
    if (rs->s.Symbol == S_IDENT) {
        ReadCallVarAss(rs, follow, mode);
    }

    /* 'IsBound' '(' <Var> ')'                                             */
    else if (rs->s.Symbol == S_ISBOUND) {
        ReadIsBound(rs, follow);
    }
    /* otherwise read a literal expression                                 */
    else if (IS_IN(rs->s.Symbol, LiteralExprStateMask)) {
        ReadLiteral(rs, follow, mode);
    }

    /* '(' <Expr> ')'                                                      */
    else if (rs->s.Symbol == S_LPAREN) {
        Match_(rs, S_LPAREN, "(", follow);
        if (rs->s.Symbol == S_RPAREN) {
            Match_(rs, S_RPAREN, ")", follow);
            TRY_IF_NO_ERROR { IntrPerm(&rs->intr, 0); }
            return;
        }
        ReadExpr(rs, S_RPAREN|follow, 'r');
        if (rs->s.Symbol == S_COMMA) {
            ReadPerm(rs, follow);
            return;
        }
        Match_(rs, S_RPAREN, ")", follow);
    }

    /* otherwise signal an error                                           */
    else {
        Match_(rs, S_INT, "expression", follow);
    }

    ReadReferenceModifiers(rs, follow);
}

/****************************************************************************
**
*F  ReadSign( <follow> )  . . . . . . . . . . . . . . read a sign, or nothing
*/
static Int ReadSign(ReaderState * rs, TypSymbolSet follow)
{
    if (rs->s.Symbol == S_PLUS) {
        Match_(rs, S_PLUS, "unary +", follow);
        return +1;
    }
    if (rs->s.Symbol == S_MINUS) {
        Match_(rs, S_MINUS, "unary -", follow);
        return -1;
    }
    return 0;
}

/****************************************************************************
**
*F  ReadFactor( <follow>, <mode> )  . . . . . . . . . . . . . . read a factor
**
**  'ReadFactor' reads a factor.  In case of an error it skips all symbols up
**  to one contained in <follow>.
**
**  <Factor> := {'+'|'-'} <Atom> [ '^' {'+'|'-'} <Atom> ]
*/
static void ReadFactor(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    volatile Int        sign1;
    volatile Int        sign2;

    /* { '+'|'-' }  leading sign                                           */
    sign1 = ReadSign(rs, follow);

    /* <Atom>                                                              */
    ReadAtom(rs, follow, (sign1 == 0 ? mode : 'r'));

    /* ['^' <Atom> ] implemented as {'^' <Atom> } for better error message */
    while (rs->s.Symbol == S_POW) {

        /* match the '^' away                                              */
        Match_(rs, S_POW, "^", follow);

        /* { '+'|'-' }  leading sign                                       */
        sign2 = ReadSign(rs, follow);

        /* ['^' <Atom>]                                                    */
        ReadAtom(rs, follow, 'r');

        /* interpret the unary minus                                       */
        if ( sign2 == -1 ) {
            TRY_IF_NO_ERROR { IntrAInv(&rs->intr); }
        }

        /* interpret the power                                             */
        TRY_IF_NO_ERROR { IntrPow(&rs->intr); }

        /* check for multiple '^'                                          */
        if (rs->s.Symbol == S_POW) {
            SyntaxError(&rs->s, "'^' is not associative");
        }
    }

    /* interpret the unary minus                                           */
    if ( sign1 == -1 ) {
        TRY_IF_NO_ERROR { IntrAInv(&rs->intr); }
    }
}


/****************************************************************************
**
*F  ReadTerm( <follow>, <mode> )  . . . . . . . . . . . . . . . . read a term
**
**  'ReadTerm' reads a term.  In case of an error it  skips all symbols up to
**  one contained in <follow>.
**
**  <Term> := <Factor> { '*'|'/'|'mod' <Factor> }
*/
static void ReadTerm(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    volatile UInt       symbol;

    /* <Factor>                                                            */
    ReadFactor(rs, follow, mode);

    /* { '*'|'/'|'mod' <Factor> }                                          */
    /* do not use 'IS_IN', since 'IS_IN(S_POW,S_MULT|S_DIV|S_MOD)' is true */
    while (rs->s.Symbol == S_MULT ||
           rs->s.Symbol == S_DIV || rs->s.Symbol == S_MOD) {
        symbol = rs->s.Symbol;
        Match_(rs, rs->s.Symbol, "*, /, or mod", follow);
        ReadFactor(rs, follow, 'r');
        TRY_IF_NO_ERROR {
            if      ( symbol == S_MULT ) { IntrProd(&rs->intr); }
            else if ( symbol == S_DIV  ) { IntrQuo(&rs->intr);  }
            else if ( symbol == S_MOD  ) { IntrMod(&rs->intr);  }
        }
    }
}


/****************************************************************************
**
*F  ReadAri( <follow>, <mode> ) . . . . . . . . read an arithmetic expression
**
**  'ReadAri' reads an  arithmetic expression.  In  case of an error it skips
**  all symbols up to one contained in <follow>.
**
**  <Arith> := <Term> { '+'|'-' <Term> }
*/
static void ReadAri(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    UInt                symbol;

    /* <Term>                                                              */
    ReadTerm(rs, follow, mode);

    /* { '+'|'-' <Term> }                                                  */
    while (IS_IN(rs->s.Symbol, S_PLUS | S_MINUS)) {
        symbol = rs->s.Symbol;
        Match_(rs, rs->s.Symbol, "+ or -", follow);
        ReadTerm(rs, follow, 'r');
        TRY_IF_NO_ERROR {
            if      ( symbol == S_PLUS  ) { IntrSum(&rs->intr);  }
            else if ( symbol == S_MINUS ) { IntrDiff(&rs->intr); }
        }
    }
}


/****************************************************************************
**
*F  ReadRel( <follow>, <mode> ) . . . . . . . .  read a relational expression
**
**  'ReadRel' reads a relational  expression.  In case  of an error it  skips
**  all symbols up to one contained in <follow>.
**
**  <Rel> := { 'not' } <Arith> { '=|<>|<|>|<=|>=|in' <Arith> }
*/
static void ReadRel(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    volatile UInt       symbol;
    volatile UInt       isNot;

    /* { 'not' }                                                           */
    isNot = 0;
    while (rs->s.Symbol == S_NOT) {
        isNot++;
        Match_(rs, S_NOT, "not", follow);
    }

    /* <Arith>                                                             */
    ReadAri(rs, follow, (isNot == 0 ? mode : 'r'));

    /* { '=|<>|<|>|<=|>=|in' <Arith> }                                     */
    if (IS_IN(rs->s.Symbol, S_EQ | S_LT | S_GT | S_NE | S_LE | S_GE | S_IN)) {
        symbol = rs->s.Symbol;
        Match_(rs, rs->s.Symbol, "comparison operator", follow);
        ReadAri(rs, follow, 'r');
        TRY_IF_NO_ERROR {
            if      ( symbol == S_EQ ) { IntrEq(&rs->intr); }
            else if ( symbol == S_NE ) { IntrNe(&rs->intr); }
            else if ( symbol == S_LT ) { IntrLt(&rs->intr); }
            else if ( symbol == S_GE ) { IntrGe(&rs->intr); }
            else if ( symbol == S_GT ) { IntrGt(&rs->intr); }
            else if ( symbol == S_LE ) { IntrLe(&rs->intr); }
            else if ( symbol == S_IN ) { IntrIn(&rs->intr); }
        }
    }

    /* interpret the not                                                   */
    if ( (isNot % 2) != 0 ) {
        TRY_IF_NO_ERROR { IntrNot(&rs->intr); }
    }
}


/****************************************************************************
**
*F  ReadAnd( <follow>, <mode> ) . . . . . . . read a logical 'and' expression
**
**  'ReadAnd' reads an and   expression.  In case of  an  error it  skips all
**  symbols up to one contained in <follow>.
**
**  <And> := <Rel> { 'and' <Rel> }
*/
static void ReadAnd(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    /* <Rel>                                                               */
    ReadRel(rs, follow, mode);

    /* { 'and' <Rel> }                                                     */
    while (rs->s.Symbol == S_AND) {
        Match_(rs, S_AND, "and", follow);
        TRY_IF_NO_ERROR { IntrAndL(&rs->intr); }
        ReadRel(rs, follow, 'r');
        TRY_IF_NO_ERROR { IntrAnd(&rs->intr); }
    }
}


/****************************************************************************
**
*F  ReadQualifiedExpr( <follow>, <mode> )  . . . . . read an expression which
**                                may be qualified with readonly or readwrite
**
**  'ReadQualifiedExpr' reads a qualified expression. In case of an error it
**  skips all symbols up to one contained in <follow>.
**
**  <QualifiedExpr> := ['readonly' | 'readwrite' ] <Expr>
**
**  These functions only do something meaningful inside HPC-GAP; in plain GAP
**  they are simply placeholders.
*/
static void
ReadQualifiedExpr(ReaderState * rs, TypSymbolSet follow, Char mode)
{
#ifdef HPCGAP
    volatile LockQual qual = LOCK_QUAL_NONE;
#else
    volatile UInt qual = 0;
#endif
    if (rs->s.Symbol == S_READWRITE) {
        Match_(rs, S_READWRITE, "readwrite", follow | EXPRBEGIN);
#ifdef HPCGAP
        qual = LOCK_QUAL_READWRITE;
#endif
    }
    else if (rs->s.Symbol == S_READONLY) {
        Match_(rs, S_READONLY, "readonly", follow | EXPRBEGIN);
#ifdef HPCGAP
        qual = LOCK_QUAL_READONLY;
#endif
    }
    TRY_IF_NO_ERROR { IntrQualifiedExprBegin(&rs->intr, qual); }
    ReadExpr(rs, follow, mode);
    TRY_IF_NO_ERROR { IntrQualifiedExprEnd(&rs->intr); }
}


/****************************************************************************
**
*F  ReadExpr( <follow>, <mode> )  . . . . . . . . . . . .  read an expression
**
**  'ReadExpr' reads an expression.  In case of an error it skips all symbols
**  up to one contained in <follow>.
**
**  <Expr> := <And> { 'or' <And> }
**
**  The <mode> is either 'r' indicating that the expression should be
**  evaluated as usual, 'x' indicating that it may be the left-hand-side of
**  an assignment or 'a' indicating that it is a function expression
**  following an "atomic" keyword and that the function should be made
**  atomic.
**
**  This last case exists because when reading "atomic function" in statement
**  context the atomic has been matched away before we can see that it is an
**  atomic function literal, not an atomic statement.
**
**
*/
static void ReadExpr(ReaderState * rs, TypSymbolSet follow, Char mode)
{
    /* <And>                                                               */
    ReadAnd(rs, follow, mode);

    /* { 'or' <And> }                                                      */
    while (rs->s.Symbol == S_OR) {
        Match_(rs, S_OR, "or", follow);
        TRY_IF_NO_ERROR { IntrOrL(&rs->intr); }
        ReadAnd(rs, follow, 'r');
        TRY_IF_NO_ERROR { IntrOr(&rs->intr); }
    }
}


/****************************************************************************
**
*F  ReadUnbind( <follow> )  . . . . . . . . . . . .  read an unbind statement
**
**  'ReadUnbind' reads an unbind statement.  In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**  <Statement> := 'Unbind' '(' <Var> ')' ';'
*/
static void ReadUnbind(ReaderState * rs, TypSymbolSet follow)
{
    Match_(rs, S_UNBIND, "Unbind", follow);
    Match_(rs, S_LPAREN, "(", follow);
    ReadCallVarAss(rs, S_RPAREN|follow, 'u');
    Match_(rs, S_RPAREN, ")", follow);
}


/****************************************************************************
**
*F  ReadEmpty( <follow> )  . . . . . . . . . . . . . .read an empty statement
**
**  'ReadEmpty' reads  an empty statement.  The argument is actually ignored
**
**  <Statement> :=  ';'
*/
static void ReadEmpty(ReaderState * rs, TypSymbolSet follow)
{
  IntrEmpty(&rs->intr);
}

/****************************************************************************
**
*F  ReadInfo( <follow> ) . . . . . . . . . . . . . . . read an info statement
**
**  'ReadInfo' reads  an info statement.  In  case of an  error  it skips all
**  symbols up to one contained in <follow>.
**
**  <Statement> := 'Info' '(' <Expr> ',' <Expr> { ',' <Expr> } ')' ';'
*/
static void ReadInfo(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt narg;     // number of arguments to print (or not)

    TRY_IF_NO_ERROR { IntrInfoBegin(&rs->intr); }
    Match_(rs, S_INFO, "Info", follow);
    Match_(rs, S_LPAREN, "(", follow);
    ReadExpr(rs, S_RPAREN | S_COMMA | follow, 'r');
    Match_(rs, S_COMMA, ",", S_RPAREN|follow);
    ReadExpr(rs, S_RPAREN | S_COMMA | follow, 'r');
    TRY_IF_NO_ERROR { IntrInfoMiddle(&rs->intr); }
    narg = 0;
    while (rs->s.Symbol == S_COMMA) {
        narg++;
        Match_(rs, S_COMMA, "", 0);
        ReadExpr(rs, S_RPAREN | S_COMMA | follow, 'r');
    }
    Match_(rs, S_RPAREN, ")", follow);
    TRY_IF_NO_ERROR { IntrInfoEnd(&rs->intr, narg); }
}


/****************************************************************************
**
*F  ReadAssert( <follow> ) . . . . . . . . . . . . . read an assert statement
**
**  'ReadAssert' reads an assert statement.  In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**  <Statement> := 'Assert' '(' <Expr> ',' <Expr> [ ',' <Expr> ]  ')' ';'
*/
static void ReadAssert(ReaderState * rs, TypSymbolSet follow)
{
    TRY_IF_NO_ERROR { IntrAssertBegin(&rs->intr); }
    Match_(rs, S_ASSERT, "Assert", follow);
    Match_(rs, S_LPAREN, "(", follow);
    ReadExpr(rs, S_RPAREN | S_COMMA | follow, 'r');
    TRY_IF_NO_ERROR { IntrAssertAfterLevel(&rs->intr); }
    Match_(rs, S_COMMA, ",", S_RPAREN|follow);
    ReadExpr(rs, S_RPAREN | S_COMMA | follow, 'r');
    TRY_IF_NO_ERROR { IntrAssertAfterCondition(&rs->intr); }
    if (rs->s.Symbol == S_COMMA) {
        Match_(rs, S_COMMA, "", 0);
        ReadExpr(rs, S_RPAREN |  follow, 'r');
        Match_(rs, S_RPAREN, ")", follow);
        TRY_IF_NO_ERROR { IntrAssertEnd3Args(&rs->intr); }
    }
    else {
        Match_(rs, S_RPAREN, ")", follow);
        TRY_IF_NO_ERROR { IntrAssertEnd2Args(&rs->intr); }
    }
}

/****************************************************************************
**
*F  ReadIf( <follow> )  . . . . . . . . . . . . . . . .  read an if statement
**
**  'ReadIf' reads an if-statement.  In case of an error it skips all symbols
**  up to one contained in <follow>.
**
**  <Statement> := 'if'   <Expr> 'then' <Statements>
**                 { 'elif' <Expr> 'then' <Statements> }
**                 [ 'else'               <Statements> ]
**                 'fi' ';'
*/
static void ReadIf(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt       nrb;            /* number of branches              */
    volatile UInt       nrs;            /* number of statements in a body  */

    /* 'if' <Expr> 'then' <Statements>                                     */
    nrb = 0;
    TRY_IF_NO_ERROR { IntrIfBegin(&rs->intr); }
    Match_(rs, S_IF, "if", follow);
    ReadExpr(rs, S_THEN|S_ELIF|S_ELSE|S_FI|follow, 'r');
    Match_(rs, S_THEN, "then", STATBEGIN|S_ELIF|S_ELSE|S_FI|follow);
    TRY_IF_NO_ERROR { IntrIfBeginBody(&rs->intr); }
    nrs = ReadStats(rs, S_ELIF|S_ELSE|S_FI|follow);
    TRY_IF_NO_ERROR { nrb += IntrIfEndBody(&rs->intr,  nrs ); }

    /* { 'elif' <Expr> 'then' <Statements> }                               */
    while (rs->s.Symbol == S_ELIF) {
        TRY_IF_NO_ERROR { IntrIfElif(&rs->intr); }
        Match_(rs, S_ELIF, "elif", follow);
        ReadExpr(rs, S_THEN|S_ELIF|S_ELSE|S_FI|follow, 'r');
        Match_(rs, S_THEN, "then", STATBEGIN|S_ELIF|S_ELSE|S_FI|follow);
        TRY_IF_NO_ERROR { IntrIfBeginBody(&rs->intr); }
        nrs = ReadStats(rs, S_ELIF|S_ELSE|S_FI|follow);
        TRY_IF_NO_ERROR { nrb += IntrIfEndBody(&rs->intr,  nrs ); }
    }

    /* [ 'else' <Statements> ]                                             */
    if (rs->s.Symbol == S_ELSE) {
        TRY_IF_NO_ERROR { IntrIfElse(&rs->intr); }
        Match_(rs, S_ELSE, "else", follow);
        TRY_IF_NO_ERROR { IntrIfBeginBody(&rs->intr); }
        nrs = ReadStats(rs, S_FI|follow);
        TRY_IF_NO_ERROR { nrb += IntrIfEndBody(&rs->intr,  nrs ); }
    }

    /* 'fi'                                                                */
    Match_(rs, S_FI, "while parsing an 'if' statement: statement or 'fi'", follow);
    TRY_IF_NO_ERROR { IntrIfEnd(&rs->intr,  nrb ); }
}


/****************************************************************************
**
*F  ReadFor( <follow> ) . . . . . . . . . . . . . . . .  read a for statement
**
**  'ReadFor' reads a for-loop.  In case of an error it  skips all symbols up
**  to one contained in <follow>.
**
**  <Statement> := 'for' <Var>  'in' <Expr>  'do'
**                     <Statements>
**                 'od' ';'
*/


static void ReadFor(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt       nrs;            /* number of statements in body    */

    /* 'for'                                                               */
    TRY_IF_NO_ERROR { IntrForBegin(&rs->intr, rs->StackNams); }
    Match_(rs, S_FOR, "for", follow);

    /* <Var>                                                               */
    volatile LHSRef ref = ReadVar(rs, follow);
    if (ref.type != R_INVALID)
        EvalRef(rs, ref, 1);
    CheckUnboundGlobal(rs, ref);

    /* 'in' <Expr>                                                         */
    Match_(rs, S_IN, "in", S_DO|S_OD|follow);
    TRY_IF_NO_ERROR { IntrForIn(&rs->intr); }
    ReadExpr(rs, S_DO|S_OD|follow, 'r');

    /* 'do' <Statements>                                                   */
    Match_(rs, S_DO, "do", STATBEGIN|S_OD|follow);
    if (ref.type == R_GVAR)
        PushGlobalForLoopVariable(rs, ref.var);
    rs->LoopNesting++;
    TRY_IF_NO_ERROR { IntrForBeginBody(&rs->intr); }
    nrs = ReadStats(rs, S_OD|follow);
    TRY_IF_NO_ERROR { IntrForEndBody(&rs->intr,  nrs ); }
    rs->LoopNesting--;
    if (ref.type == R_GVAR)
        PopGlobalForLoopVariable(rs);

    /* 'od'                                                                */
    Match_(rs, S_OD, "while parsing a 'for' loop: statement or 'od'", follow);
    TRY_IF_NO_ERROR {
        IntrForEnd(&rs->intr, rs->StackNams);
    }
}


/****************************************************************************
**
*F  ReadWhile( <follow> ) . . . . . . . . . . . . . .  read a while statement
**
**  'ReadWhile' reads a while-loop.  In case of an error it skips all symbols
**  up to one contained in <follow>.
**
**  <Statement> := 'while' <Expr>  'do'
**                     <Statements>
**                 'od' ';'
*/
static void ReadWhile(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt       nrs;            /* number of statements in body    */

    /* 'while' <Expr>  'do'                                                */
    TRY_IF_NO_ERROR { IntrWhileBegin(&rs->intr, rs->StackNams); }
    Match_(rs, S_WHILE, "while", follow);
    ReadExpr(rs, S_DO|S_OD|follow, 'r');
    Match_(rs, S_DO, "do", STATBEGIN|S_DO|follow);

    //     <Statements>
    rs->LoopNesting++;
    TRY_IF_NO_ERROR { IntrWhileBeginBody(&rs->intr); }
    nrs = ReadStats(rs, S_OD|follow);
    TRY_IF_NO_ERROR { IntrWhileEndBody(&rs->intr,  nrs ); }
    rs->LoopNesting--;

    /* 'od'                                                                */
    Match_(rs, S_OD, "while parsing a 'while' loop: statement or 'od'", follow);
    TRY_IF_NO_ERROR {
        IntrWhileEnd(&rs->intr, rs->StackNams);
    }
}

/****************************************************************************
**
*F  ReadAtomic( <follow> ) . . . . . . . . . . . . . . . read an atomic block
**
**  'ReadAtomic' reads an atomic block. In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**  <Statement> := 'atomic' <QualifiedExpr> { ',' <QualifiedExpr } 'do'
**                     <Statements>
**                 'od' ';'
**
**  These functions only do something meaningful inside HPC-GAP; in plain GAP,
**  they are simply placeholders.
*/
static void ReadAtomic(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt       nrs;            /* number of statements in body    */
    volatile UInt       nexprs;         /* number of statements in body    */
#ifdef HPCGAP
    volatile int        lockSP;         /* lock stack */

    lockSP    = RegionLockSP();
#endif

    Match_(rs, S_ATOMIC, "atomic", follow);
    /* Might just be an atomic function literal as an expression */
    if (rs->s.Symbol == S_FUNCTION) {
        ReadFuncExpr(rs, follow, 'a');
        return;
    }

    /* 'atomic' <QualifiedExpr> {',' <QualifiedExpr> } 'do'    */
    TRY_IF_NO_ERROR { IntrAtomicBegin(&rs->intr, rs->StackNams); }

    ReadQualifiedExpr(rs, S_DO|S_OD|follow, 'r');
    nexprs = 1;
    while (rs->s.Symbol == S_COMMA) {
      Match_(rs, S_COMMA, ",", follow | S_DO | S_OD);
      ReadQualifiedExpr(rs, S_DO|S_OD|follow, 'r');
      nexprs ++;
#ifdef HPCGAP
      if (nexprs > MAX_ATOMIC_OBJS) {
        SyntaxError(&rs->s, "'atomic' statement can have at most 256 objects to lock");
        return;
      }
#endif
    }

    Match_(rs, S_DO, "do", STATBEGIN|S_DO|follow);

    //     <Statements>
    TRY_IF_NO_ERROR { IntrAtomicBeginBody(&rs->intr, nexprs); }
    nrs = ReadStats(rs, S_OD|follow);
    TRY_IF_NO_ERROR { IntrAtomicEndBody(&rs->intr,  nrs ); }

    /* 'od'                                                                */
    Match_(rs, S_OD, "while parsing an atomic block: statement or 'od'", follow);
    TRY_IF_NO_ERROR {
        IntrAtomicEnd(&rs->intr, rs->StackNams);
    }
#ifdef HPCGAP
    /* This is a no-op if IntrAtomicEnd(&rs->intr) succeeded, otherwise it restores
     * locks to where they were before. */
    PopRegionLocks(lockSP);
#endif
}


/****************************************************************************
**
*F  ReadRepeat( <follow> )  . . . . . . . . . . . . . read a repeat statement
**
**  'ReadRepeat' reads a  repeat-loop.   In case  of an  error it skips   all
**  symbols up to one contained in <follow>.
**
** <Statement> := 'repeat'
**                    <Statements>
**                'until' <Expr> ';'
*/
static void ReadRepeat(ReaderState * rs, TypSymbolSet follow)
{
    volatile UInt       nrs;            /* number of statements in body    */

    /* 'repeat'                                                            */
    TRY_IF_NO_ERROR { IntrRepeatBegin(&rs->intr, rs->StackNams); }
    Match_(rs, S_REPEAT, "repeat", follow);

    //  <Statements>
    rs->LoopNesting++;
    TRY_IF_NO_ERROR { IntrRepeatBeginBody(&rs->intr); }
    nrs = ReadStats(rs, S_UNTIL|follow);
    TRY_IF_NO_ERROR { IntrRepeatEndBody(&rs->intr,  nrs ); }
    rs->LoopNesting--;

    /* 'until' <Expr>                                                      */
    Match_(rs, S_UNTIL, "while parsing a 'repeat' loop: statement or 'until'", EXPRBEGIN|follow);
    ReadExpr(rs, follow, 'r');
    TRY_IF_NO_ERROR {
        IntrRepeatEnd(&rs->intr, rs->StackNams);
    }
}


/****************************************************************************
**
*F  ReadBreak(<follow>) . . . . . . . . . . . . . . .  read a break statement
**
**  'ReadBreak' reads a  break-statement.  In case  of an error  it skips all
**  symbols up to one contained in <follow>.
**
**  <Statement> := 'break' ';'
*/
static void ReadBreak(ReaderState * rs, TypSymbolSet follow)
{
    if (!rs->LoopNesting)
        SyntaxError(&rs->s, "'break' statement not enclosed in a loop");

    /* skip the break symbol                                               */
    Match_(rs, S_BREAK, "break", follow);

    /* interpret the break statement                                       */
    TRY_IF_NO_ERROR { IntrBreak(&rs->intr); }
}

/****************************************************************************
**
*F  ReadContinue(<follow>) . . . . . . . . . . . .  read a continue statement
**
**  'ReadContinue' reads a continue-statement. In case of an error it skips
**  all symbols up to one contained in <follow>.
**
**  <Statement> := 'continue' ';'
*/
static void ReadContinue(ReaderState * rs, TypSymbolSet follow)
{
    if (!rs->LoopNesting)
        SyntaxError(&rs->s, "'continue' statement not enclosed in a loop");

    // skip the continue symbol
    Match_(rs, S_CONTINUE, "continue", follow);

    // interpret the continue statement
    TRY_IF_NO_ERROR { IntrContinue(&rs->intr); }
}


/****************************************************************************
**
*F  ReadReturn( <follow> )  . . . . . . . . . . . . . read a return statement
**
**  'ReadReturn'   reads  a  return-statement.   Return  with   no expression
**  following is used  in functions to return void.   In case of an error  it
**  skips all symbols up to one contained in <follow>.
**
**  <Statement> := 'return' [ <Expr> ] ';'
**
**  It is still legal to use parenthesis but they  are  no  longer  required,
**  a return statement is not a function call and should not look  like  one.
*/
static void ReadReturn(ReaderState * rs, TypSymbolSet follow)
{
    /* skip the return symbol                                              */
    Match_(rs, S_RETURN, "return", follow);

    /* 'return' with no expression following                               */
    if (IS_IN(rs->s.Symbol, S_SEMICOLON)) {
        TRY_IF_NO_ERROR { IntrReturnVoid(&rs->intr); }
    }

    /* 'return' with an expression following                               */
    else {
        ReadExpr(rs, follow, 'r');
        TRY_IF_NO_ERROR { IntrReturnObj(&rs->intr); }
    }
}


/****************************************************************************
**
*F  ReadTryNext(<follow>) . . . . . . . . .  read a try-next-method statement
**
**  'ReadTryNext' reads a try-next-method statement.  In case of an error  it
**  skips all symbols up to one contained in <follow>.
**
**  <Statement> := 'TryNextMethod' '(' ')' ';'
*/
static void ReadTryNext(ReaderState * rs, TypSymbolSet follow)
{
    Match_(rs, S_TRYNEXT, "TryNextMethod", follow);
    Match_(rs, S_LPAREN, "(", follow);
    Match_(rs, S_RPAREN, ")", follow);
    TRY_IF_NO_ERROR {
        IntrRefGVar(&rs->intr,  GVarName( "TRY_NEXT_METHOD" ) );
        IntrReturnObj(&rs->intr);
    }
}

static void ReadHelp(ReaderState * rs, TypSymbolSet follow)
{
    TRY_IF_NO_ERROR { IntrHelp(&rs->intr, rs->s.ValueObj); }
    rs->s.ValueObj = 0;
}

static void ReadPragma(ReaderState * rs, TypSymbolSet follow)
{
    TRY_IF_NO_ERROR { IntrPragma(&rs->intr, rs->s.ValueObj); }
    rs->s.ValueObj = 0;
}

/****************************************************************************
**
*F  ReadQuit( <follow> )  . . . . . . . . . . . . . . . read a quit statement
**
**  'ReadQuit' reads a  quit  statement.  In case   of an error it skips  all
**  symbols up to one contained in <follow>.
**
**  <Statement> := 'quit' ';'
*/
static void ReadQuit(ReaderState * rs, TypSymbolSet follow)
{
    /* skip the quit symbol                                                */
    Match_(rs, S_QUIT, "quit", follow);

    /* interpret the quit                                                  */
    TRY_IF_NO_ERROR { IntrQuit(&rs->intr); }
}

/****************************************************************************
**
*F  ReadQUIT( <follow> )  . . . . . . . . . . . . . . . read a QUIT statement
**
**  'ReadQUIT' reads a  QUIT  statement.  In case   of an error it skips  all
**  symbols up to one contained in <follow>.
**
**  <Statement> := 'QUIT' ';'
*/
static void ReadQUIT(ReaderState * rs, TypSymbolSet follow)
{
    /* skip the quit symbol                                                */
    Match_(rs, S_QQUIT, "QUIT", follow);

    /* interpret the quit                                                  */
    TRY_IF_NO_ERROR { IntrQUIT(&rs->intr); }
}


/****************************************************************************
**
*F  ReadStats(<follow>) . . . . . . . . . . . . . . read a statement sequence
**
**  'ReadStats' reads a statement sequence.  In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**  <Statements> := { <Statement> }
**
**  <Statement>  := <Var> ':=' <Expr> ';'
**              |  <Var> '(' [ <Expr> { ',' <Expr> } ] ')' ';'
**              |  'Unbind' '(' <Var> ')' ';'
**              |  'if'   <Expr>  'then' <Statements>
**                 { 'elif' <Expr>  'then' <Statements> }
**                 [ 'else'                <Statements> ] 'fi' ';'
**              |  'for' <Var> 'in' <Expr> 'do' <Statements> 'od' ';'
**              |  'while' <Expr>  'do' <Statements>  'od' ';'
**              |  'repeat' <Statements>  'until' <Expr> ';'
**              |  'break' ';'
**              |  'continue' ';'
**              |  'return' [ <Expr> ] ';'
**              |  'atomic' <QualifiedExpr> { ',' <QualifiedExpr> } 'do' <Statements> 'od' ';'
**              |  ';'
*/
static Int TryReadStatement(ReaderState * rs, TypSymbolSet follow)
{
    switch (rs->s.Symbol) {
    case S_IDENT:     ReadCallVarAss(rs, follow,'s'); break;
    case S_UNBIND:    ReadUnbind(rs,     follow    ); break;
    case S_INFO:      ReadInfo(rs,       follow    ); break;
    case S_ASSERT:    ReadAssert(rs,     follow    ); break;
    case S_IF:        ReadIf(rs,         follow    ); break;
    case S_FOR:       ReadFor(rs,        follow    ); break;
    case S_WHILE:     ReadWhile(rs,      follow    ); break;
    case S_REPEAT:    ReadRepeat(rs,     follow    ); break;
    case S_BREAK:     ReadBreak(rs,      follow    ); break;
    case S_CONTINUE:  ReadContinue(rs,   follow    ); break;
    case S_RETURN:    ReadReturn(rs,     follow    ); break;
    case S_TRYNEXT:   ReadTryNext(rs,    follow    ); break;
    case S_ATOMIC:    ReadAtomic(rs,     follow    ); break;
    case S_SEMICOLON: ReadEmpty(rs,      follow    ); break;
    case S_PRAGMA:    ReadPragma(rs,     follow    ); break;
    case S_QUIT:      SyntaxError(&rs->s, "'quit;' cannot be used in this context"); break;
    case S_QQUIT:     SyntaxError(&rs->s, "'QUIT;' cannot be used in this context"); break;
    case S_HELP:      SyntaxError(&rs->s, "'?' cannot be used in this context"); break;
    default:         return 0;
    }
    return 1;
}

static UInt ReadStats(ReaderState * rs, TypSymbolSet follow)
{
    UInt nr = 0;    // number of statements

    // read the statements
    while (IS_IN(rs->s.Symbol, STATBEGIN | S_SEMICOLON)) {
        if (!TryReadStatement(rs, follow)) {
            SyntaxError(&rs->s, "statement expected");
        }
        nr++;
        if (rs->s.Symbol == S_PRAGMA)
            Match_(rs, S_PRAGMA, "", 0);
        else
            MatchSemicolon(rs, follow);
    }

    // return the number of statements
    return nr;
}


/****************************************************************************
**
*F * * * * * * * * * * * * read and evaluate symbols  * * * * * * * * * * * *
*/


static void RecreateStackNams(ReaderState * rs, Obj context)
{
    Obj stackNams = rs->StackNams;
    Obj lvars = context;
    while (lvars && !IsBottomLVars(lvars))  {
        Obj nams = NAMS_FUNC(FUNC_LVARS(lvars));
        if (nams != (Obj) 0) {
            PushPlist(stackNams, nams);
        }
        lvars = ENVI_FUNC(FUNC_LVARS(lvars));
    }

    // At this point we have the stack upside down, so invert it
    const UInt countNams = LEN_PLIST(stackNams);
    for (UInt i = 1; i <= countNams/2; i++) {
        const UInt j = countNams + 1 -i;
        Obj tmpA = ELM_PLIST(stackNams, i);
        Obj tmpB = ELM_PLIST(stackNams, j);
        SET_ELM_PLIST(stackNams, i, tmpB);
        SET_ELM_PLIST(stackNams, j, tmpA);
    }
}


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
                           BOOL *         dualSemicolon)
{
    volatile ExecStatus status;
    volatile Obj        tilde;
    volatile Obj        errorLVars;
    jmp_buf           readJmpError;
#ifdef HPCGAP
    int                 lockSP;
#endif

    ReaderState reader;
    ReaderState * volatile rs = &reader;
    memset(rs, 0, sizeof(ReaderState));

    GAP_ASSERT(input);
    rs->s.input = input;

    ClearError();

    /* get the first symbol from the input                                 */
    Match_(rs, rs->s.Symbol, "", 0);

    // if scanning the first symbol produced a syntax error, abort
    if (rs->s.NrError) {
        FlushRestOfInputLine(input);
        return STATUS_ERROR;
    }

    /* if we have hit <end-of-file>, then give up                          */
    if (rs->s.Symbol == S_EOF) {
        return STATUS_EOF;
    }

    /* print only a partial prompt from now on                             */
    SetPrompt("> ");

    /* remember the old reader context                                     */
    tilde       = STATE(Tilde);
    errorLVars  = STATE(ErrorLVars);
    memcpy( readJmpError, STATE(ReadJmpError), sizeof(jmp_buf) );

    // initialize everything and begin an interpreter
    rs->StackNams      = NEW_PLIST( T_PLIST, 16 );
    STATE(Tilde)       = 0;
#ifdef HPCGAP
    lockSP = RegionLockSP();
#endif

    AssGVar(GVarName("READEVALCOMMAND_LINENUMBER"),
            INTOBJ_INT(GetInputLineNumber(rs->s.input)));

    // remember the old execution state and start an execution environment
    Bag oldLVars =
        context ? SWITCH_TO_OLD_LVARS(context) : SWITCH_TO_BOTTOM_LVARS();

    if (context)
        RecreateStackNams(rs, context);

    STATE(ErrorLVars) = STATE(CurrLVars);

    IntrBegin(&rs->intr);

    switch (rs->s.Symbol) {
    /* read an expression or an assignment or a procedure call             */
    case S_IDENT:     ReadExpr(rs,    S_SEMICOLON|S_EOF, 'x' ); break;

    // otherwise read a statement -- first handle some which are different on
    // the top level than inside a function, if/else or loop
    case S_QUIT:      ReadQuit(rs,    S_SEMICOLON|S_EOF      ); break;
    case S_QQUIT:     ReadQUIT(rs,    S_SEMICOLON|S_EOF      ); break;
    case S_HELP:
        ReadHelp(rs, S_SEMICOLON | S_EOF);
        rs->s.Symbol = S_SEMICOLON;    // fake a trailing semicolon
        break;
    case S_PRAGMA:
        ReadPragma(rs, S_SEMICOLON | S_EOF);
        rs->s.Symbol = S_SEMICOLON;    // fake a trailing semicolon
        break;

    // otherwise try to read a generic statement
    default:
        if (!TryReadStatement(rs, S_SEMICOLON | S_EOF)) {
            // not a statement, but perhaps it is an expression
            ReadExpr(rs, S_SEMICOLON | S_EOF, 'r');
        }
    }

    /* every statement must be terminated by a semicolon                  */
    if (!IS_IN(rs->s.Symbol, S_SEMICOLON)) {
        SyntaxError(&rs->s, "; expected");
    }

    // check for dual semicolon
    if (dualSemicolon)
        *dualSemicolon = (rs->s.Symbol == S_DUALSEMICOLON);

    // end the interpreter
    status = IntrEnd(&rs->intr, rs->s.NrError > 0, evalResult);

    // restore the execution environment
    SWITCH_TO_OLD_LVARS(oldLVars);

#ifdef HPCGAP
    if (rs->s.NrError > 0) {
        PopRegionLocks(lockSP);
        if (TLS(CurrentHashLock))
            HashUnlock(TLS(CurrentHashLock));
    }
#endif

    GAP_ASSERT(rs->LoopNesting == 0);

    /* switch back to the old reader context                               */
    memcpy( STATE(ReadJmpError), readJmpError, sizeof(jmp_buf) );
    STATE(Tilde)       = tilde;
    STATE(ErrorLVars)  = errorLVars;

    ClearError();

    /* return whether a return-statement or a quit-statement were executed */
    return status;
}

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
ExecStatus ReadEvalFile(TypInputFile * input, Obj * evalResult)
{
    volatile ExecStatus status;
    volatile Obj        tilde;
    jmp_buf           readJmpError;
    volatile UInt       nr;
    volatile Obj        nams;
    volatile Int        nloc;
#ifdef HPCGAP
    volatile int        lockSP;
#endif

    ReaderState reader;
    ReaderState * volatile rs = &reader;
    memset(rs, 0, sizeof(ReaderState));

    GAP_ASSERT(input);
    rs->s.input = input;

    ClearError();

    /* get the first symbol from the input                                 */
    Match_(rs, rs->s.Symbol, "", 0);

    /* print only a partial prompt from now on                             */
    SetPrompt("> ");

    /* remember the old reader context                                     */
    tilde       = STATE(Tilde);
#ifdef HPCGAP
    lockSP      = RegionLockSP();
#endif
    memcpy( readJmpError, STATE(ReadJmpError), sizeof(jmp_buf) );

    // initialize everything and begin an interpreter
    rs->StackNams    = NEW_PLIST( T_PLIST, 16 );
    STATE(Tilde)     = 0;

    // remember the old execution state and start an execution environment
    Bag oldLVars = SWITCH_TO_BOTTOM_LVARS();

    IntrBegin(&rs->intr);

    /* check for local variables                                           */
    nams = NEW_PLIST(T_PLIST, 0);
    PushPlist(rs->StackNams, nams);
    nloc = 0;
    if (rs->s.Symbol == S_LOCAL) {
        nloc = ReadLocals(rs, 0, nams);
    }

    /* fake the 'function ()'                                              */
    IntrFuncExprBegin(&rs->intr, 0, nloc, nams,
                      GetInputLineNumber(rs->s.input));

    /* read the statements                                                 */
    GAP_ASSERT(rs->LoopNesting == 0);
    nr = ReadStats(rs, S_SEMICOLON | S_EOF);
    GAP_ASSERT(rs->LoopNesting == 0);

    /* we now want to be at <end-of-file>                                  */
    if (rs->s.Symbol != S_EOF) {
        FlushRestOfInputLine(input);
        SyntaxError(&rs->s, "<end-of-file> expected");
    }

    /* fake the 'end;'                                                     */
    TRY_IF_NO_ERROR {
        IntrFuncExprEnd(&rs->intr, nr);
    }

    /* end the interpreter                                                 */
    status = IntrEnd(&rs->intr, rs->s.NrError > 0, evalResult);

    // restore the execution environment
    SWITCH_TO_OLD_LVARS(oldLVars);

    /* switch back to the old reader context                               */
    memcpy( STATE(ReadJmpError), readJmpError, sizeof(jmp_buf) );
#ifdef HPCGAP
    PopRegionLocks(lockSP);
    if (TLS(CurrentHashLock))
      HashUnlock(TLS(CurrentHashLock));
#endif
    STATE(Tilde)     = tilde;

    ClearError();

    /* return whether a return-statement or a quit-statement were executed */
    return status;
}


/****************************************************************************
**
*F  Call0ArgsInNewReader(Obj f)  . . . . . . . . . . . . call a GAP function
**
**  The current reader context is saved and a new one is started.
*/
Obj Call0ArgsInNewReader(Obj f)
{
    // remember the old state
    volatile UInt userHasQuit = STATE(UserHasQuit);
    volatile Obj  oldLvars;
    volatile Obj  result = 0;

    // initialize everything
    STATE(UserHasQuit) = FALSE;
    oldLvars = SWITCH_TO_BOTTOM_LVARS();

    GAP_TRY
    {
        result = CALL_0ARGS(f);
    }
    GAP_CATCH
    {
        ClearError();
    }

    // switch back to the old state
    SWITCH_TO_OLD_LVARS(oldLvars);
    STATE(UserHasQuit) = userHasQuit;
    return result;
}


/****************************************************************************
**
*F  Call1ArgsInNewReader(Obj f,Obj a) . . . . . . . . . . call a GAP function
**
**  The current reader context is saved and a new one is started.
*/
Obj Call1ArgsInNewReader(Obj f, Obj a)
{
    // remember the old state
    volatile UInt userHasQuit = STATE(UserHasQuit);
    volatile Obj  oldLvars;
    volatile Obj  result = 0;

    // initialize everything
    STATE(UserHasQuit) = FALSE;
    oldLvars = SWITCH_TO_BOTTOM_LVARS();

    GAP_TRY
    {
        result = CALL_1ARGS(f, a);
    }
    GAP_CATCH
    {
        ClearError();
    }

    // switch back to the old state
    SWITCH_TO_OLD_LVARS(oldLvars);
    STATE(UserHasQuit) = userHasQuit;
    return result;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    InitCopyGVar( "GAPInfo", &GAPInfo);
    return 0;
}


static Int InitModuleState(void)
{
    STATE(ErrorLVars) = (UInt **)0;

    return 0;
}


/****************************************************************************
**
*F  InitInfoRead()  . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "read",
    .initKernel = InitKernel,

    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoRead ( void )
{
    return &module;
}
