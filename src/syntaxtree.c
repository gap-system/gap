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

#include <stdarg.h>
#include <ctype.h>

typedef Obj (*CompileFuncT)(Obj node, Expr expr);
typedef Obj (*CompileArgT)(Expr expr);

typedef struct {
    const Char * argname;
    CompileArgT  argcomp;
} ArgT;

typedef struct {
    UInt         tnum;
    CompileFuncT compile;
    const Char * name;
    UInt         arity;
    ArgT         args[4]; /* The maximum compiler arity is currently 4 */
} CompilerT;

// We put compilers for statements and expressions into the same static array,
// assuming that the set of their respective ids are disjoint.
static const CompilerT Compilers[];
#define COMPILER_ARITY(...) (sizeof((ArgT[]){ __VA_ARGS__ }) / sizeof(ArgT))
#define COMPILER(tnum, compiler, ...)                                        \
    [tnum] = {                                                               \
        tnum, compiler, #tnum, COMPILER_ARITY(__VA_ARGS__), { __VA_ARGS__ }  \
    }

#define COMPILER_(tnum, ...)                                                 \
    COMPILER(tnum, SyntaxTreeDefaultCompiler, __VA_ARGS__)

#define ARG(name, func)                                                      \
    {                                                                        \
        name, func                                                           \
    }
#define ARG_(name) ARG(name, SyntaxTreeCompiler)

static Obj SyntaxTreeFunc(Obj result, Obj func);

static inline Obj NewSyntaxTreeNode(const char * type)
{
    Obj result;
    Obj typestr;

    typestr = MakeImmString(type);
    result = NEW_PREC(2);
    AssPRec(result, RNamName("type"), typestr);

    return result;
}

static Obj SyntaxTreeCompiler(Expr expr)
{
    Obj       result;
    UInt      tnum;
    CompilerT comp;

    // TODO: GAP_ASSERT
    tnum = TNUM_EXPR(expr);
    comp = Compilers[tnum];

    result = NewSyntaxTreeNode(comp.name);

    comp.compile(result, expr);

    return result;
}

static Obj SyntaxTreeArgcompInt(UInt i)
{
    return INTOBJ_INT(i);
}

static Obj SyntaxTreeRefLVar(Obj result, Expr expr)
{
    return INTOBJ_INT(LVAR_REFLVAR(expr));
}

static Obj SyntaxTreeDefaultCompiler(Obj result, Expr expr)
{
    int       i;
    UInt      tnum;
    CompilerT comp;

    // TODO: GAP_ASSERT tnum range
    tnum = TNUM_EXPR(expr);
    comp = Compilers[tnum];

    for (i = 0; i < comp.arity; i++) {
        AssPRec(result, RNamName(comp.args[i].argname),
                comp.args[i].argcomp(READ_EXPR(expr, i)));
    }
    return result;
}

static Obj SyntaxTreeEvalCompiler(Obj result, Expr expr)
{
    UInt      tnum;
    CompilerT comp;

    // TODO: GAP_ASSERT tnum range
    tnum = TNUM_EXPR(expr);
    comp = Compilers[tnum];
    GAP_ASSERT(comp.arity == 1);

    AssPRec(result, RNamName(comp.args[0].argname), EVAL_EXPR(expr));
    return result;
}


static Obj SyntaxTreeFunccall(Obj result, Expr expr)
{
    Obj  func;
    Obj  args, argi;
    UInt narg, i;

    func = SyntaxTreeCompiler(FUNC_CALL(expr));
    AssPRec(result, RNamName("funcref"), func);

    /* compile the argument expressions */
    narg = NARG_SIZE_CALL(SIZE_EXPR(expr));
    args = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(args, narg);

    for (i = 1; i <= narg; i++) {
        argi = SyntaxTreeCompiler(ARGI_CALL(expr, i));
        SET_ELM_PLIST(args, i, argi);
        CHANGED_BAG(args);
    }
    AssPRec(result, RNamName("args"), args);
    return result;
}

static Obj SyntaxTreeFuncExpr(Obj result, Expr expr)
{
    Obj fexp = GET_VALUE_FROM_CURRENT_BODY(READ_EXPR(expr, 0));

    SyntaxTreeFunc(result, fexp);

    return result;
}

static Obj SyntaxTreePermExpr(Obj result, Expr expr)
{
    Obj  cycles;
    Obj  cycle;
    Obj  val;
    Expr cycleexpr;
    Int  csize, n;
    Int  i, j;

    /* determine number of cycles */
    n = SIZE_EXPR(expr) / sizeof(Expr);
    cycles = NEW_PLIST(T_PLIST, n);
    AssPRec(result, RNamName("cycles"), cycles);
    SET_LEN_PLIST(cycles, n);

    /* enter cycles */
    for (i = 1; i <= n; i++) {
        cycleexpr = READ_EXPR(expr, i - 1);
        csize = SIZE_EXPR(cycleexpr) / sizeof(Expr);
        cycle = NEW_PLIST(T_PLIST, csize);
        SET_LEN_PLIST(cycle, csize);
        SET_ELM_PLIST(cycles, i, cycle);
        CHANGED_BAG(cycles);

        /* entries of the cycle */
        for (j = 1; j <= csize; j++) {
            val = SyntaxTreeCompiler(READ_EXPR(cycleexpr, j - 1));
            SET_ELM_PLIST(cycle, j, val);
            CHANGED_BAG(cycle);
        }
    }
    return result;
}

static Obj SyntaxTreeListExpr(Obj result, Expr expr)
{
    Obj list;
    Int len;
    Int i;

    len = SIZE_EXPR(expr) / sizeof(Expr);

    list = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(list, len);

    for (i = 1; i <= len; i++) {
        if (READ_EXPR(expr, i - 1) == 0) {
            continue;
        }
        else {
            SET_ELM_PLIST(list, i,
                          SyntaxTreeCompiler(READ_EXPR(expr, i - 1)));
            CHANGED_BAG(list);
        }
    }

    AssPRec(result, RNamName("list"), list);

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
    SET_LEN_PLIST(list, len);

    for (i = 1; i <= len; i++) {
        tmp = READ_EXPR(expr, 2 * i - 2);
        GAP_ASSERT(tmp != 0);

        subrec = NEW_PREC(2);
        SET_ELM_PLIST(list, i, subrec);
        CHANGED_BAG(list);

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
    UInt len;
    Obj  string;

    len = READ_EXPR(expr, 0);
    string = NEW_STRING(len);
    memcpy(CHARS_STRING(string),
           (const char *)CONST_ADDR_EXPR(expr) + 2 * sizeof(UInt), len);
    AssPRec(result, RNamName("value"), string);
    return result;
}

static Obj SyntaxTreeRNam(Expr expr)
{
    return NAME_RNAM(expr);
}

static Obj SyntaxTreeSeqStat(Obj result, Stat stat)
{
    Obj  list;
    UInt nr;
    UInt i;

    /* get the number of statements */
    nr = SIZE_STAT(stat) / sizeof(Stat);
    list = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(list, nr);

    /* compile the statements */
    for (i = 1; i <= nr; i++) {
        SET_ELM_PLIST(list, i, SyntaxTreeCompiler(READ_STAT(stat, i - 1)));
        CHANGED_BAG(list);
    }
    AssPRec(result, RNamName("statements"), list);

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
    SET_LEN_PLIST(branches, nr);

    AssPRec(result, RNamName("branches"), branches);

    cond = SyntaxTreeCompiler(READ_STAT(stat, 0));
    then = SyntaxTreeCompiler(READ_STAT(stat, 1));

    for (i = 0; i < nr; i++) {
        cond = SyntaxTreeCompiler(READ_STAT(stat, 2 * i));
        then = SyntaxTreeCompiler(READ_STAT(stat, 2 * i + 1));

        pair = NEW_PREC(2);
        AssPRec(pair, RNamName("condition"), cond);
        AssPRec(pair, RNamName("body"), then);

        SET_ELM_PLIST(branches, i + 1, pair);
        CHANGED_BAG(branches);
    }
    return result;
}

static Obj SyntaxTreeFor(Obj result, Stat stat)
{
    Obj  body;
    UInt i, nr;

    AssPRec(result, RNamName("variable"),
            SyntaxTreeCompiler(READ_STAT(stat, 0)));
    AssPRec(result, RNamName("collection"),
            SyntaxTreeCompiler(READ_STAT(stat, 1)));

    nr = SIZE_STAT(stat) / sizeof(Stat) - 2;
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for (i = 2; i < 2 + nr; i++) {
        SET_ELM_PLIST(body, i - 1, SyntaxTreeCompiler(READ_STAT(stat, i)));
        CHANGED_BAG(body);
    }

    return result;
}

static Obj SyntaxTreeWhile(Obj result, Stat stat)
{
    Obj  condition;
    Obj  body;
    UInt nr, i;

    condition = SyntaxTreeCompiler(READ_STAT(stat, 0));
    AssPRec(result, RNamName("condition"), condition);

    nr = SIZE_STAT(stat) / sizeof(Stat) - 1;
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for (i = 1; i < 1 + nr; i++) {
        SET_ELM_PLIST(body, i, SyntaxTreeCompiler(READ_STAT(stat, i)));
        CHANGED_BAG(body);
    }

    return result;
}

static Obj SyntaxTreeRepeat(Obj result, Stat stat)
{
    Obj  cond;
    Obj  body;
    UInt i, nr;

    cond = SyntaxTreeCompiler(READ_STAT(stat, 0));
    AssPRec(result, RNamName("condition"), cond);

    nr = SIZE_STAT(stat) / sizeof(Stat) - 1;
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for (i = 1; i < 1 + nr; i++) {
        SET_ELM_PLIST(body, i, SyntaxTreeCompiler(READ_STAT(stat, i)));
        CHANGED_BAG(body);
    }

    return result;
}

static Obj SyntaxTreeInfo(Obj result, Stat stat)
{
    Obj  sel;
    Obj  lev;
    Obj  lst;
    Obj  tmp;
    UInt narg, i;

    sel = SyntaxTreeCompiler(ARGI_INFO(stat, 1));
    lev = SyntaxTreeCompiler(ARGI_INFO(stat, 2));

    AssPRec(result, RNamName("sel"), sel);
    AssPRec(result, RNamName("lev"), lev);

    narg = NARG_SIZE_INFO(SIZE_STAT(stat)) - 2;
    lst = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(lst, narg);

    for (i = 1; i <= narg; i++) {
        tmp = SyntaxTreeCompiler(ARGI_INFO(stat, i + 2));
        SET_ELM_PLIST(lst, i, tmp);
        CHANGED_BAG(lst);
    }
    AssPRec(result, RNamName("args"), lst);

    return result;
}

static Obj SyntaxTreeElmList(Obj result, Stat stat)
{
    Obj list, refs;
    Int nr;
    Int i;

    list = SyntaxTreeCompiler(READ_STAT(stat, 0));
    AssPRec(result, RNamName("list"), list);

    nr = SIZE_STAT(stat) / sizeof(Stat) - 1;

    refs = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(refs, nr);
    AssPRec(result, RNamName("refs"), refs);

    for (i = 1; i < 1 + nr; i++) {
        SET_ELM_PLIST(refs, i, SyntaxTreeCompiler(READ_STAT(stat, i)));
        CHANGED_BAG(refs);
    }
    return result;
}

static Obj SyntaxTreeFunc(Obj result, Obj func)
{
    Obj str;
    Obj stats;
    Obj argnams;
    Obj locnams;

    Bag oldFrame;
    Int narg;
    Int nloc;
    Int i;

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

    /* names of arguments */
    argnams = NEW_PLIST(T_PLIST, narg);
    SET_LEN_PLIST(argnams, narg);
    AssPRec(result, RNamName("argnams"), argnams);
    for (i = 1; i <= narg; i++) {
        /* TODO: Check if it ever happens that a plain gap
           function has unnamed arguments/local variables */
        if (NAMI_FUNC(func, i) != 0) {
            str = CopyToStringRep(NAMI_FUNC(func, i));
            SET_ELM_PLIST(argnams, i, str);
            CHANGED_BAG(argnams);
        }
    }

    /* names of local variables */
    nloc = NLOC_FUNC(func);
    AssPRec(result, RNamName("nloc"), INTOBJ_INT(nloc));
    locnams = NEW_PLIST(T_PLIST, nloc);
    SET_LEN_PLIST(locnams, nloc);
    AssPRec(result, RNamName("locnams"), locnams);
    for (i = 1; i <= nloc; i++) {
        if (NAMI_FUNC(func, narg + i) != 0) {
            str = CopyToStringRep(NAMI_FUNC(func, narg + i));
            SET_ELM_PLIST(locnams, i, str);
            CHANGED_BAG(locnams);
        }
    }

    /* switch to this function (so that 'READ_STAT' and 'READ_EXPR' work) */
    SWITCH_TO_NEW_LVARS(func, narg, nloc, oldFrame);
    stats = SyntaxTreeCompiler(OFFSET_FIRST_STAT);
    SWITCH_TO_OLD_LVARS(oldFrame);

    AssPRec(result, RNamName("stats"), stats);

    return result;
}

static const CompilerT Compilers[] = {
    COMPILER(T_PROCCALL_0ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_1ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_2ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_3ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_4ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_5ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_6ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_XARGS, SyntaxTreeFunccall),

    COMPILER_(T_PROCCALL_OPTS,
              ARG_("opts"),
              ARG_("call")),

    COMPILER_(T_EMPTY),

    COMPILER(T_SEQ_STAT, SyntaxTreeSeqStat),
    COMPILER(T_SEQ_STAT2, SyntaxTreeSeqStat),
    COMPILER(T_SEQ_STAT3, SyntaxTreeSeqStat),
    COMPILER(T_SEQ_STAT4, SyntaxTreeSeqStat),
    COMPILER(T_SEQ_STAT5, SyntaxTreeSeqStat),
    COMPILER(T_SEQ_STAT6, SyntaxTreeSeqStat),
    COMPILER(T_SEQ_STAT7, SyntaxTreeSeqStat),

    COMPILER(T_IF, SyntaxTreeIf),
    COMPILER(T_IF_ELSE, SyntaxTreeIf),
    COMPILER(T_IF_ELIF, SyntaxTreeIf),
    COMPILER(T_IF_ELIF_ELSE, SyntaxTreeIf),

    COMPILER(T_FOR, SyntaxTreeFor),
    COMPILER(T_FOR2, SyntaxTreeFor),
    COMPILER(T_FOR3, SyntaxTreeFor),

    COMPILER(T_FOR_RANGE, SyntaxTreeFor),
    COMPILER(T_FOR_RANGE2, SyntaxTreeFor),
    COMPILER(T_FOR_RANGE3, SyntaxTreeFor),

    COMPILER(T_WHILE, SyntaxTreeWhile),
    COMPILER(T_WHILE2, SyntaxTreeWhile),
    COMPILER(T_WHILE3, SyntaxTreeWhile),

    COMPILER(T_REPEAT, SyntaxTreeRepeat),
    COMPILER(T_REPEAT2, SyntaxTreeRepeat),
    COMPILER(T_REPEAT3, SyntaxTreeRepeat),

#ifdef HPCGAP
    COMPILER_(T_ATOMIC),
#endif

    COMPILER_(T_BREAK),
    COMPILER_(T_CONTINUE),
    COMPILER_(T_RETURN_OBJ, ARG_("obj")),
    COMPILER_(T_RETURN_VOID),

    COMPILER_(T_ASS_LVAR, ARG("lvar", SyntaxTreeArgcompInt), ARG_("rhs")),
    COMPILER_(T_UNB_LVAR, ARG("lvar", SyntaxTreeArgcompInt)),

    COMPILER_(T_ASS_HVAR, ARG("hvar", SyntaxTreeArgcompInt), ARG_("rhs")),
    COMPILER_(T_UNB_HVAR, ARG("hvar", SyntaxTreeArgcompInt)),

    COMPILER_(T_ASS_GVAR, ARG("gvar", SyntaxTreeArgcompInt), ARG_("rhs")),
    COMPILER_(T_UNB_GVAR, ARG("gvar", SyntaxTreeArgcompInt)),

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

    COMPILER(T_INFO, SyntaxTreeInfo),
    COMPILER_(T_ASSERT_2ARGS, ARG_("level"), ARG_("condition")),
    COMPILER_(
        T_ASSERT_3ARGS, ARG_("level"), ARG_("condition"), ARG_("message")),

    /* Statements */
    COMPILER(T_FUNCCALL_0ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_1ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_2ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_3ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_4ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_5ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_6ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_XARGS, SyntaxTreeFunccall),

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

    COMPILER(T_INTEXPR, SyntaxTreeEvalCompiler, ARG_("value")),
    COMPILER(T_INT_EXPR, SyntaxTreeEvalCompiler, ARG_("value")),
    COMPILER_(T_TRUE_EXPR),
    COMPILER_(T_FALSE_EXPR),
    COMPILER_(T_TILDE_EXPR),
    COMPILER(T_CHAR_EXPR, SyntaxTreeEvalCompiler, ARG_("value")),
    COMPILER(T_PERM_EXPR, SyntaxTreePermExpr),
    COMPILER_(T_PERM_CYCLE),
    COMPILER(T_LIST_EXPR, SyntaxTreeListExpr),
    COMPILER(T_LIST_TILDE_EXPR, SyntaxTreeListExpr),
    COMPILER(T_RANGE_EXPR, SyntaxTreeRangeExpr),
    COMPILER(T_STRING_EXPR, SyntaxTreeEvalCompiler, ARG_("string")),
    COMPILER(T_REC_EXPR, SyntaxTreeRecExpr),
    COMPILER_(T_REC_TILDE_EXPR),

    COMPILER(T_FLOAT_EXPR_EAGER, SyntaxTreeEvalCompiler, ARG_("value")),
    COMPILER(T_FLOAT_EXPR_LAZY, SyntaxTreeFloatLazy),

    // T_REFLVAR is encoded differently from all other
    //           references to LVARs, so we have to treat
    //           them specially here
    COMPILER(T_REFLVAR, SyntaxTreeRefLVar),
    COMPILER_(T_ISB_LVAR, ARG("lvar", SyntaxTreeArgcompInt)),

    COMPILER_(T_REF_HVAR, ARG("hvar", SyntaxTreeArgcompInt)),
    COMPILER_(T_ISB_HVAR, ARG("hvar", SyntaxTreeArgcompInt)),

    COMPILER_(T_REF_GVAR, ARG("gvar", SyntaxTreeArgcompInt)),
    COMPILER_(T_ISB_GVAR, ARG("gvar", SyntaxTreeArgcompInt)),

    // TODO: can this be unified?
    COMPILER_(T_ELM_LIST, ARG_("list"), ARG_("pos")),
    COMPILER(T_ELM2_LIST, SyntaxTreeElmList),
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

    result = NewSyntaxTreeNode("T_FUNC_EXPR");
    return SyntaxTreeFunc(result, func);
}

static StructGVarFunc GVarFuncs[] = { GVAR_FUNC(SYNTAX_TREE, 1, "func"),
                                      { 0, 0, 0, 0, 0 } };

static Int InitKernel(StructInitInfo * module)
{
    /* init filters and functions */
    InitHdlrFuncsFromTable(GVarFuncs);

    return 0;
}

static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions */
    InitGVarFuncsFromTable(GVarFuncs);

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
