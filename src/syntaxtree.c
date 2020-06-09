/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "syntaxtree.h"

#include "bool.h"
#include "calls.h"
#include "code.h"
#include "common.h"
#include "error.h"
#include "exprs.h"
#include "gvars.h"
#include "integer.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "precord.h"
#include "profile.h"
#include "records.h"
#include "stats.h"
#include "stringobj.h"
#include "vars.h"

#include <ctype.h>
#include <stdarg.h>

enum { MAX_ARITY = 4 };

typedef Obj (*CompileFuncT)(Obj node, Expr expr);
typedef Obj (*CompileArgT)(Expr expr);
typedef Expr (*CodeFuncT)(Obj node);
typedef Expr (*CodeArgT)(Obj node);


typedef struct {
    const Char * argname;
    CompileArgT  argcomp;
    CodeArgT     argcode;
    Int          isStat;
} ArgT;

typedef struct {
    UInt1        tnum;
    CompileFuncT compile;
    CodeFuncT    code;
    const Char * name;
    UInt         arity;
    ArgT         args[MAX_ARITY];
} CompilerT;

// We put compilers for statements and expressions into the same static array,
// assuming that the set of their respective ids are disjoint.
static const CompilerT Compilers[];
#define COMPILER_ARITY(...) (sizeof((ArgT[]){ __VA_ARGS__ }) / sizeof(ArgT))
#define COMPILER_GENERIC(tnum, compiler, coder, ...)                         \
    [tnum] = {                                                               \
        tnum,           compiler, coder, #tnum, COMPILER_ARITY(__VA_ARGS__), \
        { __VA_ARGS__ }                                                      \
    }

#define COMPILER(tnum, compiler, coder)                                      \
    COMPILER_GENERIC(tnum, compiler, coder)

#define COMPILER_(tnum, ...)                                                 \
    COMPILER_GENERIC(tnum, SyntaxTreeDefaultCompiler,                        \
                     SyntaxTreeDefaultCoder, __VA_ARGS__)

#define ARG(name, func, coder, isStat)                                       \
    {                                                                        \
        name, func, coder, isStat                                            \
    }

// ARG_EXPR indicates an "expression argument", i.e., that the corresponding
// slot of the statement or expression type it belongs to is meant to
// reference an expression. This information is used for validation when
// coding an AST back into a T_BODY object. The expression is stored in resp.
// read from the record entry <name>.
#define ARG_EXPR(name, func, coder) ARG(name, func, coder, 0)

// ARG_STAT is like ARG_EXPR, except that it indicates that the corresponding
// slot should contain a statement instead of an expression. There is no
// ARG_STAT, because it is never used.


// ARG_EXPR_ can be used instead of ARG_EXPR if the default compiler
// and coder should be used to compile the corresponding expression or code
// the corresponding subnode.
#define ARG_EXPR_(name)                                                      \
    ARG(name, SyntaxTreeCompiler, SyntaxTreeDefaultExprCoder, 0)
#define ARG_STAT_(name)                                                      \
    ARG(name, SyntaxTreeCompiler, SyntaxTreeDefaultStatCoder, 1)

// ARGS_EXPR can be used instead of ARG_EXPR as the last argument to the
// COMPILER_ macro, and indicates that a variable number of arguments follow;
// all are supposed to be expressions; and all of them are to be stored into a
// plist which is stored in resp. read from the record entry <name>.
#define ARGS_EXPR(name) ARG(name, 0, 0, 0)
#define ARGS_STAT(name) ARG(name, 0, 0, 1)

// plain list mapping statement tnums to strings
// like "EXPR_INT"
static Obj typeStrings;

// plain record mapping strings like "EXPR_INT" to the
// corresponding statement tnum
static Obj typeRec;


static Obj ElmRecST(UInt1 tnum, Obj node, const char * name)
{
    RequirePlainRec("ElmRecST", node);
    UInt rnam = RNamName(name);
    if (!IsbPRec(node, rnam)) {
        const char * typename = Compilers[tnum].name;
        ErrorQuit("while coding %s: node field <%s> must be present",
                  (Int) typename, (Int)name);
    }
    return ElmPRec(node, rnam);
}

static Obj SyntaxTreeFunc(Obj result, Obj func);

static UInt1 FIND_TNUM_FROM_STRING(Obj typestr)
{
    UInt rnam = RNamObj(typestr);
    if (IsbPRec(typeRec, rnam)) {
        return (UInt1)UInt_ObjInt(ElmPRec(typeRec, rnam));
    }
    ErrorQuit("Unrecognized syntax tree node type %g", (Int)typestr, 0);
}

static UInt1 GetTypeTNum(Obj node)
{
    RequirePlainRec("GetTypeTNum", node);
    UInt type = RNamName("type");
    if (!IsbPRec(node, type)) {
        ErrorQuit("while coding: <type> field is not present", 0, 0);
    }
    return FIND_TNUM_FROM_STRING(ElmPRec(node, type));
}

static inline Obj NewSyntaxTreeNode(UInt1 tnum)
{
    Obj result;
    Obj typestr;

    typestr = ELM_LIST(typeStrings, tnum + 1);
    result = NEW_PREC(2);
    AssPRec(result, RNamName("type"), typestr);

    return result;
}

static Obj SyntaxTreeCompiler(Expr expr)
{
    Obj       result;
    UInt1     tnum;
    CompilerT comp;

    // TODO: GAP_ASSERT
    tnum = TNUM_EXPR(expr);
    comp = Compilers[tnum];

    result = NewSyntaxTreeNode(comp.tnum);

    return comp.compile(result, expr);
}

static Obj SyntaxTreeRNam(Expr expr)
{
    return NAME_RNAM(expr);
}

static Obj SyntaxTreeDefaultCompiler(Obj result, Expr expr)
{
    int       i;
    UInt1     tnum;
    CompilerT comp;

    // TODO: GAP_ASSERT tnum range
    tnum = TNUM_EXPR(expr);
    comp = Compilers[tnum];

    for (i = 0; i < comp.arity; i++) {
        UInt rnam = RNamName(comp.args[i].argname);
        Obj  compiled;

        if (comp.args[i].argcomp) {
            Expr subexpr = READ_EXPR(expr, i);
            compiled = comp.args[i].argcomp(subexpr);
        }
        else {
            // special case: the last argument may have zero as decompiler,
            // meaning that all remaining slots of the statement should be
            // decompiled into a single list
            const UInt offset = comp.arity - 1;
            GAP_ASSERT(i == offset);

            // compile the complete rest into one statement
            const UInt nr = SIZE_EXPR(expr) / sizeof(expr);
            compiled = NEW_PLIST(T_PLIST, nr - offset);
            for (; i < nr; i++) {
                Expr subexpr = READ_EXPR(expr, i);
                // handle 0 to properly deal with EXPR_LIST
                Obj obj = subexpr ? SyntaxTreeCompiler(subexpr) : 0;
                PushPlist(compiled, obj);
            }
        }

        AssPRec(result, rnam, compiled);
    }
    return result;
}

static Stat SyntaxTreeDefaultStatCoder(Obj);
static Stat SyntaxTreeDefaultExprCoder(Obj);

static Expr SyntaxTreeDefaultCoder(Obj node)
{

    RequirePlainRec("SyntaxTreeDefaultCoder", node);

    UInt1 tnum = GetTypeTNum(node);

    CompilerT comp = Compilers[tnum];

    if (comp.code != SyntaxTreeDefaultCoder) {
        return comp.code(node);
    }

    // compute how big the statement/expression we are generating needs to
    // be, i.e., how many Obj-sized "slots" we need; this is usually
    // comp.arity, but we need to take into account variadic argument lists
    UInt slots = comp.arity;
    UInt arity = comp.arity;

    UInt isvararg = comp.arity > 0 && comp.args[comp.arity - 1].argcomp == 0;
    Obj  vararglist;

    if (isvararg) {
        arity--;
        vararglist = ElmRecST(tnum, node, comp.args[arity].argname);
        slots = arity + LEN_LIST(vararglist);
    }

    // reserve space for the statement or expressions
    Expr expr = NewStatOrExpr(tnum, slots * sizeof(Expr), 0);

    UInt i;

    for (i = 0; i < arity; i++) {
        Obj subast = ElmRecST(tnum, node, comp.args[i].argname);
        WRITE_EXPR(expr, i, comp.args[i].argcode(subast));
    }

    if (isvararg) {
        for (i = arity; i < slots; i++) {
            Obj elem = ELM0_LIST(vararglist, i - arity + 1);
            // Deal with empty entries in list expressions
            if (elem == 0) {
                WRITE_EXPR(expr, i, 0);
            }
            else if (comp.args[arity].isStat) {
                WRITE_EXPR(expr, i, SyntaxTreeDefaultStatCoder(elem));
            }
            else {
                WRITE_EXPR(expr, i, SyntaxTreeDefaultExprCoder(elem));
            }
        }
    }

    return expr;
}


// Checks if node codes a statement
static Stat SyntaxTreeDefaultStatCoder(Obj node)
{
    RequirePlainRec("SyntaxTreeDefaultStatCoder", node);
    Int tnum = GetTypeTNum(node);
    if (!(FIRST_STAT_TNUM <= tnum && tnum <= LAST_STAT_TNUM))
        ErrorQuit("tried to code expression %s as statement",
                  (Int)Compilers[tnum].name, 0);
    return (Stat)SyntaxTreeDefaultCoder(node);
}

// Checks if node codes an expression
static Expr SyntaxTreeDefaultExprCoder(Obj node)
{
    RequirePlainRec("SyntaxTreeDefaultExprCoder", node);
    UInt1 tnum = GetTypeTNum(node);
    if (!(FIRST_EXPR_TNUM <= tnum && tnum <= LAST_EXPR_TNUM))
        ErrorQuit("tried to code statement %s as expression",
                  (Int)Compilers[tnum].name, 0);
    return (Expr)SyntaxTreeDefaultCoder(node);
}

static Expr SyntaxTreeCodeGVar(Obj name)
{
    RequireStringRep("SyntaxTreeCodeGVar", name);
    return GVarName(CONST_CSTR_STRING(name));
}

static Obj SyntaxTreeRefLVar(Obj result, Expr expr)
{
    AssPRec(result, RNamName("lvar"), INTOBJ_INT(LVAR_REF_LVAR(expr)));
    return result;
}

static Expr SyntaxTreeCodeRefLVar(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeRefLVar", node);
    Obj lvar = ElmRecST(EXPR_REF_LVAR, node, "lvar");
    RequireSmallInt("SyntaxTreeCodeRefLVar", lvar);
    return REF_LVAR_LVAR(INT_INTOBJ(lvar));
}

static Obj SyntaxTreeEvalCompiler(Obj result, Expr expr)
{
    pauseProfiling();
    Obj o = EVAL_EXPR(expr);
    unpauseProfiling();
    AssPRec(result, RNamName("value"), o);
    return result;
}

static Obj SyntaxTreeFuncExpr(Obj result, Expr expr)
{
    Obj fexp = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 0));

    SyntaxTreeFunc(result, fexp);

    return result;
}

static Obj SyntaxTreeRangeExpr(Obj result, Expr expr)
{
    Obj first;
    Obj second;
    Obj last;

    if (SIZE_EXPR(expr) == 2 * sizeof(Expr)) {
        first = SyntaxTreeCompiler(READ_EXPR(expr, 0));
        last = SyntaxTreeCompiler(READ_EXPR(expr, 1));

        AssPRec(result, RNamName("first"), first);
        AssPRec(result, RNamName("last"), last);
    }
    else {
        first = SyntaxTreeCompiler(READ_EXPR(expr, 0));
        second = SyntaxTreeCompiler(READ_EXPR(expr, 1));
        last = SyntaxTreeCompiler(READ_EXPR(expr, 2));

        AssPRec(result, RNamName("first"), first);
        AssPRec(result, RNamName("second"), second);
        AssPRec(result, RNamName("last"), last);
    }

    return result;
}

static Expr SyntaxTreeCodeRangeExpr(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeRangeExpr", node);
    UInt hassecond = ISB_REC(node, RNamName("second"));
    UInt size = hassecond ? 3 : 2;
    Expr result = NewStatOrExpr(EXPR_RANGE, size * sizeof(Expr), 0);
    WRITE_EXPR(
        result, 0,
        SyntaxTreeDefaultExprCoder(ElmRecST(EXPR_RANGE, node, "first")));
    WRITE_EXPR(
        result, size - 1,
        SyntaxTreeDefaultExprCoder(ElmRecST(EXPR_RANGE, node, "last")));
    if (hassecond) {
        WRITE_EXPR(result, 1,
                   SyntaxTreeDefaultExprCoder(
                       ElmRecST(EXPR_RANGE, node, "second")));
    }
    return result;
}

static Obj SyntaxTreeRecExpr(Obj result, Expr expr)
{
    Obj  key;
    Obj  val;
    Obj  list;
    Obj  subrec;
    Expr tmp;
    Int  i, len;

    len = SIZE_EXPR(expr) / (2 * sizeof(Expr));
    list = NEW_PLIST(T_PLIST, len);

    for (i = 1; i <= len; i++) {
        tmp = READ_EXPR(expr, 2 * i - 2);
        GAP_ASSERT(tmp != 0);

        subrec = NEW_PREC(2);
        PushPlist(list, subrec);

        if (IS_INTEXPR(tmp)) {
            key = NAME_RNAM((UInt)INT_INTEXPR(tmp));
        }
        else {
            key = SyntaxTreeCompiler(tmp);
        }
        AssPRec(subrec, RNamName("key"), key);

        tmp = READ_EXPR(expr, 2 * i - 1);
        val = SyntaxTreeCompiler(tmp);
        AssPRec(subrec, RNamName("value"), val);
    }
    AssPRec(result, RNamName("keyvalue"), list);

    return result;
}

static Expr SyntaxTreeCodeRecExpr(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeRecExpr", node);
    UInt1 tnum = GetTypeTNum(node);
    Obj   keyvalue = ElmRecST(tnum, node, "keyvalue");
    UInt  len = LEN_LIST(keyvalue);
    Expr  record = NewStatOrExpr(tnum, 2 * len * sizeof(Expr), 0);
    for (int i = 0; i < len; i++) {
        Obj  keyvaluepair = ELM_LIST(keyvalue, i + 1);
        Obj  keynode = ElmRecST(tnum, keyvaluepair, "key");
        Obj  valuenode = ElmRecST(tnum, keyvaluepair, "value");
        Expr key;
        if (IS_STRING(keynode)) {
            key = INTEXPR_INT(RNamObj(keynode));
        }
        else {
            key = SyntaxTreeDefaultExprCoder(keynode);
        }
        Expr value = SyntaxTreeDefaultExprCoder(valuenode);
        WRITE_EXPR(record, 2 * i, key);
        WRITE_EXPR(record, 2 * i + 1, value);
    }
    return record;
}

static Obj SyntaxTreeFloatLazy(Obj result, Expr expr)
{
    Obj string = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 1));
    AssPRec(result, RNamName("value"), string);
    return result;
}

static Obj SyntaxTreeFloatEager(Obj result, Expr expr)
{
    Obj   value = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 0));
    Obj   string = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 1));
    UChar chr = (UChar)READ_EXPR(expr, 2);
    AssPRec(result, RNamName("value"), value);
    AssPRec(result, RNamName("string"), string);
    AssPRec(result, RNamName("mark"), ObjsChar[chr]);
    return result;
}

static Expr SyntaxTreeCodeFloatLazy(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeFloatLazy", node);
    Obj value = ElmRecST(EXPR_FLOAT_LAZY, node, "value");
    return CodeLazyFloatExpr(value, 0);
}

static Expr SyntaxTreeCodeFloatEager(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeFloatEager", node);
    Obj  value = ElmRecST(EXPR_FLOAT_EAGER, node, "value");
    Obj  string = ElmRecST(EXPR_FLOAT_EAGER, node, "string");
    Obj  mark = ElmRecST(EXPR_FLOAT_EAGER, node, "mark");
    Expr fl = NewStatOrExpr(EXPR_FLOAT_EAGER, 3 * sizeof(UInt), 0);
    WRITE_EXPR(fl, 0, AddValueToBody(value));
    WRITE_EXPR(fl, 1, AddValueToBody(string));
    WRITE_EXPR(fl, 2, (UInt)CHAR_VALUE(mark));
    return fl;
}

static Obj SyntaxTreeIf(Obj result, Stat stat)
{
    Obj cond;
    Obj then;
    Obj pair;
    Obj branches;

    Int i, nr;

    nr = SIZE_STAT(stat) / (2 * sizeof(Stat));
    branches = NEW_PLIST(T_PLIST, nr);

    AssPRec(result, RNamName("branches"), branches);

    for (i = 0; i < nr; i++) {
        cond = SyntaxTreeCompiler(READ_STAT(stat, 2 * i));
        then = SyntaxTreeCompiler(READ_STAT(stat, 2 * i + 1));

        pair = NEW_PREC(2);
        AssPRec(pair, RNamName("condition"), cond);
        AssPRec(pair, RNamName("body"), then);

        PushPlist(branches, pair);
    }
    return result;
}

static Obj SyntaxTreeCompilePragma(Obj result, Stat stat)
{
    Obj message = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(stat, 0));
    AssPRec(result, RNamName("value"), message);
    return result;
}

static Expr SyntaxTreeCodeIf(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeIf", node);
    UInt1 tnum = GetTypeTNum(node);
    Obj   branches = ElmRecST(tnum, node, "branches");
    UInt  len = LEN_LIST(branches);
    Expr  ifexpr = NewStatOrExpr(tnum, 2 * len * sizeof(Expr), 0);
    for (int i = 0; i < len; i++) {
        Obj  condbodypair = ELM_LIST(branches, i + 1);
        Obj  conditionnode = ElmRecST(tnum, condbodypair, "condition");
        Obj  bodynode = ElmRecST(tnum, condbodypair, "body");
        Expr condition = SyntaxTreeDefaultExprCoder(conditionnode);
        Stat body = SyntaxTreeDefaultStatCoder(bodynode);
        WRITE_EXPR(ifexpr, 2 * i, condition);
        WRITE_EXPR(ifexpr, 2 * i + 1, body);
    }
    return ifexpr;
}

static Expr SyntaxTreeCodeImmediateInteger(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeImmediateInteger", node);
    Obj value = ElmRecST(EXPR_INT, node, "value");
    RequireSmallIntEx("SyntaxTreeCodeImmediateInteger", value,
                      "<node>.value");
    return INTEXPR_INT(INT_INTOBJ(value));
}

static Expr SyntaxTreeCodeValue(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeValue", node);
    UInt1 tnum = GetTypeTNum(node);
    Obj   value = ElmRecST(tnum, node, "value");
    Expr  expr = NewStatOrExpr(tnum, sizeof(UInt), 0);
    Int   ix = AddValueToBody(value);
    WRITE_EXPR(expr, 0, ix);
    return expr;
}

static Expr SyntaxTreeCodeChar(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeChar", node);
    Obj  chr = ElmRecST(EXPR_CHAR, node, "value");
    Char currchar = CHAR_VALUE(chr);
    Expr lit = NewStatOrExpr(EXPR_CHAR, sizeof(UChar), 0);
    WRITE_EXPR(lit, 0, currchar);
    return lit;
}

static Obj SyntaxTreeFunc(Obj result, Obj func)
{
    Obj stats;

    Bag oldFrame;
    Int narg;
    Int nloc;

    if (NAME_FUNC(func)) {
        AssPRec(result, RNamName("name"), NAME_FUNC(func));
    }

    narg = NARG_FUNC(func);
    if (narg < 0) {
        AssPRec(result, RNamName("variadic"), True);
        narg = -narg;
    }
    else {
        AssPRec(result, RNamName("variadic"), False);
    }
    AssPRec(result, RNamName("narg"), INTOBJ_INT(narg));
    nloc = NLOC_FUNC(func);
    AssPRec(result, RNamName("nloc"), INTOBJ_INT(nloc));

    /* names of arguments and locals*/
    AssPRec(result, RNamName("nams"), NAMS_FUNC(func));

    /* switch to this function (so that 'READ_STAT' and 'READ_EXPR' work) */
    oldFrame = SWITCH_TO_NEW_LVARS(func, narg, nloc);
    stats = SyntaxTreeCompiler(OFFSET_FIRST_STAT);
    SWITCH_TO_OLD_LVARS(oldFrame);

    AssPRec(result, RNamName("stats"), stats);

    return result;
}

static UInt SyntaxTreeCodeFunc_Internal(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeFunc_Internal", node);
    Int narg = INT_INTOBJ(ElmRecST(EXPR_FUNC, node, "narg"));
    Int nloc = INT_INTOBJ(ElmRecST(EXPR_FUNC, node, "nloc"));
    Obj nams = ElmRecST(EXPR_FUNC, node, "nams");
    Obj variadic = ElmRecST(EXPR_FUNC, node, "variadic");
    if (variadic == True) {
        narg = -narg;
    }
    CodeFuncExprBegin(narg, nloc, nams, 0);
    Obj  stat_rec = ElmRecST(EXPR_FUNC, node, "stats");
    Obj  body_stats = ElmRecST(EXPR_FUNC, stat_rec, "statements");
    UInt nr_stats = LEN_LIST(body_stats);
    for (int i = 1; i <= nr_stats; i++) {
        Expr current = SyntaxTreeDefaultStatCoder(ELM_LIST(body_stats, i));
        PushStat(current);
    }
    return nr_stats;
}

static Expr SyntaxTreeCodeFunc(Obj node)
{
    RequirePlainRec("SyntaxTreeCodeFunc", node);
    UInt nr_stats = SyntaxTreeCodeFunc_Internal(node);
    Expr funcexpr = CodeFuncExprEnd(nr_stats, 0);
    return funcexpr;
}

static Obj FuncSYNTAX_TREE_CODE(Obj self, Obj tree)
{
    RequirePlainRec(SELF_NAME, tree);
    CodeBegin();
    UInt nr_stats = SyntaxTreeCodeFunc_Internal(tree);
    CodeFuncExprEnd(nr_stats, 0);
    Obj func = CodeEnd(0);
    if (IsbPRec(tree, RNamName("name"))) {
        Obj name = ELM_REC(tree, RNamName("name"));
        SET_NAME_FUNC(func, name);
    }
    return func;
}

static const CompilerT Compilers[] = {
    COMPILER_(STAT_PROCCALL_0ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(STAT_PROCCALL_1ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(STAT_PROCCALL_2ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(STAT_PROCCALL_3ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(STAT_PROCCALL_4ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(STAT_PROCCALL_5ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(STAT_PROCCALL_6ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(STAT_PROCCALL_XARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),

    COMPILER_(STAT_PROCCALL_OPTS, ARG_EXPR_("opts"), ARG_STAT_("call")),

    COMPILER_(STAT_EMPTY),

    COMPILER_(STAT_SEQ_STAT, ARGS_STAT("statements")),
    COMPILER_(STAT_SEQ_STAT2, ARGS_STAT("statements")),
    COMPILER_(STAT_SEQ_STAT3, ARGS_STAT("statements")),
    COMPILER_(STAT_SEQ_STAT4, ARGS_STAT("statements")),
    COMPILER_(STAT_SEQ_STAT5, ARGS_STAT("statements")),
    COMPILER_(STAT_SEQ_STAT6, ARGS_STAT("statements")),
    COMPILER_(STAT_SEQ_STAT7, ARGS_STAT("statements")),

    COMPILER(STAT_IF, SyntaxTreeIf, SyntaxTreeCodeIf),
    COMPILER(STAT_IF_ELSE, SyntaxTreeIf, SyntaxTreeCodeIf),
    COMPILER(STAT_IF_ELIF, SyntaxTreeIf, SyntaxTreeCodeIf),
    COMPILER(STAT_IF_ELIF_ELSE, SyntaxTreeIf, SyntaxTreeCodeIf),

    COMPILER_(STAT_FOR,
              ARG_EXPR_("variable"),
              ARG_EXPR_("collection"),
              ARGS_STAT("body")),
    COMPILER_(STAT_FOR2,
              ARG_EXPR_("variable"),
              ARG_EXPR_("collection"),
              ARGS_STAT("body")),
    COMPILER_(STAT_FOR3,
              ARG_EXPR_("variable"),
              ARG_EXPR_("collection"),
              ARGS_STAT("body")),

    COMPILER_(STAT_FOR_RANGE,
              ARG_EXPR_("variable"),
              ARG_EXPR_("collection"),
              ARGS_STAT("body")),
    COMPILER_(STAT_FOR_RANGE2,
              ARG_EXPR_("variable"),
              ARG_EXPR_("collection"),
              ARGS_STAT("body")),
    COMPILER_(STAT_FOR_RANGE3,
              ARG_EXPR_("variable"),
              ARG_EXPR_("collection"),
              ARGS_STAT("body")),

    COMPILER_(STAT_WHILE, ARG_EXPR_("condition"), ARGS_STAT("body")),
    COMPILER_(STAT_WHILE2, ARG_EXPR_("condition"), ARGS_STAT("body")),
    COMPILER_(STAT_WHILE3, ARG_EXPR_("condition"), ARGS_STAT("body")),

    COMPILER_(STAT_REPEAT, ARG_EXPR_("condition"), ARGS_STAT("body")),
    COMPILER_(STAT_REPEAT2, ARG_EXPR_("condition"), ARGS_STAT("body")),
    COMPILER_(STAT_REPEAT3, ARG_EXPR_("condition"), ARGS_STAT("body")),

#ifdef HPCGAP
    COMPILER_(STAT_ATOMIC,
              ARG_STAT_("body"),
              ARGS_EXPR("locks")),    // TODO: better output
#endif

    COMPILER_(STAT_BREAK),
    COMPILER_(STAT_CONTINUE),
    COMPILER_(STAT_RETURN_OBJ, ARG_EXPR_("obj")),
    COMPILER_(STAT_RETURN_VOID),

    COMPILER_(STAT_ASS_LVAR,
              ARG_EXPR("lvar", ObjInt_UInt, UInt_ObjInt),
              ARG_EXPR_("rhs")),
    COMPILER_(STAT_UNB_LVAR, ARG_EXPR("lvar", ObjInt_UInt, UInt_ObjInt)),

    COMPILER_(STAT_ASS_HVAR,
              ARG_EXPR("hvar", ObjInt_UInt, UInt_ObjInt),
              ARG_EXPR_("rhs")),
    COMPILER_(STAT_UNB_HVAR, ARG_EXPR("hvar", ObjInt_UInt, UInt_ObjInt)),

    COMPILER_(STAT_ASS_GVAR,
              ARG_EXPR("gvar", NameGVar, SyntaxTreeCodeGVar),
              ARG_EXPR_("rhs")),
    COMPILER_(STAT_UNB_GVAR, ARG_EXPR("gvar", NameGVar, SyntaxTreeCodeGVar)),

    COMPILER_(
        STAT_ASS_LIST, ARG_EXPR_("list"), ARG_EXPR_("pos"), ARG_EXPR_("rhs")),
    COMPILER_(
        STAT_ASS_MAT, ARG_EXPR_("list"), ARG_EXPR_("row"), ARG_EXPR_("col"), ARG_EXPR_("rhs")),
    COMPILER_(
        STAT_ASSS_LIST, ARG_EXPR_("list"), ARG_EXPR_("poss"), ARG_EXPR_("rhss")),
    COMPILER_(STAT_ASS_LIST_LEV,
              ARG_EXPR_("lists"),
              ARG_EXPR_("pos"),
              ARG_EXPR_("rhss"),
              ARG_EXPR("level", ObjInt_UInt, UInt_ObjInt)),
    COMPILER_(STAT_ASSS_LIST_LEV,
              ARG_EXPR_("lists"),
              ARG_EXPR_("poss"),
              ARG_EXPR_("rhss"),
              ARG_EXPR("level", ObjInt_UInt, UInt_ObjInt)),
    COMPILER_(STAT_UNB_LIST, ARG_EXPR_("list"), ARG_EXPR_("pos")),

    COMPILER_(STAT_ASS_REC_NAME,
              ARG_EXPR_("record"),
              ARG_EXPR("rnam", SyntaxTreeRNam, RNamObj),
              ARG_EXPR_("rhs")),
    COMPILER_(STAT_ASS_REC_EXPR,
              ARG_EXPR_("record"),
              ARG_EXPR_("expression"),
              ARG_EXPR_("rhs")),
    COMPILER_(STAT_UNB_REC_NAME,
              ARG_EXPR_("record"),
              ARG_EXPR("rnam", SyntaxTreeRNam, RNamObj)),
    COMPILER_(STAT_UNB_REC_EXPR, ARG_EXPR_("record"), ARG_EXPR_("expression")),

    COMPILER_(STAT_ASS_POSOBJ,
              ARG_EXPR_("posobj"),
              ARG_EXPR_("pos"),
              ARG_EXPR_("rhs")),
    COMPILER_(STAT_UNB_POSOBJ, ARG_EXPR_("posobj"), ARG_EXPR_("pos")),

    COMPILER_(STAT_ASS_COMOBJ_NAME,
              ARG_EXPR_("comobj"),
              ARG_EXPR("rnam", SyntaxTreeRNam, RNamObj),
              ARG_EXPR_("rhs")),
    COMPILER_(STAT_ASS_COMOBJ_EXPR,
              ARG_EXPR_("comobj"),
              ARG_EXPR_("expression"),
              ARG_EXPR_("rhs")),
    COMPILER_(STAT_UNB_COMOBJ_NAME,
              ARG_EXPR_("comobj"),
              ARG_EXPR("rnam", SyntaxTreeRNam, RNamObj)),
    COMPILER_(
        STAT_UNB_COMOBJ_EXPR, ARG_EXPR_("comobj"), ARG_EXPR_("expression")),

    COMPILER_(STAT_INFO, ARG_EXPR_("sel"), ARG_EXPR_("lev"), ARGS_EXPR("args")),
    COMPILER_(STAT_ASSERT_2ARGS, ARG_EXPR_("level"), ARG_EXPR_("condition")),
    COMPILER_(STAT_ASSERT_3ARGS,
              ARG_EXPR_("level"),
              ARG_EXPR_("condition"),
              ARG_EXPR_("message")),
    COMPILER(STAT_PRAGMA, SyntaxTreeCompilePragma, SyntaxTreeCodeValue),


    /* Statements */
    COMPILER_(EXPR_FUNCCALL_0ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(EXPR_FUNCCALL_1ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(EXPR_FUNCCALL_2ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(EXPR_FUNCCALL_3ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(EXPR_FUNCCALL_4ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(EXPR_FUNCCALL_5ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(EXPR_FUNCCALL_6ARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),
    COMPILER_(EXPR_FUNCCALL_XARGS, ARG_EXPR_("funcref"), ARGS_EXPR("args")),

    COMPILER(EXPR_FUNC, SyntaxTreeFuncExpr, SyntaxTreeCodeFunc),

    COMPILER_(EXPR_FUNCCALL_OPTS, ARG_EXPR_("opts"), ARG_EXPR_("call")),


    COMPILER_(EXPR_OR, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_AND, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_NOT, ARG_EXPR_("op")),
    COMPILER_(EXPR_EQ, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_NE, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_LT, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_GE, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_GT, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_LE, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_IN, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_SUM, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_AINV, ARG_EXPR_("op")),
    COMPILER_(EXPR_DIFF, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_PROD, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_QUO, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_MOD, ARG_EXPR_("left"), ARG_EXPR_("right")),
    COMPILER_(EXPR_POW, ARG_EXPR_("left"), ARG_EXPR_("right")),

    COMPILER(
        EXPR_INT, SyntaxTreeEvalCompiler, SyntaxTreeCodeImmediateInteger),
    COMPILER(EXPR_INTPOS, SyntaxTreeEvalCompiler, SyntaxTreeCodeValue),
    COMPILER_(EXPR_TRUE),
    COMPILER_(EXPR_FALSE),
    COMPILER_(EXPR_TILDE),
    COMPILER(EXPR_CHAR, SyntaxTreeEvalCompiler, SyntaxTreeCodeChar),
    COMPILER_(EXPR_PERM, ARGS_EXPR("cycles")),
    COMPILER_(EXPR_PERM_CYCLE, ARGS_EXPR("points")),
    COMPILER_(EXPR_LIST, ARGS_EXPR("list")),
    COMPILER_(EXPR_LIST_TILDE, ARGS_EXPR("list")),
    COMPILER(EXPR_RANGE, SyntaxTreeRangeExpr, SyntaxTreeCodeRangeExpr),
    COMPILER(EXPR_STRING, SyntaxTreeEvalCompiler, SyntaxTreeCodeValue),
    COMPILER(EXPR_REC, SyntaxTreeRecExpr, SyntaxTreeCodeRecExpr),
    COMPILER_(EXPR_REC_TILDE),

    COMPILER(
        EXPR_FLOAT_EAGER, SyntaxTreeFloatEager, SyntaxTreeCodeFloatEager),
    COMPILER(EXPR_FLOAT_LAZY, SyntaxTreeFloatLazy, SyntaxTreeCodeFloatLazy),

    // EXPR_REF_LVAR is encoded differently from all other
    //           references to LVARs, so we have to treat
    //           them specially here
    COMPILER(EXPR_REF_LVAR, SyntaxTreeRefLVar, SyntaxTreeCodeRefLVar),
    COMPILER_(EXPR_ISB_LVAR, ARG_EXPR("lvar", ObjInt_UInt, UInt_ObjInt)),

    COMPILER_(EXPR_REF_HVAR, ARG_EXPR("hvar", ObjInt_UInt, UInt_ObjInt)),
    COMPILER_(EXPR_ISB_HVAR, ARG_EXPR("hvar", ObjInt_UInt, UInt_ObjInt)),

    COMPILER_(EXPR_REF_GVAR, ARG_EXPR("gvar", NameGVar, SyntaxTreeCodeGVar)),
    COMPILER_(EXPR_ISB_GVAR, ARG_EXPR("gvar", NameGVar, SyntaxTreeCodeGVar)),

    // TODO: can this be unified?
    COMPILER_(EXPR_ELM_LIST, ARG_EXPR_("list"), ARG_EXPR_("pos")),
    COMPILER_(
        EXPR_ELM_MAT, ARG_EXPR_("list"), ARG_EXPR_("row"), ARG_EXPR_("col")),
    COMPILER_(EXPR_ELMS_LIST, ARG_EXPR_("list"), ARG_EXPR_("poss")),
    COMPILER_(EXPR_ELM_LIST_LEV,
              ARG_EXPR_("lists"),
              ARG_EXPR_("pos"),
              ARG_EXPR_("level")),
    COMPILER_(EXPR_ELMS_LIST_LEV,
              ARG_EXPR_("lists"),
              ARG_EXPR_("poss"),
              ARG_EXPR_("level")),
    COMPILER_(EXPR_ISB_LIST, ARG_EXPR_("list"), ARG_EXPR_("pos")),
    COMPILER_(EXPR_ELM_REC_NAME,
              ARG_EXPR_("record"),
              ARG_EXPR("name", SyntaxTreeRNam, RNamObj)),
    COMPILER_(EXPR_ELM_REC_EXPR, ARG_EXPR_("record"), ARG_EXPR_("expression")),
    COMPILER_(EXPR_ISB_REC_NAME,
              ARG_EXPR_("record"),
              ARG_EXPR("name", SyntaxTreeRNam, RNamObj)),
    COMPILER_(EXPR_ISB_REC_EXPR, ARG_EXPR_("record"), ARG_EXPR_("expression")),
    COMPILER_(EXPR_ELM_POSOBJ, ARG_EXPR_("posobj"), ARG_EXPR_("pos")),
    COMPILER_(EXPR_ISB_POSOBJ, ARG_EXPR_("posobj"), ARG_EXPR_("pos")),
    COMPILER_(EXPR_ELM_COMOBJ_NAME,
              ARG_EXPR_("comobj"),
              ARG_EXPR("name", SyntaxTreeRNam, RNamObj)),
    COMPILER_(
        EXPR_ELM_COMOBJ_EXPR, ARG_EXPR_("comobj"), ARG_EXPR_("expression")),
    COMPILER_(EXPR_ISB_COMOBJ_NAME,
              ARG_EXPR_("comobj"),
              ARG_EXPR("name", SyntaxTreeRNam, RNamObj)),
    COMPILER_(
        EXPR_ISB_COMOBJ_EXPR, ARG_EXPR_("comobj"), ARG_EXPR_("expression")),
};

static Obj FuncSYNTAX_TREE(Obj self, Obj func)
{
    Obj result;

    if (!IS_FUNC(func) || IsKernelFunction(func) || IS_OPERATION(func)) {
        RequireArgument(SELF_NAME, func, "must be a plain GAP function");
    }

    result = NewSyntaxTreeNode(EXPR_FUNC);
    return SyntaxTreeFunc(result, func);
}

static StructGVarFunc GVarFuncs[] = { GVAR_FUNC_1ARGS(SYNTAX_TREE, func),
                                      GVAR_FUNC_1ARGS(SYNTAX_TREE_CODE, tree),
                                      { 0, 0, 0, 0, 0 } };

static Int InitKernel(StructInitInfo * module)
{
    /* init filters and functions */
    InitHdlrFuncsFromTable(GVarFuncs);

    InitGlobalBag(&typeStrings, "typeStrings");
    InitGlobalBag(&typeRec, "typeRec");

    return 0;
}

static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions */
    InitGVarFuncsFromTable(GVarFuncs);

    typeStrings = NEW_PLIST(T_PLIST, ARRAY_SIZE(Compilers));
    typeRec = NEW_PREC(0);
    for (UInt tnum = 0; tnum < ARRAY_SIZE(Compilers); tnum++) {
        const char * str = Compilers[tnum].name;
        if (str) {
            AssPRec(typeRec, RNamName(str), ObjInt_UInt(tnum));
            ASS_LIST(typeStrings, tnum + 1, MakeImmString(str));
        }
    }


    return 0;
}

static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "syntaxtree",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoSyntaxTree(void)
{
    return &module;
}
