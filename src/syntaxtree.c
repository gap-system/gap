/****************************************************************************
**
*W  syntaxtree.c
**
**
** TODO:
**  - Expressions vs Statements
*/
#include "system.h"
#include <stdarg.h>

#include "objects.h"

#include "exprs.h"
#include "stats.h"

#include "compiled.h"
#include "vars.h"

#include <ctype.h>

typedef UInt4 LVar;
typedef UInt4 HVar;
typedef UInt  GVar;

typedef Obj (*CompileFuncT)(Obj node, Expr expr);

typedef struct {
    UInt         tnum;
    CompileFuncT compile;
    const Char * name;
    UInt         arity;
    const Char * argnames[6];
} CompilerT;

static const CompilerT StatCompilers[];
static const CompilerT ExprCompilers[];

#define COMPILER_ARITY(...)                                                  \
    (sizeof((char * []){ __VA_ARGS__ }) / sizeof(char *))
#define COMPILER(tnum, compiler, ...)                                        \
    {                                                                        \
        tnum, compiler, #tnum, COMPILER_ARITY(__VA_ARGS__),                  \
        {                                                                    \
            __VA_ARGS__                                                      \
        }                                                                    \
    }

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

    if ((0 <= tnum) && (tnum < 128)) {
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

static Obj SyntaxTreeDefaultCompiler(Obj result, Expr expr)
{
    UInt      tnum;
    CompilerT comp;

    tnum = TNUM_EXPR(expr);

    if ((0 <= tnum) && (tnum < 128)) {
        comp = StatCompilers[tnum];
    }
    else if ((128 <= tnum) && (tnum < 256)) {
        comp = ExprCompilers[tnum - 128];
    }
    else {
        // error
    }

    for (int i = 0; i < comp.arity; i++) {
        AssPRec(result, RNamName(comp.argnames[i]),
                SyntaxTreeCompiler(ADDR_EXPR(expr)[i]));
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

    fexs = FEXS_FUNC(CURR_FUNC);
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

Obj SyntaxTreeRefLVar(Obj result, Expr expr)
{
    LVar lvar;

    if (IS_REFLVAR(expr)) {
        lvar = LVAR_REFLVAR(expr);
    }
    else {
        lvar = (LVar)(ADDR_EXPR(expr)[0]);
    }

    AssPRec(result, RNamName("lvar"), INTOBJ_INT(lvar));

    return result;
}

Obj SyntaxTreeIsbLVar(Obj result, Expr expr)
{
    LVar lvar;

    lvar = (LVar)(ADDR_EXPR(expr)[0]);

    AssPRec(result, RNamName("variable"), INTOBJ_INT(lvar));

    return result;
}

Obj SyntaxTreeRefHVar(Obj result, Expr expr)
{
    HVar hvar;

    hvar = (HVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("variable"), INTOBJ_INT(hvar));

    return result;
}

Obj SyntaxTreeRefGVar(Obj result, Expr expr)
{
    GVar gvar;

    gvar = (GVar)(ADDR_EXPR(expr)[0]);
    AssPRec(result, RNamName("name"), NameGVarObj(gvar));

    return result;
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

        pair = NEW_PREC(2);
        AssPRec(pair, RNamName("condition"), cond);
        AssPRec(pair, RNamName("then"), then);

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

    nr = SIZE_STAT(stat) / sizeof(Stat);
    body = NEW_PLIST(T_PLIST, nr);
    SET_LEN_PLIST(body, nr);
    AssPRec(result, RNamName("body"), body);

    for (i = 2; i < SIZE_STAT(stat) / sizeof(Stat); i++) {
        SET_ELM_PLIST(body, i - 1, SyntaxTreeCompiler(ADDR_STAT(stat)[i]));
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

Obj SyntaxTreeAssLVar(Obj result, Stat stat)
{
    Obj lvar;
    Obj rhs;

    lvar = INTOBJ_INT(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("lvar"), lvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeAssHVar(Obj result, Stat stat)
{
    Obj hvar;
    Obj rhs;

    hvar = INTOBJ_INT(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("hvar"), hvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeAssGVar(Obj result, Stat stat)
{
    Obj gvar;
    Obj rhs;

    gvar = NameGVarObj(ADDR_STAT(stat)[0]);
    rhs = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("gvar"), gvar);
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbGVar(Obj result, Stat stat)
{
    Obj gvar;

    gvar = NameGVarObj(ADDR_STAT(stat)[0]);
    AssPRec(result, RNamName("gvar"), gvar);

    return result;
}

Obj SyntaxTreeAssListLev(Obj result, Stat stat)
{
    Obj lists;
    Obj pos;
    Obj rhss;
    Int level;

    lists = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    pos = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);
    rhss = SyntaxTreeCompiler(ADDR_STAT(stat)[2]);
    level = (Int)(ADDR_STAT(stat)[3]);

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("rhss"), rhss);
    AssPRec(result, RNamName("level"), INTOBJ_INT(level));

    return result;
}

Obj SyntaxTreeAsssListLev(Obj result, Stat stat)
{
    Obj lists;
    Obj poss;
    Obj rhss;
    Int level;

    lists = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    poss = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);
    rhss = SyntaxTreeCompiler(ADDR_STAT(stat)[2]);
    level = (Int)(ADDR_STAT(stat)[3]);

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("rhss"), rhss);
    AssPRec(result, RNamName("level"), INTOBJ_INT(level));

    return result;
}

Obj SyntaxTreeAssRecName(Obj result, Stat stat)
{
    Obj record;
    Obj rnam;
    Obj rhs;

    record = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    /* TODO: Record Access */
    rnam = INTOBJ_INT(ADDR_STAT(stat)[1]);
    rhs = SyntaxTreeCompiler(ADDR_STAT(stat)[2]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeAssRecExpr(Obj result, Stat stat)
{
    Obj record;
    Obj rnam;
    Obj rhs;

    record = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    rnam = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);
    rhs = SyntaxTreeCompiler(ADDR_STAT(stat)[2]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbRecName(Obj result, Stat stat)
{
    Obj record;
    Obj rnam;

    record = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    rnam = INTOBJ_INT(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));

    return result;
}

Obj SyntaxTreeUnbRecExpr(Obj result, Stat stat)
{
    Obj record;
    Obj rnam;

    record = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    rnam = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));

    return result;
}

Obj SyntaxTreeAssPosObjLev(Obj result, Stat stat)
{
    Obj lists;
    Obj pos;
    Obj rhss;
    Int level;

    lists = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    pos = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);
    rhss = SyntaxTreeCompiler(ADDR_STAT(stat)[2]);
    level = (Int)(ADDR_STAT(stat)[3]);

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("pos"), pos);
    AssPRec(result, RNamName("rhss"), rhss);
    AssPRec(result, RNamName("level"), INTOBJ_INT(level));

    return result;
}

Obj SyntaxTreeAsssPosObjLev(Obj result, Stat stat)
{
    Obj lists;
    Obj poss;
    Obj rhss;
    Int level;

    lists = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    poss = SyntaxTreeCompiler(ADDR_STAT(stat)[1]);
    rhss = SyntaxTreeCompiler(ADDR_STAT(stat)[2]);
    level = (Int)(ADDR_STAT(stat)[3]);

    AssPRec(result, RNamName("lists"), lists);
    AssPRec(result, RNamName("poss"), poss);
    AssPRec(result, RNamName("rhss"), rhss);
    AssPRec(result, RNamName("level"), INTOBJ_INT(level));

    return result;
}

Obj SyntaxTreeAssComObjName(Obj result, Stat stat)
{
    Obj  record;
    UInt rnam;
    Obj  rhs;

    record = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    rnam = (UInt)(ADDR_STAT(stat)[1]);
    rhs = SyntaxTreeCompiler(ADDR_STAT(stat)[2]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));
    AssPRec(result, RNamName("rhs"), rhs);

    return result;
}

Obj SyntaxTreeUnbComObjName(Obj result, Stat stat)
{
    Obj  record;
    UInt rnam;

    record = SyntaxTreeCompiler(ADDR_STAT(stat)[0]);
    rnam = (UInt)(ADDR_STAT(stat)[1]);

    AssPRec(result, RNamName("record"), record);
    AssPRec(result, RNamName("rnam"), INTOBJ_INT(rnam));

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
            C_NEW_STRING_CONST(str, "localvar");
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
            C_NEW_STRING_CONST(str, "localvar");
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
    COMPILER(T_SEQ_STAT7, SyntaxTreeSeqStat), COMPILER(T_IF, SyntaxTreeIf),
    COMPILER(T_IF_ELSE, SyntaxTreeIf), COMPILER(T_IF_ELIF, SyntaxTreeIf),
    COMPILER(T_IF_ELIF_ELSE, SyntaxTreeIf), COMPILER(T_FOR, SyntaxTreeFor),
    COMPILER(T_FOR2, SyntaxTreeFor), COMPILER(T_FOR3, SyntaxTreeFor),
    COMPILER(T_FOR_RANGE, SyntaxTreeFor),
    COMPILER(T_FOR_RANGE2, SyntaxTreeFor),
    COMPILER(T_FOR_RANGE3, SyntaxTreeFor), COMPILER(T_WHILE, SyntaxTreeWhile),
    COMPILER(T_WHILE2, SyntaxTreeWhile), COMPILER(T_WHILE3, SyntaxTreeWhile),
    COMPILER(T_REPEAT, SyntaxTreeRepeat),
    COMPILER(T_REPEAT2, SyntaxTreeRepeat),
    COMPILER(T_REPEAT3, SyntaxTreeRepeat),
    COMPILER(T_BREAK, SyntaxTreeDefaultCompiler),
    COMPILER(T_CONTINUE, SyntaxTreeDefaultCompiler),
    COMPILER(T_RETURN_OBJ, SyntaxTreeDefaultCompiler, "obj"),
    COMPILER(T_RETURN_VOID, SyntaxTreeDefaultCompiler),

    COMPILER(T_ASS_LVAR, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_01, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_02, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_03, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_04, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_05, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_06, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_07, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_08, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_09, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_10, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_11, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_12, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_13, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_14, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_15, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_ASS_LVAR_16, SyntaxTreeAssLVar, "lvar", "rhs"),
    COMPILER(T_UNB_LVAR, SyntaxTreeRefLVar),
    COMPILER(T_ASS_HVAR, SyntaxTreeAssHVar),
    COMPILER(T_UNB_HVAR, SyntaxTreeRefHVar),
    COMPILER(T_ASS_GVAR, SyntaxTreeAssGVar),
    COMPILER(T_UNB_GVAR, SyntaxTreeRefGVar),
    COMPILER(T_ASS_LIST, SyntaxTreeDefaultCompiler, "list", "pos", "rhs"),
    COMPILER(T_ASSS_LIST, SyntaxTreeDefaultCompiler, "list", "poss", "rhss"),
    COMPILER(T_ASS_LIST_LEV, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSS_LIST_LEV, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_LIST, SyntaxTreeDefaultCompiler, "list", "pos"),
    COMPILER(T_ASS_REC_NAME, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_REC_EXPR,
             SyntaxTreeDefaultCompiler,
             "record",
             "expression",
             "rhs"),
    COMPILER(T_UNB_REC_NAME, SyntaxTreeDefaultCompiler),
    COMPILER(
        T_UNB_REC_EXPR, SyntaxTreeDefaultCompiler, "record", "expression"),
    COMPILER(T_ASS_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "pos", "rhs"),
    COMPILER(
        T_ASSS_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "poss", "rhss"),
    COMPILER(T_ASS_POSOBJ_LEV, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSS_POSOBJ_LEV, SyntaxTreeDefaultCompiler),
    COMPILER(T_UNB_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "pos"),
    COMPILER(T_ASS_COMOBJ_NAME, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS_COMOBJ_EXPR,
             SyntaxTreeDefaultCompiler,
             "comobj",
             "expression",
             "rhs"),
    COMPILER(T_UNB_COMOBJ_NAME, SyntaxTreeDefaultCompiler),
    COMPILER(
        T_UNB_COMOBJ_EXPR, SyntaxTreeDefaultCompiler, "comobj", "expression"),

    COMPILER(T_INFO, SyntaxTreeInfo),
    COMPILER(T_ASSERT_2ARGS, SyntaxTreeDefaultCompiler, "level", "condition"),
    COMPILER(T_ASSERT_3ARGS,
             SyntaxTreeDefaultCompiler,
             "level",
             "condition",
             "message"),

    COMPILER(T_EMPTY, SyntaxTreeDefaultCompiler),

    COMPILER(T_PROCCALL_OPTS, SyntaxTreeDefaultCompiler, "opts", "call"),

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

    COMPILER(T_OR, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_AND, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_NOT, SyntaxTreeDefaultCompiler, "op"),
    COMPILER(T_EQ, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_NE, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_LT, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_GE, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_GT, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_LE, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_IN, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_SUM, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_AINV, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_DIFF, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_PROD, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_INV, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_QUO, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_MOD, SyntaxTreeDefaultCompiler, "left", "right"),
    COMPILER(T_POW, SyntaxTreeDefaultCompiler, "left", "right"),

    COMPILER(T_INTEXPR, SyntaxTreeIntExpr),
    COMPILER(T_INT_EXPR, SyntaxTreeIntExpr),
    COMPILER(T_TRUE_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_FALSE_EXPR, SyntaxTreeDefaultCompiler),
    COMPILER(T_CHAR_EXPR, SyntaxTreeCharExpr),
    COMPILER(T_PERM_EXPR, SyntaxTreePermExpr),
    COMPILER(T_PERM_CYCLE, SyntaxTreeDefaultCompiler),
    COMPILER(T_LIST_EXPR, SyntaxTreeListExpr),
    COMPILER(T_LIST_TILD_EXPR, SyntaxTreeListExpr),
    COMPILER(T_RANGE_EXPR, SyntaxTreeRangeExpr),
    COMPILER(T_STRING_EXPR, SyntaxTreeStringExpr),
    COMPILER(T_REC_EXPR, SyntaxTreeRecExpr),
    COMPILER(T_REC_TILD_EXPR, SyntaxTreeRecExpr),

    COMPILER(T_REFLVAR, SyntaxTreeRefLVar),

    /* TODO: Are these, or were these, REFLVAR0-15? */
    COMPILER(128 + 41, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 42, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 43, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 44, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 45, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 46, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 47, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 48, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 49, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 50, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 51, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 52, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 53, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 54, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 55, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 56, SyntaxTreeDefaultCompiler),
    COMPILER(128 + 57, SyntaxTreeDefaultCompiler),

    COMPILER(T_ISB_LVAR, SyntaxTreeRefLVar, "var"),
    COMPILER(T_REF_HVAR, SyntaxTreeRefHVar, "var"),
    COMPILER(T_ISB_HVAR, SyntaxTreeRefHVar, "var"),
    COMPILER(T_REF_GVAR, SyntaxTreeRefGVar, "var"),
    COMPILER(T_ISB_GVAR, SyntaxTreeRefGVar, "var"),
    COMPILER(T_ELM_LIST, SyntaxTreeDefaultCompiler, "list", "pos"),
    COMPILER(T_ELMS_LIST, SyntaxTreeDefaultCompiler, "list", "poss"),
    COMPILER(
        T_ELM_LIST_LEV, SyntaxTreeDefaultCompiler, "lists", "pos", "level"),
    COMPILER(
        T_ELMS_LIST_LEV, SyntaxTreeDefaultCompiler, "lists", "poss", "level"),
    COMPILER(T_ISB_LIST, SyntaxTreeDefaultCompiler, "list", "pos"),
    COMPILER(T_ELM_REC_NAME, SyntaxTreeDefaultCompiler, "record", "name"),
    COMPILER(
        T_ELM_REC_EXPR, SyntaxTreeDefaultCompiler, "record", "expression"),
    COMPILER(T_ISB_REC_NAME, SyntaxTreeDefaultCompiler, "record", "name"),
    COMPILER(
        T_ISB_REC_EXPR, SyntaxTreeDefaultCompiler, "record", "expression"),
    COMPILER(T_ELM_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "pos"),
    COMPILER(T_ELMS_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "pos"),
    COMPILER(T_ELM_POSOBJ_LEV,
             SyntaxTreeDefaultCompiler,
             "posobj",
             "pos",
             "level"),
    COMPILER(T_ELMS_POSOBJ_LEV,
             SyntaxTreeDefaultCompiler,
             "posobj",
             "poss",
             "level"),
    COMPILER(T_ISB_POSOBJ, SyntaxTreeDefaultCompiler, "posobj", "pos"),
    COMPILER(T_ELM_COMOBJ_NAME, SyntaxTreeDefaultCompiler, "comobj", "name"),
    COMPILER(
        T_ELM_COMOBJ_EXPR, SyntaxTreeDefaultCompiler, "comobj", "expression"),
    COMPILER(T_ISB_COMOBJ_NAME, SyntaxTreeDefaultCompiler, "comobj", "name"),
    COMPILER(
        T_ISB_COMOBJ_EXPR, SyntaxTreeDefaultCompiler, "comobj", "expression"),

    COMPILER(T_FUNCCALL_OPTS, SyntaxTreeDefaultCompiler, "opts", "call"),

    COMPILER(T_FLOAT_EXPR_EAGER, SyntaxTreeFloatEager),
    COMPILER(T_FLOAT_EXPR_LAZY, SyntaxTreeFloatLazy),

    /* TODO: What do these do? */
    COMPILER(T_ELM2_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ELMX_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASS2_LIST, SyntaxTreeDefaultCompiler),
    COMPILER(T_ASSX_LIST, SyntaxTreeDefaultCompiler),
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
    /* init filters and functions */
    InitHdlrFuncsFromTable(GVarFuncs);

    /* TODO: Needed? Cleaner? Remove? */
    /* check TNUMS table */
    for (UInt i = 0; i < LAST_STAT_TNUM; i++) {
        if (!(StatCompilers[i].tnum == i)) {
            fprintf(stderr, "Warning, statement tnum desync %jd %jd %s\n",
                    StatCompilers[i].tnum, i, StatCompilers[i].name);
        }
    }

    for (UInt i = FIRST_EXPR_TNUM; i < LAST_EXPR_TNUM; i++) {
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
