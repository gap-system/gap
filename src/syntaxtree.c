/****************************************************************************
**
*W  syntaxtree.c
**
**
** TODO:
**  - Expressions vs Statements
**  - Documentation
**  - Compiler functions per argument (will make more separate functions go away)
**  - Floats
**  - Tilde
**  - Reconsider LVar, GVar, and HVar references
**  - what about T_SEQ_STATN?
** 
*/
#include "system.h"
#include <stdarg.h>

#include "code.h"
#include "gasman.h"
#include "objects.h"

#include "exprs.h"
#include "gapstate.h"
#include "stats.h"

#include "compiled.h"
#include "vars.h"

#include <ctype.h>

typedef UInt4 LVar;
typedef UInt4 HVar;
typedef UInt  GVar;

typedef Obj (*CompileFuncT)(Obj node, Expr expr);
typedef Obj (*CompileArgT)(Expr expr);

typedef struct {
    const Char *argname;
    CompileArgT argcomp;
} ArgT;

typedef struct {
    UInt         tnum;
    CompileFuncT compile;
    const Char * name;
    UInt         arity;
    ArgT         args[6]; /* This is not really a restriction */
} CompilerT;

static const CompilerT StatCompilers[];
static const CompilerT ExprCompilers[];

#define COMPILER_ARITY(...)                                                  \
    (sizeof((ArgT []){ __VA_ARGS__ }) / sizeof(ArgT))
#define COMPILER(tnum, compiler, ...)                                        \
    {                                                                        \
        tnum, compiler, #tnum, COMPILER_ARITY(__VA_ARGS__),                  \
        {                                                                    \
            __VA_ARGS__                                                      \
        }                                                                    \
    }

#define COMPILER_(tnum,...) COMPILER(tnum, SyntaxTreeDefaultCompiler, __VA_ARGS__)

#define ARG(name, func) \
    { name, func }
#define ARG_(name) ARG(name, SyntaxTreeCompiler)

static inline Obj SyntaxTreeFunc(Obj result, Obj func);

static inline Obj NewSyntaxTreeNode(const char * type)
{
    Obj result;
    Obj typestr;

    C_NEW_STRING_DYN(typestr, type);
    result = NEW_PREC(1);
    AssPRec(result, RNamName("type"), typestr);

    return result;
}

static Obj SyntaxTreeCompiler(Expr expr)
{
    Obj       result;
    UInt      tnum;
    CompilerT comp;

    tnum = TNUM_EXPR(expr);

    if (tnum < 128) {
        comp = StatCompilers[tnum];
    }
    else if ((128 <= tnum) && (tnum < 256)) {
        comp = ExprCompilers[tnum - 128];
    }
    else {
        // error
    }

    result = NewSyntaxTreeNode(comp.name);

    comp.compile(result, expr);

    return result;
}

static Obj SyntaxTreeIntObjInt(UInt i)
{
    return INTOBJ_INT(i);
}

static Obj SyntaxTreeDefaultCompiler(Obj result, Expr expr)
{
    int       i;
    UInt      tnum;
    CompilerT comp;

    tnum = TNUM_EXPR(expr);

    if (tnum < 128) {
        comp = StatCompilers[tnum];
    }
    else if ((128 <= tnum) && (tnum < 256)) {
        comp = ExprCompilers[tnum - 128];
    }
    else {
        // error
    }

    for (i = 0; i < comp.arity; i++) {
        AssPRec(result, RNamName(comp.args[i].argname),
                comp.args[i].argcomp(ADDR_EXPR(expr)[i]));
    }
    return result;
}

Obj SyntaxTreeFunccall(Obj result, Expr expr)
{
    Obj  func;
    Obj  args, argi;
    UInt narg, i;

    func = SyntaxTreeCompiler(FUNC_CALL(expr));
    AssPRec(result, RNamName("function"), func);

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

Obj SyntaxTreeFuncExpr(Obj result, Expr expr)
{
    Obj fexs;
    Obj fexp;

    fexs = FEXS_FUNC(CURR_FUNC());
    fexp = ELM_PLIST(fexs, ((Int *)ADDR_EXPR(expr))[0]);

    SyntaxTreeFunc(result, fexp);

    return result;
}

Obj SyntaxTreeIntExpr(Obj result, Expr expr)
{
    Obj  value;
    UInt size;
    UInt typ;

    if (IS_INTEXPR(expr)) {
        value = OBJ_INTEXPR(expr);
    }
    else {
        size = SIZE_EXPR(expr) - sizeof(UInt);
        typ = *(UInt *)ADDR_EXPR(expr);
        value = C_MAKE_INTEGER_BAG(size, typ);
        memcpy(ADDR_OBJ(value), (void *)(&ADDR_EXPR(expr)[1]), size);
    }

    AssPRec(result, RNamName("value"), value);

    return result;
}

Obj SyntaxTreeCharExpr(Obj result, Expr expr)
{
    Obj value;

    value = NewBag(T_CHAR, 1);
    *(UChar*)ADDR_OBJ(value) = (UChar)ADDR_EXPR(expr)[0];

    AssPRec(result, RNamName("result"), value);

    return result;
}

Obj SyntaxTreePermExpr(Obj result, Expr expr)
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
        cycleexpr = ADDR_EXPR(expr)[i - 1];
        csize = SIZE_EXPR(cycleexpr) / sizeof(Expr);
        cycle = NEW_PLIST(T_PLIST, csize);
        SET_LEN_PLIST(cycle, csize);
        SET_ELM_PLIST(cycles, i, cycle);
        CHANGED_BAG(cycles);

        /* entries of the cycle */
        for (j = 1; j <= csize; j++) {
            val = SyntaxTreeCompiler(ADDR_EXPR(cycleexpr)[j - 1]);
            SET_ELM_PLIST(cycle, j, val);
            CHANGED_BAG(cycle);
        }
    }
    return result;
}

Obj SyntaxTreeListExpr(Obj result, Expr expr)
{
    Obj list;
    Int len;
    Int i;

    len = SIZE_EXPR(expr) / sizeof(Expr);

    list = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(list, len);

    for (i = 1; i <= len; i++) {
        if (ADDR_EXPR(expr)[i - 1] == 0) {
            continue;
        }
        else {
            SET_ELM_PLIST(list, i,
                          SyntaxTreeCompiler(ADDR_EXPR(expr)[i - 1]));
            CHANGED_BAG(list);
        }
    }

    AssPRec(result, RNamName("list"), list);

    return result;
}

Obj SyntaxTreeRangeExpr(Obj result, Expr expr)
{
    Obj first;
    Obj second;
    Obj last;

    if (SIZE_EXPR(expr) == 2 * sizeof(Expr)) {
        first = SyntaxTreeCompiler(ADDR_EXPR(expr)[0]);
        last = SyntaxTreeCompiler(ADDR_EXPR(expr)[1]);

        AssPRec(result, RNamName("first"), first);
        AssPRec(result, RNamName("last"), last);
    }
    else {
        first = SyntaxTreeCompiler(ADDR_EXPR(expr)[0]);
        second = SyntaxTreeCompiler(ADDR_EXPR(expr)[1]);
        last = SyntaxTreeCompiler(ADDR_EXPR(expr)[2]);

        AssPRec(result, RNamName("first"), first);
        AssPRec(result, RNamName("second"), second);
        AssPRec(result, RNamName("last"), last);
    }

    return result;
}

Obj SyntaxTreeStringExpr(Obj result, Expr expr)
{
    Obj string;

    C_NEW_STRING(string, SIZE_EXPR(expr) - 1 - sizeof(UInt),
                 sizeof(UInt) + (Char *)ADDR_EXPR(expr));

    AssPRec(result, RNamName("string"), string);

    return result;
}

/* TODO: Maybe return a record or a list with key/value pairs? */
Obj SyntaxTreeRecExpr(Obj result, Expr expr)
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
        // Check whether this can happen and *why*
        tmp = ADDR_EXPR(expr)[2 * i - 2];
        if (tmp == 0) {
            continue;
        }
        else {
            subrec = NEW_PREC(2);
            SET_ELM_PLIST(list, i, subrec);
            CHANGED_BAG(list);

            if (IS_INTEXPR(tmp)) {
                key = NAME_OBJ_RNAM((UInt)INT_INTEXPR(tmp));
            }
            else {
                key = SyntaxTreeCompiler(tmp);
            }
            AssPRec(subrec, RNamName("key"), key);

            tmp = ADDR_EXPR(expr)[2 * i - 1];
            val = SyntaxTreeCompiler(tmp);
            AssPRec(subrec, RNamName("value"), val);
        }
    }
    AssPRec(result, RNamName("keyvalue"), list);

    return result;
}

/* TODO: Make this work */
Obj SyntaxTreeFloatEager(Obj result, Expr expr)
{
    return result;
}

/* TODO: Make this work */
Obj SyntaxTreeFloatLazy(Obj result, Expr expr)
{
    return result;
}

Obj SyntaxTreeLVar(Expr expr)
{
    LVar lvar;

    if (IS_REFLVAR(expr)) {
        lvar = LVAR_REFLVAR(expr);
    } else {
        lvar = (LVar)(ADDR_EXPR(expr)[0]);
    }

    return INTOBJ_INT(lvar);
}

Obj SyntaxTreeHVar(Expr expr)
{
    HVar hvar;

    hvar = (HVar)(expr);
    return INTOBJ_INT(hvar);
}

Obj SyntaxTreeGVar(Expr expr)
{
  return NameGVarObj((GVar)(expr));
}

Obj SyntaxTreeRefLVar(Obj result, Expr expr)
{
    AssPRec(result, RNamName("lvar"), SyntaxTreeLVar(expr));
    return result;
}
/*

Obj SyntaxTreeRefHVar(Obj result, Expr expr)
{
    AssPRec(result, RNamName("hvar"), SyntaxTreeHVar(expr));
    return result;
}
*/

Obj SyntaxTreeRefGVar(Obj result, Expr expr)
{
    AssPRec(result, RNamName("gvar"), SyntaxTreeGVar(expr));
    return result;
}

Obj SyntaxTreeRNam(Expr expr)
{
    Obj rnam;

    rnam = NAME_OBJ_RNAM(expr);
    return rnam;
}

Obj SyntaxTreeSeqStat(Obj result, Stat stat)
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
        SET_ELM_PLIST(list, i, SyntaxTreeCompiler(ADDR_STAT(stat)[i - 1]));
        CHANGED_BAG(list);
    }
    AssPRec(result, RNamName("statements"), list);

    return result;
}

Obj SyntaxTreeIf(Obj result, Stat stat)
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

    cond = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    then = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);

    for (i = 0; i < nr; i++) {
        cond = SyntaxTreeCompiler(ADDR_STAT(stat)[2 * i]);
        then = SyntaxTreeCompiler(ADDR_STAT(stat)[2 * i + 1]);

        if(cond==0) {
          fprintf(stderr, "cond 0, else?\n");
        }
        pair = NEW_PREC(2);
        AssPRec(pair, RNamName("condition"), cond);
        AssPRec(pair, RNamName("stats"), then);

        SET_ELM_PLIST(branches, i + 1, pair);
        CHANGED_BAG(branches);
    }
    return result;
}

Obj SyntaxTreeFor(Obj result, Stat stat)
{
    Obj  body;
    UInt i, nr;

    AssPRec(result, RNamName("variable"),
            SyntaxTreeCompiler(ADDR_STAT(stat)[0]));
    AssPRec(result, RNamName("collection"),
            SyntaxTreeCompiler(ADDR_STAT(stat)[1]));

    nr = SIZE_STAT(stat) / sizeof(Stat) - 2;
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for (i = 2; i < 2 + nr; i++) {
        SET_ELM_PLIST(body, i - 1, SyntaxTreeCompiler(ADDR_STAT(stat)[i]));
        CHANGED_BAG(body);
    }

    return result;
}

Obj SyntaxTreeWhile(Obj result, Stat stat)
{
    Obj  condition;
    Obj  body;
    UInt nr, i;

    condition = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("condition"), condition);

    nr = SIZE_STAT(stat) / sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr - 1);
    SET_LEN_PLIST(body, nr - 1);
    AssPRec(result, RNamName("body"), body);

    for (i = 1; i < nr; i++) {
        SET_ELM_PLIST(body, i, SyntaxTreeCompiler(ADDR_STAT(stat)[i]));
        CHANGED_BAG(body);
    }

    return result;
}

Obj SyntaxTreeRepeat(Obj result, Stat stat)
{
    Obj  cond;
    Obj  body;
    UInt i, nr;

    cond = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("condition"), cond);

    nr = SIZE_STAT(stat) / sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for (i = 1; i < nr; i++) {
        SET_ELM_PLIST(body, i, SyntaxTreeCompiler(ADDR_STAT(stat)[i]));
        CHANGED_BAG(body);
    }

    return result;
}

Obj SyntaxTreeInfo(Obj result, Stat stat)
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
        if (NAMI_FUNC(func, i) != 0) {
            C_NEW_STRING_DYN(str, NAMI_FUNC(func, i));
        }
        else {
            /* TODO: Probably put the number in */
            C_NEW_STRING_DYN(str, "localvar");
        }
        SET_ELM_PLIST(argnams, i, str);
        CHANGED_BAG(argnams);
    }

    /* names of local variables */
    nloc = NLOC_FUNC(func);
    AssPRec(result, RNamName("nloc"), INTOBJ_INT(nloc));
    locnams = NEW_PLIST(T_PLIST, nloc);
    SET_LEN_PLIST(locnams, nloc);
    AssPRec(result, RNamName("locnams"), locnams);
    for (i = 1; i <= nloc; i++) {
        if (NAMI_FUNC(func, narg + i) != 0) {
            C_NEW_STRING_DYN(str, NAMI_FUNC(func, narg + i));
        }
        else {
            /* TODO: Probably put the number in */
            C_NEW_STRING_DYN(str, "localvar");
        }
        SET_ELM_PLIST(locnams, i, str);
        CHANGED_BAG(locnams);
    }

    /* switch to this function (so that 'ADDR_STAT' and 'ADDR_EXPR' work) */
    SWITCH_TO_NEW_LVARS(func, narg, nloc, oldFrame);
    stats = SyntaxTreeCompiler(FIRST_STAT_CURR_FUNC);
    SWITCH_TO_OLD_LVARS(oldFrame);

    AssPRec(result, RNamName("stats"), stats);

    return result;
}

/* TODO: Make this the table for all compilers?
   static CompilerT AllCompilers[256]; */

static const CompilerT StatCompilers[] = {
    COMPILER(T_PROCCALL_0ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_1ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_2ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_3ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_4ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_5ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_6ARGS, SyntaxTreeFunccall),
    COMPILER(T_PROCCALL_XARGS, SyntaxTreeFunccall),

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
    COMPILER_(T_BREAK),
    COMPILER_(T_CONTINUE),
    COMPILER_(T_RETURN_OBJ,
             ARG_("obj") ),
    COMPILER_(T_RETURN_VOID),

    COMPILER_(T_ASS_LVAR,
             ARG("lvar", SyntaxTreeIntObjInt), ARG_("rhs")),
    COMPILER_(T_UNB_LVAR,
             ARG("lvar", SyntaxTreeLVar)),
    COMPILER_(T_ASS_HVAR,
             ARG("hvar", SyntaxTreeHVar), ARG_("rhs")),
    COMPILER_(T_UNB_HVAR,
             ARG("hvar", SyntaxTreeHVar)),
    COMPILER_(T_ASS_GVAR,
             ARG("gvar", SyntaxTreeGVar), ARG_("rhs")),
    COMPILER_(T_UNB_GVAR,
             ARG("gvar", SyntaxTreeGVar)),
    COMPILER_(T_ASS_LIST,
              ARG_("list"), ARG_("pos"), ARG_("rhs")),
    COMPILER_(T_ASSS_LIST,
              ARG_("list"), ARG_("poss"), ARG_("rhss")),
    COMPILER_(T_ASS_LIST_LEV,
              ARG_("lists"), ARG_("pos"), ARG_("rhss"), ARG("level", SyntaxTreeIntObjInt)),
    COMPILER_(T_ASSS_LIST_LEV,
              ARG_("lists"), ARG_("poss"), ARG_("rhss"), ARG("level", SyntaxTreeIntObjInt)),
    COMPILER_(T_UNB_LIST,
             ARG_("list"), ARG_("pos")),
    COMPILER_(T_ASS_REC_NAME,
              ARG_("record"), ARG("rnam", SyntaxTreeRNam), ARG_("rhs")),
    COMPILER_(T_ASS_REC_EXPR,
              ARG_("record"), ARG_("expression"), ARG_("rhs")),
    COMPILER_(T_UNB_REC_NAME,
              ARG_("record"), ARG("rnam", SyntaxTreeRNam)),
    COMPILER_(T_UNB_REC_EXPR,
              ARG_("record"), ARG_("expression")),
    COMPILER_(T_ASS_POSOBJ,
              ARG_("posobj"), ARG_("pos"), ARG_("rhs")),
    COMPILER_(T_ASSS_POSOBJ,
              ARG_("posobj"), ARG_("poss"), ARG_("rhss")),
    COMPILER_(T_ASS_POSOBJ_LEV,
              ARG_("lists"), ARG_("pos"), ARG_("rhss"), ARG("level", SyntaxTreeIntObjInt)),
    COMPILER_(T_ASSS_POSOBJ_LEV,
              ARG_("lists"), ARG_("poss"), ARG_("rhss"), ARG("level", SyntaxTreeIntObjInt)),
    COMPILER_(T_UNB_POSOBJ,
              ARG_("posobj"), ARG_("pos")),
    COMPILER_(T_ASS_COMOBJ_NAME,
              ARG_("comobj"), ARG("rnam", SyntaxTreeRNam)),
    COMPILER_(T_ASS_COMOBJ_EXPR,
              ARG_("comobj"), ARG_("expression"), ARG_("rhs")),
    COMPILER_(T_UNB_COMOBJ_NAME,
              ARG_("comobj"), ARG_("name")),
    COMPILER_(T_UNB_COMOBJ_EXPR,
              ARG_("comobj"), ARG_("expression")),

    COMPILER(T_INFO, SyntaxTreeInfo),
    COMPILER_(T_ASSERT_2ARGS,
              ARG_("level"), ARG_("condition")),
    COMPILER_(T_ASSERT_3ARGS,
              ARG_("level"), ARG_("condition"), ARG_("message")),

    COMPILER(T_EMPTY, SyntaxTreeDefaultCompiler),

    COMPILER(T_PROCCALL_OPTS, SyntaxTreeDefaultCompiler,
             ARG_("opts"), ARG_("call")),

    COMPILER(T_ATOMIC, SyntaxTreeDefaultCompiler),
};

static const CompilerT ExprCompilers[] = {
    COMPILER(T_FUNCCALL_0ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_1ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_2ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_3ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_4ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_5ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_6ARGS, SyntaxTreeFunccall),
    COMPILER(T_FUNCCALL_XARGS, SyntaxTreeFunccall),

    COMPILER(T_FUNC_EXPR, SyntaxTreeFuncExpr),

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
    COMPILER_(T_INV, ARG_("op")),
    COMPILER_(T_QUO, ARG_("left"), ARG_("right")),
    COMPILER_(T_MOD, ARG_("left"), ARG_("right")),
    COMPILER_(T_POW, ARG_("left"), ARG_("right")),

    COMPILER(T_INTEXPR, SyntaxTreeIntExpr),
    COMPILER(T_INT_EXPR, SyntaxTreeIntExpr),
    COMPILER_(T_TRUE_EXPR),
    COMPILER_(T_FALSE_EXPR),
    COMPILER_(T_TILDE_EXPR),
    COMPILER(T_CHAR_EXPR, SyntaxTreeCharExpr),
    COMPILER(T_PERM_EXPR, SyntaxTreePermExpr),
    COMPILER_(T_PERM_CYCLE),
    COMPILER(T_LIST_EXPR, SyntaxTreeListExpr),
    COMPILER(T_LIST_TILD_EXPR, SyntaxTreeListExpr),
    COMPILER(T_RANGE_EXPR, SyntaxTreeRangeExpr),
    COMPILER(T_STRING_EXPR, SyntaxTreeStringExpr),
    COMPILER(T_REC_EXPR, SyntaxTreeRecExpr),
    COMPILER_(T_REC_TILD_EXPR),

    COMPILER(T_REFLVAR, SyntaxTreeRefLVar),
    COMPILER(T_ISB_LVAR, SyntaxTreeRefLVar),
    COMPILER_(T_REF_HVAR, ARG("hvar", SyntaxTreeHVar)),
    COMPILER_(T_ISB_HVAR, ARG("hvar", SyntaxTreeHVar)),
    COMPILER_(T_REF_GVAR, ARG("gvar", SyntaxTreeGVar)),
    COMPILER_(T_ISB_GVAR, ARG("gvar", SyntaxTreeGVar)),

    COMPILER_(T_ELM_LIST,
              ARG_("list"), ARG_("pos")),
    COMPILER_(T_ELMS_LIST,
              ARG_("list"), ARG_("poss")),
    COMPILER_(T_ELM_LIST_LEV,
              ARG_("lists"), ARG_("pos"), ARG_("level")),
    COMPILER_(T_ELMS_LIST_LEV,
              ARG_("lists"), ARG_("poss"), ARG_("level")),
    COMPILER_(T_ISB_LIST,
              ARG_("list"), ARG_("pos")),
    COMPILER_(T_ELM_REC_NAME,
              ARG_("record"), ARG("name", SyntaxTreeRNam)),
    COMPILER_(T_ELM_REC_EXPR,
              ARG_("record"), ARG_("expression")),
    COMPILER_(T_ISB_REC_NAME,
              ARG_("record"), ARG("name", SyntaxTreeRNam)),
    COMPILER_(T_ISB_REC_EXPR,
              ARG_("record"), ARG_("expression")),
    COMPILER_(T_ELM_POSOBJ,
              ARG_("posobj"), ARG_("pos")),
    COMPILER_(T_ELMS_POSOBJ,
              ARG_("posobj"), ARG_("pos")),
    COMPILER_(T_ELM_POSOBJ_LEV,
              ARG_("posobj"), ARG_("pos"), ARG_("level")),
    COMPILER_(T_ELMS_POSOBJ_LEV,
              ARG_("posobj"), ARG_("poss"), ARG_("level")),
    COMPILER_(T_ISB_POSOBJ,
              ARG_("posobj"), ARG_("pos")),
    COMPILER_(T_ELM_COMOBJ_NAME,
              ARG_("comobj"), ARG("name", SyntaxTreeRNam)),
    COMPILER_(T_ELM_COMOBJ_EXPR,
              ARG_("comobj"), ARG_("expression")),
    COMPILER_(T_ISB_COMOBJ_NAME,
              ARG_("comobj"), ARG("name", SyntaxTreeRNam)),
    COMPILER_(T_ISB_COMOBJ_EXPR,
              ARG_("comobj"), ARG_("expression")),

    COMPILER_(T_FUNCCALL_OPTS,
              ARG_("opts"), ARG_("call")),

    COMPILER(T_FLOAT_EXPR_EAGER, SyntaxTreeFloatEager),
    COMPILER(T_FLOAT_EXPR_LAZY, SyntaxTreeFloatLazy),

    /* TODO: What do these do? */
    COMPILER_(T_ELM2_LIST),
    COMPILER_(T_ELMX_LIST),
    COMPILER_(T_ASS2_LIST),
    COMPILER_(T_ASSX_LIST),
};

Obj FuncSYNTAX_TREE(Obj self, Obj func)
{
    Obj result;

    if (!IS_FUNC(func)) {
        ErrorQuit("SYNTAX_TREE: <func> must be a function (not a %s)",
                  (Int)TNAM_OBJ(func), 0L);
    }

    result = NewSyntaxTreeNode("T_FUNC_EXPR");
    return SyntaxTreeFunc(result, func);
}

static StructGVarFunc GVarFuncs[] = { { "SYNTAX_TREE", 1, "func",
                                        FuncSYNTAX_TREE,
                                        "src/syntaxtree.c:SYNTAX_TREE" },
                                      { 0 } };

static Int InitKernel(StructInitInfo * module)
{
    UInt i;

    /* init filters and functions */
    InitHdlrFuncsFromTable(GVarFuncs);

    /* TODO: Needed? Cleaner? Remove? */
    /* check TNUMS table */
    for (i = 0; i < LAST_STAT_TNUM; i++) {
        if (!(StatCompilers[i].tnum == i)) {
            fprintf(stderr, "Warning, statement tnum desync %jd %jd %s\n",
                    StatCompilers[i].tnum, i, StatCompilers[i].name);
        }
    }

    for (i = FIRST_EXPR_TNUM; i < LAST_EXPR_TNUM; i++) {
        if (!(ExprCompilers[i - FIRST_EXPR_TNUM].tnum == i)) {
            fprintf(stderr, "Warning, expression tnum desync %jd %jd %s\n",
                    ExprCompilers[i - FIRST_EXPR_TNUM].tnum, i,
                    ExprCompilers[i - FIRST_EXPR_TNUM].name);
        }
    }
    return 0;
}

static Int PostRestore(StructInitInfo * module)
{
    return 0;
}

static Int InitLibrary(StructInitInfo * module)
{
    /* init filters and functions */
    InitGVarFuncsFromTable(GVarFuncs);

    /* return success */
    return PostRestore(module);
}

static StructInitInfo module = {
    MODULE_BUILTIN, /* type */
    "syntaxtree",   /* name */
    0,              /* revision entry of c file */
    0,              /* revision entry of h file */
    0,              /* version */
    0,              /* crc */
    InitKernel,     /* initKernel */
    InitLibrary,    /* initLibrary */
    0,              /* checkInit */
    0,              /* preSave */
    0,              /* postSave */
    PostRestore     /* postRestore */
};

StructInitInfo * InitInfoSyntaxTree(void)
{
    return &module;
}

/*E syntaxtree.c */
