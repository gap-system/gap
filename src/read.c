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
#include "vars.h"

#ifdef HPCGAP
#include "hpc/thread.h"
#endif


struct ReaderState {

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

static ModuleStateOffset ReaderStateOffset = -1;

extern inline struct ReaderState * ReaderState(void)
{
    return (struct ReaderState *)StateSlotsAtOffset(ReaderStateOffset);
}


/****************************************************************************
**
**  The constructs <Expr> and <Statements> may have themselves as subpart,
**  e.g., '<Var>( <Expr> )' is <Expr> and 'if <Expr> then <Statements> fi;'
**  is <Statements>. The functions 'ReadExpr' and 'ReadStats' must therefore
**  be declared forward.
*/
static void ReadExpr(ScannerState * s, TypSymbolSet follow, Char mode);

static UInt ReadStats(ScannerState * s, TypSymbolSet follow);

static void ReadFuncExprAbbrevSingle(ScannerState * s, TypSymbolSet follow);

static void ReadAtom(ScannerState * s, TypSymbolSet follow, Char mode);

void PushGlobalForLoopVariable( UInt var)
{
    struct ReaderState * rs = ReaderState();
    if (rs->CurrentGlobalForLoopDepth < 100)
        rs->CurrentGlobalForLoopVariables[rs->CurrentGlobalForLoopDepth] = var;
    rs->CurrentGlobalForLoopDepth++;
}

void PopGlobalForLoopVariable( void )
{
    GAP_ASSERT(ReaderState()->CurrentGlobalForLoopDepth);
    ReaderState()->CurrentGlobalForLoopDepth--;
}

static UInt GlobalComesFromEnclosingForLoop (UInt var)
{
    struct ReaderState * rs = ReaderState();
    for (UInt i = 0; i < rs->CurrentGlobalForLoopDepth; i++) {
        if (i == 100)
          return 0;
        if (rs->CurrentGlobalForLoopVariables[i] == var)
          return 1;
    }
    return 0;
}

// match either a semicolon or a dual semicolon
static void MatchSemicolon(ScannerState * s, TypSymbolSet skipto)
{
    Match(s, s->Symbol == S_DUALSEMICOLON ? S_DUALSEMICOLON : S_SEMICOLON,
          ";", skipto);
}

// Search the plist 'nams' for a string equal to 'value' between and
// including index 'start' and 'end' and return its index; return 0 if not
// found.
static UInt findValueInNams(Obj nams, const Char * val, UInt start, UInt end)
{
    GAP_ASSERT(LEN_PLIST(nams) < MAX_FUNC_LVARS);
    for (UInt i = start; i <= end; i++) {
        if (strcmp(CONST_CSTR_STRING(ELM_PLIST(nams, i)), val) == 0) {
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
static void ReadFuncCallOption(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt rnam; // record component name
    if (s->Symbol == S_IDENT) {
        rnam = RNamName(s->Value);
        Match(s, S_IDENT, "identifier", S_COMMA | follow);
        TRY_IF_NO_ERROR { IntrFuncCallOptionsBeginElmName(rnam); }
    }
    else if (s->Symbol == S_LPAREN) {
        Match(s, S_LPAREN, "(", S_COMMA | follow);
        ReadExpr(s, follow, 'r');
        Match(s, S_RPAREN, ")", S_COMMA | follow);
        TRY_IF_NO_ERROR { IntrFuncCallOptionsBeginElmExpr(); }
    }
    else {
        SyntaxError(s, "Identifier expected");
    }
    if (s->Symbol == S_ASSIGN) {
        Match(s, S_ASSIGN, ":=", S_COMMA | follow);
        ReadExpr(s, S_COMMA | S_RPAREN | follow, 'r');
        TRY_IF_NO_ERROR { IntrFuncCallOptionsEndElm(); }
    }
    else {
        TRY_IF_NO_ERROR { IntrFuncCallOptionsEndElmEmpty(); }
    }
}

static void ReadFuncCallOptions(ScannerState * s, TypSymbolSet follow)
{
  volatile UInt nr;
  TRY_IF_NO_ERROR { IntrFuncCallOptionsBegin( ); }
  ReadFuncCallOption(s, follow);
  nr = 1;
  while (s->Symbol == S_COMMA) {
      Match(s, S_COMMA, ",", follow);
      ReadFuncCallOption(s, follow);
      nr++;
    }
  TRY_IF_NO_ERROR {
    IntrFuncCallOptionsEnd( nr );
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
static UInt EvalRef(const LHSRef ref, Int needExpr)
{
    TRY_IF_NO_ERROR
    {
        switch (ref.type) {
        case R_LVAR:
            IntrRefLVar(ref.var);
            break;
        case R_HVAR:
            IntrRefHVar(ref.var);
            break;
        case R_DVAR:
            IntrRefDVar(ref.var, ref.nest0);
            break;
        case R_GVAR:
            IntrRefGVar(ref.var);
            break;
        case R_ELM_LIST:
            if (ref.level == 0)
                IntrElmList(ref.narg);
            else
                IntrElmListLevel(ref.narg, ref.level);
            return ref.level;
        case R_ELMS_LIST:
            if (ref.level == 0)
                IntrElmsList();
            else
                IntrElmsListLevel(ref.level);
            return ref.level + 1;
        case R_ELM_POSOBJ:
            IntrElmPosObj();
            break;
        case R_ELM_REC_NAME:
            IntrElmRecName(ref.rnam);
            break;
        case R_ELM_REC_EXPR:
            IntrElmRecExpr();
            break;
        case R_ELM_COMOBJ_NAME:
            IntrElmComObjName(ref.rnam);
            break;
        case R_ELM_COMOBJ_EXPR:
            IntrElmComObjExpr();
            break;
        case R_FUNCCALL:
            IntrFuncCallEnd(needExpr, 0, ref.narg);
            break;
        case R_FUNCCALL_OPTS:
            IntrFuncCallEnd(needExpr, 1, ref.narg);
            break;
        case R_INVALID:
        default:
            // This should never be reached
            Panic("Parse error in EvalRef");
        }
    }
    return 0;
}

static void AssignRef(const LHSRef ref)
{
    TRY_IF_NO_ERROR
    {
        switch (ref.type) {
        case R_LVAR:
            IntrAssLVar(ref.var);
            break;
        case R_HVAR:
            IntrAssHVar(ref.var);
            break;
        case R_DVAR:
            IntrAssDVar(ref.var, ref.nest0);
            break;
        case R_GVAR:
            IntrAssGVar(ref.var);
            break;
        case R_ELM_LIST:
            if (ref.level == 0)
                IntrAssList(ref.narg);
            else
                IntrAssListLevel(ref.narg, ref.level);
            break;
        case R_ELMS_LIST:
            if (ref.level == 0)
                IntrAsssList();
            else
                IntrAsssListLevel(ref.level);
            break;
        case R_ELM_POSOBJ:
            IntrAssPosObj();
            break;
        case R_ELM_REC_NAME:
            IntrAssRecName(ref.rnam);
            break;
        case R_ELM_REC_EXPR:
            IntrAssRecExpr();
            break;
        case R_ELM_COMOBJ_NAME:
            IntrAssComObjName(ref.rnam);
            break;
        case R_ELM_COMOBJ_EXPR:
            IntrAssComObjExpr();
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

static void UnbindRef(ScannerState * s, const LHSRef ref)
{
    TRY_IF_NO_ERROR
    {
        switch (ref.type) {
        case R_LVAR:
            IntrUnbLVar(ref.var);
            break;
        case R_HVAR:
            IntrUnbHVar(ref.var);
            break;
        case R_DVAR:
            IntrUnbDVar(ref.var, ref.nest0);
            break;
        case R_GVAR:
            IntrUnbGVar(ref.var);
            break;
        case R_ELM_LIST:
            IntrUnbList(ref.narg);
            break;
        case R_ELM_POSOBJ:
            IntrUnbPosObj();
            break;
        case R_ELM_REC_NAME:
            IntrUnbRecName(ref.rnam);
            break;
        case R_ELM_REC_EXPR:
            IntrUnbRecExpr();
            break;
        case R_ELM_COMOBJ_NAME:
            IntrUnbComObjName(ref.rnam);
            break;
        case R_ELM_COMOBJ_EXPR:
            IntrUnbComObjExpr();
            break;
        case R_INVALID:
        case R_ELMS_LIST:
        case R_FUNCCALL:
        case R_FUNCCALL_OPTS:
        default:
            SyntaxError(s, "Illegal operand for 'Unbind'");
        }
    }
}

static void IsBoundRef(ScannerState * s, const LHSRef ref)
{
    TRY_IF_NO_ERROR
    {
        switch (ref.type) {
        case R_LVAR:
            IntrIsbLVar(ref.var);
            break;
        case R_HVAR:
            IntrIsbHVar(ref.var);
            break;
        case R_DVAR:
            IntrIsbDVar(ref.var, ref.nest0);
            break;
        case R_GVAR:
            IntrIsbGVar(ref.var);
            break;
        case R_ELM_LIST:
            IntrIsbList(ref.narg);
            break;
        case R_ELM_POSOBJ:
            IntrIsbPosObj();
            break;
        case R_ELM_REC_NAME:
            IntrIsbRecName(ref.rnam);
            break;
        case R_ELM_REC_EXPR:
            IntrIsbRecExpr();
            break;
        case R_ELM_COMOBJ_NAME:
            IntrIsbComObjName(ref.rnam);
            break;
        case R_ELM_COMOBJ_EXPR:
            IntrIsbComObjExpr();
            break;
        case R_INVALID:
        case R_ELMS_LIST:
        case R_FUNCCALL:
        case R_FUNCCALL_OPTS:
        default:
            SyntaxError(s, "Illegal operand for 'IsBound'");
        }
    }
}


/****************************************************************************
**
*/
static LHSRef ReadSelector(ScannerState * s, TypSymbolSet follow, UInt level)
{
    volatile LHSRef ref;

    ref.type = R_INVALID;

    // <Var> '[' <Expr> ']'  list selector
    if (s->Symbol == S_LBRACK) {
        Match(s, S_LBRACK, "[", follow);
        ReadExpr(s, S_COMMA | S_RBRACK | follow, 'r');
        ref.narg = 1;
        while (s->Symbol == S_COMMA) {
            Match(s, S_COMMA, ",", follow | S_RBRACK);
            ReadExpr(s, S_COMMA | S_RBRACK | follow, 'r');
            ref.narg++;
        }
        if (ref.narg > 2) {
            SyntaxError(s, "'[]' only supports 1 or 2 indices");
        }
        Match(s, S_RBRACK, "]", follow);
        ref.type = R_ELM_LIST;
        ref.level = level;
    }

    // <Var> '{' <Expr> '}'  sublist selector
    else if (s->Symbol == S_LBRACE) {
        Match(s, S_LBRACE, "{", follow);
        ReadExpr(s, S_RBRACE | follow, 'r');
        Match(s, S_RBRACE, "}", follow);
        ref.type = R_ELMS_LIST;
        ref.level = level;
    }

    // <Var> '![' <Expr> ']'  list selector
    else if (s->Symbol == S_BLBRACK) {
        Match(s, S_BLBRACK, "![", follow);
        ReadExpr(s, S_RBRACK | follow, 'r');
        Match(s, S_RBRACK, "]", follow);
        ref.type = R_ELM_POSOBJ;
    }

    // <Var> '.' <Ident>  record selector
    else if (s->Symbol == S_DOT) {
        Match(s, S_DOT, ".", follow);
        if (s->Symbol == S_IDENT || s->Symbol == S_INT) {
            ref.rnam = RNamName(s->Value);
            Match(s, s->Symbol, "identifier", follow);
            ref.type = R_ELM_REC_NAME;
        }
        else if (s->Symbol == S_LPAREN) {
            Match(s, S_LPAREN, "(", follow);
            ReadExpr(s, S_RPAREN | follow, 'r');
            Match(s, S_RPAREN, ")", follow);
            ref.type = R_ELM_REC_EXPR;
        }
        else {
            SyntaxError(s, "Record component name expected");
        }
    }

    // <Var> '!.' <Ident>  record selector
    else if (s->Symbol == S_BDOT) {
        Match(s, S_BDOT, "!.", follow);
        if (s->Symbol == S_IDENT || s->Symbol == S_INT) {
            ref.rnam = RNamName(s->Value);
            Match(s, s->Symbol, "identifier", follow);
            ref.type = R_ELM_COMOBJ_NAME;
        }
        else if (s->Symbol == S_LPAREN) {
            Match(s, S_LPAREN, "(", follow);
            ReadExpr(s, S_RPAREN | follow, 'r');
            Match(s, S_RPAREN, ")", follow);
            ref.type = R_ELM_COMOBJ_EXPR;
        }
        else {
            SyntaxError(s, "Record component name expected");
        }
    }

    // <Var> '(' [ <Expr> { ',' <Expr> } ] ')'  function call
    else if (s->Symbol == S_LPAREN) {
        Match(s, S_LPAREN, "(", follow);
        TRY_IF_NO_ERROR
        {
            IntrFuncCallBegin();
        }
        ref.narg = 0;
        if (s->Symbol != S_RPAREN && s->Symbol != S_COLON) {
            ReadExpr(s, S_RPAREN | follow, 'r');
            ref.narg++;
        }
        while (s->Symbol == S_COMMA) {
            Match(s, S_COMMA, ",", follow);
            ReadExpr(s, S_RPAREN | follow, 'r');
            ref.narg++;
        }
        ref.type = R_FUNCCALL;
        if (s->Symbol == S_COLON) {
            Match(s, S_COLON, ":", follow);
            if (s->Symbol != S_RPAREN) {    // save work for empty options
                ReadFuncCallOptions(s, S_RPAREN | follow);
                ref.type = R_FUNCCALL_OPTS;
            }
        }
        Match(s, S_RPAREN, ")", follow);
    }

    return ref;
}

static void ReadReferenceModifiers(ScannerState * s, TypSymbolSet follow)
{
    UInt level = 0;

    // read one or more selectors
    while (IS_IN(s->Symbol, S_LPAREN | S_LBRACK | S_LBRACE | S_DOT)) {
        LHSRef ref = ReadSelector(s, follow, level);
        level = EvalRef(ref, 1);
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
static LHSRef ReadVar(ScannerState * s, TypSymbolSet follow)
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
    if (s->Symbol != S_IDENT) {
        SyntaxError(s, "Identifier expected");
        return ref;
    }

    // try to look up the variable on the stack of local variables
    const UInt countNams = LEN_PLIST(ReaderState()->StackNams);
    for (nest = 0; nest < countNams; nest++) {
#ifndef SYS_IS_64_BIT
        if (nest >= MAX_FUNC_EXPR_NESTING) {
            Pr("Warning: abandoning search for %g at %dth higher frame\n",
               (Int)s->Value, MAX_FUNC_EXPR_NESTING);
            break;
        }
#endif
        nams = ELM_PLIST(ReaderState()->StackNams, countNams - nest);
        indx = findValueInNams(nams, s->Value, 1, LEN_PLIST(nams));
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
    while (ref.type == R_INVALID && lvars0 != 0 && lvars0 != STATE(BottomLVars)) {
        lvars = lvars0;
        nest = 0;
        while (ref.type == R_INVALID && lvars != 0 && lvars != STATE(BottomLVars)) {
            nams = NAMS_FUNC(FUNC_LVARS(lvars));
            if (nams != 0) {
                indx = findValueInNams(nams, s->Value, 1, LEN_PLIST(nams));
                if (indx) {
                    ref.type = R_DVAR;
                    ref.var = (nest << MAX_FUNC_LVARS_BITS) + indx;
                    ref.nest0 = nest0;
                    break;
                }
            }
            lvars = ENVI_FUNC(FUNC_LVARS(lvars));
            nest++;
#ifndef SYS_IS_64_BIT
            if (nest >= MAX_FUNC_EXPR_NESTING) {
                Pr("Warning: abandoning search for %g at %dth higher "
                   "frame\n",
                   (Int)s->Value, MAX_FUNC_EXPR_NESTING);
                break;
            }
#endif
        }
        lvars0 = PARENT_LVARS(lvars0);
        nest0++;
    }

    // get the variable as a global variable
    if (ref.type == R_INVALID) {
        ref.type = R_GVAR;
        // we do not want to call GVarName on this value until after we
        // have checked if this is the argument to a lambda function
        strlcpy(varname, s->Value, sizeof(varname));
    }

    // match away the identifier, now that we know the variable
    Match(s, S_IDENT, "identifier", follow);

    // If this isn't a lambda function, look up the name
    if (s->Symbol != S_MAPTO && ref.type == R_GVAR) {
        ref.var = GVarName(varname);
    }

    return ref;
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
static void ReadCallVarAss(ScannerState * s, TypSymbolSet follow, Char mode)
{
    volatile LHSRef ref = ReadVar(s, follow);
    if (ref.type == R_INVALID)
        return;

    // if this was actually the beginning of a function literal, then we are
    // in the wrong function
    if (s->Symbol == S_MAPTO) {
        if (mode == 'r' || mode == 'x')
            ReadFuncExprAbbrevSingle(s, follow);
        else
            SyntaxError(s, "Function literal in impossible context");
        return;
    }

    // Check if the variable is a constant
    if (ref.type == R_GVAR && IsConstantGVar(ref.var) && ValGVar(ref.var)) {
        // deal with references
        if (mode == 'r' || (mode == 'x' && s->Symbol != S_ASSIGN)) {
            Obj val = ValAutoGVar(ref.var);
            TRY_IF_NO_ERROR {
                if (val == True)
                    IntrTrueExpr();
                else if (val == False)
                    IntrFalseExpr();
                else if (IS_INTOBJ(val))
                    IntrIntObjExpr(val);
                else
                    SyntaxError(s, "Invalid constant variable");
            }
            return;
        }
    }


    /* check whether this is an unbound global variable                    */

    if (WarnOnUnboundGlobalsRNam == 0)
      WarnOnUnboundGlobalsRNam = RNamName("WarnOnUnboundGlobals");

    if ( ref.type == R_GVAR            // Reading a global variable
      && mode != 'i'                // Not inside 'IsBound'
      && LEN_PLIST(ReaderState()->StackNams) != 0   // Inside a function
      && ref.var != ReaderState()->CurrLHSGVar  // Not LHS of assignment
      && ValGVar(ref.var) == 0          // Not an existing global var
      && ExprGVar(ref.var) == 0         // Or an auto var
      && ! STATE(IntrIgnoring)      // Not currently ignoring parsed code
      && ! GlobalComesFromEnclosingForLoop(ref.var) // Not loop variable
      && (GAPInfo == 0 || !IS_REC(GAPInfo)
          || !ISB_REC(GAPInfo,WarnOnUnboundGlobalsRNam) // Warning enabled
          ||  ELM_REC(GAPInfo,WarnOnUnboundGlobalsRNam) != False )
      && ! SyCompilePlease )        // Not compiling
    {
        // Need to pass an offset, because we have already parsed more tokens
        SyntaxWarningWithOffset(s, "Unbound global variable", 2);
    }

    /* followed by one or more selectors                                   */
    while (IS_IN(s->Symbol, S_LPAREN | S_LBRACK | S_LBRACE | S_DOT)) {

        /* so the prefix was a reference                                   */
        UInt level = EvalRef(ref, 1);
        ref = ReadSelector(s, follow, level);
    }

    /* if we need a reference                                              */
    if (mode == 'r' || (mode == 'x' && s->Symbol != S_ASSIGN)) {
        Int needExpr = mode == 'r' || !IS_IN(s->Symbol, S_SEMICOLON);
        EvalRef(ref, needExpr);
    }

    /* if we need a statement                                              */
    else if (mode == 's' || (mode == 'x' && s->Symbol == S_ASSIGN)) {
        if (ref.type == R_FUNCCALL || ref.type == R_FUNCCALL_OPTS) {
            TRY_IF_NO_ERROR {
                IntrFuncCallEnd(0, ref.type == R_FUNCCALL_OPTS, ref.narg);
            }
        }
        else {
            Match(s, S_ASSIGN, ":=", follow);
            UInt currLHSGVar = ReaderState()->CurrLHSGVar;
            if ( LEN_PLIST(ReaderState()->StackNams) == 0 || !STATE(IntrCoding) ) {
                ReaderState()->CurrLHSGVar = (ref.type == R_GVAR ? ref.var : 0);
            }
            ReadExpr(s, follow, 'r');
            AssignRef(ref);
            ReaderState()->CurrLHSGVar = currLHSGVar;
        }
    }

    /*  if we need an unbind                                               */
    else if ( mode == 'u' ) {
        if (s->Symbol != S_RPAREN) {
            SyntaxError(s, "'Unbind': argument should be followed by ')'");
        }
        UnbindRef(s, ref);
    }


    /* if we need an isbound                                               */
    else /* if ( mode == 'i' ) */ {
        IsBoundRef(s, ref);
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
static void ReadIsBound(ScannerState * s, TypSymbolSet follow)
{
    Match(s, S_ISBOUND, "IsBound", follow);
    Match(s, S_LPAREN, "(", follow);
    ReadCallVarAss(s, S_RPAREN|follow, 'i');
    Match(s, S_RPAREN, ")", follow);
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
static void ReadPerm(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt       nrc;            /* number of cycles                */
    volatile UInt       nrx;            /* number of expressions in cycle  */

    /* read the first cycle (first expression has already been read)       */
    nrx = 1;
    while (s->Symbol == S_COMMA) {
        Match(s, S_COMMA, ",", follow);
        ReadExpr(s, S_COMMA|S_RPAREN|follow, 'r');
        nrx++;
    }
    Match(s, S_RPAREN, ")", follow);
    nrc = 1;
    TRY_IF_NO_ERROR { IntrPermCycle( nrx, nrc ); }

    /* read the remaining cycles                                           */
    while (s->Symbol == S_LPAREN) {
        Match(s, S_LPAREN, "(", follow);
        ReadExpr(s, S_COMMA|S_RPAREN|follow, 'r');
        nrx = 1;
        while (s->Symbol == S_COMMA) {
            Match(s, S_COMMA, ",", follow);
            ReadExpr(s, S_COMMA|S_RPAREN|follow, 'r');
            nrx++;
        }
        Match(s, S_RPAREN, ")", follow);
        nrc++;
        TRY_IF_NO_ERROR { IntrPermCycle( nrx, nrc ); }
    }

    /* that was the permutation                                            */
    TRY_IF_NO_ERROR { IntrPerm( nrc ); }
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
static void ReadListExpr(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt       pos;            /* actual position of element      */
    volatile UInt       nr;             /* number of elements              */
    volatile UInt       range;          /* is the list expression a range  */

    struct ReaderState * volatile rs = ReaderState();

    /* '['                                                                 */
    Match(s, S_LBRACK, "[", follow);
    rs->ReadTop++;
    if (rs->ReadTop == 1) {
        rs->ReadTilde = 0;
        STATE(Tilde) = 0;
    }
    TRY_IF_NO_ERROR { IntrListExprBegin( (rs->ReadTop == 1) ); }
    pos   = 1;
    nr    = 0;
    range = 0;

    /* [ <Expr> ]                                                          */
    if (s->Symbol != S_COMMA && s->Symbol != S_RBRACK) {
        TRY_IF_NO_ERROR { IntrListExprBeginElm( pos ); }
        ReadExpr(s, S_RBRACK|follow, 'r');
        TRY_IF_NO_ERROR { IntrListExprEndElm(); }
        nr++;
    }

    /* {',' [ <Expr> ] }                                                   */
    while (s->Symbol == S_COMMA) {
        Match(s, S_COMMA, ",", follow);
        pos++;
        if (s->Symbol != S_COMMA && s->Symbol != S_RBRACK) {
            TRY_IF_NO_ERROR { IntrListExprBeginElm( pos ); }
            ReadExpr(s, S_RBRACK|follow, 'r');
            TRY_IF_NO_ERROR { IntrListExprEndElm(); }
            nr++;
        }
    }

    /* incorrect place for three dots                                      */
    if (s->Symbol == S_DOTDOTDOT) {
        SyntaxError(s, "Only two dots in a range");
    }

    /* '..' <Expr> ']'                                                     */
    if (s->Symbol == S_DOTDOT) {
        if ( pos != nr ) {
            SyntaxError(s, "Must have no unbound entries in range");
        }
        if ( 2 < nr ) {
            SyntaxError(s, "Must have at most 2 entries before '..'");
        }
        range = 1;
        Match(s, S_DOTDOT, "..", follow);
        pos++;
        TRY_IF_NO_ERROR { IntrListExprBeginElm( pos ); }
        ReadExpr(s, S_RBRACK|follow, 'r');
        TRY_IF_NO_ERROR { IntrListExprEndElm(); }
        nr++;
        if (rs->ReadTop == 1 && rs->ReadTilde == 1) {
            SyntaxError(s, "Sorry, '~' not allowed in range");
        }
    }

    /* ']'                                                                 */
    Match(s, S_RBRACK, "]", follow);
    TRY_IF_NO_ERROR {
        IntrListExprEnd( nr, range, (rs->ReadTop == 1), (rs->ReadTilde == 1) );
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
static void ReadRecExpr(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt       rnam;           /* record component name           */
    volatile UInt       nr;             /* number of components            */

    struct ReaderState * volatile rs = ReaderState();

    /* 'rec('                                                              */
    Match(s, S_REC, "rec", follow);
    Match(s, S_LPAREN, "(", follow|S_RPAREN|S_COMMA);
    rs->ReadTop++;
    if ( rs->ReadTop == 1 ) {
        rs->ReadTilde = 0;
        STATE(Tilde) = 0;
    }
    TRY_IF_NO_ERROR { IntrRecExprBegin( (rs->ReadTop == 1) ); }
    nr = 0;

    /* [ <Ident> | '(' <Expr> ')' ':=' <Expr>                              */
    do {
      if (nr || s->Symbol == S_COMMA) {
        Match(s, S_COMMA, ",", follow);
      }
      if ( s->Symbol != S_RPAREN ) {
        if ( s->Symbol == S_INT ) {
          rnam = RNamName( s->Value );
          Match(s, S_INT, "integer", follow);
          TRY_IF_NO_ERROR { IntrRecExprBeginElmName( rnam ); }
        }
        else if ( s->Symbol == S_IDENT ) {
          rnam = RNamName( s->Value );
          Match(s, S_IDENT, "identifier", follow);
          TRY_IF_NO_ERROR { IntrRecExprBeginElmName( rnam ); }
        }
        else if ( s->Symbol == S_LPAREN ) {
          Match(s, S_LPAREN, "(", follow);
          ReadExpr(s, follow, 'r');
          Match(s, S_RPAREN, ")", follow);
          TRY_IF_NO_ERROR { IntrRecExprBeginElmExpr(); }
        }
        else {
          SyntaxError(s, "Identifier expected");
        }
        Match(s, S_ASSIGN, ":=", follow);
        ReadExpr(s, S_RPAREN|follow, 'r');
        TRY_IF_NO_ERROR { IntrRecExprEndElm(); }
        nr++;
      }

    } while (s->Symbol == S_COMMA);

    /* ')'                                                                 */
    Match(s, S_RPAREN, ")", follow);
    TRY_IF_NO_ERROR {
        IntrRecExprEnd( nr, (rs->ReadTop == 1), (rs->ReadTilde == 1) );
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
    UInt       isvarg;         /* does function have varargs?     */
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
**  symbol: The end symbol of the arglist (usually S_RBRACK, but S_RBRACE
**          for lambda functions).
**  symbolstr: symbol as an ascii string
**
**  This function assumes the opening bracket is already read, and is
**  responsible for reading the closing bracket.
*/

static ArgList ReadFuncArgList(ScannerState * s,
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
    UInt       isvarg = 0;     /* does function have varargs?     */

#ifdef HPCGAP
    if (is_atomic)
        locks = NEW_STRING(4);
#endif

    /* make and push the new local variables list (args and locals)        */
    narg = 0;
    nams = NEW_PLIST(T_PLIST, 0);
    if (s->Symbol != symbol) {
        goto start;
    }

    while (s->Symbol == S_COMMA) {
        if (isvarg) {
            SyntaxError(s, "Only final argument can be variadic");
        }

        Match(s, S_COMMA, ",", follow);
    start:
#ifdef HPCGAP
        lockqual = LOCK_QUAL_NONE;
#endif
        if (s->Symbol == S_READWRITE) {
            if (!is_atomic) {
                SyntaxError(s, "'readwrite' argument of non-atomic function");
            }
#ifdef HPCGAP
            else {
                lockqual = LOCK_QUAL_READWRITE;
            }
#endif
            Match(s, S_READWRITE, "readwrite", follow);
        }
        else if (s->Symbol == S_READONLY) {
            if (!is_atomic) {
                SyntaxError(s, "'readonly' argument of non-atomic function");
            }
#ifdef HPCGAP
            else {
                lockqual = LOCK_QUAL_READONLY;
            }
#endif
            Match(s, S_READONLY, "readonly", follow);
        }
        if (s->Symbol == S_IDENT && findValueInNams(nams, s->Value, 1, narg)) {
            SyntaxError(s, "Name used for two arguments");
        }
        narg += 1;
        PushPlist(nams, MakeImmString(s->Value));
#ifdef HPCGAP
        if (is_atomic) {
            GrowString(locks, narg);
            SET_LEN_STRING(locks, narg);
            CHARS_STRING(locks)[narg - 1] = lockqual;
        }
#endif
        if (LEN_PLIST(nams) >= MAX_FUNC_LVARS) {
            SyntaxError(s, "Too many function arguments");
        }
        Match(s, S_IDENT,"identifier",symbol|S_LOCAL|STATBEGIN|S_END|follow);
        if (s->Symbol == S_DOTDOT) {
            SyntaxError(s, "Three dots required for variadic argument list");
        }
        if (s->Symbol == S_DOTDOTDOT) {
            isvarg = 1;
            Match(s, S_DOTDOTDOT, "...", follow);
        }
    }
    Match(s, symbol, symbolstr, S_LOCAL|STATBEGIN|S_END|follow);

    // Special case for function(arg)
    if ( narg == 1 && ! strcmp( "arg", CONST_CSTR_STRING( ELM_PLIST(nams, narg) ) )) {
        isvarg = 1;
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


void StartFakeFuncExpr(Int startLine)
{
    assert(STATE(IntrCoding) == 0);

    // switch to coding mode now
    CodeBegin();

    // code a function expression (with no arguments and locals)
    Obj nams = NEW_PLIST(T_PLIST, 0);

    // If we are in the break loop, then a local variable context may well
    // exist, and we have to create an empty local variable names list to
    // match the function expression that we are creating.
    //
    // Without this, access to variables defined in the existing local
    // variable context will be coded as LVAR accesses; but when we then
    // execute this code, they will not actually be available in the current
    // context, but rather one level up, i.e., they really should have been
    // coded as HVARs.
    //
    // If we are not in a break loop, then this would be a waste of time and
    // effort
    if (LEN_PLIST(ReaderState()->StackNams) > 0) {
        PushPlist(ReaderState()->StackNams, nams);
    }

    CodeFuncExprBegin(0, 0, nams, startLine);
}


void FinishAndCallFakeFuncExpr(void)
{
    assert(STATE(IntrCoding) == 0);

    // code a function expression (with one statement in the body)
    CodeFuncExprEnd(1, 1);

    // switch back to immediate mode and get the function
    Obj func = CodeEnd(0);

    // If we are in a break loop, then we will have created a "dummy" local
    // variable names list to get the counts right. Remove it.
    const UInt len = LEN_PLIST(ReaderState()->StackNams);
    if (len > 0)
        PopPlist(ReaderState()->StackNams);

    // call the function
    CALL_0ARGS(func);

    // push void
    PushVoidObj();
}


static void ReadFuncExprBody(ScannerState * s,
                             TypSymbolSet   follow,
                             Int            isAbbrev,
                             Int            nloc,
                             ArgList        args,
                             Int            startLine)
{
    volatile UInt nr;           // number of statements
    volatile UInt nrError;      // copy of <STATE(NrError)>
    volatile Bag  currLVars;    // copy of <STATE(CurrLVars)>

    // remember the current variables in case of an error
    currLVars = STATE(CurrLVars);
    nrError = STATE(NrError);

    // push the new local variables list
    PushPlist(ReaderState()->StackNams, args.nams);

    // begin interpreting the function expression
    TRY_IF_NO_ERROR {
        IntrFuncExprBegin(args.isvarg ? -args.narg : args.narg, nloc,
                          args.nams, startLine);
    }

    if (isAbbrev) {
        // read the expression and turn it into a return-statement
        ReadExpr(s, follow, 'r');
        TRY_IF_NO_ERROR {
            IntrReturnObj();
        }
        nr = 1;
    }
    else {
#ifdef HPCGAP
        if (nrError == 0)
            SET_LCKS_FUNC(CURR_FUNC(), args.locks);
#endif
        // <Statements>
        UInt oldLoopNesting = ReaderState()->LoopNesting;
        ReaderState()->LoopNesting = 0;
        nr = ReadStats(s, S_END | follow);
        ReaderState()->LoopNesting = oldLoopNesting;
    }


    // end interpreting the function expression
    TRY_IF_NO_ERROR {
        IntrFuncExprEnd(nr);
    }
    CATCH_ERROR {
        // an error has occurred *after* the 'IntrFuncExprEnd'
        if (nrError == 0)
            IntrAbortCoding(currLVars);
    }

    // pop the new local variables list
    PopPlist(ReaderState()->StackNams);
}


/****************************************************************************
**
*F  ReadLocals( <follow> )
*/
static UInt ReadLocals(ScannerState * s, TypSymbolSet follow, Obj nams)
{
    UInt narg = LEN_PLIST(nams);
    UInt nloc = 0;

    Match(s, S_LOCAL, "local", follow);

    while (1) {
        if (s->Symbol == S_IDENT) {
            if (findValueInNams(nams, s->Value, narg + 1, narg + nloc)) {
                SyntaxError(s, "Name used for two locals");
            }
            if (findValueInNams(nams, s->Value, 1, narg)) {
                SyntaxError(s, "Name used for argument and local");
            }
            nloc += 1;
            PushPlist(nams, MakeImmString(s->Value));
            if (LEN_PLIST(nams) >= 65536) {
                SyntaxError(s, "Too many function arguments and locals");
            }
        }
        Match(s, S_IDENT, "identifier", STATBEGIN | S_END | follow);

        if (s->Symbol != S_COMMA)
            break;

        // init to avoid strange message in case of empty string
        s->Value[0] = '\0';
        Match(s, S_COMMA, ",", follow);
    }
    MatchSemicolon(s, STATBEGIN | S_END | follow);

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
static void ReadFuncExpr(ScannerState * s, TypSymbolSet follow, Char mode)
{
    Int     startLine;        // line number of function keyword
    int     is_atomic = 0;    // is this an atomic function?
    UInt    nloc = 0;         // number of locals
    ArgList args;

    /* begin the function               */
    startLine = GetInputLineNumber();
    if (s->Symbol == S_ATOMIC) {
        Match(s, S_ATOMIC, "atomic", follow);
        is_atomic = 1;
    } else if (mode == 'a') {
        // in this case the atomic keyword was matched away by ReadAtomic
        // before we realised we were reading an atomic function
        is_atomic = 1;
    }
    Match(s, S_FUNCTION, "function", follow);
    Match(s, S_LPAREN, "(", S_IDENT|S_RPAREN|S_LOCAL|STATBEGIN|S_END|follow);

    args = ReadFuncArgList(s, follow, is_atomic, S_RPAREN, ")");

    if (s->Symbol == S_LOCAL) {
        nloc = ReadLocals(s, follow, args.nams);
    }

    ReadFuncExprBody(s, follow, 0, nloc, args, startLine);

    /* 'end'                                                               */
    Match(s, S_END, "while parsing a function: statement or 'end'", follow);
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
static void ReadFuncExprAbbrevMulti(ScannerState * s, TypSymbolSet follow)
{
    Match(s, S_LBRACE, "{", follow);

    ArgList args = ReadFuncArgList(s, follow, 0, S_RBRACE, ")");

    /* match away the '->'                                                 */
    Match(s, S_MAPTO, "->", follow);

    ReadFuncExprBody(s, follow, 1, 0, args, GetInputLineNumber());
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
static void ReadFuncExprAbbrevSingle(ScannerState * s, TypSymbolSet follow)
{
    /* make and push the new local variables list                          */
    Obj nams = NEW_PLIST(T_PLIST, 1);
    PushPlist(nams, MakeImmString(s->Value));

    ArgList args;
    args.narg = 1;
    args.nams = nams;
    args.isvarg = 0;
#ifdef HPCGAP
    args.locks = 0;
#endif

    /* match away the '->'                                                 */
    Match(s, S_MAPTO, "->", follow);

    ReadFuncExprBody(s, follow, 1, 0, args, GetInputLineNumber());
}

/****************************************************************************
**
*F  ReadLiteral( <follow>, <mode> ) . . . . . . . . . . . . . .  read an atom
**
**  'ReadLiteral' reads a  literal expression.  In  case of an error it skips
**  all symbols up to one contained in <follow>.
**
**  <Literal> := <Int>
**            |  'true'
**            |  'false'
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
static void ReadLiteral(ScannerState * s, TypSymbolSet follow, Char mode)
{
    if (s->Symbol == S_DOT) {
        // HACK: The only way a dot could turn up here is in a floating point
        // literal that starts with '.'. Call back to the scanner to deal
        // with this.
        ScanForFloatAfterDotHACK(s);
    }

    switch (s->Symbol) {

    /* <Int>                                                               */
    case S_INT:
        TRY_IF_NO_ERROR { IntrIntExpr(s->ValueObj, s->Value); }
        Match(s, S_INT, "integer", follow);
        break;

    /* <Float> */
    case S_FLOAT:
        TRY_IF_NO_ERROR { IntrFloatExpr(s->ValueObj, s->Value); }
        Match(s, S_FLOAT, "float", follow);
        break;

    /* 'true'                                                              */
    case S_TRUE:
        Match(s, S_TRUE, "true", follow);
        IntrTrueExpr();
        break;

    /* 'false'                                                             */
    case S_FALSE:
        Match(s, S_FALSE, "false", follow);
        IntrFalseExpr();
        break;

    /* '~'                                                                 */
    case S_TILDE:
        if (ReaderState()->ReadTop == 0) {
            SyntaxError(s, "'~' not allowed here");
        }
        ReaderState()->ReadTilde = 1;
        TRY_IF_NO_ERROR { IntrTildeExpr(); }
        Match(s, S_TILDE, "~", follow);
        break;

    /* <Char>                                                              */
    case S_CHAR:
        TRY_IF_NO_ERROR { IntrCharExpr( s->Value[0] ); }
        Match(s, S_CHAR, "character", follow);
        break;

    /* string */
    case S_STRING:
        GAP_ASSERT(s->ValueObj != 0);
        TRY_IF_NO_ERROR { IntrStringExpr(s->ValueObj); }
        Match(s, S_STRING, "", follow);
        s->ValueObj = 0;
        break;

    /* <List>                                                              */
    case S_LBRACK:
        ReadListExpr(s, follow);
        break;

    /* <Rec>                                                               */
    case S_REC:
        ReadRecExpr(s, follow);
        break;

    /* <Function>                                                          */
    case S_FUNCTION:
    case S_ATOMIC:
        ReadFuncExpr(s, follow, mode);
        break;

    case S_LBRACE:
        ReadFuncExprAbbrevMulti(s, follow);
        break;

    /* signal an error, we want to see a literal                           */
    default:
        Match(s, S_INT, "literal", follow);
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

static void ReadAtom(ScannerState * s, TypSymbolSet follow, Char mode)
{
    /* read a variable                                                     */
    if (s->Symbol == S_IDENT) {
        ReadCallVarAss(s, follow, mode);
    }

    /* 'IsBound' '(' <Var> ')'                                             */
    else if (s->Symbol == S_ISBOUND) {
        ReadIsBound(s, follow);
    }
    /* otherwise read a literal expression                                 */
    else if (IS_IN(s->Symbol, LiteralExprStateMask)) {
        ReadLiteral(s, follow, mode);
    }

    /* '(' <Expr> ')'                                                      */
    else if (s->Symbol == S_LPAREN) {
        Match(s, S_LPAREN, "(", follow);
        if (s->Symbol == S_RPAREN) {
            Match(s, S_RPAREN, ")", follow);
            TRY_IF_NO_ERROR { IntrPerm( 0UL ); }
            return;
        }
        ReadExpr(s, S_RPAREN|follow, 'r');
        if (s->Symbol == S_COMMA) {
            ReadPerm(s, follow);
            return;
        }
        Match(s, S_RPAREN, ")", follow);
    }

    /* otherwise signal an error                                           */
    else {
        Match(s, S_INT, "expression", follow);
    }

    ReadReferenceModifiers(s, follow);
}

/****************************************************************************
**
*F  ReadSign( <follow> )  . . . . . . . . . . . . . . read a sign, or nothing
*/
static Int ReadSign(ScannerState * s, TypSymbolSet follow)
{
    if (s->Symbol == S_PLUS) {
        Match(s, S_PLUS, "unary +", follow);
        return +1;
    }
    if (s->Symbol == S_MINUS) {
        Match(s, S_MINUS, "unary -", follow);
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
static void ReadFactor(ScannerState * s, TypSymbolSet follow, Char mode)
{
    volatile Int        sign1;
    volatile Int        sign2;

    /* { '+'|'-' }  leading sign                                           */
    sign1 = ReadSign(s, follow);

    /* <Atom>                                                              */
    ReadAtom(s, follow, (sign1 == 0 ? mode : 'r'));

    /* ['^' <Atom> ] implemented as {'^' <Atom> } for better error message */
    while (s->Symbol == S_POW) {

        /* match the '^' away                                              */
        Match(s, S_POW, "^", follow);

        /* { '+'|'-' }  leading sign                                       */
        sign2 = ReadSign(s, follow);

        /* ['^' <Atom>]                                                    */
        ReadAtom(s, follow, 'r');

        /* interpret the unary minus                                       */
        if ( sign2 == -1 ) {
            TRY_IF_NO_ERROR { IntrAInv(); }
        }

        /* interpret the power                                             */
        TRY_IF_NO_ERROR { IntrPow(); }

        /* check for multiple '^'                                          */
        if (s->Symbol == S_POW) {
            SyntaxError(s, "'^' is not associative");
        }
    }

    /* interpret the unary minus                                           */
    if ( sign1 == -1 ) {
        TRY_IF_NO_ERROR { IntrAInv(); }
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
static void ReadTerm(ScannerState * s, TypSymbolSet follow, Char mode)
{
    volatile UInt       symbol;

    /* <Factor>                                                            */
    ReadFactor(s, follow, mode);

    /* { '*'|'/'|'mod' <Factor> }                                          */
    /* do not use 'IS_IN', since 'IS_IN(S_POW,S_MULT|S_DIV|S_MOD)' is true */
    while (s->Symbol == S_MULT ||
           s->Symbol == S_DIV || s->Symbol == S_MOD) {
        symbol = s->Symbol;
        Match(s, s->Symbol, "*, /, or mod", follow);
        ReadFactor(s, follow, 'r');
        TRY_IF_NO_ERROR {
            if      ( symbol == S_MULT ) { IntrProd(); }
            else if ( symbol == S_DIV  ) { IntrQuo();  }
            else if ( symbol == S_MOD  ) { IntrMod();  }
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
static void ReadAri(ScannerState * s, TypSymbolSet follow, Char mode)
{
    UInt                symbol;

    /* <Term>                                                              */
    ReadTerm(s, follow, mode);

    /* { '+'|'-' <Term> }                                                  */
    while (IS_IN(s->Symbol, S_PLUS | S_MINUS)) {
        symbol = s->Symbol;
        Match(s, s->Symbol, "+ or -", follow);
        ReadTerm(s, follow, 'r');
        TRY_IF_NO_ERROR {
            if      ( symbol == S_PLUS  ) { IntrSum();  }
            else if ( symbol == S_MINUS ) { IntrDiff(); }
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
static void ReadRel(ScannerState * s, TypSymbolSet follow, Char mode)
{
    volatile UInt       symbol;
    volatile UInt       isNot;

    /* { 'not' }                                                           */
    isNot = 0;
    while (s->Symbol == S_NOT) {
        isNot++;
        Match(s, S_NOT, "not", follow);
    }

    /* <Arith>                                                             */
    ReadAri(s, follow, (isNot == 0 ? mode : 'r'));

    /* { '=|<>|<|>|<=|>=|in' <Arith> }                                     */
    if (IS_IN(s->Symbol, S_EQ | S_LT | S_GT | S_NE | S_LE | S_GE | S_IN)) {
        symbol = s->Symbol;
        Match(s, s->Symbol, "comparison operator", follow);
        ReadAri(s, follow, 'r');
        TRY_IF_NO_ERROR {
            if      ( symbol == S_EQ ) { IntrEq(); }
            else if ( symbol == S_NE ) { IntrNe(); }
            else if ( symbol == S_LT ) { IntrLt(); }
            else if ( symbol == S_GE ) { IntrGe(); }
            else if ( symbol == S_GT ) { IntrGt(); }
            else if ( symbol == S_LE ) { IntrLe(); }
            else if ( symbol == S_IN ) { IntrIn(); }
        }
    }

    /* interpret the not                                                   */
    if ( (isNot % 2) != 0 ) {
        TRY_IF_NO_ERROR { IntrNot(); }
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
static void ReadAnd(ScannerState * s, TypSymbolSet follow, Char mode)
{
    /* <Rel>                                                               */
    ReadRel(s, follow, mode);

    /* { 'and' <Rel> }                                                     */
    while (s->Symbol == S_AND) {
        Match(s, S_AND, "and", follow);
        TRY_IF_NO_ERROR { IntrAndL(); }
        ReadRel(s, follow, 'r');
        TRY_IF_NO_ERROR { IntrAnd(); }
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
ReadQualifiedExpr(ScannerState * s, TypSymbolSet follow, Char mode)
{
  volatile UInt access  = 0;
  if (s->Symbol == S_READWRITE) 
    {
      Match(s, S_READWRITE, "readwrite", follow | EXPRBEGIN);
      access = 2;
    }
  else if (s->Symbol == S_READONLY) 
    {
      Match(s, S_READONLY, "readonly", follow | EXPRBEGIN);
      access = 1;
    }
  TRY_IF_NO_ERROR { IntrQualifiedExprBegin(access); }
  ReadExpr(s, follow,mode);
  TRY_IF_NO_ERROR { IntrQualifiedExprEnd(); }
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
static void ReadExpr(ScannerState * s, TypSymbolSet follow, Char mode)
{
    /* <And>                                                               */
    ReadAnd(s, follow, mode);

    /* { 'or' <And> }                                                      */
    while (s->Symbol == S_OR) {
        Match(s, S_OR, "or", follow);
        TRY_IF_NO_ERROR { IntrOrL(); }
        ReadAnd(s, follow, 'r');
        TRY_IF_NO_ERROR { IntrOr(); }
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
static void ReadUnbind(ScannerState * s, TypSymbolSet follow)
{
    Match(s, S_UNBIND, "Unbind", follow);
    Match(s, S_LPAREN, "(", follow);
    ReadCallVarAss(s, S_RPAREN|follow, 'u');
    Match(s, S_RPAREN, ")", follow);
}


/****************************************************************************
**
*F  ReadEmpty( <follow> )  . . . . . . . . . . . . . .read an empty statement
**
**  'ReadEmpty' reads  an empty statement.  The argument is actually ignored
**
**  <Statement> :=  ';'
*/
static void ReadEmpty(ScannerState * s, TypSymbolSet follow)
{
  IntrEmpty();
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
static void ReadInfo(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt narg;     // number of arguments to print (or not)

    TRY_IF_NO_ERROR { IntrInfoBegin(); }
    Match(s, S_INFO, "Info", follow);
    Match(s, S_LPAREN, "(", follow);
    ReadExpr(s, S_RPAREN | S_COMMA | follow, 'r');
    Match(s, S_COMMA, ",", S_RPAREN|follow);
    ReadExpr(s, S_RPAREN | S_COMMA | follow, 'r');
    TRY_IF_NO_ERROR { IntrInfoMiddle(); }
    narg = 0;
    while (s->Symbol == S_COMMA) {
        narg++;
        Match(s, S_COMMA, "", 0L);
        ReadExpr(s, S_RPAREN | S_COMMA | follow, 'r');
    }
    Match(s, S_RPAREN, ")", follow);
    TRY_IF_NO_ERROR { IntrInfoEnd(narg); }
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
static void ReadAssert(ScannerState * s, TypSymbolSet follow)
{
    TRY_IF_NO_ERROR { IntrAssertBegin(); }
    Match(s, S_ASSERT, "Assert", follow);
    Match(s, S_LPAREN, "(", follow);
    ReadExpr(s, S_RPAREN | S_COMMA | follow, 'r');
    TRY_IF_NO_ERROR { IntrAssertAfterLevel(); }
    Match(s, S_COMMA, ",", S_RPAREN|follow);
    ReadExpr(s, S_RPAREN | S_COMMA | follow, 'r');
    TRY_IF_NO_ERROR { IntrAssertAfterCondition(); }
    if (s->Symbol == S_COMMA) {
        Match(s, S_COMMA, "", 0L);
        ReadExpr(s, S_RPAREN |  follow, 'r');
        Match(s, S_RPAREN, ")", follow);
        TRY_IF_NO_ERROR { IntrAssertEnd3Args(); }
      }
    else
      {
        Match(s, S_RPAREN, ")", follow);
        TRY_IF_NO_ERROR { IntrAssertEnd2Args(); }
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
static void ReadIf(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt       nrb;            /* number of branches              */
    volatile UInt       nrs;            /* number of statements in a body  */

    /* 'if' <Expr> 'then' <Statements>                                     */
    nrb = 0;
    TRY_IF_NO_ERROR { IntrIfBegin(); }
    Match(s, S_IF, "if", follow);
    ReadExpr(s, S_THEN|S_ELIF|S_ELSE|S_FI|follow, 'r');
    Match(s, S_THEN, "then", STATBEGIN|S_ELIF|S_ELSE|S_FI|follow);
    TRY_IF_NO_ERROR { IntrIfBeginBody(); }
    nrs = ReadStats(s, S_ELIF|S_ELSE|S_FI|follow);
    TRY_IF_NO_ERROR { nrb += IntrIfEndBody( nrs ); }

    /* { 'elif' <Expr> 'then' <Statements> }                               */
    while (s->Symbol == S_ELIF) {
        TRY_IF_NO_ERROR { IntrIfElif(); }
        Match(s, S_ELIF, "elif", follow);
        ReadExpr(s, S_THEN|S_ELIF|S_ELSE|S_FI|follow, 'r');
        Match(s, S_THEN, "then", STATBEGIN|S_ELIF|S_ELSE|S_FI|follow);
        TRY_IF_NO_ERROR { IntrIfBeginBody(); }
        nrs = ReadStats(s, S_ELIF|S_ELSE|S_FI|follow);
        TRY_IF_NO_ERROR { nrb += IntrIfEndBody( nrs ); }
    }

    /* [ 'else' <Statements> ]                                             */
    if (s->Symbol == S_ELSE) {
        TRY_IF_NO_ERROR { IntrIfElse(); }
        Match(s, S_ELSE, "else", follow);
        TRY_IF_NO_ERROR { IntrIfBeginBody(); }
        nrs = ReadStats(s, S_FI|follow);
        TRY_IF_NO_ERROR { nrb += IntrIfEndBody( nrs ); }
    }

    /* 'fi'                                                                */
    Match(s, S_FI, "while parsing an 'if' statement: statement or 'fi'", follow);
    TRY_IF_NO_ERROR { IntrIfEnd( nrb ); }
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


static void ReadFor(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt       nrs;            /* number of statements in body    */
    volatile UInt       nrError;        /* copy of <STATE(NrError)>        */
    volatile Bag        currLVars;      /* copy of <STATE(CurrLVars)>      */

    /* remember the current variables in case of an error                  */
    currLVars = STATE(CurrLVars);
    nrError   = STATE(NrError);

    /* 'for'                                                               */
    TRY_IF_NO_ERROR { IntrForBegin(); }
    Match(s, S_FOR, "for", follow);

    /* <Var>                                                               */
    ReadCallVarAss(s, follow, 'r');

    /* 'in' <Expr>                                                         */
    Match(s, S_IN, "in", S_DO|S_OD|follow);
    TRY_IF_NO_ERROR { IntrForIn(); }
    ReadExpr(s, S_DO|S_OD|follow, 'r');

    /* 'do' <Statements>                                                   */
    Match(s, S_DO, "do", STATBEGIN|S_OD|follow);
    ReaderState()->LoopNesting++;
    TRY_IF_NO_ERROR { IntrForBeginBody(); }
    nrs = ReadStats(s, S_OD|follow);
    TRY_IF_NO_ERROR { IntrForEndBody( nrs ); }
    ReaderState()->LoopNesting--;

    /* 'od'                                                                */
    Match(s, S_OD, "while parsing a 'for' loop: statement or 'od'", follow);
    TRY_IF_NO_ERROR {
        IntrForEnd();
    }
    CATCH_ERROR {
        /* an error has occurred *after* the 'IntrForBegin'                */
        /* If we hadn't actually come out of coding the body, we need
           to recover. Otherwise it was probably an error in executing the
           body and we just return */
        if (nrError == 0)
            IntrAbortCoding(currLVars);
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
static void ReadWhile(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt       nrs;            /* number of statements in body    */
    volatile UInt       nrError;        /* copy of <STATE(NrError)>        */
    volatile Bag        currLVars;      /* copy of <STATE(CurrLVars)>      */

    /* remember the current variables in case of an error                  */
    currLVars = STATE(CurrLVars);
    nrError   = STATE(NrError);

    /* 'while' <Expr>  'do'                                                */
    TRY_IF_NO_ERROR { IntrWhileBegin(); }
    Match(s, S_WHILE, "while", follow);
    ReadExpr(s, S_DO|S_OD|follow, 'r');
    Match(s, S_DO, "do", STATBEGIN|S_DO|follow);

    //     <Statements>
    ReaderState()->LoopNesting++;
    TRY_IF_NO_ERROR { IntrWhileBeginBody(); }
    nrs = ReadStats(s, S_OD|follow);
    TRY_IF_NO_ERROR { IntrWhileEndBody( nrs ); }
    ReaderState()->LoopNesting--;

    /* 'od'                                                                */
    Match(s, S_OD, "while parsing a 'while' loop: statement or 'od'", follow);
    TRY_IF_NO_ERROR {
        IntrWhileEnd();
    }
    CATCH_ERROR {
        /* an error has occurred *after* the 'IntrWhileBegin'              */
        /* If we hadn't actually come out of coding the body, we need
           to recover. Otherwise it was probably an error in executing the
           body and we just return */
        if (nrError == 0)
            IntrAbortCoding(currLVars);
    }
}

/****************************************************************************
**
*F  ReadAtomic( <follow> ) . . . . . . . . . . . . . .  read an atomic block
**
**  'ReadAtomic' reads an atomic block. In case of an error it skips all
**  symbols up to one contained in <follow>.
**
**  <Statement> := 'atomic' <QualifiedExpression> { ',' <QualifiedExpression } 'do' <Statements> 'od' ';'
**
**  These functions only do something meaningful inside HPC-GAP; in plain GAP,
**  they are simply placeholders.
*/
static void ReadAtomic(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt       nrs;            /* number of statements in body    */
    volatile UInt       nexprs;         /* number of statements in body    */
    volatile UInt       nrError;        /* copy of <STATE(NrError)>        */
    volatile Bag        currLVars;      /* copy of <STATE(CurrLVars)>      */
#ifdef HPCGAP
    volatile int        lockSP;         /* lock stack */
#endif

    /* remember the current variables in case of an error                  */
    currLVars = STATE(CurrLVars);
    nrError   = STATE(NrError);
#ifdef HPCGAP
    lockSP    = RegionLockSP();
#endif

    Match(s, S_ATOMIC, "atomic", follow);
    /* Might just be an atomic function literal as an expression */
    if (s->Symbol == S_FUNCTION) {
        ReadExpr(s, follow, 'a');
        return;
    }

    /* 'atomic' <QualifiedExpression> {',' <QualifiedExpression> } 'do'    */
    TRY_IF_NO_ERROR { IntrAtomicBegin(); }

    ReadQualifiedExpr(s, S_DO|S_OD|follow, 'r');
    nexprs = 1;
    while (s->Symbol == S_COMMA) {
      Match(s, S_COMMA, ",", follow | S_DO | S_OD);
      ReadQualifiedExpr(s, S_DO|S_OD|follow, 'r');
      nexprs ++;
#ifdef HPCGAP
      if (nexprs > MAX_ATOMIC_OBJS) {
        SyntaxError(s, "'atomic' statement can have at most 256 objects to lock");
        return;
      }
#endif
    }

    Match(s, S_DO, "do", STATBEGIN|S_DO|follow);

    //     <Statements>
    TRY_IF_NO_ERROR { IntrAtomicBeginBody(nexprs); }
    nrs = ReadStats(s, S_OD|follow);
    TRY_IF_NO_ERROR { IntrAtomicEndBody( nrs ); }

    /* 'od'                                                                */
    Match(s, S_OD, "while parsing an atomic block: statement or 'od'", follow);
    TRY_IF_NO_ERROR {
        IntrAtomicEnd();
    }
    CATCH_ERROR {
        /* an error has occurred *after* the 'IntrAtomicBegin'             */
        /* If we hadn't actually come out of coding the body, we need
           to recover. Otherwise it was probably an error in executing the
           body and we just return */
        if (nrError == 0)
            IntrAbortCoding(currLVars);
    }
#ifdef HPCGAP
    /* This is a no-op if IntrAtomicEnd() succeeded, otherwise it restores
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
static void ReadRepeat(ScannerState * s, TypSymbolSet follow)
{
    volatile UInt       nrs;            /* number of statements in body    */
    volatile UInt       nrError;        /* copy of <STATE(NrError)>        */
    volatile Bag        currLVars;      /* copy of <STATE(CurrLVars)>      */

    /* remember the current variables in case of an error                  */
    currLVars = STATE(CurrLVars);
    nrError   = STATE(NrError);

    /* 'repeat'                                                            */
    TRY_IF_NO_ERROR { IntrRepeatBegin(); }
    Match(s, S_REPEAT, "repeat", follow);

    //  <Statements>
    ReaderState()->LoopNesting++;
    TRY_IF_NO_ERROR { IntrRepeatBeginBody(); }
    nrs = ReadStats(s, S_UNTIL|follow);
    TRY_IF_NO_ERROR { IntrRepeatEndBody( nrs ); }
    ReaderState()->LoopNesting--;

    /* 'until' <Expr>                                                      */
    Match(s, S_UNTIL, "while parsing a 'repeat' loop: statement or 'until'", EXPRBEGIN|follow);
    ReadExpr(s, follow, 'r');
    TRY_IF_NO_ERROR {
        IntrRepeatEnd();
    }
    CATCH_ERROR {
        /* an error has occurred *after* the 'IntrRepeatBegin'             */
        /* If we hadn't actually come out of coding the body, we need
           to recover. Otherwise it was probably an error in executing the
           body and we just return */
        if (nrError == 0)
            IntrAbortCoding(currLVars);
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
static void ReadBreak(ScannerState * s, TypSymbolSet follow)
{
    if (!ReaderState()->LoopNesting)
        SyntaxError(s, "'break' statement not enclosed in a loop");

    /* skip the break symbol                                               */
    Match(s, S_BREAK, "break", follow);

    /* interpret the break statement                                       */
    TRY_IF_NO_ERROR { IntrBreak(); }
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
static void ReadContinue(ScannerState * s, TypSymbolSet follow)
{
    if (!ReaderState()->LoopNesting)
        SyntaxError(s, "'continue' statement not enclosed in a loop");

    // skip the continue symbol
    Match(s, S_CONTINUE, "continue", follow);

    // interpret the continue statement
    TRY_IF_NO_ERROR { IntrContinue(); }
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
static void ReadReturn(ScannerState * s, TypSymbolSet follow)
{
    /* skip the return symbol                                              */
    Match(s, S_RETURN, "return", follow);

    /* 'return' with no expression following                               */
    if (IS_IN(s->Symbol, S_SEMICOLON)) {
        TRY_IF_NO_ERROR { IntrReturnVoid(); }
    }

    /* 'return' with an expression following                               */
    else {
        ReadExpr(s, follow, 'r');
        TRY_IF_NO_ERROR { IntrReturnObj(); }
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
static void ReadTryNext(ScannerState * s, TypSymbolSet follow)
{
    Match(s, S_TRYNEXT, "TryNextMethod", follow);
    Match(s, S_LPAREN, "(", follow);
    Match(s, S_RPAREN, ")", follow);
    TRY_IF_NO_ERROR {
        IntrRefGVar( GVarName( "TRY_NEXT_METHOD" ) );
        IntrReturnObj();
    }
}

static void ReadHelp(ScannerState * s, TypSymbolSet follow)
{
    TRY_IF_NO_ERROR { IntrHelp(s->ValueObj); }
    s->ValueObj = 0;
}

static void ReadPragma(ScannerState * s, TypSymbolSet follow)
{
    TRY_IF_NO_ERROR { IntrPragma(s->ValueObj); }
    s->ValueObj = 0;
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
static void ReadQuit(ScannerState * s, TypSymbolSet follow)
{
    /* skip the quit symbol                                                */
    Match(s, S_QUIT, "quit", follow);

    /* interpret the quit                                                  */
    TRY_IF_NO_ERROR { IntrQuit(); }
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
static void ReadQUIT(ScannerState * s, TypSymbolSet follow)
{
    /* skip the quit symbol                                                */
    Match(s, S_QQUIT, "QUIT", follow);

    /* interpret the quit                                                  */
    TRY_IF_NO_ERROR { IntrQUIT(); }
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
**              |  'return' [ <Expr> ] ';'
**              |  'atomic' <QualifiedExpression> { ',' <QualifiedExpression> } 'do' <Statements> 'od' ';'
**              |  ';'
*/
static Int TryReadStatement(ScannerState * s, TypSymbolSet follow)
{
    switch (s->Symbol) {
    case S_IDENT:     ReadCallVarAss(s, follow,'s'); break;
    case S_UNBIND:    ReadUnbind(s,     follow    ); break;
    case S_INFO:      ReadInfo(s,       follow    ); break;
    case S_ASSERT:    ReadAssert(s,     follow    ); break;
    case S_IF:        ReadIf(s,         follow    ); break;
    case S_FOR:       ReadFor(s,        follow    ); break;
    case S_WHILE:     ReadWhile(s,      follow    ); break;
    case S_REPEAT:    ReadRepeat(s,     follow    ); break;
    case S_BREAK:     ReadBreak(s,      follow    ); break;
    case S_CONTINUE:  ReadContinue(s,   follow    ); break;
    case S_RETURN:    ReadReturn(s,     follow    ); break;
    case S_TRYNEXT:   ReadTryNext(s,    follow    ); break;
    case S_ATOMIC:    ReadAtomic(s,     follow    ); break;
    case S_SEMICOLON: ReadEmpty(s,      follow    ); break;
    case S_PRAGMA:    ReadPragma(s,     follow    ); break;
    case S_QUIT:      SyntaxError(s, "'quit;' cannot be used in this context"); break;
    case S_QQUIT:     SyntaxError(s, "'QUIT;' cannot be used in this context"); break;
    case S_HELP:      SyntaxError(s, "'?' cannot be used in this context"); break;
    default:         return 0;
    }
    return 1;
}

static UInt ReadStats(ScannerState * s, TypSymbolSet follow)
{
    UInt nr = 0;    // number of statements

    // read the statements
    while (IS_IN(s->Symbol, STATBEGIN | S_SEMICOLON)) {
        if (!TryReadStatement(s, follow)) {
            SyntaxError(s, "statement expected");
        }
        nr++;
        if (s->Symbol == S_PRAGMA)
            Match(s, S_PRAGMA, "", 0);
        else
            MatchSemicolon(s, follow);
    }

    // return the number of statements
    return nr;
}


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
**  read the  first symbol of the  next  input.
**
*/

static void RecreateStackNams( Obj context )
{
    Obj stackNams = ReaderState()->StackNams;
    Obj lvars = context;
    while (lvars != STATE(BottomLVars) && lvars != (Obj)0)  {
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

ExecStatus ReadEvalCommand(Obj context, Obj *evalResult, UInt *dualSemicolon)
{
    volatile ExecStatus          type;
    volatile Obj                 stackNams;
    volatile UInt                readTop;
    volatile UInt                readTilde;
    volatile Obj                 tilde;
    volatile UInt                currLHSGVar;
    volatile Obj                 errorLVars;
    syJmp_buf           readJmpError;
#ifdef HPCGAP
    int                 lockSP;
#endif

    struct ReaderState * volatile rs = ReaderState();
    ScannerState * volatile       s = &STATE(Scanner);

    /* get the first symbol from the input                                 */
    Match(s, s->Symbol, "", 0UL);

    // if scanning the first symbol produced a syntax error, abort
    if (STATE(NrError)) {
        FlushRestOfInputLine();
        return STATUS_ERROR;
    }

    /* if we have hit <end-of-file>, then give up                          */
    if (s->Symbol == S_EOF) {
        return STATUS_EOF;
    }

    /* print only a partial prompt from now on                             */
    STATE(Prompt) = SyQuiet ? "" : "> ";

    /* remember the old reader context                                     */
    stackNams   = rs->StackNams;
    readTop     = rs->ReadTop;
    readTilde   = rs->ReadTilde;
    tilde       = STATE(Tilde);
    currLHSGVar = rs->CurrLHSGVar;
    errorLVars  = STATE(ErrorLVars);
    memcpy( readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf) );

    // initialize everything and begin an interpreter
    rs->StackNams      = NEW_PLIST( T_PLIST, 16 );
    rs->ReadTop        = 0;
    rs->ReadTilde      = 0;
    STATE(Tilde)       = 0;
    rs->CurrLHSGVar    = 0;
    STATE(ErrorLVars)  = context;
    RecreateStackNams(context);
#ifdef HPCGAP
    lockSP = RegionLockSP();
#endif

    AssGVar(GVarName("READEVALCOMMAND_LINENUMBER"), INTOBJ_INT(GetInputLineNumber()));

    GAP_ASSERT(rs->LoopNesting == 0);

    IntrBegin( context );

    switch (s->Symbol) {
    /* read an expression or an assignment or a procedure call             */
    case S_IDENT:     ReadExpr(s,    S_SEMICOLON|S_EOF, 'x' ); break;

    // otherwise read a statement -- first handle some which are different on
    // the top level than inside a function, if/else or loop
    case S_QUIT:      ReadQuit(s,    S_SEMICOLON|S_EOF      ); break;
    case S_QQUIT:     ReadQUIT(s,    S_SEMICOLON|S_EOF      ); break;
    case S_HELP:      ReadHelp(s,    S_SEMICOLON|S_EOF      ); break;
    case S_PRAGMA:    ReadPragma(s,  S_SEMICOLON|S_EOF      ); break;

    // otherwise try to read a generic statement
    default:
        if (!TryReadStatement(s, S_SEMICOLON | S_EOF)) {
            // not a statement, but perhaps it is an expression
            ReadExpr(s, S_SEMICOLON | S_EOF, 'r');
        }
    }

    /* every statement must be terminated by a semicolon                  */
    if (!IS_IN(s->Symbol, S_SEMICOLON) && s->Symbol != S_HELP && s->Symbol != S_PRAGMA) {
        SyntaxError(s, "; expected");
    }

    /* end the interpreter                                                 */
    TRY_IF_NO_ERROR {
        type = IntrEnd(0, evalResult);

        /* check for dual semicolon */
        if (dualSemicolon)
            *dualSemicolon = (s->Symbol == S_DUALSEMICOLON);
    }
    CATCH_ERROR {
        IntrEnd(1, evalResult);
        type = STATUS_ERROR;
#ifdef HPCGAP
        PopRegionLocks(lockSP);
        if (TLS(CurrentHashLock))
            HashUnlock(TLS(CurrentHashLock));
#endif
    }

    GAP_ASSERT(rs->LoopNesting == 0);

    /* switch back to the old reader context                               */
    memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
    rs->StackNams      = stackNams;
    rs->ReadTop        = readTop;
    rs->ReadTilde      = readTilde;
    STATE(Tilde)       = tilde;
    rs->CurrLHSGVar    = currLHSGVar;
    STATE(ErrorLVars)  = errorLVars;

    /* return whether a return-statement or a quit-statement were executed */
    return type;
}

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
UInt ReadEvalFile(Obj *evalResult)
{
    volatile ExecStatus type;
    volatile Obj        stackNams;
    volatile UInt       readTop;
    volatile UInt       readTilde;
    volatile Obj        tilde;
    volatile UInt       currLHSGVar;
    syJmp_buf           readJmpError;
    volatile UInt       nr;
    volatile Obj        nams;
    volatile Int        nloc;
    volatile Bag        currLVars;      /* copy of <STATE(CurrLVars)>      */
#ifdef HPCGAP
    volatile int        lockSP;
#endif

    struct ReaderState * volatile rs = ReaderState();
    ScannerState * volatile       s = &STATE(Scanner);

    /* get the first symbol from the input                                 */
    Match(s, s->Symbol, "", 0UL);

    /* if we have hit <end-of-file>, then give up                          */
    if (s->Symbol == S_EOF) {
        return STATUS_EOF;
    }

    /* print only a partial prompt from now on                             */
    STATE(Prompt) = SyQuiet ? "" : "> ";

    /* remember the old reader context                                     */
    stackNams   = rs->StackNams;
    readTop     = rs->ReadTop;
    readTilde   = rs->ReadTilde;
    tilde       = STATE(Tilde);
    currLHSGVar = rs->CurrLHSGVar;
#ifdef HPCGAP
    lockSP      = RegionLockSP();
#endif
    memcpy( readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf) );

    // initialize everything and begin an interpreter
    rs->StackNams    = NEW_PLIST( T_PLIST, 16 );
    rs->ReadTop      = 0;
    rs->ReadTilde    = 0;
    STATE(Tilde)     = 0;
    rs->CurrLHSGVar  = 0;
    IntrBegin(STATE(BottomLVars));

    GAP_ASSERT(rs->LoopNesting == 0);

    /* check for local variables                                           */
    nams = NEW_PLIST(T_PLIST, 0);
    PushPlist(rs->StackNams, nams);
    nloc = 0;
    if (s->Symbol == S_LOCAL) {
        nloc = ReadLocals(s, 0, nams);
    }

    currLVars = STATE(CurrLVars);

    /* fake the 'function ()'                                              */
    IntrFuncExprBegin(0, nloc, nams, GetInputLineNumber());

    /* read the statements                                                 */
    {
        UInt oldLoopNesting = rs->LoopNesting;
        rs->LoopNesting = 0;
        nr = ReadStats(s, S_SEMICOLON | S_EOF);
        rs->LoopNesting = oldLoopNesting;
    }

    GAP_ASSERT(rs->LoopNesting == 0);

    /* we now want to be at <end-of-file>                                  */
    if (s->Symbol != S_EOF) {
        SyntaxError(s, "<end-of-file> expected");
    }

    /* fake the 'end;'                                                     */
    TRY_IF_NO_ERROR {
        IntrFuncExprEnd(nr);
    }
    CATCH_ERROR {
        IntrAbortCoding(currLVars);
    }

    /* end the interpreter                                                 */
    TRY_IF_NO_ERROR {
        type = IntrEnd(0, evalResult);
    }
    CATCH_ERROR {
        IntrEnd(1, evalResult);
        type = STATUS_ERROR;
    }

    /* switch back to the old reader context                               */
    memcpy( STATE(ReadJmpError), readJmpError, sizeof(syJmp_buf) );
#ifdef HPCGAP
    PopRegionLocks(lockSP);
    if (TLS(CurrentHashLock))
      HashUnlock(TLS(CurrentHashLock));
#endif
    rs->StackNams    = stackNams;
    rs->ReadTop      = readTop;
    rs->ReadTilde    = readTilde;
    STATE(Tilde)     = tilde;
    rs->CurrLHSGVar  = currLHSGVar;

    /* return whether a return-statement or a quit-statement were executed */
    return type;
}


/****************************************************************************
**
*F  ReadEvalError() . . . . . . . . . . . . . . . . . .  return with an error
*/
void ReadEvalError(void)
{
    STATE(PtrBody)  = PTR_BAG(BODY_FUNC(CURR_FUNC()));
    STATE(PtrLVars) = PTR_BAG(STATE(CurrLVars));
    syLongjmp( &(STATE(ReadJmpError)), 1 );
}


/****************************************************************************
**
**  Reader state -- the next group of functions are used to "push" the
**  current interpreter state allowing GAP code to be interpreted in the
**  middle of other code. This is used, for instance, in the command-line
**  editor.
*/


struct SavedReaderState {
  Obj                 stackNams;
  UInt                readTop;
  UInt                readTilde;
  UInt                currLHSGVar;
  UInt                userHasQuit;
  syJmp_buf           readJmpError;
  UInt                intrCoding;
  UInt                intrIgnoring;
  UInt                intrReturning;
  UInt                nrError;
};

static void SaveReaderState(struct SavedReaderState *s) {
  s->stackNams   = ReaderState()->StackNams;
  s->readTop     = ReaderState()->ReadTop;
  s->readTilde   = ReaderState()->ReadTilde;
  s->currLHSGVar = ReaderState()->CurrLHSGVar;
  s->userHasQuit = STATE(UserHasQuit);
  s->intrCoding = STATE(IntrCoding);
  s->intrIgnoring = STATE(IntrIgnoring);
  s->intrReturning = STATE(IntrReturning);
  s->nrError = STATE(NrError);
  memcpy( s->readJmpError, STATE(ReadJmpError), sizeof(syJmp_buf) );
}

static void ClearReaderState(void ) {
  ReaderState()->StackNams   = NEW_PLIST( T_PLIST, 16 );
  ReaderState()->ReadTop     = 0;
  ReaderState()->ReadTilde   = 0;
  ReaderState()->CurrLHSGVar = 0;
  STATE(UserHasQuit) = 0;
  STATE(IntrCoding) = 0;
  STATE(IntrIgnoring) = 0;
  STATE(IntrReturning) = 0;
  STATE(NrError) = 0;
}

static void RestoreReaderState(const struct SavedReaderState *s) {
  memcpy( STATE(ReadJmpError), s->readJmpError, sizeof(syJmp_buf) );
  STATE(UserHasQuit) = s->userHasQuit;
  ReaderState()->StackNams   = s->stackNams;
  ReaderState()->ReadTop     = s->readTop;
  ReaderState()->ReadTilde   = s->readTilde;
  ReaderState()->CurrLHSGVar = s->currLHSGVar;
  STATE(IntrCoding) = s->intrCoding;
  STATE(IntrIgnoring) = s->intrIgnoring;
  STATE(IntrReturning) = s->intrReturning;
  STATE(NrError) = s->nrError;
}


/****************************************************************************
**
*F  Call0ArgsInNewReader(Obj f)  . . . . . . . . . . . . call a GAP function
**
**  The current reader context is saved and a new one is started.
*/
Obj Call0ArgsInNewReader(Obj f)

{
  /* for the new interpreter context: */
/*  ExecStatus          type; */
  struct SavedReaderState s;
  Obj result;

  /* remember the old reader context                                     */
  SaveReaderState(&s);

  // initialize everything and begin an interpreter
  ClearReaderState();
  IntrBegin( STATE(BottomLVars) );

  TRY_IF_NO_ERROR {
    result = CALL_0ARGS(f);
    PushVoidObj();
    /* end the interpreter                                                 */
    IntrEnd(0, NULL);
  }
  CATCH_ERROR {
    result = (Obj) 0L;
    IntrEnd(1, NULL);
    ClearError();
  }

  /* switch back to the old reader context                               */
  RestoreReaderState(&s);
  return result;
}

/****************************************************************************
**
*F  Call1ArgsInNewReader(Obj f,Obj a) . . . . . . . . . . call a GAP function
**
**  The current reader context is saved and a new one is started.
*/
Obj Call1ArgsInNewReader(Obj f,Obj a)

{
  /* for the new interpreter context: */
/*ExecStatus          type; */
  struct SavedReaderState s;
  Obj result;

  /* remember the old reader context                                     */

  SaveReaderState(&s);

  // initialize everything and begin an interpreter
  ClearReaderState();
  IntrBegin( STATE(BottomLVars) );

  TRY_IF_NO_ERROR {
    result = CALL_1ARGS(f,a);
    PushVoidObj();
    /* end the interpreter                                                 */
    IntrEnd(0, NULL);
  }
  CATCH_ERROR {
    result = (Obj) 0L;
    IntrEnd(1, NULL);
    ClearError();
  }

  /* switch back to the old reader context                               */
  RestoreReaderState(&s);
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
#if !defined(HPCGAP)
    InitGlobalBag(&ReaderState()->StackNams, "src/read.c:StackNams");
#endif
    InitCopyGVar( "GAPInfo", &GAPInfo);
    /* return success                                                      */
    return 0;
}


static Int InitModuleState(void)
{
    STATE(ErrorLVars) = (UInt **)0;
    ReaderState()->StackNams = NEW_PLIST(T_PLIST, 16);
    ReaderState()->ReadTop = 0;
    ReaderState()->ReadTilde = 0;
    ReaderState()->CurrLHSGVar = 0;
    ReaderState()->CurrentGlobalForLoopDepth = 0;

    // return success
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

    .moduleStateSize = sizeof(struct ReaderState),
    .moduleStateOffsetPtr = &ReaderStateOffset,
    .initModuleState = InitModuleState,
};

StructInitInfo * InitInfoRead ( void )
{
    return &module;
}
