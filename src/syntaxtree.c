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
#include "error.h"
#include "exprs.h"
#include "gvars.h"
#include "integer.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "precord.h"
#include "records.h"
#include "stats.h"
#include "stringobj.h"
#include "system.h"
#include "vars.h"

#include <ctype.h>
#include <stdarg.h>

typedef Obj (*CompileFuncT)(Obj node, Expr expr);
typedef Obj (*CompileArgT)(Expr expr);

typedef struct {
    const Char * argname;
    CompileArgT  argcomp;
} ArgT;

typedef struct {
    UInt1        tnum;
    CompileFuncT compile;
    const Char * name;
    UInt1        arity;
    ArgT         args[4]; /* The maximum compiler arity is currently 4 */
} CompilerT;

// We put compilers for statements and expressions into the same static array,
// assuming that the set of their respective ids are disjoint.
static const CompilerT Compilers[];
#define COMPILER_ARITY(...) (sizeof((ArgT[]){ __VA_ARGS__ }) / sizeof(ArgT))
#define COMPILER_GENERIC(tnum, compiler, ...)                                \
    [tnum] = {                                                               \
        tnum, compiler, #tnum, COMPILER_ARITY(__VA_ARGS__), { __VA_ARGS__ }  \
    }

#define COMPILER(tnum, compiler) COMPILER_GENERIC(tnum, compiler)

#define COMPILER_(tnum, ...)                                                 \
    COMPILER_GENERIC(tnum, SyntaxTreeDefaultCompiler, __VA_ARGS__)

#define ARG(name, func)                                                      \
    {                                                                        \
        name, func                                                           \
    }
#define ARG_(name) ARG(name, SyntaxTreeCompiler)

#define ARGS(name) ARG(name, 0)


static Obj typeStrings;


static Obj SyntaxTreeFunc(Obj result, Obj func);

static inline Obj NewSyntaxTreeNode(UInt1 tnum)
{
    Obj result;
    Obj typestr;

    typestr = ELM_PLIST(typeStrings, tnum + 1);
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

static Obj SyntaxTreeArgcompInt(UInt i)
{
    return INTOBJ_INT(i);
}

static Obj SyntaxTreeRNam(Expr expr)
{
    return NAME_RNAM(expr);
}

static Obj SyntaxTreeRefLVar(Obj result, Expr expr)
{
    AssPRec(result, RNamName("lvar"), INTOBJ_INT(LVAR_REFLVAR(expr)));
    return result;
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
                // handle 0 to properly deal with T_LIST_EXPR
                Obj obj = subexpr ? SyntaxTreeCompiler(subexpr) : 0;
                PushPlist(compiled, obj);
            }
        }

        AssPRec(result, rnam, compiled);
    }
    return result;
}

static Obj SyntaxTreeEvalCompiler(Obj result, Expr expr)
{
    AssPRec(result, RNamName("value"), EVAL_EXPR(expr));
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

static Obj SyntaxTreeFloatLazy(Obj result, Expr expr)
{
    Obj string;

    string = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 1));
    AssPRec(result, RNamName("value"), string);
    return result;
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
    SWITCH_TO_NEW_LVARS(func, narg, nloc, oldFrame);
    stats = SyntaxTreeCompiler(OFFSET_FIRST_STAT);
    SWITCH_TO_OLD_LVARS(oldFrame);

    AssPRec(result, RNamName("stats"), stats);

    return result;
}

static const CompilerT Compilers[] = {
    COMPILER_(T_PROCCALL_0ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_PROCCALL_1ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_PROCCALL_2ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_PROCCALL_3ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_PROCCALL_4ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_PROCCALL_5ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_PROCCALL_6ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_PROCCALL_XARGS, ARG_("funcref"), ARGS("args")),

    COMPILER_(T_PROCCALL_OPTS, ARG_("opts"), ARG_("call")),

    COMPILER_(T_EMPTY),

    COMPILER_(T_SEQ_STAT, ARGS("statements")),
    COMPILER_(T_SEQ_STAT2, ARGS("statements")),
    COMPILER_(T_SEQ_STAT3, ARGS("statements")),
    COMPILER_(T_SEQ_STAT4, ARGS("statements")),
    COMPILER_(T_SEQ_STAT5, ARGS("statements")),
    COMPILER_(T_SEQ_STAT6, ARGS("statements")),
    COMPILER_(T_SEQ_STAT7, ARGS("statements")),

    COMPILER(T_IF, SyntaxTreeIf),
    COMPILER(T_IF_ELSE, SyntaxTreeIf),
    COMPILER(T_IF_ELIF, SyntaxTreeIf),
    COMPILER(T_IF_ELIF_ELSE, SyntaxTreeIf),

    COMPILER_(T_FOR, ARG_("variable"), ARG_("collection"), ARGS("body")),
    COMPILER_(T_FOR2, ARG_("variable"), ARG_("collection"), ARGS("body")),
    COMPILER_(T_FOR3, ARG_("variable"), ARG_("collection"), ARGS("body")),

    COMPILER_(
        T_FOR_RANGE, ARG_("variable"), ARG_("collection"), ARGS("body")),
    COMPILER_(
        T_FOR_RANGE2, ARG_("variable"), ARG_("collection"), ARGS("body")),
    COMPILER_(
        T_FOR_RANGE3, ARG_("variable"), ARG_("collection"), ARGS("body")),

    COMPILER_(T_WHILE, ARG_("condition"), ARGS("body")),
    COMPILER_(T_WHILE2, ARG_("condition"), ARGS("body")),
    COMPILER_(T_WHILE3, ARG_("condition"), ARGS("body")),

    COMPILER_(T_REPEAT, ARG_("condition"), ARGS("body")),
    COMPILER_(T_REPEAT2, ARG_("condition"), ARGS("body")),
    COMPILER_(T_REPEAT3, ARG_("condition"), ARGS("body")),

#ifdef HPCGAP
    COMPILER_(
        T_ATOMIC, ARG_("body"), ARGS("locks")),    // TODO: better output
#endif

    COMPILER_(T_BREAK),
    COMPILER_(T_CONTINUE),
    COMPILER_(T_RETURN_OBJ, ARG_("obj")),
    COMPILER_(T_RETURN_VOID),

    COMPILER_(T_ASS_LVAR, ARG("lvar", SyntaxTreeArgcompInt), ARG_("rhs")),
    COMPILER_(T_UNB_LVAR, ARG("lvar", SyntaxTreeArgcompInt)),

    COMPILER_(T_ASS_HVAR, ARG("hvar", SyntaxTreeArgcompInt), ARG_("rhs")),
    COMPILER_(T_UNB_HVAR, ARG("hvar", SyntaxTreeArgcompInt)),

    COMPILER_(T_ASS_GVAR, ARG("gvar", NameGVar), ARG_("rhs")),
    COMPILER_(T_UNB_GVAR, ARG("gvar", NameGVar)),

    COMPILER_(T_ASS_LIST, ARG_("list"), ARG_("pos"), ARG_("rhs")),
    COMPILER_(T_ASS2_LIST, ARG_("list"), ARG_("pos"), ARG_("rhs")),
    COMPILER_(T_ASSS_LIST, ARG_("list"), ARG_("poss"), ARG_("rhss")),
    COMPILER_(T_ASS_LIST_LEV,
              ARG_("lists"),
              ARG_("pos"),
              ARG_("rhss"),
              ARG("level", SyntaxTreeArgcompInt)),
    COMPILER_(T_ASSS_LIST_LEV,
              ARG_("lists"),
              ARG_("poss"),
              ARG_("rhss"),
              ARG("level", SyntaxTreeArgcompInt)),
    COMPILER_(T_UNB_LIST, ARG_("list"), ARG_("pos")),

    COMPILER_(T_ASS_REC_NAME,
              ARG_("record"),
              ARG("rnam", SyntaxTreeRNam),
              ARG_("rhs")),
    COMPILER_(
        T_ASS_REC_EXPR, ARG_("record"), ARG_("expression"), ARG_("rhs")),
    COMPILER_(T_UNB_REC_NAME, ARG_("record"), ARG("rnam", SyntaxTreeRNam)),
    COMPILER_(T_UNB_REC_EXPR, ARG_("record"), ARG_("expression")),

    COMPILER_(T_ASS_POSOBJ, ARG_("posobj"), ARG_("pos"), ARG_("rhs")),
    COMPILER_(T_UNB_POSOBJ, ARG_("posobj"), ARG_("pos")),

    COMPILER_(T_ASS_COMOBJ_NAME, ARG_("comobj"), ARG("rnam", SyntaxTreeRNam)),
    COMPILER_(
        T_ASS_COMOBJ_EXPR, ARG_("comobj"), ARG_("expression"), ARG_("rhs")),
    COMPILER_(T_UNB_COMOBJ_NAME, ARG_("comobj"), ARG("rnam", SyntaxTreeRNam)),
    COMPILER_(T_UNB_COMOBJ_EXPR, ARG_("comobj"), ARG_("expression")),

    COMPILER_(T_INFO, ARG_("sel"), ARG_("lev"), ARGS("args")),
    COMPILER_(T_ASSERT_2ARGS, ARG_("level"), ARG_("condition")),
    COMPILER_(
        T_ASSERT_3ARGS, ARG_("level"), ARG_("condition"), ARG_("message")),

    COMPILER(T_PRAGMA, SyntaxTreeCompilePragma),

    /* Statements */
    COMPILER_(T_FUNCCALL_0ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_FUNCCALL_1ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_FUNCCALL_2ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_FUNCCALL_3ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_FUNCCALL_4ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_FUNCCALL_5ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_FUNCCALL_6ARGS, ARG_("funcref"), ARGS("args")),
    COMPILER_(T_FUNCCALL_XARGS, ARG_("funcref"), ARGS("args")),

    COMPILER(T_FUNC_EXPR, SyntaxTreeFuncExpr),

    COMPILER_(T_FUNCCALL_OPTS, ARG_("opts"), ARG_("call")),


    COMPILER_(T_OR, ARG_("left"), ARG_("right")),
    COMPILER_(T_AND, ARG_("left"), ARG_("right")),
    COMPILER_(T_NOT, ARG_("op")),
    COMPILER_(T_EQ, ARG_("left"), ARG_("right")),
    COMPILER_(T_NE, ARG_("left"), ARG_("right")),
    COMPILER_(T_LT, ARG_("left"), ARG_("right")),
    COMPILER_(T_GE, ARG_("left"), ARG_("right")),
    COMPILER_(T_GT, ARG_("left"), ARG_("right")),
    COMPILER_(T_LE, ARG_("left"), ARG_("right")),
    COMPILER_(T_IN, ARG_("left"), ARG_("right")),
    COMPILER_(T_SUM, ARG_("left"), ARG_("right")),
    COMPILER_(T_AINV, ARG_("op")),
    COMPILER_(T_DIFF, ARG_("left"), ARG_("right")),
    COMPILER_(T_PROD, ARG_("left"), ARG_("right")),
    COMPILER_(T_QUO, ARG_("left"), ARG_("right")),
    COMPILER_(T_MOD, ARG_("left"), ARG_("right")),
    COMPILER_(T_POW, ARG_("left"), ARG_("right")),

    COMPILER(T_INTEXPR, SyntaxTreeEvalCompiler),
    COMPILER(T_INT_EXPR, SyntaxTreeEvalCompiler),
    COMPILER_(T_TRUE_EXPR),
    COMPILER_(T_FALSE_EXPR),
    COMPILER_(T_TILDE_EXPR),
    COMPILER(T_CHAR_EXPR, SyntaxTreeEvalCompiler),
    COMPILER_(T_PERM_EXPR, ARGS("cycles")),
    COMPILER_(T_PERM_CYCLE, ARGS("points")),
    COMPILER_(T_LIST_EXPR, ARGS("list")),
    COMPILER_(T_LIST_TILDE_EXPR, ARGS("list")),
    COMPILER(T_RANGE_EXPR, SyntaxTreeRangeExpr),
    COMPILER(T_STRING_EXPR, SyntaxTreeEvalCompiler),
    COMPILER(T_REC_EXPR, SyntaxTreeRecExpr),
    COMPILER_(T_REC_TILDE_EXPR),

    COMPILER(T_FLOAT_EXPR_EAGER, SyntaxTreeEvalCompiler),
    COMPILER(T_FLOAT_EXPR_LAZY, SyntaxTreeFloatLazy),

    // T_REFLVAR is encoded differently from all other
    //           references to LVARs, so we have to treat
    //           them specially here
    COMPILER(T_REFLVAR, SyntaxTreeRefLVar),
    COMPILER_(T_ISB_LVAR, ARG("lvar", SyntaxTreeArgcompInt)),

    COMPILER_(T_REF_HVAR, ARG("hvar", SyntaxTreeArgcompInt)),
    COMPILER_(T_ISB_HVAR, ARG("hvar", SyntaxTreeArgcompInt)),

    COMPILER_(T_REF_GVAR, ARG("gvar", NameGVar)),
    COMPILER_(T_ISB_GVAR, ARG("gvar", NameGVar)),

    // TODO: can this be unified?
    COMPILER_(T_ELM_LIST, ARG_("list"), ARG_("pos")),
    COMPILER_(T_ELM2_LIST, ARG_("list"), ARG_("pos1"), ARG_("pos2")),
    COMPILER_(T_ELMS_LIST, ARG_("list"), ARG_("poss")),
    COMPILER_(T_ELM_LIST_LEV, ARG_("lists"), ARG_("pos"), ARG_("level")),
    COMPILER_(T_ELMS_LIST_LEV, ARG_("lists"), ARG_("poss"), ARG_("level")),
    COMPILER_(T_ISB_LIST, ARG_("list"), ARG_("pos")),
    COMPILER_(T_ELM_REC_NAME, ARG_("record"), ARG("name", SyntaxTreeRNam)),
    COMPILER_(T_ELM_REC_EXPR, ARG_("record"), ARG_("expression")),
    COMPILER_(T_ISB_REC_NAME, ARG_("record"), ARG("name", SyntaxTreeRNam)),
    COMPILER_(T_ISB_REC_EXPR, ARG_("record"), ARG_("expression")),
    COMPILER_(T_ELM_POSOBJ, ARG_("posobj"), ARG_("pos")),
    COMPILER_(T_ISB_POSOBJ, ARG_("posobj"), ARG_("pos")),
    COMPILER_(T_ELM_COMOBJ_NAME, ARG_("comobj"), ARG("name", SyntaxTreeRNam)),
    COMPILER_(T_ELM_COMOBJ_EXPR, ARG_("comobj"), ARG_("expression")),
    COMPILER_(T_ISB_COMOBJ_NAME, ARG_("comobj"), ARG("name", SyntaxTreeRNam)),
    COMPILER_(T_ISB_COMOBJ_EXPR, ARG_("comobj"), ARG_("expression")),
};

static Obj FuncSYNTAX_TREE(Obj self, Obj func)
{
    Obj result;

    if (!IS_FUNC(func) || IsKernelFunction(func) || IS_OPERATION(func)) {
        RequireArgument("SYNTAX_TREE", func, "must be a plain GAP function");
    }

    result = NewSyntaxTreeNode(T_FUNC_EXPR);
    return SyntaxTreeFunc(result, func);
}

static StructGVarFunc GVarFuncs[] = { GVAR_FUNC(SYNTAX_TREE, 1, "func"),
                                      { 0, 0, 0, 0, 0 } };

static Int InitKernel(StructInitInfo * module)
{
    /* init filters and functions */
    InitHdlrFuncsFromTable(GVarFuncs);

    InitGlobalBag(&typeStrings, "typeStrings");

    return 0;
}

static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions */
    InitGVarFuncsFromTable(GVarFuncs);

    typeStrings = NEW_PLIST(T_PLIST, ARRAY_SIZE(Compilers));
    for (UInt tnum = 0; tnum < ARRAY_SIZE(Compilers); tnum++) {
        const char * str = Compilers[tnum].name;
        if (str)
            ASS_LIST(typeStrings, tnum + 1, MakeImmString(str));
    }

    /* return success */
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
